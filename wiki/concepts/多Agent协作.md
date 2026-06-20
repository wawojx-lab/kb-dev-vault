---
type: concept
title: 多Agent协作
source: 'Microsoft Agent Framework 文档 + AutoGen 文档 + OpenAI Swarm + LangGraph'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [方法论, 多智能体, agent-orchestration, 协作模式]
---

# 多 Agent 协作（Multi-Agent Collaboration）

多个 AI Agent 通过分工、通信、协调共同完成复杂任务的架构模式。核心问题是**谁做什么、怎么传递、何时结束**。

## 为什么需要多 Agent

| 单 Agent 的瓶颈 | 多 Agent 的优势 |
|-----------------|---------------|
| Prompt 过长 → 注意力稀释 | 每个 Agent 专注一个领域 |
| 工具过多 → 选择困难 | 工具按职责分配给不同 Agent |
| 任务复杂 → 一步出错全盘失败 | 子任务独立验证，局部失败可重试 |
| 无专精 → 样样通样样松 | 每个 Agent 深耕一个能力域 |

## 四种主流协作模式

### 模式 1：顺序流水线（Sequential Pipeline）

```
Agent A ──→ Agent B ──→ Agent C ──→ 输出
(研究)      (编写)      (审核)
```

- **分工方式**：每个 Agent 负责一个阶段
- **传递机制**：前一个 Agent 的输出直接作为后一个的输入
- **适用场景**：有明确先后顺序的任务（研究 → 写作 → 审核）
- **框架支持**：Agent Workflow Sequential / LangGraph 线性图 / AutoGen Sequential

### 模式 2：总控调度（Supervisor/Orchestrator）

```
         ┌─────────────┐
         │  Supervisor  │ ← 路由决策
         └──┬───┬───┬──┘
            │   │   │
            ▼   ▼   ▼
         AgentA AgentB AgentC
            │   │   │
            └───┼───┘
                ▼
             输出
```

- **分工方式**：总控 Agent 分配任务给子 Agent
- **传递机制**：总控读取子 Agent 输出，决定下一步路由
- **路由策略**：LLM 决策（灵活）/ 规则路由（确定性）/ 混合
- **适用场景**：需要动态调度的复杂任务
- **框架支持**：LangGraph Supervisor / Agent Workflow Handoff / AutoGen SelectorGroupChat
- **详见**：[[concepts/总控Agent模式]]

### 模式 3：对等对话（Peer Conversation / GroupChat）

```
Agent A ←→ Agent B ←→ Agent C
    ↕           ↕           ↕
  共享消息历史（对话空间）
```

- **分工方式**：无固定分工，Agent 根据对话上下文自主发言
- **传递机制**：共享对话历史，Agent 读取后决定是否发言
- **发言者选择**：RoundRobin（轮流）/ Selector（LLM 选择）/ 自定义
- **适用场景**：头脑风暴、多角度分析、辩论式推理
- **框架支持**：AutoGen GroupChat（首创） / Agent Framework Magentic

### 模式 4：Handoff 接力（Dynamic Transfer）

```
Agent A ──handoff──→ Agent B ──handoff──→ Agent A
                    （主动移交控制权）
```

- **分工方式**：Agent 自主决定何时将控制权交给谁
- **传递机制**：Agent 调用 handoff 工具，传递上下文 + 原因
- **适用场景**：客服系统、多技能 Agent、需要灵活路由的场景
- **框架支持**：OpenAI Swarm（首创） / Agent Framework Handoff / AutoGen Swarm

## 传递机制对比

| 维度 | Shared State（共享状态） | Message Passing（消息传递） | File Relay（文件接力） |
|------|------------------------|---------------------------|---------------------|
| **数据位置** | 全局 State 对象 | Agent 间消息队列 | 文件系统 |
| **作用域** | 同一会话内 | 同一运行时内 | 跨会话/跨工具 |
| **持久化** | Checkpoint 自动 | 需手动持久化 | Git 管理 |
| **类型安全** | 类型化 State Schema | 消息类型校验 | 约定（非强制） |
| **典型框架** | LangGraph / Agent Framework | AutoGen Runtime | [[concepts/接力机制]] |
| **适用** | 运行时协作 | 事件驱动协作 | 开发时协作 |

## 分工设计原则

1. **单一职责**：每个 Agent 只擅长一件事（参考 [[concepts/任务拆解]]）
2. **明确接口**：输入/输出格式预先约定
3. **可替代**：同角色的 Agent 可热替换（如不同 LLM 后端）
4. **失败隔离**：子 Agent 失败不影响其他 Agent
5. **人审卡点**：高风险决策点插入 Human-in-the-Loop

## 各框架多 Agent 能力对比

| 能力 | Agent Framework | AutoGen | LangGraph |
|------|----------------|---------|-----------|
| 顺序编排 | ✅ Sequential Workflow | ✅ Sequential | ✅ 线性图 |
| 总控调度 | ✅ Handoff / Magentic | ✅ SelectorGroupChat | ✅ Supervisor + Subgraph |
| 对等对话 | ✅ Magentic | ✅ GroupChat（首创） | ⚠️ 需手动实现 |
| 动态 Handoff | ✅ Handoff pattern | ✅ Swarm | ✅ Command(goto=) |
| 类型安全路由 | ✅ Edge 类型校验 | ❌ LLM 决策 | ✅ Conditional Edge |
| 持久化/恢复 | ✅ Checkpointing | ❌ 无内置 | ✅ Checkpointer |
| 分布式 | 🔜 规划中 | ⚠️ 实验性 | ❌ 单进程 |
| A2A 互操作 | ✅ 原生支持 | ❌ | ❌ |

## 与已有概念的关系

- **[[concepts/任务拆解]]**：多 Agent 协作的前提是任务已被合理拆解
- **[[concepts/总控Agent模式]]**：模式 2 的详细实现指南
- **[[concepts/接力机制]]**：解决跨会话/跨工具的 Agent 协作（文件级传递）
- **[[concepts/工作流图]]**：Agent 编排的底层图结构

## 选型建议

| 场景 | 推荐模式 | 推荐框架 |
|------|---------|---------|
| 简单多步任务 | 顺序流水线 | Agent Framework / LangGraph |
| 复杂动态任务 | 总控调度 | LangGraph / Agent Framework |
| 多视角分析 | 对等对话 | AutoGen GroupChat |
| 客服/技能路由 | Handoff 接力 | Agent Framework / Swarm |
| 跨 AI 工具协作 | 文件接力 | [[concepts/接力机制]] |

## 关联图谱

- [[concepts/任务拆解]] — 任务拆解方法论
- [[concepts/总控Agent模式]] — 总控 Agent 详细模式
- [[concepts/接力机制]] — 跨智能体接力协议
- [[concepts/工作流图]] — Agent 编排的底层图结构
