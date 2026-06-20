---
type: entity
title: Strands Agents
source: 'https://strandsagents.com/latest/ + https://www.51cto.com/article/816247.html + https://github.com/strands-agents/strands-agents'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [AWS, 开源, Agent-SDK, Python, 模型驱动]
---

# Strands Agents（AWS 开源模型驱动 Agent SDK）

AWS 2025 年开源的 AI Agent 开发框架，核心理念：**"模型驱动" + 几行代码构建生产级 Agent**。已在 AWS 内部多个核心团队投入生产。

## 核心定位

> "A model-driven approach to building AI agents in just a few lines of code."

与 LangGraph（图形编排）形成对比：Strands 强调**让模型自己推理决定调用链**，开发者只需定义：
- 模型（Bedrock / Anthropic / OpenAI / Ollama 自托管）
- 工具（@tool 装饰器声明的 Python 函数）
- 系统提示词

## 架构特点

### 1. 模型驱动 vs 图形驱动
| 维度 | Strands | LangGraph |
|------|---------|-----------|
| 控制流 | 模型推理决定 | 开发者画 DAG 显式控制 |
| 代码量 | 几行 | 几十到几百行 |
| 灵活性 | 高（模型自主） | 中（受图结构约束） |
| 调试 | 较难（黑盒推理） | 容易（图可视化） |
| 适用 | 通用 Agent | 复杂多步流水线 |

### 2. 多模型支持
- **托管模型**：Bedrock（Claude / Nova / Llama / Mistral / Cohere）
- **第三方 API**：OpenAI、Anthropic 直连
- **自托管**：Ollama、vLLM、本地 HuggingFace
- **统一接口**：`BedrockModel` / `AnthropicModel` / `OllamaModel` 可插拔

### 3. 工具系统
- **@tool 装饰器**：Python 函数即工具
- **MCP 集成**：直接接入 Model Context Protocol 服务器
- **工具分类**：内置常用工具（calculator / file_read / http_request / shell 等）

### 4. 行为控制（Steering 机制）
两个核心钩子解决"Prompt 写了 2000 字还是翻车"：
- **steer_before_tool**：工具调用前检查，拦截/重定向
- **steer_after_tool**：工具调用后校验结果
- 相比单纯依赖 Prompt，Steering 把控制从"软提示"升级为"硬拦截"

## 最小示例
```python
from strands import Agent
from strands_tools import calculator

agent = Agent(
    model="anthropic.claude-sonnet-4-20250514",
    tools=[calculator],
    system_prompt="你是财务计算助手"
)
response = agent("100万的8%年化收益5年后是多少？")
```

## 部署路径

```
本地开发（Strands SDK）
    ↓
打包成 Docker / ZIP
    ↓
部署到 AgentCore Runtime（AWS 生产托管）
    ↓
或部署到任意云（自托管模型 + Strands）
```

## 优势
- **AWS 内部验证**：CodeDeploy、AWS Labs、Quick Suite 都在用
- **多模型中立**：不绑定 Bedrock，避免供应商锁定
- **Python 优先**：对数据科学家友好
- **MCP 原生**：与 MCP 生态兼容

## 劣势
- **Python-only**（无 JS/Go SDK 官方支持）
- **Steering 行为研究较新**（2026 Q1 才出评估论文）
- **生态比 LangGraph 小**：社区贡献工具少
- **复杂工作流不如 LangGraph 可视化调试**

## 适用场景
- **快速原型**：几天内跑通 Agent
- **多模型实验**：GPT-4 / Claude / Llama 切换对比
- **MCP 生态集成**：接 Claude Desktop / Cursor 等
- **避免锁定**：本地开发 + 任意云部署

## 与 Bedrock 关系
- **Strands = SDK 层**（开发者写代码用）
- **AgentCore Runtime = 部署层**（生产环境跑用）
- 二者**正交**：Strands 应用可上 AgentCore；非 Strands Agent 也可上 AgentCore

## 关联图谱

- [[entities/Amazon-Bedrock]]
- [[entities/LangGraph]]
- [[concepts/企业Agent集成]]
- [[comparisons/bedrock-vs-azure-ai]]
- [[summaries/建设聚合模型平台]]

## 参考资料
- [Strands Agents 官网](https://strandsagents.com/latest/)
- [Strands GitHub](https://github.com/strands-agents/strands-agents)
- [AWS 开源 Strands 介绍（51CTO）](https://www.51cto.com/article/816247.html)
- [Steering 行为控制评估（CSDN）](https://blog.csdn.net/rralucard123/article/details/159390638)
