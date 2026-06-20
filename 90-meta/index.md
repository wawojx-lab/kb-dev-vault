---
type: index
title: 知识库总索引
source: '个人整理 + flywheel 知识库'
created: 2026-06-19
updated: 2026-06-20
confidence: stated
status: mature
tags: [index, meta]
---

# 知识库总索引

> vault 所有笔记的索引。三层架构：raw / wiki（OKF 5 type）/ 90-meta
> flywheel 兼容：wiki/ 下固定 5 个 type 子目录（entities / concepts / comparisons / summaries / synthesis），子目录名 = type
> **2026-06-20 更新**：多 Agent 框架调研 6/6 完成，知识库增至 54 页 185 边

## 目录导航（三层架构）

- [raw/](../raw/) — 人类策展源（原始资料、笔记、截图，flywheel 期望的 raw 位置）
- [wiki/](../wiki/) — LLM 编译产物（OKF 格式，按 type 分子目录）
- [90-meta/](.) — vault 元信息（index / frontmatter 模板 / Obsidian 配置 / 整理日志 / MOC）

## Wiki 笔记（54 页，按 type 分类）

### entities/（16 — 具体实体：人物/公司/产品/工具）

**AI Agent 框架（7）**：[AutoGen](../wiki/entities/AutoGen.md) · [Google-ADK](../wiki/entities/Google-ADK.md) · [LangGraph](../wiki/entities/LangGraph.md) · [OpenAI-Agents-SDK](../wiki/entities/OpenAI-Agents-SDK.md) · [Microsoft-Agent-Framework](../wiki/entities/Microsoft-Agent-Framework.md) · [Amazon-Bedrock](../wiki/entities/Amazon-Bedrock.md) · [Strands](../wiki/entities/Strands.md)

**AI 编码工具（3）**：[Trae](../wiki/entities/Trae.md) · [Claude-Code](../wiki/entities/Claude-Code.md) · [flywheel](../wiki/entities/flywheel.md)

**基础设施（6）**：[Git](../wiki/entities/Git.md) · [GitHub](../wiki/entities/GitHub.md) · [Docker](../wiki/entities/Docker.md) · [SQLite](../wiki/entities/SQLite.md) · [Task-Scheduler](../wiki/entities/Task-Scheduler.md) · [OKF](../wiki/entities/OKF.md)

### concepts/（14 — 抽象概念：方法/指标/理论/偏好）

**核心方法论（5）**：[接力机制](../wiki/concepts/接力机制.md) · [任务拆解](../wiki/concepts/任务拆解.md) · [渐进式开发](../wiki/concepts/渐进式开发.md) · [DAG-思维](../wiki/concepts/DAG-思维.md) · [用户偏好](../wiki/concepts/用户偏好.md)

**Agent 模式（9）**：[多Agent协作](../wiki/concepts/多Agent协作.md) · [总控Agent模式](../wiki/concepts/总控Agent模式.md) · [工作流图](../wiki/concepts/工作流图.md) · [Handoff模式](../wiki/concepts/Handoff模式.md) · [Guardrail模式](../wiki/concepts/Guardrail模式.md) · [Agent状态管理](../wiki/concepts/Agent状态管理.md) · [Agent工具组织](../wiki/concepts/Agent工具组织.md) · [安全边界模式](../wiki/concepts/安全边界模式.md) · [企业Agent集成](../wiki/concepts/企业Agent集成.md)

### comparisons/（8 — 对比：X vs Y 选型/优劣）

[ai-coding-tools](../wiki/comparisons/ai-coding-tools.md) · [flywheel-vs-rag](../wiki/comparisons/flywheel-vs-rag.md) · [adk-vs-autogen](../wiki/comparisons/adk-vs-autogen.md) · [autogen-vs-openai-agents](../wiki/comparisons/autogen-vs-openai-agents.md) · [bedrock-vs-azure-ai](../wiki/comparisons/bedrock-vs-azure-ai.md) · [langgraph-vs-dag](../wiki/comparisons/langgraph-vs-dag.md) · [sync-vs-async](../wiki/comparisons/sync-vs-async.md) · [git-rebase-vs-merge](../wiki/comparisons/git-rebase-vs-merge.md)

### summaries/（11 — 摘要：单源提炼的项目/文章/书）

**项目摘要（4）**：[stock-sim](../wiki/summaries/stock-sim.md) · [TradingAgents](../wiki/summaries/TradingAgents.md) · [SuanJia](../wiki/summaries/SuanJia.md) · [3D](../wiki/summaries/3D.md)

**业务实践（4）**：[客户管理实践](../wiki/summaries/客户管理实践.md) · [交付项目管理](../wiki/summaries/交付项目管理.md) · [文档生产实践](../wiki/summaries/文档生产实践.md) · [进度追踪实践](../wiki/summaries/进度追踪实践.md)

**应用案例（2）**：[建设聚合模型平台](../wiki/summaries/建设聚合模型平台.md) · [排查总控仓库脏状态](../wiki/summaries/排查总控仓库脏状态.md)

**调研汇总（1）**：[multi-agent-research](../wiki/summaries/multi-agent-research.md) — 6 框架调研总报告

### synthesis/（5 — 综合：多源合成的调研/全景）

[知识库架构调研](../wiki/synthesis/知识库架构调研.md) · [知识库下一步调研五方向](../wiki/synthesis/知识库下一步调研五方向.md) · [知识库下一步-执行清单](../wiki/synthesis/知识库下一步-执行清单.md) · [开发流程最佳实践](../wiki/synthesis/开发流程最佳实践.md) · [任务拆解方法论](../wiki/synthesis/任务拆解方法论.md)

## 90-meta/ 元信息（8 文件）

- [vault 总说明](../README.md) — 目录结构 + 写入规则（OKF 格式 + 所有智能体可写）
- [frontmatter 模板](frontmatter-templates.md) — 各类笔记的 frontmatter（OKF 5 type 封闭词汇）
- [Obsidian 插件配置](obsidian-plugins.md) — Smart Connections + kb MCP（已放弃 obsidian MCP 和 Claudian）
- [知识管家流程](km-agent-workflow.md) — 整理/拆解/同步流程（含 flywheel 工具调用约定 + 自动化脚本）
- [vault 整理日志](vault-changelog.md) — 知识管家整理操作记录
- [AI 工具链 MOC](moc-ai-toolchain.md) — 智能体/规范/MCP 导航
- [多 Agent 调研协调计划](multi-agent-research.md) — 6 框架调研任务分配
- [远程接入方案](remote-access.md) — Git remote 主方案 + Tailscale/Syncthing 对比

## flywheel 工具（实测状态，2026-06-20）

| 工具 | 命令 | 状态 |
|------|------|------|
| lint | `kb lint` | 0 错误 0 警告 0 cycle 0 orphan（完全健康）|
| stats | `kb stats --wiki-dir <dir>` | 54 页 185 边 1 组件 |
| graph-viz | `kb graph-viz` | Mermaid DAG，5 subgraph 按 type 分组 |

**必传 `KB_PROJECT_ROOT` 和 `--wiki-dir`**：
- `KB_PROJECT_ROOT=d:\xiangmu\_kb`（不设会去 `_kb_flywheel/demo/`）
- `kb stats` 必须传 `--wiki-dir`（flywheel `_validate_wiki_dir(None)` bug）

**自动化脚本**（2026-06-20 落地）：
- `_kb_flywheel\kb-daily.ps1` — 每日 lint + stats + graph-viz，输出到 `90-meta/reports/`
- Windows Task Scheduler 每天 09:00 自动触发

## 知识图谱指标（2026-06-20）

```
54 节点 | 185 边 | 1 组件（完全连通）| 0 cycle | 0 orphan
```

**Most linked Top5**（入度最高）：
1. concepts/接力机制（20 入边）— 跨 agent 任务接力核心
2. concepts/渐进式开发（12 入边）
3. concepts/任务拆解（10 入边）
4. synthesis/开发流程最佳实践（10 入边）
5. concepts/用户偏好（9 入边）

**PageRank Top5**：
1. entities/flywheel（0.1194）
2. concepts/接力机制（0.0994）
3. concepts/DAG-思维（0.0532）
4. entities/Git（0.0442）
5. concepts/任务拆解（0.0441）

## 旧目录（已清理）

- ~~00-inbox/~~ ~~10-projects/~~ ~~30-resources/~~ ~~40-archive/~~ — 旧 4 块结构，2026-06-20 清理
- ~~20-areas/~~ — 旧主题分类，2026-06-19 清理
- ~~research/~~ ~~projects/~~ — 4 层架构，2026-06-20 合并为 3 层，文件迁入 wiki/synthesis/ 和 wiki/summaries/

## 更新日志

- 2026-06-20（22:43）index.md 大改：列全 54 页面（6/6 调研完成），更新图谱指标（54 节点 185 边），补充自动化脚本说明
- 2026-06-20（19:00）90-meta/ 4 文件重写（km-agent-workflow / frontmatter-templates / obsidian-plugins / moc-ai-toolchain）+ index.md 补齐 frontmatter
- 2026-06-20（18:30）清理 6 个空旧目录 + .gitignore 路径修复 + wikilink DAG 重设计（10 边 0 cycle）
- 2026-06-20（18:20）flywheel 兼容：建 5 个 type 子目录，8 个 .md 迁入，4 层→3 层架构
- 2026-06-19 初版创建（4 层架构：raw/wiki/research/projects）
