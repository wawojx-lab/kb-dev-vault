---
type: concept
title: Agent工具组织
source: 'Google ADK 文档 + LangGraph ToolNode + AutoGen FunctionTool 调研'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [方法论, agent-orchestration, 工具集成, 框架对比]
---

# Agent 工具组织（Agent Tool Organization）

AI Agent 框架如何将外部能力（API / 函数 / 数据源 / 其他 Agent）组织为可被 LLM 调用的工具。工具组织是 Agent 能力的边界定义——工具越清晰，Agent 越可靠。

## 工具的三层抽象

```
┌───────────────────────────────────────┐
│  Agent 可见层（LLM 看到的 tool schema）  │
│  → name / description / parameters    │
├───────────────────────────────────────┤
│  适配层（自动推断 + 手动标注）            │
│  → 类型注解 / docstring / Pydantic     │
├───────────────────────────────────────┤
│  执行层（实际调用的代码）                 │
│  → Python 函数 / HTTP 请求 / MCP 调用  │
└───────────────────────────────────────┘
```

## 三大框架的工具组织方式

### Google ADK：FunctionTool + 内置工具

ADK 工具分四类：

| 类型 | 说明 | 示例 |
|------|------|------|
| **FunctionTool** | Python 函数 → 自动推断 JSON Schema | `def get_weather(city: str) -> dict` |
| **Built-in Tools** | Google 内置，仅 Gemini 可用 | Google Search / Code Execution |
| **Agent-as-Tool** | 将子 Agent 包装为工具调用 | `agent.as_tool()` |
| **MCP Tools** | 通过 MCP 协议连接外部工具服务 | 连接任意 MCP Server |

```python
# ADK：自动从签名推断 schema
from google.adk.tools import FunctionTool

def search_docs(query: str, top_k: int = 5) -> list:
    """搜索文档库返回相关结果。

    Args:
        query: 搜索关键词
        top_k: 返回结果数量
    """
    return vector_db.search(query, limit=top_k)

tool = FunctionTool(func=search_docs)
```

**ADK 特色**：Agent-as-Tool 模式——一个 Agent 被另一个 Agent 当工具调用，而非转移控制权。这区别于 sub_agents 的委派（Handoff）模式。

### LangGraph：ToolNode + bind_tools

LangGraph 的工具组织围绕 **ToolNode** 和 **MessagesState**：

```python
# LangGraph：显式绑定 + ToolNode 执行
from langgraph.prebuilt import ToolNode

tools = [get_weather, search_docs]
model_with_tools = model.bind_tools(tools)
tool_node = ToolNode(tools)

# 工具通过 messages 中的 tool_calls 字段驱动
def agent_node(state: MessagesState):
    response = model_with_tools.invoke(state["messages"])
    return {"messages": [response]}  # tool_calls 自动触发 ToolNode
```

**LangGraph 特色**：工具是图节点，可以通过条件边控制执行流（如权限检查节点在工具节点之前）。

### AutoGen：FunctionTool + ToolAgent

```python
# AutoGen：函数包装 + 注册到 Agent
from autogen_core.tools import FunctionTool

tool = FunctionTool(search_docs, description="搜索文档库")
agent = AssistantAgent("assistant", model_client=model, tools=[tool])
```

**AutoGen 特色**：SocietyOfMindAgent 可以将一组 Agent 包装为单个工具。

## 工具 Schema 推断策略

| 框架 | 推断方式 | 描述来源 | 备注 |
|------|---------|---------|------|
| **ADK** | 类型注解 + docstring Args | 函数文档字符串 | 支持 Pydantic model |
| **LangGraph** | 类型注解 + Pydantic | `@tool` 装饰器的 docstring | 同 LangChain tool 规范 |
| **AutoGen** | 类型注解 + docstring | 函数文档字符串 | 支持 JSON Schema 手动定义 |

三种框架都实现了**自动推断**：开发者只需写好类型注解和文档字符串，框架自动生成 LLM 可理解的 tool schema。

## 工具编排模式

### 模式 1：扁平工具列表

```
Agent
├── tool_1 (API 调用)
├── tool_2 (数据库查询)
├── tool_3 (文件操作)
└── tool_4 (计算)
```

所有工具平铺，LLM 自主选择。适合工具少（< 10）、职责不冲突的场景。

### 模式 2：分层工具（Agent-as-Tool）

```
Agent (总控)
├── research_agent.as_tool()   ← 研究能力
├── coding_agent.as_tool()     ← 编码能力
└── review_agent.as_tool()     ← 审查能力
    ├── search_tool            ← research_agent 的工具
    ├── code_exec_tool         ← coding_agent 的工具
    └── diff_tool              ← review_agent 的工具
```

每个子 Agent 封装一组相关工具，对外暴露为单一工具。适合工具多、需要领域隔离的场景。

### 模式 3：动态工具注册

```
Agent + Plugin System
├── 核心工具（始终可用）
├── 按需加载（通过 MCP / Tool Server 动态发现）
└── 用户自定义（运行时注册）
```

ADK 的 MCP 支持实现了动态工具发现：Agent 运行时连接 MCP Server，自动获取可用工具列表。

## 与 [[concepts/接力机制]] 的关系

| 维度 | 工具调用 | 接力机制 |
|------|---------|---------|
| **粒度** | 单次函数调用 | 完整任务交接 |
| **上下文** | 通过 state 自动传递 | 通过文件手动传递 |
| **控制权** | 调用后返回调用者 | 调用后控制权转移 |
| **适用** | API / 计算 / 查询 | 跨会话 / 跨智能体 |

## 最佳实践

1. **一个工具做一件事** — 单一职责，描述清晰
2. **描述比签名更重要** — LLM 通过描述理解何时使用工具
3. **参数越少越好** — 必填参数少，可选参数有默认值
4. **返回结构化数据** — dict / JSON 而非自由文本
5. **错误要可读** — 工具异常返回用户可理解的消息
6. **Agent-as-Tool 隔离复杂度** — 子 Agent 封装领域知识，总控只关心结果

## 关联图谱

- [[entities/Google-ADK]] — ADK 框架详解
- [[entities/LangGraph]] — LangGraph ToolNode
- [[entities/AutoGen]] — AutoGen FunctionTool
- [[concepts/接力机制]] — Agent 间传递上下文
- [[concepts/总控Agent模式]] — Agent-as-Tool 的编排拓扑
