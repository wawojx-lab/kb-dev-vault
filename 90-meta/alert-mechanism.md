---
type: index
title: 告警机制
source: P2-11 改进项
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: mature
tags: [meta, alert, notification, webhook, email, monitoring]
---

# 告警机制

> 定义 lint 报错、密钥泄露、锁死锁、健康度 critical 时的通知机制。
> 关联改进项：P2-11（告警机制）
> 关联问题：I4（lint 报错时无通知）

---

## 1. 告警类型

| 类型 | 触发条件 | 严重度 | 触发点 |
|------|----------|--------|--------|
| `lint-error` | pre-commit 检测到 KB lint error/cycle | WARNING | pre-commit hook |
| `secret-detected` | pre-commit 检测到密钥/token | CRITICAL | pre-commit hook |
| `lock-stuck` | kb-write.lock 超过 TTL 未释放 | WARNING | health-dashboard |
| `health-critical` | 项目 blocked 数 > 阈值 或 KB error > 0 | CRITICAL | health-dashboard |
| `custom` | 用户自定义 | INFO | 手动调用 |

---

## 2. 通知渠道

| 渠道 | 配置 | 适用 |
|------|------|------|
| **飞书 webhook** | `alert-config.json` → feishu.webhookUrl | 团队协作（推荐） |
| **钉钉 webhook** | `alert-config.json` → dingtalk.webhookUrl | 团队协作 |
| **邮件 (SMTP)** | `alert-config.json` → email.* | 个人通知 |
| **日志文件** | `_meta/logs/alerts.log`（默认开启） | 审计追溯 |

---

## 3. 配置

### 3.1 配置文件

`d:\xiangmu\_meta\alert-config.json`：

```json
{
  "feishu": {
    "enabled": true,
    "webhookUrl": "https://open.feishu.cn/open-apis/bot/v2/hook/<your-hook-id>"
  },
  "dingtalk": {
    "enabled": false,
    "webhookUrl": ""
  },
  "email": {
    "enabled": false,
    "smtpServer": "",
    "port": 587,
    "from": "",
    "to": "",
    "username": "",
    "password": ""
  }
}
```

### 3.2 获取飞书 webhook

1. 飞书群 → 设置 → 群机器人 → 添加机器人 → 自定义机器人
2. 复制 webhook URL
3. 填入 `alert-config.json` 的 `feishu.webhookUrl`
4. 设置 `feishu.enabled: true`

### 3.3 获取钉钉 webhook

1. 钉钉群 → 群设置 → 智能群助手 → 添加机器人 → 自定义
2. 复制 webhook URL
3. 填入 `alert-config.json` 的 `dingtalk.webhookUrl`
4. 设置 `dingtalk.enabled: true`

---

## 4. 使用

### 4.1 手动发送告警

```powershell
# 自定义告警
.\alert.ps1 -Type custom -Message "测试告警" -Detail "这是详情"

# DryRun 测试（不实际发送）
.\alert.ps1 -Type custom -Message "测试" -DryRun
```

### 4.2 集成到 pre-commit hook

在 `pre-commit.ps1` 中，当检测到 lint error 或 secret 时调用：

```powershell
# lint error 时
if ($hasError -or $hasCycle) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "d:\xiangmu\_meta\alert.ps1" -Type lint-error -Message "KB lint failed in commit" -Detail "$lintOutput"
}

# secret detected 时
if ($secretsFound.Count -gt 0) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "d:\xiangmu\_meta\alert.ps1" -Type secret-detected -Message "Potential secrets in staged files" -Detail ($secretsFound | Out-String)
}
```

### 4.3 集成到 health-dashboard

在 `health-dashboard.ps1` 中，检测到 critical 状态时调用：

```powershell
# 项目 blocked 数 > 10
if ($blockedCount -gt 10) {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "d:\xiangmu\_meta\alert.ps1" -Type health-critical -Message "Projects blocked count: $blockedCount"
}

# 锁死锁检测
$lockStatus = & powershell.exe -NoProfile -File "d:\xiangmu\_kb\90-meta\kb-lock.ps1" status
if ($lockStatus -match "expired") {
    & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "d:\xiangmu\_meta\alert.ps1" -Type lock-stuck -Message "KB write lock expired but not released"
}
```

---

## 5. 告警日志

所有告警（无论是否发送成功）都记录到 `_meta/logs/alerts.log`：

```
[2026-06-21 01:10:00] CRITICAL secret-detected | feishu=true dingtalk=false email=false | Potential secrets in staged files
[2026-06-21 01:15:00] WARNING lint-error | feishu=true dingtalk=false email=false | KB lint failed in commit
[2026-06-21 02:00:00] WARNING lock-stuck | feishu=false dingtalk=false email=false | KB write lock expired
```

---

## 6. 设计原则

1. **非阻断**：告警发送失败不影响主流程（pre-commit 仍阻断，但 alert.ps1 exit 0）
2. **多渠道冗余**：可同时启用飞书 + 钉钉 + 邮件，任一成功即通知
3. **可配置**：通过 JSON 配置，无需改代码
4. **可审计**：所有告警记录到 logs/alerts.log
5. **防骚扰**：同类型告警可扩展去重（未来加 cooldown 机制）

---

## 7. 相关文件

| 文件 | 用途 |
|------|------|
| `_meta/alert.ps1` | 告警发送脚本 |
| `_meta/alert-config.json` | 渠道配置 |
| `_meta/logs/alerts.log` | 告警日志 |
| `_kb/.git/hooks/pre-commit.ps1` | lint/secret 告警触发点 |
| `_meta/health-dashboard.ps1` | health/lock 告警触发点 |
