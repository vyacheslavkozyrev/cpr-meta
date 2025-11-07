# CPR Specification Analysis Process

This document outlines how to use the specification analysis process within the CPR project structure.

## Quick Start

```powershell
# Navigate to your feature directory
cd "path/to/feature"

# Run analysis (requires spec.md, plan.md, and tasks.md)
& "d:\projects\CPR\source\cpr-meta\scripts\analyze-spec.ps1" -FeaturePath .
```

## Process Overview

The analysis follows these steps:

1. **Prerequisites Check**: Validates required files exist
2. **Artifact Loading**: Loads spec.md, plan.md, tasks.md progressively  
3. **Constitution Validation**: Checks against CPR project principles
4. **Multi-Dimensional Analysis**: Detects issues across 6 categories
5. **Structured Reporting**: Outputs actionable findings with severity levels

## Analysis Categories

| Category | Detects | Severity Levels |
|----------|---------|----------------|
| **Duplication** | Redundant requirements | HIGH: Conflicting duplicates |
| **Ambiguity** | Vague specifications | HIGH: Untestable criteria |
| **Underspecification** | Missing details | CRITICAL: No acceptance criteria |
| **Constitution** | Principle violations | CRITICAL: MUST violations |
| **Coverage** | Requirement gaps | CRITICAL: Unmapped core requirements |
| **Inconsistency** | Contradictions | HIGH: Conflicting technologies |

## Integration with CPR Workflow

### Before Implementation
```powershell
# 1. Create specification artifacts
/speckit.specify    # Creates spec.md
/speckit.plan       # Creates plan.md  
/speckit.tasks      # Creates tasks.md

# 2. Run analysis
/speckit.analyze    # This process

# 3. Resolve CRITICAL issues before proceeding
/speckit.implement  # Only after analysis passes
```

### Constitution Integration

The analysis automatically validates against `constitution.md` principles:

- **CRITICAL**: Any violation of MUST principles
- **HIGH**: Missing mandated sections or quality gates  
- **MEDIUM**: Recommendations not followed

## Output Structure

### Analysis Report
```markdown
## Specification Analysis Report

| ID | Category | Severity | Location(s) | Summary | Recommendation |
|----|----------|----------|-------------|---------|----------------|
| A1 | Constitution | CRITICAL | spec.md:L45 | Violates Principle 1... | Add specification section |
| D1 | Duplication | HIGH | spec.md:L120-134 | Two similar requirements | Merge into single requirement |
```

### Coverage Summary  
```markdown
| Requirement Key | Has Task? | Task IDs | Notes |
|-----------------|-----------|----------|-------|
| user-can-upload | ✅ | T001, T002 | Complete coverage |
| performance-sla | ❌ | - | Missing implementation tasks |
```

### Metrics Dashboard
- Coverage percentage (requirements → tasks)
- Constitution compliance score
- Issue distribution by severity
- Remediation priority ranking

## Customization Points

### 1. Constitution Principles
Edit `constitution.md` to add/modify project principles. Analysis automatically picks up changes.

### 2. Severity Thresholds
Modify analysis thresholds in the analysis script:
```powershell
$SeverityThresholds = @{
    ConstitutionViolation = "CRITICAL"
    MissingAcceptanceCriteria = "HIGH"  
    TerminologyDrift = "MEDIUM"
    StyleIssues = "LOW"
}
```

### 3. Report Templates
Customize output format by modifying:
- `templates/spec-analysis-report-template.md`
- Analysis script report generation section

## Best Practices

### 1. Run Early and Often
- After each artifact update (spec → plan → tasks)
- Before implementation begins
- During specification reviews

### 2. Address Issues by Severity
1. **CRITICAL**: Block all implementation until resolved
2. **HIGH**: Resolve before implementation begins  
3. **MEDIUM**: Include in implementation planning
4. **LOW**: Address during code review

### 3. Constitution Alignment
- Treat constitution violations as non-negotiable
- Update constitution separately from feature work
- Document any approved principle exceptions

### 4. Remediation Workflow
```powershell
# 1. Get analysis report
/speckit.analyze

# 2. For CRITICAL issues, update specs first:
# Edit spec.md, plan.md, or tasks.md manually

# 3. Re-run analysis to verify fixes
/speckit.analyze

# 4. Proceed only when CRITICAL issues = 0
/speckit.implement
```

## Integration with Existing CPR Templates

The process leverages existing CPR templates:

- `spec-description-template.md` → Analyzed for completeness
- `spec-implementation-plan-template.md` → Cross-checked with tasks
- `spec-analysis-report-template.md` → Output format template
- `constitution.md` → Validation authority

This ensures seamless integration with established CPR workflows while adding comprehensive quality assurance.