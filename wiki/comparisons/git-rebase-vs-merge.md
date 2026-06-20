---
type: comparison
title: git-rebase-vs-merge
subjects: [git rebase, git merge]
source: 'Git 官方文档'
status: evergreen
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [方法论, Git, 选型]
---

# git rebase vs git merge

两种合并分支方法的对比。

## 维度对比

| 维度 | rebase | merge |
|---|---|---|
| **历史** | 线性（clean） | 保留分支（真实） |
| **冲突** | 一次性（在 rebase 时） | 可能多次（每个 merge） |
| **回退** | 难（commit hash 改） | 易（merge commit） |
| **协作** | 适合本地 / 个人分支 | 适合共享分支 |
| **命令** | `git pull --rebase` | `git pull` |
| **风险** | 改写历史（已 push 不可 rebase） | 保留历史（安全） |

## 选型建议
- **本地 feature 分支**：用 rebase（保持线性）
- **共享 main 分支**：用 merge（保留历史）
- **PR 合并**：用 merge（保留协作痕迹）
- **个人 fix 分支**：用 rebase（避免噪音）

## 在本工作区的应用
- 接力机制下每个智能体在自己的分支 rebase
- merge 到 main 时用 --no-ff 保留痕迹

## 关联图谱

- [[entities/Git]]

## 关联导航

- [开发流程最佳实践](../synthesis/开发流程最佳实践.md) — Git 工作流选择
