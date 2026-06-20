---
type: concept
title: Agent状态管理
source: 'Google ADK Session 文档 + LangGraph Checkpointer + AutoGen Runtime 调研'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [方法论, agent-orchestration, 状态管理, 持久化]
---

# Agent 状态管理（Agent State Management）

AI Agent 框架如何在多轮对话、多工具调用、多 Agent 协作中维护和持久化状态。状态管理决定了 Agent 的**记忆能力**和**容错能力**。

## 状态的三个层次

```
┌───────────────────────────────────────┐
│  会话级状态（Session State）           │
│  → 一次对话内的共享数据                │
├───────────────────────────────────────┤
│  用户级状态（User State）              │
│  → 跨会话的用户偏好和历史              │
├───────────────────────────────────────┤
│  应用级状态（App State）               │
│  → 全局配置、共享资源                  │
└───────────────────────────────────────┘
```

## Google ADK 的状态模型

ADK 以 **Session** 为中心组织状态：

### Session 结构

```python
Session {
    id: str                    # 会话唯一标识
    app_name: str              # 应用名
    user_id: str               # 用户标识
    state: dict[str, Any]      # ★ 核心：跨工具/跨 Agent 共享状态
    events: list[Event]        # 对话历史（消息 + 工具调用 + 结果）
}
```

### 三级 State 空间

ADK 的 `session.state` 字典按前缀区分三个层级：

| 前缀 | 层级 | 生命周期 | 示例 |
|------|------|---------|------|
| 无前缀 | Session 级 | 会话结束即销毁 | `state["current_topic"]` |
| `user:` | User 级 | 跨会话持久化 | `state["user:theme"]` |
| `app:` | App 级 | 全局共享 | `state["app:version"]` |

### SessionService 后端

| 后端 | 持久化 | 适用场景 |
|------|--------|---------|
| **InMemorySessionService** | 进程内存 | 开发测试 |
| **DatabaseSessionService** | Cloud SQL / PostgreSQL | 生产部署 |
| **VertexAiSessionService** | Vertex AI 托管 | Google Cloud 全托管 |

### ToolContext 读写状态

工具函数通过 `ToolContext` 参数读写 Session State：

```python
def remember_preference(key: str, value: str, tool_context: ToolContext) -> dict:
    """保存用户偏好到 session state。"""
    # 读取已有状态
    existing = tool_context.state.get("preferences", {})
    # 创建新状态（不可变更新）
    updated = {**existing, key: value}
    # 写回 state
    tool_context.state["preferences"] = updated
    return {"saved": True, "key": key}
```

### Artifacts（文件级状态）

ADK 还支持 **Artifacts**——与 Session 关联的文件级数据，适合存储大文件或二进制数据：

```python
# 保存 artifact
tool_context.save_artifact("report.pdf", pdf_bytes)

# 加载 artifact
data = tool_context.load_artifact("report.pdf")
```

## LangGraph 的状态模型

LangGraph 以 **StateGraph + Checkpointer** 为核心：

### State 定义

```python
from typing import TypedDict, Annotated
from langgraph.graph import MessagesState
import operator

class AgentState(TypedDict):
    messages: Annotated[list, operator.add]  # reducer：追加而非覆盖
    research: str                             # 研究结果
    iterations: int                           # 迭代计数
```

**Reducer 函数**是 LangGraph 的独特设计：定义 state 字段的合并策略（覆盖 / 追加 / 去重追加 / 自定义）。

### Checkpointer 持久化

```python
from langgraph.checkpoint.memory import MemorySaver
from langgraph.checkpoint.sqlite import SqliteSaver

# 每个 super-step 自动快照
checkpointer = SqliteSaver.from_conn_string("checkpoints.db")
agent = builder.compile(checkpointer=checkpointer)

# 时间旅行：查看任意历史状态
history = list(agent.get_state_history(config))
```

| Checkpointer | 存储 | 用途 |
|-------------|------|------|
| **MemorySaver** | 内存 | 测试 |
| **SqliteSaver** | SQLite 文件 | 本地开发 |
| **PostgresSaver** | PostgreSQL | 生产 |

**与 ADK 对比**：LangGraph 的 Checkpointer 更强大——支持**时间旅行**（回溯到任意历史状态）和**故障恢复**（从最近 checkpoint 继续）。ADK 的 Session State 是扁平字典，无 checkpoint 概念。

## AutoGen 的状态模型

AutoGen 的状态管理**最弱**：

- 无内置持久化机制
- Agent 通过 conversation history 维护上下文
- 需要开发者自行实现状态保存
- DistributedRuntime（实验性）计划支持跨进程状态

## 框架对比

| 维度 | Google ADK | LangGraph | AutoGen |
|------|-----------|-----------|---------|
| **状态结构** | 扁平 dict | TypedDict + Reducer | 消息列表 |
| **持久化** | SessionService（可插拔） | Checkpointer（自动） | 无内置 |
| **粒度** | 三级（Session/User/App） | 一级（Thread） | 无 |
| **时间旅行** | ❌ | ✅ `get_state_history()` | ❌ |
| **故障恢复** | Session 重连 | Checkpoint 继续执行 | ❌ |
| **状态隔离** | 前缀区分 | thread_id 隔离 | conversation_id |
| **文件状态** | Artifacts | 无内置 | 无内置 |

## 状态管理的设计模式

### 模式 1：集中式 State（LangGraph）

```
所有 Node 读写同一个 State 对象
→ 类型安全（TypedDict）
→ Reducer 控制合并策略
→ Checkpointer 自动持久化
```

**优点**：简单、可追踪、类型安全
**缺点**：State 膨胀时性能下降

### 模式 2：分层 State（ADK）

```
Session State (会话内)
User State (跨会话)
App State (全局)
→ 前缀路由
→ SessionService 统一管理
```

**优点**：天然支持多层持久化
**缺点**：无类型约束，需手动管理前缀

### 模式 3：消息流 State（AutoGen）

```
Agent 通过 conversation history 维护状态
→ 每条消息是状态的一个快照
→ 无显式 state dict
```

**优点**：与 LLM 对话模式天然契合
**缺点**：无法存储非消息状态，难以持久化

## 与 [[concepts/接力机制]] 的关系

| 维度 | 框架内状态 | 接力机制 |
|------|-----------|---------|
| **作用域** | 同一框架运行时 | 跨框架、跨会话 |
| **存储** | 内存 / 数据库 | 文件（MD / JSON） |
| **格式** | 框架定义（dict / TypedDict） | 人类可读文档 |
| **持久化** | 自动（Session / Checkpoint） | 手动（更新 WORKLOG.md） |
| **适用** | 运行时协作 | 开发时协作 |

## 最佳实践

1. **State 最小化** — 只放必要数据，大文件用 Artifacts / 外部存储
2. **不可变更新** — 创建新 dict 而非修改现有（参见 [[concepts/用户偏好]]）
3. **选择合适的持久化后端** — 开发用 Memory/SQLite，生产用 PostgreSQL
4. **前缀命名规范** — ADK 用 `user:` / `app:` 前缀，避免 key 冲突
5. **LangGraph 用 Reducer** — 消息用 `add_messages`，避免覆盖历史
6. **定期清理** — Session 过期策略，避免 State 无限增长

## 关联图谱

- [[entities/Google-ADK]] — ADK SessionService 详解
- [[entities/LangGraph]] — LangGraph Checkpointer 详解
- [[concepts/Agent工具组织]] — 工具如何通过 ToolContext 读写状态
- [[concepts/接力机制]] — 跨智能体状态传递
- [[concepts/任务拆解]] — 状态如何在子任务间流转
