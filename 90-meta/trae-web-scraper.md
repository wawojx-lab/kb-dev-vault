---
type: index
title: Trae 网络抓取专员模式
source: P2-4 改进项 + 多 agent 网络能力不对称实测（2026-06-20）
created: 2026-06-21
updated: 2026-06-21
confidence: high
status: mature
tags: [meta, trae, web-scraping, multi-agent, relay, network]
---

# Trae 网络抓取专员模式

> 固化 Trae 作为多 agent 网络抓取专员的工作流。
> 关联改进项：P2-4（Trae 网络抓取专员模式固化）
> 关联问题：C4（agent 网络能力不对称）/ L4（网络抓取无标准流程）
> 实测依据：2026-06-20 multi-agent-research 验证（见 project_memory）

---

## 1. 背景与问题

### 1.1 多 agent 网络能力不对称

| Agent | 网络能力 | 原因 |
|-------|----------|------|
| **Trae** | ✅ 完整（WebSearch + WebFetch） | IDE 原生工具，不依赖 MCP，不受模型影响 |
| Claude Code | ⚠️ 取决于模型 + MCP | 旗舰模型（Sonnet/Opus）有 WebFetch；小模型降级为 chat-only |
| Codex | ⚠️ 取决于模型 + MCP | 同上，GPT-4 有，小模型无 |
| OpenCode | ✅ 通常有 | 使用自家内置模型（通常 Anthropic 旗舰） |
| Hermes | ⚠️ 取决于模型 + MCP | 小模型 function calling 准确率参差 |

### 1.2 核心洞察

> **agent 报"网络不可达"是误判症状**：实际可能是"模型降级"或"MCP server 未装"，不要被"网络"二字误导去查 DNS/firewall。

### 1.3 解决方案

**Trae 做网络抓取专员** + 落 `_kb/raw/` + 其他 agent 接力读本地。这是最稳的方案，契合接力机制。

---

## 2. Trae 网络抓取专员工作流

### 2.1 标准流程

```
其他 agent 需要网络资料
  ↓
向 Trae 发起抓取请求（通过 agent-dispatcher 或手动）
  ↓
Trae 执行抓取：
  1. WebSearch 搜索关键词
  2. WebFetch 抓取目标 URL
  3. 整理为 OKF raw 格式
  4. 落地到 _kb/raw/YYYY-MM-DD_<topic>.md
  ↓
其他 agent 从 _kb/raw/ 读取本地文件（无需网络）
  ↓
接力完成
```

### 2.2 抓取请求格式

其他 agent 向 Trae 发起请求时，使用以下格式：

```markdown
## 抓取请求

- **主题**: <要调研的主题>
- **关键词**: <搜索关键词列表>
- **目标 URL**（可选）: <已知的相关 URL>
- **输出文件**: _kb/raw/YYYY-MM-DD_<topic>.md
- **要求**: <深度/语言/格式要求>
- **用途**: <哪个 agent 用于什么任务>
```

### 2.3 Trae 抓取 SOP

#### Step 1: 搜索

```
WebSearch("<关键词> <年份>")
→ 获取 5-10 个相关结果
```

#### Step 2: 抓取

```
对每个相关 URL：
WebFetch(url)
→ 获取 markdown 格式内容
```

#### Step 3: 整理为 OKF raw 格式

```markdown
---
type: raw
title: <主题>
source: <URL 列表>
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [<主题标签>]
---

# <主题> 调研资料

## 来源 1: <标题>
URL: <url>
抓取时间: YYYY-MM-DD HH:MM

<内容摘要/全文>

## 来源 2: <标题>
...
```

#### Step 4: 落地

```
写入 _kb/raw/YYYY-MM-DD_<topic>.md
```

#### Step 5: 通知

```
回复请求 agent：
"抓取完成，资料已落地到 _kb/raw/YYYY-MM-DD_<topic>.md，共 N 个来源，X 字"
```

---

## 3. 适用场景

### 3.1 必须用 Trae 抓取的场景

- 其他 agent 报"网络不可达"（实际是模型降级）
- 需要抓取认证/私有内容（Trae 有用户 session）
- 需要实时搜索（WebSearch）

### 3.2 可不用 Trae 的场景

- OpenCode（通常有网络能力，可直接抓取）
- 已有本地资料（直接读 `_kb/raw/` 或 `_kb/wiki/`）
- 不需要网络的任务（纯代码/纯文档）

---

## 4. 与 agent-dispatcher 集成

### 4.1 dispatcher 配置

在 `agent-dispatcher.ps1` 的任务 JSON 中，网络抓取任务指定 Trae：

```json
{
  "tasks": [
    {
      "id": "web-research",
      "agent": "trae",
      "prompt": "抓取请求：主题=LangGraph 工作流图设计，关键词=[langgraph workflow graph design 2026]，输出=_kb/raw/2026-06-21_langgraph.md，用途=OpenCode 写 wiki 页",
      "dependsOn": [],
      "timeout": 600
    },
    {
      "id": "write-wiki",
      "agent": "opencode",
      "prompt": "读取 _kb/raw/2026-06-21_langgraph.md，按 page-templates.md 模板写 wiki/concepts/langgraph.md",
      "dependsOn": ["web-research"],
      "timeout": 1800
    }
  ]
}
```

### 4.2 Trae 不参与 dispatcher 的约束

> **注意**：Trae 是 IDE 内 agent，不能被 `agent-dispatcher.ps1` 直接调用（dispatcher 只支持 codex/claude/opencode/hermes）。

Trae 的网络抓取任务通过以下方式触发：
1. **用户在 Trae IDE 内直接下达**（最常见）
2. **其他 agent 在输出中建议**："建议请 Trae 抓取 XXX 资料"
3. **定时任务**（未来，通过 Trae Schedule 工具）

---

## 5. raw/ 文件管理

### 5.1 命名规范

```
_kb/raw/YYYY-MM-DD_<topic>.md
```

示例：
- `_kb/raw/2026-06-20_langgraph-workflow.md`
- `_kb/raw/2026-06-20_autogen-framework.md`

### 5.2 生命周期

```
raw/（抓取落地）
  ↓ 知识管家定期编译（flywheel kb compile 或手动）
wiki/<type>/（编译为 OKF 格式）
  ↓ 索引生成
index.md（自动收录）
```

### 5.3 清理规则

- raw/ 文件编译进 wiki/ 后**保留**（作为原始资料溯源）
- raw/ 文件数 ≥ 20 时触发知识管家整理（见 [km-agent-workflow.md](km-agent-workflow.md)）

---

## 6. 备选方案

当 Trae 也不可用时（IDE 未启动）：

| 方案 | 适用 | 操作 |
|------|------|------|
| OpenCode 直接抓取 | OpenCode 有网络能力 | OpenCode 用自身工具抓取，直接写 wiki/ |
| 手动抓取 | 紧急 | 用户浏览器手动下载，放 raw/ |
| 跳过网络 | 非关键路径 | 用已有本地资料，标注"待补充网络资料" |

---

## 7. 质量标准

Trae 抓取的 raw 文件需满足：

1. **frontmatter 完整** — type/source/created/updated/tags
2. **source 字段单引号** — Windows 路径含 `\d` `\s` 必须用单引号（见 project_memory 教训）
3. **多来源** — 至少 2 个独立来源（避免单一来源偏见）
4. **标注抓取时间** — 每个来源标注抓取日期
5. **内容深度** — 单个 raw 文件 ≥ 200 字

---

## 8. 相关文档

- [km-agent-workflow.md](km-agent-workflow.md) — raw → wiki 编译流程
- [page-templates.md](page-templates.md) — wiki 页面模板
- [flywheel-degradation.md](flywheel-degradation.md) — flywheel 降级方案
- `_meta/adapters/trae.md` — Trae adapter 配置
