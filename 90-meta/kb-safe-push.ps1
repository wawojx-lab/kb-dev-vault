param(
    [Parameter(Mandatory=$true)]
    [string]$CommitMsg,
    [Parameter(Mandatory=$true)]
    [string]$Holder,
    [string]$Repo = "d:\xiangmu\_kb",
    [string]$Remote = "origin",
    [string]$Branch = "main",
    [int]$MaxRetries = 2,
    [switch]$SkipLock,
    [switch]$DryRun
)

# kb-safe-push.ps1 - Safe push wrapper for _kb/ concurrent writes
# Flow: acquire lock -> commit -> pull --rebase -> push -> release lock
# Solves H1/H2/H3: no lock / push conflict / no coordinator

if ($MyInvocation.CommandOrigin -eq 'Runspace' -or [Console]::OutputEncoding.WebName -eq 'utf-8') {
    & {

$exitCode = 0
$script:lockAcquired = $false

function Invoke-Git {
    param([string]$GitCmd, [string]$Description, [switch]$AllowFail)
    Write-Host ("[git] {0}: {1}" -f $Description, $GitCmd) -ForegroundColor Cyan
    $output = & git -C $Repo @($GitCmd -split ' ') 2>&1
    $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Gray }
    if ($LASTEXITCODE -ne 0 -and -not $AllowFail) {
        Write-Host ("[git] FAILED: {0}" -f $Description) -ForegroundColor Red
        return @{ success = $false; output = $output }
    }
    return @{ success = ($LASTEXITCODE -eq 0); output = $output }
}

function Release-Lock-If-Held {
    if ($script:lockAcquired) {
        Write-Host "[lock] Releasing lock..." -ForegroundColor Cyan
        & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "d:\xiangmu\_kb\90-meta\kb-lock.ps1" release -Holder $Holder -Force
        $script:lockAcquired = $false
    }
}

try {
    # === Step 1: Acquire lock ===
    if (-not $SkipLock) {
        Write-Host "=== Step 1: Acquire lock ===" -ForegroundColor Yellow
        $lockResult = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File "d:\xiangmu\_kb\90-meta\kb-lock.ps1" acquire -Holder $Holder -Purpose "push: $CommitMsg"
        $lockExit = $LASTEXITCODE
        Write-Host $lockResult
        if ($lockExit -ne 0) {
            Write-Host "[lock] Failed to acquire lock (exit $lockExit). Aborting." -ForegroundColor Red
            exit 1
        }
        $script:lockAcquired = $true
    } else {
        Write-Host "[lock] Skipped (-SkipLock)" -ForegroundColor Yellow
    }

    # === Step 2: git add ===
    Write-Host ""
    Write-Host "=== Step 2: git add ===" -ForegroundColor Yellow
    if (-not $DryRun) {
        $addResult = Invoke-Git -GitCmd "add -A" -Description "stage all changes"
        if (-not $addResult.success) {
            Write-Host "git add failed" -ForegroundColor Red
            $exitCode = 1
            Release-Lock-If-Held
            exit $exitCode
        }
    } else {
        Write-Host "  [dry-run] skipped git add"
    }

    # === Step 3: git commit ===
    Write-Host ""
    Write-Host "=== Step 3: git commit ===" -ForegroundColor Yellow
    if (-not $DryRun) {
        # Check if there's anything to commit
        $status = & git -C $Repo status --porcelain 2>&1
        if (-not $status) {
            Write-Host "  Nothing to commit (working tree clean)" -ForegroundColor Yellow
            Release-Lock-If-Held
            exit 0
        }

        $commitResult = Invoke-Git -GitCmd "commit -m `"$CommitMsg`"" -Description "create commit"
        if (-not $commitResult.success) {
            Write-Host "git commit failed (maybe pre-commit hook blocked it)" -ForegroundColor Red
            $exitCode = 1
            Release-Lock-If-Held
            exit $exitCode
        }
    } else {
        Write-Host "  [dry-run] skipped git commit: $CommitMsg"
    }

    # === Step 4: git pull --rebase ===
    Write-Host ""
    Write-Host "=== Step 4: git pull --rebase ===" -ForegroundColor Yellow
    $retryCount = 0
    $rebaseSuccess = $false
    while ($retryCount -le $MaxRetries) {
        if ($DryRun) {
            Write-Host "  [dry-run] skipped git pull --rebase"
            $rebaseSuccess = $true
            break
        }
        $pullResult = Invoke-Git -GitCmd "pull --rebase $Remote $Branch" -Description "rebase on remote" -AllowFail
        if ($pullResult.success) {
            $rebaseSuccess = $true
            break
        }
        # Check for conflict markers
        $conflictFiles = & git -C $Repo diff --name-only --diff-filter=U 2>&1
        if ($conflictFiles) {
            Write-Host "[conflict] Files in conflict:" -ForegroundColor Red
            $conflictFiles | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            Write-Host "[conflict] Aborting rebase. Manual resolution required." -ForegroundColor Red
            & git -C $Repo rebase --abort 2>&1 | Out-Null
            $exitCode = 2
            break
        }
        $retryCount++
        if ($retryCount -le $MaxRetries) {
            Write-Host "[retry] Pull failed, retrying ($retryCount/$MaxRetries)..." -ForegroundColor Yellow
            Start-Sleep -Seconds 5
        }
    }
    if (-not $rebaseSuccess -and -not $DryRun) {
        Write-Host "Pull --rebase failed after $MaxRetries retries" -ForegroundColor Red
        Release-Lock-If-Held
        exit $exitCode
    }

    # === Step 5: git push ===
    Write-Host ""
    Write-Host "=== Step 5: git push ===" -ForegroundColor Yellow
    $pushRetry = 0
    $pushSuccess = $false
    while ($pushRetry -le $MaxRetries) {
        if ($DryRun) {
            Write-Host "  [dry-run] skipped git push"
            $pushSuccess = $true
            break
        }
        $pushResult = Invoke-Git -GitCmd "push $Remote $Branch" -Description "push to remote" -AllowFail
        if ($pushResult.success) {
            $pushSuccess = $true
            break
        }
        $pushRetry++
        if ($pushRetry -le $MaxRetries) {
            Write-Host "[retry] Push failed, retrying ($pushRetry/$MaxRetries)..." -ForegroundColor Yellow
            # Re-pull before retry
            Invoke-Git -GitCmd "pull --rebase $Remote $Branch" -Description "re-pull before push retry" -AllowFail | Out-Null
            Start-Sleep -Seconds 5
        }
    }
    if (-not $pushSuccess -and -not $DryRun) {
        Write-Host "Push failed after $MaxRetries retries" -ForegroundColor Red
        $exitCode = 3
    }

    # === Step 6: Release lock ===
    Write-Host ""
    Write-Host "=== Step 6: Release lock ===" -ForegroundColor Yellow
    Release-Lock-If-Held

    # === Summary ===
    Write-Host ""
    Write-Host "=== Summary ===" -ForegroundColor Green
    if ($exitCode -eq 0) {
        Write-Host "Result: SUCCESS" -ForegroundColor Green
        if (-not $DryRun) {
            $lastCommit = & git -C $Repo log -1 --format="%h %s" 2>&1
            Write-Host "Last commit: $lastCommit"
        }
    } else {
        Write-Host "Result: FAILED (exit $exitCode)" -ForegroundColor Red
    }

    exit $exitCode

} catch {
    Write-Host ("FATAL: $_") -ForegroundColor Red
    Release-Lock-If-Held
    exit 99
}

    }
    return
}

# ANSI mode: re-launch as UTF-8
$utf8 = New-Object System.Text.UTF8Encoding $True
$content = [System.IO.File]::ReadAllText($PSCommandPath, $utf8)
$tempPath = [System.IO.Path]::GetTempFileName() + '.ps1'
[System.IO.File]::WriteAllText($tempPath, $content, $utf8)
$argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $tempPath, '-CommitMsg', $CommitMsg, '-Holder', $Holder)
if ($Repo -ne 'd:\xiangmu\_kb') { $argList += '-Repo'; $argList += $Repo }
if ($Remote -ne 'origin') { $argList += '-Remote'; $argList += $Remote }
if ($Branch -ne 'main') { $argList += '-Branch'; $argList += $Branch }
if ($MaxRetries -ne 2) { $argList += '-MaxRetries'; $argList += $MaxRetries }
if ($SkipLock) { $argList += '-SkipLock' }
if ($DryRun) { $argList += '-DryRun' }
& powershell.exe @argList
$exitCode = $LASTEXITCODE
Remove-Item $tempPath -Force
exit $exitCode
