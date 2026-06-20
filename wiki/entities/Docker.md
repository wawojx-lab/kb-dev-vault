---
type: entity
title: Docker
source: 'd:\xiangmu\dsa-work\docker'
status: developing
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [工具, 容器, 部署]
---

# Docker

容器化平台，本工作区 dsa-work 等项目部署依赖。

## 在本工作区的应用
- `dsa-work/docker/` — Dockerfile + docker-compose
- 部署流程：本地 build → push 镜像 → 云端 run

## 关键命令
- `docker build -t name:tag .` — 构建镜像
- `docker run -d -p 8000:8000 name:tag` — 后台运行
- `docker-compose up` — 启动多容器
- `docker logs` — 查看日志

## 关联导航

- [开发流程最佳实践](../synthesis/开发流程最佳实践.md) — Docker 在部署流程的位置
