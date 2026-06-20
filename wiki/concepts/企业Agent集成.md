---
type: concept
title: 企业Agent集成
source: 'https://aws.amazon.com/cn/bedrock/agentcore/ + 个人整理'
created: 2026-06-20
updated: 2026-06-20
confidence: inferred
status: developing
tags: [方法论, 企业, Agent, 集成模式]
---

# 企业 Agent 集成模式（Enterprise Agent Integration Patterns）

把 AI Agent 接入企业现有业务系统（ERP/CRM/数据库/内部 API）的标准化模式分类。源自 AWS Bedrock AgentCore 设计 + LangGraph / Strands 实践总结。

## 四层集成模型

```
┌──────────────────────────────────────────┐
│ L1: 业务系统层（System of Record）         │
│   - SAP / Salesforce / 自研 ERP            │
│   - PostgreSQL / Oracle / 数据湖           │
├──────────────────────────────────────────┤
│ L2: 工具网关层（Tool Gateway）             │
│   - AgentCore Gateway / MCP Server        │
│   - API 包装 + 语义检索                    │
├──────────────────────────────────────────┤
│ L3: 编排层（Orchestration）               │
│   - Supervisor Agent / LangGraph / Strands │
│   - 决定"调用哪个工具 / 顺序"              │
├──────────────────────────────────────────┤
│ L4: 模型层（Model）                       │
│   - Claude / GPT / Nova / Llama            │
│   - 自托管 vLLM / Ollama                   │
└──────────────────────────────────────────┘
```

## 5 种典型集成模式

### 模式 1：API 直连（最简单）
Agent 直接调用业务系统 REST API。
- 适用：查询类只读操作
- 风险：写操作需额外鉴权层
- 工具示例：Strands `@tool` 包装 `requests.get/post`

### 模式 2：MCP 网关（推荐生产用）
把内部 API 包装成 MCP Server，Agent 通过统一协议访问。
- 优势：工具发现、权限隔离、审计统一
- 实施：AgentCore Gateway / 自建 MCP Server
- 适用：多 Agent 共享工具集

### 模式 3：事件驱动（异步长任务）
Agent 触发 → 业务系统执行 → 结果回传 Agent。
- 工具：SQS / EventBridge / Kafka
- 适用：批量处理、长时间工作流（AgentCore Runtime 支持 8h 异步）
- 案例：营销活动自动化（Cox Automotive / Epsilon）

### 模式 4：数据底座接入（RAG）
Agent 通过向量检索查询企业知识库。
- 工具：Kendra / OpenSearch / S3 Vectors / Pinecone
- 适用：客服助手、文档问答、合同审查

### 模式 5：身份委派（用户身份而非系统身份）
Agent 代表"用户"访问系统，权限继承用户。
- 实现：AgentCore Identity / OAuth 2.0 Token Exchange
- 适用：邮件发送、文件操作（需用户本人权限）
- 案例：用户让 Agent 帮忙发邮件 → 用用户 OAuth Token 调 Gmail API

## 关键设计原则

### 1. 工具粒度适中
- **太粗**（一个工具 = 整个 ERP）：模型无法推理
- **太细**（每个字段一个工具）：组合爆炸
- **推荐**：业务动词粒度（"创建订单" / "查询库存" / "审批发票"）

### 2. 错误处理前置
- 工具返回结构化错误（不是堆栈）
- Agent 根据错误码决定重试 / 降级 / 询问用户

### 3. 幂等性保证
- 写操作工具必须支持 Idempotency-Key
- 避免 Agent 重试产生重复订单

### 4. 审计日志完整
- 谁（User / Agent）
- 何时（timestamp）
- 调了什么（tool name + 参数）
- 结果（成功 / 失败 / 返回值 hash）
- 用于：合规 / 调试 / 计费

## 与传统 ESB / API Gateway 区别

| 维度 | 传统 ESB | Agent 网关 |
|------|----------|-----------|
| 调用方 | 微服务 | LLM Agent |
| 协议 | SOAP/REST | REST + MCP |
| 路由 | 静态配置 | 语义搜索发现 |
| 鉴权 | JWT/API Key | 用户委派 OAuth |
| 错误处理 | HTTP 状态码 | 自然语言 + 错误码 |

## 选型决策树

```
企业主要业务系统在哪个云？
├── AWS → Bedrock AgentCore（首选）
├── Azure → Azure AI Foundry + MCP
├── GCP → Vertex AI Agent Engine
└── 多云 / 私有 → Strands SDK + 自建网关
```

## 实施陷阱

- **直接让 Agent 调生产 DB**：永远不要，给 Agent 走 API 层
- **Prompt 写权限规则**：必须 Gateway 层强制，Prompt 可绕过
- **忽略工具版本**：业务系统升级，工具签名要同步
- **缺少 dry-run 模式**：生产前需沙盒演练

## 关联图谱

- [[entities/Amazon-Bedrock]]
- [[entities/Strands]]
- [[concepts/安全边界模式]]
- [[concepts/工作流图]]
- [[comparisons/bedrock-vs-azure-ai]]
- [[summaries/建设聚合模型平台]]

## 参考资料
- [Amazon Bedrock AgentCore Gateway](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/gateway.html)
- [AgentCore Identity 用户委派](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/identity.html)
