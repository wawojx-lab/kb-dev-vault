---
type: comparison
title: Bedrock vs Azure AI Agent 对比
source: 'https://aws.amazon.com/cn/bedrock/agentcore/ + Azure AI Foundry 公开资料 + 个人整理'
created: 2026-06-20
updated: 2026-06-20
confidence: inferred
status: developing
tags: [对比, 云厂商, Bedrock, Azure-AI, 选型]
---

# Bedrock vs Azure AI Agent 平台对比

AWS Bedrock AgentCore vs Microsoft Azure AI Foundry Agent Service — 云厂商 Agent 托管服务选型参考。

## 定位差异

| 维度 | AWS Bedrock AgentCore | Azure AI Foundry |
|------|----------------------|------------------|
| 母公司 | Amazon | Microsoft |
| 模型策略 | **中立多模型**（Claude/Nova/Llama/Grok/Mistral） | **深度绑定 OpenAI**（GPT-4/o1/o3） + 部分开源 |
| 生态 | AWS 服务（S3/Lambda/DynamoDB） | M365 / Teams / Power Platform |
| 定位 | 中立 + 全模型整合 + 自研算力 | OpenAI 独家 + 微软生态闭环 |
| 发布时间 | 2024 公开预览 / 2025-2026 GA | 2024 GA / 持续迭代 |

## 核心能力对比

### 运行时（Runtime）
| 维度 | Bedrock AgentCore Runtime | Azure AI Foundry |
|------|---------------------------|------------------|
| 部署方式 | 无服务器 + 容器 | 无服务器 + 容器 |
| 异步工作负载 | 8h | 长时间支持 |
| 会话隔离 | 完整隔离 | 完整隔离 |
| 冷启动 | 秒级 | 秒级 |
| 定价 | 按活跃资源消耗 | 按 token + 计算 |

### 工具网关
| 维度 | Bedrock Gateway | Azure AI Foundry |
|------|----------------|------------------|
| 工具来源 | API / Lambda / MCP | OpenAPI / MCP / Logic Apps |
| 工具发现 | 语义搜索 | 列表 + 标签 |
| 策略拦截 | Cedar 策略（自然语言生成） | 内容安全 + 自定义过滤器 |

### 身份
| 维度 | Bedrock Identity | Azure AI Foundry |
|------|------------------|------------------|
| 用户身份 | OAuth / SAML / OIDC | Microsoft Entra ID（原 AAD） |
| 跨服务委派 | Token Exchange | Managed Identity |
| 多租户 | 完善 | 完善（M365 原生） |

### 记忆
| 维度 | Bedrock Memory | Azure AI Foundry |
|------|----------------|------------------|
| 短时记忆 | 会话内 | 会话内 |
| 长期记忆 | 持久 + 向量 | Cosmos DB + 语义记忆 |
| 跨用户共享 | 不支持（按用户隔离） | 可配置 |

### 可观测性
| 维度 | Bedrock | Azure AI Foundry |
|------|---------|------------------|
| 原生面板 | CloudWatch | Application Insights |
| 追踪标准 | OpenTelemetry | OpenTelemetry |
| 评估能力 | Evaluations（Preview） | 内置评估器 + AI Studio |

## 选型决策矩阵

### 选 Bedrock 的场景
- 业务系统**已在 AWS**（S3/Lambda/DynamoDB 大量依赖）
- 想要**多模型策略**（避免 OpenAI 绑定）
- 需要 **Grok / Claude / Llama** 等特定模型
- 团队熟悉 **IAM / VPC / CloudTrail**
- 数据合规要求**数据不出 AWS**

### 选 Azure AI Foundry 的场景
- 业务系统**深度集成 M365**（Outlook/Teams/SharePoint）
- 需要 **OpenAI 最新模型**（o1/o3 系列）
- 已有 **Entra ID（Azure AD）** 用户体系
- 走 **Power Platform 低代码** 扩展
- 微软生态 ISV / 系统集成商

### 选 GCP Vertex AI 的场景
- 业务系统**在 GCP**（BigQuery / GCS）
- 看重 **Gemini 多模态**（视频/音频）
- 谷歌生态（Workspace）

### 选自托管（Strands + vLLM）的场景
- 多云部署 / 私有化
- 严格数据合规（金融核心 / 医疗病历）
- 成本敏感（自托管 Llama 3 比 OpenAI API 便宜 5-10x）
- 已有 ML Ops 团队

## 实际案例：聚合模型平台

### 选型 1：纯 Bedrock（推荐 AWS 现有用户）
- 模型：Claude Opus 4 + Nova Pro + Llama 4
- 编排：Strands SDK → 部署到 AgentCore Runtime
- 优势：一套 IAM / 一套监控 / 一套计费
- 劣势：锁定 AWS

### 选型 2：Bedrock + Azure 双云
- 主力模型：Bedrock Claude（生产）
- 实验模型：Azure OpenAI o1（推理）
- 编排：LangGraph（云中立）
- 优势：模型风险分散
- 劣势：双套安全配置 / 双套账单

### 选型 3：自托管优先
- 模型：自托管 Llama 4 + Qwen 3（私有 IDC GPU 集群）
- 编排：Strands + LangGraph
- 调用外部模型：仅做 A/B 对比，不走生产
- 优势：完全可控 / 数据不出域
- 劣势：算力成本 + 运维负担

## 价格对比（粗略估算，2026-06）

| 场景 | Bedrock | Azure AI Foundry |
|------|---------|------------------|
| Claude Sonnet 4 输入 | $3/M tokens | 同（OpenAI 同价位） |
| Claude Sonnet 4 输出 | $15/M tokens | 同 |
| GPT-4o 输入 | N/A | $5/M tokens |
| Llama 4 70B | $0.99/M tokens | 略高 |
| Nova Micro | $0.035/M tokens | N/A |

## 总结建议

> **如果团队已有云生态绑定** → 选对应云（AWS 选 Bedrock，Azure 选 Foundry）
> **如果从零开始** → 推荐 Bedrock（多模型中立 + Claude 顶级 + AgentCore 完整）
> **如果多云 / 私有化** → Strands SDK + 自建网关 + 多模型路由层

## 关联图谱

- [[entities/Amazon-Bedrock]]
- [[entities/Strands]]
- [[concepts/企业Agent集成]]
- [[concepts/安全边界模式]]
- [[summaries/建设聚合模型平台]]

## 参考资料
- [Bedrock AgentCore 定价](https://aws.amazon.com/cn/bedrock/agentcore/pricing/)
- [Azure AI Foundry 定价](https://azure.microsoft.com/en-us/pricing/details/ai-foundry/)
- [2026 云厂商 AI 能力对比（今日头条）](http://m.toutiao.com/group/7652461143587291683/)
