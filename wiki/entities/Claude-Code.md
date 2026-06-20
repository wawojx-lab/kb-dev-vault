---
type: entity
title: Claude-Code
source: 'Anthropic 官方 CLI'
status: evergreen
path: n/a
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [AI 工具, 编程助手, Anthropic]
---

# Claude Code

Anthropic 官方 CLI 编程助手，强调"agentic coding workflow"。

## 核心能力
- **多文件编辑**：跨多个文件协调修改
- **Bash 工具**：直接执行 shell 命令
- **MCP 协议**：连接外部工具（filesystem、github、playwright 等）
- **Skills 系统**：自定义工作流
- **Sub-agents**：派生子任务
- **Context 自动压缩**：长会话不爆 context

## 在本工作区的角色
- 与 Trae / Codex / OpenCode / Hermes 并列
- 用户日常 5 大 AI 工具之一
- 适合大型项目（multi-file refactor）

## 关联图谱

- [[entities/flywheel]] — Claude Code 通过 MCP 集成 flywheel

## 关联导航

- [用户偏好](../concepts/用户偏好.md) — 用户对 AI 工具的偏好
- [AI 编码工具对比](../comparisons/ai-coding-tools.md) — 5 大 AI 工具对比
