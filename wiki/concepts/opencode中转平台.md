---
type: concept
title: OpenCode 中转平台
source: 'opencode 1.17.9 官方文档（https://opencode.ai/docs/cli/）+ SuanJia\feishu_bridge\ARCHITECTURE.md + 本地验证 2026-06-21'
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: design
tags: [架构, 中转平台, opencode, 飞书, 多Agent, agent-orchestration]
---

# OpenCode 中转平台（OpenCode Relay Platform）

以 OpenCode `serve` 为后端、`run --attach` 为调用方、复用 SuanJia `feishu_bridge` 为前端的多端 AI 中转架构。**目标**：让用户从任意设备（飞书群 / 浏览器 / TUI）发消息，**5 秒内**得到 OpenCode 回答，所有 session 可追溯、可统计、可回放。

> **相关概念**：[[concepts/多Agent协作]]、[[concepts/接力机制]]

## 一、为什么需要中转

直接用 `opencode` CLI 的局限：

| 痛点 | 表现 | 中转方案 |
|------|------|----------|
| 单进程 | 一次只能跑一个会话 | `serve` 持常驻进程，多客户端 attach |
| 无持久化 | 关掉 CLI 会话丢失 | `opencode session` 内置 SQLite |
| 无 Web 入口 | 必须开终端 | `opencode web` 自带 UI |
| 无跨设备 | CLI 锁在本地 | `serve --mdns` 自动发现 |
| 无飞书集成 | 飞书用户够不到 | 复用 SuanJia `bridge.py` |
| 冷启动慢 | 每次 MCP server 重新初始化 | 一次 serve，N 次 attach 复用 |

> **任务拆解视角**：中转平台本身就是把"用户输入 → AI 推理 → 工具调用 → 结果输出"这个完整任务按端（飞书/Web/TUI）拆解并交给不同 handler，详见 [[concepts/任务拆解]]。

## 二、架构总览（C4 Context）

```
┌─────────────┐     ┌──────────────┐     ┌────────────────┐
│  飞书群用户  │────▶│  feishu_bridge│────▶│  opencode serve│
│  (手机/PC)  │◀────│   (Python)    │◀────│  (localhost)   │
└─────────────┘     └──────────────┘     └────────────────┘
                                                ▲
┌─────────────┐     ┌──────────────┐            │
│  Web 用户   │────▶│  opencode web│────────────┘
│  (浏览器)   │◀────│   (内置 UI)   │   (同进程)
└─────────────┘     └──────────────┘
                                                ▲
┌─────────────┐     ┌──────────────┐            │
│  终端用户   │────▶│ opencode run │────────────┘
│  (TUI 党)  │     │  --attach    │
└─────────────┘     └──────────────┘
                                                │
                                          ┌─────┴─────┐
                                          │ Anthropic │
                                          │  Claude   │
                                          │ (旗舰)    │
                                          └───────────┘
```

**关键边界**：
- `opencode serve` = **唯一 AI 进程**（省 token 缓存 / 统计 / session）
- 三个客户端（飞书 / Web / TUI）= **同 session API 接入**
- 会话元数据存 `~/.local/share/opencode/opencode.db`（SQLite）

## 三、组件设计

### 3.1 后端：opencode serve

```bash
# 启动（生产用 systemd / Task Scheduler / 后台 job）
opencode serve \
  --port 14096 \
  --hostname 0.0.0.0 \      # 监听所有接口（Tailscale 可达）
  --mdns \                   # 跨设备自动发现
  --print-logs               # 错误排查
```

**环境变量**：

| 变量 | 必填 | 用途 |
|------|------|------|
| `OPENCODE_SERVER_PASSWORD` | ✅ 生产 | HTTP basic auth（防未授权访问）|
| `OPENCODE_SERVER_USERNAME` | 可选 | 默认 `opencode` |
| `OPENCODE_AUTO_SHARE` | false | 是否自动分享 session URL |
| `OPENCODE_DISABLE_AUTOCOMPACT` | false | 关闭自动上下文压缩（保护长 session）|
| `OPENCODE_EXPERIMENTAL_BACKGROUND_SUBAGENTS` | true | 后台子 agent 任务（多 agent 并行）|

**安全加固**：
- 必须设 `OPENCODE_SERVER_PASSWORD`（生产）
- 防火墙只开 14096 给 Tailscale 网段（100.x）
- `--hostname 127.0.0.1` 限定本机（开发），`0.0.0.0` 限内网（生产 + Tailscale）

### 3.2 客户端 A：opencode-bridge.py（飞书桥接）

复用 SuanJia `feishu_bridge/bridge.py` 的模式，**只替换 AI 引擎**。

```python
# opencode-bridge.py — 飞书群消息 ↔ opencode run --attach
import subprocess, json, lark_oapi as lark

RELAY_URL = "http://127.0.0.1:14096"

@lark.on_message
def handle(event):
    user_msg = event.text.strip()
    # 调用 opencode run --attach，--format json 拿结构化输出
    result = subprocess.run(
        ["opencode", "run", "--attach", RELAY_URL,
         "--format", "json", "--dangerously-skip-permissions",
         user_msg],
        capture_output=True, text=True, timeout=120
    )
    # 解析 JSON 事件流，提取最后一个 text part
    answer = parse_json_events(result.stdout)
    return answer  # 回复到飞书群
```

**优势对比 SuanJia 自建 agent_engine**：
- ❌ 不需要 cc-switch 代理
- ❌ 不需要 mimo-v2.5-pro 适配
- ❌ 不需要自己管理 SQLite
- ✅ 直接用 Anthropic 旗舰（不受小模型降级影响）
- ✅ Token 统计 / 成本透明（`opencode stats`）

### 3.3 客户端 B：opencode web（浏览器）

```bash
opencode web --port 14097 --hostname 0.0.0.0
```

- 普通用户用浏览器直接访问 `http://100.x.x.x:14097`（Tailscale 内网）
- 图形化 session 管理
- 适合非技术团队成员（造价/秘书/老板）

### 3.4 客户端 C：opencode run --attach（终端）

```bash
# 复用 serve，复用 MCP server 缓存
opencode run --attach http://127.0.0.1:14096 "解释这段代码"

# 接续上次会话
opencode run --attach http://127.0.0.1:14096 --continue "继续"

# 切换 agent
opencode run --attach http://127.0.0.1:14096 --agent architect "评审这个设计"

# 强制分叉（保留主 session 干净）
opencode run --attach http://127.0.0.1:14096 --session ses_xxx --fork "实验性改动"
```

## 四、关键能力清单

| 能力 | 命令 | 用途 | 状态 |
|------|------|------|------|
| 启动后端 | `opencode serve --port 14096` | 常驻进程 | ✅ 已验证 |
| Web UI | `opencode web --port 14097` | 浏览器入口 | ✅ 内置 |
| 客户端 attach | `opencode run --attach URL` | 复用 serve | ✅ 已验证 |
| Session 列表 | `opencode session list` | 历史查询 | ✅ 13 sessions 已存 |
| Session 删除 | `opencode session delete <id>` | 清理 | ✅ |
| 用量统计 | `opencode stats` | 成本透明 | ✅ 缓存命中 99% |
| 模型自动调工具 | 模型自决 | WebFetch / Bash / Read | ✅ 演示中模型自动拉文档 |
| 会话继续/分支 | `--continue` / `--session` / `--fork` | 多轮 / 实验 | ✅ |
| 多 agent 路由 | `--agent <name>` | 角色切换 | ✅（待配置 agent）|
| 密码保护 | `OPENCODE_SERVER_PASSWORD` | 防未授权 | ✅ |
| mDNS 设备发现 | `serve --mdns` | 跨设备 | ✅ |
| 跨域 CORS | `serve --cors <origin>` | 浏览器接入 | ✅ |
| 自动批准 | `--dangerously-skip-permissions` | 生产用 | ✅ |
| 会话导出 | `opencode export <id>` | 备份/迁移 | ✅ |
| 会话导入 | `opencode import <file>` | 恢复 | ✅ |
| MCP 集成 | `opencode mcp add/list` | 工具扩展 | ✅（复用 _kb MCP 生态）|
| 移动端访问 | Tailscale + 14096 | 手机/平板 | ✅（Tailscale 已配）|

## 五、Session 策略

| 场景 | 策略 | 命令 |
|------|------|------|
| 飞书群私聊 | 每个用户一个 session | `--title "飞书-用户A-20260621"` |
| 飞书群公共群 | 群一个 session | `--session <群固定id>` |
| Web 用户 | 默认 session（`--continue`）| 浏览器自动管理 |
| 终端实验 | `--fork` 分叉 | 不污染主 session |
| 顾问任务 | 每次新 session | `--title "顾问-架构评审-20260621"` |
| 长期记忆 | 导出存档到 _kb | `opencode export > _kb/wiki/summaries/yyyymmdd-session.md` |

## 六、安全模型

| 层 | 控制 |
|----|------|
| 传输 | Tailscale WireGuard 加密（不暴露公网）|
| 认证 | HTTP basic auth（`OPENCODE_SERVER_PASSWORD`）|
| 授权 | `--dangerously-skip-permissions` 仅在受信网络用；公网需加 IP 白名单 |
| 审计 | `opencode session list` + `stats` 全留痕 |
| 凭证 | 复用 `secrets.ps1` DPAPI 加密（飞书 webhook 等）|
| 文件 | 模型读 `_kb/` 受 `git` 保护；写只允许 `_meta/output/` |

## 七、监控与告警

| 指标 | 来源 | 阈值 | 告警 |
|------|------|------|------|
| serve 进程存活 | Task Scheduler 周期检查 | down > 5min | 飞书告警 |
| Token 用量 | `opencode stats` | 单日 > $5 | 飞书告警 |
| Session 数 | `opencode session list \| wc -l` | > 200 | 飞书警告（清理）|
| 缓存命中率 | stats 显示 | < 80% | 飞书警告（模型配置问题）|
| bridge 错误 | `bridge.log` | 5xx 连续 3 次 | 飞书告警 |

**复用现有 alert.ps1**（已支持中文 + DPAPI）：
```powershell
pwsh d:\xiangmu\_meta\alert.ps1 -Type health-critical `
  -Message "opencode serve 进程消失" `
  -Detail "PID: xxx, 端口: 14096, 最后心跳: 2026-06-21 14:30"
```

## 八、成本模型

| 组成 | 来源 | 月度预估 |
|------|------|----------|
| OpenCode 服务 | Anthropic API（按 token）| $20-50（个人/小团队）|
| 飞书消息 | 免费（lark-oapi）| 0 |
| Tailscale | 免费（个人 100 设备）| 0 |
| 本地存储 | SQLite session DB | < 1 GB |
| **总计** | - | **$20-50/月** |

**省钱技巧**：
- 99% 缓存命中（演示实测）→ 大幅减少 input token 成本
- `--model anthropic/claude-haiku` 简单任务用 haiku（$0.25/1M）
- `--model anthropic/claude-sonnet` 复杂任务用 sonnet（$3/1M）
- 默认 sonnet，按需切 haiku

## 九、实施路线图

### P0 文档（今天，1 天）
- ✅ 本文档（opencode 中转平台架构设计）
- 写 `opencode-bridge.py` 设计稿（消息路由 / session 策略 / 错误处理）

### P1 MVP（2-3 天）
1. 启动 `opencode serve --port 14096`（Task Scheduler 常驻）
2. 写 `opencode-bridge.py`（最小可用版）：
   - 飞书群消息 → `opencode run --attach --format json`
   - 解析 JSON 事件流 → 提取 text part → 回复飞书
   - 每个用户一个 session，存到 session_id ↔ user_id 映射
3. 复用 `secrets.ps1` DPAPI 存飞书 webhook
4. 端到端测试：飞书发消息 → 5 秒内收到回答
5. `pwsh` 写 `opencode-serve-manager.ps1`（start/stop/status）

### P2 多 agent + Web UI（3-4 天）
1. 配置 4 个 agent：`architect` / `cost` / `gm` / `secretary`
2. bridge 按关键词路由 → 不同 `--agent` 参数
3. 启动 `opencode web` 暴露给浏览器
4. 每周 `opencode session list` 归档到 `_kb/wiki/summaries/`

### P3 远程 + 加固（1 周）
1. Tailscale 测试 + 文档化
2. `OPENCODE_SERVER_PASSWORD` 强制设置
3. 防火墙规则：只允许 Tailscale 网段 100.64.0.0/10
4. 移动端浏览器测试

## 十、风险与缓解

| 风险 | 影响 | 缓解 |
|------|------|------|
| opencode serve 进程挂 | 全部客户端不可用 | Task Scheduler 心跳 + 飞书告警 + auto-restart |
| 飞书消息洪水 | token 费用爆炸 | 速率限制（每用户 60 msg/h）+ 月度预算告警 |
| 模型误操作 | 误删文件 | `--dangerously-skip-permissions` 仅在受信网络；危险路径加 guard |
| 缓存失效 | 成本上升 | 监控 cache hit rate < 80% 告警 |
| session 无限增长 | 磁盘占满 | 每周归档 + `prune` 旧 session |
| 凭证泄露 | webhook 滥用 | 全部凭证走 DPAPI，不入 git |

## 十一、参考

- SuanJia `feishu_bridge/ARCHITECTURE.md`（飞书桥接模板）
- SuanJia `feishu_bridge/bridge.py`（lark-oapi 接入代码）
- SuanJia `feishu_bridge/agent_engine.py`（Tool Use 循环）
- SuanJia `feishu_bridge/router.py`（关键词路由，可改造为 `--agent` 切换）
- 本地 `d:\xiangmu\_meta\secrets.ps1`（DPAPI 凭证）
- 本地 `d:\xiangmu\_meta\alert.ps1`（中文告警）
- OpenCode 文档：https://opencode.ai/docs/cli/
- OpenCode 文档：https://opencode.ai/docs/server/

---

**实施开始日期**：2026-06-21
**预计完成日期**：P1 MVP = 2026-06-24
**Owner**：Trae + opencode 双 agent 协作
**前置依赖**：
- ✅ Tailscale 已配（2026-06-21）
- ✅ 飞书 webhook DPAPI 已迁移（2026-06-21）
- ✅ 告警系统中文版已部署（c68ba53）
- ✅ opencode 1.17.9 已装（C:\Users\65128\AppData\Roaming\npm\opencode.ps1）
