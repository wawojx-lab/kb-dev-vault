# Frontmatter 模板

> 所有 vault 笔记应含 frontmatter，便于检索和整理。

## inbox 投递模板（必填 type）

```yaml
---
type: project | area | resource
project: [项目名，type=project 时必填]
area: [主题名，type=area 时必填]
source: Trae | Codex | Claude-Code | OpenCode | Hermes | 手动
date: YYYY-MM-DD HH:MM
tags: []
---
```

## 项目笔记模板（10-projects/）

```yaml
---
type: project
project: [项目名]
title: [笔记标题]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
status: active | archived
---
```

## 主题笔记模板（20-areas/）

```yaml
---
type: area
area: ai-toolchain | stocks | construction | bidding
title: [笔记标题]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
status: active | archived
---
```

## 资源笔记模板（30-resources/，如书籍拆解）

```yaml
---
type: resource
resource_type: book | article | video | course
title: [资源标题]
author: [作者]
source: [URL 或来源]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: []
status: reading | completed | archived
---
```

## MOC 模板（90-meta/）

```yaml
---
type: moc
title: [MOC 标题，如 AI 工具链地图]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [moc]
---
```

## 索引模板（90-meta/）

```yaml
---
type: index
title: [索引标题]
created: YYYY-MM-DD
updated: YYYY-MM-DD
tags: [index]
---
```
