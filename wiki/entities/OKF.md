---
type: entity
title: OKF
source: 'Google 2026-06-16 发布的标准'
status: evergreen
path: n/a
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [标准, 知识图谱, Markdown]
---

# OKF (Open Knowledge Format)

Google 2026-06-16 发布的开放知识图谱标准：Markdown + YAML frontmatter。

## 核心要素
- **载体**：Markdown（人类可读）
- **元数据**：YAML frontmatter（机器可解析）
- **必填字段**：
  - `title`：笔记标题
  - `type`：笔记类型（封闭词汇）
  - `created` / `updated`：日期
  - `source`：来源追溯
  - `confidence`：可信度（stated/inferred/speculative）

## 与 flywheel 关系
- flywheel 是 OKF 标准的"超集"实现
- flywheel 强制 5 个封闭 type 词汇（entity/concept/comparison/summary/synthesis）
- OKF v0.1 本身 type 开放，flywheel 选择封闭以保证图谱结构

## 关联图谱

- [[entities/flywheel]] — 飞轮是 OKF 的超集实现

## 关联导航

- [知识库架构调研](../synthesis/知识库架构调研.md) — OKF 在整体架构中的位置
- [用户偏好](../concepts/用户偏好.md) — 用户对知识图谱的偏好
