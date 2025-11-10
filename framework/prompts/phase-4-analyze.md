---
phase: 4_analyze
purpose: Analyze specification artifacts for completeness, consistency, conflicts, and quality
applies_to: analysis-report.md
related_documents:
  - ../workflow.md
  - phase-1-specify.md
  - phase-2-refine.md
  - phase-3-plan.md
  - ../../constitution.md
---

# Phase 4: Analyze Specification - GitHub Copilot Prompt

## User Input

```text
$ARGUMENTS
```

You **MUST** consider user input before proceeding (if not empty).

## Context

You are helping to analyze a feature specification for the CPR (Career Progress Registry) project. This is **Phase 4: Analyze**, where we perform comprehensive quality analysis of all specification artifacts to ensure they are complete, consistent, and ready for implementation.

**Prerequisites**:
- Phase 1 (Specify) created the initial specification
- Phase 2 (Refine) clarified all ambiguities
- Phase 3 (Plan) created implementation planning documents
- All required artifacts exist: `description.md`, `implementation-plan.md`, `tasks.md`, `endpoints.md`, `progress.md`
- **Automated pre-analysis completed**: `automation-report.json` contains deterministic validation results

**Your Mission**: Review automated findings, perform semantic analysis, and produce an `analysis-report.md` with final quality score and actionable findings.

**Automation Tool**: Before using this prompt, the user should run:
```powershell
.\framework\tools\phase-4-analyze.ps1 -FeatureNumber "XXXX" -FeatureName "feature-name"
```

This tool validates file structure, naming conventions, placeholders, constitutional compliance, and generates `automation-report.json` with:
- File existence/completeness checks (PASS/FAIL)
- Placeholder detection (TODO, TBD, etc.)
- Naming convention violations (camelCase in JSON, etc.)
- Constitutional compliance metrics (11 principles)
- Coverage analysis (tasks per story)
- Automated quality score (0-100)
- Structured findings with severity levels (CRITICAL/HIGH/MEDIUM/LOW)

---

## IMPORTANT: Operating Constraints

**STRICTLY READ-ONLY ANALYSIS**: Do **NOT** modify any existing files during analysis. Only create the `analysis-report.md` file with findings.

**Constitution Authority**: The CPR Constitution (`constitution.md`) principles are **non-negotiable**. Constitution violations are automatically CRITICAL and must be reported.

**Quality Threshold**: Specifications must score ≥ 90/100 to proceed to Phase 5 (Implementation). Scores below 90 require remediation.

---

## Analysis Scope

### Artifacts to Analyze

**Mandatory Artifacts**:
1. `description.md` - Feature specification
2. `implementation-plan.md` - Technical design and phases
3. `tasks.md` - Task breakdown and dependencies
4. `endpoints.md` - API contracts (if applicable)
5. `progress.md` - Current status

**Optional Artifacts** (if present):
6. `data-model.md` - Database schema
7. `research.md` - Technical decisions

### Cross-Reference Documents

- `constitution.md` - 11 CPR Constitutional Principles
- Other feature specifications (for conflict detection)
- Existing API contracts (for consistency)

---

## Analysis Workflow

### Step 1: Load Automated Findings

**First, read `automation-report.json`**:
- Review all automated validation results (PASS/FAIL)
- Review all automated findings with severity levels
- Note automated quality score
- Check metrics (user stories, tasks, endpoints, placeholders)

**The automation tool has already checked**:
- ✅ File existence and completeness (all required files present and > 100 bytes)
- ✅ Placeholder detection (TODO, TBD, FILL IN patterns)
- ✅ Naming conventions (camelCase in JSON = violation)
- ✅ Constitutional compliance (section present, 11 principles reviewed)
- ✅ Basic coverage (tasks per user story ratio)

**Your AI analysis focuses on what automation cannot detect**: semantic meaning, conflicts, ambiguity, gaps, and quality.

---

## Analysis Categories

### 1. Completeness Analysis

**START with automated completeness findings from `automation-report.json`**, then perform deeper semantic checks:

**Check for Missing Elements**:

**In `description.md`**:
- [ ] Executive summary present and clear
- [ ] All user stories have 3-5 acceptance criteria
- [ ] Business rules defined (at least 3-5 rules)
- [ ] Technical requirements (performance, security, offline, i18n)
- [ ] API design with endpoints
- [ ] Data model with constraints
- [ ] Type definitions (C# DTOs and TypeScript interfaces)
- [ ] Testing strategy (unit, integration, performance, E2E)
- [ ] Success metrics defined
- [ ] Constitutional compliance checklist completed
- [ ] Dependencies and assumptions documented

**In `implementation-plan.md`**:
- [ ] Executive summary present
- [ ] Constitutional Compliance Check for all 11 principles
- [ ] All principles have status: PASS/FAIL/NEEDS REVIEW
- [ ] Technical context (stack, patterns, integrations)
- [ ] Implementation phases with deliverables
- [ ] Risk assessment
- [ ] Timeline estimates

**In `tasks.md`**:
- [ ] Tasks organized by phase
- [ ] Each task has ID, priority, file path
- [ ] Dependencies identified
- [ ] Parallel execution opportunities marked [P]
- [ ] Task summary with counts
- [ ] Critical path documented

**In `endpoints.md`**:
- [ ] All endpoints from description.md included
- [ ] Request/response schemas in JSON format
- [ ] Error responses with status codes
- [ ] Authentication/authorization requirements
- [ ] Query parameters and headers

**Severity**: Missing required sections = **CRITICAL**, Missing optional details = **MINOR**

---

### 2. Consistency Analysis

**START with automated consistency findings from `automation-report.json`** (naming violations), then perform deeper semantic checks:

**Cross-Artifact Consistency**:

**DTOs Alignment**:
- [ ] C# DTOs in `description.md` match TypeScript interfaces
- [ ] JSON property names use snake_case in all places
- [ ] Field types consistent (string, number, boolean, etc.)
- [ ] Required vs optional fields match across C# and TypeScript

**Endpoints Alignment**:
- [ ] Endpoints in `description.md` match `endpoints.md`
- [ ] HTTP methods consistent (GET, POST, PATCH, DELETE)
- [ ] URL paths match (kebab-case)
- [ ] Request/response structures identical

**Database Schema Alignment** (if `data-model.md` exists):
- [ ] Tables in `data-model.md` match entities in `description.md`
- [ ] Column names use snake_case
- [ ] Constraints match business rules
- [ ] Foreign keys match relationships described

**Task Coverage**:
- [ ] Every user story has corresponding tasks
- [ ] Every endpoint has implementation tasks
- [ ] Database migrations have tasks (if schema changes)
- [ ] Testing tasks cover all test strategies

**Terminology Consistency**:
- [ ] Same concepts use same names across all files
- [ ] No conflicting definitions
- [ ] Acronyms defined consistently

**Severity**: DTO mismatch = **CRITICAL**, Terminology drift = **MEDIUM**, Minor wording = **LOW**

---

### 3. Conflict Detection

**Internal Conflicts** (within specification):
- Contradictory requirements (e.g., "must be real-time" vs "batch processing")
- Conflicting business rules
- Incompatible technical choices
- Authorization conflicts (who can do what)

**External Conflicts** (with other features):
- API endpoint path collisions
- Database table/column name conflicts
- Shared component incompatibilities
- Authentication/authorization inconsistencies

**Constitution Conflicts**:
- Violations of any of the 11 CPR Constitutional Principles
- Naming convention violations (snake_case, PascalCase, kebab-case)
- Missing offline mode support (if required)
- Type safety violations (use of `any` in TypeScript)

**Severity**: Constitution violation = **CRITICAL**, Feature conflict = **HIGH**, Internal contradiction = **HIGH**

---

### 4. Gap Analysis

**Requirement Gaps**:
- User stories without acceptance criteria
- Business rules without validation tasks
- Non-functional requirements without test tasks
- Error scenarios not covered in endpoints

**Implementation Gaps**:
- Requirements with no associated tasks
- Tasks referencing undefined files/components
- Missing integration tasks
- Missing test coverage tasks

**Security Gaps**:
- Endpoints without authentication specified
- Authorization rules not defined
- Input validation missing
- XSS/SQL injection protection not mentioned

**Performance Gaps**:
- No performance requirements specified
- No load testing tasks
- No caching strategy
- No index optimization

**Severity**: Security gap = **CRITICAL**, Missing test coverage = **HIGH**, Minor edge case = **MEDIUM**

---

### 5. Ambiguity Detection

**Vague Language**:
- "Fast", "scalable", "secure", "intuitive" without metrics
- "Should work well" instead of specific criteria
- "As needed" without clear triggers
- Unresolved placeholders (TODO, TBD, ???, <placeholder>)

**Underspecification**:
- Verbs without objects ("User can update" - update what?)
- Missing measurable outcomes
- Acceptance criteria not testable
- Error handling not specified

**Severity**: Untestable acceptance criteria = **HIGH**, Vague performance = **MEDIUM**, Minor wording = **LOW**

---

### 6. Duplication Analysis

**Duplicate Requirements**:
- Near-identical user stories
- Redundant business rules
- Duplicate acceptance criteria

**Duplicate Tasks**:
- Same work described multiple times
- Overlapping file paths

**Severity**: Significant duplication = **MEDIUM**, Minor overlap = **LOW**

---

### 7. Constitutional Compliance Analysis

**Review Against All 11 Principles**:

1. **Principle 1: Specification-First Development**
   - [ ] Complete specification exists before implementation
   - [ ] All required artifacts present

2. **Principle 2: API Contract Consistency**
   - [ ] C# DTOs match TypeScript interfaces
   - [ ] JSON uses snake_case

3. **Principle 3: API Standards & Security**
   - [ ] RESTful conventions followed
   - [ ] Standard HTTP methods and status codes
   - [ ] Authentication/authorization specified

4. **Principle 4: Type Safety Everywhere**
   - [ ] C# DTOs have validation attributes
   - [ ] TypeScript uses strict types (no `any`)

5. **Principle 5: Offline Mode**
   - [ ] Offline capabilities identified
   - [ ] Sync mechanism specified

6. **Principle 6: Internationalization**
   - [ ] UI text externalizable
   - [ ] Locale-specific formatting

7. **Principle 7: Comprehensive Testing**
   - [ ] Unit, integration, performance tests defined
   - [ ] Coverage targets set

8. **Principle 8: Performance-First React Development**
   - [ ] Performance targets specified
   - [ ] React Query caching strategy

9. **Principle 9: Strict Naming Conventions**
   - [ ] JSON/API: snake_case
   - [ ] C#: PascalCase with [JsonPropertyName]
   - [ ] URLs: kebab-case
   - [ ] Database: snake_case

10. **Principle 10: Security & Data Privacy**
    - [ ] Authentication requirements
    - [ ] Authorization rules
    - [ ] Data encryption

11. **Principle 11: Database Design Standards**
    - [ ] UUID primary keys
    - [ ] Proper constraints
    - [ ] Indexes defined

**Severity**: Any principle violation = **CRITICAL**

---

### 8. Parallel Work Analysis

**Identify Parallel Execution Opportunities**:

**Phase-Level Parallelism**:
- Which implementation phases can run in parallel?
- Backend vs Frontend work separation
- Independent feature components

**Task-Level Parallelism**:
- Review tasks marked with [P] in `tasks.md`
- Identify additional parallel opportunities:
  - Independent services/repositories
  - Separate database tables
  - Different UI components
  - Test suites

**Dependency Chains**:
- Map critical path (sequential dependencies)
- Identify blocking tasks
- Calculate parallel work capacity

**Team Distribution**:
- Suggest work packages for different developers
- Backend team tasks vs Frontend team tasks
- Database team vs API team vs UI team

**Output**: Include parallel work analysis in report with:
- Critical path diagram
- Parallel work packages
- Estimated time savings
- Resource allocation suggestions

---

## Analysis Process

### Step 1: Load All Artifacts

Read all specification files:
```
specifications/[####]-<feature-name>/
├── description.md
├── implementation-plan.md
├── tasks.md
├── endpoints.md
├── progress.md
├── data-model.md (if exists)
└── research.md (if exists)
```

### Step 2: Build Semantic Models

Create internal representations:
- **Requirements inventory**: List all functional and non-functional requirements
- **User stories inventory**: All user stories with acceptance criteria
- **API endpoints inventory**: All endpoints with methods and contracts
- **Tasks inventory**: All tasks with IDs, dependencies, file paths
- **Constitution checklist**: Extract compliance items

### Step 3: Run Detection Passes

Execute each analysis category:
1. Completeness check
2. Consistency check
3. Conflict detection
4. Gap analysis
5. Ambiguity detection
6. Duplication check
7. Constitutional compliance
8. Parallel work analysis

### Step 4: Assign Severity Levels

For each finding, assign severity:
- **CRITICAL**: Blocks development, violates constitution, missing core requirement
- **HIGH**: Significant gap, conflict, or ambiguity
- **MEDIUM**: Moderate issue, terminology drift, minor gap
- **LOW**: Style improvement, minor redundancy

### Step 5: Calculate Quality Score

**Starting Score**: 100 points

**Deductions**:
- CRITICAL issue: Immediate fail (score = 0, must fix before proceeding)
- HIGH issue: -20 points each
- MEDIUM issue: -5 points each
- LOW issue: -1 point each

**Minimum Score**: 0 (cannot go negative)

**Quality Thresholds**:
- **≥ 90/100**: ✅ Ready for Development
- **70-89/100**: ⚠️ Needs Improvement (fix major issues)
- **< 70/100**: ❌ Not Ready (significant rework required)
- **Any CRITICAL issue**: ❌ Blocked (must resolve before proceeding)

### Step 6: Generate Analysis Report

Create `analysis-report.md` with structure:

```markdown
# Specification Analysis Report: [Feature Name]

**Analyzed By**: GitHub Copilot  
**Analysis Date**: YYYY-MM-DD  
**Specification Version**: [from description.md metadata]  

## Analysis Summary

- **Overall Rating**: XX/100 [✅ READY | ⚠️ NEEDS IMPROVEMENT | ❌ NOT READY]
- **Critical Issues**: X
- **High Issues**: X
- **Medium Issues**: X
- **Low Issues**: X

---

## Findings

| ID | Category | Severity | Location | Summary | Recommendation |
|----|----------|----------|----------|---------|----------------|
| F001 | Completeness | CRITICAL | description.md | Missing ... | Add ... |
| F002 | Consistency | HIGH | endpoints.md vs description.md | Mismatch ... | Align ... |
| ... | ... | ... | ... | ... | ... |

---

## Detailed Findings

### F001: [Finding Title] [CRITICAL]
**Category**: Completeness  
**Location**: `description.md`, line XX  
**Description**: [Detailed description of the issue]  
**Impact**: [Why this matters and what it blocks]  
**Recommendation**: [Specific action to resolve]  
**Status**: ⚠️ OPEN

---

## Constitutional Compliance Review

### Principle 1: Specification-First Development
- ✅ PASS - All required artifacts present
- Notes: [Any relevant notes]

### Principle 2: API Contract Consistency
- ❌ FAIL - C# and TypeScript DTOs mismatch
- Notes: Field `user_id` present in C# but missing in TypeScript

[... repeat for all 11 principles ...]

---

## Coverage Analysis

### Requirements Coverage
| Requirement ID | User Story | Has Tasks? | Task IDs | Status |
|----------------|------------|------------|----------|--------|
| US-001 | Create Goal | ✅ Yes | T010, T011, T012 | Covered |
| US-002 | View Goals | ❌ No | - | **MISSING** |

**Coverage Metrics**:
- Total Requirements: XX
- Requirements with Tasks: XX
- Coverage Percentage: XX%

### Task Coverage
| Task ID | Maps to Requirement | File Path | Status |
|---------|---------------------|-----------|--------|
| T001 | Setup | src/... | Mapped |
| T050 | **ORPHAN** | src/... | **No requirement** |

---

## Parallel Work Analysis

### Critical Path
```
Phase 1 → Phase 2 → Phase 3
  |         |         |
  └─ 5 days └─ 3 days └─ 4 days
Total: 12 days (sequential)
```

### Parallel Opportunities

**Phase 1 Parallelism**:
- Backend team: T001-T010 (Database, Domain, Services)
- Frontend team: T020-T030 (Components, Hooks, Types)
- Potential time savings: 3 days

**Phase 2 Parallelism**:
- API team: T011-T015 (Endpoints)
- UI team: T031-T040 (Forms, Lists)
- Test team: T050-T060 (Unit tests)
- Potential time savings: 2 days

**Recommended Team Distribution**:
1. **Backend Developer**: Tasks T001-T015 (5 days)
2. **Frontend Developer**: Tasks T020-T040 (4 days)
3. **QA Engineer**: Tasks T050-T070 (3 days, starts after Phase 1)

**Total Duration with Parallelism**: 8 days (vs 12 days sequential)  
**Time Savings**: 4 days (33% reduction)

---

## Metrics

- **Total Artifacts Analyzed**: X
- **Total Requirements**: XX
- **Total User Stories**: XX
- **Total Tasks**: XXX
- **Total Endpoints**: XX
- **Constitutional Principles Reviewed**: 11
- **Findings Identified**: XX
- **Requirements Coverage**: XX%
- **Task Coverage**: XX%

---

## Quality Score Calculation

**Starting Score**: 100 points (or use automated score from `automation-report.json` as baseline)

**Combine Automated + AI Findings**:

1. **Load automated findings** from `automation-report.json`:
   - Automated score: XX/100
   - CRITICAL issues: X (automated validation failures)
   - HIGH issues: X (naming violations, missing principles)
   - MEDIUM issues: X (placeholders, coverage gaps)
   - LOW issues: X (minor issues)

2. **Add AI-detected findings** (semantic analysis):
   - CRITICAL: X (conflicts, constitution violations)
   - HIGH: X (ambiguity, missing requirements)
   - MEDIUM: X (inconsistencies, gaps)
   - LOW: X (suggestions, optimizations)

3. **Calculate Final Score**:
   - Start with MIN(100, automated_score + 10) to allow improvement
   - Apply AI deductions:
     - Critical Issues: Immediate fail (score = 0)
     - High Issues (X × -20): -XX points
     - Medium Issues (X × -5): -XX points
     - Low Issues (X × -1): -XX points

**Final Score**: XX/100

**Status**: [✅ READY FOR DEVELOPMENT | ⚠️ NEEDS IMPROVEMENT | ❌ NOT READY]

---

## Recommendations

### Must Fix (Before Phase 5)
1. [CRITICAL issue from automation or AI - specific action]
2. [HIGH issue - specific action]

### Should Fix (Before Phase 5)
1. [MEDIUM issue - improvement]

### Nice to Have (Can defer)
1. [LOW issue - polish]

---

## Next Actions

**If Score ≥ 90 and No CRITICAL Issues**:
- ✅ Specification approved for implementation
- Proceed to Phase 5: Implementation
- Update `progress.md` to mark Phase 4 complete

**If Score 70-89 or Has HIGH Issues**:
- ⚠️ Address HIGH and MEDIUM issues
- Fix issues directly in specification files
- Re-run automated tool: `.\framework\tools\phase-4-analyze.ps1 -FeatureNumber "XXXX" -FeatureName "feature-name"`
- Re-run AI analysis with this prompt
- Get stakeholder approval for deferred issues

**If Score < 70 or Has CRITICAL Issues**:
- ❌ Specification blocked
- Must resolve all CRITICAL issues
- Revisit Phase 1-3 as needed
- Re-run automated tool after fixes
- Re-run AI analysis with this prompt after fixes

---

## Execution Checklist

Before generating `analysis-report.md`, ensure you have:

- [ ] Read `automation-report.json` and incorporated all automated findings
- [ ] Reviewed automated quality score (baseline)
- [ ] Performed all 8 AI-specific analysis categories
- [ ] Identified at least 3-5 semantic issues (or confirmed none exist)
- [ ] Calculated final quality score combining automated + AI findings
- [ ] Provided specific, actionable recommendations
- [ ] Referenced automation tool for re-validation after fixes

---

## Sign-Off

- [ ] All CRITICAL issues resolved (both automated and AI-detected)
- [ ] All HIGH issues resolved or accepted as risks
- [ ] MEDIUM/LOW issues documented and tracked
- [ ] Overall rating ≥ 90/100
- [ ] Specification approved for development

**Approved By**: [Name]  
**Approval Date**: YYYY-MM-DD
```

---

## Output Format

Generate the `analysis-report.md` file with:
1. **Summary section** (automated score + AI score + final score)
2. **Automated Findings** (from `automation-report.json`)
3. **AI Analysis Findings** (semantic analysis results)
4. **Combined Findings table** (all issues in tabular format with source: AUTO/AI)
5. **Detailed findings** (one section per finding with full context)
6. **Constitutional compliance** (all 11 principles reviewed)
5. **Coverage analysis** (requirements and tasks)
6. **Parallel work analysis** (critical path and opportunities)
7. **Metrics** (counts and percentages)
8. **Score calculation** (transparent breakdown)
9. **Recommendations** (prioritized actions)
10. **Sign-off section** (approval checklist)

---

## Best Practices

### Be Specific
- Cite exact file names and line numbers
- Quote problematic text
- Provide concrete examples

### Be Actionable
- Every finding includes a recommendation
- Recommendations are specific and implementable
- Prioritize by severity and impact

### Be Objective
- Base findings on constitutional principles and best practices
- Don't introduce personal preferences
- Focus on quality, completeness, and consistency

### Be Constructive
- Frame findings as opportunities for improvement
- Acknowledge what's done well
- Provide context for why issues matter

### Be Efficient
- Limit to 50 findings (aggregate overflow)
- Focus on high-signal issues
- Don't repeat similar findings

---

## Success Criteria

Analysis is complete when:
- [ ] All mandatory artifacts analyzed
- [ ] All 11 constitutional principles reviewed
- [ ] All analysis categories executed
- [ ] Quality score calculated
- [ ] Findings documented with recommendations
- [ ] Parallel work opportunities identified
- [ ] `analysis-report.md` created
- [ ] Clear next actions provided

---

**Next Phase**: Phase 5 (Implement) - Execute implementation tasks

**GitHub Copilot Instructions**: Use this prompt to analyze feature specifications and generate comprehensive analysis reports following CPR constitutional principles and framework standards.
