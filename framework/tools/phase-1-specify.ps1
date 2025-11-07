<#
.SYNOPSIS
    CPR Phase 1: Specify Feature

.DESCRIPTION
    Creates specification folder structure and git branches for a new feature.
    
    Steps:
    1. Create specification folder: specifications/####-<feature-name>/
    2. Create git branches in cpr-api and cpr-ui: feature/####-<feature-name>
    3. Generate description.md from template
    4. Generate progress.md from template

.PARAMETER FeatureNumber
    Four-digit feature number (e.g., 0001, 0042)

.PARAMETER FeatureName
    Short kebab-case feature name (e.g., user-profile-management)

.EXAMPLE
    .\framework\tools\phase-1-specify.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
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

# Paths
$metaRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$cprRoot = Split-Path $metaRoot -Parent
$apiRoot = Join-Path $cprRoot "cpr-api"
$uiRoot = Join-Path $cprRoot "cpr-ui"

$specFolderName = "$FeatureNumber-$FeatureName"
$specPath = Join-Path $metaRoot "specifications\$specFolderName"
$branchName = "feature/$FeatureNumber-$FeatureName"

Write-Host "`n=== CPR Phase 1: Specify Feature ===" -ForegroundColor Cyan
Write-Host "Feature: $specFolderName" -ForegroundColor Yellow
Write-Host ""

# Step 1: Create specification folder
Write-Host "[1/3] Creating specification folder..." -ForegroundColor Green
if (Test-Path $specPath) {
    Write-Host "  WARNING: Specification folder already exists: $specPath" -ForegroundColor Yellow
    $continue = Read-Host "  Continue anyway? (y/n)"
    if ($continue -ne 'y') {
        Write-Host "  Aborted." -ForegroundColor Red
        exit 1
    }
}
else {
    New-Item -ItemType Directory -Path $specPath -Force | Out-Null
    Write-Host "  SUCCESS: Created: specifications/$specFolderName/" -ForegroundColor Green
}

# Step 2: Create git branches
Write-Host "`n[2/3] Creating git branches..." -ForegroundColor Green

# Create branch in cpr-api
if (Test-Path $apiRoot) {
    Push-Location $apiRoot
    try {
        $currentBranch = git branch --show-current 2>$null
        $branchExists = git branch --list $branchName 2>$null
        
        if ($branchExists) {
            Write-Host "  WARNING: Branch already exists in cpr-api: $branchName" -ForegroundColor Yellow
        }
        else {
            git checkout -b $branchName 2>&1 | Out-Null
            Write-Host "  SUCCESS: Created branch in cpr-api: $branchName" -ForegroundColor Green
            git checkout $currentBranch 2>&1 | Out-Null
        }
    }
    catch {
        Write-Host "  ERROR: Error creating branch in cpr-api: $_" -ForegroundColor Red
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host "  WARNING: cpr-api repository not found at: $apiRoot" -ForegroundColor Yellow
}

# Create branch in cpr-ui
if (Test-Path $uiRoot) {
    Push-Location $uiRoot
    try {
        $currentBranch = git branch --show-current 2>$null
        $branchExists = git branch --list $branchName 2>$null
        
        if ($branchExists) {
            Write-Host "  WARNING: Branch already exists in cpr-ui: $branchName" -ForegroundColor Yellow
        }
        else {
            git checkout -b $branchName 2>&1 | Out-Null
            Write-Host "  SUCCESS: Created branch in cpr-ui: $branchName" -ForegroundColor Green
            git checkout $currentBranch 2>&1 | Out-Null
        }
    }
    catch {
        Write-Host "  ERROR: Error creating branch in cpr-ui: $_" -ForegroundColor Red
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host "  WARNING: cpr-ui repository not found at: $uiRoot" -ForegroundColor Yellow
}

# Step 3: Generate specification files from templates
Write-Host "`n[3/4] Creating specification files from templates..." -ForegroundColor Green

$currentDate = Get-Date -Format 'yyyy-MM-dd'

# Create description.md
$descriptionTemplatePath = Join-Path $metaRoot "framework\templates\description.md"
$descriptionPath = Join-Path $specPath "description.md"

if (-not (Test-Path $descriptionTemplatePath)) {
    Write-Host "  ERROR: Template not found: $descriptionTemplatePath" -ForegroundColor Red
    exit 1
}

$descriptionTemplate = Get-Content $descriptionTemplatePath -Raw -Encoding UTF8
$descriptionTemplate = $descriptionTemplate -replace '{{FEATURE_NUMBER}}', $FeatureNumber
$descriptionTemplate = $descriptionTemplate -replace '{{FEATURE_NAME}}', $FeatureName
$descriptionTemplate = $descriptionTemplate -replace '{{CREATED_DATE}}', $currentDate

Set-Content -Path $descriptionPath -Value $descriptionTemplate -Encoding UTF8 -NoNewline
Write-Host "  SUCCESS: Created: $specFolderName/description.md" -ForegroundColor Green

# Create progress.md
$progressTemplatePath = Join-Path $metaRoot "framework\templates\progress.md"
$progressPath = Join-Path $specPath "progress.md"

if (-not (Test-Path $progressTemplatePath)) {
    Write-Host "  ERROR: Template not found: $progressTemplatePath" -ForegroundColor Red
    exit 1
}

$progressTemplate = Get-Content $progressTemplatePath -Raw -Encoding UTF8
$progressTemplate = $progressTemplate -replace '{{FEATURE_NUMBER}}', $FeatureNumber
$progressTemplate = $progressTemplate -replace '{{FEATURE_NAME}}', $FeatureName
$progressTemplate = $progressTemplate -replace '{{CREATED_DATE}}', $currentDate

Set-Content -Path $progressPath -Value $progressTemplate -Encoding UTF8 -NoNewline
Write-Host "  SUCCESS: Created: $specFolderName/progress.md" -ForegroundColor Green

# Summary
Write-Host "`n=== Phase 1 Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Specification: specifications/$specFolderName/" -ForegroundColor White
Write-Host "Branches: feature/$FeatureNumber-$FeatureName" -ForegroundColor White
Write-Host "Files Created:" -ForegroundColor White
Write-Host "  - $specFolderName/description.md" -ForegroundColor Gray
Write-Host "  - $specFolderName/progress.md" -ForegroundColor Gray
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Open: specifications/$specFolderName/description.md" -ForegroundColor White
Write-Host "  2. Use GitHub Copilot to fill in the specification template" -ForegroundColor White
Write-Host "  3. Review and validate constitutional compliance" -ForegroundColor White
Write-Host "  4. Update progress.md as you complete Phase 1 checklist items" -ForegroundColor White
Write-Host ""
