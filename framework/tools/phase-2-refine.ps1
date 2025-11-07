<#
.SYNOPSIS
    CPR Phase 2: Refine Specification

.DESCRIPTION
    Validates prerequisites and prepares for Phase 2 refinement process.
    
    Steps:
    1. Verify specification folder exists (from Phase 1)
    2. Verify description.md exists and is not empty
    3. Check if description.md appears to be filled in (not just template)
    4. Update progress.md to track Phase 2 start

.PARAMETER FeatureNumber
    Four-digit feature number (e.g., 0001, 0042)

.PARAMETER FeatureName
    Short kebab-case feature name (e.g., user-profile-management)

.EXAMPLE
    .\framework\tools\phase-2-refine.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
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
$specFolderName = "$FeatureNumber-$FeatureName"
$specPath = Join-Path $metaRoot "specifications\$specFolderName"
$descriptionPath = Join-Path $specPath "description.md"
$progressPath = Join-Path $specPath "progress.md"

Write-Host "`n=== CPR Phase 2: Refine Specification ===" -ForegroundColor Cyan
Write-Host "Feature: $specFolderName" -ForegroundColor Yellow
Write-Host ""

# Step 1: Verify specification folder exists
Write-Host "[1/4] Verifying specification folder..." -ForegroundColor Green

if (-not (Test-Path $specPath)) {
    Write-Host "  ERROR: Specification folder not found: specifications/$specFolderName/" -ForegroundColor Red
    Write-Host "  Please run Phase 1 first:" -ForegroundColor Yellow
    Write-Host "    .\framework\tools\phase-1-specify.ps1 -FeatureNumber `"$FeatureNumber`" -FeatureName `"$FeatureName`"" -ForegroundColor Gray
    exit 1
}
Write-Host "  SUCCESS: Specification folder exists" -ForegroundColor Green

# Step 2: Verify description.md exists
Write-Host "`n[2/4] Verifying description.md..." -ForegroundColor Green

if (-not (Test-Path $descriptionPath)) {
    Write-Host "  ERROR: description.md not found in specification folder" -ForegroundColor Red
    Write-Host "  Please complete Phase 1 first" -ForegroundColor Yellow
    exit 1
}
Write-Host "  SUCCESS: description.md exists" -ForegroundColor Green

# Step 3: Check if description.md is filled in
Write-Host "`n[3/4] Checking description.md content..." -ForegroundColor Green

$descriptionContent = Get-Content $descriptionPath -Raw -Encoding UTF8

# Check for common template placeholders
$templateMarkers = @(
    '\[TODO\]',
    '\[FILL IN\]',
    '\[PLACEHOLDER\]',
    '\[Your content here\]',
    '\[Describe\]',
    '\[List\]',
    '\[Specify\]',
    '\[Define\]',
    '{{.*}}',  # Template variables like {{FEATURE_NAME}}
    'Executive Summary\s*\n\s*\n\s*##'  # Empty section
)

$foundPlaceholders = @()
foreach ($marker in $templateMarkers) {
    if ($descriptionContent -match $marker) {
        $foundPlaceholders += $marker
    }
}

if ($foundPlaceholders.Count -gt 0) {
    Write-Host "  WARNING: description.md appears incomplete" -ForegroundColor Yellow
    Write-Host "  Found template placeholders:" -ForegroundColor Yellow
    foreach ($placeholder in $foundPlaceholders) {
        Write-Host "    - $placeholder" -ForegroundColor Gray
    }
    Write-Host ""
    Write-Host "  Phase 2 is for refining an already filled specification." -ForegroundColor Yellow
    Write-Host "  Please complete Phase 1 by filling in description.md first." -ForegroundColor Yellow
    Write-Host ""
    $continue = Read-Host "  Continue with Phase 2 anyway? (y/n)"
    if ($continue -ne 'y') {
        Write-Host "  Aborted. Please complete Phase 1 first." -ForegroundColor Red
        exit 1
    }
}
else {
    Write-Host "  SUCCESS: description.md appears to be filled in" -ForegroundColor Green
}

# Step 4: Update progress.md
Write-Host "`n[4/4] Updating progress tracking..." -ForegroundColor Green

$currentDate = Get-Date -Format 'yyyy-MM-dd'

if (Test-Path $progressPath) {
    $progressContent = Get-Content $progressPath -Raw -Encoding UTF8
    
    # Add Phase 2 section if not already present
    if ($progressContent -notmatch '## Phase 2: Refine Specification') {
        $phase2Section = @"

---

## Phase 2: Refine Specification

**Status**: 🚧 In Progress  
**Started**: $currentDate  
**Completed**: -

### Checklist

- [ ] User stories analyzed for completeness
- [ ] Clarifying questions generated for each user story
- [ ] Stakeholder interview conducted
- [ ] All questions answered and documented
- [ ] Edge cases and error scenarios added to acceptance criteria
- [ ] Business rules refined with new insights
- [ ] API design updated (if needed)
- [ ] Technical requirements enhanced with specifics
- [ ] UX mockups generated (Mermaid diagrams)
- [ ] No contradictions in specification
- [ ] Constitutional compliance verified
- [ ] Stakeholder sign-off obtained

### Next Steps

Use GitHub Copilot with ``framework/prompts/phase-2-refine.md`` to:
1. Analyze the specification for ambiguities
2. Generate clarifying questions
3. Document answers and update description.md
4. Generate UX mockups with Mermaid diagrams
5. Validate completeness
"@
        
        $progressContent += $phase2Section
        Set-Content -Path $progressPath -Value $progressContent -Encoding UTF8 -NoNewline
        Write-Host "  SUCCESS: Updated progress.md with Phase 2 tracking" -ForegroundColor Green
    }
    else {
        Write-Host "  INFO: Phase 2 section already exists in progress.md" -ForegroundColor Gray
    }
}
else {
    Write-Host "  WARNING: progress.md not found - Phase 1 may be incomplete" -ForegroundColor Yellow
}

# Summary
Write-Host "`n=== Phase 2 Ready to Start ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Specification: specifications/$specFolderName/description.md" -ForegroundColor White
Write-Host "Status: Ready for refinement" -ForegroundColor Green
Write-Host ""
Write-Host "Next Steps:" -ForegroundColor Yellow
Write-Host "  1. Open: specifications/$specFolderName/description.md" -ForegroundColor White
Write-Host "  2. Review the current specification content" -ForegroundColor White
Write-Host "  3. Use GitHub Copilot with the Phase 2 prompt:" -ForegroundColor White
Write-Host "     - Open: framework/prompts/phase-2-refine.md" -ForegroundColor Gray
Write-Host "     - Reference: specifications/$specFolderName/description.md" -ForegroundColor Gray
Write-Host "  4. Generate clarifying questions for each user story" -ForegroundColor White
Write-Host "  5. Conduct stakeholder interview to answer questions" -ForegroundColor White
Write-Host "  6. Update description.md with clarifications" -ForegroundColor White
Write-Host "  7. Generate UX mockups with Mermaid diagrams" -ForegroundColor White
Write-Host "  8. Validate completeness and get stakeholder sign-off" -ForegroundColor White
Write-Host "  9. Update progress.md when Phase 2 is complete" -ForegroundColor White
Write-Host ""
Write-Host "Tip: Use '@workspace Analyze $specFolderName specification for Phase 2' in Copilot Chat" -ForegroundColor Cyan
Write-Host ""
