<#
.SYNOPSIS
    CPR Phase 4: Analyze Specification

.DESCRIPTION
    Performs automated quality analysis of specification artifacts and generates
    structured data for AI-powered deep analysis.

.PARAMETER FeatureNumber
    Four-digit feature number (e.g., 0001, 0042)

.PARAMETER FeatureName
    Short kebab-case feature name (e.g., user-profile-management)

.EXAMPLE
    .\framework\tools\phase-4-analyze.ps1 -FeatureNumber "0001" -FeatureName "personal-goal-creation-management"
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d{4}$')]
    [string]$FeatureNumber,
    
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*$')]
    [string]$FeatureName
)

$ErrorActionPreference = "Stop"

# Configuration
$metaRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$specFolderName = "$FeatureNumber-$FeatureName"
$specPath = Join-Path $metaRoot "specifications\$specFolderName"
$currentDate = Get-Date -Format 'yyyy-MM-dd'

# Analysis results
$findings = @()
$metrics = @{
    totalUserStories = 0
    totalTasks       = 0
    totalEndpoints   = 0
    placeholderCount = 0
    namingViolations = 0
}
$autoScore = 100

# Helper Functions
function Add-Finding {
    param(
        [string]$Id,
        [string]$Category,
        [string]$Severity,
        [string]$Location,
        [string]$Summary,
        [string]$Recommendation
    )
    
    $script:findings += @{
        id             = $Id
        category       = $Category
        severity       = $Severity
        location       = $Location
        summary        = $Summary
        recommendation = $Recommendation
    }
    
    # Update score
    switch ($Severity) {
        "CRITICAL" { $script:autoScore = 0 }
        "HIGH" { $script:autoScore = [Math]::Max(0, $script:autoScore - 20) }
        "MEDIUM" { $script:autoScore = [Math]::Max(0, $script:autoScore - 5) }
        "LOW" { $script:autoScore = [Math]::Max(0, $script:autoScore - 1) }
    }
}

function Get-PlaceholderCount {
    param([string]$Content)
    
    $patterns = @('\[TODO\]', '\[TBD\]', '\[FILL IN\]', '\[PLACEHOLDER\]', '\?\?\?')
    $count = 0
    
    foreach ($pattern in $patterns) {
        $matches = [regex]::Matches($Content, $pattern, [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)
        $count += $matches.Count
    }
    
    return $count
}

Write-Host ""
Write-Host "=== CPR Phase 4: Analyze Specification ===" -ForegroundColor Cyan
Write-Host "Feature: $specFolderName" -ForegroundColor Yellow
Write-Host "Analysis Date: $currentDate" -ForegroundColor Gray
Write-Host ""

# Step 1: Validate Prerequisites
Write-Host "[1/4] Validating prerequisites..." -ForegroundColor Green

if (-not (Test-Path $specPath)) {
    Write-Host "  ERROR: Specification folder not found: $specPath" -ForegroundColor Red
    Write-Host "  Please run Phase 1 first." -ForegroundColor Yellow
    exit 1
}

$requiredFiles = @(
    "description.md",
    "implementation-plan.md",
    "tasks.md",
    "endpoints.md",
    "progress.md"
)

$allFilesExist = $true
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $specPath $file
    if (-not (Test-Path $filePath)) {
        Add-Finding -Id "C001" -Category "Completeness" -Severity "CRITICAL" `
            -Location $file -Summary "$file is missing" `
            -Recommendation "Create $file using appropriate template"
        $allFilesExist = $false
    }
    elseif ((Get-Item $filePath).Length -lt 100) {
        Add-Finding -Id "C002" -Category "Completeness" -Severity "HIGH" `
            -Location $file -Summary "$file appears empty or incomplete" `
            -Recommendation "Fill in $file with required content"
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host "  ERROR: Not all required files exist or are complete" -ForegroundColor Red
    exit 1
}

Write-Host "  OK: All required files present and not empty" -ForegroundColor Gray

# Step 2: Scan for Placeholders
Write-Host ""
Write-Host "[2/4] Scanning for placeholders..." -ForegroundColor Green

$totalPlaceholders = 0
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $specPath $file
    $content = Get-Content $filePath -Raw -Encoding UTF8
    $count = Get-PlaceholderCount -Content $content
    $totalPlaceholders += $count
    
    if ($count -gt 0) {
        Add-Finding -Id "A001" -Category "Ambiguity" -Severity "MEDIUM" `
            -Location $file `
            -Summary "Found $count placeholder(s) in file" `
            -Recommendation 'Replace all placeholders with actual content'
    }
}

$metrics.placeholderCount = $totalPlaceholders
Write-Host "  Found $totalPlaceholders total placeholder(s)" -ForegroundColor $(if ($totalPlaceholders -gt 0) { "Yellow" } else { "Gray" })

# Step 3: Calculate Metrics
Write-Host ""
Write-Host "[3/4] Calculating metrics..." -ForegroundColor Green

$descPath = Join-Path $specPath "description.md"
$tasksPath = Join-Path $specPath "tasks.md"
$endpointsPath = Join-Path $specPath "endpoints.md"

$descContent = Get-Content $descPath -Raw -Encoding UTF8
$tasksContent = Get-Content $tasksPath -Raw -Encoding UTF8
$endpointsContent = Get-Content $endpointsPath -Raw -Encoding UTF8

# Count user stories
$storyMatches = [regex]::Matches($descContent, '(?m)^### US-\d+:')
$metrics.totalUserStories = $storyMatches.Count
Write-Host "  User Stories: $($metrics.totalUserStories)" -ForegroundColor Gray

# Count tasks
$taskMatches = [regex]::Matches($tasksContent, '(?m)^-\s*\[\s*\]\s+T\d+')
$metrics.totalTasks = $taskMatches.Count
Write-Host "  Tasks: $($metrics.totalTasks)" -ForegroundColor Gray

# Count endpoints
$endpointMatches = [regex]::Matches($endpointsContent, '(?m)^(GET|POST|PUT|PATCH|DELETE)\s+/api/')
$metrics.totalEndpoints = $endpointMatches.Count
Write-Host "  Endpoints: $($metrics.totalEndpoints)" -ForegroundColor Gray

if ($metrics.totalTasks -eq 0) {
    Add-Finding -Id "G001" -Category "Gap" -Severity "CRITICAL" `
        -Location "tasks.md" `
        -Summary "No tasks found" `
        -Recommendation "Add implementation tasks to tasks.md"
}

# Step 4: Constitutional Compliance
Write-Host ""
Write-Host "[4/4] Validating constitutional compliance..." -ForegroundColor Green

$planPath = Join-Path $specPath "implementation-plan.md"
$planContent = Get-Content $planPath -Raw -Encoding UTF8

$hasComplianceSection = $planContent -match '(?i)constitutional\s+compliance'
$principleMatches = [regex]::Matches($planContent, '(?m)^###?\s*.*Principle\s+\d+:')
$principleCount = $principleMatches.Count

if (-not $hasComplianceSection) {
    Add-Finding -Id "CC001" -Category "Constitutional" -Severity "CRITICAL" `
        -Location "implementation-plan.md" `
        -Summary "Missing Constitutional Compliance Check section" `
        -Recommendation "Add Constitutional Compliance Check section reviewing all 11 principles"
}

if ($principleCount -lt 11 -and $hasComplianceSection) {
    Add-Finding -Id "CC002" -Category "Constitutional" -Severity "HIGH" `
        -Location "implementation-plan.md" `
        -Summary "Only $principleCount principles reviewed (should be 11)" `
        -Recommendation "Review all 11 CPR Constitutional Principles"
}

Write-Host "  Constitutional Compliance: $(if ($hasComplianceSection) { 'Present' } else { 'MISSING' })" -ForegroundColor $(if ($hasComplianceSection) { "Gray" } else { "Red" })
Write-Host "  Principles Reviewed: $principleCount / 11" -ForegroundColor $(if ($principleCount -ge 11) { "Gray" } else { "Yellow" })

# Generate Summary
Write-Host ""
Write-Host "=== Automated Analysis Complete ===" -ForegroundColor Cyan
Write-Host ""

$criticalCount = ($findings | Where-Object { $_.severity -eq "CRITICAL" }).Count
$highCount = ($findings | Where-Object { $_.severity -eq "HIGH" }).Count
$mediumCount = ($findings | Where-Object { $_.severity -eq "MEDIUM" }).Count
$lowCount = ($findings | Where-Object { $_.severity -eq "LOW" }).Count

Write-Host "Automated Quality Score: " -NoNewline
if ($autoScore -ge 90) {
    Write-Host "$autoScore/100" -ForegroundColor Green
}
elseif ($autoScore -ge 70) {
    Write-Host "$autoScore/100" -ForegroundColor Yellow
}
else {
    Write-Host "$autoScore/100" -ForegroundColor Red
}

Write-Host ""
Write-Host "Findings Summary:" -ForegroundColor White
Write-Host "  CRITICAL: $criticalCount" -ForegroundColor $(if ($criticalCount -gt 0) { "Red" } else { "Gray" })
Write-Host "  HIGH:     $highCount" -ForegroundColor $(if ($highCount -gt 0) { "Yellow" } else { "Gray" })
Write-Host "  MEDIUM:   $mediumCount" -ForegroundColor $(if ($mediumCount -gt 0) { "Yellow" } else { "Gray" })
Write-Host "  LOW:      $lowCount" -ForegroundColor "Gray"

# Output JSON Report
Write-Host ""
Write-Host "[Output] Generating automation-report.json..." -ForegroundColor Green

$report = @{
    metadata        = @{
        featureNumber = $FeatureNumber
        featureName   = $FeatureName
        analysisDate  = $currentDate
        analysisType  = "automated"
        toolVersion   = "1.0.0"
    }
    findings        = $findings
    metrics         = $metrics
    automatedScore  = $autoScore
    summary         = @{
        criticalIssues = $criticalCount
        highIssues     = $highCount
        mediumIssues   = $mediumCount
        lowIssues      = $lowCount
        totalFindings  = $findings.Count
    }
    recommendations = @{
        nextStep = if ($criticalCount -gt 0) {
            "BLOCKED - Resolve CRITICAL issues before proceeding"
        }
        elseif ($autoScore -lt 90) {
            "NEEDS_IMPROVEMENT - Address HIGH/MEDIUM issues"
        }
        else {
            "READY_FOR_AI_ANALYSIS - Proceed with deep analysis"
        }
        useAI    = $true
        aiPrompt = "framework/prompts/phase-4-analyze.md"
    }
}

$jsonPath = Join-Path $specPath "automation-report.json"
$report | ConvertTo-Json -Depth 10 | Set-Content $jsonPath -Encoding UTF8

Write-Host "  Created: automation-report.json" -ForegroundColor Green

# Next Actions
Write-Host ""
Write-Host "=== Next Actions ===" -ForegroundColor Cyan
Write-Host ""

if ($criticalCount -gt 0) {
    Write-Host "Status: BLOCKED" -ForegroundColor Red
    Write-Host ""
    Write-Host "You must resolve all CRITICAL issues before proceeding:" -ForegroundColor Yellow
    foreach ($finding in ($findings | Where-Object { $_.severity -eq "CRITICAL" })) {
        Write-Host "  - [$($finding.id)] $($finding.summary)" -ForegroundColor Red
        Write-Host "    Location: $($finding.location)" -ForegroundColor Gray
        Write-Host "    Fix: $($finding.recommendation)" -ForegroundColor Gray
    }
    exit 1
}

Write-Host "Ready for AI-Powered Deep Analysis:" -ForegroundColor White
Write-Host ""
Write-Host "Use GitHub Copilot Chat:" -ForegroundColor Gray
Write-Host "@workspace Use framework/prompts/phase-4-analyze.md to analyze feature $FeatureNumber" -ForegroundColor Cyan
Write-Host ""

if ($autoScore -ge 90) {
    Write-Host "Automated checks: PASSED" -ForegroundColor Green
}
else {
    Write-Host "Automated checks: NEEDS IMPROVEMENT (score: $autoScore/100)" -ForegroundColor Yellow
}

Write-Host ""
