---
type: concept
title: Handoff模式
source: 'https://openai.github.io/openai-agents-python/handoffs/'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [概念, 多智能体, handoff, 任务交接, OpenAI]
---

# Handoff 模式（Agent 间任务交接）

Agent 之间传递控制权的机制。源自 OpenAI Agents SDK 的核心设计：Agent 自主决定何时将任务交给哪个专家。

## 核心思想

Handoff = **路由决策权交给 LLM**。与图工作流（预定义 DAG）不同，Handoff 模式下 Agent 根据对话内容自主决定是否交接、交给谁。

```
用户 → [分诊Agent] ──handoff──→ [退款Agent] ──handoff──→ [分诊Agent] → 用户
                                    ↑
                              LLM 判断需要退款专家
```

## 工作原理

1. **Handoff 表现为工具调用**：对 LLM 来说，`handoff_to_refund_agent` 就是一个普通工具
2. **LLM 自主决策**：根据用户输入和指令，决定是否调用 handoff 工具
3. **控制权转移**：调用后，新的 Agent 接管对话，看到之前的历史
4. **可链式传递**：新 Agent 也可以 handoff 到其他 Agent

## 代码示例

### 基础用法

```python
from agents import Agent

billing = Agent(name="账单专家", instructions="处理账单问题")
refund = Agent(name="退款专家", instructions="处理退款")

triage = Agent(
    name="分诊台",
    instructions="根据问题类型路由：账单→billing，退款→refund",
    handoffs=[billing, refund]
)
```

### 完整定制

```python
from agents import Agent, handoff, RunContextWrapper
from pydantic import BaseModel

class EscalationData(BaseModel):
    reason: str
    priority: str

async def on_handoff(ctx: RunContextWrapper, input_data: EscalationData):
    log(f"升级原因: {input_data.reason}, 优先级: {input_data.priority}")

escalation = Agent(name="升级处理")

triage = Agent(
    name="分诊台",
    handoffs=[
        handoff(
            agent=escalation,
            on_handoff=on_handoff,
            input_type=EscalationData,
            tool_name_override="escalate_to_senior",
            tool_description_override="将问题升级给高级处理团队"
        )
    ]
)
```

### Input Filter（过滤对话历史）

```python
from agents import handoff, HandoffInputData

def filter_history(data: HandoffInputData) -> HandoffInputData:
    """只保留最近 5 条消息传给下一个 Agent"""
    if isinstance(data.input_history, list):
        data.input_history = data.input_history[-5:]
    return data

triage = Agent(
    name="分诊台",
    handoffs=[
        handoff(agent=specialist, input_filter=filter_history)
    ]
)
```

## Handoff 配置参数

| 参数 | 说明 |
|------|------|
| agent | 目标 Agent |
| tool_name_override | 自定义工具名（默认 `transfer_to_<name>`） |
| tool_description_override | 自定义工具描述 |
| on_handoff | 交接时的回调函数 |
| input_type | Pydantic 模型，定义 LLM 交接时需提供的数据 |
| input_filter | 过滤传给下一个 Agent 的对话历史 |
| is_enabled | 动态启用/禁用（布尔值或函数） |
| nest_handoff_history | 是否嵌套历史（RunConfig 级别覆盖） |

## 适用场景

| 场景 | 为什么用 Handoff |
|------|-----------------|
| 客服分诊 | 用户问题类型不确定，需要 LLM 判断路由 |
| 流水线处理 | 阶段间有条件跳转（如退款需审批→升级） |
| 多语言 | 根据用户语言 handoff 到对应语言 Agent |
| 复杂度递增 | 先用简单模型，不确定时 handoff 到强模型 |

## 与其他模式的对比

| 维度 | Handoff | Agent as Tool | 图工作流 |
|------|---------|---------------|----------|
| 控制流 | LLM 决定 | 调用方决定 | 预定义 |
| 控制权 | 完全转移 | 保持在调用方 | 框架管理 |
| 灵活性 | 高（动态路由） | 中 | 低（固定拓扑） |
| 可观测性 | 需 tracing | 天然嵌套 | 天然 DAG |
| 适用场景 | 路由/分诊 | 子任务委托 | 固定流程 |

## 工程化要点

### 1. 指令要明确路由规则

```python
# ❌ 模糊指令
instructions="帮助用户解决问题"

# ✓ 明确路由规则
instructions="""你是分诊台，按以下规则路由：
- 账单/付款问题 → transfer_to_billing
- 退款/退货 → transfer_to_refund
- 技术问题 → transfer_to_tech
- 其他 → 自己回答"""
```

### 2. 用 on_handoff 做副作用

```python
async def log_handoff(ctx, input_data):
    metrics.increment(f"handoff_to_{target_agent.name}")
    logger.info(f"Handoff: {input_data.reason}")
```

### 3. 用 input_filter 控制上下文膨胀

长对话中，传全部历史会导致 token 浪费。用 filter 只传相关部分。

### 4. 用 is_enabled 做动态路由

```python
handoff(
    agent=premium_agent,
    is_enabled=lambda ctx: ctx.context.user_tier == "premium"
)
```

## 与接力机制的关系

Handoff 是**代码级的接力**：Agent A 完成工作后，通过工具调用将控制权交给 Agent B。与 [[concepts/接力机制]] 中的文件级接力（WORKLOG.md / PROJECT_STATUS.md）互补：

- **Handoff 接力**：同一次运行内，Agent 间实时传递
- **文件接力**：跨会话/跨智能体，通过文件传递上下文

## 关联图谱

- [[entities/OpenAI-Agents-SDK]] — 所属框架
- [Guardrail模式](../concepts/Guardrail模式.md) — 安全边界（与 Handoff 配合使用）
- [[concepts/多Agent协作]] — 协作模式全景
- [[concepts/接力机制]] — 文件级接力协议
