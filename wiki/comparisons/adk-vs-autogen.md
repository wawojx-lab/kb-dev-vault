---
type: comparison
title: ADK vs AutoGen
source: 'Google ADK 文档 + Microsoft AutoGen 文档 + 社区调研'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [对比, 选型, agent-orchestration, 谷歌, 微软]
---

# ADK vs AutoGen

Google Agent Development Kit 与 Microsoft AutoGen 的选型对比。两者都是开源多 Agent 框架，但设计哲学和适用场景有本质差异。

## 一句话总结

| 框架 | 一句话 |
|------|--------|
| **Google ADK** | 全栈 Agent 开发框架：开发 + 工具 + 编排 + 部署一体化 |
| **AutoGen** | 多 Agent 对话框架：Agent 通过 GroupChat 协作，微软已宣布 Agent Framework 为继任者 |

## 核心差异

| 维度 | Google ADK | AutoGen |
|------|-----------|---------|
| **设计哲学** | Agent-centric（Agent 是第一公民） | Conversation-centric（对话是第一公民） |
| **编排模型** | 显式编排（Sequential / Parallel / Loop） | 隐式编排（GroupChat 发言者选择） |
| **状态管理** | Session dict + SessionService（可插拔） | 无内置持久化，依赖 conversation history |
| **工具系统** | FunctionTool + MCP + Built-in + Agent-as-Tool | FunctionTool + CodeExecutor |
| **模型绑定** | Gemini 优先，支持任意 OpenAI 兼容 API | 模型无关（OpenAI / Anthropic / Ollama） |
| **部署** | Vertex AI / Cloud Run / GKE（Google 生态） | 无内置部署方案 |
| **互操作** | A2A 协议原生支持 | 无标准互操作协议 |
| **成熟度** | 2025-04 发布，较新 | 2023 发布，社区更大 |

## 架构对比

### Google ADK

```
LlmAgent (核心)
├── tools: [FunctionTool, MCP, Built-in]
├── sub_agents: [子 Agent 列表]
└── 编排容器
    ├── SequentialAgent (A → B → C)
    ├── ParallelAgent (A ‖ B ‖ C)
    └── LoopAgent (循环执行)

SessionService → State dict（三级：Session / User / App）
```

### AutoGen

```
AssistantAgent (核心)
├── tools: [FunctionTool]
└── 编排容器
    ├── RoundRobinGroupChat (轮流)
    ├── SelectorGroupChat (LLM 选择)
    ├── Swarm (Handoff 动态)
    └── MagenticOneGroupChat (自适应)

conversation history → 无显式 state
```

## 编排模式对比

| 模式 | ADK 实现 | AutoGen 实现 |
|------|---------|-------------|
| **顺序执行** | `SequentialAgent` — 声明式子 Agent 列表 | `RoundRobinGroupChat(max_turns=N)` — 隐式轮流 |
| **并行执行** | `ParallelAgent` — 原生支持 | 无内置，需手动实现 |
| **循环执行** | `LoopAgent` — 带退出条件 | 无内置，需 `max_turns` 控制 |
| **动态路由** | LlmAgent 委派子 Agent | `SelectorGroupChat` LLM 选发言者 |
| **Handoff** | sub_agents 隐式委派 | `Swarm` + Handoff 工具 |
| **自适应** | 无内置 | `MagenticOneGroupChat`（Ledger 驱动） |

**关键差异**：ADK 的编排是**声明式的**（在 Agent 结构中显式定义），AutoGen 的编排是**对话式的**（通过 GroupChat 协议隐式涌现）。

## 工具系统对比

| 维度 | ADK | AutoGen |
|------|-----|---------|
| **函数工具** | `FunctionTool(func)` 自动推断 | `FunctionTool(func)` 自动推断 |
| **内置工具** | Google Search / Code Execution / Vertex AI Search | CodeExecutor (Docker / subprocess) |
| **MCP 支持** | ✅ 原生集成 | ❌ 无 |
| **Agent-as-Tool** | ✅ `agent.as_tool()` | ✅ `SocietyOfMindAgent` |
| **第三方桥接** | LangChain / CrewAI | OpenAI Assistant Agent |
| **Schema 推断** | docstring + type hints | docstring + type hints |

两者在函数工具层面能力相当，但 ADK 通过 MCP 支持实现了更强的**工具生态系统**。

## 状态管理对比

| 维度 | ADK | AutoGen |
|------|-----|---------|
| **状态结构** | `session.state` 字典 | 无显式状态 |
| **持久化** | `SessionService`（内存/数据库/Vertex AI） | 无内置 |
| **跨会话** | User State / App State | 需自行实现 |
| **时间旅行** | ❌ | ❌ |
| **文件级状态** | Artifacts | 无 |

**ADK 明显胜出**：Session Service 提供了生产级的状态管理，AutoGen 需要开发者自行构建。

## 部署对比

| 维度 | ADK | AutoGen |
|------|-----|---------|
| **本地开发** | `adk web` / `adk run` CLI | 直接运行 Python 脚本 |
| **云部署** | Vertex AI Agent Engine（全托管） | 无内置 |
| **容器化** | Cloud Run / GKE | 需自行容器化 |
| **可观测性** | 无内置 tracing | 无内置 |

两者都缺乏内置的可观测性平台（对比 LangGraph 有 LangSmith）。

## 开发体验对比

| 维度 | ADK | AutoGen |
|------|-----|---------|
| **上手难度** | 中等（概念多但文档好） | 低（GroupChat 直觉化） |
| **调试工具** | `adk web` 本地调试 UI | 无内置调试 UI |
| **社区规模** | 较小（2025-04 发布） | 较大（2023 发布，40k+ stars） |
| **示例数量** | 官方示例丰富 | 社区示例丰富 |
| **文档质量** | 结构化，有 Quickstart | 社区驱动，质量参差 |

## 选型建议

### 选 ADK 当

- ✅ 在 Google Cloud 生态内（Vertex AI / Gemini）
- ✅ 需要生产级状态管理和部署方案
- ✅ 需要 MCP 工具生态
- ✅ 需要声明式编排（Sequential / Parallel / Loop）
- ✅ 需要 A2A 协议互操作
- ✅ 新项目，无 AutoGen 历史包袱

### 选 AutoGen 当

- ✅ 需要成熟的社区和大量示例
- ✅ 项目以 Agent 对话协作为核心
- ✅ 需要 MagenticOne 自适应编排
- ✅ 非 Google Cloud 环境
- ⚠️ 注意：微软已宣布 Agent Framework 为继任者，新项目考虑直接用 Agent Framework

### 都不选当

- 需要图工作流 → 选 [[entities/LangGraph]]
- 需要企业级中间件 → 选 [[entities/Microsoft-Agent-Framework]]

## 未来趋势

| 趋势 | 对 ADK 的影响 | 对 AutoGen 的影响 |
|------|-------------|------------------|
| **A2A 协议普及** | 利好：原生支持，互操作优势 | 中性：需适配 |
| **MCP 工具生态** | 利好：原生集成 | 不利：无支持 |
| **多模态 Agent** | 利好：Gemini 多模态能力 | 中性：依赖外部模型 |
| **Agent Framework 崛起** | 竞争加剧 | 不利：被继任者取代 |

## 关联图谱

- [[entities/Google-ADK]] — ADK 框架详解
- [[entities/AutoGen]] — AutoGen 框架详解
- [[entities/Microsoft-Agent-Framework]] — AutoGen 的继任者
- [[concepts/Agent工具组织]] — 两框架工具组织对比
- [[concepts/Agent状态管理]] — 两框架状态管理对比
- [[concepts/总控Agent模式]] — 编排模式对比
