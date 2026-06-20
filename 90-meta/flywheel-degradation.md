---
type: index
title: flywheel 降级方案
source: P2-6 改进项 + 多 agent 网络能力不对称经验
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: mature
tags: [meta, flywheel, resilience, degradation, knowledge-management]
---

# flywheel 降级方案

> 定义 flywheel 引擎不可用时知识库的降级流程，确保 KB 写入/校验/同步不中断。
> 关联改进项：P2-6（flywheel 降级方案）
> 关联问题：B4（flywheel 依赖单一）/ K1（flywheel 不可用时无降级）

---

## 1. flywheel 依赖矩阵

| 功能 | 依赖 flywheel？ | 降级替代 |
|------|----------------|----------|
| `kb lint`（frontmatter/wikilink/cycle 校验） | 是 | `wiki-validator.ps1`（P1-2，8 项检查 + DFS cycle） |
| `kb stats`（页面数/边数/PageRank） | 是 | `index-generator.ps1` 统计页面数 + 手动 grep wikilink |
| `kb graph-viz`（Mermaid 图谱） | 是 | `index.md` 表格视图（无图谱但可导航） |
| `kb compile`（raw → wiki 编译） | 是（需 LLM API Key） | 手动整理 raw → wiki（agent 直接写 OKF 格式页） |
| `kb evolve`（知识演进） | 是（需 LLM API Key） | 跳过（非关键路径） |
| `kb ingest`（文件入库） | 是 | 手动放文件到 wiki/ 对应 type 子目录 |
| pre-commit hook lint | 是（调 `kb lint`） | 降级为调 `wiki-validator.ps1 -All` |
| 索引生成 | 否 | `index-generator.ps1`（独立运行） |
| 并发写入锁 | 否 | `kb-lock.ps1`（独立运行） |
| 安全 push | 否 | `kb-safe-push.ps1`（独立运行） |

**结论**：flywheel 不可用时，**写入/锁/push/索引不受影响**；**lint 有替代**；**stats/graph-viz/compile/evolve 降级**。

---

## 2. 降级触发条件

满足任一即触发降级：

1. **flywheel MCP 连接失败** — `kb_stats` / `kb_lint` 调用超时或返回连接错误
2. **flywheel 引擎文件缺失** — `_kb_flywheel/src` 目录被删或 PYTHONPATH 错误
3. **Python 环境损坏** — `python` 不可用或依赖包缺失
4. **LLM API Key 未配置/失效** — `kb compile` / `kb evolve` 返回 401/403
5. **手动降级** — 用户主动切换（"flywheel 挂了，用降级模式"）

---

## 3. 降级模式操作手册

### 3.1 检测 flywheel 是否可用

```powershell
# 快速检测脚本
$flywheelOk = $false
try {
    $env:KB_PROJECT_ROOT = "d:\xiangmu\_kb"
    $result = & python -c "import kb; print('ok')" 2>&1
    if ($LASTEXITCODE -eq 0 -and $result -match "ok") {
        $flywheelOk = $true
    }
} catch {
    $flywheelOk = $false
}
Write-Host "flywheel available: $flywheelOk"
```

### 3.2 降级模式 A：lint 替代

| 正常模式 | 降级模式 |
|----------|----------|
| `kb_lint`（MCP） | `powershell -File d:\xiangmu\_kb\90-meta\wiki-validator.ps1 -All` |
| pre-commit hook 调 `kb lint` | pre-commit hook 调 `wiki-validator.ps1 -Target <staged-file>` |

**pre-commit hook 降级切换**：
```powershell
# 在 pre-commit.ps1 中添加降级逻辑
$flywheelOk = & python -c "import kb; print('ok')" 2>&1
if ($LASTEXITCODE -eq 0) {
    # 正常模式：用 flywheel kb lint
    kb lint --wiki-dir d:\xiangmu\_kb\wiki
} else {
    # 降级模式：用 wiki-validator.ps1
    powershell -File d:\xiangmu\_kb\90-meta\wiki-validator.ps1 -All
}
```

### 3.3 降级模式 B：stats 替代

| 正常模式 | 降级模式 |
|----------|----------|
| `kb_stats`（页面数/边数/PageRank） | `index-generator.ps1` 统计页面数 + grep `[[` 统计 wikilink 数 |

```powershell
# 降级 stats
$pageCount = (Get-ChildItem d:\xiangmu\_kb\wiki -Recurse -Filter *.md).Count
$wikilinkCount = (Select-String -Path d:\xiangmu\_kb\wiki\**\*.md -Pattern '\[\[').Count
Write-Host "Pages: $pageCount, Wikilinks: $wikilinkCount"
```

### 3.4 降级模式 C：compile 替代（raw → wiki）

flywheel `kb compile` 用 LLM 把 raw 笔记编译成 OKF 格式 wiki 页。降级模式下：

1. **agent 直接写 OKF 页** — 按 [page-templates.md](page-templates.md) 模板手动创建 wiki 页
2. **跳过自动编译** — raw/ 文件保留，等 flywheel 恢复后批量编译
3. **手动校验** — 用 `wiki-validator.ps1 -Target <new-page>` 校验

### 3.5 降级模式 D：graph-viz 替代

| 正常模式 | 降级模式 |
|----------|----------|
| `kb_graph_viz`（Mermaid 图谱） | 用 Obsidian 打开 `_kb/` 查看图谱视图（已配置，见 [obsidian-plugins.md](obsidian-plugins.md)） |

---

## 4. 降级模式下的 agent SOP

### 4.1 写入流程（降级）

```
1. agent 生成 wiki 页（按 page-templates.md 模板）
2. 校验：powershell -File d:\xiangmu\_kb\90-meta\wiki-validator.ps1 -Target <new-page>
3. 加锁：powershell -File d:\xiangmu\_kb\90-meta\kb-lock.ps1 acquire -Holder <agent> -Purpose "<目的>"
4. 安全 push：powershell -File d:\xiangmu\_kb\90-meta\kb-safe-push.ps1 -CommitMsg "<msg>" -Holder <agent>
5. （锁在 safe-push 内自动释放）
```

### 4.2 健康检查（降级）

`health-dashboard.ps1` 需检测 flywheel 状态并标注降级模式：

```powershell
# 在 health-dashboard.ps1 中添加
$flywheelStatus = if ($flywheelOk) { "available" } else { "DEGRADED" }
```

---

## 5. 恢复流程

当 flywheel 恢复可用时：

1. **验证恢复**：跑 `kb_stats` 确认返回正常
2. **补跑 lint**：`kb_lint` 全量校验降级期间写入的页面
3. **补跑 compile**（如有 raw 积压）：`kb_compile_scan` 扫描 raw/ 批量编译
4. **更新图谱**：`kb_graph_viz` 重新生成 Mermaid 图谱
5. **切换 pre-commit**：恢复 flywheel lint 模式
6. **记录**：在 [vault-changelog.md](vault-changelog.md) 记录降级时段 + 恢复时间

---

## 6. 降级模式能力对照表

| 能力 | 正常 | 降级 | 影响 |
|------|------|------|------|
| 写入 wiki 页 | ✅ | ✅ | 无影响 |
| 并发写入锁 | ✅ | ✅ | 无影响 |
| 安全 push | ✅ | ✅ | 无影响 |
| 索引生成 | ✅ | ✅ | 无影响 |
| frontmatter 校验 | ✅ | ✅ | 无影响（wiki-validator 替代） |
| cycle 检测 | ✅ | ✅ | 无影响（DFS 替代） |
| 页面数统计 | ✅ | ⚠️ | 降级（无 PageRank） |
| 知识图谱 | ✅ | ⚠️ | 降级（用 Obsidian 替代） |
| raw → wiki 编译 | ✅ | ❌ | 不可用（手动写） |
| 知识演进 | ✅ | ❌ | 不可用（跳过） |

---

## 7. 预防措施

1. **定期备份 flywheel 引擎** — `_kb_flywheel/` 纳入 git 管理
2. **LLM API Key 冗余** — 配置至少 2 个 provider（如 OpenAI + Anthropic），P2-1 跟进
3. **降级演练** — 每月一次手动触发降级模式，验证替代流程可用
4. **健康检查** — `health-dashboard.ps1` 每日检测 flywheel 状态，降级时标红

---

## 8. 相关文档

- [km-agent-workflow.md](km-agent-workflow.md) — KB agent 正常工作流
- [page-templates.md](page-templates.md) — 降级模式下手动写页的模板
- [concurrent-write-protocol.md](concurrent-write-protocol.md) — 写入锁协议（降级不受影响）
- [obsidian-plugins.md](obsidian-plugins.md) — graph-viz 降级替代方案
