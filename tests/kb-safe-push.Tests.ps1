# Pester tests for kb-safe-push.ps1
# Tests DryRun mode and parameter handling (no real git operations)
# Pester v4 syntax

$script:pushScript = "d:\xiangmu\_kb\90-meta\kb-safe-push.ps1"
$script:testRepo = Join-Path $env:TEMP "test-kb-safe-push-repo"

function Invoke-PushScript {
    param(
        [string]$CommitMsg = "test commit",
        [string]$Holder = "test-agent",
        [string]$Repo = $script:testRepo,
        [switch]$DryRun,
        [switch]$SkipLock
    )
    $scriptArgs = @("-CommitMsg", $CommitMsg, "-Holder", $Holder, "-Repo", $Repo)
    if ($DryRun) { $scriptArgs += "-DryRun" }
    if ($SkipLock) { $scriptArgs += "-SkipLock" }
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script:pushScript @scriptArgs
    return @{ Output = $output -join "`n"; ExitCode = $LASTEXITCODE }
}

Describe "kb-safe-push parameter validation" {
    It "should require CommitMsg parameter" {
        $result = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script:pushScript -Holder "test" 2>&1
        $result -join "`n" | Should Match "missing mandatory parameters"
    }

    It "should require Holder parameter" {
        $result = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script:pushScript -CommitMsg "test" 2>&1
        $result -join "`n" | Should Match "missing mandatory parameters"
    }

    It "should accept default Repo value" {
        # DryRun with default repo should at least start (may fail on lock, but param accepted)
        $result = Invoke-PushScript -CommitMsg "test" -Holder "test-agent" -Repo $script:testRepo -DryRun -SkipLock
        $result.ExitCode | Should Be 0
    }
}

Describe "kb-safe-push DryRun mode" {
    BeforeEach {
        # Create a temporary git repo
        if (Test-Path $script:testRepo) {
            Remove-Item $script:testRepo -Recurse -Force
        }
        New-Item -ItemType Directory -Path $script:testRepo -Force | Out-Null
        & git init $script:testRepo 2>&1 | Out-Null
        & git -C $script:testRepo config user.email "test@test.com"
        & git -C $script:testRepo config user.name "test"
        "test content" | Out-File "$script:testRepo\test.txt"
    }

    AfterEach {
        if (Test-Path $script:testRepo) {
            Remove-Item $script:testRepo -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "should complete successfully in DryRun mode with SkipLock" {
        $result = Invoke-PushScript -CommitMsg "dry run test" -Holder "test-agent" -DryRun -SkipLock
        $result.ExitCode | Should Be 0
        $result.Output | Should Match "dry-run"
    }

    It "should skip git add in DryRun mode" {
        $result = Invoke-PushScript -CommitMsg "dry run test" -Holder "test-agent" -DryRun -SkipLock
        $result.Output | Should Match "skipped git add"
    }

    It "should skip git commit in DryRun mode" {
        $result = Invoke-PushScript -CommitMsg "dry run test" -Holder "test-agent" -DryRun -SkipLock
        $result.Output | Should Match "skipped git commit"
    }

    It "should skip git pull in DryRun mode" {
        $result = Invoke-PushScript -CommitMsg "dry run test" -Holder "test-agent" -DryRun -SkipLock
        $result.Output | Should Match "skipped git pull"
    }

    It "should skip git push in DryRun mode" {
        $result = Invoke-PushScript -CommitMsg "dry run test" -Holder "test-agent" -DryRun -SkipLock
        $result.Output | Should Match "skipped git push"
    }

    It "should report SUCCESS in DryRun mode" {
        $result = Invoke-PushScript -CommitMsg "dry run test" -Holder "test-agent" -DryRun -SkipLock
        $result.Output | Should Match "SUCCESS"
    }
}

Describe "kb-safe-push flow steps" {
    BeforeEach {
        if (Test-Path $script:testRepo) {
            Remove-Item $script:testRepo -Recurse -Force
        }
        New-Item -ItemType Directory -Path $script:testRepo -Force | Out-Null
        & git init $script:testRepo 2>&1 | Out-Null
        & git -C $script:testRepo config user.email "test@test.com"
        & git -C $script:testRepo config user.name "test"
        "test content" | Out-File "$script:testRepo\test.txt"
    }

    AfterEach {
        if (Test-Path $script:testRepo) {
            Remove-Item $script:testRepo -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "should execute all 6 steps in DryRun mode" {
        $result = Invoke-PushScript -CommitMsg "step test" -Holder "test-agent" -DryRun -SkipLock
        # Step 1 is lock (skipped), steps 2-6 should appear
        $result.Output | Should Match "Step 2"
        $result.Output | Should Match "Step 3"
        $result.Output | Should Match "Step 4"
        $result.Output | Should Match "Step 5"
        $result.Output | Should Match "Step 6"
    }

    It "should show lock skipped message with SkipLock" {
        $result = Invoke-PushScript -CommitMsg "skip lock test" -Holder "test-agent" -DryRun -SkipLock
        $result.Output | Should Match "Skipped"
    }
}

Describe "kb-safe-push exit codes" {
    BeforeEach {
        if (Test-Path $script:testRepo) {
            Remove-Item $script:testRepo -Recurse -Force
        }
        New-Item -ItemType Directory -Path $script:testRepo -Force | Out-Null
        & git init $script:testRepo 2>&1 | Out-Null
        & git -C $script:testRepo config user.email "test@test.com"
        & git -C $script:testRepo config user.name "test"
        "test content" | Out-File "$script:testRepo\test.txt"
    }

    AfterEach {
        if (Test-Path $script:testRepo) {
            Remove-Item $script:testRepo -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "should exit 0 on successful DryRun" {
        $result = Invoke-PushScript -CommitMsg "exit test" -Holder "test-agent" -DryRun -SkipLock
        $result.ExitCode | Should Be 0
    }
}
