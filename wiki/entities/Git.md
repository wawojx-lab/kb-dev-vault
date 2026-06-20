---
type: entity
title: Git
source: 'd:\xiangmu\.gitignore'
status: evergreen
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [工具, 版本控制, 命令行]
---

# Git

分布式版本控制系统，本工作区所有项目的版本管理基础。

## 核心命令
- `git init` — 初始化仓库
- `git add` — 暂存文件
- `git commit -m "..."` — 提交
- `git push origin main` — 推远程
- `git pull --rebase` — 拉远程 + 重放
- `git status` / `git diff` / `git log` — 查看状态

## 在本工作区的应用
- `_kb/` Git 仓 → GitHub 私有仓（wawojx-lab/kb-dev-vault）
- `d:\xiangmu\.gitignore` 130+ 行排除规则
- 每个项目独立 .git（部分项目）
- 接力机制：跨设备同步通过 git pull

## 关键决策
- 用 gh CLI 而非 mcp_GitHub（boolean 参数 bug）
- .gitignore 优先于 git rm（避免历史污染）
- git tag 标记里程碑（V1.0 / V1.2 / V1.3）

## 关联图谱

（无出边 — 作为基础工具，被 GitHub/接力机制/开发流程引用）

## 关联导航

- [开发流程最佳实践](../synthesis/开发流程最佳实践.md) — Git 在开发流程的位置
