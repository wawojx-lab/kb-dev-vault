---
type: meta
title: wiki page templates (5 type)
source: 'd:\xiangmu\_kb\90-meta\page-templates.md'
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: evergreen
tags: [模板, OKF, wiki, agent-output]
---

# Wiki Page Templates (5 type)

> 所有 agent 产出 wiki 页面**必须**基于以下 5 个模板之一。
> 校验脚本：`d:\xiangmu\_kb\90-meta\wiki-validator.ps1`（frontmatter + cycle + 深度）

## 通用规则（所有 type 共享）

### Frontmatter 必填字段

| 字段 | 类型 | 说明 | 示例 |
|------|------|------|------|
| `type` | enum | 必须是 5 个封闭词汇之一：entity / concept / comparison / summary / synthesis | `entity` |
| `title` | string | 页面标题（与文件名可不同） | `Trae IDE` |
| `source` | string | **Windows 路径必须用单引号**（双引号会触发 `\d` `\s` 转义） | `'d:\xiangmu\_meta'` |
| `created` | date | YYYY-MM-DD | `2026-06-21` |
| `updated` | date | YYYY-MM-DD（每次修改必须更新） | `2026-06-21` |
| `confidence` | enum | stated / inferred / derived | `stated` |
| `tags` | array | 至少 1 个标签 | `[工具, IDE]` |

### Frontmatter 可选字段

| 字段 | 类型 | 适用 type | 说明 |
|------|------|-----------|------|
| `status` | enum | 全部 | developing / evergreen / mature |
| `subjects` | array | comparison | 被对比的实体列表 |
| `path` | string | entity | 实体在本工作区的路径 |
| `parent` | string | summary | 父项目名 |

### Wikilink 规则（防 cycle）

- **单向引用优先**：A → B 后，B 不应再 → A（除非是 comparison 类型）
- **entity 是 sink**：entity 页面内的 wikilink 应改为 markdown link `[text](path.md)`
- **comparison 是 bridge**：comparison 页面可以双向引用 entity
- **新页面至少 1 个 wikilink**：连接到已有页面，避免孤立节点

### 内容深度下限

| type | 最低字数 | 最低 wikilink 数 | 必含章节 |
|------|----------|------------------|----------|
| entity | 200 | 1 | 核心能力 / 在本工作区的角色 |
| concept | 200 | 2 | 核心原则 / 关键文件位置 |
| comparison | 300 | 2 | 维度对比（表格）/ 选型建议 |
| summary | 300 | 3 | 项目背景 / 执行步骤 / 产出清单 |
| synthesis | 400 | 4 | 调研背景 / 核心洞察 / 行动清单 |

---

## 模板 1：entity（具体实体）

```markdown
---
type: entity
title: <实体名>
source: '<来源路径或文档>'
status: developing
path: <工作区路径，可选>
created: 2026-06-21
updated: 2026-06-21
confidence: stated
tags: [<标签1>, <标签2>]
---

# <实体名>

<一句话定位>

## 核心能力
- **<能力1>**：<描述>
- **<能力2>**：<描述>

## 在本工作区的角色
- <角色描述>

## 关键特性
| 特性 | 说明 |
|------|------|
| <特性1> | <说明> |

## 关联
- [[<相关概念>]]
- [相关实体](../entities/<other>.md)
```

---

## 模板 2：concept（抽象概念）

```markdown
---
type: concept
title: <概念名>
source: '<来源>'
status: developing
created: 2026-06-21
updated: 2026-06-21
confidence: stated
tags: [<标签>]
---

# <概念名>（<英文>）

<一句话定义>

## 核心原则
- **<原则1>**：<描述>
- **<原则2>**：<描述>

## 关键文件位置
- `<路径1>` — <说明>
- `<路径2>` — <说明>

## 实践案例
<具体案例描述>

## 关联
- [[<相关概念1>]]
- [[<相关概念2>]]
- [相关实体](../entities/<other>.md)
```

---

## 模板 3：comparison（对比分析）

```markdown
---
type: comparison
title: <A>-vs-<B>
subjects: [<A>, <B>]
source: '<来源>'
status: developing
created: 2026-06-21
updated: 2026-06-21
confidence: inferred
tags: [对比, <领域>]
---

# <A> vs <B>

<一句话对比核心差异>

## 维度对比

| 维度 | <A> | <B> |
|------|-----|-----|
| <维度1> | <A的值> | <B的值> |
| <维度2> | <A的值> | <B的值> |
| <维度3> | <A的值> | <B的值> |

## 各自优势
### <A> 的优势
- <优势1>

### <B> 的优势
- <优势1>

## 选型建议
- **选 <A> 当**：<场景>
- **选 <B> 当**：<场景>

## 关联
- [[<A 实体>]]
- [[<B 实体>]]
```

---

## 模板 4：summary（项目总结）

```markdown
---
type: summary
title: <项目名>-summary
parent: <父项目名>
source: '<来源>'
status: developing
created: 2026-06-21
updated: 2026-06-21
confidence: stated
tags: [总结, <领域>]
---

# 项目：<项目名>

> <项目一句话描述>

## 项目背景
<为什么做这个项目>

## 执行步骤
1. <步骤1>
2. <步骤2>
3. <步骤3>

## 产出清单
- [产出1](../entities/<file>.md)
- [产出2](../concepts/<file>.md)

## 经验教训
- <教训1>
- <教训2>

## 关联
- [[<相关概念>]]
- [[<相关实体>]]
- [[<相关总结>]]
```

---

## 模板 5：synthesis（综合洞察）

```markdown
---
type: synthesis
title: <洞察标题>
source: '<来源>'
status: developing
created: 2026-06-21
updated: 2026-06-21
confidence: derived
tags: [综合, <领域>]
---

# <洞察标题>

> <一句话核心洞察>

## 调研背景
<为什么做这个综合分析>

## 核心洞察
1. **<洞察1>**：<描述 + 证据>
2. **<洞察2>**：<描述 + 证据>
3. **<洞察3>**：<描述 + 证据>

## 跨领域连接
- <领域A> 与 <领域B> 的交集：<描述>
- [[<概念A>]] ↔ [[<概念B>]]

## 行动清单
- [ ] <行动1>
- [ ] <行动2>

## 关联
- [[<相关实体1>]]
- [[<相关概念1>]]
- [[<相关对比>]]
- [[<相关总结>]]
```

---

## Agent 产出流程

1. **选模板**：根据内容性质选 5 个 type 之一
2. **填字段**：frontmatter 必填字段全部填齐（`source` 用单引号）
3. **写内容**：达到字数下限 + wikilink 下限
4. **自查 cycle**：新页面的 wikilink 不应形成环（entity 是 sink）
5. **跑校验**：`powershell.exe -File wiki-validator.ps1 -Target <新页面.md>`
6. **修问题**：根据校验报告修复，直到 0 error
7. **commit**：通过 pre-commit hook（已含 kb lint）

## 校验脚本

`d:\xiangmu\_kb\90-meta\wiki-validator.ps1`

支持 3 种模式：
- 单文件校验：`-Target <file.md>`
- 全量校验：`-All`
- 仅 cycle 检测：`-CycleOnly`
