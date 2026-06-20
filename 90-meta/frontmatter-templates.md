---
type: index
title: Frontmatter 模板（OKF 5 type 封闭词汇）
source: Google OKF v0.1 + flywheel WIKI_SUBDIR_TO_TYPE
created: 2026-06-19
updated: 2026-06-20
confidence: stated
status: developing
tags: [meta, frontmatter, okf, flywheel]
---

# Frontmatter 模板

> **2026-06-20 重大更新**：从开放 type 词汇（project/area/resource）改为 flywheel 封闭 type 词汇（entity/concept/comparison/summary/synthesis）
> **所有 wiki 笔记**必须有 title/source/created/updated/type/confidence 必填字段（flywheel 强校验）
> **YAML source 字段含 Windows 路径时用单引号**（双引号让 `\d` `\s` 被当转义序列）

## wiki/ 笔记通用模板（必填）

```yaml
---
type: concept | entity | comparison | summary | synthesis   # flywheel 封闭 5 type
title: [笔记标题]
source: 'PROJECT_STATUS.md @ d:\xiangmu\xxx'   # 单引号！含 Windows 路径必须单引号
created: YYYY-MM-DD
updated: YYYY-MM-DD
confidence: stated | inferred | speculative
status: seed | developing | mature | evergreen
tags: [tag1, tag2]
---
```

## 各 type 详细模板

### concept（概念）— wiki/concepts/
抽象概念（方法/指标/理论/偏好）

```yaml
---
type: concept
title: 用户偏好（从 Trae memory 同步）
source: 'Trae memory (user_profile.md) + 手动整理'
created: 2026-06-19
updated: 2026-06-20
confidence: stated
status: mature
tags: [偏好, user-profile]
---
```

### entity（实体）— wiki/entities/
具体实体（人物/公司/产品/工具）

```yaml
---
type: entity
title: flywheel
source: 'https://github.com/.../flywheel'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [工具, kb-engine]
---
```

### comparison（对比）— wiki/comparisons/
X vs Y 选型/优劣

```yaml
---
type: comparison
title: OKF vs 普通 Markdown 知识库
source: 'Google OKF 公告 + 个人整理'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [对比, okf, 选型]
---
```

### summary（摘要）— wiki/summaries/
单源提炼的项目/文章/书

```yaml
---
type: summary
title: stock-sim
source: 'PROJECT_STATUS.md @ d:\xiangmu\stock-sim'
status: developing
path: d:\xiangmu\stock-sim
created: 2026-06-20
updated: 2026-06-20
confidence: stated
tags: [项目摘要, 股票, 交易系统]
---
```

### synthesis（综合）— wiki/synthesis/
多源合成的调研/全景

```yaml
---
type: synthesis
title: 知识库架构调研（OKF + Dynamic Workflows + flywheel）
source: 'Google OKF 2026-06-16 公告 + Claude Code 文档 + flywheel README'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: developing
tags: [调研, 知识库, OKF, flywheel, Dynamic-Workflows]
---
```

## 90-meta/ 元笔记模板

90-meta/ 下的元文件不参与 flywheel 校验，但保持 frontmatter 一致便于检索：

```yaml
---
type: index | moc   # flywheel 5 type 不含 index/moc，用 90-meta 自定义
title: [meta 笔记标题]
source: 'Trae + Claude Code + flywheel'
created: YYYY-MM-DD
updated: YYYY-MM-DD
confidence: stated
status: developing | mature
tags: [meta]
---
```

> 注意：90-meta/ 的 type 可以是 `index` / `moc` 等元 type，不强制走 flywheel 封闭词汇
> 飞轮只校验 wiki/ 下文件，90-meta/ 不查

## raw/ 原始素材模板

```yaml
---
type: raw    # 或 concept/entity/...，作为初始 type
title: [素材标题]
source: '原始来源（URL/书/会议/笔记）'
created: YYYY-MM-DD
date: YYYY-MM-DD HH:MM   # 原始时间
tags: []
status: raw | processed
---
```

## 必填字段（flywheel 强校验）

| 字段 | 取值 | 必填 |
|------|------|------|
| title | 字符串 | ✓ |
| source | 字符串（含路径用单引号）| ✓ |
| created | YYYY-MM-DD | ✓ |
| updated | YYYY-MM-DD | ✓ |
| type | 5 type 之一 | ✓ |
| confidence | stated/inferred/speculative | ✓ |
| status | seed/developing/mature/evergreen | 推荐 |
| tags | 字符串数组 | 推荐 |

## YAML 转义陷阱

```yaml
# 错：双引号包 Windows 路径 → \d \s 被当转义
source: "PROJECT_STATUS.md @ d:\xiangmu\stock-sim"   # ❌ YAML 解析错

# 对：单引号
source: 'PROJECT_STATUS.md @ d:\xiangmu\stock-sim'   # ✓
```
