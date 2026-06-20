---
type: entity
title: Amazon Bedrock
source: 'https://aws.amazon.com/cn/bedrock/agents/ + https://aws.amazon.com/cn/bedrock/agentcore/'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [云服务, AWS, AI-Agent, 基础模型, 企业]
---

# Amazon Bedrock（亚马逊云科技一站式生成式 AI 平台）

AWS 提供的企业级生成式 AI 平台，统一接入多家基础模型（FM）并配套 Agent 构建/部署/监控托管服务。

## 核心组成（2026-06 现状）

### 1. Bedrock Agents（应用层）
无服务器化代理服务，开发者用自然语言指令定义代理角色，自动完成：
- **多步任务分解**：FM 推理 + API 调用编排
- **检索增强生成（RAG）**：连接企业知识库（Kendra / OpenSearch / S3 Vectors）
- **记忆保留**：会话级 + 跨会话记忆，提升多轮准确度
- **代码解释**：沙盒内安全执行 Python
- **多代理协作**：Supervisor Agent 协调多个专业 Agent

### 2. Bedrock AgentCore（运行时层，2026 GA）
Bedrock Agents 的"工业级"生产化平台，**框架无关 + 模型无关**：

| 服务 | 作用 |
|------|------|
| **Runtime** | 无服务器代理部署，8h 异步工作负载，会话完全隔离 |
| **Gateway** | API/Lambda → Agent Tool；支持 MCP 服务器；语义搜索发现工具 |
| **Policy (Preview)** | Cedar 策略语言实时拦截工具调用，事前合规 |
| **Memory** | 持久 + 短时记忆，行业领先准确度 |
| **Identity** | 代理身份 + 用户身份委派，跨 IdP 联邦 |
| **Evaluations** | 实时采样 + 自定义评估器，准确性/安全性/目标达成率 |
| **Observability** | CloudWatch 面板 + OpenTelemetry 导出 |
| **Code Interpreter** | 多语言沙盒代码执行 |
| **Browser** | 无服务器浏览器运行时，零到数百会话自动伸缩 |

## 支持的基础模型
- **Anthropic**：Claude Opus 4 / Sonnet 4 / Haiku
- **Amazon**：Nova Pro / Lite / Micro / Premier
- **Meta**：Llama 4 系列
- **Mistral / AI21 / Cohere**
- **xAI**：Grok 4.3（2026-06-17 GA）
- **Stability AI** 图像模型

## 企业级安全特性
- **IAM 原生集成**：细粒度权限控制（Agent → Tool → Data）
- **VPC 连接 + PrivateLink**：流量不出 AWS 内网
- **完全会话隔离**：防止数据泄露
- **CloudTrail 审计**：所有 API 调用可追溯
- **AWS Marketplace 集成**：预构建 Agent + Tool 部署

## 典型客户案例
- **Ericsson**：3G/4G/5G/6G 系统研发，AgentCore 用于代码融合
- **Thomson Reuters**：内容工作流代理化，周期从月压缩到周
- **Cox Automotive**：经销商虚拟助手 + 代理式市场
- **Amazon Devices**：制造流程代理，模型微调从天压缩到 1 小时

## 适用场景
- 企业已有 AWS 生态（S3 / Lambda / DynamoDB / IAM）→ 直接接
- 需要联邦身份（Okta / Azure AD）→ Identity 服务
- 多模型策略（避免供应商锁定）→ Bedrock 一站式接入
- 严格合规（金融/医疗）→ VPC + KMS + CloudTrail 完整审计链

## 与 Strands 关系
- **Bedrock Agents / AgentCore** = 托管云服务（AWS 账号内运行）
- **Strands SDK** = 开源 SDK，本地/任意云部署
- 两者**互补不替代**：Strands 应用可直接部署到 AgentCore Runtime

## 关联图谱

- [[entities/Strands]]
- [[entities/Claude-Code]]
- [[summaries/建设聚合模型平台]]

## 参考资料
- [Amazon Bedrock Agents 官方页](https://aws.amazon.com/cn/bedrock/agents/)
- [Amazon Bedrock AgentCore 官方页](https://aws.amazon.com/cn/bedrock/agentcore/)
- [AgentCore Developer Guide](https://docs.aws.amazon.com/bedrock-agentcore/latest/devguide/what-is-bedrock-agentcore.html)
- [AgentCore 代码示例](https://github.com/awslabs/amazon-bedrock-agentcore-samples/)
