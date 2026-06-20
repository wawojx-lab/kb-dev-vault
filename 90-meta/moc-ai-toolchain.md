---
type: index
title: AI 工具链地图（2026-06-20 更新）
source: 个人整理 + flywheel 知识库
created: 2026-06-19
updated: 2026-06-20
confidence: stated
status: developing
tags: [moc, ai-toolchain]
---

# AI 工具链 MOC

> AI 工具链相关笔记的导航地图。**2026-06-20 更新**：合并旧 4 层架构为 3 层，统一用 kb MCP 替代 obsidian MCP

## 智能体（5 个，均可写入 vault）

- [Codex](file:///d:/xiangmu/_meta/adapters/codex.md) — OpenAI CLI
- [Claude Code](file:///d:/xiangmu/_meta/adapters/claude-code.md) — Anthropic CLI
- [Trae](file:///d:/xiangmu/_meta/adapters/trae.md) — ByteDance IDE
- [OpenCode](file:///d:/xiangmu/_meta/adapters/opencode.md) — 开源 CLI
- [Hermes](file:///d:/xiangmu/_meta/adapters/hermes.md) — 调度/定时

## 规范体系（_meta/）

- [通用规范源](file:///d:/xiangmu/_meta/AGENTS.md) — `_meta/AGENTS.md`
- [接力机制](file:///d:/xiangmu/_meta/rules/relay.md) — WORKLOG + CURRENT_TASK + PROJECT_STATUS 三件套
- [项目状态管理](file:///d:/xiangmu/_meta/rules/project-status.md) — 状态档案规范
- [项目初始化](file:///d:/xiangmu/_meta/rules/project-init.md) — 新项目 AGENTS.md 流程
- [清理规范](file:///d:/xiangmu/_meta/rules/cleanup.md) — .gitignore + 滚动归档
- [Git 规范](file:///d:/xiangmu/_meta/rules/git.md) — 提交格式 + 安全规则

## 知识库（vault）

### 架构（3 层 + flywheel 5 type）

```
_kb/
├── raw/                # 人类策展源（所有智能体可写）
├── wiki/               # LLM 编译产物（flywheel 5 type 子目录）
│   ├── entities/       # 实体
│   ├── concepts/       # 概念
│   ├── comparisons/    # 对比
│   ├── summaries/      # 摘要
│   └── synthesis/      # 综合
└── 90-meta/            # vault 元信息（本目录）
```

### 元笔记（90-meta/）

- [vault 总说明](../README.md) — 目录结构 + 写入规则（OKF 格式）
- [总索引](index.md) — vault 笔记索引
- [知识管家流程](km-agent-workflow.md) — 整理/拆解/同步
- [Frontmatter 模板](frontmatter-templates.md) — 各类笔记 frontmatter
- [Obsidian 插件配置](obsidian-plugins.md) — Smart Connections + kb MCP

### wiki 核心笔记

- [用户偏好](../wiki/concepts/用户偏好.md) — 沟通/UI/工作流偏好（账号切换兜底）
- [知识库架构调研](../wiki/synthesis/知识库架构调研.md) — OKF + Dynamic Workflows + flywheel
- [知识库下一步调研五方向](../wiki/synthesis/知识库下一步调研五方向.md) — 5 方向决策
- [知识库下一步-执行清单](../wiki/synthesis/知识库下一步-执行清单.md) — 5 方向执行计划

### 项目摘要（wiki/summaries/）

- [stock-sim](../wiki/summaries/stock-sim.md) — 股票策略模拟系统
- [TradingAgents](../wiki/summaries/TradingAgents.md) — 多智能体交易系统
- [SuanJia](../wiki/summaries/SuanJia.md) — 飞书 AI 虚拟公司
- [3D](../wiki/summaries/3D.md) — SketchUp 建模项目

## MCP 工具链（2026-06-20 调整）

### 核心 MCP（全局配置）

| MCP | 工具数 | 用途 |
|-----|--------|------|
| kb | 27 | 知识库（lint/stats/graph-viz/compile/ingest/query/...）|
| obsidian | 18 | Obsidian 内部（**已被 kb 替代**）|
| filesystem | — | 文件读写 |
| mcp_Time | — | 时间/时区 |
| mcp_Excel | 7 | Excel 操作 |
| mcp_GitHub | 17 | GitHub 仓库/Issue/PR |
| mcp_blender | — | 3D 建模 |
| agent-reach | — | 网页抓取 |

### 配置位置

- **全局**：`C:\Users\65128\.claude.json`（`mcpServers` 节点）
- **Trae 端**：待接入（参考 _meta/adapters/trae.md）

## flywheel 工具

详见 [km-agent-workflow.md](km-agent-workflow.md) 的"flywheel 工具调用约定"段。

## 远程接入（待办，见步骤 6）

- Tailscale（VPN 局域网）
- Syncthing（点对点文件同步）
- Git remote（**当前用**，kb-dev-vault 私有仓）

## 待补充

- [ ] flywheel LLM API Key 配置（kb compile/ingest 需要）
- [ ] 远程接入三方案对比（步骤 6）
- [ ] 16+ 活跃子项目的 PROJECT_STATUS（用通用 Codex 提示词）
- [ ] 书籍拆解（待知识管家处理）
