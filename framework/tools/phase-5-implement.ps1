<#
.SYNOPSIS
    CPR Phase 5: Implement Feature

.DESCRIPTION
    Prepares for implementation by validating prerequisites, creating feature branches,
    and providing implementation guidance.
    
    This tool does NOT implement code automatically. It prepares the environment and
    guides the developer to use GitHub Copilot for actual code implementation.

.PARAMETER FeatureNumber
    Four-digit feature number (e.g., 0001, 0042)

.PARAMETER FeatureName
    Short kebab-case feature name (e.g., user-profile-management)

.PARAMETER SkipBranchCreation
    Skip creating git branches (if already created)

.EXAMPLE
    .\framework\tools\phase-5-implement.ps1 -FeatureNumber "0001" -FeatureName "personal-goal-creation-management"
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d{4}$')]
    [string]$FeatureNumber,
    
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*$')]
    [string]$FeatureName,
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipBranchCreation
)

$ErrorActionPreference = "Stop"

# Configuration
$metaRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$cprRoot = Split-Path $metaRoot -Parent
$apiRoot = Join-Path $cprRoot "cpr-api"
$uiRoot = Join-Path $cprRoot "cpr-ui"

$specFolderName = "$FeatureNumber-$FeatureName"
$specPath = Join-Path $metaRoot "specifications\$specFolderName"
$branchName = "feature/$FeatureNumber-$FeatureName"
$currentDate = Get-Date -Format 'yyyy-MM-dd'

Write-Host ""
Write-Host "=== CPR Phase 5: Implement Feature ===" -ForegroundColor Cyan
Write-Host "Feature: $specFolderName" -ForegroundColor Yellow
Write-Host "Date: $currentDate" -ForegroundColor Gray
Write-Host ""

# Step 1: Validate Prerequisites
Write-Host "[1/5] Validating prerequisites..." -ForegroundColor Green

# Check specification exists
if (-not (Test-Path $specPath)) {
    Write-Host "  ERROR: Specification folder not found: $specPath" -ForegroundColor Red
    Write-Host "  Please run Phase 1 first." -ForegroundColor Yellow
    exit 1
}
Write-Host "  OK: Specification folder exists" -ForegroundColor Gray

# Check Phase 4 complete
$analysisReport = Join-Path $specPath "analysis-report.md"
if (-not (Test-Path $analysisReport)) {
    Write-Host "  ERROR: analysis-report.md not found" -ForegroundColor Red
    Write-Host "  Please complete Phase 4 (Analyze) first." -ForegroundColor Yellow
    exit 1
}

# Check quality score
$reportContent = Get-Content $analysisReport -Raw -Encoding UTF8
if ($reportContent -match 'Overall Quality Score[:\s]*(\d+)/100') {
    $qualityScore = [int]$Matches[1]
    if ($qualityScore -lt 90) {
        Write-Host "  ERROR: Quality score is $qualityScore/100 (minimum: 90)" -ForegroundColor Red
        Write-Host "  Please address issues in analysis-report.md first." -ForegroundColor Yellow
        exit 1
    }
    Write-Host "  OK: Quality score is $qualityScore/100" -ForegroundColor Gray
}
else {
    Write-Host "  WARNING: Could not parse quality score from analysis-report.md" -ForegroundColor Yellow
    Write-Host "  Continuing anyway..." -ForegroundColor Gray
}

# Check required files
$requiredFiles = @("description.md", "implementation-plan.md", "tasks.md", "endpoints.md")
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $specPath $file
    if (-not (Test-Path $filePath)) {
        Write-Host "  ERROR: Missing required file: $file" -ForegroundColor Red
        exit 1
    }
}
Write-Host "  OK: All required files present" -ForegroundColor Gray

# Check repositories exist
if (-not (Test-Path $apiRoot)) {
    Write-Host "  ERROR: cpr-api repository not found at: $apiRoot" -ForegroundColor Red
    exit 1
}
if (-not (Test-Path $uiRoot)) {
    Write-Host "  ERROR: cpr-ui repository not found at: $uiRoot" -ForegroundColor Red
    exit 1
}
Write-Host "  OK: Both repositories found" -ForegroundColor Gray

# Step 2: Check Repository State
Write-Host ""
Write-Host "[2/5] Checking repository state..." -ForegroundColor Green

# Check cpr-api
Push-Location $apiRoot
$apiCurrentBranch = git rev-parse --abbrev-ref HEAD 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: cpr-api is not a git repository" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  cpr-api: Current branch: $apiCurrentBranch" -ForegroundColor Gray

# Check for uncommitted changes in API
$apiStatus = git status --porcelain 2>$null
if ($apiStatus) {
    Write-Host "  WARNING: cpr-api has uncommitted changes" -ForegroundColor Yellow
    Write-Host "  Consider committing or stashing before creating feature branch" -ForegroundColor Yellow
}
Pop-Location

# Check cpr-ui
Push-Location $uiRoot
$uiCurrentBranch = git rev-parse --abbrev-ref HEAD 2>$null
if ($LASTEXITCODE -ne 0) {
    Write-Host "  ERROR: cpr-ui is not a git repository" -ForegroundColor Red
    Pop-Location
    exit 1
}
Write-Host "  cpr-ui: Current branch: $uiCurrentBranch" -ForegroundColor Gray

# Check for uncommitted changes in UI
$uiStatus = git status --porcelain 2>$null
if ($uiStatus) {
    Write-Host "  WARNING: cpr-ui has uncommitted changes" -ForegroundColor Yellow
    Write-Host "  Consider committing or stashing before creating feature branch" -ForegroundColor Yellow
}
Pop-Location

# Step 3: Create Feature Branches
if (-not $SkipBranchCreation) {
    Write-Host ""
    Write-Host "[3/5] Creating feature branches..." -ForegroundColor Green
    
    # Create branch in cpr-api
    Push-Location $apiRoot
    # Use show-ref to reliably check for local branch existence without printing errors
    git show-ref --verify --quiet "refs/heads/$branchName"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  cpr-api: Branch '$branchName' already exists" -ForegroundColor Yellow
        cmd /c "git checkout $branchName >nul 2>&1"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  cpr-api: Checked out existing branch" -ForegroundColor Gray
        }
        else {
            Write-Host "  ERROR: Failed to checkout existing branch '$branchName' in cpr-api" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }
    else {
        cmd /c "git checkout -b $branchName >nul 2>&1"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  cpr-api: Created and checked out branch '$branchName'" -ForegroundColor Green
        }
        else {
            Write-Host "  ERROR: Failed to create branch in cpr-api" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }
    Pop-Location
    
    # Create branch in cpr-ui
    Push-Location $uiRoot
    # Use show-ref to reliably check for local branch existence without printing errors
    git show-ref --verify --quiet "refs/heads/$branchName"
    if ($LASTEXITCODE -eq 0) {
        Write-Host "  cpr-ui: Branch '$branchName' already exists" -ForegroundColor Yellow
        cmd /c "git checkout $branchName >nul 2>&1"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  cpr-ui: Checked out existing branch" -ForegroundColor Gray
        }
        else {
            Write-Host "  ERROR: Failed to checkout existing branch '$branchName' in cpr-ui" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }
    else {
        cmd /c "git checkout -b $branchName >nul 2>&1"
        if ($LASTEXITCODE -eq 0) {
            Write-Host "  cpr-ui: Created and checked out branch '$branchName'" -ForegroundColor Green
        }
        else {
            Write-Host "  ERROR: Failed to create branch in cpr-ui" -ForegroundColor Red
            Pop-Location
            exit 1
        }
    }
    Pop-Location
}
else {
    Write-Host ""
    Write-Host "[3/5] Skipping branch creation (--SkipBranchCreation)" -ForegroundColor Gray
}

# Step 4: Parse Task Statistics
Write-Host ""
Write-Host "[4/5] Analyzing task breakdown..." -ForegroundColor Green

$tasksPath = Join-Path $specPath "tasks.md"
$tasksContent = Get-Content $tasksPath -Raw -Encoding UTF8

# Count total tasks
$totalTasks = ([regex]::Matches($tasksContent, '(?m)^-\s*\[\s*\]\s+T\d+')).Count
$completedTasks = ([regex]::Matches($tasksContent, '(?m)^-\s*\[x\]\s+T\d+')).Count
$remainingTasks = $totalTasks - $completedTasks

Write-Host "  Total tasks: $totalTasks" -ForegroundColor Gray
Write-Host "  Completed: $completedTasks" -ForegroundColor $(if ($completedTasks -gt 0) { "Green" } else { "Gray" })
Write-Host "  Remaining: $remainingTasks" -ForegroundColor $(if ($remainingTasks -gt 0) { "Yellow" } else { "Gray" })

# Count parallel tasks
$parallelTasks = ([regex]::Matches($tasksContent, '(?m)^-\s*\[\s*\]\s+T\d+\s+\[P\]')).Count
Write-Host "  Parallel opportunities: $parallelTasks tasks" -ForegroundColor Gray

# Parse phases
$phaseMatches = [regex]::Matches($tasksContent, '(?m)^##\s+Phase\s+\d+:\s+(.+)$')
$phaseCount = $phaseMatches.Count
Write-Host "  Implementation phases: $phaseCount" -ForegroundColor Gray

if ($remainingTasks -eq 0 -and $completedTasks -gt 0) {
    Write-Host ""
    Write-Host "  NOTE: All tasks already marked complete!" -ForegroundColor Yellow
    Write-Host "  If re-implementing, consider resetting tasks.md" -ForegroundColor Yellow
}

# Step 5: Generate Implementation Summary
Write-Host ""
Write-Host "[5/5] Generating implementation guide..." -ForegroundColor Green

$summaryPath = Join-Path $specPath "implementation-summary.txt"
$summary = @"
=== CPR Phase 5: Implementation Guide ===
Feature: $specFolderName
Date: $currentDate

REPOSITORIES:
- cpr-api: $apiRoot
- cpr-ui: $uiRoot

FEATURE BRANCHES:
- Branch: $branchName
- Created in both repositories

TASK BREAKDOWN:
- Total Tasks: $totalTasks
- Completed: $completedTasks
- Remaining: $remainingTasks
- Parallel Opportunities: $parallelTasks
- Phases: $phaseCount

IMPLEMENTATION APPROACH:
1. Use GitHub Copilot Chat with phase-5-implement.md prompt
2. Follow task-driven development (tasks.md)
3. Implement in phases (Setup → Foundational → User Stories → Polish)
4. Mark tasks complete as you go: [ ] → [x]
5. Commit after each phase completion
6. Run tests frequently

GITHUB COPILOT COMMAND:
@workspace Use framework/prompts/phase-5-implement.md to implement feature $FeatureNumber

CONSTITUTIONAL COMPLIANCE CHECKLIST:
- [ ] Principle 2: DTOs use snake_case JSON with [JsonPropertyName]
- [ ] Principle 4: Strong typing, no 'any' in TypeScript
- [ ] Principle 5: Offline mode with IndexedDB caching
- [ ] Principle 6: All UI text uses i18n keys
- [ ] Principle 7: Tests written (unit, integration, E2E)
- [ ] Principle 9: Naming conventions followed everywhere
- [ ] Principle 11: Database uses UUID PKs, proper indexes

KEY FILES:
- Specification: $specPath\description.md
- Implementation Plan: $specPath\implementation-plan.md
- Task List: $specPath\tasks.md
- API Contracts: $specPath\endpoints.md
- Analysis Report: $specPath\analysis-report.md

QUALITY GATES:
- Code must compile/build successfully
- All tests must pass
- No linting errors
- Constitutional compliance maintained
- All tasks marked complete before Phase 5 done

NEXT ACTIONS:
1. Open GitHub Copilot Chat in VS Code
2. Navigate to cpr-api or cpr-ui in terminal
3. Use prompt: @workspace Use framework/prompts/phase-5-implement.md to implement feature $FeatureNumber
4. Follow task breakdown in tasks.md
5. Update progress.md regularly
6. Commit and push frequently

IMPLEMENTATION ORDER:
Phase 1: Setup & Project Structure (backend entities, DTOs, types)
Phase 2: Foundational (repositories, services, base components)
Phase 3+: User Stories (one at a time, backend + frontend)
Final: Polish (error handling, i18n, tests, documentation)

TIPS:
- Start with backend (API provides contract for frontend)
- Write tests before implementation (TDD)
- Use parallel tasks to speed up development
- Reference existing code for patterns
- Ask Copilot for help with boilerplate
- Test frequently, commit often

=== Ready to Begin Implementation ===
"@

$summary | Set-Content $summaryPath -Encoding UTF8
Write-Host "  Created: implementation-summary.txt" -ForegroundColor Green

# Final Output
Write-Host ""
Write-Host "=== Phase 5 Preparation Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Status: " -NoNewline
Write-Host "READY TO IMPLEMENT" -ForegroundColor Green
Write-Host ""

Write-Host "Next Steps:" -ForegroundColor White
Write-Host "1. Open GitHub Copilot Chat in VS Code" -ForegroundColor Gray
Write-Host "2. Use this command:" -ForegroundColor Gray
Write-Host "   @workspace Use framework/prompts/phase-5-implement.md to implement feature $FeatureNumber" -ForegroundColor Cyan
Write-Host ""
Write-Host "3. Follow the task breakdown in:" -ForegroundColor Gray
Write-Host "   $specPath\tasks.md" -ForegroundColor Cyan
Write-Host ""
Write-Host "4. Mark tasks complete as you implement: [ ] -> [x]" -ForegroundColor Gray
Write-Host "5. Commit after each phase: git commit -m 'feat($FeatureNumber): Phase X complete'" -ForegroundColor Gray
Write-Host ""

Write-Host "Implementation Summary: " -NoNewline -ForegroundColor White
Write-Host "$specPath\implementation-summary.txt" -ForegroundColor Cyan
Write-Host ""

Write-Host "Good luck with implementation!" -ForegroundColor Green
Write-Host ""
