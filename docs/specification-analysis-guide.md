# Specification Analysis System

## Overview

The CPR project uses an **automated specification analysis system** to ensure specification quality before development begins. This system uses AI to identify gaps, conflicts, duplications, and quality issues, then provides actionable guidance for improvement.

## Quality Gate

**Specifications must score ≥ 90/100 to proceed to development.**

No critical issues are allowed, regardless of score.

## How to Use

### Step 1: Create Your Specification

Create a complete specification in `specs/[spec-###]-feature-name/` with all required files:
- `description.md`
- `implementation-plan.md`
- `tasks.md`
- `endpoints.md` (if API feature)
- `progress.md`

### Step 2: Run Automated Analysis

#### Using GitHub Copilot Chat or Similar AI Assistant:

1. **Open the analysis prompt**:
   ```
   Open: prompts/specification-analysis.md
   ```

2. **Load your specification files** as context:
   ```
   @workspace Load all files from specs/[spec-###]-feature-name/
   ```

3. **Request analysis**:
   ```
   Using the specification-analysis.md prompt, analyze this specification 
   and generate an analysis-report.md file using the template from 
   templates/spec-analysis-report-template.md
   ```

4. **AI will generate**: `specs/[spec-###]-feature-name/analysis-report.md`

#### Using Command Line (Future):

```bash
# Run automated analysis script
npm run analyze:spec [spec-###]-feature-name

# Or using PowerShell
.\scripts\analyze-spec.ps1 -SpecFolder "[spec-###]-feature-name"
```

### Step 3: Review AI Analysis

**Human reviewer validates**:
1. Open generated `analysis-report.md`
2. Verify each identified issue is accurate
3. Add any issues the AI missed
4. Adjust severity ratings if needed
5. Update the final score if changes made

### Step 4: Address Issues

#### If Score ≥ 90/100 ✅
- Proceed to manual approval by tech lead
- Mark in `progress.md` as "Ready for Development"

#### If Score 70-89/100 ⚠️
- Review "Questions to Address" section in `analysis-report.md`
- Fix all major issues
- Consider fixing high-priority minor issues
- Update specification files
- Re-run analysis
- Repeat until ≥ 90/100

#### If Score < 70/100 or Critical Issues ❌
- Review "Critical Issues Must Be Resolved" section
- Address all critical issues first
- Address major issues
- Complete missing sections
- Consider significant rework
- Re-run analysis after major changes
- Target: ≥ 90/100 with no critical issues

### Step 5: Manual Approval

After specification scores ≥ 90/100:
1. Tech lead or architect reviews specification
2. Verifies analysis is accurate
3. Checks feasibility and alignment with architecture
4. Signs off in `analysis-report.md` "Sign-Off" section
5. Updates `progress.md` to "Approved - Ready for Development"

## Rating System

### Issue Severity

| Severity | Points | Description | Examples |
|----------|--------|-------------|----------|
| **CRITICAL** | Blocks (score = 0) | Fundamental flaw | Missing auth spec, contradictory requirements |
| **MAJOR** | -20 each | Significant gap | Undefined error handling, API conflict |
| **MINOR** | -5 each | Small issue | Ambiguous wording, missing example |

### Quality Thresholds

- **≥ 90/100**: ✅ Ready for Development
- **70-89/100**: ⚠️ Needs Improvement
- **< 70/100**: ❌ Not Ready

## Analysis Categories

### 1. Gaps Analysis
**Missing or incomplete information**:
- Incomplete requirements
- Missing API specifications
- Undefined error handling
- Missing test scenarios
- Incomplete documentation

### 2. Conflicts Analysis
**Contradictions and inconsistencies**:
- Internal conflicts within spec
- Conflicts with existing features
- Conflicts with other specs
- Backward compatibility issues
- Naming conflicts

### 3. Duplications Analysis
**Redundant or overlapping functionality**:
- Duplicate functionality
- Reusable endpoints
- Reusable DTOs
- Consolidation opportunities

### 4. Quality Issues
**Ambiguities and quality problems**:
- Unclear language
- Missing definitions
- Inconsistent terminology
- Formatting issues
- Feasibility concerns

## AI Analysis Capabilities

The AI analyzer will:
- ✅ Read all specification files
- ✅ Check completeness against requirements
- ✅ Identify internal inconsistencies
- ✅ Check for conflicts with existing CPR features
- ✅ Detect duplications
- ✅ Flag ambiguous or unclear sections
- ✅ Calculate objective quality score
- ✅ Ask guiding questions if improvements needed
- ✅ Suggest specific fixes for each issue

## Example Workflow

```bash
# 1. Create specification
mkdir -p specs/spec-042-user-notifications
# ... create all required files ...

# 2. Run analysis
# Use GitHub Copilot with prompts/specification-analysis.md

# 3. Review generated analysis-report.md
# Score: 85/100 (Needs Improvement)
# - 1 Major issue: Missing error responses (-20)
# - 3 Minor issues: Ambiguous wording (-15)

# 4. Fix issues based on AI recommendations
# Update endpoints.md with error responses
# Clarify ambiguous sections

# 5. Re-run analysis
# New Score: 95/100 (Ready!)

# 6. Manual approval
# Tech lead reviews and approves

# 7. Begin implementation
# Mark in progress.md: "Approved - In Development"
```

## Files Reference

### Prompt
**Location**: `prompts/specification-analysis.md`
**Purpose**: Instructions for AI to analyze specifications
**Usage**: Load this as context for AI analysis

### Template
**Location**: `templates/spec-analysis-report-template.md`
**Purpose**: Structure for analysis-report.md output
**Usage**: AI uses this to format analysis results

### Analysis Output
**Location**: `specs/[spec-###]-feature-name/analysis-report.md`
**Purpose**: Generated analysis with issues and score
**Usage**: Review, fix issues, get approval

## Tips for Better Specifications

1. **Be Specific**: Avoid vague language like "should be fast" - use measurable criteria
2. **Include Examples**: JSON examples prevent ambiguity
3. **Define All Errors**: Don't just specify success cases
4. **Be Consistent**: Use same terminology throughout
5. **Check Existing Features**: Review existing specs to avoid conflicts
6. **Think About Edge Cases**: What happens when things go wrong?
7. **Make It Testable**: Acceptance criteria should be verifiable

## Continuous Improvement

### Track Analysis Patterns

After multiple analyses, track common issues:
- Which types of gaps appear most often?
- Which conflicts are frequently missed?
- What areas need better templates or examples?

Use this data to:
- Improve specification templates
- Add more examples
- Create checklists for common issues
- Train team on frequent problems

### Update Analysis Prompt

As you learn what works:
- Add new checklist items
- Refine severity guidelines
- Add project-specific context
- Include examples of past issues

## Questions?

- **Who runs the analysis?** - Specification author or assigned reviewer
- **How long does it take?** - 2-5 minutes for AI, 5-10 minutes for human review
- **Can I skip it for small changes?** - No, all specs require analysis (but small specs analyze quickly)
- **What if I disagree with AI?** - Human reviewer has final say, adjust ratings as needed
- **Can we improve the AI prompt?** - Yes! It's version-controlled, submit PRs to improve it

## Related Documents

- [Constitution](../constitution.md) - Core Principles (Specification-First Development)
- [Specification Structure](../constitution.md#specification-locations) - Required files and format
- [Workflow](../constitution.md#workflow) - Complete development workflow

---

**Remember**: The goal is to catch issues early when they're cheap to fix. A 10-minute analysis can save hours or days of rework.
