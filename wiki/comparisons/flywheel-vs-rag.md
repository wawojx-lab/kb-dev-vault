---
type: comparison
title: flywheel-vs-rag
subjects: [flywheel, RAG]
source: '_kb/90-meta/ frontmatter-templates.md'
status: developing
created: 2026-06-20
updated: 2026-06-20
confidence: inferred
tags: [架构, 选型, 知识库]
---

# flywheel vs RAG

传统 RAG（检索增强生成）vs flywheel（编译式知识库）的核心差异。

## 维度对比

| 维度 | RAG | flywheel |
|---|---|---|
| **核心思路** | 检索（运行时拼接） | 编译（预计算结构） |
| **输出** | 临时回答 | 结构化 wiki + DAG |
| **时间成本** | 每次查询都重算 | 一次性编译 + 增量更新 |
| **图谱** | 无（向量空间） | 有（wikilink DAG + PageRank） |
| **质量保障** | 无 | lint 11 项检查 |
| **增量更新** | 嵌入重新生成 | affected-pages 自动重算 |
| **跨会话** | 否（每次重新检索） | 是（编译产物持久） |
| **LLM 角色** | 检索 + 生成 | 编译（人类维护结构） |
| **使用场景** | 长尾查询、探索性 | 结构化知识、固定领域 |

## 关键差异
- **RAG**：Naive search engine（Naive 命名是 flywheel 的吐槽）
- **flywheel**：Compile, not retrieve（编译而非检索）

## 选型建议
- 数据频繁变 + 长尾查询 → RAG
- 数据结构化 + 高频复用 → flywheel
- 混合方案：flywheel 编译核心知识 + RAG 检索历史对话

## 关联图谱

- [[entities/flywheel]]
- [[concepts/用户偏好]]

## 关联导航

- [知识库架构调研](../synthesis/知识库架构调研.md) — 选型背景
- [OKF](../entities/OKF.md) — flywheel 使用的格式
