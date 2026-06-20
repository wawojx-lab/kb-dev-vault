#Requires -Version 5.1
# Pester v4 tests for kb-lock.ps1
# Run: Invoke-Pester -Path tests/kb-lock.Tests.ps1 -OutputFile test-results.xml -OutputFormat NUnitXml

$script:lockScript = "d:\xiangmu\_kb\90-meta\kb-lock.ps1"
$script:testLockFile = Join-Path $env:TEMP "test-kb-write.lock"

function Invoke-LockScript {
    param(
        [string]$Action = "status",
        [string]$Holder = "",
        [string]$Purpose = "",
        [int]$TtlMinutes = 15,
        [switch]$Force,
        [string]$LockFile = $script:testLockFile
    )
    $scriptArgs = @($Action)
    if ($Holder) { $scriptArgs += @("-Holder", $Holder) }
    if ($Purpose) { $scriptArgs += @("-Purpose", $Purpose) }
    if ($TtlMinutes -ne 15) { $scriptArgs += @("-TtlMinutes", $TtlMinutes) }
    if ($Force) { $scriptArgs += @("-Force") }
    $scriptArgs += @("-LockFile", $LockFile)

    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script:lockScript @scriptArgs
    return @{
        Output = $output -join "`n"
        ExitCode = $LASTEXITCODE
    }
}

Describe "kb-lock acquire" {
    BeforeEach {
        if (Test-Path $script:testLockFile) { Remove-Item $script:testLockFile -Force }
    }

    It "Should acquire lock when not held" {
        $result = Invoke-LockScript -Action acquire -Holder "test-agent" -Purpose "unit-test"
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "LOCK ACQUIRED"
        Test-Path $script:testLockFile | Should Be $true
    }

    It "should fail when lock already held" {
        Invoke-LockScript -Action acquire -Holder "agent-1" -Purpose "test"
        $result = Invoke-LockScript -Action acquire -Holder "agent-2" -Purpose "test"
        $result.ExitCode | Should Be 1
        $result.Output | Should Match "LOCKED by agent-1"
    }

    It "should require -Holder parameter" {
        $result = Invoke-LockScript -Action acquire -Purpose "test"
        $result.ExitCode | Should Be 2
        $result.Output | Should Match "ERROR.*Holder required"
    }

    It "should require -Purpose parameter" {
        $result = Invoke-LockScript -Action acquire -Holder "test"
        $result.ExitCode | Should Be 2
        $result.Output | Should Match "ERROR.*Purpose required"
    }

    It "should override expired lock" {
        Invoke-LockScript -Action acquire -Holder "old-agent" -Purpose "test" -TtlMinutes 0
        Start-Sleep -Seconds 1
        $result = Invoke-LockScript -Action acquire -Holder "new-agent" -Purpose "test"
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "Stale lock detected"
    }

    It "should force acquire with -Force" {
        Invoke-LockScript -Action acquire -Holder "agent-1" -Purpose "test"
        $result = Invoke-LockScript -Action acquire -Holder "agent-2" -Purpose "test" -Force
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "LOCK ACQUIRED by agent-2"
    }
}

Describe "kb-lock release" {
    BeforeEach {
        if (Test-Path $script:testLockFile) { Remove-Item $script:testLockFile -Force }
    }

    It "should release own lock" {
        Invoke-LockScript -Action acquire -Holder "test-agent" -Purpose "test"
        $result = Invoke-LockScript -Action release -Holder "test-agent"
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "LOCK RELEASED"
        Test-Path $script:testLockFile | Should Be $false
    }

    It "should not release others lock without -Force" {
        Invoke-LockScript -Action acquire -Holder "agent-1" -Purpose "test"
        $result = Invoke-LockScript -Action release -Holder "agent-2"
        $result.ExitCode | Should Be 1
        $result.Output | Should Match "LOCK held by agent-1"
        Test-Path $script:testLockFile | Should Be $true
    }

    It "should release others lock with -Force" {
        Invoke-LockScript -Action acquire -Holder "agent-1" -Purpose "test"
        $result = Invoke-LockScript -Action release -Holder "agent-2" -Force
        $result.ExitCode | Should Be 0
        Test-Path $script:testLockFile | Should Be $false
    }

    It "should handle release when no lock exists" {
        $result = Invoke-LockScript -Action release -Holder "test-agent"
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "No lock to release"
    }
}

Describe "kb-lock is-held" {
    BeforeEach {
        if (Test-Path $script:testLockFile) { Remove-Item $script:testLockFile -Force }
    }

    It "should return HELD (exit 0) when lock held" {
        Invoke-LockScript -Action acquire -Holder "test-agent" -Purpose "test"
        $result = Invoke-LockScript -Action is-held
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "HELD"
    }

    It "should return FREE (exit 1) when no lock" {
        $result = Invoke-LockScript -Action is-held
        $result.ExitCode | Should Be 1
        $result.Output | Should Match "FREE"
    }

    It "should return FREE when lock expired" {
        Invoke-LockScript -Action acquire -Holder "test-agent" -Purpose "test" -TtlMinutes 0
        Start-Sleep -Seconds 1
        $result = Invoke-LockScript -Action is-held
        $result.ExitCode | Should Be 1
        $result.Output | Should Match "FREE"
    }
}

Describe "kb-lock status" {
    BeforeEach {
        if (Test-Path $script:testLockFile) { Remove-Item $script:testLockFile -Force }
    }

    It "should show FREE when no lock" {
        $result = Invoke-LockScript -Action status
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "FREE"
    }

    It "should show HELD with details when lock held" {
        Invoke-LockScript -Action acquire -Holder "test-agent" -Purpose "test-purpose"
        $result = Invoke-LockScript -Action status
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "HELD by test-agent"
        $result.Output | Should Match "test-purpose"
    }

    It "should show EXPIRED when lock expired" {
        Invoke-LockScript -Action acquire -Holder "test-agent" -Purpose "test" -TtlMinutes 0
        Start-Sleep -Seconds 1
        $result = Invoke-LockScript -Action status
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "EXPIRED"
    }
}

Describe "kb-lock lock file format" {
    BeforeEach {
        if (Test-Path $script:testLockFile) { Remove-Item $script:testLockFile -Force }
    }

    It "should write valid JSON lock file" {
        Invoke-LockScript -Action acquire -Holder "test-agent" -Purpose "test"
        $content = Get-Content $script:testLockFile -Raw -Encoding UTF8
        $lock = $content | ConvertFrom-Json
        $lock.holder | Should Be "test-agent"
        $lock.purpose | Should Be "test"
        $lock.acquiredAt | Should Not Be $null
        $lock.expiresAt | Should Not Be $null
        $lock.pid | Should BeGreaterThan 0
    }
}

Describe "kb-lock invalid action" {
    It "should show usage for unknown action" {
        $result = Invoke-LockScript -Action "invalid-action"
        $result.ExitCode | Should Be 2
        $result.Output | Should Match "Usage:"
    }
}
