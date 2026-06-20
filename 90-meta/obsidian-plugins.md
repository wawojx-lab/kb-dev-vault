---
type: index
title: Obsidian 插件配置（2026-06-20 调整）
source: 个人偏好 + Obsidian 社区插件市场
created: 2026-06-19
updated: 2026-06-20
confidence: stated
status: developing
tags: [meta, obsidian, plugins]
---

# Obsidian 插件配置

> **2026-06-20 调整**：放弃 obsidian MCP（其 18 工具与 kb MCP 的 27 工具大量重复），统一用 kb MCP
> Claude Code 走 CLI 模式，不在 Obsidian 侧边栏嵌入（避免 Claudian 插件）
> vault 用途：纯本地浏览/编辑，知识图谱构建/查询走 kb MCP

## 推荐插件（按必要性）

### 1. Smart Connections（必装）

- 作用：用 RAG 自动找笔记间的语义关联
- 安装：Obsidian 设置 → 第三方插件 → 浏览 → 搜索 "Smart Connections" → 安装并启用
- 配置：
  - 嵌入模型：推荐本地 BGE-M3（免费）或 OpenAI text-embedding-3-small
  - 排除目录：`raw/`（未整理的笔记不参与关联）
  - 自动建议：开启（编辑时自动推荐相关笔记）
- 用途：vault 内的语义搜索（**互补** kb MCP 的图谱搜索）
  - kb MCP：结构化 wikilink 图谱
  - Smart Connections：非结构化语义相似度

### 2. Dataview（推荐装）

- 作用：用类 SQL 语法查询笔记，生成动态表格
- 用途：自动生成项目列表、待办清单、按标签聚合
- 安装：第三方插件 → 搜索 "Dataview"

### 3. Templater（推荐装）

- 作用：比核心模板插件更强大的模板系统
- 用途：新建笔记时自动填入 frontmatter 模板
- 安装：第三方插件 → 搜索 "Templater"
- 配置：模板目录设为 `90-meta/`，引用 `frontmatter-templates.md` 的模板

### 4. Obsidian Git（推荐装）

- 作用：自动备份 vault 到 Git 仓库
- 用途：vault 版本控制和远程备份
- 远程仓库：`https://github.com/wawojx-lab/kb-dev-vault`（私有仓，gh CLI 创建）
- 注意：vault 可能含敏感笔记，**必须用 private repo**

## 不装插件

### Claudian（不装）

- 理由：用户 Claude Code 走 **CLI 模式**（命令行），不在 Obsidian 侧边栏嵌入
- 装 Claudian 反而冗余，且与全局 kb MCP 冲突

### Copilot（不装）

- 理由：Obsidian 内 AI 整理能力由 Smart Connections + kb MCP 覆盖
- Copilot 是付费且功能重复

### obsidian MCP（不装）

- 理由：obsidian MCP 的 18 工具与 kb MCP 的 27 工具大量重复
- 统一用 kb MCP（全局配置在 `~/.claude.json` 的 `mcpServers.kb`）
- 优势：kb MCP 跨 vault 工作，obsidian MCP 只能在 Obsidian 运行时用

## 核心插件配置（Obsidian 自带）

### 文件与链接
- 新建文件位置：当前文件夹
- 链接格式：相对路径（便于跨目录引用）
- 默认视图：编辑视图

### 外观
- 主题：深色模式（减少视觉疲劳，符合用户偏好）
- 字体大小：偏大（用户偏好，减少视觉疲劳，**禁用 emoji**）

## vault 设置

- vault 路径：`d:\xiangmu\_kb\`
- 附件默认位置：`raw/attachments/`（图片等附件统一存放）
- CLI 已开启：kb MCP 在 Claude Code 全局可见
- Git 远程：自动 push 到 `wawojx-lab/kb-dev-vault`
