# KB 测试套件

> Pester 测试，验证 _kb 工具链的正确性。
> 关联文档: [../_meta/rules/testing.md](../_meta/rules/testing.md)

## 运行测试

### 前置条件

```powershell
# 安装 Pester
Install-Module -Name Pester -MinimumVersion 5.5 -Force -SkipPublisherCheck
```

### 运行所有测试

```powershell
cd d:\xiangmu\_kb
Invoke-Pester -Path tests/ -Output Detailed
```

### 运行单个测试文件

```powershell
Invoke-Pester -Path tests/kb-lock.Tests.ps1 -Output Detailed
```

### 运行并生成覆盖率报告

```powershell
Invoke-Pester -Path tests/ -CodeCoverage 90-meta/*.ps1 -CodeCoverageOutputFile coverage.xml -Output Detailed
```

## 测试清单

| 测试文件 | 被测脚本 | 测试数 | 覆盖功能 |
|----------|----------|--------|----------|
| kb-lock.Tests.ps1 | kb-lock.ps1 | 19 | acquire/release/is-held/status/JSON 格式/过期锁/强制释放 |
| wiki-validator.Tests.ps1 | wiki-validator.ps1 | 6 | 单文件校验/全量扫描/环检测 |

## 测试维度

### kb-lock.ps1
- acquire: 正常获取/已锁定/缺参数/过期锁/强制获取
- release: 释放自己的锁/不能释放他人的锁/强制释放/无锁释放
- is-held: 持有/未持有/过期
- status: FREE/HELD/EXPIRED
- 文件格式: JSON 有效性/字段完整性
- 异常: 未知 action

### wiki-validator.ps1
- 单文件: 合法页面/缺 frontmatter/无效 type/缺必填字段
- 全量: 扫描所有页面
- 环检测: 简单环/无环

## CI 集成

测试在 GitHub Actions CI 中自动运行（见 `.github/workflows/ci.yml`）。

## 待补充测试

| 脚本 | 优先级 | 状态 |
|------|--------|------|
| kb-safe-push.ps1 | P0 | 待补 |
| index-generator.ps1 | P1 | 待补 |
| moc-generator.ps1 | P1 | 待补 |
| health-dashboard.ps1 | P1 | 待补 |
| doc-sync-check.ps1 | P2 | 待补 |
| alert.ps1 | P2 | 待补 |
| cost-tracker.ps1 | P2 | 待补 |
