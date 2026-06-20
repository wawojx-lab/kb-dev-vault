---
type: index
title: AI 工具链地图（2026-06-20 更新）
source: 个人整理 + flywheel 知识库
created: 2026-06-19
updated: 2026-06-20
confidence: stated
status: mature
tags: [moc, ai-toolchain]
---

# AI 工具链 MOC

> AI 工具链相关笔记的导航地图。**2026-06-20 更新**：多 Agent 框架调研 6/6 完成，知识库 54 页 185 边，远程接入 Git remote 主方案已落地

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

### wiki 核心笔记（54 页，详见 [index.md](index.md)）

**核心方法论**：[接力机制](../wiki/concepts/接力机制.md) · [任务拆解](../wiki/concepts/任务拆解.md) · [渐进式开发](../wiki/concepts/渐进式开发.md) · [DAG-思维](../wiki/concepts/DAG-思维.md) · [用户偏好](../wiki/concepts/用户偏好.md)

**AI Agent 框架调研（6/6 完成）**：[AutoGen](../wiki/entities/AutoGen.md) · [Google-ADK](../wiki/entities/Google-ADK.md) · [LangGraph](../wiki/entities/LangGraph.md) · [OpenAI-Agents-SDK](../wiki/entities/OpenAI-Agents-SDK.md) · [Amazon-Bedrock](../wiki/entities/Amazon-Bedrock.md) · [Strands](../wiki/entities/Strands.md) · [调研总报告](../wiki/summaries/multi-agent-research.md)

**知识库架构**：[知识库架构调研](../wiki/synthesis/知识库架构调研.md) · [知识库下一步调研五方向](../wiki/synthesis/知识库下一步调研五方向.md) · [知识库下一步-执行清单](../wiki/synthesis/知识库下一步-执行清单.md) · [开发流程最佳实践](../wiki/synthesis/开发流程最佳实践.md) · [任务拆解方法论](../wiki/synthesis/任务拆解方法论.md)

### 项目摘要（wiki/summaries/，4 个）

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

## 远程接入（2026-06-20 落地，详见 [remote-access.md](remote-access.md)）

- **Git remote（主方案，已落地）**：`https://github.com/wawojx-lab/kb-dev-vault`（私有仓）
  - 远程设备 `git clone` + 定期 `git pull` / `git push`
  - 15 commits 已推送，最新 commit `131789c`
- **Tailscale（备选）**：VPN 局域网，中国大陆稳定性待验证
- **Syncthing（不推荐）**：md 文件并发编辑冲突风险高

## 待补充

- [ ] flywheel LLM API Key 配置（kb compile/ingest 需要，当前 lint/stats/graph-viz 不需要）
- [x] ~~远程接入三方案对比（步骤 6）~~ → 已落地 Git remote 主方案，详见 [remote-access.md](remote-access.md)
- [x] ~~16+ 活跃子项目的 PROJECT_STATUS~~ → 35 项目全覆盖（2026-06-20 完成）
- [ ] 书籍拆解（待知识管家处理）
- [ ] 多 Agent 自动调度（Hermes cron 触发，不用手动启动每个 agent）— 复盘阶段细化
