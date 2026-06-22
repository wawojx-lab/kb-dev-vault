---
type: entity
title: xiangmu 元工作区
source: 'd:\xiangmu\PROJECT_STATUS.md'
created: 2026-06-22
updated: 2026-06-22
confidence: stated
status: developing
tags: [project, meta, workspace, multi-agent]
---

# xiangmu 元工作区

> 多 Agent 协同的本地项目生态与知识管理工作台，统一治理规范、知识库、备份与跨项目调度。
> 权威状态源：[[d:\xiangmu\PROJECT_STATUS.md]]

## 一句话定位
整个 `d:\xiangmu` 生态的元项目，承载通用规范、Agent 适配器、知识库、备份策略与飞书总控入口。

## 技术栈
- 治理：PowerShell + Python + Markdown + Git
- Agent 层：Trae / Codex / Claude Code / OpenCode / Hermes
- 知识库：`_kb/`（OKF + flywheel 治理）
- 状态同步：`WORKLOG.md` / `CURRENT_TASK.md` / `PROJECT_STATUS.md`

## 关键组件
- `_meta/`：通用规范、适配器、脚本、模板
- `_kb/`：开发领域知识库
- `_kb_personal/`：个人领域知识库
- `zichan/`：可复用资产

## 运行状态
- 阶段：维护 + 治理机制迭代
- 下一里程碑：飞书 OpenCode 总控 P2（多 Agent 动态拆解与分派）

## 关键决策
- 2026-06-22：将 d:\xiangmu 明确定义为元项目/工作区，创建根目录接力状态文件

## 关联
- [[agent-orchestration]]
- [[multi-agent-research]]
- [[opencode中转平台]]
