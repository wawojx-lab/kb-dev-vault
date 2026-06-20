---
type: entity
title: GitHub
source: 'd:\xiangmu\_kb\.git\config'
status: evergreen
path: https://github.com/wawojx-lab/kb-dev-vault
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [平台, 远程仓库, 协作]
---

# GitHub

代码托管平台，本工作区 _kb/ 知识库远程仓库所在地。

## 远程仓库
- `wawojx-lab/kb-dev-vault`（私有，_kb/ 同步）

## 关键工具
- `gh repo create` — 创建仓（绕过 mcp_GitHub boolean bug）
- `gh repo view` — 查看仓
- `gh issue` — issue 管理
- `gh pr` — PR 管理

## 与 mcp_GitHub 关系
- mcp_GitHub：Trae MCP 工具（多数可用，create_repository 不可用）
- gh CLI：兜底（用于 create_repository）

## 关联图谱

（无出边 — 作为平台，被 GitHub-Actions 引用）

## 关联导航

- [开发流程最佳实践](../synthesis/开发流程最佳实践.md) — GitHub 在开发流程的位置
