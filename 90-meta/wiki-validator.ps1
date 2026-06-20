param(
    [string]$Target = "",
    [switch]$All,
    [switch]$CycleOnly,
    [string]$WikiDir = "d:\xiangmu\_kb\wiki"
)

# wiki-validator.ps1
# Validate wiki pages: frontmatter + cycle + depth
# Modes:
#   -Target <file.md>  : validate single file
#   -All               : validate all wiki pages
#   -CycleOnly         : only check wikilink cycles (DFS)
# ASCII-only script body; Chinese content lives in source data

if ($MyInvocation.CommandOrigin -eq 'Runspace' -or [Console]::OutputEncoding.WebName -eq 'utf-8') {
    & {

$validTypes = @("entity", "concept", "comparison", "summary", "synthesis")
$requiredFields = @("type", "title", "source", "created", "updated", "confidence")
$confidenceValues = @("stated", "inferred", "derived")

# Depth thresholds: type -> @{ minWords; minWikilinks }
$depthRules = @{
    entity     = @{ minWords = 200; minWikilinks = 1 }
    concept    = @{ minWords = 200; minWikilinks = 2 }
    comparison = @{ minWords = 300; minWikilinks = 2 }
    summary    = @{ minWords = 300; minWikilinks = 3 }
    synthesis  = @{ minWords = 400; minWikilinks = 4 }
}

function Get-Frontmatter {
    param([string]$Path)
    $content = Get-Content -Path $Path -Raw -Encoding UTF8
    $fm = @{}
    $m = [regex]::Match($content, "^---\s*\r?\n(.+?)\r?\n---\s*\r?\n", "Singleline")
    if (-not $m.Success) { return @{ __raw = ""; __content = $content } }
    $yaml = $m.Groups[1].Value
    $body = $content.Substring($m.Length)
    foreach ($line in ($yaml -split "`r?`n")) {
        $km = [regex]::Match($line, "^(\w+):\s*(.*)$")
        if ($km.Success) {
            $key = $km.Groups[1].Value
            $val = $km.Groups[2].Value.Trim()
            $val = $val -replace "^'(.*)'$", '$1'
            $val = $val -replace '^"(.*)"$', '$1'
            $fm[$key] = $val
        }
    }
    $fm["__raw"] = $yaml
    $fm["__content"] = $body
    return $fm
}

function Get-Wikilinks {
    param([string]$Content)
    $links = [regex]::Matches($Content, '\[\[([^\]]+)\]\]')
    $result = @()
    foreach ($l in $links) {
        $target = $l.Groups[1].Value
        # Handle alias: [[target|alias]]
        if ($target -match '\|') { $target = ($target -split '\|')[0] }
        $result += $target.Trim()
    }
    return $result
}

function Test-Date {
    param([string]$s)
    try { [DateTime]::ParseExact($s, "yyyy-MM-dd", $null) | Out-Null; return $true }
    catch { return $false }
}

function Test-SourceQuotes {
    param([string]$Source)
    # Windows path with backslash in double quotes triggers \d \s escape
    if ($Source -match '^[a-zA-Z]:\\' -or $Source -match '^\\\\') {
        # Has Windows path - check if original yaml had double quotes
        return $true  # We can't tell from parsed value; just pass
    }
    return $true
}

function Validate-File {
    param([string]$Path)

    $errors = @()
    $warnings = @()
    $infos = @()

    if (-not (Test-Path $Path)) {
        return @{ file = $Path; errors = @("file not found"); warnings = @(); infos = @() }
    }

    $fm = Get-Frontmatter -Path $Path
    $content = $fm["__content"]
    $raw = $fm["__raw"]

    # 1. Frontmatter exists
    if (-not $raw) {
        $errors += "frontmatter: missing (no --- block)"
        return @{ file = $Path; errors = $errors; warnings = $warnings; infos = $infos }
    }

    # 2. Required fields
    foreach ($f in $requiredFields) {
        if (-not $fm.ContainsKey($f) -or -not $fm[$f]) {
            $errors += "frontmatter: missing required field '$f'"
        }
    }

    # 3. type must be in closed vocabulary
    if ($fm.ContainsKey("type")) {
        if ($validTypes -notcontains $fm["type"]) {
            $errors += "frontmatter: type '$($fm.type)' not in closed vocabulary (entity/concept/comparison/summary/synthesis)"
        }
    }

    # 4. confidence must be valid
    if ($fm.ContainsKey("confidence") -and $fm["confidence"]) {
        if ($confidenceValues -notcontains $fm["confidence"]) {
            $errors += "frontmatter: confidence '$($fm.confidence)' not in (stated/inferred/derived)"
        }
    }

    # 5. created/updated must be YYYY-MM-DD
    if ($fm.ContainsKey("created") -and $fm["created"]) {
        if (-not (Test-Date $fm["created"])) { $errors += "frontmatter: created '$($fm.created)' not YYYY-MM-DD" }
    }
    if ($fm.ContainsKey("updated") -and $fm["updated"]) {
        if (-not (Test-Date $fm["updated"])) { $errors += "frontmatter: updated '$($fm.updated)' not YYYY-MM-DD" }
    }

    # 6. source field with Windows path must use single quotes (check raw yaml)
    if ($raw -match "(?m)^source:\s*`".*\\.*`"\s*$") {
        $errors += "frontmatter: source uses double quotes with Windows path (will trigger \d \s escape) - use single quotes"
    }

    # 7. Content depth (only if type is valid)
    if ($fm.ContainsKey("type") -and $validTypes -contains $fm["type"]) {
        $rule = $depthRules[$fm["type"]]
        # Word count: split by whitespace, count non-empty tokens
        $bodyText = $content -replace '\[\[[^\]]+\]\]', '' -replace '\[([^\]]+)\]\([^\)]+\)', '$1' -replace '#+', '' -replace '\|', ' ' -replace '`', ''
        $words = ($bodyText -split '\s+' | Where-Object { $_ -ne "" }).Count
        $wikilinks = Get-Wikilinks -Content $content
        $wlCount = $wikilinks.Count

        if ($words -lt $rule.minWords) {
            $warnings += "depth: $($fm.type) needs $($rule.minWords) words, got $words"
        }
        if ($wlCount -lt $rule.minWikilinks) {
            $warnings += "depth: $($fm.type) needs $($rule.minWikilinks) wikilinks, got $wlCount"
        }
        $infos += "depth: $words words, $wlCount wikilinks"
    }

    # 8. Isolated page check (no wikilinks at all)
    $allWl = Get-Wikilinks -Content $content
    if ($allWl.Count -eq 0) {
        $warnings += "isolated: page has 0 wikilinks (will be orphan node in graph)"
    }

    return @{ file = $Path; errors = $errors; warnings = $warnings; infos = $infos }
}

function Build-AdjacencyList {
    param([string]$WikiRoot)

    $adj = @{}
    $files = Get-ChildItem $WikiRoot -Recurse -Filter *.md -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $baseName = $f.BaseName
        if (-not $adj.ContainsKey($baseName)) { $adj[$baseName] = @() }
        $content = Get-Content $f.FullName -Raw -Encoding UTF8 -ErrorAction SilentlyContinue
        if (-not $content) { continue }
        $links = Get-Wikilinks -Content $content
        foreach ($l in $links) {
            $target = $l
            if ($target -match '\|') { $target = ($target -split '\|')[0].Trim() }
            if (-not $adj[$baseName].Contains($target)) { $adj[$baseName] += $target }
        }
    }
    return $adj
}

function Find-Cycles {
    param([hashtable]$Adj)

    $cycles = @()
    $visited = @{}
    $stack = @{}
    $path = @()

    function DFS-Visit {
        param([string]$Node)
        if ($stack.ContainsKey($Node)) {
            # Found cycle - extract the cycle path
            $cycleStart = $path.IndexOf($Node)
            $cycle = $path[$cycleStart..($path.Count - 1)] + $Node
            $cycles += ,@($cycle)
            return
        }
        if ($visited.ContainsKey($Node)) { return }
        $visited[$Node] = $true
        $stack[$Node] = $true
        $path += $Node
        if ($Adj.ContainsKey($Node)) {
            foreach ($neighbor in $Adj[$Node]) {
                DFS-Visit -Node $neighbor
            }
        }
        $path = $path[0..($path.Count - 2)]
        $stack.Remove($Node)
    }

    foreach ($node in $Adj.Keys) {
        if (-not $visited.ContainsKey($node)) {
            DFS-Visit -Node $node
        }
    }
    return $cycles
}

# === Main ===
Write-Host "=== Wiki Validator ==="
Write-Host ("Wiki: {0}" -f $WikiDir)
Write-Host ""

$totalErrors = 0
$totalWarnings = 0
$totalFiles = 0

if ($CycleOnly) {
    Write-Host "Mode: cycle detection only"
    Write-Host ""
    $adj = Build-AdjacencyList -WikiRoot $WikiDir
    Write-Host ("Nodes: {0}" -f $adj.Count)
    $cycles = Find-Cycles -Adj $adj
    if ($cycles.Count -eq 0) {
        Write-Host "Cycles: 0 (OK)" -ForegroundColor Green
    } else {
        Write-Host ("Cycles: {0}" -f $cycles.Count) -ForegroundColor Red
        foreach ($c in $cycles) {
            Write-Host ("  - " + ($c -join " -> "))
        }
    }
    exit 0
}

if ($All) {
    Write-Host "Mode: validate all wiki pages"
    Write-Host ""
    $files = Get-ChildItem $WikiDir -Recurse -Filter *.md -ErrorAction SilentlyContinue
    foreach ($f in $files) {
        $totalFiles++
        $result = Validate-File -Path $f.FullName
        $icon = if ($result.errors.Count -eq 0) { "[OK]" } elseif ($result.warnings.Count -gt 0) { "[WW]" } else { "[ERR]" }
        $color = if ($result.errors.Count -eq 0) { "Green" } else { "Red" }
        Write-Host ("  $icon {0}" -f $f.Name) -ForegroundColor $color
        foreach ($e in $result.errors) { Write-Host ("      ERR: $e") -ForegroundColor Red; $totalErrors++ }
        foreach ($w in $result.warnings) { Write-Host ("      WRN: $w") -ForegroundColor Yellow; $totalWarnings++ }
    }
    Write-Host ""
    Write-Host ("Files:   {0}" -f $totalFiles)
    Write-Host ("Errors:  {0}" -f $totalErrors)
    Write-Host ("Warnings: {0}" -f $totalWarnings)

    # Also run cycle detection
    Write-Host ""
    Write-Host "=== Cycle Detection ==="
    $adj = Build-AdjacencyList -WikiRoot $WikiDir
    Write-Host ("Nodes: {0}" -f $adj.Count)
    $cycles = Find-Cycles -Adj $adj
    if ($cycles.Count -eq 0) {
        Write-Host "Cycles: 0 (OK)" -ForegroundColor Green
    } else {
        Write-Host ("Cycles: {0}" -f $cycles.Count) -ForegroundColor Red
        foreach ($c in $cycles) {
            Write-Host ("  - " + ($c -join " -> "))
        }
        $totalErrors += $cycles.Count
    }
} elseif ($Target) {
    Write-Host "Mode: validate single file"
    Write-Host ("Target: {0}" -f $Target)
    Write-Host ""
    $totalFiles = 1
    $result = Validate-File -Path $Target
    $icon = if ($result.errors.Count -eq 0) { "[OK]" } elseif ($result.warnings.Count -gt 0) { "[WW]" } else { "[ERR]" }
    Write-Host ("  $icon {0}" -f (Split-Path $Target -Leaf))
    foreach ($e in $result.errors) { Write-Host ("      ERR: $e") -ForegroundColor Red; $totalErrors++ }
    foreach ($w in $result.warnings) { Write-Host ("      WRN: $w") -ForegroundColor Yellow; $totalWarnings++ }
    foreach ($i in $result.infos) { Write-Host ("      INF: $i") -ForegroundColor Cyan }
} else {
    Write-Host "Usage:"
    Write-Host "  wiki-validator.ps1 -Target <file.md>   # single file"
    Write-Host "  wiki-validator.ps1 -All                # all wiki pages"
    Write-Host "  wiki-validator.ps1 -CycleOnly          # cycle detection only"
    exit 1
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host ("Files:    {0}" -f $totalFiles)
Write-Host ("Errors:   {0}" -f $totalErrors)
Write-Host ("Warnings: {0}" -f $totalWarnings)
if ($totalErrors -eq 0) {
    Write-Host "Result: PASS" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Result: FAIL" -ForegroundColor Red
    exit 1
}

    }
    return
}

# ANSI mode: re-launch as UTF-8
$utf8 = New-Object System.Text.UTF8Encoding $True
$content = [System.IO.File]::ReadAllText($PSCommandPath, $utf8)
$tempPath = [System.IO.Path]::GetTempFileName() + '.ps1'
[System.IO.File]::WriteAllText($tempPath, $content, $utf8)
$argList = @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', $tempPath)
if ($Target) { $argList += '-Target'; $argList += $Target }
if ($All) { $argList += '-All' }
if ($CycleOnly) { $argList += '-CycleOnly' }
if ($WikiDir -ne 'd:\xiangmu\_kb\wiki') { $argList += '-WikiDir'; $argList += $WikiDir }
& powershell.exe @argList
$exitCode = $LASTEXITCODE
Remove-Item $tempPath -Force
exit $exitCode
