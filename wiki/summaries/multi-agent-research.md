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
- 当前阶段：派发 6 任务

## 6 任务分配

| 任务 | 框架 | 智能体 | 时间 |
|---|---|---|---|
| 1 | Microsoft Agent Framework / AutoGen | Codex | 2h | ✅ 完成 |
| 2 | Google ADK | Claude Code | 2h |
| 3 | LangGraph | OpenCode | 2h | ✅ 完成 |
| 4 | OpenAI Agents SDK | Hermes | 6h |
| 5 | Amazon Bedrock / Strands | Trae | 13h | ✅ 完成（f31f0ec） |
| 6 | 本地业务实践 | 混合 | 2h |

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
