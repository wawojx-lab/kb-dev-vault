param(
    [Parameter(Position=0)]
    [string]$Action = "status",
    [string]$Holder = "",
    [string]$Purpose = "",
    [int]$TtlMinutes = 15,
    [switch]$Force,
    [string]$LockFile = "d:\xiangmu\_kb\.git\kb-write.lock"
)

# kb-lock.ps1 - File lock for concurrent _kb/ writes
# Actions: acquire | release | is-held | status
# Lock file: d:\xiangmu\_kb\.git\kb-write.lock (in .git/, auto-gitignored)
# TTL: 15 min default (prevents deadlock if agent crashes)

if ($MyInvocation.CommandOrigin -eq 'Runspace' -or [Console]::OutputEncoding.WebName -eq 'utf-8') {
    & {

function Get-LockInfo {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $null }
    try {
        $content = Get-Content $Path -Raw -Encoding UTF8
        return $content | ConvertFrom-Json
    } catch {
        return $null
    }
}

function Test-LockExpired {
    param($LockInfo)
    if (-not $LockInfo) { return $true }
    if (-not $LockInfo.expiresAt) { return $true }
    try {
        $exp = [DateTime]::Parse($LockInfo.expiresAt)
        return ([DateTime]::Now -gt $exp)
    } catch {
        return $true
    }
}

function Write-Lock {
    param([string]$Path, [string]$HolderName, [string]$PurposeText, [int]$TtlMin)

    $now = [DateTime]::Now
    $expires = $now.AddMinutes($TtlMin)
    $procId = $PID

    $lockObj = [PSCustomObject]@{
        holder      = $HolderName
        acquiredAt  = $now.ToString("o")
        expiresAt   = $expires.ToString("o")
        purpose     = $PurposeText
        pid         = $procId
    }

    $json = $lockObj | ConvertTo-Json -Compress
    [System.IO.File]::WriteAllText($Path, $json, (New-Object System.Text.UTF8Encoding $False))
    return $lockObj
}

function Remove-Lock {
    param([string]$Path)
    if (Test-Path $Path) {
        Remove-Item $Path -Force
        return $true
    }
    return $false
}

# === Main ===
$exitCode = 0

switch ($Action.ToLower()) {
    "acquire" {
        if (-not $Holder) {
            Write-Host "ERROR: -Holder required for acquire" -ForegroundColor Red
            exit 2
        }
        if (-not $Purpose) {
            Write-Host "ERROR: -Purpose required for acquire" -ForegroundColor Red
            exit 2
        }

        $existing = Get-LockInfo -Path $LockFile
        if ($existing -and -not (Test-LockExpired -LockInfo $existing) -and -not $Force) {
            $remaining = ([DateTime]::Parse($existing.expiresAt) - [DateTime]::Now).TotalMinutes
            Write-Host ("LOCKED by {0} (expires in {1:N1} min)" -f $existing.holder, $remaining) -ForegroundColor Yellow
            Write-Host ("  purpose: {0}" -f $existing.purpose)
            Write-Host ("  acquired: {0}" -f $existing.acquiredAt)
            $exitCode = 1
        } else {
            if ($existing -and (Test-LockExpired -LockInfo $existing)) {
                Write-Host ("Stale lock detected (expired {0}), overriding" -f $existing.expiresAt) -ForegroundColor Yellow
            }
            $lock = Write-Lock -Path $LockFile -HolderName $Holder -PurposeText $Purpose -TtlMin $TtlMinutes
            Write-Host ("LOCK ACQUIRED by {0}" -f $Holder) -ForegroundColor Green
            Write-Host ("  expires: {0}" -f $lock.expiresAt)
            Write-Host ("  purpose: {0}" -f $Purpose)
            $exitCode = 0
        }
    }

    "release" {
        $existing = Get-LockInfo -Path $LockFile
        if (-not $existing) {
            Write-Host "No lock to release" -ForegroundColor Yellow
            $exitCode = 0
        } elseif ($existing.holder -ne $Holder -and -not $Force) {
            Write-Host ("LOCK held by {0}, not you ({1}). Use -Force to override." -f $existing.holder, $Holder) -ForegroundColor Red
            $exitCode = 1
        } else {
            Remove-Lock -Path $LockFile | Out-Null
            Write-Host "LOCK RELEASED" -ForegroundColor Green
            $exitCode = 0
        }
    }

    "is-held" {
        $existing = Get-LockInfo -Path $LockFile
        if ($existing -and -not (Test-LockExpired -LockInfo $existing)) {
            Write-Host "HELD"
            $exitCode = 0
        } else {
            Write-Host "FREE"
            $exitCode = 1
        }
    }

    "status" {
        $existing = Get-LockInfo -Path $LockFile
        if (-not $existing) {
            Write-Host "Lock status: FREE (no lock file)" -ForegroundColor Green
        } elseif (Test-LockExpired -LockInfo $existing) {
            Write-Host ("Lock status: EXPIRED (was held by {0})" -f $existing.holder) -ForegroundColor Yellow
            Write-Host ("  expired at: {0}" -f $existing.expiresAt)
            Write-Host ("  purpose: {0}" -f $existing.purpose)
        } else {
            $remaining = ([DateTime]::Parse($existing.expiresAt) - [DateTime]::Now).TotalMinutes
            Write-Host ("Lock status: HELD by {0}" -f $existing.holder) -ForegroundColor Cyan
            Write-Host ("  acquired:  {0}" -f $existing.acquiredAt)
            Write-Host ("  expires:   {0} (in {1:N1} min)" -f $existing.expiresAt, $remaining)
            Write-Host ("  purpose:   {0}" -f $existing.purpose)
            Write-Host ("  pid:       {0}" -f $existing.pid)
        }
        $exitCode = 0
    }

    default {
        Write-Host "Usage: kb-lock.ps1 <acquire|release|is-held|status> [-Holder <name>] [-Purpose <text>] [-TtlMinutes <n>] [-Force]"
        Write-Host ""
        Write-Host "Actions:"
        Write-Host "  acquire  - Get lock (requires -Holder, -Purpose)"
        Write-Host "  release  - Release lock (use -Force to release others lock)"
        Write-Host "  is-held  - Check if lock is held (exit 0=held, 1=free)"
        Write-Host "  status   - Print lock details"
        $exitCode = 2
    }
}

exit $exitCode

    }
    return
}

# ANSI mode: re-launch as UTF-8
$utf8 = New-Object System.Text.UTF8Encoding $True
$content = [System.IO.File]::ReadAllText($PSCommandPath, $utf8)
$tempPath = [System.IO.Path]::GetTempFileName() + '.ps1'
[System.IO.File]::WriteAllText($tempPath, $content, $utf8)
$argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $tempPath)
# Rebuild all args
if ($Action) { $argList += $Action }
if ($Holder) { $argList += '-Holder'; $argList += $Holder }
if ($Purpose) { $argList += '-Purpose'; $argList += $Purpose }
if ($TtlMinutes -ne 15) { $argList += '-TtlMinutes'; $argList += $TtlMinutes }
if ($Force) { $argList += '-Force' }
if ($LockFile -ne 'd:\xiangmu\_kb\.git\kb-write.lock') { $argList += '-LockFile'; $argList += $LockFile }
& powershell.exe @argList
$exitCode = $LASTEXITCODE
Remove-Item $tempPath -Force
exit $exitCode
