---
type: index
title: 文档联动机制
source: P2-13 改进项
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: mature
tags: [meta, documentation, sync, automation, git-hooks]
---

# 文档联动机制

> 定义代码/配置变更时提示更新文档的机制，防止文档与代码脱节。
> 关联改进项：P2-13（文档联动机制）
> 关联问题：N3（代码/配置变更时文档未同步更新）

---

## 1. 问题分析

### 1.1 文档脱节场景

| 场景 | 后果 | 频率 |
|------|------|------|
| 修改脚本参数签名，未更新使用文档 | 用户按旧文档调用报错 | 高 |
| 新增脚本，未更新 index/SYSTEM-HEALTH | 脚本不可见，重复造轮子 | 高 |
| 修改目录结构，未更新 AGENTS.md | agent 按旧结构找不到文件 | 中 |
| 修改 frontmatter 字段规则，未更新模板 | 新页面用旧规则，lint 报错 | 中 |
| 删除脚本，未清理引用 | 死链接，health-dashboard 报错 | 低 |

### 1.2 根因

- 无自动化检测：git commit 时只跑 lint/secret scan，不检查文档同步
- 无责任分配：谁改代码谁负责更新文档，但容易忘
- 无提醒机制：即使检测到脱节，也无通知渠道

---

## 2. 联动机制设计

### 2.1 三层防线

```
Layer 1: pre-commit 检测（提交时）
  ↓ 检测到代码变更涉及文档关联项
Layer 2: 提醒输出（commit 时打印提醒）
  ↓ 用户决定是否更新文档
Layer 3: 健康检查（每日 health-dashboard）
  ↓ 检测文档与代码的一致性
```

### 2.2 触发规则

| 变更类型 | 检测方式 | 提醒文档 |
|----------|----------|----------|
| `_meta/*.ps1` 新增/删除 | 文件名对比 index.md | 更新 SYSTEM-HEALTH.md 脚本清单 |
| `_kb/90-meta/*.ps1` 新增/删除 | 文件名对比 index.md | 更新 90-meta/index.md |
| `_meta/*.ps1` 参数签名变更 | `param()` 块 diff | 更新对应使用文档 |
| `_kb/wiki/` 目录结构变更 | 子目录数对比 | 更新 moc-ai-toolchain.md |
| `AGENTS.md` 变更 | 文件 diff | 检查所有项目 AGENTS.md 是否需同步 |
| `PROJECT_STATUS.md` 变更 | status 字段 diff | 更新 projects-registry.json |
| `page-templates.md` 变更 | 文件 diff | 检查现有页面是否符合新模板 |

---

## 3. 实现：doc-sync-check.ps1

### 3.1 脚本位置

`d:\xiangmu\_meta\doc-sync-check.ps1`（工作区级，跨项目检测）

### 3.2 检测模式

```powershell
# 模式 1: 检测 staged 文件（pre-commit 集成）
.\doc-sync-check.ps1 -Mode staged

# 模式 2: 全量检测（health-dashboard 集成）
.\doc-sync-check.ps1 -Mode full

# 模式 3: 检测特定文件
.\doc-sync-check.ps1 -Mode file -Path "d:\xiangmu\_meta\kb-lock.ps1"
```

### 3.3 输出格式

```
[doc-sync] Checking staged files...
[doc-sync] WARNING: _meta/new-script.ps1 is new but not in SYSTEM-HEALTH.md
  → Suggestion: run health-dashboard.ps1 to update script list
[doc-sync] WARNING: _kb/90-meta/page-templates.md was modified
  → Suggestion: run wiki-validator.ps1 -All to check existing pages
[doc-sync] OK: 5 files checked, 2 warnings, 0 errors
```

### 3.4 集成点

| 集成点 | 方式 | 阻断？ |
|--------|------|--------|
| pre-commit hook | 在 secret scan 后追加 doc-sync 检测 | 否（仅提醒） |
| health-dashboard | 每日全量检测，结果写入 SYSTEM-HEALTH.md | 否（仅报告） |
| weekly-review | 周报中汇总本周 doc-sync 提醒数 | 否（仅统计） |

---

## 4. pre-commit hook 集成方案

在 `pre-commit.ps1` 的 Step 3（secret scan）后追加 Step 4（doc-sync check）：

```powershell
# === Step 4: Doc sync check (non-blocking) ===
Write-Host "[pre-commit] Checking doc sync..."
$syncScript = "d:\xiangmu\_meta\doc-sync-check.ps1"
if (Test-Path $syncScript) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $syncScript -Mode staged 2>&1 | ForEach-Object {
        Write-Host "  $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[pre-commit] doc-sync-check.ps1 not found, skipping." -ForegroundColor Gray
}
```

**关键设计**：doc-sync 检测**不阻断 commit**（只提醒），避免过度干扰开发流程。

---

## 5. 检测规则详解

### 5.1 脚本清单同步

```powershell
# 检测 _meta/*.ps1 是否都在 SYSTEM-HEALTH.md 中列出
$metaScripts = Get-ChildItem "d:\xiangmu\_meta\*.ps1" -Name
$healthContent = Get-Content "d:\xiangmu\_meta\SYSTEM-HEALTH.md" -Raw
foreach ($script in $metaScripts) {
    if ($healthContent -notmatch [regex]::Escape($script)) {
        Write-Host "WARNING: $script not found in SYSTEM-HEALTH.md"
    }
}
```

### 5.2 参数签名变更检测

```powershell
# 对比 staged 文件的 param() 块与上一版本
$stagedFile = "d:\xiangmu\_meta\kb-lock.ps1"
$oldContent = & git show HEAD:$relativePath 2>&1
$newContent = Get-Content $stagedFile -Raw

$oldParam = [regex]::Match($oldContent, '(?s)param\((.*?)\)').Groups[1].Value
$newParam = [regex]::Match($newContent, '(?s)param\((.*?)\)').Groups[1].Value

if ($oldParam -ne $newParam) {
    Write-Host "WARNING: Parameter signature changed in $stagedFile"
    Write-Host "  Old: param($oldParam)"
    Write-Host "  New: param($newParam)"
    Write-Host "  → Check if usage docs need updating"
}
```

### 5.3 目录结构变更检测

```powershell
# 检测 _kb/wiki/ 子目录数变化
$wikiSubdirs = (Get-ChildItem "d:\xiangmu\_kb\wiki" -Directory).Count
if ($wikiSubdirs -ne 5) {
    Write-Host "WARNING: wiki/ has $wikiSubdirs subdirs (expected 5 for flywheel type vocabulary)"
}
```

---

## 6. 文档责任矩阵

| 变更项 | 负责更新的文档 | 检测方式 |
|--------|---------------|----------|
| `_meta/*.ps1` | SYSTEM-HEALTH.md, agent-dispatcher-guide.md | 文件名对比 |
| `_kb/90-meta/*.ps1` | 90-meta/index.md | 文件名对比 |
| `_kb/90-meta/*.md`（模板/协议） | km-agent-workflow.md, page-templates.md | 内容引用检查 |
| `_kb/wiki/` 结构 | moc-ai-toolchain.md, index.md | 子目录数 + 文件数 |
| `AGENTS.md`（工作区） | 所有项目 AGENTS.md | 内容 diff |
| `PROJECT_STATUS.md` | projects-registry.json | status 字段对比 |
| `BACKLOG.md` | weekly review 报告 | 状态字段统计 |

---

## 7. 与现有系统的关系

| 现有系统 | 文档联动集成 |
|----------|-------------|
| pre-commit hook | 追加 doc-sync 检测（非阻断） |
| health-dashboard.ps1 | 追加 doc-sync 全量检测结果 |
| weekly-review.ps1 | 周报中汇总 doc-sync 提醒 |
| wiki-validator.ps1 | 检测模板变更后的页面合规性 |
| index-generator.ps1 | 检测新页面是否已收录 |

---

## 8. 实施计划

| 阶段 | 内容 | 状态 |
|------|------|------|
| Phase 1 | 设计文档（本文档） | done |
| Phase 2 | 实现 doc-sync-check.ps1（staged + full 模式） | pending |
| Phase 3 | 集成 pre-commit hook | pending |
| Phase 4 | 集成 health-dashboard | pending |
| Phase 5 | 验证 + 迭代 | pending |

---

## 9. 相关文档

- [concurrent-write-protocol.md](concurrent-write-protocol.md) — 写入协议
- [flywheel-degradation.md](flywheel-degradation.md) — 降级方案
- [page-templates.md](page-templates.md) — 页面模板
- `_meta/SYSTEM-HEALTH.md` — 系统健康度
- `_meta/health-dashboard.ps1` — 健康度聚合脚本
