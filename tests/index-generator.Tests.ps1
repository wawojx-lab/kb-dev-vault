# Pester tests for index-generator.ps1
# Tests frontmatter parsing and index.md generation
# Pester v4 syntax

$script:generatorScript = "d:\xiangmu\_kb\90-meta\index-generator.ps1"
$script:testWikiDir = Join-Path $env:TEMP "test-index-wiki"
$script:testOutPath = Join-Path $env:TEMP "test-index.md"

function New-TestWikiPage {
    param(
        [string]$Type,
        [string]$FileName,
        [string]$Title,
        [string]$Tags = "",
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
    if ($Tags) { $content += "tags: [$Tags]`n" }
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

function Invoke-Generator {
    param(
        [string]$WikiDir = $script:testWikiDir,
        [string]$OutPath = $script:testOutPath
    )
    $output = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $script:generatorScript -WikiDir $WikiDir -OutPath $OutPath
    return @{ Output = $output -join "`n"; ExitCode = $LASTEXITCODE }
}

Describe "index-generator basic functionality" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force
        }
        if (Test-Path $script:testOutPath) {
            Remove-Item $script:testOutPath -Force
        }
    }

    AfterEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $script:testOutPath) {
            Remove-Item $script:testOutPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "should generate index.md from empty wiki" {
        New-Item -ItemType Directory -Path "$script:testWikiDir\entities" -Force | Out-Null
        $result = Invoke-Generator
        $result.ExitCode | Should Be 0
        Test-Path $script:testOutPath | Should Be $true
    }

    It "should generate index.md with pages" {
        New-TestWikiPage -Type "entities" -FileName "test-entity" -Title "Test Entity"
        $result = Invoke-Generator
        $result.ExitCode | Should Be 0
        $content = Get-Content $script:testOutPath -Raw
        $content | Should Match "Test Entity"
    }

    It "should count pages correctly" {
        New-TestWikiPage -Type "entities" -FileName "entity1" -Title "Entity One"
        New-TestWikiPage -Type "entities" -FileName "entity2" -Title "Entity Two"
        New-TestWikiPage -Type "concepts" -FileName "concept1" -Title "Concept One"
        $result = Invoke-Generator
        $result.Output | Should Match "Total: 3 pages"
    }
}

Describe "index-generator frontmatter parsing" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force
        }
        if (Test-Path $script:testOutPath) {
            Remove-Item $script:testOutPath -Force
        }
    }

    AfterEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $script:testOutPath) {
            Remove-Item $script:testOutPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "should use frontmatter title when available" {
        New-TestWikiPage -Type "entities" -FileName "file-name" -Title "Display Title"
        $result = Invoke-Generator
        $content = Get-Content $script:testOutPath -Raw
        $content | Should Match "Display Title"
    }

    It "should fall back to filename when no title" {
        $typeDir = Join-Path $script:testWikiDir "entities"
        New-Item -ItemType Directory -Path $typeDir -Force | Out-Null
        $filePath = Join-Path $typeDir "no-title.md"
        $content = "---`ntype: entity`nconfidence: stated`nsource: 'test'`n---`n# No Title"
        [System.IO.File]::WriteAllText($filePath, $content, [System.Text.UTF8Encoding]::new($true))
        $result = Invoke-Generator
        $indexContent = Get-Content $script:testOutPath -Raw
        $indexContent | Should Match "no-title"
    }

    It "should parse tags from frontmatter" {
        New-TestWikiPage -Type "concepts" -FileName "tagged-concept" -Title "Tagged Concept" -Tags "ai, ml, testing"
        $result = Invoke-Generator
        $content = Get-Content $script:testOutPath -Raw
        $content | Should Match "ai"
    }
}

Describe "index-generator type distribution" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force
        }
        if (Test-Path $script:testOutPath) {
            Remove-Item $script:testOutPath -Force
        }
    }

    AfterEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $script:testOutPath) {
            Remove-Item $script:testOutPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "should group pages by type" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "Entity"
        New-TestWikiPage -Type "concepts" -FileName "c1" -Title "Concept"
        New-TestWikiPage -Type "synthesis" -FileName "s1" -Title "Synthesis"
        $result = Invoke-Generator
        $content = Get-Content $script:testOutPath -Raw
        $content | Should Match "entities/"
        $content | Should Match "concepts/"
        $content | Should Match "synthesis/"
    }

    It "should skip empty type directories" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "Entity"
        # Create empty comparisons dir
        New-Item -ItemType Directory -Path "$script:testWikiDir\comparisons" -Force | Out-Null
        $result = Invoke-Generator
        $content = Get-Content $script:testOutPath -Raw
        # entities should appear, comparisons should not (no pages)
        $content | Should Match "entities/"
    }
}

Describe "index-generator output format" {
    BeforeEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force
        }
        if (Test-Path $script:testOutPath) {
            Remove-Item $script:testOutPath -Force
        }
    }

    AfterEach {
        if (Test-Path $script:testWikiDir) {
            Remove-Item $script:testWikiDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        if (Test-Path $script:testOutPath) {
            Remove-Item $script:testOutPath -Force -ErrorAction SilentlyContinue
        }
    }

    It "should include frontmatter in output" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "Entity"
        $result = Invoke-Generator
        $content = Get-Content $script:testOutPath -Raw
        $content | Should Match "^---"
        $content | Should Match "type: index"
    }

    It "should include directory navigation section" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "Entity"
        $result = Invoke-Generator
        $content = Get-Content $script:testOutPath -Raw
        $content | Should Match "directory navigation"
        $content | Should Match "raw/"
        $content | Should Match "wiki/"
    }

    It "should include type distribution table" {
        New-TestWikiPage -Type "entities" -FileName "e1" -Title "Entity"
        New-TestWikiPage -Type "concepts" -FileName "c1" -Title "Concept"
        $result = Invoke-Generator
        $content = Get-Content $script:testOutPath -Raw
        $content | Should Match "type distribution"
        $content | Should Match "total"
    }
}
