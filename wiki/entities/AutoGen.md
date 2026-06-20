---
type: entity
title: AutoGen
source: 'https://github.com/microsoft/autogen'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [工具, 框架, 多智能体, 微软, 开源]
---

# AutoGen

微软研究院发起的开源多 Agent 框架，是**最早提出 GroupChat 和事件驱动 Agent Runtime** 的项目之一。当前版本 0.7.x，分为 `autogen-core`（基础层）和 `autogen-agentchat`（高层编排）。微软已宣布 Agent Framework 为其继任者。

## 核心定位

| 维度 | 说明 |
|------|------|
| **发起方** | Microsoft Research |
| **定位** | 多 Agent 对话与编排框架 |
| **当前版本** | autogen-core 0.7.5 / autogen-agentchat 0.7.5 |
| **继承者** | Microsoft-Agent-Framework |
| **语言** | Python（.NET SDK 在早期版本后已弱化） |

## 架构分层

```
┌───────────────────────────────────┐
│  autogen-agentchat（高层 API）     │
│  ┌───────────┐  ┌──────────────┐  │
│  │AssistantAgent│ │ GroupChat    │  │
│  │UserProxyAgent│ │ RoundRobin  │  │
│  │  ...        │ │ MagenticOne │  │
│  └───────────┘  └──────────────┘  │
├───────────────────────────────────┤
│  autogen-core（基础设施层）         │
│  ┌──────────────────────────────┐ │
│  │ AgentRuntime（事件驱动）      │ │
│  │ AgentProtocol（消息协议）     │ │
│  │ ModelClient（模型抽象）       │ │
│  │ FunctionTool（工具封装）      │ │
│  │ Subscription（消息订阅）      │ │
│  └──────────────────────────────┘ │
└───────────────────────────────────┘
```

## 核心概念

### Agent 类型

| Agent | 用途 |
|-------|------|
| **AssistantAgent** | LLM 驱动的助手，支持工具调用 |
| **UserProxyAgent** | 代理用户输入/执行代码 |
| **CodeExecutorAgent** | 在沙箱中执行代码 |
| **SocietyOfMindAgent** | 嵌套多 Agent 组作为单个 Agent |
| **OpenAIAssistantAgent** | 包装 OpenAI Assistants API |

### 编排模式

| 模式 | 说明 |
|------|------|
| **TwoAgentChat** | 两个 Agent 对话 |
| **RoundRobinGroupChat** | 轮流发言 |
| **SelectorGroupChat** | LLM 选择下一个发言者 |
| **Swarm** | 基于 Handoff 的动态协作 |
| **MagenticOneGroupChat** | 自适应多 Agent 协调 |

### Runtime

- **EmbeddedRuntime**（默认）：单进程内事件驱动，适合开发测试
- **DistributedRuntime**（实验性）：跨进程/机器分布式执行

## 代码示例

```python
from autogen_agentchat.agents import AssistantAgent
from autogen_agentchat.teams import RoundRobinGroupChat
from autogen_ext.models.openai import OpenAIChatCompletionClient

model = OpenAIChatCompletionClient(model="gpt-4o")

agent_a = AssistantAgent("researcher", model_client=model,
    system_message="你是研究助手")
agent_b = AssistantAgent("writer", model_client=model,
    system_message="你是写作助手")

team = RoundRobinGroupChat([agent_a, agent_b], max_turns=4)
result = await team.run(task="调研并撰写一篇关于 AI Agent 的文章")
```

## 关键特性

- **事件驱动架构**：Agent 通过消息传递通信，解耦发送和接收
- **GroupChat**：首创多 Agent 对话模式，支持灵活的发言者选择策略
- **工具调用**：`FunctionTool` 包装 Python 函数，自动推断 JSON Schema
- **代码执行**：内建 Docker / subprocess 代码沙箱
- **Human-in-the-Loop**：`UserProxyAgent` 在关键节点等待人类输入
- **Magentic-One**：2024 年底推出的自适应编排系统，可处理复杂多步任务

## Magentic-One 亮点

Magentic-One 是 AutoGen 中最成熟的编排模式：

- **Orchestrator Agent**：维护任务 ledger（任务列表 + 进度 + 未解决问题）
- **动态路由**：根据任务状态选择最合适的子 Agent
- **Ledger-based Planning**：持续更新任务计划，支持失败重试
- **子 Agent 池**：WebSurfer / FileSurfer / Coder / ComputerTerminal

## 局限性

| 局限 | 说明 |
|------|------|
| **无图工作流** | 编排基于对话协议，无显式 DAG/状态图 |
| **无类型安全路由** | 消息路由通过 LLM 决策，非类型校验 |
| **状态管理弱** | 无内置 Checkpoint / 持久化机制 |
| **运行时实验性** | 分布式 Runtime 尚未稳定 |
| **维护方向** | 微软已明确 Agent Framework 为继任，AutoGen 进入维护模式 |

## 现状（2026-06）

- **PyPI**：`pip install autogen-agentchat` / `pip install autogen-core`，版本 0.7.5
- **GitHub Stars**：~40k+
- **状态**：活跃开发但核心团队已转向 Agent Framework
- **迁移建议**：新项目推荐直接使用 Microsoft-Agent-Framework（见 entities/Microsoft-Agent-Framework）

## 关联图谱

- [[concepts/总控Agent模式]] — 总控 Agent 设计模式
