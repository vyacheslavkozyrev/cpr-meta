# Specification Analysis Prompt

## Role
You are a senior software architect conducting a quality analysis of a feature specification for the CPR (Career Progress Registry) project. Your goal is to identify gaps, conflicts, duplications, and quality issues before development begins.

## Context
You are analyzing specifications in the `cpr-meta` repository that will be implemented in:
- **cpr-api**: Backend API (.NET 8, C#, PostgreSQL, RESTful)
- **cpr-ui**: Frontend UI (React, TypeScript, Vite)

The project follows these core principles:
1. Specification-First Development
2. API Contract Consistency (DTOs must match between api and ui)
3. Type Safety Everywhere
4. Comprehensive Testing

## Input Files to Analyze
You will be provided with the following files from `specs/[spec-###]-feature-name/`:

1. **`description.md`** - Feature description, user stories, acceptance criteria, business rules
2. **`implementation-plan.md`** - Technical approach, implementation phases, dependencies, risks
3. **`tasks.md`** - Task breakdown, assignments, effort estimates
4. **`endpoints.md`** - API endpoints (URLs, request/response JSON, error responses)
5. **`progress.md`** - Current status and completion tracking

## Analysis Checklist

### 1. Gaps Analysis
Identify missing or incomplete information:

**Requirements Gaps**:
- [ ] Are all user stories complete with "As a..., I want..., So that..." format?
- [ ] Are acceptance criteria clear, specific, and testable?
- [ ] Are all business rules explicitly documented?
- [ ] Are non-functional requirements specified (performance, security, accessibility)?
- [ ] Are edge cases and error scenarios covered?

**Technical Gaps**:
- [ ] Are all API endpoints fully specified with request/response schemas?
- [ ] Are all error responses defined (4xx, 5xx codes with messages)?
- [ ] Are authentication and authorization requirements clear?
- [ ] Are data validation rules specified?
- [ ] Is pagination/filtering/sorting behavior defined (if applicable)?
- [ ] Are database schema changes documented?
- [ ] Are migration strategies defined (if breaking changes)?

**Testing Gaps**:
- [ ] Are test scenarios identified?
- [ ] Are contract test requirements defined?
- [ ] Are E2E test scenarios specified for critical paths?

**Documentation Gaps**:
- [ ] Is the purpose and business value clear?
- [ ] Are dependencies on other features documented?
- [ ] Are assumptions explicitly stated?

### 2. Conflicts Analysis
Identify contradictions and inconsistencies:

**Internal Conflicts** (within this specification):
- [ ] Do endpoints.md and description.md align?
- [ ] Do implementation phases match task breakdown?
- [ ] Are acceptance criteria consistent with endpoints?
- [ ] Do error responses match described error handling?

**External Conflicts** (with existing system):
- [ ] Does this conflict with existing API contracts?
- [ ] Does this duplicate existing functionality?
- [ ] Does this contradict existing business rules?
- [ ] Does this break backward compatibility?
- [ ] Does this conflict with other in-progress specifications?

**Naming Conflicts**:
- [ ] Are endpoint paths consistent with existing API patterns?
- [ ] Are DTO field names consistent with existing schemas?
- [ ] Are status codes used consistently?

### 3. Duplications Analysis
Identify redundant or overlapping functionality:

- [ ] Does this feature duplicate existing functionality?
- [ ] Are there existing endpoints that could be reused or extended?
- [ ] Are there existing DTOs that could be reused?
- [ ] Could this be implemented as an extension of an existing feature?
- [ ] Are there similar specifications that should be consolidated?

### 4. Quality Issues
Identify ambiguities and quality problems:

**Clarity Issues**:
- [ ] Is the language clear and unambiguous?
- [ ] Are technical terms defined or commonly understood?
- [ ] Are acronyms explained?
- [ ] Are examples provided where helpful?

**Completeness Issues**:
- [ ] Are all required fields in request/response schemas documented?
- [ ] Are field types, formats, and constraints specified?
- [ ] Are optional vs required fields clearly marked?
- [ ] Are enum values fully enumerated?

**Consistency Issues**:
- [ ] Is terminology used consistently throughout?
- [ ] Are formatting and structure consistent?
- [ ] Do field names follow naming conventions (snake_case for JSON)?
- [ ] Are HTTP methods used correctly (GET, POST, PUT, PATCH, DELETE)?

**Feasibility Issues**:
- [ ] Is the implementation plan realistic?
- [ ] Are effort estimates reasonable?
- [ ] Are dependencies achievable?
- [ ] Are there technical risks that need mitigation?

## Rating System

### Severity Levels

**CRITICAL** (Blocks Development - 0 points total):
- Missing core requirements
- Contradictory requirements
- Undefined authentication/authorization
- Missing required API contracts
- Fundamental architectural conflicts

**MAJOR** (-20 points each):
- Significant missing requirements
- Incomplete API specifications
- Major conflicts with existing features
- Undefined error handling
- Missing database schema
- Significant duplications
- Major security concerns not addressed

**MINOR** (-5 points each):
- Ambiguous wording
- Missing optional details
- Minor inconsistencies
- Missing examples
- Incomplete task breakdown
- Minor formatting issues

### Scoring

**Starting Score**: 100 points

**Deductions**:
- Critical issues: Block development (score = 0)
- Major issues: -20 points each
- Minor issues: -5 points each

**Minimum Score**: 0 points (cannot go negative)

**Quality Thresholds**:
- **≥ 90/100**: ✅ Ready for Development
- **70-89/100**: ⚠️ Needs Improvement
- **< 70/100**: ❌ Not Ready (significant rework required)

**Note**: Any specification with CRITICAL issues is automatically NOT READY regardless of score.

## Output Format

Generate an `analysis-report.md` file with the following structure:

```markdown
# Specification Analysis: [Spec Name]

**Analyzed By**: AI Specification Analyzer  
**Analysis Date**: YYYY-MM-DD  
**Specification Version**: [from progress.md or v1.0]  

## Analysis Summary

- **Overall Rating**: [score]/100 [✅ READY | ⚠️ NEEDS IMPROVEMENT | ❌ NOT READY]
- **Critical Issues**: [count]
- **Major Issues**: [count]
- **Minor Issues**: [count]

---

## Gaps Analysis

[For each gap found:]

### Gap [#]: [Short Description] [SEVERITY]
**Severity**: [Critical/Major/Minor] ([point deduction])  
**Location**: [filename] - [specific section]  
**Description**: [Detailed description of what's missing]  
**Impact**: [How this affects development or implementation]  
**Recommendation**: [Specific action to resolve]  
**Status**: ⚠️ OPEN

[If no gaps:]
### No Gaps Detected
All requirements appear complete and well-specified.

---

## Conflicts Analysis

[For each conflict found:]

### Conflict [#]: [Short Description] [SEVERITY]
**Severity**: [Critical/Major/Minor] ([point deduction])  
**Location**: [filename] - [specific section]  
**Description**: [Detailed description of the conflict]  
**Conflicts With**: [What it conflicts with - existing feature, other spec, etc.]  
**Impact**: [How this affects integration or compatibility]  
**Recommendation**: [Specific action to resolve]  
**Status**: ⚠️ OPEN

[If no conflicts:]
### No Conflicts Detected
Specification is consistent internally and with existing system.

---

## Duplications Analysis

[For each duplication found:]

### Duplication [#]: [Short Description] [SEVERITY]
**Severity**: [Major/Minor] ([point deduction])  
**Location**: [filename] - [specific section]  
**Description**: [What is duplicated and where]  
**Duplicates**: [Reference to existing feature/spec]  
**Impact**: [Code duplication, maintenance burden, etc.]  
**Recommendation**: [Reuse existing, consolidate, or justify duplication]  
**Status**: ⚠️ OPEN

[If no duplications:]
### No Duplications Detected
Specification introduces new functionality without unnecessary duplication.

---

## Quality Issues

[For each quality issue found:]

### Issue [#]: [Short Description]
**Severity**: [N/A or Minor if affects score]  
**Location**: [filename] - [specific section]  
**Description**: [What is unclear, ambiguous, or low quality]  
**Impact**: [How this affects understanding or implementation]  
**Recommendation**: [Specific improvement suggestion]  
**Status**: ⚠️ OPEN

[If no quality issues:]
### No Quality Issues Detected
Specification is clear, complete, and well-structured.

---

## Rating Calculation

**Starting Score**: 100 points

**Deductions**:
[List each deduction:]
- [Issue description] ([Severity]): -[points] points
- [...]

**Final Score**: 100 - [total deductions] = **[final score]/100**

**Status**: [✅ READY FOR DEVELOPMENT | ⚠️ NEEDS IMPROVEMENT | ❌ NOT READY]

---

## Next Steps

[If score ≥ 90/100:]
### ✅ Specification is Ready for Development

**Recommendations before starting**:
1. [Any minor issues to consider during implementation]
2. [Any nice-to-have improvements for future iterations]

**Proceed to**:
- Manual review and approval by tech lead/architect
- Mark specification as "Ready for Development" in progress.md

---

[If score 70-89/100:]
### ⚠️ Specification Needs Improvement

**Required Actions**:
1. [Resolve all major issues listed above]
2. [Consider addressing high-priority minor issues]
3. [Re-run analysis after fixes]

**Questions to Address**:
[Ask specific questions to guide the spec author:]
- Q1: [Question about Gap/Conflict/Issue #X]
- Q2: [Question about Gap/Conflict/Issue #Y]
- [...]

**After Fixes**:
- Update relevant specification files
- Re-run automated analysis
- Target score: ≥ 90/100

---

[If score < 70/100 OR any critical issues:]
### ❌ Specification is Not Ready

**Critical Issues Must Be Resolved**:
[List all critical issues with detailed explanation]

**Required Actions**:
1. [Specific action for each critical issue]
2. [Address major issues]
3. [Complete missing sections]
4. [Re-run analysis after significant rework]

**Questions to Address**:
[Ask probing questions to guide major rework:]
- Q1: [Fundamental question about missing requirements]
- Q2: [Question about conflicts or architectural concerns]
- Q3: [Question about feasibility or approach]
- [...]

**Next Steps**:
1. Schedule specification review meeting with architect
2. Revise specification based on feedback
3. Re-run automated analysis
4. Target score: ≥ 90/100 with no critical issues

---

## Sign-Off Checklist

- [ ] All critical issues resolved
- [ ] All major issues resolved or accepted as risks
- [ ] Minor issues documented and tracked
- [ ] Overall rating ≥ 90/100
- [ ] Specification ready for manual review

**Ready for Manual Approval**: [YES/NO]

---

## Notes

[Any additional observations, suggestions, or context that doesn't fit above categories]
```

## Analysis Instructions

1. **Read all specification files** in the spec folder
2. **Apply each checklist item** systematically
3. **Document every issue found** with specific references
4. **Assign severity levels** objectively based on impact
5. **Calculate final score** accurately
6. **Ask guiding questions** if score < 90/100
7. **Be constructive** - suggest specific improvements
8. **Be thorough** - better to over-document than miss issues

## Context Awareness

Consider these existing CPR features (check for conflicts/duplications):
- User authentication and authorization (Entra External ID)
- Goal management (create, read, update, delete goals)
- Goal tasks (sub-tasks under goals)
- Project management
- Career tracking
- Feedback system
- Dashboard and reporting
- Taxonomy management (skills, positions, etc.)

## Quality Bar

Remember: The goal is to catch issues BEFORE development, when they're cheapest to fix. Be thorough, be specific, and help the team build better software.

**Your analysis should save time, reduce rework, and improve quality.**
