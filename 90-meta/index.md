---
type: index
title: 知识库总索引
source: '个人整理 + flywheel 知识库'
created: 2026-06-19
updated: 2026-06-20
confidence: stated
status: developing
tags: [index, meta]
---

# 知识库总索引

> vault 所有笔记的索引。三层架构：raw / wiki（OKF 5 type）/ 90-meta
> flywheel 兼容：wiki/ 下固定 5 个 type 子目录（entities / concepts / comparisons / summaries / synthesis），子目录名 = type

## 目录导航（三层架构）

- [raw/](../raw/) — 人类策展源（原始资料、笔记、截图，flywheel 期望的 raw 位置）
- [wiki/](../wiki/) — LLM 编译产物（OKF 格式，按 type 分子目录）
- [90-meta/](.) — vault 元信息（index / frontmatter 模板 / Obsidian 配置 / 整理日志 / MOC）

## Wiki 笔记（按 type 分类）

### entities/（具体实体）
- *（空，待补充）*

### concepts/（抽象概念）
- [用户偏好](../wiki/concepts/用户偏好.md) — 沟通/UI/工作流偏好

### comparisons/（对比）
- *（空，待补充）*

### summaries/（摘要）
- [stock-sim](../wiki/summaries/stock-sim.md) — 股票策略模拟系统
- [TradingAgents](../wiki/summaries/TradingAgents.md) — 多智能体交易系统
- [SuanJia](../wiki/summaries/SuanJia.md) — 飞书 AI 虚拟公司
- [3D](../wiki/summaries/3D.md) — SketchUp 建模项目

### synthesis/（综合调研）
- [知识库架构调研](../wiki/synthesis/知识库架构调研.md) — OKF + Dynamic Workflows + flywheel
- [知识库下一步调研五方向](../wiki/synthesis/知识库下一步调研五方向.md) — 5 方向决策记录
- [知识库下一步-执行清单](../wiki/synthesis/知识库下一步-执行清单.md) — 5 方向详细执行计划

## 90-meta/ 元信息（5 个文件）

- [vault 总说明](../README.md) — 目录结构 + 写入规则（OKF 格式 + 所有智能体可写）
- [frontmatter 模板](frontmatter-templates.md) — 各类笔记的 frontmatter（OKF 5 type 封闭词汇）
- [Obsidian 插件配置](obsidian-plugins.md) — Smart Connections + kb MCP（已放弃 obsidian MCP 和 Claudian）
- [知识管家流程](km-agent-workflow.md) — 整理/拆解/同步流程（含 flywheel 工具调用约定）
- [vault 整理日志](vault-changelog.md) — 知识管家整理操作记录
- [AI 工具链 MOC](moc-ai-toolchain.md) — 智能体/规范/MCP 导航

## flywheel 工具（实测状态，2026-06-20）

| 工具 | 命令 | 状态 |
|------|------|------|
| lint | `kb lint` | 0 错误 1 警告（设计选择：用户偏好作 root 源点）|
| stats | `kb stats --wiki-dir <dir>` | 8 页 8 节点 10 边 1 组件（连通 DAG）|
| graph-viz | `kb graph-viz` | Mermaid DAG，5 subgraph 按 type 分组 |

**必传 `KB_PROJECT_ROOT` 和 `--wiki-dir`**：
- `KB_PROJECT_ROOT=d:\xiangmu\_kb`（不设会去 `_kb_flywheel/demo/`）
- `kb stats` 必须传 `--wiki-dir`（flywheel `_validate_wiki_dir(None)` bug）

## 知识图谱（DAG 拓扑）

```
用户偏好 (concepts)
   ↓ 4 出边
4 项目 (summaries) → stock-sim / TradingAgents / SuanJia / 3D
   ↓ 4 出边汇聚
知识库架构调研 (synthesis)
   ↓ 1 出边
知识库下一步调研五方向 (synthesis)
   ↓ 1 出边
知识库下一步-执行清单 (synthesis)  ← 汇聚节点，PageRank 最高
```

10 条有向边，0 cycle，1 组件（完全连通）。

## 旧目录（已清理）

- ~~00-inbox/~~ ~~10-projects/~~ ~~30-resources/~~ ~~40-archive/~~ — 旧 4 块结构，2026-06-20 清理
- ~~20-areas/~~ — 旧主题分类，2026-06-19 清理
- ~~research/~~ ~~projects/~~ — 4 层架构，2026-06-20 合并为 3 层，文件迁入 wiki/synthesis/ 和 wiki/summaries/

## 更新日志

- 2026-06-20（19:00）90-meta/ 4 文件重写（km-agent-workflow / frontmatter-templates / obsidian-plugins / moc-ai-toolchain）+ index.md 补齐 frontmatter
- 2026-06-20（18:30）清理 6 个空旧目录 + .gitignore 路径修复 + wikilink DAG 重设计（10 边 0 cycle）
- 2026-06-20（18:20）flywheel 兼容：建 5 个 type 子目录，8 个 .md 迁入，4 层→3 层架构
- 2026-06-19 初版创建（4 层架构：raw/wiki/research/projects）
