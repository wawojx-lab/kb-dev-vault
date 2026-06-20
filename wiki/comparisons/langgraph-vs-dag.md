---
type: comparison
title: LangGraph 工作流图 vs DAG 思维
source: 'LangGraph 文档 + 本地 DAG-思维.md + 调研总结'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [对比, 选型, 图论, 状态机, agent-orchestration]
---

# LangGraph 工作流图 vs DAG 思维

本知识库已有 [[concepts/DAG-思维]] 作为知识图谱和任务依赖的基础方法论。LangGraph 的**可追踪工作流图**引入了一种新的图视角。以下是两者的深度对比。

## 对比总览

| 维度 | DAG 思维 | LangGraph 工作流图 |
|------|---------|-------------------|
| **图的本质** | 依赖关系图（静态结构） | 状态转移图（动态执行） |
| **方向性** | 单向（无环） | 可以有循环（Agent loop） |
| **节点** | 概念/任务/实体 | 计算步骤（LLM call / tool / router） |
| **边** | 依赖/引用 | 控制流（确定 + 条件 + 动态） |
| **状态** | 无全局状态 | 全局 Shared State + Reducer |
| **持久化** | 无 | Checkpointer 每步保存 |
| **执行** | 拓扑排序后一次过 | 逐 super-step 推进，可暂停/恢复 |
| **数据流** | 边传递数据 | State 传递数据 |
| **可追踪性** | 手动 | 自动（Checkpoint + LangSmith） |
| **典型应用** | 知识图谱 / 任务分解 / CI/CD | AI Agent 工作流 / 多 Agent 协作 |

## 相同点

1. **有向图建模** — 都认为图是最好的表达方式
2. **避免孤儿节点** — DAG 思维要求 0 orphan，LangGraph compile 时也检查无人引用的节点
3. **解偶节点** — 每个节点独立，通过边连接
4. **拓扑可见** — 都可导出可视化图

## 核心差异详解

### 1. 有环 vs 无环

```
DAG 思维（无环）          LangGraph（可以有环）

A → B → C              A → B → C → D
                        ↑         │
                        └─────────┘  ← Agent loop
```

DAG 禁止循环因为它代表**依赖关系**（A 依赖 B，不能 A 又依赖 B 又依赖 A）。LangGraph 允许循环因为它代表**迭代过程**（LLM 反复调用工具直到完成）。

### 2. 状态管理

DAG 思维中节点间通过边传递数据，无全局状态。LangGraph 所有节点共享 State，通过 Reducer 控制合并策略。

```python
# LangGraph 的 State 设计
class AgentState(TypedDict):
    messages: Annotated[list, add_messages]  # 追加不覆盖
    task_status: str                          # 直接覆盖
    remaining_steps: RemainingSteps           # 托管值（框架自动计算）
```

### 3. 持久化与恢复

DAG 思维不关心执行过程，只关心结构和依赖。LangGraph 每步 checkpoint，支持时间旅行调试。

### 4. 可观察性

DAG 思维通过手动维护（`flywheel healthy` 检查拓扑健康度）。LangGraph 通过 LangSmith 自动捕获每节点输入/输出/耗时/错误。

## 何时用哪个

| 场景 | 推荐方案 |
|------|---------|
| 知识库结构设计（[[entities/flywheel]]） | **DAG 思维** |
| 任务分解与依赖分析 | **DAG 思维** |
| 简单线性 Agent（单一 LLM + 工具） | **DAG 思维** 或 LangGraph 均可用 |
| 复杂多步 Agent（循环/条件/HIL） | **LangGraph 工作流图** |
| 多 Agent 协调（supervisor + subgraph） | **LangGraph 工作流图** |
| 需要故障恢复的生产 Agent | **LangGraph 工作流图** |
| 需要人类审批的流程 | **LangGraph 工作流图** |
| CI/CD 构建依赖 | **DAG 思维** |

## 结合使用

两者不是互斥的。在实际项目中可以结合：

1. **用 DAG 思维设计知识库结构**（concepts → entities → comparisons → summaries → synthesis）
2. **用 LangGraph 工作流图执行 Agent 任务**
3. **知识库中的 DAG 作为 Agent 的认知地图**，Agent 工作流图在执行时引用知识库节点

```
[知识库 DAG] ──引用──→ [Agent 工作流图]
                              │
                 ┌────────────┼────────────┐
                 ▼            ▼            ▼
              concept      entity      comparison
              {{ .summary }}              
              (从知识库读取)              
```

## 关联图谱

- [[concepts/DAG-思维]] — DAG 设计基础
