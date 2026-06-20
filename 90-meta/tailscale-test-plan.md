---
type: index
title: Tailscale 实测方案
source: P2-5 改进项
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: mature
tags: [meta, tailscale, vpn, remote-access, testing, china]
---

# Tailscale 实测方案

> 定义 Tailscale 在中国大陆环境的稳定性实测方案，验证其作为远程 agent 接入方案的可行性。
> 关联改进项：P2-5（Tailscale 实测）
> 关联问题：D4（远程访问方案未验证）

---

## 1. 背景

### 1.1 为什么选 Tailscale

| 方案 | 优点 | 缺点 | 中国大陆可用性 |
|------|------|------|---------------|
| **Tailscale** | 零配置、P2P、WireGuard、免费 | 依赖 DERP 中继（Google CDN） | ⚠️ 需实测 |
| 传统 VPN | 成熟 | 配置复杂、需公网 IP | ✅ 稳定 |
| frp/ngrok | 简单 | 需中转服务器、带宽受限 | ✅ 稳定 |
| ZeroTier | P2P | 节点少时慢 | ⚠️ 类似 Tailscale |

### 1.2 实测目标

验证 Tailscale 在中国大陆能否：
1. 成功连接到 Tailscale 网络
2. 节点间 P2P 直连（低延迟）
3. DERP 中继 fallback 可用（P2P 失败时）
4. 长时间稳定性（不掉线）
5. 带宽满足 git push/pull 需求

---

## 2. 实测环境

### 2.1 节点规划

| 节点 | 位置 | 网络 | 角色 |
|------|------|------|------|
| Node A | 北京（家宽电信） | 100Mbps 下载 / 30Mbps 上传 | 主工作机（d:\xiangmu） |
| Node B | 上海（云服务器/家宽） | 任意 | 远程 agent 机器 |
| Node C（可选） | 海外（VPS） | 任意 | DERP 中继测试 |

### 2.2 前置条件

- 两个 Tailscale 账号（或同一账号多设备）
- 两台机器均可访问互联网
- Windows / Linux / macOS 均可

---

## 3. 实测步骤

### 3.1 Phase 1: 安装与登录（10 分钟）

#### Node A（主工作机）

```powershell
# 1. 下载 Tailscale for Windows
# https://tailscale.com/download/windows
# 安装后登录（Google/Microsoft/GitHub 账号）

# 2. 验证连接
tailscale status
# 应显示自身节点为 "active"

# 3. 获取 Tailscale IP
tailscale ip -4
# 记录输出，如 100.x.x.x
```

#### Node B（远程机器）

```bash
# Linux 安装
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up

# 或 Windows: 同 Node A

# 验证
tailscale status
tailscale ip -4
```

### 3.2 Phase 2: 连通性测试（10 分钟）

#### 从 Node A ping Node B

```powershell
# 用 Tailscale IP
ping <node-b-tailscale-ip>

# 期望：延迟 < 50ms（P2P 直连）或 < 200ms（DERP 中继）
```

#### 从 Node A SSH 到 Node B

```powershell
ssh user@<node-b-tailscale-ip>
# 期望：可连接
```

#### Tailscale 状态检查

```powershell
# 查看连接路径
tailscale status
# 关注 "relay" 字段：
#   direct = P2P 直连（最佳）
#   "derp-xxx" = DERP 中继（fallback）

# 查看详细网络路径
tailscale ping <node-b-tailscale-ip>
# 显示 via DERP 或 via direct
```

### 3.3 Phase 3: 稳定性测试（24 小时）

#### 长连接测试

```powershell
# 持续 ping 24 小时，记录丢包率
ping -t <node-b-tailscale-ip> > tailscale-ping.log

# 24 小时后分析
$pingLog = Get-Content tailscale-ping.log
$total = ($pingLog | Where-Object { $_ -match "Reply" }).Count
$lost = ($pingLog | Where-Object { $_ -match "Request timed out" }).Count
$lossRate = if ($total -gt 0) { [math]::Round($lost / ($total + $lost) * 100, 2) } else { 100 }
Write-Host "Packet loss: $lossRate% ($lost lost / $($total+$lost) total)"
```

**验收标准**：
- 丢包率 < 1%
- 平均延迟 < 100ms
- 无超过 5 分钟的断连

### 3.4 Phase 4: 带宽测试（10 分钟）

#### git push/pull 测试

```powershell
# 在 Node B 上 clone _kb（通过 Tailscale 访问 Node A 的 git server）
# 或通过 GitHub 中转（不经过 Tailscale，作为对照）

# 方案 A: Node A 开 git server
# Node A:
cd d:\xiangmu\_kb
git daemon --reuseaddr --base-path=d:\xiangmu --export-all --enable=receive-pack

# Node B:
git clone git://<node-a-tailscale-ip>/kb test-clone
cd test-clone
# 测量 clone 时间

# 方案 B: 通过 Tailscale SSH
git clone user@<node-a-tailscale-ip>:d:/xiangmu/_kb test-clone
```

**验收标准**：
- clone 54 页 KB（约 1MB）< 30 秒
- push 单次提交 < 10 秒

### 3.5 Phase 5: 中国大陆专项测试

#### DERP 中继可用性

```powershell
# 检查 DERP 服务器
tailscale netcheck
# 关注：
#   - Nearest DERP: 是否有亚洲节点（tok/hkg/sin）
#   - UDP: 是否可用（影响 P2P）
#   - IPv4/IPv6: 连接性

# 如果 DERP 只有海外节点（如 sfo/ord），中继延迟会很高
```

#### NAT 穿透测试

```powershell
# 检查 NAT 类型
tailscale debug netcheck

# 期望：NAT 类型为 Easy/Hard，非 Symmetric
# Symmetric NAT 会阻止 P2P，强制走 DERP
```

#### GFW 干扰检测

```powershell
# 测试 Tailscale 控制平面连通性
Test-NetConnection controlplane.tailscale.com -Port 443
# 期望：TcpTestSucceeded = True

# 测试 DERP 连通性
Test-NetConnection derp1.tailscale.com -Port 443
# 如果失败，DERP 中继不可用，P2P 失败时无法 fallback
```

---

## 4. 实测记录模板

### 4.1 测试结果记录

```
## Tailscale 实测记录

日期: YYYY-MM-DD
测试人: <name>
节点 A: <位置> <网络> <Tailscale IP>
节点 B: <位置> <网络> <Tailscale IP>

### Phase 1: 安装登录
- [ ] Node A 登录成功
- [ ] Node B 登录成功
- 耗时: X 分钟

### Phase 2: 连通性
- Ping 延迟: X ms
- 连接路径: direct / DERP
- DERP 节点: <location>

### Phase 3: 稳定性（24h）
- 丢包率: X%
- 平均延迟: X ms
- 最长断连: X 分钟
- 断连次数: X

### Phase 4: 带宽
- clone 时间: X 秒
- push 时间: X 秒

### Phase 5: 中国大陆专项
- netcheck 结果: <粘贴>
- NAT 类型: <type>
- controlplane 可达: 是/否
- DERP 可达: 是/否

### 结论
- [ ] 可用（满足远程 agent 接入需求）
- [ ] 不可用（原因: xxx）
- [ ] 有条件可用（需自建 DERP / 换方案）
```

---

## 5. 备选方案

如果 Tailscale 在中国大陆不可用：

| 方案 | 适用场景 | 配置复杂度 |
|------|----------|-----------|
| **自建 DERP** | Tailscale P2P 可用但官方 DERP 慢 | 中 |
| **frp** | 需要稳定中转 | 中 |
| **ZeroTier** | Tailscale 替代 | 低 |
| **WireGuard 手动** | 完全自控 | 高 |
| **GitHub 中转** | 无需 VPN，用 git push/pull | 最低（已实现） |

### 5.1 当前推荐

在 Tailscale 实测完成前，**继续使用 GitHub 中转方案**（已实现，见 [remote-access.md](remote-access.md)）：
- 远程 agent 通过 `remote-agent-bootstrap.ps1` clone _kb
- 写入后通过 `kb-safe-push.ps1` push 到 GitHub
- 其他 agent pull 获取更新

---

## 6. 自建 DERP 方案（如需）

如果官方 DERP 在中国大陆慢，可自建：

```bash
# 在海外 VPS 上
docker run -d --name derper --restart always \
  -p 443:443 \
  -v /var/run/tailscale/tailscaled.sock:/var/run/tailscale/tailscaled.sock \
  fredliang/derper

# 在 Tailscale ACL 中添加自定义 DERP
# 访问 https://login.tailscale.com/admin/acls
```

---

## 7. 相关文档

- [remote-access.md](remote-access.md) — 远程访问方案（GitHub 中转）
- [trae-web-scraper.md](trae-web-scraper.md) — Trae 网络抓取专员
- [flywheel-degradation.md](flywheel-degradation.md) — 降级方案
- `_meta/remote-agent-bootstrap.ps1` — 远程 agent 接入脚本
