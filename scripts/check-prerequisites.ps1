# CPR Specification Prerequisites Check
param(
    [switch]$Json,
    [switch]$RequireTasks,
    [switch]$IncludeTasks,
    [string]$FeaturePath = ""
)

# Initialize result object
$result = @{
    Status        = "Success"
    FeatureDir    = ""
    AvailableDocs = @()
    Errors        = @()
    RequiredFiles = @("spec.md", "plan.md")
    TasksRequired = $RequireTasks.IsPresent
}

# Add tasks.md to required files if needed
if ($RequireTasks) {
    $result.RequiredFiles += "tasks.md"
}

# Determine feature directory
if ($FeaturePath) {
    $featureDir = $FeaturePath
}
else {
    # Default to current directory or prompt user
    $featureDir = Get-Location
}

$result.FeatureDir = $featureDir

# Check for required files
$missingFiles = @()
foreach ($file in $result.RequiredFiles) {
    $fullPath = Join-Path $featureDir $file
    if (Test-Path $fullPath) {
        $result.AvailableDocs += $file
    }
    else {
        $missingFiles += $file
        $result.Errors += "Missing required file: $file"
    }
}

# Set status based on findings
if ($missingFiles.Count -gt 0) {
    $result.Status = "Error"
}

# Include task details if requested
if ($IncludeTasks -and (Test-Path (Join-Path $featureDir "tasks.md"))) {
    $tasksContent = Get-Content (Join-Path $featureDir "tasks.md") -Raw
    $result.TasksContent = $tasksContent
}

# Output result
if ($Json) {
    $result | ConvertTo-Json -Depth 3
}
else {
    Write-Host "Feature Directory: $($result.FeatureDir)"
    Write-Host "Available Documents: $($result.AvailableDocs -join ', ')"
    Write-Host "Status: $($result.Status)"
    if ($result.Errors) {
        Write-Host "Errors:" -ForegroundColor Red
        $result.Errors | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    }
}