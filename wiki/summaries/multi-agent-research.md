---
type: summary
title: multi-agent-research-coordination
source: 'd:\xiangmu\_kb\90-meta\multi-agent-research.md'
status: developing
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [协调, 多智能体, 调研]
---

# 项目：多 Agent 框架调研协调

> 用 5 智能体并发调研 5 个 AI Agent 框架 + 本地业务实践，输出汇入 _kb/。

## 项目阶段
- 启动：2026-06-20
- 计划完成：2026-06-24
- 当前阶段：5/6 完成（任务 1-3-5-6 完成，任务 4 进行中，任务 2 完成）

## 6 任务分配

| 任务 | 框架 | 智能体 | 时间 |
|---|---|---|---|
| 1 | Microsoft Agent Framework / AutoGen | Codex | 2h | ✅ 完成 |
| 2 | Google ADK | Claude Code | 2h | ✅ 完成（2026-06-20） |
| 3 | LangGraph | OpenCode | 2h | ✅ 完成 |
| 4 | OpenAI Agents SDK | Hermes | 6h |
| 5 | Amazon Bedrock / Strands | Trae | 13h | ✅ 完成（f31f0ec） |
| 6 | 本地业务实践 | 混合 | 2h | ✅ 完成（2026-06-20） |

## 协调计划
见 [90-meta/multi-agent-research.md](../../90-meta/multi-agent-research.md)

## 关联图谱

- [[concepts/接力机制]]
- [[concepts/任务拆解]]
- [[synthesis/开发流程最佳实践]]
- [[synthesis/任务拆解方法论]]

## 任务 1 完成记录（Codex，2026-06-20）

**产出页面**：
- [[entities/Microsoft-Agent-Framework]] — 框架实体（架构、编排模式、代码示例）
- [[entities/AutoGen]] — AutoGen 实体（GroupChat、Magentic-One、与 AF 的关系）
- [[concepts/多Agent协作]] — 4 种协作模式 + 传递机制对比 + 各框架能力矩阵
- [[comparisons/autogen-vs-openai-agents]] — 选型对比 + 决策树 + 迁移路径

**关键发现**：
1. Agent Framework 是 AutoGen + Semantic Kernel 的官方继任者
2. Agent Workflow 内置 4 种编排：Sequential / Concurrent / Handoff / Magentic
3. AutoGen 的 GroupChat 和 Magentic-One 是多 Agent 对话协作的先驱
4. OpenAI Agents SDK 以 Handoff 为核心，更适合路由场景
5. 企业级场景推荐 Agent Framework（类型安全 + Checkpoint + A2A）

## 任务 2 完成记录（Claude Code，2026-06-20）

**产出页面**：
- [[entities/Google-ADK]] — ADK 框架实体（架构、Agent 类型、工具、状态、回调、部署、A2A）
- [[concepts/Agent工具组织]] — 三大框架工具组织对比（ADK FunctionTool / LangGraph ToolNode / AutoGen FunctionTool）
- [[concepts/Agent状态管理]] — 三大框架状态管理对比（ADK SessionService / LangGraph Checkpointer / AutoGen 无）
- [[comparisons/adk-vs-autogen]] — ADK vs AutoGen 选型对比（编排/工具/状态/部署全维度）

**关键发现**：
1. ADK 设计哲学是 Agent-centric（Agent 是第一公民），区别于 AutoGen 的 Conversation-centric
2. ADK 内置 3 种编排原语（Sequential / Parallel / Loop），声明式但较简单（对比 LangGraph 的 StateGraph）
3. SessionService 三级状态（Session / User / App）是 ADK 的生产级优势，AutoGen 无内置持久化
4. MCP 原生集成使 ADK 工具生态更开放（对比 AutoGen 无 MCP 支持）
5. A2A 协议原生支持是 ADK 的互操作护城河，但生态尚年轻（2025-04 发布）

## 任务 6 完成记录（混合/Trae，2026-06-20）

**产出页面**（4 个 summary）：
- [[summaries/客户管理实践]] — CRM 工作流（SuanJia 经营部 16 工具 + zhaobiaowenjian 公司库 + 飞书用户映射）
- [[summaries/交付项目管理]] — 项目交付工作流（4 Phase 招投标 + 经营部 project_pipeline + night-tasks）
- [[summaries/文档生产实践]] — 文档生产工作流（SuanJia docs 体系 + 信息域 8 份控制台 + _kb OKF 5 type）
- [[summaries/进度追踪实践]] — 进度管理工作流（3 层接力机制 + 5 智能体接力验证 + Backlog/Cron）

**关键发现**：
1. **客户管理**：3 源割裂（经营部 clients.json / zhaobiaowenjian 公司库 / 飞书 USER_MAP）— 需建 _kb_personal/03-私有/客户库 单点维护
2. **交付项目**：4 Phase 流程仅在 CLAUDE.md 自然语言描述 — 需 biz_mcp 工具代码化 + 5 智能体并行 Phase 1
3. **文档生产**：信息域 8 份 .md 已结构化 + _kb OKF 体系成熟 — SuanJia docs 300+ 份待建索引 + 飞书云文档协同
4. **进度追踪**：5 智能体接力验证全通过 — 待建进度仪表盘 + 接力标记协议 + GitHub Issues 镜像 Backlog

**复用价值**：
- 这 4 个实践页是后续 5 智能体落地业务的"参考蓝图"
- 客户/项目/文档/进度四大维度形成完整业务闭环
- 与 5 框架调研（任务 1-5）互为补充：框架是"怎么做"，业务是"做什么"
