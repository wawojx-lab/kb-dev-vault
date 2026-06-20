---
type: entity
title: LangGraph
source: 'https://docs.langchain.com/oss/python/langgraph/overview'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [工具, 框架, agent-orchestration, 状态机, langchain]
---

# LangGraph

LangChain 推出的低阶编排框架（low-level orchestration framework），用于构建、管理和部署**有状态、长运行**的 AI Agent。灵感来自 Google Pregel 和 Apache Beam 的消息传递模型。

## 核心定位

- **不是**高层 Agent 框架（不抽象 prompt / architecture）
- **是** Agent 编排运行时（orchestration runtime）：持久化执行、流式输出、Human-in-the-Loop
- 可与 LangChain 解耦使用，也可无缝集成

## 核心概念

| 概念 | 说明 |
|------|------|
| **StateGraph** | 主图类，以 typed state schema 为参数 |
| **State** | 共享数据结构（TypedDict / Pydantic），带 reducer 函数控制更新策略 |
| **Node** | 计算节点，接收 state → 计算 → 返回 state 更新 |
| **Edge** | 节点间路由：普通边（确定性）或条件边（动态路由） |
| **Reducers** | 控制 state 字段的合并策略（默认覆盖，operator.add 追加，add_messages 去重追加） |
| **Checkpointer** | 每 super-step 持久化 state，支持故障恢复和时间旅行 |
| **Interrupt** | 暂停图执行，等待人审后通过 Command(resume=...) 恢复 |
| **Command** | 多功能原语：更新 state + 路由 + 处理 interrupt resume |
| **Send** | 分布式 Map-Reduce 模式：动态创建多个下游节点实例 |

## 双 API

LangGraph 提供两套 API，共享同一运行时：

- **Graph API**（声明式）：定义 State → add_node → add_edge → compile，适合复杂工作流
- **Functional API**（命令式）：`@entrypoint` + `@task`，用标准 Python 控制流写逻辑，适合从已有代码迁移

## 关键能力

### 持久化执行（Durable Execution）

通过 Checkpointer 每步自动保存 state。支持 MemorySaver / SqliteSaver / PostgresSaver。故障后自动从最近 checkpoint 恢复。

### Human-in-the-Loop

`interrupt()` 暂停图执行 → 返回 Interrupt 对象 → 外部注入 `Command(resume=value)` → 继续执行。支持多轮审批、验证循环。

### 流式输出（Streaming）

原生支持 token-by-token 流式，实时展示 Agent 推理过程。配合 LangSmith 实现完整可观测性。

### 可视化

`agent.get_graph().draw_mermaid_png()` 直接输出 Mermaid 图。LangSmith Studio 提供交互式图调试。

### 多 Agent 模式

通过 Subgraph + Command.PARENT 实现 Supervisor / Hierarchical / Handoff 等拓扑。

## 生态系统

| 产品 | 定位 |
|------|------|
| **LangChain** | 高层 Agent 框架，model/tool 抽象 |
| **LangGraph** | 编排运行时（本实体） |
| **Deep Agents** | 基于 LangGraph 的 Agent 封装（planning / subagent / filesystem） |
| **LangSmith** | 可观测性 + 评估 + 部署平台 |
| **LangSmith Deployment** | 托管部署，支持长运行有状态工作流 |

## 代码示例（Graph API）

```python
from langgraph.graph import StateGraph, MessagesState, START, END

def llm_call(state: MessagesState):
    return {"messages": [model_with_tools.invoke(state["messages"])]}

def should_continue(state) -> Literal["tool_node", END]:
    return "tool_node" if state["messages"][-1].tool_calls else END

builder = StateGraph(MessagesState)
builder.add_node("llm_call", llm_call)
builder.add_node("tool_node", tool_node)
builder.add_edge(START, "llm_call")
builder.add_conditional_edges("llm_call", should_continue)
builder.add_edge("tool_node", "llm_call")
agent = builder.compile(checkpointer=MemorySaver())
agent.invoke({"messages": [HumanMessage("hello")]}, config)
```

## 现状（2026-06）

- GitHub Stars: ~35k
- 最新版本: langgraph==1.2.6（2026-06-18）
- 生产用户：Klarna, Uber, J.P. Morgan, Replit, Elastic, LinkedIn
- 语言支持：Python / TypeScript

## 关联图谱

- [[concepts/工作流图]] — 可追踪工作流图设计
- [[concepts/DAG-思维]] — DAG 设计基础
- [[comparisons/langgraph-vs-dag]] — 与现有 DAG 思维对比
- [[concepts/总控Agent模式]] — 总控 agent 设计模式
