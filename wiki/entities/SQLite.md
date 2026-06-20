---
type: entity
title: SQLite
source: 'd:\xiangmu\lianghua\trading.db'
status: evergreen
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [工具, 数据库, 嵌入式]
---

# SQLite

嵌入式关系数据库，本工作区多个项目使用（lianghua / computer use / jizhang 等）。

## 关键特性
- 零配置：单文件数据库
- ACID：完整事务支持
- 跨平台：Windows / macOS / Linux
- 性能：小数据量极快（< 1 GB）

## 在本工作区的应用
- `lianghua/trading.db` — 交易数据
- `computer use/orchestrator/state.db` — orchestrator 状态
- `jizhang/` 记账数据
- 35+ 项目中使用

## 决策建议
- 数据 < 1 GB + 单机 + 低并发 → SQLite（推荐）
- 数据 > 10 GB + 多人 + 高并发 → PostgreSQL

## 关联图谱

- [[entities/Docker]]

## 关联导航

- [开发流程最佳实践](../synthesis/开发流程最佳实践.md) — SQLite 在开发流程的位置
