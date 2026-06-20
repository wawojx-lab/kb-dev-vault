---
type: comparison
title: sync-vs-async
subjects: [同步编程, 异步编程]
source: 'Python asyncio 文档'
status: evergreen
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [方法论, 编程范式, 选型]
---

# 同步 vs 异步编程

两种编程范式的对比。

## 维度对比

| 维度 | 同步 | 异步 |
|---|---|---|
| **I/O 等待** | 阻塞 | 非阻塞 |
| **并发** | 多线程 / 多进程 | 协程（asyncio） |
| **复杂度** | 低 | 中高 |
| **调试** | 易 | 较难 |
| **适用** | CPU 密集 / 简单 I/O | I/O 密集 / 高并发 |
| **Python 库** | requests | aiohttp / httpx |
| **Node.js 库** | sync 函数 | async/await |

## 选型建议
- **CPU 密集**（计算 / 图像处理）→ 同步 + 多进程
- **I/O 密集**（HTTP / DB / 文件）→ 异步
- **小项目** → 同步（避免过度工程）
- **高并发服务** → 异步（FastAPI / aiohttp）

## 在本工作区的应用
- `stock-sim/` 同步 + pandas
- `digital community/server` 异步（Express）
- `dsa-work/data_provider` 异步（多数据源并发）
- `tech-intelligence/api` Vercel Serverless 异步

## 关联图谱

- [[entities/flywheel]]
- [[concepts/渐进式开发]]

## 关联导航

- [开发流程最佳实践](../synthesis/开发流程最佳实践.md) — 编程范式选择
