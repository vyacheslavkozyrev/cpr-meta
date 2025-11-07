<#
.SYNOPSIS
    CPR Phase 3: Plan Implementation

.DESCRIPTION
    Creates implementation planning artifacts from templates for a feature.
    
    Steps:
    1. Verify specification folder and description.md exist
    2. Create mandatory planning documents:
       - implementation-plan.md
       - tasks.md
       - endpoints.md
    3. Create optional planning documents based on flags:
       - data-model.md (if -IncludeDataModel)
       - research.md (if -IncludeResearch)
    4. Update progress.md to track Phase 3

.PARAMETER FeatureNumber
    Four-digit feature number (e.g., 0001, 0042)

.PARAMETER FeatureName
    Short kebab-case feature name (e.g., user-profile-management)

.PARAMETER IncludeDataModel
    Include data-model.md template (use if feature requires database changes)

.PARAMETER IncludeResearch
    Include research.md template (use if feature involves technical decisions)

.EXAMPLE
    .\framework\tools\phase-3-plan.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
    
.EXAMPLE
    .\framework\tools\phase-3-plan.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management" -IncludeDataModel -IncludeResearch
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d{4}$')]
    [string]$FeatureNumber,
    
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*$')]
    [string]$FeatureName,
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeDataModel,
    
    [Parameter(Mandatory = $false)]
    [switch]$IncludeResearch
)

$ErrorActionPreference = "Stop"

# Paths
$metaRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$specFolderName = "$FeatureNumber-$FeatureName"
$specPath = Join-Path $metaRoot "specifications\$specFolderName"
$templatesPath = Join-Path $metaRoot "framework\templates"

Write-Host "`n=== CPR Phase 3: Plan Implementation ===" -ForegroundColor Cyan
Write-Host "Feature: $specFolderName" -ForegroundColor Yellow
Write-Host ""

# Step 1: Verify prerequisites
Write-Host "[1/3] Verifying prerequisites..." -ForegroundColor Green

if (-not (Test-Path $specPath)) {
    Write-Host "  ERROR: Specification folder not found: $specPath" -ForegroundColor Red
    Write-Host "  Please run Phase 1 first: .\framework\tools\phase-1-specify.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "  SUCCESS: Specification folder exists" -ForegroundColor Green

$descriptionPath = Join-Path $specPath "description.md"
if (-not (Test-Path $descriptionPath)) {
    Write-Host "  ERROR: description.md not found in specification folder" -ForegroundColor Red
    Write-Host "  Please complete Phase 1 and Phase 2 first" -ForegroundColor Yellow
    exit 1
}
Write-Host "  SUCCESS: description.md exists" -ForegroundColor Green

# Check if Phase 2 is complete (optional warning)
$descriptionContent = Get-Content $descriptionPath -Raw -Encoding UTF8
if ($descriptionContent -match '\[TODO\]|\[FILL IN\]|\[PLACEHOLDER\]') {
    Write-Host "  WARNING: description.md appears incomplete (contains TODO/FILL IN markers)" -ForegroundColor Yellow
    $continue = Read-Host "  Continue with Phase 3 anyway? (y/n)"
    if ($continue -ne 'y') {
        Write-Host "  Aborted. Please complete Phase 2 first." -ForegroundColor Red
        exit 1
    }
}

# Step 2: Create mandatory planning documents
Write-Host "`n[2/3] Creating mandatory planning documents..." -ForegroundColor Green

$currentDate = Get-Date -Format 'yyyy-MM-dd'
$filesCreated = @()

# Helper function to create file from template
function New-PlanningDocument {
    param(
        [string]$TemplateName,
        [string]$TargetFileName,
        [bool]$IsMandatory = $true
    )
    
    $templatePath = Join-Path $templatesPath $TemplateName
    $targetPath = Join-Path $specPath $TargetFileName
    
    if (-not (Test-Path $templatePath)) {
        Write-Host "  ERROR: Template not found: $templatePath" -ForegroundColor Red
        if ($IsMandatory) {
            exit 1
        }
        return $false
    }
    
    if (Test-Path $targetPath) {
        Write-Host "  WARNING: File already exists: $TargetFileName" -ForegroundColor Yellow
        $overwrite = Read-Host "  Overwrite? (y/n)"
        if ($overwrite -ne 'y') {
            Write-Host "  SKIPPED: $TargetFileName" -ForegroundColor Gray
            return $false
        }
    }
    
    $template = Get-Content $templatePath -Raw -Encoding UTF8
    $template = $template -replace '\[Feature Number\]', $FeatureNumber
    $template = $template -replace '\[Short Feature Name\]', $FeatureName
    $template = $template -replace '\[Feature Name\]', ($FeatureName -replace '-', ' ' | ForEach-Object { (Get-Culture).TextInfo.ToTitleCase($_) })
    $template = $template -replace '\[Date\]', $currentDate
    $template = $template -replace '\[####\]', $FeatureNumber
    $template = $template -replace '<short-feature-name>', $FeatureName
    $template = $template -replace '<name>', $FeatureName
    
    Set-Content -Path $targetPath -Value $template -Encoding UTF8 -NoNewline
    Write-Host "  SUCCESS: Created: $TargetFileName" -ForegroundColor Green
    return $true
}

# Create mandatory documents
if (New-PlanningDocument "implementation-plan.md" "implementation-plan.md" $true) {
    $filesCreated += "implementation-plan.md"
}

if (New-PlanningDocument "tasks.md" "tasks.md" $true) {
    $filesCreated += "tasks.md"
}

if (New-PlanningDocument "endpoints.md" "endpoints.md" $true) {
    $filesCreated += "endpoints.md"
}

# Step 3: Create optional planning documents
Write-Host "`n[3/3] Creating optional planning documents..." -ForegroundColor Green

if ($IncludeDataModel) {
    if (New-PlanningDocument "data-model.md" "data-model.md" $false) {
        $filesCreated += "data-model.md"
    }
}
else {
    Write-Host "  SKIPPED: data-model.md (use -IncludeDataModel flag to include)" -ForegroundColor Gray
}

if ($IncludeResearch) {
    if (New-PlanningDocument "research.md" "research.md" $false) {
        $filesCreated += "research.md"
    }
}
else {
    Write-Host "  SKIPPED: research.md (use -IncludeResearch flag to include)" -ForegroundColor Gray
}

# Step 4: Update progress.md
Write-Host "`n[4/4] Updating progress tracking..." -ForegroundColor Green

$progressPath = Join-Path $specPath "progress.md"
if (Test-Path $progressPath) {
    $progressContent = Get-Content $progressPath -Raw -Encoding UTF8
    
    # Add Phase 3 section if not already present
    if ($progressContent -notmatch '## Phase 3: Plan Implementation') {
        $phase3Section = @"

---

## Phase 3: Plan Implementation

**Status**: 🚧 In Progress  
**Started**: $currentDate  
**Completed**: -

### Artifacts Created
"@
        foreach ($file in $filesCreated) {
            $phase3Section += "`n- ✅ $file"
        }
        
        $phase3Section += @"


### Checklist

- [ ] Implementation plan completed
- [ ] Tasks broken down and prioritized
- [ ] API endpoints defined with contracts
- [ ] Data model designed (if applicable)
- [ ] Technical decisions documented (if applicable)
- [ ] Constitutional compliance verified
- [ ] Effort estimation completed
- [ ] Risk assessment completed

### Next Steps

Use GitHub Copilot with `framework/prompts/phase-3-plan.md` to populate the planning documents.
"@
        
        $progressContent += $phase3Section
        Set-Content -Path $progressPath -Value $progressContent -Encoding UTF8 -NoNewline
        Write-Host "  SUCCESS: Updated progress.md with Phase 3 tracking" -ForegroundColor Green
    }
    else {
        Write-Host "  INFO: Phase 3 section already exists in progress.md" -ForegroundColor Gray
    }
}

# Summary
Write-Host "`n=== Phase 3 Initialization Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Specification: specifications/$specFolderName/" -ForegroundColor White
Write-Host ""
Write-Host "Files Created:" -ForegroundColor White
foreach ($file in $filesCreated) {
    Write-Host "  ✅ $file" -ForegroundColor Green
}
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Open the planning documents in specifications/$specFolderName/" -ForegroundColor White
Write-Host "  2. Use GitHub Copilot with the Phase 3 prompt:" -ForegroundColor White
Write-Host "     - Open: framework/prompts/phase-3-plan.md" -ForegroundColor Gray
Write-Host "     - Reference: specifications/$specFolderName/description.md" -ForegroundColor Gray
Write-Host "  3. Fill in the planning templates with comprehensive details" -ForegroundColor White
Write-Host "  4. Verify constitutional compliance in implementation-plan.md" -ForegroundColor White
Write-Host "  5. Review and validate all planning documents" -ForegroundColor White
Write-Host "  6. Update progress.md when Phase 3 is complete" -ForegroundColor White
Write-Host ""
Write-Host "Tip: Use '@workspace How should I plan implementation for $specFolderName?' in Copilot Chat" -ForegroundColor Cyan
Write-Host ""
