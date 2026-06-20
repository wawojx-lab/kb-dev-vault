#Requires -Version 5.1
# Run all Pester tests and report summary
$ErrorActionPreference = "Stop"

Write-Host "=== KB Pester Test Suite ===" -ForegroundColor Cyan
Write-Host ""

Set-Location "d:\xiangmu\_kb"

# Ensure Pester
$pesterModule = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
if (-not $pesterModule) {
    Write-Host "Installing Pester..." -ForegroundColor Yellow
    Install-Module -Name Pester -Force -SkipPublisherCheck -Scope CurrentUser
    $pesterModule = Get-Module -ListAvailable -Name Pester | Sort-Object Version -Descending | Select-Object -First 1
}

Write-Host ("Pester version: {0}" -f $pesterModule.Version) -ForegroundColor Gray
Import-Module Pester -MinimumVersion 4.0

# Run tests (v4 compatible)
$pesterParams = @{
    Path    = "tests"
    PassThru = $true
    OutputFile = "test-results.xml"
    OutputFormat = "NUnitXml"
}
$results = Invoke-Pester @pesterParams

# Summary
Write-Host ""
Write-Host "=== Test Summary ===" -ForegroundColor Cyan
Write-Host ("Total:   {0}" -f $results.TotalCount)
Write-Host ("Passed:  {0}" -f $results.PassedCount) -ForegroundColor Green
Write-Host ("Failed:  {0}" -f $results.FailedCount) -ForegroundColor Red
Write-Host ("Skipped: {0}" -f $results.SkippedCount) -ForegroundColor Yellow
Write-Host ("Duration: {0:N1}s" -f $results.Duration.TotalSeconds)

if ($results.FailedCount -gt 0) {
    Write-Host ""
    Write-Host "=== Failed Tests ===" -ForegroundColor Red
    foreach ($r in $results.Tests) {
        if ($r.Result -eq "Failed") {
            Write-Host ("  FAIL: {0}" -f $r.Name) -ForegroundColor Red
        }
    }
    exit 1
}

Write-Host ""
Write-Host "All tests passed!" -ForegroundColor Green
exit 0
