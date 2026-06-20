---
type: entity
title: OpenAI Agents SDK
source: 'https://openai.github.io/openai-agents-python/ + https://github.com/openai/openai-agents-python'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [框架, 多智能体, OpenAI, agent, handoff, guardrail]
---

# OpenAI Agents SDK

OpenAI 官方 Agent 框架，是 Swarm 实验项目的生产级继任者。以极简原语（Agent / Handoff / Guardrail）构建多 Agent 应用。

> **GitHub**: https://github.com/openai/openai-agents-python
> **文档**: https://openai.github.io/openai-agents-python/
> **版本**: 0.17.x（快速迭代中）
> **语言**: Python
> **许可证**: MIT

## 核心设计哲学

两大原则：
1. **足够好用，但原语足够少** — 只有 Agent / Handoff / Guardrail 三个核心概念
2. **开箱即用，但完全可定制** — 默认行为合理，但每个环节都可覆盖

与 AutoGen 的"对话驱动"、Agent Framework 的"图驱动"不同，OpenAI Agents SDK 以 **Handoff 驱动** 为核心：Agent 自主决定何时将控制权交给谁。

## 三大原语

### 1. Agent（智能体）

Agent = LLM + 指令 + 工具 + 可选行为（handoff / guardrail / 结构化输出）。

```python
from agents import Agent, function_tool

@function_tool
def get_weather(city: str) -> str:
    """返回指定城市的天气信息。"""
    return f"{city} 天气晴朗"

agent = Agent(
    name="天气助手",
    instructions="你是一个天气查询助手，始终用中文回答。",
    model="gpt-5-nano",
    tools=[get_weather],
)
```

**关键属性**：

| 属性 | 必填 | 说明 |
|------|------|------|
| name | ✓ | 人类可读的 Agent 名称 |
| instructions | 推荐 | 系统提示词（支持动态回调） |
| model | — | LLM 模型（默认 gpt-5-nano） |
| tools | — | 工具列表 |
| handoffs | — | 可交接的目标 Agent 列表 |
| input_guardrails | — | 输入护栏 |
| output_guardrails | — | 输出护栏 |
| output_type | — | 结构化输出类型（Pydantic） |
| hooks | — | 生命周期回调 |
| mcp_servers | — | MCP 服务器列表 |

### 2. Handoff（任务交接）

Agent 之间的控制权转移机制。Handoff 对 LLM 表现为一个工具调用（如 `transfer_to_billing_agent`）。

```python
from agents import Agent, handoff

billing_agent = Agent(name="账单专家", instructions="处理账单问题")
refund_agent = Agent(name="退款专家", instructions="处理退款请求")

triage_agent = Agent(
    name="分诊台",
    instructions="根据用户问题路由到正确的专家",
    handoffs=[billing_agent, handoff(refund_agent)]
)
```

详见 → [Handoff模式](../concepts/Handoff模式.md)

### 3. Guardrail（护栏）

输入/输出验证机制，可并行或阻塞执行，通过 tripwire（绊线）快速失败。

```python
from agents import Agent, input_guardrail, GuardrailFunctionOutput

@input_guardrail
async def check_no_math(ctx, agent, input):
    # 用快速模型检查用户是否在问数学题
    result = await Runner.run(math_detector, input)
    return GuardrailFunctionOutput(
        output_info=result,
        tripwire_triggered=result.final_output.is_math_homework
    )

agent = Agent(
    name="客服",
    instructions="帮助客户解决问题",
    input_guardrails=[check_no_math]
)
```

详见 → [Guardrail模式](../concepts/Guardrail模式.md)

## 工具体系

SDK 支持 5 类工具：

| 类别 | 说明 | 运行位置 |
|------|------|----------|
| Hosted 工具 | WebSearchTool / FileSearchTool / CodeInterpreterTool / HostedMCPTool / ImageGenerationTool | OpenAI 服务器 |
| 本地运行时工具 | ComputerTool / ShellTool / ApplyPatchTool | 本地环境 |
| Function 工具 | 任意 Python 函数包装为工具 | 本地 |
| Agent as Tool | Agent 作为可调用工具（无 handoff） | 本地 |
| Codex 工具（实验） | 工作区级 Codex 任务 | 本地/远程 |

### Agent as Tool vs Handoff

| 维度 | Handoff | Agent as Tool |
|------|---------|---------------|
| 控制权 | 完全转移 | 保持在调用方 |
| 对话历史 | 接收方看到全部历史 | 调用方管理 |
| 适用场景 | 路由/分诊 | Manager 模式/子任务 |

```python
# Agent as Tool — Manager 模式
researcher = Agent(name="研究员", instructions="搜索信息")
writer = Agent(name="作家", instructions="撰写报告")

manager = Agent(
    name="项目经理",
    instructions="协调研究员和作家完成任务",
    tools=[
        researcher.as_tool(tool_name="research", tool_description="搜索信息"),
        writer.as_tool(tool_name="write", tool_description="撰写报告"),
    ]
)
```

## Tracing（链路追踪）

内置 OpenTelemetry 兼容的 tracing，可可视化完整 Agent 执行流程：

- 每次 `Runner.run()` 生成一个 trace
- Handoff / 工具调用 / Guardrail 检查 各有 span
- 支持自定义 exporter（对接 Jaeger / Zipkin / Datadog）
- 可用于评估和微调

```python
from agents import set_trace_processors

# 自定义 trace 处理器
set_trace_processors([my_custom_processor])
```

## Runner（运行引擎）

Runner 是 Agent 的执行引擎，管理工具调用循环：

```python
from agents import Runner

# 同步运行
result = Runner.run_sync(agent, "你好")
print(result.final_output)

# 异步运行
result = await Runner.run(agent, "你好")

# 流式运行
async for event in Runner.run_streamed(agent, "你好"):
    print(event)
```

**执行流程**：
1. 将用户输入 + 系统提示发送给 LLM
2. LLM 返回文本 → 结束，或返回工具调用 → 执行工具
3. 工具结果回传 LLM → 重复步骤 2
4. 直到 LLM 返回最终文本或触发 handoff

## Context（上下文管理）

Agent 支持泛型 Context 类型，用于依赖注入：

```python
from dataclasses import dataclass
from agents import Agent, RunContextWrapper, function_tool

@dataclass
class AppContext:
    db: Database
    user_id: str

@function_tool
async def get_user_orders(ctx: RunContextWrapper[AppContext]) -> str:
    """查询当前用户的订单。"""
    orders = await ctx.context.db.get_orders(ctx.context.user_id)
    return str(orders)

agent = Agent[AppContext](
    name="订单助手",
    tools=[get_user_orders]
)
```

## MCP 集成

原生支持 Model Context Protocol，可连接 MCP 服务器获取工具：

```python
from agents import Agent
from agents.mcp import MCPServerStdio

mcp_server = MCPServerStdio(
    command="npx",
    args=["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
)

agent = Agent(
    name="文件助手",
    mcp_servers=[mcp_server]
)
```

## 与本知识库的关联

| 已有概念 | 与本框架的关系 |
|---------|--------------|
| [接力机制](../concepts/接力机制.md) | Handoff 是接力的代码级实现 |
| [渐进式开发](../concepts/渐进式开发.md) | SDK 的极简设计适合渐进式集成 |
| [多Agent协作](../concepts/多Agent协作.md) | Handoff 模式是协作模式之一 |
| [Guardrail模式](../concepts/Guardrail模式.md) | 安全边界的工程化实现 |
| [Handoff模式](../concepts/Handoff模式.md) | Handoff 模式详解 |
| [autogen-vs-openai-agents](../comparisons/autogen-vs-openai-agents.md) | 选型对比 |

## 关联图谱

- [Handoff模式](../concepts/Handoff模式.md) — Agent 间任务交接详解
- [Guardrail模式](../concepts/Guardrail模式.md) — 安全边界机制详解
- [autogen-vs-openai-agents](../comparisons/autogen-vs-openai-agents.md) — 与 AutoGen/Agent Framework 对比
- [排查总控仓库脏状态](../summaries/排查总控仓库脏状态.md) — 应用案例
