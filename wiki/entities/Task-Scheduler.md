---
type: entity
title: Task-Scheduler
source: 'Windows 系统'
status: evergreen
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [工具, Windows, 周期任务]
---

# Windows Task Scheduler

Windows 系统计划任务工具，步骤 5 知识管家自动化的载体。

## 在本工作区的应用
- 计划：每天自动跑 `kb lint` + `kb stats`（步骤 5）
- 计划：每周自动跑 `kb graph-viz` + 推送到 GitHub
- 计划：每天清理 `_kb/.data/` 临时目录

## 关键操作
- `taskschd.msc` — 打开 GUI
- `Register-ScheduledTask` — PowerShell 注册任务
- XML 格式定义任务（triggers / actions / settings）

## 设计原则
- 最小频率：每天 1 次（避免性能影响）
- 失败通知：写日志不直接弹窗
- 幂等：多次跑不冲突
- 隔离：每个任务独立 .ps1 脚本

## 关联图谱

- [[concepts/渐进式开发]]

## 关联导航

- [知识库架构调研](../synthesis/知识库架构调研.md) — Task Scheduler 在自动化中的位置
