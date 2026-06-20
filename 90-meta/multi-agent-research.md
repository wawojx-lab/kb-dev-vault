# 多 Agent 框架调研协调计划

> 用 5 智能体（Trae / Codex / Claude Code / OpenCode / Hermes）并发调研 5 个 AI Agent 框架 + 本地业务实践，输出汇入 _kb/ 知识库。

## 调研框架清单（5 + 1 = 6 个）

| # | 框架 | 智能体 | 标签 | 时间预算 | 焦点 |
|---|---|---|---|---|---|
| 1 | Microsoft Agent Framework / AutoGen | Codex | @ 自动化 | 2h | 多 Agent 分工 / 协作 / 任务传递 |
| 2 | Google ADK | Claude Code | 白 个人工作台 | 2h | 工具 / 状态 / 流程组织 |
| 3 | LangGraph | OpenCode | 总控 agent | 2h | 可追踪工作流图 |
| 4 | OpenAI Agents SDK | Hermes | 排查总控仓库脏状态 | 6h | handoff / guardrail 工程化 |
| 5 | Amazon Bedrock / Strands | Trae | 建设聚合模型平台 | 13h | 企业业务系统集成 + 安全边界 |
| 6 | 本地业务实践 | 混合 | 客户/交付/文档/进度 | 2h | 真实工作流 |

## 调度策略

- **5 智能体并发**：每个 agent 在自己工作区跑
- **统一输出格式**：每个框架至少 3 个 wiki 页面（entity / concept / comparison）
- **汇入 _kb/**：所有结果以 OKF frontmatter 提交到 `_kb/wiki/`
- **时间预算合计**：27h（分摊到多天）

## 5 个任务的工作流

```
每个智能体收到 prompt
  ↓
读 _kb/90-meta/knowledge-base-conventions.md
  ↓
读 _kb/90-meta/frontmatter-templates.md
  ↓
跑调研（WebSearch / WebFetch / 官方文档）
  ↓
写 N 个 wiki 页面到 _kb/wiki/{entity|concept|comparison}/框架名.md
  ↓
跑 kb_lint 验证（0 错 0 警）
  ↓
git add + commit + push
  ↓
在 _kb\wiki\projects\ 写任务完成报告
```

## 验收标准

每个智能体任务完成需满足：

- [ ] 至少 3 个 wiki 页面（entity / concept / comparison 至少各 1）
- [ ] 全部用 OKF frontmatter（type/title/source/created/updated/confidence/tags）
- [ ] wikilink 单向无环（避免 cycle）
- [ ] 0 kb_lint 错误
- [ ] git commit + push
- [ ] 在 _kb\wiki\concepts\开发流程最佳实践.md 加新引用

## 优先级

- **P0**：任务 3（LangGraph）+ 任务 6（本地业务）— 与现有"接力机制"直接相关
- **P1**：任务 4（OpenAI Agents SDK）+ 任务 1（AutoGen）— 通用模式
- **P2**：任务 2（Google ADK）+ 任务 5（Bedrock）— 企业集成

## 时间线

- 2026-06-21：派发 6 任务
- 2026-06-22：回收 3 任务结果
- 2026-06-23：回收剩余 3 任务结果
- 2026-06-24：综合 6 任务到 synthesis/AI-Agent-Framework-Comparison

## 风险

- 智能体不一定按格式输出（需提供详细 prompt + 模板）
- 时间预算可能不够（任务 5 13h 实际可能要 2-3 天）
- wikilink 容易形成 cycle（需 lint 验证）

## 关联图谱

- [[concepts/接力机制]]
- [[concepts/任务拆解]]
- [[synthesis/开发流程最佳实践]]
- [[synthesis/任务拆解方法论]]
