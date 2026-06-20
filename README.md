# 知识库（开发域 Vault）

> 本 vault 是所有智能体的共享知识大脑（开发域）。
> 采用 OKF（Open Knowledge Format）格式 + flywheel 编译架构。
> 与个人域 `_kb_personal/` 物理隔离。

## 目录结构（三层架构 + flywheel 兼容）

| 目录         | 用途                                                     | 写入权限           |
| ---------- | ------------------------------------------------------ | -------------- |
| `raw/`     | 人类策展源（原始资料、笔记、截图、会议记录）                                 | 所有智能体可写        |
| `wiki/`    | LLM 编译产物（OKF 格式，5 type 子目录）                            | 所有智能体可写，知识管家治理 |
| `90-meta/` | vault 元信息（index / frontmatter 模板 / Obsidian 配置 / 整理日志） | 所有智能体可写        |
|            |                                                        |                |

### wiki/ 的 5 个 type 子目录（flywheel 约定）

| 子目录 | type | 用途 |
|--------|------|------|
| `wiki/entities/` | entity | 实体（人物/公司/产品/工具） |
| `wiki/concepts/` | concept | 抽象概念（方法/指标/理论） |
| `wiki/comparisons/` | comparison | 对比（X vs Y 选型/优劣） |
| `wiki/summaries/` | summary | 摘要（单源提炼的项目/文章/书） |
| `wiki/synthesis/` | synthesis | 综合（多源合成的调研/全景） |

> **子目录名 = type**。flywheel `WIKI_SUBDIR_TO_TYPE`（`config.py:597-603`）写死这个映射。
> frontmatter 的 `type` 字段是元数据，**不参与** flywheel 的 type 推断。

## 写入规则（核心变更）

### 规则 1：所有智能体可写入（取消单点写入限制）
- **所有智能体**（Trae/Codex/OpenCode/Hermes/Claude Code）均可写入 `raw/`、`wiki/{type}/`、`90-meta/`
- 知识管家（Claude Code + flywheel）负责**治理**：lint 检查格式、compile 编译、evolve 演进
- 用户可在 Obsidian 中直接编辑任意文件
- 写入 wiki/ 时按 type 选子目录；不确定 type 时默认 `wiki/summaries/`（最宽松）

### 规则 2：OKF 格式（Open Knowledge Format）
所有 wiki/ 文件遵循 OKF v0.1 规范：
```yaml
---
type: table | dataset | metric | api | concept | project | area | resource
title: [标题]
tags: [标签列表]
timestamp: YYYY-MM-DDTHH:MM:SSZ
---

# [正文，Markdown 自由格式]

链接用普通 Markdown：[相关概念](/path/to/other.md)
```
- `type` 是唯一强制字段
- 概念之间用 Markdown 链接互相引用，形成知识图谱
- 详见 https://github.com/GoogleCloudPlatform/knowledge-catalog/tree/main/okf

### 规则 3：代码不进 vault
- 代码、配置、依赖目录永远不进 vault
- vault 只放知识笔记、结论、方法论、索引

### 规则 4：敏感信息不入库
- 密钥、密码、token 不入库，只记位置
- 个人私有内容放 `_kb_personal/`，不放本 vault

## 各层职责

### raw/（人类策展源）
- 原始资料：会议记录、截图、外部文章摘录、灵感笔记
- 格式宽松：可无 frontmatter，知识管家会定期编译到 wiki/
- 命名：`YYYY-MM-DD-[简述].md` 或自由命名

### wiki/（LLM 编译产物）
- 知识管家用 flywheel 从 raw/ 编译产出的结构化知识
- 严格 OKF 格式
- **必须按 type 归类到 5 个子目录之一**（entity/concept/comparison/summary/synthesis）
- 概念之间用 wikilink `[[xxx]]` 互引（flywheel 用 wikilink 建图谱边，普通 Markdown 链接建不了边）
- 知识管家定期 lint 检查格式一致性

### 90-meta/（vault 元信息）
- `index.md` — 知识库总索引（按 type 列出所有 wiki 笔记）
- `frontmatter-templates.md` — 各类笔记的 frontmatter 模板
- `obsidian-plugins.md` — Obsidian 插件配置
- `km-agent-workflow.md` — 知识管家整理/拆解/同步流程
- `vault-changelog.md` — 知识管家整理操作记录

## 治理规则（知识管家执行）

### 日常治理（flywheel）
- `kb ingest`：从 raw/ 摄取新资料
- `kb compile`：编译 raw/ → wiki/
- `kb lint`：检查 wiki/ 格式一致性
- `kb query`：知识检索
- `kb evolve`：知识演进（更新过期内容）

### 大规模重构（Dynamic Workflows）
- 多 agent 并行读源、交叉验证、合成 wiki
- 适合：知识库迁移、全库审计、主题重构
- 不占主上下文（中间结果在脚本变量流转）

## 清理规则
- raw/ 超过 6 个月且已编译到 wiki/ 的，评估归档
- wiki/ 超过 1 年未更新的，标记"待复核"
- 详细清理规则见 `d:\xiangmu\_meta\rules\cleanup.md`

## 与项目的关系
- `wiki/summaries/[项目名].md` 存项目摘要，指向项目 PROJECT_STATUS.md
- 项目代码在 `d:\xiangmu\[项目名]/`
- 项目知识笔记（设计思路、决策记录）放 `wiki/concepts/` 或 `wiki/synthesis/`

## 智能体访问方式
- MCP（主力）：通过 obsidian-mcp-server 访问（所有智能体可读写）
- 文件系统（兜底）：任何智能体可直接读写 `d:\xiangmu\_kb\*.md`
- flywheel MCP（知识管家专用）：28 个知识编译工具

## 与个人域的隔离
- 本 vault（`_kb/`）：开发域，所有智能体可访问
- 个人域（`_kb_personal/`）：仅 Hermes/Trae/Claude Code 可访问
- 两个 vault 物理隔离，MCP 权限分开配置
