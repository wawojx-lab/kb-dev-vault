---
type: concept
title: DAG-思维
source: 'flywheel wikilink DAG 设计'
status: developing
created: 2026-06-20
updated: 2026-06-20
confidence: inferred
tags: [方法论, 图论, 知识图谱]
---

# DAG 思维（DAG Thinking）

用有向无环图（DAG）表达任务依赖、知识关联、流程的思维方法。

## 核心要素
- **节点**：实体（任务 / 概念 / 实体 / 项目）
- **有向边**：依赖或引用关系
- **无环**：避免循环依赖（否则死锁 / 编译失败 / 知识混乱）
- **拓扑序**：按依赖排序，可并行识别
- **入度 / 出度**：节点的依赖 / 被依赖

## 应用场景
- **任务管理**：当前任务依赖前 3 步
- **知识图谱**：summaries 引用 synthesis（不反向）
- **CI/CD**：构建依赖图
- **数据流**：数据处理管道

## 关键技巧
- **单向引用**：从底层 → 高层（无反向）
- **入度有限**：节点入度最好 < 10（避免高耦合）
- **出度有限**：节点出度 < 5（避免过载）
- **汇聚节点**：执行清单型节点出度 = 0

## flywheel 中的应用
- 14 个 wiki 页面 + 23 条有向边
- 0 cycle 0 orphan（健康）
- 拓扑序：concepts → entities → comparisons → summaries → synthesis

## 关联图谱

- [[entities/flywheel]]
- [[concepts/任务拆解]]

## 关联导航

- [知识库架构调研](../synthesis/知识库架构调研.md) — DAG 在 flywheel 中的应用
- [开发流程最佳实践](../synthesis/开发流程最佳实践.md) — DAG 思维在开发中的位置
