---
type: entity
title: Google ADK
source: 'https://google.github.io/adk-docs/ + https://github.com/google/adk-python'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [工具, 框架, agent-orchestration, 多智能体, 谷歌, gemini]
---

# Google ADK（Agent Development Kit）

Google 于 2025 年 4 月在 Cloud Next 大会上发布的开源 AI Agent 开发框架。与 Gemini 深度集成但支持任意 LLM，是 Google Agent 生态的核心 SDK，与 **A2A（Agent-to-Agent）协议**共同构成 Google 的 Agent 互操作标准。

## 核心定位

| 维度 | 说明 |
|------|------|
| **发起方** | Google（Gemini / Vertex AI 团队） |
| **定位** | 全栈 Agent 开发框架（开发 + 编排 + 部署） |
| **语言** | Python / Go |
| **模型支持** | Gemini（首选）/ OpenAI / Anthropic / 任意兼容 OpenAI API 的模型 |
| **安装** | `pip install google-adk` |
| **开源协议** | Apache 2.0 |

## 架构总览

```
┌─────────────────────────────────────────────────┐
│                  Google ADK                       │
├─────────────────────────────────────────────────┤
│  Agent 层                                        │
│  ┌──────────┐ ┌────────────┐ ┌──────────────┐  │
│  │ LlmAgent │ │Sequential  │ │  Parallel    │  │
│  │ (核心)   │ │  Agent     │ │  Agent       │  │
│  └──────────┘ └────────────┘ └──────────────┘  │
│  ┌──────────┐ ┌────────────┐                    │
│  │LoopAgent │ │  BaseAgent │ ← 自定义基类       │
│  └──────────┘ └────────────┘                    │
├─────────────────────────────────────────────────┤
│  工具层                                          │
│  FunctionTool | Google Search | Code Execution  │
│  Agent-as-Tool | MCP Tools | LangChain Bridge   │
├─────────────────────────────────────────────────┤
│  状态 / 会话层                                    │
│  SessionService | ToolContext | Artifacts        │
├─────────────────────────────────────────────────┤
│  基础设施层                                       │
│  Model Callbacks | A2A Protocol | Deployment     │
│  Vertex AI Agent Engine | Cloud Run | GKE        │
└─────────────────────────────────────────────────┘
```

## Agent 类型

| Agent | 用途 | 关键特征 |
|-------|------|---------|
| **LlmAgent** | 核心 LLM Agent | 自动工具调用循环、多轮推理、子 Agent 委派 |
| **SequentialAgent** | 顺序编排 | 子 Agent 按序执行，前一个输出作为后一个上下文 |
| **ParallelAgent** | 并发编排 | 子 Agent 并行执行，结果合并 |
| **LoopAgent** | 循环编排 | 子 Agent 重复执行，直到满足退出条件 |
| **BaseAgent** | 自定义基类 | 用户继承实现 `run_async`，扩展任意行为 |

### LlmAgent 核心属性

```python
from google.adk.agents import LlmAgent

agent = LlmAgent(
    name="research_agent",
    model="gemini-2.0-flash",          # 或 "gpt-4o" 等
    instruction="你是研究助手...",       # 系统指令
    tools=[search_tool, calc_tool],     # 工具列表
    sub_agents=[writer_agent],          # 子 Agent（可委派）
    output_key="research_result",       # 输出写入 state 的 key
)
```

### 子 Agent 委派机制

LlmAgent 的 `sub_agents` 属性启用**隐式委派**：当 LLM 判断当前任务更适合由子 Agent 处理时，自动将控制权转移给子 Agent（类似 OpenAI Swarm 的 Handoff）。

## 工具集成（Tool Integration）

ADK 的工具系统分四层，详见 [[concepts/Agent工具组织]]：

| 工具类型 | 说明 | 示例 |
|---------|------|------|
| **FunctionTool** | Python 函数自动包装 | `def get_weather(city: str) -> dict` |
| **Built-in Tools** | Google 内置工具 | Google Search / Code Execution / Vertex AI Search |
| **Agent-as-Tool** | 子 Agent 作为工具调用 | `LlmAgent(tools=[sub_agent.as_tool()])` |
| **MCP Tools** | Model Context Protocol | 连接任意 MCP Server 提供的工具 |
| **Third-party Bridge** | 桥接其他框架 | LangChain / CrewAI 工具适配 |

### FunctionTool 自动推断

ADK 通过函数签名和 docstring 自动推断 JSON Schema，无需手动定义参数描述：

```python
from google.adk.tools import FunctionTool

def query_database(sql: str, limit: int = 100) -> list:
    """执行 SQL 查询并返回结果。

    Args:
        sql: SQL 查询语句
        limit: 返回行数上限
    """
    return db.execute(sql).fetchmany(limit)

# ADK 自动从类型注解 + docstring 生成 tool schema
tool = FunctionTool(func=query_database)
```

## 状态管理（State Management）

ADK 的状态系统以 **Session** 为核心，详见 [[concepts/Agent状态管理]]：

```
Session
├── state: dict          ← 跨工具/跨 Agent 共享的键值存储
├── events: list[Event]  ← 对话历史（消息 + 工具调用 + 结果）
├── user_data: dict      ← 用户级持久数据
└── app_state: dict      ← 应用级持久数据
```

### SessionService 后端

| 后端 | 用途 |
|------|------|
| **InMemorySessionService** | 开发测试，进程内存 |
| **DatabaseSessionService** | 生产环境，Cloud SQL / PostgreSQL |
| **VertexAiSessionService** | Vertex AI Agent Engine 托管 |

### ToolContext 读写 State

```python
def update_preference(key: str, value: str, tool_context: ToolContext) -> dict:
    """更新用户偏好设置。"""
    tool_context.state[f"user_pref_{key}"] = value
    return {"status": "updated", "key": key}
```

## 回调系统（Callbacks）

ADK 在 Agent 生命周期的关键节点提供回调钩子：

| 回调 | 触发时机 | 典型用途 |
|------|---------|---------|
| `before_agent_callback` | Agent 开始执行前 | 权限检查、输入清洗 |
| `after_agent_callback` | Agent 执行完成后 | 日志记录、结果后处理 |
| `before_model_callback` | LLM 调用前 | Prompt 注入、token 预算检查 |
| `after_model_callback` | LLM 调用后 | 输出过滤、安全检查 |
| `before_tool_callback` | 工具调用前 | 参数校验、权限验证 |
| `after_tool_callback` | 工具调用后 | 结果缓存、审计日志 |

```python
def safety_check(callback_context, tool, args):
    """工具调用前的安全检查。"""
    if "DROP TABLE" in args.get("sql", ""):
        return "SQL 操作被安全策略阻止"
    return None  # None = 允许继续

agent = LlmAgent(
    model="gemini-2.0-flash",
    tools=[query_tool],
    before_tool_callback=safety_check,
)
```

## 多 Agent 编排

ADK 内置三种编排原语 + 自定义扩展：

```
SequentialAgent (A → B → C)     适合 Pipeline
ParallelAgent (A ‖ B ‖ C)       适合 Map-Reduce
LoopAgent (A ↔ B ↔ C)           适合迭代优化
```

### 典型编排拓扑

```python
# 研究 → 写作 → 审查 Pipeline
pipeline = SequentialAgent(
    name="content_pipeline",
    sub_agents=[
        LlmAgent(name="researcher", model="gemini-2.0-flash",
                 instruction="搜索并整理资料", tools=[search]),
        LlmAgent(name="writer", model="gemini-2.0-flash",
                 instruction="基于资料撰写文章"),
        LlmAgent(name="reviewer", model="gemini-2.0-flash",
                 instruction="审查并改进文章质量"),
    ]
)
```

## A2A 协议（Agent-to-Agent）

ADK 原生支持 Google 提出的 **A2A 协议**，实现跨框架 Agent 互操作：

| 概念 | 说明 |
|------|------|
| **Agent Card** | JSON 描述文件，暴露 Agent 的能力和端点 |
| **Task** | Agent 间的工作单元，有状态生命周期 |
| **Message** | Agent 间通信的消息格式 |
| **Artifact** | Task 产生的文件/数据输出 |

A2A 使 ADK Agent 可以与 AutoGen、LangGraph、OpenAI Agents 等框架的 Agent 直接通信。

## 部署选项

| 目标 | 说明 |
|------|------|
| **本地开发** | `adk web` 启动本地调试 UI / `adk run` CLI 测试 |
| **Vertex AI Agent Engine** | Google 全托管，自动扩缩、监控、评估 |
| **Cloud Run** | 容器化部署，支持长连接 |
| **GKE** | Kubernetes 编排，适合复杂多 Agent 系统 |

### 开发 CLI

```bash
# 启动 Web 调试界面
adk web

# CLI 直接运行 Agent
adk run my_agent

# 运行测试
adk test my_agent --test-data test.json
```

## 与其他框架对比

| 维度 | Google ADK | LangGraph | AutoGen |
|------|-----------|-----------|---------|
| **架构** | Agent-centric | Graph-centric | Conversation-centric |
| **编排原语** | Sequential/Parallel/Loop | StateGraph + Edge | GroupChat |
| **状态管理** | Session dict | Checkpoint + Reducer | 弱（无内置持久化） |
| **工具集成** | FunctionTool + MCP + Built-in | ToolNode + LangChain | FunctionTool |
| **模型绑定** | Gemini 优先，可扩展 | 模型无关 | 模型无关 |
| **部署** | Vertex AI / Cloud Run / GKE | LangSmith Deploy | 无内置 |
| **互操作** | A2A 协议原生支持 | 无 | 无 |

详见 [[comparisons/adk-vs-autogen]]

## 局限性

| 局限 | 说明 |
|------|------|
| **Gemini 偏向** | 内置工具（Google Search / Code Execution）仅 Gemini 可用 |
| **编排较简单** | 三种原语不够表达复杂条件分支（对比 LangGraph 的 StateGraph） |
| **生态年轻** | 2025 年 4 月发布，社区和第三方集成尚在建设 |
| **可观测性** | 无内置 tracing 平台（对比 LangSmith） |
| **Checkpointer** | 无原生 Checkpoint 机制（对比 LangGraph 的 Checkpointer） |

## 现状（2026-06）

- **PyPI**：`pip install google-adk`
- **GitHub Stars**：~15k+
- **版本**：持续更新中
- **状态**：活跃开发，Google Agent 生态核心 SDK

## 关联图谱

- [[concepts/Agent工具组织]] — ADK 工具组织模式详解
- [[concepts/Agent状态管理]] — ADK 状态管理模式详解
- [[comparisons/adk-vs-autogen]] — ADK vs AutoGen 对比
- [[entities/LangGraph]] — 另一种编排框架
- [[entities/AutoGen]] — 另一种多 Agent 框架
- [[concepts/总控Agent模式]] — Supervisor 架构在 ADK 中的实现
- [[concepts/接力机制]] — ADK 子 Agent 委派 vs 接力机制
