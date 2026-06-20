# Obsidian 插件配置说明

> 本文件记录 vault 需要的 Obsidian 插件及配置方式。

## 必装插件

### 1. Claudian（已装）
- 作用：把 Claude Code 嵌入 Obsidian 侧边栏，能调 Claude 的工具/skills/MCP
- 配置：已配 mimo-v2.5 模型
- 用途：在 Obsidian 内直接和 Claude 对话，整理笔记

### 2. Smart Connections（待装）
- 作用：用 RAG 自动找笔记间的语义关联，能和整个 vault 对话
- 安装：Obsidian 设置 → 第三方插件 → 浏览 → 搜索 "Smart Connections" → 安装并启用
- 配置：
  - 嵌入模型：推荐本地 BGE-M3（免费）或 OpenAI text-embedding-3-small
  - 排除目录：`00-inbox`（未整理的笔记不参与关联）
  - 自动建议：开启（编辑时自动推荐相关笔记）
- 用途：vault 的语义搜索引擎，发现笔记间隐藏联系

## 不装插件

### Copilot（不装）
- 理由：Claudian 已覆盖"在 Obsidian 里和 AI 对话"功能，且更强（能调 Claude 完整能力）
- 装 Copilot 反而冗余

## 可选插件（按需）

### Dataview（推荐装）
- 作用：用类 SQL 语法查询笔记，生成动态表格
- 用途：自动生成项目列表、待办清单、按标签聚合
- 安装：第三方插件 → 搜索 "Dataview"

### Templater（推荐装）
- 作用：比核心模板插件更强大的模板系统
- 用途：新建笔记时自动填入 frontmatter 模板
- 安装：第三方插件 → 搜索 "Templater"
- 配置：模板目录设为 `90-meta/`，引用 `frontmatter-templates.md` 的模板

### Obsidian Git（可选）
- 作用：自动备份 vault 到 Git 仓库
- 用途：vault 版本控制和远程备份
- 注意：vault 可能含敏感笔记，建议用 private repo

## 核心插件配置（Obsidian 自带）

### 文件与链接
- 新建文件位置：当前文件夹
- 链接格式：相对路径（便于跨目录引用）
- 默认视图：编辑视图

### 外观
- 主题：深色模式（减少视觉疲劳）
- 字体大小：偏大（用户偏好，减少视觉疲劳）

## vault 设置
- vault 路径：`d:\xiangmu\_kb\`
- 附件默认位置：`00-inbox/attachments/`（图片等附件统一存放）
- CLI 已开启（MCP 可用）
