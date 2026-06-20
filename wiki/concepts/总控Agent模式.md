---
type: concept
title: 总控Agent模式
source: 'LangGraph 官方文档 + 多 Agent 架构调研'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [方法论, agent-orchestration, 多智能体, 层级架构]
---

# 总控 Agent 模式（Supervisor Agent Pattern）

一个中心 Agent（总控）协调多个子 Agent 共同完成复杂任务的架构模式。LangGraph 通过 **Subgraph + Command.PARENT** 原生支持。

## 架构

```
                    ┌─────────────┐
                    │  Supervisor  │ ← 总控 Agent（路由决策）
                    │  (LLM Node)  │
                    └──────┬──────┘
            ┌──────────────┼──────────────┐
            ▼              ▼              ▼
     ┌──────────┐  ┌──────────┐  ┌──────────┐
     │ Agent A  │  │ Agent B  │  │ Agent C  │ ← 子 Agent（各为 Subgraph）
     │ (research)│  │ (coding) │  │ (review) │
     └──────────┘  └──────────┘  └──────────┘
            │              │              │
            └──────────────┼──────────────┘
                           ▼
                    ┌─────────────┐
                    │   Output    │
                    └─────────────┘
```

## LangGraph 实现方式

### 方式 1：Supervisor + Subgraph Handoff

每个子 Agent 作为一个独立 Subgraph。总控节点通过 LLM 判断哪个子 Agent 应该接手，子 Agent 完成后通过 `Command(goto=..., graph=Command.PARENT)` 回到总控。

```python
def supervisor_node(state: State) -> Command[Literal["agent_a", "agent_b", END]]:
    response = llm.invoke([
        system_prompt("你负责调度：research / code / review"),
        HumanMessage(content=f"当前状态: {state}")
    ])
    return Command(goto=response.content, update={"messages": [response]})

builder = StateGraph(State)
builder.add_node("supervisor", supervisor_node)
builder.add_node("agent_a", research_agent.compile())  # subgraph
builder.add_node("agent_b", coding_agent.compile())     # subgraph
builder.add_edge(START, "supervisor")
```

### 方式 2：Functional API 嵌套

`@entrypoint` 做总控，内部调用多个 `@task` 子 Agent，用标准 Python if/for 控制流程。

```python
@entrypoint(checkpointer=checkpointer)
def supervisor(inputs: dict):
    plan = planner_task(inputs).result()
    results = []
    for step in plan:
        if step.type == "research":
            r = research_task(step.query).result()
        elif step.type == "code":
            r = coding_task(step.spec).result()
        results.append(r)
    review = review_task(results).result()
    return review
```

## 总控 Agent 的关键设计问题

| 问题 | 方案 |
|------|------|
| **如何决策下一步** | LLM routing（最灵活）/ 规则路由（确定性）/ 混合（规则兜底） |
| **如何传递上下文** | Shared State（全局可见）+ thread_id 隔离会话 |
| **子 Agent 失败怎么处理** | Task 的 fault-tolerance + retry + Checkpoint 恢复 |
| **总控如何拿到结果** | Subgraph 输出自动写入 State，总控读取对应 key |
| **并发子任务** | Send() 做 Map-Reduce，或 @task 并发执行 |
| **人类何时介入** | 总控节点或子 Agent 内部调用 interrupt() |

## 子 Agent 的粒度设计

| 粒度 | 适用场景 | LangGraph 映射 |
|------|---------|----------------|
| **原子工具** | 单次 API 调用/计算 | Node + Tool |
| **子流程** | 多步任务（如 research → summarize） | Subgraph（小图） |
| **独立 Agent** | 完整能力单元（如代码 Agent） | Subgraph（含循环 + 工具 + HIL） |
| **外部服务** | 通过 API 调用的已有服务 | RemoteGraph / Node with HTTP call |

## 与接力机制的关系

总控 Agent 模式和 [[concepts/接力机制]] 解决不同层面的问题：

| 维度 | 总控 Agent 模式 | 接力机制 |
|------|----------------|---------|
| **场景** | 同一会话内多 Agent 协调 | 跨会话/跨智能体接力 |
| **通信** | Shared State / Subgraph output | 文件（AGENTS.md / WORKLOG.md） |
| **状态** | Checkpoint 自动持久化 | 手动更新 PROJECT_STATUS.md |
| **适用** | 运行时协同 | 开发时协同 |

两者可互补：总控 Agent 用 LangGraph 管理运行时协作，接力机制管理开发时协作。

## 最佳实践

1. **总控的 state 不要太胖** — 只放路由所需上下文，子 Agent 用私有 state
2. **每条边都要有退出条件** — 防止无限循环（设 recursion_limit）
3. **子 Agent 内用 Interrupt 做审批** — 关键决策点暂停等人
4. **总控 + 人审组合** — 总控做初筛，高风险节点加 HIL
5. **集成 LangSmith** — 追踪每步调试

## 关联图谱

- [[entities/LangGraph]] — LangGraph 框架
- [[concepts/工作流图]] — 可追踪工作流图设计
- [[concepts/接力机制]] — 跨 AI 智能体接力协议
- [[concepts/DAG-思维]] — DAG 设计基础
