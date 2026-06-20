---
type: entity
title: flywheel
source: 'pyproject.toml @ d:\xiangmu\_kb_flywheel'
status: evergreen
path: d:\xiangmu\_kb_flywheel
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [工具链, 知识库, 编译引擎]
---

# flywheel (llm-wiki-flywheel)

LLM 维护的知识库编译引擎（v0.12.0），把 raw sources 编译成结构化、互联的 markdown wiki。

## 核心功能
- **compile**：从 raw/ 编译到 wiki/（frontmatter + wikilink + DAG）
- **lint**：检查 dead_links / orphan_pages / cycles / frontmatter 等
- **stats / graph-viz**：DAG 统计 + Mermaid 可视化
- **query / search / read-page**：BM25 + 向量混合检索
- **ingest**：原始内容到 raw/ + 自动编译
- **evolve**：自动建议新连接 + 缺失来源
- **publish**：导出 llms.txt / llms-full.txt

## 封闭 type 词汇（5 个）
- `entity`（具体实体：人/项目/工具/平台）
- `concept`（抽象概念：方法/原则/规律）
- `comparison`（多者对比：选型 A vs B）
- `summary`（项目级总结）
- `synthesis`（多源综合的洞察）

## 关键设计
- `KB_PROJECT_ROOT` 环境变量必须设到 _kb 根目录
- `kb stats` 必须传 `--wiki-dir`（flywheel bug）
- YAML source 字段含 Windows 路径必须单引号
- type 必须匹配子目录名（5 词汇封闭）

## 关联图谱（单向无环）

（无出边 — 作为 root 引擎，被 OKF/Claude-Code/Trae/comparisons 引用）

## 关联导航

- [知识库架构调研](../synthesis/知识库架构调研.md) — flywheel 在整体架构中的位置
- [OKF](OKF.md) — flywheel 使用的格式标准
