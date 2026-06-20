---
type: index
title: 远程接入方案（step 6）
source: 'Trae 评估 + Git remote 实测'
created: 2026-06-20
updated: 2026-06-20
confidence: stated
status: mature
tags: [meta, remote, git, tailscale, syncthing]
---

# 远程接入方案

> 让 `_kb/` 知识库可被远程设备/其他智能体访问。
> **2026-06-20 落地**：Git remote 主方案已启用（kb-dev-vault 私有仓，15 commits）。

## 三方案对比

| 维度 | Git remote（主） | Tailscale（备） | Syncthing（不推荐） |
|------|------------------|-----------------|---------------------|
| 原理 | GitHub 私有仓托管 | VPN 局域网 | P2P 文件同步 |
| 实时性 | 手动 push/pull | 实时（局域网内） | 准实时（秒级） |
| 冲突处理 | Git merge/rebase | 无（单端写） | 文件级冲突文件 |
| 离线访问 | 否（需 pull） | 否（需在线） | 是（本地副本） |
| 中国大陆稳定性 | 中（GitHub 偶尔抖动） | 低（VPN 干扰） | 中（P2P 打洞不稳） |
| 配置复杂度 | 低（git clone） | 中（装客户端+登录） | 中（装+配共享目录） |
| 多设备支持 | 无限 | 无限（同网络） | 有限（NAT 穿透） |
| 安全性 | 高（SSH+私有仓） | 高（WireGuard） | 中（自签证书） |
| 适合场景 | 异步协作、版本历史 | 实时编辑、低延迟 | 不适合 md 并发编辑 |

**结论**：Git remote 作为主方案（已落地），Tailscale 作为低延迟备选（未启用），Syncthing 不推荐（md 并发编辑冲突风险高）。

## 主方案：Git remote（已落地）

### 仓库信息
- **远程**：`https://github.com/wawojx-lab/kb-dev-vault`（私有仓）
- **本地**：`d:\xiangmu\_kb\`
- **分支**：`main`
- **最新 commit**：`f5990cc`（2026-06-20）
- **总 commits**：16

### 远程设备接入步骤

#### 1. 前置条件
- 远程设备安装 Git
- 远程设备有 GitHub 账号且被添加为仓库协作者（或用相同账号）

#### 2. Clone 仓库
```bash
git clone https://github.com/wawojx-lab/kb-dev-vault.git _kb
cd _kb
```

#### 3. 配置 flywheel（可选，用于 lint/stats）
```bash
# 克隆 flywheel 引擎
git clone <flywheel-repo> _kb_flywheel
cd _kb_flywheel
python -m venv .venv
.venv\Scripts\activate  # Windows
# source .venv/bin/activate  # Linux/Mac
pip install -e .

# 设置环境变量
set KB_PROJECT_ROOT=<path-to-_kb>
set PYTHONPATH=<path-to-_kb_flywheel>\src
```

#### 4. 日常同步
```bash
# 拉取最新（开始工作前）
git pull origin main

# 推送修改（结束工作后）
git add .
git commit -m "feat(kb): <描述>"
git push origin main
```

#### 5. 冲突处理
```bash
# 拉取时冲突
git pull origin main
# 若冲突，手动解决后
git add .
git commit -m "merge: resolve conflicts"
git push origin main
```

### 自动推送（可选）

在 `_kb_flywheel\kb-daily.ps1` 末尾追加自动 commit + push（每日维护后）：
```powershell
# Auto commit + push (optional, uncomment to enable)
# cd d:\xiangmu\_kb
# git add .
# git commit -m "chore(kb): daily auto-maintenance $today"
# git push origin main
```

> 默认不启用自动推送，避免意外提交半成品。手动推送更可控。

## 备选方案：Tailscale（未启用）

### 适用场景
- 需要实时编辑（低延迟）
- Git push/pull 延迟不可接受
- 多设备在同一 Tailscale 网络内

### 配置步骤（如需启用）
1. 安装 Tailscale 客户端（https://tailscale.com/download）
2. 登录 Tailscale 账号
3. 获取本机 Tailscale IP（`tailscale ip -4`）
4. 远程设备同样安装+登录
5. 远程设备通过 Tailscale IP 访问 `_kb/`（需共享目录或 SMB）

### 风险
- 中国大陆 Tailscale 连接不稳定（DERP 服务器在海外）
- 可能需要自建 DERP 服务器中转
- 不提供版本历史

## 不推荐方案：Syncthing

### 不推荐原因
- md 文件并发编辑时产生 `.sync-conflict-*` 冲突文件
- 无版本历史（只有文件级快照）
- NAT 穿透不稳定
- 与 Git remote 功能重叠且不如 Git 可靠

## 远程智能体接入

远程智能体（非本地 5 agent）访问 `_kb/` 的方式：

### 方式 1：Git clone（推荐）
```bash
git clone https://github.com/wawojx-lab/kb-dev-vault.git _kb
# 智能体直接读写本地文件
# 工作结束后 git push
```

### 方式 2：GitHub API（只读）
- 通过 GitHub API 读取文件内容
- 适合不需要写入的智能体
- 受 GitHub API 速率限制

### 方式 3：flywheel MCP 远程（未来）
- flywheel MCP 支持 SSE/HTTP 传输（需配置）
- 远程智能体通过 MCP 协议访问
- 当前未配置，待需求驱动

## 关联

- [知识管家流程](km-agent-workflow.md) — 含 flywheel 工具调用约定
- [AI 工具链 MOC](moc-ai-toolchain.md) — 智能体/规范/MCP 导航
- [index.md](index.md) — 知识库总索引
