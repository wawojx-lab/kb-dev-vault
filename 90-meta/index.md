---
type: index
title: 知识库总索引
tags: [index]
timestamp: 2026-06-20T18:20:00Z
---

# 知识库总索引

> vault 所有笔记的索引。三层架构：raw / wiki（OKF 5 type）/ 90-meta。
> flywheel 兼容：wiki/ 下固定 5 个 type 子目录（entities / concepts / comparisons / summaries / synthesis），子目录名 = type。

## 目录导航（三层架构）

- [raw/](../raw/) — 人类策展源（原始资料、笔记、截图，flywheel 期望的 raw 位置）
- [wiki/](../wiki/) — LLM 编译产物（OKF 格式，按 type 分子目录）
- [90-meta/](.) — vault 元信息（index / frontmatter 模板 / Obsidian 配置 / 整理日志）

## Wiki 笔记（按 type 分类）

### entities/
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

## 规则文件（90-meta/）
- [vault 总说明](../README.md) — 目录结构 + 写入规则（OKF 格式）
- [frontmatter 模板](frontmatter-templates.md) — 各类笔记的 frontmatter
- [Obsidian 插件配置](obsidian-plugins.md) — 插件安装与配置
- [知识管家流程](km-agent-workflow.md) — 整理/拆解/同步流程
- [vault 整理日志](vault-changelog.md) — 知识管家整理操作记录

## flywheel 工具（实测状态）

| 工具 | 命令 | 状态 |
|------|------|------|
| lint | `kb lint` | 0 错误 2 警告（flywheel demo raw 残留），12 项检查全 PASS |
| stats | `kb stats --wiki-dir <dir>` | 8 页 8 节点 0 边 8 组件（孤立） |
| graph-viz | `kb graph-viz` | 输出 Mermaid，subgraph 按 type 分组 |

**必传 `--wiki-dir`** 是因为 flywheel 的 `_validate_wiki_dir(None, ...)` 返回 `(None, None)` 不走默认值。

## 旧目录（已清理）
- ~~20-areas/~~ `00-inbox/` `10-projects/` `30-resources/` `40-archive/` — 旧结构，2026-06-20 清理
- ~~research/~~ ~~projects/~~ — 2026-06-20 调整为 flywheel 5 type 子目录，文件迁移到 wiki/ 下

## 更新日志
- 2026-06-20（18:20）flywheel 兼容：建 5 个 type 子目录，8 个 .md 迁入，4 层→3 层架构
- 2026-06-20 架构调整：改为 raw/wiki/research/projects 四层 + OKF 格式 + 所有智能体可写
- 2026-06-19 初版创建
