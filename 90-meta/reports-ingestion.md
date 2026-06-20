---
type: index
title: reports 入库选项
source: P2-12 改进项
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: mature
tags: [meta, reports, git, optional-ingestion, configuration]
---

# 90-meta/reports/ 入库选项

> 定义各类报告（周报、成本报告、健康度报告）是否入库 Git 的配置机制。
> 关联改进项：P2-12（90-meta/reports/ 入库选项）
> 关联问题：E6（报告入库无选项，全入或全不入）

---

## 1. 问题分析

### 1.1 现状

| 报告 | 当前位置 | 是否入 Git | 问题 |
|------|----------|-----------|------|
| 周报 | `_retrospective/weekly/YYYY-WW.md` | 否（_retrospective 非 git repo） | 无法远程查看 |
| 成本报告 | `_meta/COST-REPORT.md` | 否（_meta 非 git repo） | 无法远程查看 |
| 系统健康度 | `_meta/SYSTEM-HEALTH.md` | 否 | 无法远程查看 |
| 项目健康度 | `_meta/PROJECTS-HEALTH.md` | 否 | 无法远程查看 |
| 项目归档报告 | `_meta/PROJECT-ARCHIVE-REPORT.md` | 否 | 无法远程查看 |
| KB 索引 | `_kb/90-meta/index.md` | 是（随 _kb repo） | 已入库 |
| MOC 页 | `_kb/90-meta/moc-auto-*.md` | 是 | 已入库 |

### 1.2 矛盾

- **全不入库**：报告无法远程查看，多 agent 接力时看不到历史报告
- **全入库**：报告频繁更新（每日/每周），Git 历史膨胀；含临时性数据，不适合永久保存
- **需要选项**：不同报告有不同的入库需求

---

## 2. 入库策略

### 2.1 三级入库策略

| 级别 | 含义 | 适用报告 |
|------|------|----------|
| **always** | 每次生成都入库 Git | KB 索引、MOC 页（知识资产） |
| **snapshot** | 定期快照入库（如每月） | 周报、成本报告月度汇总 |
| **never** | 永不入库（仅本地） | 系统健康度、项目健康度（临时状态） |

### 2.2 报告入库分类

| 报告 | 级别 | 理由 | 入库路径 |
|------|------|------|----------|
| KB 索引 (index.md) | always | 知识导航资产 | `_kb/90-meta/index.md` |
| MOC 页 (moc-auto-*.md) | always | 知识导航资产 | `_kb/90-meta/moc-auto-*.md` |
| 周报 (YYYY-WW.md) | snapshot | 历史价值，但每周更新太频繁 | `_kb/90-meta/reports/weekly/YYYY-WW.md`（月度批量入库） |
| 成本报告 (COST-REPORT.md) | never | 临时状态，每日覆盖 | `_meta/COST-REPORT.md`（仅本地） |
| 系统健康度 (SYSTEM-HEALTH.md) | never | 临时状态，每日覆盖 | `_meta/SYSTEM-HEALTH.md`（仅本地） |
| 项目健康度 (PROJECTS-HEALTH.md) | never | 临时状态 | `_meta/PROJECTS-HEALTH.md`（仅本地） |
| 项目归档报告 | snapshot | 季度归档有价值 | `_kb/90-meta/reports/archive/YYYY-QN.md`（季度入库） |
| KB 变更日志 (vault-changelog.md) | always | KB 演进历史 | `_kb/90-meta/vault-changelog.md` |

---

## 3. 配置机制

### 3.1 配置文件

在 `_kb/90-meta/reports-config.json` 中定义入库策略：

```json
{
  "reports": [
    {
      "name": "weekly-review",
      "source": "d:\\xiangmu\\_retrospective\\weekly\\",
      "pattern": "YYYY-WW.md",
      "level": "snapshot",
      "snapshotInterval": "monthly",
      "target": "90-meta/reports/weekly/",
      "gitRepo": "_kb"
    },
    {
      "name": "cost-report",
      "source": "d:\\xiangmu\\_meta\\COST-REPORT.md",
      "level": "never",
      "target": null,
      "gitRepo": null
    },
    {
      "name": "system-health",
      "source": "d:\\xiangmu\\_meta\\SYSTEM-HEALTH.md",
      "level": "never",
      "target": null,
      "gitRepo": null
    },
    {
      "name": "project-archive",
      "source": "d:\\xiangmu\\_meta\\PROJECT-ARCHIVE-REPORT.md",
      "level": "snapshot",
      "snapshotInterval": "quarterly",
      "target": "90-meta/reports/archive/",
      "gitRepo": "_kb"
    }
  ]
}
```

### 3.2 入库脚本

`_meta/reports-ingestor.ps1`（待实现）：

```powershell
# 按 reports-config.json 配置，将 snapshot 级报告复制到 _kb/90-meta/reports/ 并提交
.\reports-ingestor.ps1 -Mode snapshot    # 执行快照入库
.\reports-ingestor.ps1 -Mode full       # 执行所有 always + snapshot
.\reports-ingestor.ps1 -Mode check      # 检查哪些报告待入库
```

---

## 4. 目录结构

```
_kb/90-meta/
├── reports/                    # [新建] 报告快照入库目录
│   ├── weekly/                 # 周报快照（月度批量入库）
│   │   ├── 2026-W21.md
│   │   ├── 2026-W22.md
│   │   └── ...
│   ├── archive/                # 项目归档报告快照（季度入库）
│   │   ├── 2026-Q2.md
│   │   └── ...
│   └── monthly-summary/        # 月度汇总（可选）
│       ├── 2026-06.md
│       └── ...
├── reports-config.json         # 入库策略配置
├── index.md                    # always（已入库）
├── moc-auto-*.md               # always（已入库）
└── vault-changelog.md          # always（已入库）
```

---

## 5. 入库流程

### 5.1 自动入库（月度）

在 `weekly-review.ps1` 或 `weekly-review-opencode.ps1` 的月末执行时，触发 `reports-ingestor.ps1 -Mode snapshot`：

```
月末周报生成时：
  1. 生成本周周报 → _retrospective/weekly/YYYY-WW.md
  2. 检查是否月末 → 是则执行 reports-ingestor.ps1 -Mode snapshot
  3. reports-ingestor 复制本月所有周报到 _kb/90-meta/reports/weekly/
  4. kb-safe-push.ps1 提交到 Git
```

### 5.2 手动入库

```powershell
# 手动入库特定报告
.\reports-ingestor.ps1 -Mode full -ReportName weekly-review

# 检查待入库报告
.\reports-ingestor.ps1 -Mode check
```

---

## 6. .gitignore 配置

在 `_kb/.gitignore` 中排除不需要入库的临时文件：

```gitignore
# 临时报告（never 级别，不入库）
*.tmp.md
*.draft.md

# reports/ 目录只入库快照，不入库临时文件
90-meta/reports/*.tmp.md
```

---

## 7. 与现有系统的关系

| 现有系统 | 集成方式 |
|----------|----------|
| weekly-review.ps1 | 月末触发 reports-ingestor |
| health-dashboard.ps1 | never 级，不入库 |
| cost-tracker.ps1 | never 级，不入库 |
| project-archiver.ps1 | snapshot 级（季度），通过 reports-ingestor 入库 |
| kb-safe-push.ps1 | 入库时用此脚本提交 |
| pre-commit hook | 入库时正常跑 lint + secret scan |

---

## 8. 实施计划

| 阶段 | 内容 | 状态 |
|------|------|------|
| Phase 1 | 设计文档（本文档） | done |
| Phase 2 | 创建 reports-config.json | pending |
| Phase 3 | 创建 _kb/90-meta/reports/ 目录 | pending |
| Phase 4 | 实现 reports-ingestor.ps1 | pending |
| Phase 5 | 集成 weekly-review 月末触发 | pending |
| Phase 6 | 验证 + 迭代 | pending |

---

## 9. 决策记录

| 决策 | 选择 | 理由 |
|------|------|------|
| 周报入库频率 | 月度快照 | 每周入库太频繁，月度汇总有足够历史价值 |
| 成本报告入库 | never | 每日覆盖，无历史价值；月度汇总可从 git log 推算 |
| 健康度报告入库 | never | 临时状态，每日覆盖 |
| 项目归档报告入库 | 季度快照 | 季度归档有审计价值 |
| 配置格式 | JSON | 机器可读，脚本易解析 |

---

## 10. 相关文档

- [flywheel-degradation.md](flywheel-degradation.md) — 降级方案
- [doc-sync-mechanism.md](doc-sync-mechanism.md) — 文档联动
- `_meta/weekly-review.ps1` — 周报生成脚本
- `_meta/cost-tracker.ps1` — 成本追踪脚本
- `_meta/health-dashboard.ps1` — 健康度聚合脚本
