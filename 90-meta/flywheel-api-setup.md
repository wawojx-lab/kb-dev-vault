---
type: index
title: flywheel LLM API Key 配置
source: P2-1 改进项
created: 2026-06-21
updated: 2026-06-21
confidence: stated
status: mature
tags: [meta, flywheel, api-key, configuration, llm]
---

# flywheel LLM API Key 配置

> 配置 flywheel 引擎的 LLM API Key，启用 kb compile/evolve 功能。
> 关联改进项：P2-1（flywheel LLM API Key 配置）
> 关联问题：E3（kb compile/evolve 不可用）/ E4（无 API Key 配置流程）

---

## 1. flywheel LLM 后端

flywheel 支持 8 种 LLM 后端：

| 后端 | 环境变量 | 用途 | 需要 API Key？ |
|------|----------|------|---------------|
| `anthropic`（默认） | `ANTHROPIC_API_KEY` | Claude API（推荐） | 是 |
| `openai` | `OPENAI_API_KEY` | OpenAI GPT | 是 |
| `gemini` | `GEMINI_API_KEY` | Google Gemini | 是 |
| `kimi` | `KIMI_API_KEY` | Moonshot Kimi | 是 |
| `qwen` | `QWEN_API_KEY` | 阿里通义千问 | 是 |
| `deepseek` | `DEEPSEEK_API_KEY` | DeepSeek | 是 |
| `zai` | `ZAI_API_KEY` | Z.ai | 是 |
| `ollama` | 无需 | 本地 Ollama | 否（本地） |

### 1.1 三层模型（tier）

flywheel 将 LLM 调用分为三层：

| Tier | 用途 | 默认模型（anthropic） |
|------|------|----------------------|
| `scan` | 快速扫描（轻量） | claude-haiku |
| `write` | 写入编译（中量） | claude-sonnet |
| `orchestrate` | 编排决策（重量） | claude-opus |

可通过 `KB_CLI_MODEL_SCAN/WRITE/ORCHESTRATE` 覆盖。

---

## 2. 配置方法

### 2.1 一键配置脚本

```powershell
# Anthropic（推荐）
.\flywheel-api-setup.ps1 -Backend anthropic -ApiKey "sk-ant-xxxxx"

# OpenAI
.\flywheel-api-setup.ps1 -Backend openai -ApiKey "sk-xxxxx"

# DeepSeek（国内可用）
.\flywheel-api-setup.ps1 -Backend deepseek -ApiKey "sk-xxxxx"

# 指定模型 + tier
.\flywheel-api-setup.ps1 -Backend anthropic -ApiKey "sk-ant-xxx" -Model claude-sonnet-4-6 -Tier write

# 查看当前配置
.\flywheel-api-setup.ps1 -Show

# 预览不写入
.\flywheel-api-setup.ps1 -Backend anthropic -ApiKey "sk-ant-xxx" -DryRun
```

### 2.2 手动配置

1. 复制 `.env.example` 为 `.env`：
   ```powershell
   Copy-Item "d:\xiangmu\_kb_flywheel\.env.example" "d:\xiangmu\_kb_flywheel\.env"
   ```

2. 编辑 `.env`，填入 API Key：
   ```
   ANTHROPIC_API_KEY=sk-ant-your-key-here
   KB_LLM_BACKEND=anthropic
   ```

3. 可选：覆盖模型 tier：
   ```
   CLAUDE_SCAN_MODEL=claude-haiku-4-5-20251001
   CLAUDE_WRITE_MODEL=claude-sonnet-4-6
   CLAUDE_ORCHESTRATE_MODEL=claude-opus-4-7
   ```

---

## 3. API Key 获取

| 后端 | 获取地址 | 费用 |
|------|----------|------|
| Anthropic | https://console.anthropic.com/ | 按 token 计费 |
| OpenAI | https://platform.openai.com/api-keys | 按 token 计费 |
| Google Gemini | https://aistudio.google.com/apikey | 有免费额度 |
| DeepSeek | https://platform.deepseek.com/ | 按 token 计费（国内） |
| 阿里通义 | https://dashscope.console.aliyun.com/ | 有免费额度 |
| Moonshot Kimi | https://platform.moonshot.cn/ | 按 token 计费 |

---

## 4. 验证

### 4.1 检查 flywheel 引擎

```powershell
.\flywheel-api-setup.ps1 -Show
```

输出应显示 `flywheel engine: OK`。

### 4.2 测试 kb compile

配置 API Key 后，测试 raw → wiki 编译：

```powershell
# 通过 MCP
kb_compile_scan

# 或通过 CLI
cd d:\xiangmu\_kb_flywheel
.venv\Scripts\python.exe -m kb.cli compile
```

### 4.3 测试 kb evolve

```powershell
# 通过 MCP
kb_evolve

# 或通过 CLI
.venv\Scripts\python.exe -m kb.cli evolve
```

---

## 5. 安全注意事项

1. **.env 不入 Git** — `_kb_flywheel/.gitignore` 应包含 `.env`
2. **API Key 脱敏** — `flywheel-api-setup.ps1 -Show` 自动脱敏显示
3. **密钥轮换** — 定期更换 API Key，重新运行 setup 脚本
4. **告警集成** — pre-commit hook 的 secret scan 会阻止含 API Key 的文件提交

### 5.1 检查 .gitignore

```powershell
# 确认 .env 在 .gitignore 中
Select-String -Path "d:\xiangmu\_kb_flywheel\.gitignore" -Pattern "^\.env$"
```

如果不在，添加：
```
.env
```

---

## 6. 降级模式

如果 API Key 未配置或失效，flywheel 降级模式见 [flywheel-degradation.md](flywheel-degradation.md)：

- `kb lint` / `kb stats` / `kb graph-viz` — 不需要 API Key，正常可用
- `kb compile` / `kb evolve` — 需要 API Key，降级模式下不可用
- pre-commit hook — 降级为 `wiki-validator.ps1`

---

## 7. 多后端切换

可随时切换后端（无需重启）：

```powershell
# 切换到 DeepSeek
.\flywheel-api-setup.ps1 -Backend deepseek -ApiKey "sk-xxxxx"

# 切换回 Anthropic
.\flywheel-api-setup.ps1 -Backend anthropic -ApiKey "sk-ant-xxxxx"

# 切换到本地 Ollama（无需 API Key）
.\flywheel-api-setup.ps1 -Backend ollama -ApiKey "dummy"
```

---

## 8. 故障排查

| 问题 | 原因 | 解决 |
|------|------|------|
| `kb compile` 报 401 | API Key 无效 | 重新获取 Key，运行 setup 脚本 |
| `kb compile` 报 429 | 超出速率限制 | 降低调用频率或升级套餐 |
| `flywheel engine: FAILED` | Python 环境损坏 | 重建 venv：`python -m venv .venv` |
| `.env not found` | 未配置 | 运行 setup 脚本 |
| `KB_LLM_BACKEND` 未生效 | .env 格式错误 | 检查无 `#` 注释 |

---

## 9. 相关文件

| 文件 | 用途 |
|------|------|
| `_meta/flywheel-api-setup.ps1` | 配置脚本 |
| `_kb_flywheel/.env.example` | 配置模板 |
| `_kb_flywheel/.env` | 实际配置（不入 Git） |
| `_kb/90-meta/flywheel-degradation.md` | 降级方案 |
| `_kb/90-meta/km-agent-workflow.md` | KB agent 工作流 |
