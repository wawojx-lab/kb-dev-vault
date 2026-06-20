# 知识管家 Agent 整理流程

> 知识管家 Agent（Claude Code）是 vault 唯一有写权限的智能体。
> 本文件定义其整理流程和触发条件。

## 职责
1. 定期整理 `00-inbox/` → 分发到各目录
2. 拆解书籍/长文 → 结构化笔记
3. 维护 `90-meta/` 索引和 MOC
4. 同步 Trae memory 关键内容到 vault（账号切换兜底）

## 整理流程

### 触发条件（满足任一即触发）
- `00-inbox/` 文件数 ≥ 20
- 距上次整理超过 7 天
- 用户手动触发（"整理一下知识库"）

### Step 1：扫描 inbox
读取 `00-inbox/` 下所有 .md 文件，解析 frontmatter

### Step 2：按 type 分发
- `type=project` → 移动到 `10-projects/[project 字段值]/`
  - 目标目录不存在则创建
- `type=area` → 移动到 `20-areas/[area 字段值]/`
- `type=resource` → 移动到 `30-resources/`
  - 书籍类 → `30-resources/books/[标题]/`
  - 其他 → `30-resources/`

### Step 3：处理无 frontmatter 的文件
- 尝试从内容推断 type（含项目名 → project，含主题关键词 → area）
- 无法推断 → 标记为"待处理"，在文件名加 `[待处理]` 前缀，留在 inbox
- 提醒用户手动分类

### Step 4：更新索引
- 更新 `90-meta/index.md`，记录新增笔记
- 若某项目/主题笔记数 ≥ 5，创建或更新对应 MOC

### Step 5：清理 inbox
- 已分发的文件从 inbox 删除
- 记录整理日志到 `90-meta/vault-changelog.md`（vault 整理日志，区别于 `_meta/CHANGELOG.md` 规范变更日志）

### Step 6：超期提醒
- 检查 inbox 中超过 30 天未分发的文件
- 列出清单提醒用户处理

## 书籍拆解流程

### 触发：用户提供书籍内容（文本/PDF/链接）

### Step 1：通读
- 用 Claude Code 读取全文
- 提取核心观点、方法论、案例

### Step 2：结构化输出
在 `30-resources/books/[书名]/` 下创建：
- `核心原则.md` — 10 条以内的核心原则
- `执行方法论.md` — 可操作的步骤
- `案例映射.md` — 书中案例如何映射到用户的项目
- `原文摘要.md` — 关键段落摘录（版权合规：单条摘录不超过 200 字，总量不超过 1000 字，注明页码）

### Step 3：关联
- 在 `20-areas/` 相关主题笔记中引用该书
- 更新对应 MOC

### Step 4：智能体引用
- 在 `_meta/AGENTS.md` 或项目 AGENTS.md 中添加引用：
  "执行任务时参考 `_kb/30-resources/books/[书名]/核心原则.md`"
- 智能体通过 MCP 读取，把原则注入上下文

## Memory 同步流程

### 触发：每次知识管家运行时

### Step 1：读取 Trae memory
- 读取 `C:\Users\65128\.trae-cn\memory\user_profile.md`（用户级偏好）
- 读取 `C:\Users\65128\.trae-cn\memory\projects\-d-xiangmu\project_memory.md`（工作区级项目记忆，含多项目信息）

### Step 2：同步到 vault
- user_profile 内容 → `20-areas/ai-toolchain/我的偏好.md`（覆盖更新）
- project_memory 内容 → `20-areas/ai-toolchain/项目记忆.md`（工作区级，整体同步，不按项目拆分，因为 project_memory.md 是工作区级而非项目级）

### Step 3：换账号兜底
- 新账号第一次会话时，智能体读 `20-areas/ai-toolchain/我的偏好.md` 恢复偏好
- vault 是文件，和账号无关，永远在

## 运行方式
- 手动触发：用户说"整理知识库"或"拆解这本书"
- 定时触发（Hermes Cron）：每周日 09:00 自动运行整理流程
- 详细定时配置见远程接入细化阶段
