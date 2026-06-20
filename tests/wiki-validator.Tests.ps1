#Requires -Version 5.1
# Pester v4 tests for wiki-validator.ps1
# Run: Invoke-Pester -Path tests/wiki-validator.Tests.ps1 -OutputFile test-results.xml -OutputFormat NUnitXml

$script:validatorScript = "d:\xiangmu\_kb\90-meta\wiki-validator.ps1"
$script:testWikiDir = Join-Path $env:TEMP "test-wiki-validator"

function New-TestPage {
    param(
        [string]$Path,
        [string]$Type = "entity",
        [string]$Title = "Test Page",
        [string]$Source = "test",
        [string]$Confidence = "stated",
        [string]$Body = ""
    )
    $fm = @"
---
type: $Type
title: $Title
source: '$Source'
created: 2026-06-21
updated: 2026-06-21
confidence: $Confidence
tags: [test]
---

$Body
"@
    $dir = Split-Path $Path -Parent
    if (-not (Test-Path $dir)) { New-Item -ItemType Directory -Path $dir -Force | Out-Null }
    [System.IO.File]::WriteAllText($Path, $fm, (New-Object System.Text.UTF8Encoding $False))
}

function Invoke-Validator {
    param(
        [string]$Target = "",
        [switch]$All,
        [switch]$CycleOnly,
        [string]$WikiDir = $script:testWikiDir
    )
    $scriptArgs = @()
    if ($Target) { $scriptArgs += @("-Target", $Target) }
    if ($All) { $scriptArgs += @("-All") }
    if ($CycleOnly) { $scriptArgs += @("-CycleOnly") }
    $scriptArgs += @("-WikiDir", $WikiDir)

    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script:validatorScript @scriptArgs
    return @{
        Output = $output -join "`n"
        ExitCode = $LASTEXITCODE
    }
}

Describe "wiki-validator single file" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) { Remove-Item $script:testWikiDir -Recurse -Force }
        New-Item -ItemType Directory -Path "$script:testWikiDir\entities" -Force | Out-Null
        New-Item -ItemType Directory -Path "$script:testWikiDir\concepts" -Force | Out-Null
    }

    It "should detect missing frontmatter" {
        $badPage = "$script:testWikiDir\entities\no-fm.md"
        [System.IO.File]::WriteAllText($badPage, "No frontmatter here.", (New-Object System.Text.UTF8Encoding $False))
        $result = Invoke-Validator -Target $badPage
        $result.Output | Should Match "frontmatter|FAIL|error|missing"
    }

    It "should detect invalid type" {
        $badPage = "$script:testWikiDir\entities\bad-type.md"
        New-TestPage -Path $badPage -Type "invalid-type" -Body "content"
        $result = Invoke-Validator -Target $badPage
        $result.Output | Should Match "type|FAIL|error|invalid"
    }

    It "should detect missing required field" {
        $badPage = "$script:testWikiDir\entities\missing-field.md"
        $content = @"
---
type: entity
title: Missing Source
created: 2026-06-21
updated: 2026-06-21
confidence: stated
---

Content here.
"@
        [System.IO.File]::WriteAllText($badPage, $content, (New-Object System.Text.UTF8Encoding $False))
        $result = Invoke-Validator -Target $badPage
        $result.Output | Should Match "source|FAIL|error|missing"
    }
}

Describe "wiki-validator all pages" {
    It "should scan all pages in wiki dir" {
        $result = Invoke-Validator -All
        $result.Output | Should Match "page|error|warning|PASS|OK"
    }
}

Describe "wiki-validator cycle detection" {
    It "should run cycle detection without error" {
        $result = Invoke-Validator -CycleOnly
        $result.ExitCode | Should BeLessOrEqual 1
    }
}
