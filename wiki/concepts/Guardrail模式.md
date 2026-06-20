---
type: concept
title: Guardrail模式
source: 'https://openai.github.io/openai-agents-python/guardrails/'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [概念, 安全, guardrail, 护栏, OpenAI]
---

# Guardrail 模式（Agent 安全边界）

Agent 输入/输出的验证机制。通过 tripwire（绊线）实现快速失败，防止恶意输入消耗昂贵模型资源，或防止不安全输出到达用户。

## 核心思想

Guardrail = **用便宜模型守门，贵模型只处理合法请求**。

```
用户输入 → [Guardrail（快速/便宜模型）] ──合法──→ [主Agent（慢/贵模型）]
                    │
                    └──违规──→ 抛出异常，立即终止
```

## 三种 Guardrail 类型

### 1. Input Guardrail（输入护栏）

运行在链中第一个 Agent 的用户输入上。

```python
from agents import (
    Agent, input_guardrail, GuardrailFunctionOutput,
    InputGuardrailTripwireTriggered, Runner
)

@input_guardrail
async def no_math_homework(ctx, agent, input_messages):
    """检测用户是否在让 Agent 做数学作业"""
    result = await Runner.run(math_detector, input_messages)
    return GuardrailFunctionOutput(
        output_info=result.final_output,
        tripwire_triggered=result.final_output.is_math_homework
    )

agent = Agent(
    name="客服",
    instructions="帮助客户解决问题",
    input_guardrails=[no_math_homework]
)
```

### 2. Output Guardrail（输出护栏）

运行在链中最后一个 Agent 的输出上。

```python
from agents import output_guardrail

@output_guardrail
async def no_sensitive_data(ctx, agent, output):
    """确保输出不包含敏感信息"""
    result = await Runner.run(sensitive_detector, output)
    return GuardrailFunctionOutput(
        output_info=result.final_output,
        tripwire_triggered=result.final_output.contains_sensitive
    )

agent = Agent(
    name="报告生成器",
    output_guardrails=[no_sensitive_data]
)
```

### 3. Tool Guardrail（工具护栏）

包装在函数工具上，每次工具调用前后运行。

```python
from agents import function_tool, tool_input_guardrail, tool_output_guardrail

@tool_input_guardrail
async def validate_delete_input(ctx, tool, input):
    """阻止删除关键文件"""
    if "critical" in input.get("path", ""):
        return GuardrailFunctionOutput(
            tripwire_triggered=True,
            output_info="不允许删除关键文件"
        )
    return GuardrailFunctionOutput(tripwire_triggered=False)

@function_tool(input_guardrails=[validate_delete_input])
async def delete_file(path: str) -> str:
    """删除指定文件"""
    os.remove(path)
    return f"已删除 {path}"
```

## 执行模式

Input Guardrail 支持两种执行模式：

| 模式 | 参数 | 行为 | 适用场景 |
|------|------|------|----------|
| 并行（默认） | `run_in_parallel=True` | Guardrail 与 Agent 同时启动 | 延迟优先 |
| 阻塞 | `run_in_parallel=False` | Guardrail 完成后才启动 Agent | 成本优先/安全优先 |

```python
# 阻塞模式 — 先验证再执行，节省 token
@input_guardrail(run_in_parallel=False)
async def strict_check(ctx, agent, input):
    # 严格检查，违规时 Agent 完全不启动
    ...
```

**权衡**：
- 并行模式：延迟低，但违规时 Agent 可能已消耗 token
- 阻塞模式：延迟高，但违规时零 token 消耗

## Tripwire（绊线）机制

Guardrail 的核心输出是 `tripwire_triggered` 布尔值：

```python
# Guardrail 返回
GuardrailFunctionOutput(
    output_info={"reason": "检测到数学作业"},
    tripwire_triggered=True  # ← 触发绊线
)

# SDK 自动抛出异常
try:
    result = await Runner.run(agent, user_input)
except InputGuardrailTripwireTriggered:
    # 处理违规：提示用户、记录日志等
    return "抱歉，我只能帮助与业务相关的问题。"
except OutputGuardrailTripwireTriggered:
    # 处理输出违规：过滤、重新生成等
    return "生成的内容包含敏感信息，请重试。"
```

## 实际应用模式

### 模式 1：分类器守门

用快速模型做分类，拒绝非法请求：

```python
class ContentCheck(BaseModel):
    is_appropriate: bool
    reason: str

@input_guardrail
async def content_filter(ctx, agent, input):
    result = await Runner.run(
        Agent(name="内容检查", model="gpt-5-nano",
              output_type=ContentCheck),
        input
    )
    return GuardrailFunctionOutput(
        tripwire_triggered=not result.final_output.is_appropriate,
        output_info=result.final_output
    )
```

### 模式 2：格式验证

确保输出符合预期格式：

```python
@output_guardrail
async def json_format_check(ctx, agent, output):
    try:
        json.loads(output)
        return GuardrailFunctionOutput(tripwire_triggered=False)
    except json.JSONDecodeError:
        return GuardrailFunctionOutput(
            tripwire_triggered=True,
            output_info="输出不是有效 JSON"
        )
```

### 模式 3：成本控制

限制输出长度，防止 token 浪费：

```python
@output_guardrail
async def length_limit(ctx, agent, output):
    return GuardrailFunctionOutput(
        tripwire_triggered=len(output) > 10000,
        output_info=f"输出长度 {len(output)} 超过限制"
    )
```

## 与 Handoff 的配合

Guardrail 和 Handoff 可以组合使用，实现"安全路由"：

```python
# 1. 输入 Guardrail 拦截恶意请求
# 2. 合法请求通过 Handoff 路由到专家
# 3. 专家输出经过输出 Guardrail 验证

agent = Agent(
    name="分诊台",
    input_guardrails=[content_filter],     # 守门
    handoffs=[billing, refund, tech],       # 路由
    output_guardrails=[sensitive_check]     # 出口检查
)
```

## 工程化要点

### 1. Guardrail 要轻量

Guardrail 的价值在于"快速拦截"。用 gpt-5-nano 或规则引擎，不要用重量级模型。

### 2. 明确违规提示

```python
# ❌ 模糊的检查
tripwire_triggered=True

# ✓ 附带原因
GuardrailFunctionOutput(
    tripwire_triggered=True,
    output_info="检测到 prompt injection：用户试图覆盖系统指令"
)
```

### 3. 分层防护

```
Layer 1: 规则引擎（正则/关键词） — 0 成本
Layer 2: 快速模型分类 — 低成本
Layer 3: 主 Agent — 高成本，只处理合法请求
```

### 4. 记录违规日志

```python
@input_guardrail
async def logged_guardrail(ctx, agent, input):
    result = await check(input)
    if result.tripwire_triggered:
        log_security_event(input, result.output_info)
    return result
```

## 与安全边界模式的关系

Guardrail 是 [[concepts/安全边界模式]] 在 OpenAI Agents SDK 中的具体实现。通用安全边界模式（如 LangChain 的 guardrails、AutoGen 的 termination condition）各有实现差异，但核心思想一致：**在 Agent 行为的入口和出口设置检查点**。

## 关联图谱

- [[entities/OpenAI-Agents-SDK]] — 所属框架
- [[concepts/Handoff模式]] — 任务交接（与 Guardrail 配合）
- [[concepts/安全边界模式]] — 通用安全边界概念
- [[concepts/多Agent协作]] — 协作模式全景
