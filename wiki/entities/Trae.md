---
type: entity
title: Trae
source: 'd:\xiangmu\_meta 通用规范'
status: evergreen
path: d:\xiangmu\_meta
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [AI 工具, IDE, 编程助手]
---

# Trae IDE

字节跳动推出的 AI IDE，定位"AI 协作开发环境"。

## 核心能力
- **多 Agent 切换**：可调用不同 AI 模型（MiniMax-M3 等）
- **MCP 工具链**：内置 filesystem / github / time / Excel / GitHub / Time / PPT 生成 / 飞书报告 等
- **本地服务器预览**：web 前端项目可直接预览
- **接力机制**：通过 AGENTS.md / CLAUDE.md 跨会话保持上下文

## 在本工作区的角色
- 当前会话的 AI 助手
- 与 Codex / Claude Code / Hermes 并列
- 适合本工作区的快速整理（PROMPT 模板生成、批量文件操作）

## 关联图谱

- [[entities/flywheel]] — Trae 通过文件系统 MCP 访问 _kb/

## 关联导航

- [用户偏好](../concepts/用户偏好.md) — 用户对 Trae 的偏好
- [AI 编码工具对比](../comparisons/ai-coding-tools.md) — 5 大 AI 工具对比
- [知识库架构调研](../synthesis/知识库架构调研.md) — Trae 在多智能体接力中的位置
