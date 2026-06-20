---
type: index
title: 知识管家 Agent 整理流程
source: Trae + Claude Code 协作 + 飞轮知识编译
created: 2026-06-19
updated: 2026-06-20
confidence: stated
status: developing
tags: [meta, knowledge-management, flywheel]
---

# 知识管家 Agent 整理流程

> **写入权限（2026-06-20 更新）**：取消"单点写入"限制，**所有智能体可写** raw/wiki/90-meta；知识管家（Claude Code + flywheel）负责**治理**。
> 4 层架构（raw/wiki/research/projects）已合并为 3 层（raw/wiki/90-meta）+ wiki 内 flywheel 5 type 子目录。

## 职责

1. **lint 检查** — 定期跑 `kb lint` 检查 wiki 内 frontmatter、wikilink、type 词汇
2. **stats 统计** — 定期跑 `kb stats` 看页面数/边数/PageRank
3. **图谱可视化** — 跑 `kb graph-viz` 输出 Mermaid 知识图谱
4. **维护 90-meta/** — 索引（index.md）+ frontmatter 模板 + 整理日志
5. **同步 Trae memory** — 把 user_profile.md / project_memory.md 关键内容同步到 wiki/concepts/（账号切换兜底）

## 整理流程

### 触发条件（满足任一即触发）
- `raw/` 文件数 ≥ 20
- 距上次整理超过 7 天
- 用户手动触发（"整理一下知识库"）

### Step 1：扫描 raw 源

读取 `raw/` 下所有 .md 文件，解析 frontmatter（type/source/created/updated/tags）

### Step 2：按 OKF 5 type 分发

wiki/ 下固定 5 个子目录，子目录名 = type：

| 源 type | 目标子目录 | 飞轮推断 type |
|--------|----------|------------|
| `concept` | `wiki/concepts/` | concept |
| `entity` | `wiki/entities/` | entity |
| `comparison` | `wiki/comparisons/` | comparison |
| `summary` | `wiki/summaries/` | summary |
| `synthesis` | `wiki/synthesis/` | synthesis |
| 其他 raw 笔记 | 留在 raw/ | 不参与图谱 |

> 5 type 词汇来自 flywheel `WIKI_SUBDIR_TO_TYPE`（`config.py:597-603`）的封闭词汇表
> frontmatter `type` 字段是元数据，**不**参与 flywheel 的 type 推断（flywheel 看子目录名）

### Step 3：处理无 frontmatter / type 错误的文件

- 尝试从内容推断 type（含项目名 → summary，含主题关键词 → concept）
- 无法推断 → 标记为"待处理"，在文件名加 `[待处理]` 前缀，留在 raw
- 提醒用户手动分类

### Step 4：更新索引

- 更新 [index.md](index.md)，按 type 列出 wiki 笔记
- 若某概念笔记数 ≥ 5，创建或更新对应 MOC

### Step 5：清理 raw

- 已分发的文件从 raw 删除
- 记录整理日志到 [vault-changelog.md](vault-changelog.md)

### Step 6：超期提醒

- 检查 raw 中超过 30 天未分发的文件
- 列出清单提醒用户处理

## flywheel 工具调用约定

```bash
# 必传 KB_PROJECT_ROOT，否则去找 flywheel demo
export KB_PROJECT_ROOT=d:\xiangmu\_kb

# lint — 12 项检查（frontmatter/wikilink/cycles/dead_links/orphan/staleness/...）
kb lint

# stats — 必须显式传 --wiki-dir（flywheel _validate_wiki_dir(None) bug）
kb stats --wiki-dir d:\xiangmu\_kb\wiki

# graph-viz — 输出 Mermaid
kb graph-viz

# graph-viz 保存到文件
kb graph-viz --output graph.mmd
```

## Memory 同步流程

### 触发：每次知识管家运行时

### Step 1：读取 Trae memory

- 读取 `C:\Users\65128\.trae-cn\memory\user_profile.md`（用户级偏好）
- 读取 `C:\Users\65128\.trae-cn\memory\projects\-d-xiangmu\project_memory.md`（工作区级项目记忆）

### Step 2：同步到 vault

- user_profile 内容 → `wiki/concepts/用户偏好.md`（覆盖更新）
- project_memory 内容 → `wiki/synthesis/项目记忆.md`（整体同步，工作区级而非项目级）

### Step 3：换账号兜底

- 新账号第一次会话时，智能体读 `wiki/concepts/用户偏好.md` 恢复偏好
- vault 是文件，和账号无关，永远在

## wikilink 约定（必读）

flywheel 的两个 lint 限制：
1. **dead_links 不解析 bare slug** — `[[stock-sim]]` 报死链，必须用 `[[summaries/stock-sim]]` 完整 page_id
2. **wikilink_cycles 检测严格** — 2-cycle 也算 cycle，**必须单向无环 DAG 设计**

DAG 设计原则：
- **出度有限**：每个节点建议 1-4 个 wikilink 出度
- **无环**：拓扑排序后只能从高层引用低层
- **强引用用 wikilink**（参与图谱），**导航用 markdown 链接**（不参与图谱）

## 运行方式

- 手动触发：用户说"整理知识库"或"跑 kb lint"
- 定时触发（待定）：每周日 09:00 自动跑 kb lint + stats
- 详细定时配置见远程接入细化阶段
