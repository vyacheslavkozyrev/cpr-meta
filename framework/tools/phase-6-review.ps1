<#
.SYNOPSIS
    CPR Phase 6: Code Review

.DESCRIPTION
    Performs automated code review checks including build validation, test execution,
    linting analysis, complexity metrics, and git history quality. Generates
    automation-review.json for AI-assisted comprehensive review.

.PARAMETER FeatureNumber
    Four-digit feature number (e.g., 0001, 0042)

.PARAMETER FeatureName
    Short kebab-case feature name (e.g., user-profile-management)

.EXAMPLE
    .\framework\tools\phase-6-review.ps1 -FeatureNumber "0001" -FeatureName "personal-goal-creation-management"
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
$cprRoot = Split-Path $metaRoot -Parent
$apiRoot = Join-Path $cprRoot "cpr-api"
$uiRoot = Join-Path $cprRoot "cpr-ui"

$specFolderName = "$FeatureNumber-$FeatureName"
$specPath = Join-Path $metaRoot "specifications\$specFolderName"
$branchName = "feature/$FeatureNumber-$FeatureName"
$currentDate = Get-Date -Format 'yyyy-MM-dd'

# Review results
$reviewData = @{
    metadata           = @{
        feature_number = $FeatureNumber
        feature_name   = $FeatureName
        review_date    = $currentDate
        tool_version   = "1.0.0"
        repositories   = @{
            cpr_api_branch = $branchName
            cpr_ui_branch  = $branchName
        }
    }
    validation_summary = @{
        phase_5_complete            = $false
        all_required_files_exist    = $false
        tasks_completion_percentage = 0
        total_tasks                 = 0
        completed_tasks             = 0
        remaining_tasks             = 0
    }
    build_status       = @{
        cpr_api = @{
            status               = "NOT_RUN"
            compilation_errors   = 0
            compilation_warnings = 0
            build_time_seconds   = 0
            target_framework     = ".NET 8.0"
            configuration        = "Debug"
            errors               = @()
        }
        cpr_ui  = @{
            status             = "NOT_RUN"
            build_errors       = 0
            build_warnings     = 0
            build_time_seconds = 0
            bundle_size_kb     = 0
            configuration      = "development"
            errors             = @()
        }
    }
    test_results       = @{
        cpr_api = @{
            status           = "NOT_RUN"
            total_tests      = 0
            passed           = 0
            failed           = 0
            skipped          = 0
            duration_seconds = 0
            coverage         = @{
                line_coverage_percent   = 0
                branch_coverage_percent = 0
                method_coverage_percent = 0
                meets_threshold         = $false
                threshold_percent       = 80
            }
            test_suites      = @{
                unit_tests        = @{
                    total   = 0
                    passed  = 0
                    failed  = 0
                    skipped = 0
                }
                integration_tests = @{
                    total   = 0
                    passed  = 0
                    failed  = 0
                    skipped = 0
                }
            }
            failed_tests     = @()
        }
        cpr_ui  = @{
            status           = "NOT_RUN"
            total_tests      = 0
            passed           = 0
            failed           = 0
            skipped          = 0
            duration_seconds = 0
            coverage         = @{
                line_coverage_percent      = 0
                branch_coverage_percent    = 0
                function_coverage_percent  = 0
                statement_coverage_percent = 0
                meets_threshold            = $false
                threshold_percent          = 80
            }
            test_suites      = @{
                component_tests   = @{
                    total   = 0
                    passed  = 0
                    failed  = 0
                    skipped = 0
                }
                hook_tests        = @{
                    total   = 0
                    passed  = 0
                    failed  = 0
                    skipped = 0
                }
                integration_tests = @{
                    total   = 0
                    passed  = 0
                    failed  = 0
                    skipped = 0
                }
            }
            failed_tests     = @()
        }
    }
    linting_analysis   = @{
        cpr_api = @{
            status       = "NOT_RUN"
            total_issues = 0
            errors       = 0
            warnings     = 0
            info         = 0
            tool         = "dotnet format"
            issues       = @()
        }
        cpr_ui  = @{
            status       = "NOT_RUN"
            total_issues = 0
            errors       = 0
            warnings     = 0
            tool         = "ESLint"
            issues       = @()
        }
    }
    complexity_metrics = @{
        cpr_api = @{
            total_files_analyzed          = 0
            average_cyclomatic_complexity = 0
            max_cyclomatic_complexity     = 0
            files_above_threshold         = @()
            threshold                     = 15
            methods_above_threshold       = @()
        }
        cpr_ui  = @{
            total_files_analyzed          = 0
            average_cyclomatic_complexity = 0
            max_cyclomatic_complexity     = 0
            files_above_threshold         = @()
            threshold                     = 15
            functions_above_threshold     = @()
        }
    }
    git_analysis       = @{
        cpr_api = @{
            branch_name                    = $branchName
            total_commits                  = 0
            conventional_commits           = 0
            non_conventional_commits       = 0
            conventional_commit_percentage = 0
            commits_behind_main            = 0
            has_merge_conflicts            = $false
            uncommitted_changes            = $false
            commit_quality_issues          = @()
        }
        cpr_ui  = @{
            branch_name                    = $branchName
            total_commits                  = 0
            conventional_commits           = 0
            non_conventional_commits       = 0
            conventional_commit_percentage = 0
            commits_behind_main            = 0
            has_merge_conflicts            = $false
            uncommitted_changes            = $false
            commit_quality_issues          = @()
        }
    }
    file_statistics    = @{
        cpr_api = @{
            files_added         = 0
            files_modified      = 0
            files_deleted       = 0
            total_lines_added   = 0
            total_lines_deleted = 0
            net_lines_changed   = 0
            file_types          = @{
                cs    = 0
                json  = 0
                sql   = 0
                other = 0
            }
        }
        cpr_ui  = @{
            files_added         = 0
            files_modified      = 0
            files_deleted       = 0
            total_lines_added   = 0
            total_lines_deleted = 0
            net_lines_changed   = 0
            file_types          = @{
                tsx   = 0
                ts    = 0
                css   = 0
                json  = 0
                other = 0
            }
        }
    }
    automated_findings = @()
    automated_score    = @{
        total_points = 100
        deductions   = @()
        final_score  = 100
        status       = "PASS"
    }
    summary            = @{
        critical_issues         = 0
        high_issues             = 0
        medium_issues           = 0
        low_issues              = 0
        total_issues            = 0
        automated_quality_score = 100
        ready_for_ai_review     = $true
        blocking_issues         = @()
    }
    recommendations    = @()
}

# Helper Functions
function Add-Finding {
    param(
        [string]$Id,
        [string]$Severity,
        [string]$Category,
        [string]$Title,
        [string]$Description,
        [string]$Location,
        [string]$Details,
        [string]$Remediation
    )
    
    $finding = @{
        id          = $Id
        severity    = $Severity
        category    = $Category
        title       = $Title
        description = $Description
        location    = $Location
        details     = $Details
        remediation = $Remediation
    }
    
    $reviewData.automated_findings += $finding
    
    # Update summary counts
    switch ($Severity) {
        "CRITICAL" { $reviewData.summary.critical_issues++ }
        "HIGH" { $reviewData.summary.high_issues++ }
        "MEDIUM" { $reviewData.summary.medium_issues++ }
        "LOW" { $reviewData.summary.low_issues++ }
    }
    $reviewData.summary.total_issues++
    
    # Add to blocking issues if CRITICAL
    if ($Severity -eq "CRITICAL") {
        $reviewData.summary.blocking_issues += $Title
        $reviewData.summary.ready_for_ai_review = $false
    }
}

function Add-Deduction {
    param(
        [string]$Category,
        [string]$Severity,
        [int]$Points,
        [string]$Reason
    )
    
    $deduction = @{
        category = $Category
        severity = $Severity
        points   = $Points
        reason   = $Reason
    }
    
    $reviewData.automated_score.deductions += $deduction
    $reviewData.automated_score.final_score = [Math]::Max(0, $reviewData.automated_score.final_score - $Points)
}

function Test-CommandExists {
    param([string]$Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

Write-Host ""
Write-Host "=== CPR Phase 6: Code Review ===" -ForegroundColor Cyan
Write-Host "Feature: $specFolderName" -ForegroundColor Yellow
Write-Host "Review Date: $currentDate" -ForegroundColor Gray
Write-Host ""

# Step 1: Validate Prerequisites
Write-Host "[1/8] Validating prerequisites..." -ForegroundColor Green

# Check specification exists
if (-not (Test-Path $specPath)) {
    Write-Host "  ERROR: Specification folder not found: $specPath" -ForegroundColor Red
    Write-Host "  Please run Phase 1 first." -ForegroundColor Yellow
    exit 1
}
Write-Host "  OK: Specification folder exists" -ForegroundColor Gray

# Check required files
$requiredFiles = @("description.md", "implementation-plan.md", "tasks.md", "endpoints.md", "progress.md")
$allFilesExist = $true
foreach ($file in $requiredFiles) {
    $filePath = Join-Path $specPath $file
    if (-not (Test-Path $filePath)) {
        Write-Host "  ERROR: Missing required file: $file" -ForegroundColor Red
        $allFilesExist = $false
    }
}

if (-not $allFilesExist) {
    Write-Host "  ERROR: Not all required files exist" -ForegroundColor Red
    exit 1
}

$reviewData.validation_summary.all_required_files_exist = $true
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

# Step 2: Check Task Completion
Write-Host ""
Write-Host "[2/8] Checking task completion..." -ForegroundColor Green

$tasksPath = Join-Path $specPath "tasks.md"
$tasksContent = Get-Content $tasksPath -Raw -Encoding UTF8

$totalTasks = ([regex]::Matches($tasksContent, '(?m)^-\s*\[\s*\]\s+T\d+')).Count + 
([regex]::Matches($tasksContent, '(?m)^-\s*\[x\]\s+T\d+')).Count
$completedTasks = ([regex]::Matches($tasksContent, '(?m)^-\s*\[x\]\s+T\d+')).Count
$remainingTasks = $totalTasks - $completedTasks

$reviewData.validation_summary.total_tasks = $totalTasks
$reviewData.validation_summary.completed_tasks = $completedTasks
$reviewData.validation_summary.remaining_tasks = $remainingTasks

if ($totalTasks -gt 0) {
    $completionPercentage = [Math]::Round(($completedTasks / $totalTasks) * 100, 2)
    $reviewData.validation_summary.tasks_completion_percentage = $completionPercentage
}
else {
    $completionPercentage = 0
}

Write-Host "  Total tasks: $totalTasks" -ForegroundColor Gray
Write-Host "  Completed: $completedTasks ($completionPercentage%)" -ForegroundColor $(if ($completedTasks -eq $totalTasks) { "Green" } else { "Yellow" })
Write-Host "  Remaining: $remainingTasks" -ForegroundColor $(if ($remainingTasks -gt 0) { "Yellow" } else { "Gray" })

if ($completionPercentage -lt 100) {
    Add-Finding -Id "AUTO-001" -Severity "CRITICAL" -Category "Completeness" `
        -Title "Incomplete Task List" `
        -Description "Only $completionPercentage% of tasks marked complete (Expected: 100%)" `
        -Location "tasks.md" `
        -Details "$remainingTasks tasks still marked as incomplete" `
        -Remediation "Complete all remaining tasks before code review. Phase 5 must be 100% done."
    
    Write-Host "  ERROR: Not all tasks complete. Phase 5 must be finished before Phase 6." -ForegroundColor Red
}
else {
    $reviewData.validation_summary.phase_5_complete = $true
    Write-Host "  OK: All tasks marked complete" -ForegroundColor Green
}

# Step 3: Build Status Check
Write-Host ""
Write-Host "[3/8] Checking build status..." -ForegroundColor Green

# Backend Build
Write-Host "  Backend (cpr-api)..." -ForegroundColor Gray
Push-Location $apiRoot
try {
    $buildStart = Get-Date
    $buildOutput = dotnet build src/CPR.sln --configuration Debug --no-restore 2>&1
    $buildEnd = Get-Date
    $buildTime = ($buildEnd - $buildStart).TotalSeconds
    
    if ($LASTEXITCODE -eq 0) {
        $reviewData.build_status.cpr_api.status = "PASS"
        $reviewData.build_status.cpr_api.build_time_seconds = [Math]::Round($buildTime, 2)
        Write-Host "    Build: PASS ($([Math]::Round($buildTime, 1))s)" -ForegroundColor Green
    }
    else {
        $reviewData.build_status.cpr_api.status = "FAIL"
        $reviewData.build_status.cpr_api.build_time_seconds = [Math]::Round($buildTime, 2)
        
        # Parse errors and warnings
        $errorLines = $buildOutput | Select-String "error CS\d+:" -AllMatches
        $warningLines = $buildOutput | Select-String "warning CS\d+:" -AllMatches
        
        $reviewData.build_status.cpr_api.compilation_errors = $errorLines.Count
        $reviewData.build_status.cpr_api.compilation_warnings = $warningLines.Count
        $reviewData.build_status.cpr_api.errors = @($errorLines | ForEach-Object { $_.Line })
        
        Write-Host "    Build: FAIL" -ForegroundColor Red
        Write-Host "    Errors: $($errorLines.Count)" -ForegroundColor Red
        Write-Host "    Warnings: $($warningLines.Count)" -ForegroundColor Yellow
        
        Add-Finding -Id "AUTO-002" -Severity "CRITICAL" -Category "Build" `
            -Title "Backend Build Failure" `
            -Description "cpr-api solution failed to compile with $($errorLines.Count) error(s)" `
            -Location "cpr-api/src/CPR.sln" `
            -Details ($errorLines -join "`n") `
            -Remediation "Fix all compilation errors. Run 'dotnet build' in cpr-api and resolve errors."
    }
}
catch {
    $reviewData.build_status.cpr_api.status = "ERROR"
    Write-Host "    Build: ERROR - $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

# Frontend Build
Write-Host "  Frontend (cpr-ui)..." -ForegroundColor Gray
Push-Location $uiRoot
try {
    if (Test-Path "package.json") {
        $buildStart = Get-Date
        $buildOutput = npm run build 2>&1
        $buildEnd = Get-Date
        $buildTime = ($buildEnd - $buildStart).TotalSeconds
        
        if ($LASTEXITCODE -eq 0) {
            $reviewData.build_status.cpr_ui.status = "PASS"
            $reviewData.build_status.cpr_ui.build_time_seconds = [Math]::Round($buildTime, 2)
            
            # Get bundle size if dist folder exists
            $distPath = Join-Path $uiRoot "dist"
            if (Test-Path $distPath) {
                $size = (Get-ChildItem -Path $distPath -Recurse | Measure-Object -Property Length -Sum).Sum / 1KB
                $reviewData.build_status.cpr_ui.bundle_size_kb = [Math]::Round($size, 2)
            }
            
            Write-Host "    Build: PASS ($([Math]::Round($buildTime, 1))s)" -ForegroundColor Green
        }
        else {
            $reviewData.build_status.cpr_ui.status = "FAIL"
            $reviewData.build_status.cpr_ui.build_time_seconds = [Math]::Round($buildTime, 2)
            
            # Parse errors
            $errorLines = $buildOutput | Select-String "error|failed" -AllMatches
            $reviewData.build_status.cpr_ui.build_errors = $errorLines.Count
            $reviewData.build_status.cpr_ui.errors = @($errorLines | ForEach-Object { $_.Line })
            
            Write-Host "    Build: FAIL" -ForegroundColor Red
            
            Add-Finding -Id "AUTO-003" -Severity "CRITICAL" -Category "Build" `
                -Title "Frontend Build Failure" `
                -Description "cpr-ui failed to build" `
                -Location "cpr-ui/" `
                -Details ($errorLines -join "`n") `
                -Remediation "Fix build errors. Run 'npm run build' in cpr-ui and resolve issues."
        }
    }
    else {
        Write-Host "    Skipped (no package.json)" -ForegroundColor Gray
    }
}
catch {
    $reviewData.build_status.cpr_ui.status = "ERROR"
    Write-Host "    Build: ERROR - $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

# Step 4: Test Execution
Write-Host ""
Write-Host "[4/8] Running tests..." -ForegroundColor Green

# Backend Tests
Write-Host "  Backend tests..." -ForegroundColor Gray
Push-Location $apiRoot
try {
    $testStart = Get-Date
    $testOutput = dotnet test src/CPR.sln --configuration Debug --no-build --verbosity quiet 2>&1
    $testEnd = Get-Date
    $testTime = ($testEnd - $testStart).TotalSeconds
    
    $reviewData.test_results.cpr_api.duration_seconds = [Math]::Round($testTime, 2)
    
    # Parse test results
    if ($testOutput -match 'Passed!\s+-\s+Failed:\s+(\d+),\s+Passed:\s+(\d+),\s+Skipped:\s+(\d+),\s+Total:\s+(\d+)') {
        $failed = [int]$Matches[1]
        $passed = [int]$Matches[2]
        $skipped = [int]$Matches[3]
        $total = [int]$Matches[4]
        
        $reviewData.test_results.cpr_api.status = if ($failed -eq 0) { "PASS" } else { "FAIL" }
        $reviewData.test_results.cpr_api.total_tests = $total
        $reviewData.test_results.cpr_api.passed = $passed
        $reviewData.test_results.cpr_api.failed = $failed
        $reviewData.test_results.cpr_api.skipped = $skipped
        
        Write-Host "    Tests: $passed passed, $failed failed, $skipped skipped ($([Math]::Round($testTime, 1))s)" -ForegroundColor $(if ($failed -eq 0) { "Green" } else { "Red" })
        
        if ($failed -gt 0) {
            # Extract failed test names
            $failedTests = $testOutput | Select-String "^\s+X\s+" | ForEach-Object { $_.Line.Trim() }
            $reviewData.test_results.cpr_api.failed_tests = @($failedTests)
            
            Add-Finding -Id "AUTO-004" -Severity "HIGH" -Category "Testing" `
                -Title "Backend Test Failures" `
                -Description "$failed test(s) failing in cpr-api" `
                -Location "cpr-api/tests/" `
                -Details ($failedTests -join "`n") `
                -Remediation "Fix failing tests. All tests must pass before proceeding to Phase 7."
        }
    }
    else {
        Write-Host "    Tests: Could not parse results" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "    Tests: ERROR - $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

# Frontend Tests
Write-Host "  Frontend tests..." -ForegroundColor Gray
Push-Location $uiRoot
try {
    if (Test-Path "package.json") {
        $testStart = Get-Date
        $testOutput = npm test -- --run 2>&1
        $testEnd = Get-Date
        $testTime = ($testEnd - $testStart).TotalSeconds
        
        $reviewData.test_results.cpr_ui.duration_seconds = [Math]::Round($testTime, 2)
        
        # Parse Vitest output
        if ($testOutput -match 'Tests\s+(\d+)\s+passed') {
            $passed = [int]$Matches[1]
            $reviewData.test_results.cpr_ui.passed = $passed
            $reviewData.test_results.cpr_ui.total_tests = $passed
            $reviewData.test_results.cpr_ui.status = "PASS"
            Write-Host "    Tests: $passed passed ($([Math]::Round($testTime, 1))s)" -ForegroundColor Green
        }
        elseif ($testOutput -match 'FAIL') {
            $reviewData.test_results.cpr_ui.status = "FAIL"
            Write-Host "    Tests: FAIL" -ForegroundColor Red
            
            Add-Finding -Id "AUTO-005" -Severity "HIGH" -Category "Testing" `
                -Title "Frontend Test Failures" `
                -Description "Tests failing in cpr-ui" `
                -Location "cpr-ui/" `
                -Details "Check test output for details" `
                -Remediation "Fix failing tests. Run 'npm test' and resolve issues."
        }
        else {
            Write-Host "    Tests: No tests found or could not parse" -ForegroundColor Yellow
        }
    }
}
catch {
    Write-Host "    Tests: ERROR - $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

# Step 5: Linting Analysis
Write-Host ""
Write-Host "[5/8] Running linting..." -ForegroundColor Green

# Backend Linting
Write-Host "  Backend linting..." -ForegroundColor Gray
Push-Location $apiRoot
try {
    $lintOutput = dotnet format src/CPR.sln --verify-no-changes --verbosity quiet 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        $reviewData.linting_analysis.cpr_api.status = "PASS"
        Write-Host "    Linting: PASS" -ForegroundColor Green
    }
    else {
        $reviewData.linting_analysis.cpr_api.status = "FAIL"
        $issueCount = ($lintOutput | Select-String "would be formatted" -AllMatches).Count
        $reviewData.linting_analysis.cpr_api.total_issues = $issueCount
        $reviewData.linting_analysis.cpr_api.warnings = $issueCount
        
        Write-Host "    Linting: $issueCount formatting issue(s)" -ForegroundColor Yellow
        
        if ($issueCount -gt 0) {
            Add-Finding -Id "AUTO-006" -Severity "MEDIUM" -Category "Code Quality" `
                -Title "Backend Formatting Issues" `
                -Description "$issueCount file(s) need formatting" `
                -Location "cpr-api/src/" `
                -Details "Run 'dotnet format' to see details" `
                -Remediation "Run 'dotnet format src/CPR.sln' to fix formatting issues."
        }
    }
}
catch {
    Write-Host "    Linting: Not available (dotnet format not found)" -ForegroundColor Gray
}
finally {
    Pop-Location
}

# Frontend Linting
Write-Host "  Frontend linting..." -ForegroundColor Gray
Push-Location $uiRoot
try {
    if (Test-Path "package.json") {
        $lintOutput = npm run lint 2>&1
        
        # Parse ESLint output
        $errorLines = $lintOutput | Select-String "✖\s+\d+\s+problem" -AllMatches
        if ($errorLines) {
            if ($lintOutput -match '(\d+)\s+error') {
                $errors = [int]$Matches[1]
            }
            else { $errors = 0 }
            
            if ($lintOutput -match '(\d+)\s+warning') {
                $warnings = [int]$Matches[1]
            }
            else { $warnings = 0 }
            
            $reviewData.linting_analysis.cpr_ui.errors = $errors
            $reviewData.linting_analysis.cpr_ui.warnings = $warnings
            $reviewData.linting_analysis.cpr_ui.total_issues = $errors + $warnings
            $reviewData.linting_analysis.cpr_ui.status = if ($errors -eq 0) { "PASS" } else { "FAIL" }
            
            Write-Host "    Linting: $errors error(s), $warnings warning(s)" -ForegroundColor $(if ($errors -eq 0) { "Green" } else { "Red" })
            
            if ($errors -gt 0) {
                Add-Finding -Id "AUTO-007" -Severity "MEDIUM" -Category "Code Quality" `
                    -Title "Frontend Linting Errors" `
                    -Description "$errors ESLint error(s) in cpr-ui" `
                    -Location "cpr-ui/src/" `
                    -Details "Run 'npm run lint' for details" `
                    -Remediation "Fix ESLint errors. Some may be auto-fixable with 'npm run lint -- --fix'."
            }
        }
        else {
            $reviewData.linting_analysis.cpr_ui.status = "PASS"
            Write-Host "    Linting: PASS" -ForegroundColor Green
        }
    }
}
catch {
    Write-Host "    Linting: ERROR - $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

# Step 6: Git Analysis
Write-Host ""
Write-Host "[6/8] Analyzing git history..." -ForegroundColor Green

# Backend Git Analysis
Write-Host "  Backend git history..." -ForegroundColor Gray
Push-Location $apiRoot
try {
    # Check if on feature branch
    $currentBranch = git rev-parse --abbrev-ref HEAD 2>&1
    
    if ($currentBranch -eq $branchName) {
        # Count commits on feature branch
        $commits = git log main..$branchName --oneline 2>&1
        $commitCount = ($commits | Measure-Object).Count
        $reviewData.git_analysis.cpr_api.total_commits = $commitCount
        
        # Check conventional commits
        $conventionalCount = 0
        foreach ($commit in $commits) {
            if ($commit -match '^\w{7}\s+(feat|fix|docs|style|refactor|test|chore)\(') {
                $conventionalCount++
            }
        }
        
        $reviewData.git_analysis.cpr_api.conventional_commits = $conventionalCount
        $reviewData.git_analysis.cpr_api.non_conventional_commits = $commitCount - $conventionalCount
        
        if ($commitCount -gt 0) {
            $conventionalPercentage = [Math]::Round(($conventionalCount / $commitCount) * 100, 2)
            $reviewData.git_analysis.cpr_api.conventional_commit_percentage = $conventionalPercentage
        }
        
        Write-Host "    Commits: $commitCount ($conventionalCount conventional, $conventionalPercentage%)" -ForegroundColor Gray
        
        # Check if behind main
        $behindCount = (git rev-list --count $branchName..main 2>&1)
        if ($behindCount -match '^\d+$') {
            $reviewData.git_analysis.cpr_api.commits_behind_main = [int]$behindCount
            if ([int]$behindCount -gt 0) {
                Write-Host "    Branch is $behindCount commit(s) behind main" -ForegroundColor Yellow
            }
        }
        
        # Check for uncommitted changes
        $status = git status --porcelain 2>&1
        if ($status) {
            $reviewData.git_analysis.cpr_api.uncommitted_changes = $true
            Write-Host "    WARNING: Uncommitted changes detected" -ForegroundColor Yellow
        }
        
        # File statistics
        $diffStats = git diff --numstat main..$branchName 2>&1
        if ($diffStats) {
            $added = 0
            $deleted = 0
            $fileTypes = @{}
            
            foreach ($line in $diffStats) {
                if ($line -match '^(\d+)\s+(\d+)\s+(.+)$') {
                    $added += [int]$Matches[1]
                    $deleted += [int]$Matches[2]
                    $file = $Matches[3]
                    
                    $ext = [System.IO.Path]::GetExtension($file).TrimStart('.')
                    if (-not $ext) { $ext = "other" }
                    
                    if (-not $fileTypes.ContainsKey($ext)) {
                        $fileTypes[$ext] = 0
                    }
                    $fileTypes[$ext]++
                }
            }
            
            $reviewData.file_statistics.cpr_api.total_lines_added = $added
            $reviewData.file_statistics.cpr_api.total_lines_deleted = $deleted
            $reviewData.file_statistics.cpr_api.net_lines_changed = $added - $deleted
            $reviewData.file_statistics.cpr_api.files_modified = $fileTypes.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum
            
            if ($fileTypes.ContainsKey("cs")) { $reviewData.file_statistics.cpr_api.file_types.cs = $fileTypes["cs"] }
            if ($fileTypes.ContainsKey("json")) { $reviewData.file_statistics.cpr_api.file_types.json = $fileTypes["json"] }
            if ($fileTypes.ContainsKey("sql")) { $reviewData.file_statistics.cpr_api.file_types.sql = $fileTypes["sql"] }
            
            Write-Host "    Changes: +$added/-$deleted lines in $($fileTypes.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum) files" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "    Not on feature branch (current: $currentBranch)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "    Git analysis: ERROR - $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

# Frontend Git Analysis
Write-Host "  Frontend git history..." -ForegroundColor Gray
Push-Location $uiRoot
try {
    $currentBranch = git rev-parse --abbrev-ref HEAD 2>&1
    
    if ($currentBranch -eq $branchName) {
        $commits = git log main..$branchName --oneline 2>&1
        $commitCount = ($commits | Measure-Object).Count
        $reviewData.git_analysis.cpr_ui.total_commits = $commitCount
        
        $conventionalCount = 0
        foreach ($commit in $commits) {
            if ($commit -match '^\w{7}\s+(feat|fix|docs|style|refactor|test|chore)\(') {
                $conventionalCount++
            }
        }
        
        $reviewData.git_analysis.cpr_ui.conventional_commits = $conventionalCount
        $reviewData.git_analysis.cpr_ui.non_conventional_commits = $commitCount - $conventionalCount
        
        if ($commitCount -gt 0) {
            $conventionalPercentage = [Math]::Round(($conventionalCount / $commitCount) * 100, 2)
            $reviewData.git_analysis.cpr_ui.conventional_commit_percentage = $conventionalPercentage
        }
        
        Write-Host "    Commits: $commitCount ($conventionalCount conventional, $conventionalPercentage%)" -ForegroundColor Gray
        
        # File statistics
        $diffStats = git diff --numstat main..$branchName 2>&1
        if ($diffStats) {
            $added = 0
            $deleted = 0
            $fileTypes = @{}
            
            foreach ($line in $diffStats) {
                if ($line -match '^(\d+)\s+(\d+)\s+(.+)$') {
                    $added += [int]$Matches[1]
                    $deleted += [int]$Matches[2]
                    $file = $Matches[3]
                    
                    $ext = [System.IO.Path]::GetExtension($file).TrimStart('.')
                    if (-not $ext) { $ext = "other" }
                    
                    if (-not $fileTypes.ContainsKey($ext)) {
                        $fileTypes[$ext] = 0
                    }
                    $fileTypes[$ext]++
                }
            }
            
            $reviewData.file_statistics.cpr_ui.total_lines_added = $added
            $reviewData.file_statistics.cpr_ui.total_lines_deleted = $deleted
            $reviewData.file_statistics.cpr_ui.net_lines_changed = $added - $deleted
            $reviewData.file_statistics.cpr_ui.files_modified = $fileTypes.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum
            
            if ($fileTypes.ContainsKey("tsx")) { $reviewData.file_statistics.cpr_ui.file_types.tsx = $fileTypes["tsx"] }
            if ($fileTypes.ContainsKey("ts")) { $reviewData.file_statistics.cpr_ui.file_types.ts = $fileTypes["ts"] }
            if ($fileTypes.ContainsKey("css")) { $reviewData.file_statistics.cpr_ui.file_types.css = $fileTypes["css"] }
            if ($fileTypes.ContainsKey("json")) { $reviewData.file_statistics.cpr_ui.file_types.json = $fileTypes["json"] }
            
            Write-Host "    Changes: +$added/-$deleted lines in $($fileTypes.Values | Measure-Object -Sum | Select-Object -ExpandProperty Sum) files" -ForegroundColor Gray
        }
    }
    else {
        Write-Host "    Not on feature branch (current: $currentBranch)" -ForegroundColor Yellow
    }
}
catch {
    Write-Host "    Git analysis: ERROR - $_" -ForegroundColor Red
}
finally {
    Pop-Location
}

# Step 7: Calculate Score
Write-Host ""
Write-Host "[7/8] Calculating automated score..." -ForegroundColor Green

$score = 100

# Build failures = CRITICAL (automatic 0)
if ($reviewData.build_status.cpr_api.status -eq "FAIL" -or $reviewData.build_status.cpr_ui.status -eq "FAIL") {
    Add-Deduction -Category "Build" -Severity "CRITICAL" -Points 100 -Reason "Build failures detected"
    $score = 0
}
else {
    Add-Deduction -Category "Build" -Severity "NONE" -Points 0 -Reason "All builds passing"
}

# Test failures = HIGH (-15 per repository)
if ($reviewData.test_results.cpr_api.failed -gt 0) {
    Add-Deduction -Category "Tests" -Severity "HIGH" -Points 15 -Reason "Backend test failures"
    $score -= 15
}
if ($reviewData.test_results.cpr_ui.failed -gt 0) {
    Add-Deduction -Category "Tests" -Severity "HIGH" -Points 15 -Reason "Frontend test failures"
    $score -= 15
}
if ($reviewData.test_results.cpr_api.failed -eq 0 -and $reviewData.test_results.cpr_ui.failed -eq 0) {
    Add-Deduction -Category "Tests" -Severity "NONE" -Points 0 -Reason "All tests passing"
}

# Linting errors = MEDIUM (-5)
$totalLintingErrors = $reviewData.linting_analysis.cpr_api.errors + $reviewData.linting_analysis.cpr_ui.errors
if ($totalLintingErrors -gt 0) {
    Add-Deduction -Category "Linting" -Severity "MEDIUM" -Points 5 -Reason "$totalLintingErrors linting error(s)"
    $score -= 5
}
else {
    Add-Deduction -Category "Linting" -Severity "NONE" -Points 0 -Reason "No linting errors"
}

# Low conventional commit percentage = LOW (-1 to -5)
$avgConventionalPercentage = ($reviewData.git_analysis.cpr_api.conventional_commit_percentage + 
    $reviewData.git_analysis.cpr_ui.conventional_commit_percentage) / 2
if ($avgConventionalPercentage -lt 80 -and $avgConventionalPercentage -gt 0) {
    $deduction = [Math]::Ceiling((100 - $avgConventionalPercentage) / 20)
    Add-Deduction -Category "Git" -Severity "LOW" -Points $deduction -Reason "Only $([Math]::Round($avgConventionalPercentage, 0))% conventional commits"
    $score -= $deduction
}
else {
    Add-Deduction -Category "Git" -Severity "NONE" -Points 0 -Reason "Good commit quality"
}

$reviewData.automated_score.final_score = [Math]::Max(0, $score)
$reviewData.automated_score.status = if ($score -ge 85) { "PASS" } elseif ($score -ge 70) { "CONDITIONAL" } else { "FAIL" }
$reviewData.summary.automated_quality_score = $reviewData.automated_score.final_score

Write-Host "  Automated Score: $($reviewData.automated_score.final_score)/100" -ForegroundColor $(
    if ($reviewData.automated_score.final_score -ge 85) { "Green" } 
    elseif ($reviewData.automated_score.final_score -ge 70) { "Yellow" } 
    else { "Red" }
)

# Step 8: Generate Recommendations
Write-Host ""
Write-Host "[8/8] Generating recommendations..." -ForegroundColor Green

if ($reviewData.summary.blocking_issues.Count -gt 0) {
    $reviewData.recommendations += "CRITICAL: Fix blocking issues before proceeding"
    foreach ($issue in $reviewData.summary.blocking_issues) {
        $reviewData.recommendations += "  - $issue"
    }
}
elseif ($reviewData.automated_score.final_score -ge 85) {
    $reviewData.recommendations += "Proceed with AI-assisted semantic code review using phase-6-review.md prompt"
    $reviewData.recommendations += "Focus AI review on architecture, business logic, and constitutional compliance"
    $reviewData.recommendations += "Automated checks show good baseline quality"
}
elseif ($reviewData.automated_score.final_score -ge 70) {
    $reviewData.recommendations += "Address HIGH severity issues before full AI review"
    $reviewData.recommendations += "Consider proceeding with AI review in parallel to save time"
    $reviewData.recommendations += "Must achieve 85+ final score to proceed to Phase 7"
}
else {
    $reviewData.recommendations += "Automated score too low for AI review"
    $reviewData.recommendations += "Fix CRITICAL and HIGH issues first"
    $reviewData.recommendations += "Re-run this tool after fixes"
}

# Save automation-review.json
$outputPath = Join-Path $specPath "automation-review.json"
$reviewData | ConvertTo-Json -Depth 10 | Set-Content $outputPath -Encoding UTF8

Write-Host "  Saved: automation-review.json" -ForegroundColor Green

# Final Summary
Write-Host ""
Write-Host "=== Automated Review Complete ===" -ForegroundColor Cyan
Write-Host ""

Write-Host "Status: " -NoNewline
$statusColor = if ($reviewData.automated_score.final_score -ge 85) { "Green" } 
elseif ($reviewData.automated_score.final_score -ge 70) { "Yellow" } 
else { "Red" }
Write-Host $reviewData.automated_score.status -ForegroundColor $statusColor
Write-Host ""

Write-Host "Findings:" -ForegroundColor White
Write-Host "  CRITICAL: $($reviewData.summary.critical_issues)" -ForegroundColor $(if ($reviewData.summary.critical_issues -gt 0) { "Red" } else { "Gray" })
Write-Host "  HIGH:     $($reviewData.summary.high_issues)" -ForegroundColor $(if ($reviewData.summary.high_issues -gt 0) { "Red" } else { "Gray" })
Write-Host "  MEDIUM:   $($reviewData.summary.medium_issues)" -ForegroundColor $(if ($reviewData.summary.medium_issues -gt 0) { "Yellow" } else { "Gray" })
Write-Host "  LOW:      $($reviewData.summary.low_issues)" -ForegroundColor $(if ($reviewData.summary.low_issues -gt 0) { "Yellow" } else { "Gray" })
Write-Host ""

Write-Host "Automated Score: " -NoNewline -ForegroundColor White
Write-Host "$($reviewData.automated_score.final_score)/100" -ForegroundColor $statusColor
Write-Host ""

if ($reviewData.summary.ready_for_ai_review) {
    Write-Host "Next Steps:" -ForegroundColor White
    Write-Host "1. Review automated findings in:" -ForegroundColor Gray
    Write-Host "   $outputPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Run AI-assisted comprehensive review:" -ForegroundColor Gray
    Write-Host "   @workspace Use framework/prompts/phase-6-review.md to review feature $FeatureNumber" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. AI review will generate:" -ForegroundColor Gray
    Write-Host "   - review-report.md with detailed findings" -ForegroundColor Gray
    Write-Host "   - Final approval decision (APPROVED/CONDITIONAL/REJECTED)" -ForegroundColor Gray
    Write-Host ""
}
else {
    Write-Host "Next Steps:" -ForegroundColor White
    Write-Host "1. Fix CRITICAL issues:" -ForegroundColor Red
    foreach ($issue in $reviewData.summary.blocking_issues) {
        Write-Host "   - $issue" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "2. Re-run this tool after fixes" -ForegroundColor Gray
    Write-Host "3. Must pass automated checks before AI review" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "Automation report saved: " -NoNewline -ForegroundColor White
Write-Host "$outputPath" -ForegroundColor Cyan
Write-Host ""

if (-not $reviewData.summary.ready_for_ai_review) {
    Write-Host "Review BLOCKED: Fix critical issues first" -ForegroundColor Red
    Write-Host ""
    exit 1
}

Write-Host "Ready for AI-assisted review!" -ForegroundColor Green
Write-Host ""
