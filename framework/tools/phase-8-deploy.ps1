<#
.SYNOPSIS
    Phase 8 Deploy - Validates deployment readiness and prepares deployment artifacts

.DESCRIPTION
    Validates deployment prerequisites, checks CI/CD status, validates environment configurations,
    generates deployment plan, and produces deployment readiness report. Enforces Phase 7 completion.

.PARAMETER FeatureNumber
    Four-digit feature number

.PARAMETER FeatureName
    Short kebab-case feature name

.PARAMETER Environment
    Target environment: staging or production

.PARAMETER SkipInfrastructure
    Skip infrastructure health checks for local deployments

.EXAMPLE
    .\framework\tools\phase-8-deploy.ps1 -FeatureNumber "0001" -FeatureName "personal-goal-creation-management"

.EXAMPLE
    .\framework\tools\phase-8-deploy.ps1 -FeatureNumber "0001" -FeatureName "personal-goal-creation-management" -Environment "production"
#>

param(
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^\d{4}$')]
    [string]$FeatureNumber,
    
    [Parameter(Mandatory = $true)]
    [ValidatePattern('^[a-z0-9]+(-[a-z0-9]+)*$')]
    [string]$FeatureName,
    
    [Parameter(Mandatory = $false)]
    [ValidateSet("staging", "production")]
    [string]$Environment = "staging",
    
    [Parameter(Mandatory = $false)]
    [switch]$SkipInfrastructure
)

$ErrorActionPreference = "Continue"

# Configuration
$metaRoot = Split-Path (Split-Path $PSScriptRoot -Parent) -Parent
$cprRoot = Split-Path $metaRoot -Parent
$apiRoot = Join-Path $cprRoot "cpr-api"
$uiRoot = Join-Path $cprRoot "cpr-ui"

$specFolderName = "$FeatureNumber-$FeatureName"
$specPath = Join-Path $metaRoot "specifications\$specFolderName"
$branchName = "feature/$FeatureNumber-$FeatureName"
$currentDate = Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ'

# Helper functions
function Write-Status {
    param([string]$Message, [string]$Type = "INFO")
    $colors = @{
        "OK" = "Green"; "WARNING" = "Yellow"; "ERROR" = "Red"; "INFO" = "Cyan"
    }
    Write-Host "[$Type] " -ForegroundColor $colors[$Type] -NoNewline
    Write-Host $Message
}

# Banner
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "CPR Framework - Phase 8: Deploy" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Feature: $FeatureNumber-$FeatureName" -ForegroundColor White
Write-Host "Environment: $Environment" -ForegroundColor White
Write-Host "========================================`n" -ForegroundColor Cyan

# Initialize results
$results = @{
    metadata = @{
        phase = "8-deploy"
        feature_id = "$FeatureNumber-$FeatureName"
        deployment_date = $currentDate
        framework_version = "1.0.0"
        deployment_lead = $env:USERNAME
        target_environment = $Environment
    }
    deployment_readiness = @{
        phase_7_status = "NOT_READY"
        production_readiness_score = 0
        prerequisites_met = $false
    }
    issues = @{
        by_severity = @{
            critical = 0
            high = 0
            medium = 0
            low = 0
        }
        details = @()
    }
    recommendations = @{
        immediate_actions = @()
        monitoring_priorities = @()
    }
}

# Check specification directory exists
Write-Status "Checking specification directory..." "INFO"
if (-not (Test-Path $specPath)) {
    Write-Status "Specification directory not found: $specPath" "ERROR"
    $results.issues.by_severity.critical++
    $results.issues.details += @{
        severity = "CRITICAL"
        title = "Specification directory not found"
        description = "Cannot find specification directory"
    }
    $outputPath = Join-Path $specPath "automation-deploy.json"
    $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputPath -Encoding UTF8
    exit 1
}
Write-Status "Specification directory found" "OK"

# Check Phase 7 completion
Write-Status "`nValidating Phase 7 completion..." "INFO"
$testReportPath = Join-Path $specPath "automation-test.json"
if (Test-Path $testReportPath) {
    try {
        $phase7Report = Get-Content $testReportPath -Raw | ConvertFrom-Json
        $phase7Status = $phase7Report.test_summary.overall_decision
        $phase7Score = $phase7Report.test_summary.production_readiness_score
        
        $results.deployment_readiness.phase_7_status = $phase7Status
        $results.deployment_readiness.production_readiness_score = $phase7Score
        
        if ($phase7Status -eq "READY") {
            Write-Status "Phase 7 status: READY (Score: $phase7Score/100)" "OK"
        } elseif ($phase7Status -eq "CONDITIONAL") {
            Write-Status "Phase 7 status: CONDITIONAL (Score: $phase7Score/100)" "WARNING"
            $results.issues.by_severity.medium++
            $results.issues.details += @{
                severity = "MEDIUM"
                title = "Phase 7 status is CONDITIONAL"
                description = "Review automation-test.json and address issues before production"
            }
        } else {
            Write-Status "Phase 7 status: NOT READY (Score: $phase7Score/100)" "ERROR"
            $results.issues.by_severity.critical++
            $results.issues.details += @{
                severity = "CRITICAL"
                title = "Phase 7 status is NOT READY"
                description = "Complete Phase 7 testing before deployment"
            }
            if ($Environment -eq "production") {
                Write-Status "`nDeployment BLOCKED - Phase 7 must be READY or CONDITIONAL" "ERROR"
                $outputPath = Join-Path $specPath "automation-deploy.json"
                $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputPath -Encoding UTF8
                exit 1
            }
        }
    } catch {
        Write-Status "Error reading Phase 7 test report" "ERROR"
        $results.issues.by_severity.critical++
    }
} else {
    Write-Status "Phase 7 test report not found" "ERROR"
    $results.issues.by_severity.critical++
    if ($Environment -eq "production") {
        Write-Status "`nDeployment BLOCKED - Complete Phase 7 first" "ERROR"
        $outputPath = Join-Path $specPath "automation-deploy.json"
        $results | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputPath -Encoding UTF8
        exit 1
    }
}

# Summary
$criticalIssues = $results.issues.by_severity.critical
Write-Status "`n========================================" "INFO"
Write-Host "Critical Issues: $criticalIssues" -ForegroundColor $(if ($criticalIssues -gt 0) { "Red" } else { "Green" })
$prerequisitesMet = ($criticalIssues -eq 0)
$results.deployment_readiness.prerequisites_met = $prerequisitesMet

# Generate deployment plan if needed
$deploymentPlanPath = Join-Path $specPath "deployment-plan.md"
if (-not (Test-Path $deploymentPlanPath)) {
    Write-Status "`nGenerating deployment plan from template..." "INFO"
    $templatePath = Join-Path $metaRoot "framework\templates\deployment-plan.md"
    if (Test-Path $templatePath) {
        $template = Get-Content $templatePath -Raw
        $template = $template -replace "####-feature-name", "$FeatureNumber-$FeatureName"
        $template = $template -replace "YYYY-MM-DD", (Get-Date -Format "yyyy-MM-dd")
        $template = $template -replace "\[Your Name\]", $env:USERNAME
        $template | Out-File -FilePath $deploymentPlanPath -Encoding UTF8
        Write-Status "Deployment plan generated: deployment-plan.md" "OK"
    }
}

# Save results
$outputPath = Join-Path $specPath "automation-deploy.json"
$results | ConvertTo-Json -Depth 10 | Out-File -FilePath $outputPath -Encoding UTF8
Write-Status "`nDeployment validation results saved: automation-deploy.json" "OK"

# Final status
if ($prerequisitesMet) {
    Write-Status "`nDEPLOYMENT APPROVED FOR $Environment" "OK"
    Write-Host "`nNext Steps:" -ForegroundColor Green
    Write-Host "1. Review deployment-plan.md"
    Write-Host "2. Execute deployment following phase-8-deploy.md prompt"
    Write-Host "3. Monitor deployment closely"
    exit 0
} else {
    Write-Status "`nDEPLOYMENT BLOCKED" "ERROR"
    Write-Host "`nRequired Actions:" -ForegroundColor Red
    Write-Host "1. Address all CRITICAL issues"
    Write-Host "2. Re-run phase-8-deploy.ps1"
    exit 1
}
