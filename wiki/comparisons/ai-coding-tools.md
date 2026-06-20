---
type: comparison
title: ai-coding-tools
subjects: [Trae, Codex, Claude-Code, Hermes, OpenCode]
source: 'd:\xiangmu\信息 03-API密钥清单.md'
status: developing
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [AI 工具, 选型, 编程助手]
---

# AI 编码工具对比

用户日常使用的 5 大 AI 编码工具横向对比。

## 维度对比

| 维度 | Trae | Codex | Claude Code | Hermes | OpenCode |
|---|---|---|---|---|---|
| **厂商** | 字节跳动 | OpenAI | Anthropic | 社区 | SST |
| **核心模型** | MiniMax-M3 | GPT 系列 | Claude 系列 | 多模型切换 | 多模型切换 |
| **MCP 支持** | 强 | 中 | 强 | 中 | 中 |
| **Skills 系统** | 无（自定义） | 无 | 有 | 无 | 无 |
| **接力机制** | AGENTS.md | 无原生 | CLAUDE.md | 无 | 无 |
| **本地预览** | 有（web） | 无 | 无 | 无 | 无 |
| **批量文件** | 强 | 中 | 强 | 中 | 中 |
| **大型项目** | 中 | 强 | 强 | 中 | 中 |
| **学习曲线** | 低 | 中 | 中 | 中 | 中 |
| **成本** | 免费/订阅 | 订阅 | 订阅 | 免费/订阅 | 免费/订阅 |

## 用户使用场景
- **Trae**：日常整理、PROMPT 模板生成、批量操作
- **Codex**：跨文件 refactor、PR review
- **Claude Code**：大型项目、multi-file 任务
- **Hermes**：实验性任务、模型对比
- **OpenCode**：多模型切换场景

## 接力机制
- Trae + Claude Code 通过 `AGENTS.md` / `CLAUDE.md` 共享上下文
- Codex / Hermes / OpenCode 需手动同步
- 用户已验证 Trae + Codex + OpenCode + Hermes + Claude Code 5 智能体接力（2026-06-20）

## 关联图谱

- [[entities/Trae]]
- [[entities/Claude-Code]]

## 关联导航

- [用户偏好](../concepts/用户偏好.md) — 用户对 AI 工具的偏好
- [flywheel vs RAG](flywheel-vs-rag.md) — flywheel 与 AI 工具结合
- [知识库架构调研](../synthesis/知识库架构调研.md) — AI 工具在整体架构中的位置
