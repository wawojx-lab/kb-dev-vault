# 移动端远程访问实操指南

> 适用场景：手机访问 d:\xiangmu 工作区 + 手机远程控制 Windows 桌面
> 网络基础：Tailscale 100.x 内网（设备间 WireGuard 加密直连/P2P fallback 到 DERP）
> 本机信息：kktd @ 100.125.61.13（已登录）

---

## 当前状态（2026-06-21 10:45 实测）

| 节点 | Tailscale 状态 | Tailscale IP | 备注 |
|------|---------------|-------------|------|
| 本机 (kktd) | ✅ active | 100.125.61.13 | Windows，四川电信 |
| 手机 (ace-3) | ❌ offline | 100.66.140.112 | Android，22 天前在线 |
| DERP | Tokyo 188ms | - | 日本节点，fallback 可用 |
| 控制平面 | ✅ 可达 | - | controlplane.tailscale.com |

---

## 场景 A：手机访问 d:\xiangmu 工作区

### 原理

手机 Tailscale app → 加入同一账号 → 获得 100.x IP → 通过 SSH/终端执行 PowerShell 命令 → 间接操作 d:\xiangmu

### 步骤

#### 1. 本机：开启 SSH 服务（一次性）

本机 Windows 10/11 已自带 OpenSSH Server，但默认未启用。

```powershell
# 检查是否已安装
Get-WindowsCapability -Online | Where-Object Name -like 'OpenSSH*'

# 启用 SSH Server
Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0

# 启动服务并设为自动
Start-Service sshd
Set-Service -Name sshd -StartupType 'Automatic'

# 验证：监听 22 端口
Test-NetConnection -ComputerName 100.125.61.13 -Port 22
# 期望：TcpTestSucceeded = True
```

#### 2. 手机：安装 Tailscale + 终端 app

**必装 app**：
- Tailscale（iOS App Store / Android Google Play / 华为应用市场）
- 终端 app（推荐）：
  - iOS: **Termius**（免费，支持 SSH 密钥）
  - Android: **JuiceSSH**（免费，支持 SSH 密钥）

#### 3. 手机：登录 Tailscale

打开 Tailscale app → 登录（用 `wawojx@` 同一个账号，GitHub/Microsoft/Google 登录都行）→ 启用连接

登录成功后，app 会显示：
```
kktd  (this device)
ace-3  (your phone)
```

#### 4. 手机：SSH 连接到本机

在 Termius/JuiceSSH 里新建连接：
- **Host**: `100.125.61.13`
- **Port**: `22`
- **Username**: 你的 Windows 账号（运行 `whoami` 查看）
- **Auth**: Password（先用密码，后续可改 SSH 密钥）

连接后，你会看到 PowerShell 提示符，可以直接：
```powershell
cd d:\xiangmu
ls
git status
# 任何 PowerShell 命令都能跑
```

#### 5. 手机：访问文件

##### 方案 A：通过 SSH 跑命令（最简）

```bash
# 列文件
ls d:/xiangmu/_kb/wiki/

# 读文件
cat d:/xiangmu/_kb/90-meta/index.md

# 编辑文件（用 vim/nano，但手机操作不便）
```

##### 方案 B：SFTP 文件管理（推荐）

Termius / JuiceSSH 都支持 SFTP，可以浏览/上传/下载文件：

Termius：连接右侧的 SFTP 按钮 → 浏览 d:\xiangmu 树形结构
JuiceSSH：连接 → 顶部菜单 → SFTP

#### 6. 关键操作清单

| 你想做的 | 手机端操作 |
|---------|-----------|
| 跑 health-dashboard | `pwsh -File d:/xiangmu/_meta/health-dashboard.ps1` |
| 推 git | `pwsh -File d:/xiangmu/_kb/90-meta/kb-safe-push.ps1 -CommitMsg "..." -Holder "phone"` |
| 看日志 | `cat` 或 SFTP 下载查看 |
| 编辑 KB | SFTP 下载 → 本地编辑 → SFTP 上传 |
| 看 git diff | `cd d:/xiangmu/_kb && git diff` |

---

## 场景 B：手机远程控制 Windows 桌面

### 原理

本机开启远程桌面服务 → 手机 RDP 客户端连入 → 看到完整 Windows 桌面，像坐在电脑前一样操作

### 步骤

#### 1. 本机：开启远程桌面

```powershell
# 启用远程桌面
Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0

# 允许远程桌面通过防火墙
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# 或者用 GUI：设置 → 系统 → 远程桌面 → 启用
```

#### 2. 本机：检查监听

```powershell
Test-NetConnection -ComputerName 100.125.61.13 -Port 3389
# 期望：TcpTestSucceeded = True
```

#### 3. 手机：装 RDP 客户端

**iOS**: Microsoft Remote Desktop（免费，App Store）
**Android**: Microsoft Remote Desktop 或 RD Client（免费，Google Play）

#### 4. 手机：添加远程桌面连接

- **PC name**: `100.125.61.13:3389`（Tailscale IP + 远程桌面端口）
- **User account**: 添加你的 Windows 账号
- **Display**: 任意分辨率（手机建议 1280x720）

连接后会看到完整 Windows 桌面，可以双击 `d:\xiangmu` 文件夹浏览。

#### 5. 优化体验

- 启用 Tailscale MagicDNS（如果未启用）：访问 Tailscale 时用 `kktd.tailnet-xxxx.ts.net` 代替 IP
- 调整 RDP 画质：手机端 RDP 设置里选 "Low bandwidth" 模式
- 快捷键：手机 RDP 客户端有"键盘"按钮，可以弹全键盘

---

## 安全性补充

### Tailscale ACL（访问控制）

默认情况下，同一账号的设备能互相访问任何端口。

如果你想限制手机只能访问特定端口：
- 访问 https://login.tailscale.com/admin/acls
- 添加规则：
  ```json
  {
    "acls": [
      {"action": "accept", "src": ["tag:phone"], "dst": ["tag:desktop:22,3389"]}
    ]
  }
  ```

### SSH 密钥认证（推荐替代密码）

```powershell
# 本机生成密钥
ssh-keygen -t ed25519

# 把公钥写入 authorized_keys
mkdir $HOME\.ssh -Force
Get-Content $HOME\.ssh\id_ed25519.pub | Out-File $HOME\.ssh\authorized_keys -Encoding ascii
icacls $HOME\.ssh\authorized_keys /inheritance:r /grant:r "$($env:USERNAME):(R)"

# 手机端：把私钥（id_ed25519）导入 Termius/JuiceSSH
```

---

## 中国大陆实测

### 当前已知
- DERP Tokyo 188ms（fallback 延迟，可接受）
- UDP 支持：✅（P2P 穿透可能成功）
- 公网 IP：四川电信

### 你要测试的
1. 手机连上 Tailscale 后，看是 `direct` 还是 `relay`
2. 跑一次 git push 看延迟
3. 长时间挂着看稳定性

### 记录表

```
## Tailscale 移动端实测记录

日期: 2026-06-21
本机: kktd @ 100.125.61.13
手机: ace-3 @ 100.66.140.112

### Phase 1: 手机重连
- [ ] Tailscale app 打开并连接
- [ ] 显示 active
- [ ] 耗时: ___ 秒

### Phase 2: SSH 连通性
- 连接路径: direct / DERP
- SSH 延迟: ___ ms
- DERP 节点: Tokyo (188ms)

### Phase 3: 实操验证
- [ ] ls d:/xiangmu/_kb/wiki/ 成功
- [ ] git status 成功
- [ ] pwsh -File health-dashboard.ps1 成功

### Phase 4: 远程桌面（如启用）
- RDP 延迟: ___ ms
- 流畅度: 流畅 / 一般 / 卡顿

### 结论
- [ ] 可用（满足移动办公需求）
- [ ] 有条件可用（需优化）
- [ ] 不可用（原因: ___）
```

---

## 相关文档

- [tailscale-test-plan.md](tailscale-test-plan.md) — 完整 5 阶段实测方案
- [remote-access.md](remote-access.md) — 远程访问总览
- `_meta/remote-agent-bootstrap.ps1` — 远程 agent 接入脚本（GitHub 中转方案）
