---
type: meta
title: Concurrent Write Protocol (multi-agent _kb/ writes)
source: 'd:\xiangmu\_kb\90-meta\concurrent-write-protocol.md'
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: evergreen
tags: [协议, 并发, git, 锁, multi-agent]
---

# Concurrent Write Protocol

> 5 agent（Trae/Codex/Claude-Code/OpenCode/Hermes）并发写入 `_kb/` 的协议。
> 解决复盘 H1/H2/H3：无锁 / push 冲突无协议 / 无协调器。

## 1. 问题场景

| 场景 | 后果 | 当前（无协议） |
|------|------|----------------|
| A 写 wiki/entities/X.md，B 同时写 wiki/entities/X.md | 后写者覆盖先写者 | 靠"串行 commit"默契 |
| A push 后，B push 前 origin 已变 | B push 被拒（non-fast-forward） | B 不知道怎么办，放弃 |
| A lint 失败 commit 卡住，B 同时 commit | B 的 commit 也卡 | 互相阻塞 |
| A 改 frontmatter，B 改同一文件正文 | rebase 冲突 | 无解决流程 |

## 2. 锁机制（File Lock）

### 2.1 锁文件位置

```
d:\xiangmu\_kb\.git\kb-write.lock
```

放在 `.git/` 下（已 gitignore，不会被 commit），单文件简单可靠。

### 2.2 锁文件格式

```json
{
  "holder": "Trae",
  "acquiredAt": "2026-06-21T00:30:15+08:00",
  "expiresAt": "2026-06-21T00:45:15+08:00",
  "purpose": "add wiki/entities/NewTool.md + update index.md",
  "pid": 12345
}
```

- `holder`：agent 名（Trae/Codex/Claude-Code/OpenCode/Hermes）
- `acquiredAt`：获取时间（ISO 8601）
- `expiresAt`：过期时间（默认 15 分钟，防 agent 崩溃后死锁）
- `purpose`：本次写入目的（人类可读）
- `pid`：获取锁的进程 ID（用于检测僵死锁）

### 2.3 锁操作

| 操作 | 命令 | 行为 |
|------|------|------|
| acquire | `kb-lock.ps1 acquire -Holder <agent> -Purpose <text>` | 若锁不存在或已过期 → 创建锁；否则 → 退出码 1 |
| release | `kb-lock.ps1 release` | 删除锁文件（任何 agent 可释放过期锁） |
| is-held | `kb-lock.ps1 is-held` | 检查锁是否存在且未过期（退出码 0=held, 1=free） |
| status | `kb-lock.ps1 status` | 打印当前锁状态 |

### 2.4 过期策略

- 默认 TTL = 15 分钟
- 任何 agent 检测到过期锁可直接 acquire（覆盖旧锁）
- agent 完成写入后**必须** release（不要等过期）

## 3. Push 冲突处理协议

### 3.1 标准流程（kb-safe-push.ps1）

```
1. acquire lock (TTL 15min)
2. git add <files>
3. git commit -m "<msg>"
4. git pull --rebase origin main
   ├── 成功 → goto 5
   └── 冲突 → goto 6
5. git push origin main
   ├── 成功 → release lock, done
   └── 失败 → goto 4 (最多重试 2 次)
6. 冲突处理:
   - 同一文件不同区域 → 保留双方改动（git add 后 continue rebase）
   - 同一文件同一区域 → agent 手动解决，或放弃本次 push（release lock, exit 1）
   - frontmatter 冲突 → 以"updated 更新者"为准，重写冲突行
7. release lock
```

### 3.2 重试限制

- pull --rebase 失败：最多重试 2 次
- push 失败：最多重试 2 次
- 总超时：15 分钟（锁过期自动释放）

### 3.3 冲突解决优先级

| 冲突类型 | 解决策略 |
|----------|----------|
| 新增文件（无冲突） | 自动合并 |
| 同文件不同区域 | 自动合并 |
| 同文件同区域 | 手动解决或放弃 |
| frontmatter `updated` 字段 | 以最新日期为准 |
| frontmatter `tags` 字段 | 并集合并 |
| wikilink 冲突 | 保留双方 wikilink（多比少好） |

## 4. Agent 写入流程（标准 SOP）

每个 agent 写入 `_kb/` **必须**遵循：

```
1. kb-lock.ps1 acquire -Holder <agent-name> -Purpose "<本次写入目的>"
   ├── 退出码 0 → 获得锁，继续
   └── 退出码 1 → 锁被占用，等待 30s 后重试（最多 3 次）

2. 创建/修改 wiki/<type>/<file>.md

3. wiki-validator.ps1 -Target <file.md>
   ├── PASS → 继续
   └── FAIL → 修复或放弃（release lock, exit 1）

4. index-generator.ps1  # 刷新 index.md

5. kb-safe-push.ps1 -CommitMsg "<msg>" -Holder <agent-name>
   # 内部: commit + pull --rebase + push + release lock

6. 验证: git log -1 --format="%h %s"
```

## 5. 紧急情况

### 5.1 锁死锁（agent 崩溃未 release）

```powershell
# 任何 agent 可强制释放过期锁
kb-lock.ps1 release -Force
```

### 5.2 跳过锁（仅紧急）

```powershell
# 直接 git 操作，不获取锁（不推荐，仅用于修复损坏状态）
git add . && git commit -m "emergency fix" && git push
```

### 5.3 锁状态查询

```powershell
kb-lock.ps1 status
# 输出: Lock held by Trae since 2026-06-21 00:30 (5 min ago), purpose: add NewTool.md
```

## 6. 工具清单

| 工具 | 路径 | 用途 |
|------|------|------|
| kb-lock.ps1 | `d:\xiangmu\_kb\90-meta\kb-lock.ps1` | 锁 acquire/release/is-held/status |
| kb-safe-push.ps1 | `d:\xiangmu\_kb\90-meta\kb-safe-push.ps1` | 安全 push 包装（lock+commit+rebase+push+unlock） |
| wiki-validator.ps1 | `d:\xiangmu\_kb\90-meta\wiki-validator.ps1` | 页面校验（P1-2） |
| pre-commit.ps1 | `d:\xiangmu\_kb\.git\hooks\pre-commit.ps1` | lint + secret scan（P0-1/P0-2） |

## 7. 与 agent-dispatcher 集成

`agent-dispatcher.ps1` 派发任务时，每个 agent 任务的 prompt 模板应包含：

```
写入 _kb/ 时遵循 concurrent-write-protocol.md：
1. 先 acquire lock: powershell -File d:\xiangmu\_kb\90-meta\kb-lock.ps1 acquire -Holder <你> -Purpose "<目的>"
2. 写入 + 校验
3. 安全 push: powershell -File d:\xiangmu\_kb\90-meta\kb-safe-push.ps1 -CommitMsg "<msg>" -Holder <你>
```

## 8. 健康度指标

以下指标纳入 `health-dashboard.ps1`：

- 当前锁状态（held/free）
- 过去 24h 锁获取次数
- 过去 24h push 冲突次数
- 过去 24h 锁过期次数（agent 崩溃指标）
