---
type: entity
title: Microsoft Agent Framework
source: 'https://learn.microsoft.com/en-us/agent-framework/'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [工具, 框架, agent-orchestration, 多智能体, 微软]
---

# Microsoft Agent Framework

微软于 2025 年推出的统一 AI Agent 框架，是 **AutoGen** 和 **Semantic Kernel** 的直接继承者。由同一核心团队开发，融合了 AutoGen 的简洁 Agent 抽象与 Semantic Kernel 的企业级特性（session 管理、类型安全、中间件、遥测），并新增图工作流引擎。

## 核心定位

| 定位 | 说明 |
|------|------|
| **继承关系** | AutoGen + Semantic Kernel → Agent Framework（官方继任者） |
| **语言支持** | Python + C#（双语言 SDK） |
| **模型支持** | Microsoft Foundry / Azure OpenAI / OpenAI / Anthropic / Ollama |
| **设计哲学** | Agent 抽象 + Workflow 编排 + 企业级基础设施 |

## 架构总览

```
┌─────────────────────────────────────────────┐
│            Microsoft Agent Framework         │
├──────────────┬──────────────────────────────┤
│   Agents     │   Workflows                  │
│  ┌─────────┐ │  ┌──────────────────────────┐│
│  │ AgentA  │ │  │ WorkflowBuilder (Graph)   ││
│  │ (LLM +  │ │  │ + Functional API (Python) ││
│  │  tools) │ │  └──────────────────────────┘│
│  └─────────┘ │                              │
│  ┌─────────┐ │  编排模式：                    │
│  │ AgentB  │ │  Sequential / Concurrent /   │
│  │ (LLM +  │ │  Handoff / Magentic          │
│  │  tools) │ │                              │
│  └─────────┘ │                              │
├──────────────┴──────────────────────────────┤
│  基础设施层                                   │
│  Model Clients | AgentSession | Context      │
│  Providers | Middleware | MCP Clients         │
└─────────────────────────────────────────────┘
```

## 两大能力

### 1. Agents（智能体）

- **AIAgent 基类**：所有 Agent 统一接口，支持多态编排
- **ChatClientAgent**：基于 `IChatClient` 实现，支持任意推理后端
- **默认多轮**：Agent 持续调用工具直到返回最终答案（区别于 AutoGen 需设置 `max_tool_iterations`）
- **Agent Skills**：可移植的能力包（SKILL.md + scripts + references + assets），遵循开放规范
- **MCP 集成**：原生支持 MCP Server 作为工具来源

### 2. Workflows（工作流）

图工作流引擎，将 Agent 和函数连接为有向图：

| 概念 | 说明 |
|------|------|
| **Executor** | 处理单元（Agent 或自定义逻辑） |
| **Edge** | 类型安全的消息路由 |
| **WorkflowBuilder** | 声明式图构建 API |
| **Functional Workflow** | Python 实验性 API，用 `async def` + decorator |
| **Superstep** | 并行执行模型，同一步骤的多个 Executor 可并发 |
| **Checkpointing** | 自动保存/恢复工作流状态 |
| **Human-in-the-Loop** | `RequestInfoExecutor` 暂停等待人类输入 |

## 多 Agent 编排模式

Agent Workflow 内置 4 种多 Agent 编排模式：

1. **Sequential（顺序）**：Agent A → Agent B → Agent C，前一个输出作为后一个输入
2. **Concurrent（并发）**：多个 Agent 并行执行同一任务，结果合并
3. **Handoff（接力）**：Agent 主动将控制权交给另一个 Agent（类似 OpenAI Swarm）
4. **Magentic**：自适应编排，Agent 根据任务动态选择协作策略

## Agent Runtime 执行模型

所有 Agent 共享统一运行时循环：

```
用户输入 → LLM 推理 → 工具调用 → 结果返回 LLM → 循环/结束
```

关键特性：
- **会话管理**：`AgentSession` 统一管理对话状态
- **中间件**：拦截 Agent 动作（日志、安全检查、速率限制）
- **可观测性**：与 OpenTelemetry 集成
- **A2A 协议**：Agent-to-Agent 标准化通信协议，支持跨框架互操作

## 与 AutoGen 的关系

Agent Framework 是 AutoGen 的**下一代继任者**。微软提供完整的迁移指南：

- `AssistantAgent` → `Agent`（基类名改变）
- `FunctionTool` → 直接传 Python 函数（自动推断 schema）
- `GroupChat` → WorkflowBuilder 的 graph-based 编排
- 嵌入式运行时 → 单进程组合（分布式执行规划中）

## 代码示例（Python）

```python
from agent_framework.foundry import FoundryChatClient
from azure.identity import AzureCliCredential

client = FoundryChatClient(
    project_endpoint="https://your-endpoint",
    model="gpt-5.4-mini",
    credential=AzureCliCredential(),
)

agent = client.as_agent(
    name="HelloAgent",
    instructions="You are a friendly assistant.",
)

result = await agent.run("What is the largest city in France?")
```

## 现状（2026-06）

- **状态**：预览阶段（prerelease packages）
- **安装**：`pip install agent-framework` / `dotnet add package Microsoft.Agents.AI.Foundry --prerelease`
- **文档**：https://learn.microsoft.com/en-us/agent-framework/
- **GitHub**：提供 Python 和 C# samples

## 关联图谱

- [[entities/AutoGen]] — 前身框架
- [[concepts/接力机制]] — 跨智能体接力协议

