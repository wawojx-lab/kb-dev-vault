# Pester tests for moc-generator.ps1
# Tests MOC page generation by tag grouping
# Pester v4 syntax

$script:mocScript = "d:\xiangmu\_kb\90-meta\moc-generator.ps1"
$script:testWikiDir = Join-Path $env:TEMP "test-moc-wiki"
$script:testOutDir = Join-Path $env:TEMP "test-moc-out"

function New-TestWikiPage {
    param(
        [string]$Type,
        [string]$FileName,
        [string]$Title,
        [string[]]$Tags = @(),
        [string]$Created = "2026-06-21",
        [string]$Updated = "2026-06-21"
    )
    $typeDir = Join-Path $script:testWikiDir $Type
    if (-not (Test-Path $typeDir)) {
        New-Item -ItemType Directory -Path $typeDir -Force | Out-Null
    }
    $filePath = Join-Path $typeDir "$FileName.md"
    $content = "---`n"
    $content += "title: $Title`n"
    if ($Tags.Count -gt 0) {
        $tagStr = $Tags -join ", "
        $content += "tags: [$tagStr]`n"
    }
    $content += "created: $Created`n"
    $content += "updated: $Updated`n"
    $content += "type: $Type`n"
    $content += "confidence: stated`n"
    $content += "source: 'test'`n"
    $content += "---`n"
    $content += "# $Title`n"
    $content += "Test content."
    [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($true))
}

function Invoke-MocGenerator {
    param(
        [string]$WikiDir = $script:testWikiDir,
        [string]$OutDir = $script:testOutDir,
        [int]$MinPagesPerMoc = 3,
        [switch]$DryRun
    )
    $scriptArgs = @("-WikiDir", $WikiDir, "-OutDir", $OutDir, "-MinPagesPerMoc", $MinPagesPerMoc)
    if ($DryRun) { $scriptArgs += "-DryRun" }
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script:mocScript @scriptArgs
    return @{ Output = $output -join "`n"; ExitCode = $LASTEXITCODE }
}

Describe "moc-generator basic functionality" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force
        }
        if (Test-Path $script:testOutDir) {
            Remove-Item $script:testOutDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $script:testOutDir -Force | Out-Null
    }

    AfterEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $script:testOutDir) {
            Remove-Item $script:testOutDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "should run successfully on empty wiki" {
        New-Item -ItemType Directory -Path "$script:testWikiDir\entities" -Force | Out-Null
        $result = Invoke-MocGenerator
        $result.ExitCode | Should Be 0
    }

    It "should scan all 5 type directories" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "E1" -Tags @("ai")
        New-TestWikiPage -Type "concepts" -FileName "c1" -Title "C1" -Tags @("ai")
        $result = Invoke-MocGenerator
        $result.Output | Should Match "Scanning"
    }
}

Describe "moc-generator tag grouping" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force
        }
        if (Test-Path $script:testOutDir) {
            Remove-Item $script:testOutDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $script:testOutDir -Force | Out-Null
    }

    AfterEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $script:testOutDir) {
            Remove-Item $script:testOutDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "should generate MOC when tag has >= MinPagesPerMoc pages" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "E1" -Tags @("ai")
        New-TestWikiPage -Type "entities" -FileName "e2" -Title "E2" -Tags @("ai")
        New-TestWikiPage -Type "concepts" -FileName "c1" -Title "C1" -Tags @("ai")
        $result = Invoke-MocGenerator -MinPagesPerMoc 3
        $result.ExitCode | Should Be 0
        $mocFiles = Get-ChildItem $script:testOutDir -Filter "moc-auto-*.md" -ErrorAction SilentlyContinue
        $mocFiles.Count | Should BeGreaterThan 0
    }

    It "should NOT generate MOC when tag has < MinPagesPerMoc pages" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "E1" -Tags @("rare-tag")
        New-TestWikiPage -Type "concepts" -FileName "c1" -Title "C1" -Tags @("other-tag")
        $result = Invoke-MocGenerator -MinPagesPerMoc 3
        $result.ExitCode | Should Be 0
        $mocFiles = Get-ChildItem $script:testOutDir -Filter "moc-auto-*.md" -ErrorAction SilentlyContinue
        $mocFiles.Count | Should Be 0
    }

    It "should group pages by tag across types" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "Entity AI" -Tags @("ai")
        New-TestWikiPage -Type "concepts" -FileName "c1" -Title "Concept AI" -Tags @("ai")
        New-TestWikiPage -Type "synthesis" -FileName "s1" -Title "Synthesis AI" -Tags @("ai")
        $result = Invoke-MocGenerator -MinPagesPerMoc 3
        $mocFiles = Get-ChildItem $script:testOutDir -Filter "moc-auto-ai.md" -ErrorAction SilentlyContinue
        $mocFiles.Count | Should Be 1
        $content = Get-Content $mocFiles[0].FullName -Raw
        $content | Should Match "Entity AI"
        $content | Should Match "Concept AI"
        $content | Should Match "Synthesis AI"
    }
}

Describe "moc-generator frontmatter parsing" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force
        }
        if (Test-Path $script:testOutDir) {
            Remove-Item $script:testOutDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $script:testOutDir -Force | Out-Null
    }

    AfterEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $script:testOutDir) {
            Remove-Item $script:testOutDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "should parse inline array tags [a, b, c]" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "E1" -Tags @("inline", "test")
        New-TestWikiPage -Type "entities" -FileName "e2" -Title "E2" -Tags @("inline")
        New-TestWikiPage -Type "entities" -FileName "e3" -Title "E3" -Tags @("inline")
        $result = Invoke-MocGenerator -MinPagesPerMoc 3
        $mocFiles = Get-ChildItem $script:testOutDir -Filter "moc-auto-inline.md" -ErrorAction SilentlyContinue
        $mocFiles.Count | Should Be 1
    }

    It "should handle pages without tags" {
        $typeDir = Join-Path $script:testWikiDir "entities"
        New-Item -ItemType Directory -Path $typeDir -Force | Out-Null
        $filePath = Join-Path $typeDir "no-tags.md"
        $content = "---`ntitle: No Tags`ntype: entity`nconfidence: stated`nsource: 'test'`n---`n# No Tags"
        [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($true))
        $result = Invoke-MocGenerator
        $result.ExitCode | Should Be 0
    }
}

Describe "moc-generator DryRun mode" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force
        }
        if (Test-Path $script:testOutDir) {
            Remove-Item $script:testOutDir -Recurse -Force
        }
        New-Item -ItemType Directory -Path $script:testOutDir -Force | Out-Null
    }

    AfterEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $script:testOutDir) {
            Remove-Item $script:testOutDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    It "should not generate files in DryRun mode" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "E1" -Tags @("dryrun")
        New-TestWikiPage -Type "entities" -FileName "e2" -Title "E2" -Tags @("dryrun")
        New-TestWikiPage -Type "entities" -FileName "e3" -Title "E3" -Tags @("dryrun")
        $result = Invoke-MocGenerator -MinPagesPerMoc 3 -DryRun
        $result.ExitCode | Should Be 0
        $mocFiles = Get-ChildItem $script:testOutDir -Filter "moc-auto-*.md" -ErrorAction SilentlyContinue
        $mocFiles.Count | Should Be 0
    }
}
