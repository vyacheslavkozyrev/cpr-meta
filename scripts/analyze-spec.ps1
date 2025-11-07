# CPR Specification Analyzer
<#
.SYNOPSIS
    Performs cross-artifact consistency and quality analysis across spec.md, plan.md, and tasks.md

.DESCRIPTION
    Analyzes specification artifacts for inconsistencies, gaps, ambiguities, and constitution violations.
    Produces a structured report with actionable recommendations and quality scoring.

.PARAMETER FeaturePath
    Path to the feature directory containing spec.md, plan.md, and tasks.md files.
    Defaults to current directory.

.PARAMETER Arguments
    Optional context arguments to include in the analysis report.

.PARAMETER Json
    Output results in JSON format instead of formatted text.

.PARAMETER Remediation
    Offer interactive remediation suggestions after analysis.

.PARAMETER MaxFindings
    Maximum number of findings to include in the report (default: 50).
    Additional findings are summarized as overflow.

.EXAMPLE
    .\analyze-spec.ps1 -FeaturePath ".\user-auth-feature"
    
.EXAMPLE
    .\analyze-spec.ps1 -FeaturePath "." -MaxFindings 25 -Remediation
    
.EXAMPLE
    .\analyze-spec.ps1 -Json | ConvertFrom-Json | Select-Object Metrics
#>

param(
    [string]$FeaturePath = (Get-Location),
    [string]$Arguments = "",
    [switch]$Json,
    [switch]$Remediation,
    [int]$MaxFindings = 50
)

# Import the constitution and templates
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$metaRoot = Split-Path -Parent $scriptDir
$constitutionPath = Join-Path $metaRoot "constitution.md"
$templatePath = Join-Path $metaRoot "templates\spec-analysis-report-template.md"

Write-Host "CPR Specification Analysis" -ForegroundColor Cyan
Write-Host "Feature Path: $FeaturePath" -ForegroundColor Gray

# Step 1: Initialize Analysis Context
Write-Host "`nStep 1: Checking Prerequisites..." -ForegroundColor Yellow

$prereqScript = Join-Path $scriptDir "check-prerequisites.ps1"
try {
    $prereqResult = & $prereqScript -Json -RequireTasks -IncludeTasks -FeaturePath $FeaturePath | ConvertFrom-Json
}
catch {
    Write-Host "Failed to run prerequisites check: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

if ($prereqResult.Status -eq "Error") {
    Write-Host "Prerequisites check failed:" -ForegroundColor Red
    $prereqResult.Errors | ForEach-Object { Write-Host "   $_" -ForegroundColor Red }
    Write-Host "`nResolution: Ensure spec.md, plan.md, and tasks.md exist in the feature directory." -ForegroundColor Yellow
    exit 1
}

$SPEC = Join-Path $prereqResult.FeatureDir "spec.md"
$PLAN = Join-Path $prereqResult.FeatureDir "plan.md"
$TASKS = Join-Path $prereqResult.FeatureDir "tasks.md"

# Suppress PSUseDeclaredVarsMoreThanAssignments for variables used in Test-Path conditions
$null = $SPEC, $PLAN, $TASKS

Write-Host "Prerequisites met. Found: $($prereqResult.AvailableDocs -join ', ')" -ForegroundColor Green

# Step 2: Load Artifacts (Progressive Disclosure)
Write-Host "`nStep 2: Loading Artifacts..." -ForegroundColor Yellow

$analysis = @{
    Timestamp    = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    FeaturePath  = $prereqResult.FeatureDir
    Arguments    = $Arguments
    Constitution = @{ Principles = @(); Content = "" }
    Requirements = @()
    UserStories  = @()
    Plan         = @{ ArchitectureChoices = @(); DataModelReferences = @(); TechnicalConstraints = @(); Phases = @() }
    Tasks        = @()
    Findings     = @()
    Metrics      = @{
        TotalRequirements = 0
        TotalTasks        = 0
        CoveragePercent   = 0
        AmbiguityCount    = 0
        DuplicationCount  = 0
        CriticalIssues    = 0
    }
}

# Load Constitution
if (Test-Path $constitutionPath) {
    $constitutionContent = Get-Content $constitutionPath -Raw
    $analysis.Constitution.Content = $constitutionContent
    
    # Extract principles (simplified parsing)
    $principles = @()
    if ($constitutionContent -match "(?ms)## Core Principles.*?(?=^##|\z)") {
        $principlesSection = $matches[0]
        $principleMatches = [regex]::Matches($principlesSection, "(?ms)### Statement\s*\*\*(.+?)\*\*")
        foreach ($match in $principleMatches) {
            $principles += $match.Groups[1].Value
        }
    }
    $analysis.Constitution.Principles = $principles
    Write-Host "   Constitution loaded: $($principles.Count) principles found" -ForegroundColor Gray
}
else {
    Write-Host "   Constitution not found at $constitutionPath" -ForegroundColor Yellow
}

# Load Spec (extract requirements)
if (Test-Path $SPEC) {
    $specContent = Get-Content $SPEC -Raw
    
    # Extract functional requirements (simplified)
    $requirements = @()
    if ($specContent -match "(?ms)## Functional Requirements.*?(?=^##|\z)") {
        $reqSection = $matches[0]
        $reqMatches = [regex]::Matches($reqSection, "(?m)^[-*]\s+(.+)$")
        foreach ($match in $reqMatches) {
            $reqText = $match.Groups[1].Value
            $reqKey = $reqText -replace "[^\w\s]", "" -replace "\s+", "-"
            $reqKey = $reqKey.ToLower()
            $requirements += @{
                Key      = $reqKey
                Text     = $reqText
                Type     = "Functional"
                HasTasks = $false
                TaskIds  = @()
            }
        }
    }
    
    # Extract user stories
    $userStories = @()
    if ($specContent -match "(?ms)## User Stories.*?(?=^##|\z)") {
        $storiesSection = $matches[0]
        $storyMatches = [regex]::Matches($storiesSection, "(?ms)### (.+?)\n(.+?)(?=^###|\z)")
        foreach ($match in $storyMatches) {
            $userStories += @{
                Title                 = $match.Groups[1].Value
                Content               = $match.Groups[2].Value
                HasAcceptanceCriteria = $match.Groups[2].Value -match "Acceptance Criteria"
            }
        }
    }
    
    $analysis.Requirements = $requirements
    $analysis.UserStories = $userStories
    $analysis.Metrics.TotalRequirements = $requirements.Count
    
    Write-Host "   Spec loaded: $($requirements.Count) requirements, $($userStories.Count) user stories" -ForegroundColor Gray
}

# Load Plan (extract architecture and data model info)
$planData = @{
    ArchitectureChoices  = @()
    DataModelReferences  = @()
    TechnicalConstraints = @()
    Phases               = @()
}

if (Test-Path $PLAN) {
    $planContent = Get-Content $PLAN -Raw
    
    # Extract architecture choices
    if ($planContent -match "(?ms)## Architecture.*?(?=^##|\z)") {
        $archSection = $matches[0]
        $archMatches = [regex]::Matches($archSection, "(?m)^[-*]\s+(.+)$")
        foreach ($match in $archMatches) {
            $planData.ArchitectureChoices += $match.Groups[1].Value
        }
    }
    
    # Extract data model references
    if ($planContent -match "(?ms)## Data Model.*?(?=^##|\z)") {
        $dataSection = $matches[0]
        $dataMatches = [regex]::Matches($dataSection, "(?m)^[-*]\s+(.+)$")
        foreach ($match in $dataMatches) {
            $planData.DataModelReferences += $match.Groups[1].Value
        }
    }
    
    # Extract phases
    if ($planContent -match "(?ms)## Phase.*?(?=^##|\z)") {
        $phaseSection = $matches[0]
        $phaseMatches = [regex]::Matches($phaseSection, "(?m)^[-*]\s+(.+)$")
        foreach ($match in $phaseMatches) {
            $planData.Phases += $match.Groups[1].Value
        }
    }
    
    Write-Host "   Plan loaded: $($planData.ArchitectureChoices.Count) architecture items, $($planData.DataModelReferences.Count) data model items" -ForegroundColor Gray
}
else {
    Write-Host "   Plan file not found at $PLAN" -ForegroundColor Yellow
}

$analysis.Plan = $planData

# Load Tasks
if (Test-Path $TASKS) {
    $tasksContent = Get-Content $TASKS -Raw
    
    $tasks = @()
    # Extract tasks (simplified parsing)
    $taskPattern = "(?m)^[-*]\s+\[([^\]]+)\]\s+(.+)$"
    $taskMatches = [regex]::Matches($tasksContent, $taskPattern)
    foreach ($match in $taskMatches) {
        $taskId = $match.Groups[1].Value
        $taskDesc = $match.Groups[2].Value
        
        $tasks += @{
            Id          = $taskId
            Description = $taskDesc
            IsParallel  = $taskDesc -match "\[P\]"
            Phase       = "Unknown"
        }
    }
    
    $analysis.Tasks = $tasks
    $analysis.Metrics.TotalTasks = $tasks.Count
    
    Write-Host "   Tasks loaded: $($tasks.Count) tasks found" -ForegroundColor Gray
}

# Step 3: Detection Passes
Write-Host "`nStep 3: Running Analysis..." -ForegroundColor Yellow

$findingId = 1

# A. Constitution Alignment Check
Write-Host "   Checking constitution alignment..." -ForegroundColor Gray
if ($analysis.Constitution.Principles.Count -eq 0) {
    $analysis.Findings += @{
        ID             = "C$findingId"
        Category       = "Constitution"
        Severity       = "CRITICAL"  
        Locations      = @("constitution.md")
        Summary        = "Constitution principles not found or not parseable"
        Recommendation = "Ensure constitution.md exists with proper ## Core Principles section"
        Status         = "OPEN"
    }
    $findingId++
    $analysis.Metrics.CriticalIssues++
}

# B. Coverage Gap Analysis  
Write-Host "   Checking requirement coverage..." -ForegroundColor Gray
$unmappedRequirements = @()
foreach ($req in $analysis.Requirements) {
    $hasCoverage = $false
    foreach ($task in $analysis.Tasks) {
        $keywordMatch = $task.Description -match [regex]::Escape($req.Key)
        $textMatch = $false
        if ($req.Text.Length -ge 20) {
            $textMatch = $task.Description -match [regex]::Escape($req.Text.Substring(0, 20))
        }
        
        if ($keywordMatch -or $textMatch) {
            $req.HasTasks = $true
            $req.TaskIds += $task.Id
            $hasCoverage = $true
        }
    }
    
    if (-not $hasCoverage) {
        $unmappedRequirements += $req
    }
}

foreach ($req in $unmappedRequirements) {
    $severity = if ($req.Text -match "must|required|shall") { "CRITICAL" } else { "HIGH" }
    
    $summaryText = if ($req.Text.Length -gt 50) { 
        $req.Text.Substring(0, 50) + "..." 
    }
    else { 
        $req.Text 
    }
    
    $analysis.Findings += @{
        ID             = "G$findingId"
        Category       = "Coverage"
        Severity       = $severity
        Locations      = @("spec.md", "tasks.md")
        Summary        = "Requirement has no associated implementation tasks: '$summaryText'"
        Recommendation = "Add implementation tasks to tasks.md or clarify requirement scope"
        Status         = "OPEN"
    }
    $findingId++
    
    if ($severity -eq "CRITICAL") {
        $analysis.Metrics.CriticalIssues++
    }
}

# C. Ambiguity Detection
Write-Host "   Checking for ambiguities..." -ForegroundColor Gray
$vagueWords = @("fast", "scalable", "secure", "intuitive", "robust", "efficient", "good", "bad", "better")
foreach ($req in $analysis.Requirements) {
    foreach ($word in $vagueWords) {
        if ($req.Text -match "\b$word\b") {
            $summaryText = if ($req.Text.Length -gt 50) { 
                $req.Text.Substring(0, 50) + "..." 
            }
            else { 
                $req.Text 
            }
            
            $analysis.Findings += @{
                ID             = "A$findingId"
                Category       = "Ambiguity"
                Severity       = "HIGH"
                Locations      = @("spec.md")
                Summary        = "Requirement contains vague term '$word': '$summaryText'"
                Recommendation = "Replace with measurable criteria (e.g., 'responds within 200ms' instead of 'fast')"
                Status         = "OPEN"
            }
            $findingId++
            $analysis.Metrics.AmbiguityCount++
            break
        }
    }
}

# D. Plan-Spec Consistency Check
Write-Host "   Checking plan-spec consistency..." -ForegroundColor Gray

# Check for data model references in plan that aren't mentioned in spec
foreach ($dataItem in $analysis.Plan.DataModelReferences) {
    $foundInSpec = $false
    foreach ($req in $analysis.Requirements) {
        if ($req.Text -match [regex]::Escape($dataItem.Split(' ')[0])) {
            # Check first word of data model item
            $foundInSpec = $true
            break
        }
    }
    
    if (-not $foundInSpec) {
        $analysis.Findings += @{
            ID             = "P$findingId"
            Category       = "Inconsistency"
            Severity       = "MEDIUM"
            Locations      = @("plan.md", "spec.md")
            Summary        = "Plan references data model '$dataItem' not found in spec requirements"
            Recommendation = "Add requirement for data model or remove from plan"
            Status         = "OPEN"
        }
        $findingId++
    }
}

# Check for architecture choices that conflict with requirements
foreach ($archChoice in $analysis.Plan.ArchitectureChoices) {
    # Simple conflict detection for common technology conflicts
    if ($archChoice -match "React" -and ($analysis.Requirements | Where-Object { $_.Text -match "Vue|Angular" })) {
        $analysis.Findings += @{
            ID             = "P$findingId"
            Category       = "Inconsistency"
            Severity       = "HIGH"
            Locations      = @("plan.md", "spec.md")
            Summary        = "Architecture choice '$archChoice' conflicts with requirements mentioning other frameworks"
            Recommendation = "Align architecture choices with requirements or update requirements"
            Status         = "OPEN"
        }
        $findingId++
    }
}

# E. User Story Validation
Write-Host "   Validating user stories..." -ForegroundColor Gray
foreach ($story in $analysis.UserStories) {
    if (-not $story.HasAcceptanceCriteria) {
        $analysis.Findings += @{
            ID             = "U$findingId"
            Category       = "Underspecification"
            Severity       = "HIGH"
            Locations      = @("spec.md")
            Summary        = "User story lacks acceptance criteria: '$($story.Title)'"
            Recommendation = "Add measurable acceptance criteria section to user story"
            Status         = "OPEN"
        }
        $findingId++
    }
}

# Calculate metrics
if ($analysis.Metrics.TotalRequirements -gt 0) {
    $coveredReqs = ($analysis.Requirements | Where-Object { $_.HasTasks }).Count
    $analysis.Metrics.CoveragePercent = [Math]::Round(($coveredReqs / $analysis.Metrics.TotalRequirements) * 100, 1)
}

# Step 4: Generate Report
Write-Host "`nStep 4: Generating Report..." -ForegroundColor Yellow

# Load and use template if available
$useTemplate = Test-Path $templatePath
if ($useTemplate) {
    Write-Host "   Using template: $templatePath" -ForegroundColor Gray
}
else {
    Write-Host "   Template not found, using built-in format" -ForegroundColor Yellow
}

# Limit findings based on MaxFindings parameter
$limitedFindings = $analysis.Findings | Sort-Object { 
    switch ($_.Severity) { 
        "CRITICAL" { 0 } 
        "HIGH" { 1 } 
        "MEDIUM" { 2 } 
        "LOW" { 3 } 
        default { 4 } 
    } 
} | Select-Object -First $MaxFindings

$overflowCount = $analysis.Findings.Count - $limitedFindings.Count

# Calculate quality score
$startingScore = 100
$deductions = 0
foreach ($finding in $analysis.Findings) {
    switch ($finding.Severity) {
        "CRITICAL" { $deductions += 25 }
        "HIGH" { $deductions += 10 }
        "MEDIUM" { $deductions += 5 }
        "LOW" { $deductions += 2 }
    }
}
$finalScore = [Math]::Max(0, $startingScore - $deductions)

$statusRating = if ($finalScore -ge 90 -and $analysis.Metrics.CriticalIssues -eq 0) { 
    "READY FOR DEVELOPMENT" 
}
elseif ($finalScore -ge 70) { 
    "NEEDS IMPROVEMENT" 
}
else { 
    "NOT READY" 
}

$reportOutput = @"
# Specification Analysis: $(Split-Path -Leaf $analysis.FeaturePath)

**Analyzed By**: CPR Specification Analyzer  
**Analysis Date**: $($analysis.Timestamp)  
**Feature Path**: $($analysis.FeaturePath)  
**Arguments**: $($analysis.Arguments)

## Analysis Summary

- **Overall Rating**: $finalScore/100 [$statusRating]
- **Critical Issues**: $($analysis.Metrics.CriticalIssues)
- **High Issues**: $(($analysis.Findings | Where-Object { $_.Severity -eq "HIGH" }).Count)
- **Medium Issues**: $(($analysis.Findings | Where-Object { $_.Severity -eq "MEDIUM" }).Count)
- **Low Issues**: $(($analysis.Findings | Where-Object { $_.Severity -eq "LOW" }).Count)
- **Coverage**: $($analysis.Metrics.CoveragePercent)% ($($analysis.Requirements.Count - $unmappedRequirements.Count)/$($analysis.Requirements.Count) requirements have tasks)

---

## Findings Summary (Top $MaxFindings)

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|
"@

foreach ($finding in $limitedFindings) {
    $locationStr = $finding.Locations -join ", "
    $reportOutput += "`n| $($finding.ID) | $($finding.Category) | $($finding.Severity) | $locationStr | $($finding.Summary) | $($finding.Recommendation) |"
}

if ($limitedFindings.Count -eq 0) {
    $reportOutput += "`n| - | - | - | - | No issues found | Continue with implementation |"
}

if ($overflowCount -gt 0) {
    $reportOutput += "`n`n**Note**: $overflowCount additional findings not shown. Use -MaxFindings parameter to see more."
}

$reportOutput += @"

---

## Coverage Summary

| Requirement | Has Tasks | Task IDs | Status |
|-------------|-----------|----------|---------|
"@

foreach ($req in $analysis.Requirements | Sort-Object Key) {
    $hasTasksIcon = if ($req.HasTasks) { "Yes" } else { "No" }
    $taskIdStr = $req.TaskIds -join ", "
    $statusStr = if ($req.HasTasks) { "Covered" } else { "Missing Tasks" }
    
    $reportOutput += "`n| $($req.Key) | $hasTasksIcon | $taskIdStr | $statusStr |"
}

if ($analysis.Requirements.Count -eq 0) {
    $reportOutput += "`n| No requirements found | - | - | Check spec.md format |"
}

$reportOutput += @"

---

## Plan Analysis

**Architecture Choices**: $($analysis.Plan.ArchitectureChoices.Count)  
**Data Model Items**: $($analysis.Plan.DataModelReferences.Count)  
**Phases**: $($analysis.Plan.Phases.Count)

"@

if ($analysis.Plan.ArchitectureChoices.Count -gt 0) {
    $reportOutput += "**Architecture Decisions**:`n"
    foreach ($choice in $analysis.Plan.ArchitectureChoices) {
        $reportOutput += "- $choice`n"
    }
    $reportOutput += "`n"
}

if ($analysis.Plan.DataModelReferences.Count -gt 0) {
    $reportOutput += "**Data Model References**:`n"
    foreach ($dataRef in $analysis.Plan.DataModelReferences) {
        $reportOutput += "- $dataRef`n"
    }
}

$reportOutput += @"

---

## Constitution Alignment

**Principles Found**: $($analysis.Constitution.Principles.Count)  
**Constitution Violations**: $(($analysis.Findings | Where-Object { $_.Category -eq "Constitution" }).Count)

"@

if ($analysis.Constitution.Principles.Count -gt 0) {
    $reportOutput += "**Active Principles**:`n"
    foreach ($principle in $analysis.Constitution.Principles) {
        $reportOutput += "- $principle`n"
    }
}
else {
    $reportOutput += "Warning: Constitution not loaded or principles not found"
}

$reportOutput += @"

---

## Next Actions

"@

if ($finalScore -ge 90 -and $analysis.Metrics.CriticalIssues -eq 0) {
    $reportOutput += "### READY FOR DEVELOPMENT`n`n"
    $reportOutput += "**Proceed to**: Manual review and approval by tech lead"
}
elseif ($finalScore -ge 70) {
    $reportOutput += "### NEEDS IMPROVEMENT`n`n**Required Actions**:`n"
    $criticalAndHighFindings = $analysis.Findings | Where-Object { $_.Severity -in @("CRITICAL", "HIGH") }
    $actionCount = 1
    foreach ($finding in $criticalAndHighFindings) {
        $reportOutput += "$actionCount. $($finding.Recommendation)`n"
        $actionCount++
    }
    $reportOutput += "`n**Re-run analysis after addressing issues**"
}
else {
    $reportOutput += "### NOT READY`n`n**Critical Issues Must Be Resolved**:`n"
    $criticalFindings = $analysis.Findings | Where-Object { $_.Severity -eq "CRITICAL" }
    foreach ($finding in $criticalFindings) {
        $reportOutput += "- $($finding.Summary)`n"
    }
    $reportOutput += "`n**Required Actions**:`n"
    $actionCount = 1
    foreach ($finding in $criticalFindings) {
        $reportOutput += "$actionCount. $($finding.Recommendation)`n"
        $actionCount++
    }
}

$reportOutput += @"

---

## Analysis Metrics

- **Requirements Analyzed**: $($analysis.Metrics.TotalRequirements)
- **Tasks Analyzed**: $($analysis.Metrics.TotalTasks)  
- **Coverage Percentage**: $($analysis.Metrics.CoveragePercent)%
- **Ambiguity Flags**: $($analysis.Metrics.AmbiguityCount)
- **Duplication Flags**: $($analysis.Metrics.DuplicationCount)
- **Critical Issues**: $($analysis.Metrics.CriticalIssues)
- **Total Findings**: $($analysis.Findings.Count)
"@

if ($overflowCount -gt 0) {
    $reportOutput += "`n- **Findings Shown**: $($limitedFindings.Count) (limited by MaxFindings parameter)"
}

$endTime = Get-Date
$analysisTime = ($endTime - [DateTime]$analysis.Timestamp).TotalSeconds
$reportOutput += "`n`n**Analysis completed in**: $analysisTime seconds"

# Output results
if ($Json) {
    $analysis | ConvertTo-Json -Depth 10
}
else {
    Write-Host $reportOutput
    
    # Save report to file
    $reportFile = Join-Path $analysis.FeaturePath "spec-analysis-report.md"
    $reportOutput | Out-File -FilePath $reportFile -Encoding UTF8
    Write-Host "`nReport saved to: $reportFile" -ForegroundColor Green
    
    # Step 5: Offer Remediation
    if ($Remediation -and $analysis.Findings.Count -gt 0) {
        Write-Host "`nRemediation Options:" -ForegroundColor Cyan
        Write-Host "Would you like suggestions for the top issues? [Y/N]" -NoNewline
        $response = Read-Host
        
        if ($response -match "^[Yy]") {
            Write-Host "`nTop Remediation Suggestions:" -ForegroundColor Yellow
            
            $topFindings = $limitedFindings | Select-Object -First 5
            
            $i = 1
            foreach ($finding in $topFindings) {
                Write-Host "$i. [$($finding.Severity)] $($finding.Summary)" -ForegroundColor White
                Write-Host "   $($finding.Recommendation)" -ForegroundColor Gray
                Write-Host ""
                $i++
            }
        }
    }
}

Write-Host "`nAnalysis Complete!" -ForegroundColor Green