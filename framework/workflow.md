# CPR Feature Development Workflow

> **Status**: Complete  
> **Current Phase**: Phase 8 (Deploy) - Definition Complete  
> **Last Updated**: 2025-11-11

---

## Overview

This document defines the CPR feature development workflow. Each phase has clear inputs, outputs, and automation support.

---

## Phase 1: Specify Feature

### Purpose
Create initial feature specification with clear business requirements and technical foundation.

### Inputs
- Feature idea or requirement
- Feature number (e.g., 0001)
- Short feature name (e.g., "user-profile-management")

### Process

1. **Create Specification Folder**
   - Location: `specifications/[####]-<short-feature-name>/`
   - Example: `specifications/0001-user-profile-management/`

2. **Create Git Branches**
   - Branch name: `feature/[####]-<short-feature-name>`
   - Create in: `cpr-api` and `cpr-ui` repositories
   - Example: `feature/0001-user-profile-management`

3. **Generate Specification Document**
   - File: `specifications/[####]-<short-feature-name>/description.md`
   - Generated from: `framework/templates/description.md`
   - Use GitHub Copilot to fill in template content
   - Template provides structure for:
     - Executive summary
     - User stories with acceptance criteria
     - Business rules
     - Technical requirements
     - API design
     - Data model
     - Type definitions (C# DTOs and TypeScript interfaces)
     - Testing strategy
     - Constitutional compliance checklist

### Outputs
- ✅ Specification folder created
- ✅ Git branches created in cpr-api and cpr-ui
- ✅ `description.md` file ready for Copilot to populate
- ✅ `progress.md` file created for tracking progress

### Automation
- Tool: `framework/tools/phase-1-specify.ps1`
- Usage: `.\framework\tools\phase-1-specify.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"`

### Success Criteria
- Specification folder exists with correct naming
- Both repository branches created successfully
- `description.md` contains complete specification following CPR principles
- All constitutional compliance requirements addressed
- `progress.md` updated with Phase 1 completion status

---

## Phase 2: Refine Specification

### Purpose
Walk through user stories, ask clarifying questions, and refine the specification with additional details to ensure complete understanding before implementation.

### Inputs
- Completed `description.md` from Phase 1
- Product owner or stakeholder availability for questions
- Existing system context (API, UI, database)

### Process

1. **Review User Stories**
   - Analyze each user story for completeness
   - Identify ambiguities, edge cases, and missing acceptance criteria
   - Check for consistency across user stories

2. **Generate Clarifying Questions**
   - For each user story, formulate specific questions about:
     - Edge cases and error scenarios
     - UI behavior and user interactions
     - Data validation rules
     - Performance expectations
     - Security and authorization details
     - Integration points with existing features

3. **Stakeholder Interview**
   - Present questions to product owner/stakeholders
   - Document answers and decisions
   - Capture additional requirements that surface

4. **Update Specification**
   - Incorporate clarifications into `description.md`
   - Add edge cases to acceptance criteria
   - Refine business rules with new insights
   - Update API design if needed
   - Enhance technical requirements with specifics

5. **Validation**
   - Ensure all questions are answered
   - Verify no contradictions in updated specification
   - Confirm alignment with constitutional principles
   - Get stakeholder sign-off on refined specification

6. **Generate UX Mockups**
   - Generate mermaid diagrams to illustrate user interface in the description.md

### Outputs
- ✅ Updated `description.md` with clarifications
- ✅ Edge cases and error scenarios documented
- ✅ All ambiguities resolved
- ✅ Stakeholder approval obtained
- ✅ Specification ready for implementation planning
- ✅ `progress.md` updated with Phase 2 completion status

### Automation
- Tool: `framework/tools/phase-2-refine.ps1`
- Prompt: `framework/prompts/phase-2-refine.md`
- Usage: 
  ```powershell
  .\framework\tools\phase-2-refine.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
  ```
- The script validates Phase 1 completion and prepares for Phase 2
- Use GitHub Copilot with phase-2-refine.md prompt for interactive refinement

### Success Criteria
- All user stories have clear, unambiguous acceptance criteria
- Edge cases are identified and documented
- Technical details are specific enough for developers to implement
- No outstanding questions or ambiguities remain
- Stakeholders confirm specification matches their intent

---

## Phase 3: Plan Implementation

### Purpose
Create detailed implementation plan with technical design, API contracts, task breakdown, and resource allocation for both backend (cpr-api) and frontend (cpr-ui).

### Inputs
- Refined `description.md` from Phase 2
- CPR constitutional principles
- Existing API and UI architecture patterns
- Project technical stack (C# .NET 8, React 18, PostgreSQL)

### Process

1. **Initialize Planning Artifacts**
   - Create mandatory planning documents from templates:
     - `implementation-plan.md` - Technical strategy and execution phases
     - `tasks.md` - Detailed task checklist with dependencies
     - `endpoints.md` - API endpoint specifications
   - Create optional documents as needed:
     - `data-model.md` - Entity definitions and database schema (if data changes required)
     - `research.md` - Technical decisions and alternatives (if new technologies or patterns)

2. **Analyze Technical Requirements**
   - Review refined specification for technical implications
   - Identify backend vs frontend work distribution
   - Map user stories to API endpoints and UI components
   - Determine data model changes and migrations
   - Assess integration points with existing features

3. **Generate Implementation Plan**
   - Define implementation phases and milestones
   - Estimate effort and timeline for each phase
   - Identify technical risks and mitigation strategies
   - Plan for both cpr-api and cpr-ui repositories
   - Ensure constitutional compliance throughout

4. **Design API Contracts**
   - Define RESTful endpoints with HTTP methods
   - Specify request/response DTOs (C# and TypeScript)
   - Follow snake_case naming for JSON/API
   - Document authentication and authorization requirements
   - Include error responses and status codes

5. **Create Task Breakdown**
   - Break down implementation into actionable tasks
   - Use checklist format with task IDs and labels
   - Organize by user story and implementation phase
   - Identify dependencies and parallel execution opportunities
   - Include file paths for each task

6. **Define Data Model** (if needed)
   - Specify database entities and relationships
   - Define constraints, indexes, and migrations
   - Map to C# Domain models and DTOs
   - Follow snake_case for database naming
   - Consider offline mode implications

7. **Document Technical Decisions** (if needed)
   - Record technology choices and rationale
   - Document alternatives considered
   - Explain architectural patterns selected
   - Note performance considerations

8. **Constitutional Compliance Check**
   - Verify all 11 CPR principles are addressed
   - Ensure API contract consistency (Principle 2)
   - Validate type safety approach (Principle 4)
   - Confirm naming conventions (Principle 9)
   - Document security measures (Principle 10)

### Outputs
- ✅ `implementation-plan.md` - Complete technical implementation strategy
- ✅ `tasks.md` - Executable task checklist with dependencies
- ✅ `endpoints.md` - API endpoint specifications
- ✅ `data-model.md` - Entity and schema definitions (if applicable)
- ✅ `research.md` - Technical decisions documentation (if applicable)
- ✅ `progress.md` updated with Phase 3 completion status

### Automation
- Tool: `framework/tools/phase-3-plan.ps1`
- Prompt: `framework/prompts/phase-3-plan.md`
- Usage: 
  ```powershell
  .\framework\tools\phase-3-plan.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
  ```
- The script creates template files in the specification folder
- Use GitHub Copilot with phase-3-plan.md prompt to populate templates

### Success Criteria
- Implementation plan covers both backend and frontend work
- All API endpoints defined with complete request/response contracts
- Tasks are specific, actionable, and include file paths
- Dependencies between tasks are clearly identified
- Data model changes properly planned with migrations
- Constitutional compliance verified for all aspects
- Technical risks identified with mitigation plans
- Effort estimates provided for resource planning
- `progress.md` updated with Phase 3 completion

---

## Phase 4: Analyze Specification

### Purpose
Perform comprehensive quality analysis of all specification artifacts to ensure completeness, consistency, and readiness for implementation. Generate a quality score and identify any issues that must be resolved before development begins.

### Inputs
- Completed `description.md` from Phase 2
- Completed `implementation-plan.md` from Phase 3
- Completed `tasks.md` from Phase 3
- Completed `endpoints.md` from Phase 3
- Optional: `data-model.md`, `research.md` from Phase 3
- CPR Constitutional Principles from `constitution.md`
- Existing feature specifications (for conflict detection)

### Process

1. **Load All Artifacts**
   - Read all specification files in the feature folder
   - Load constitution.md for principle validation
   - Review related feature specifications for conflicts

2. **Completeness Analysis**
   - Verify all required sections present in each artifact
   - Check for missing user stories, acceptance criteria, business rules
   - Validate constitutional compliance checklist completed
   - Identify missing technical details or specifications

3. **Consistency Analysis**
   - Cross-check DTOs between C# and TypeScript definitions
   - Verify endpoints match between description.md and endpoints.md
   - Validate database schema aligns with data model descriptions
   - Check task coverage maps to all requirements and user stories
   - Ensure terminology is consistent across all artifacts

4. **Conflict Detection**
   - Identify internal contradictions within specification
   - Check for conflicts with other feature specifications
   - Detect API endpoint path collisions
   - Find database schema conflicts
   - Flag constitutional principle violations

5. **Gap Analysis**
   - Find requirements without associated implementation tasks
   - Identify tasks without mapped requirements (orphan tasks)
   - Detect missing security, performance, or testing coverage
   - Locate underspecified error handling or edge cases

6. **Ambiguity Detection**
   - Flag vague language without measurable criteria
   - Identify unresolved placeholders (TODO, TBD, ???)
   - Find untestable acceptance criteria
   - Detect underspecified requirements

7. **Duplication Analysis**
   - Identify duplicate or redundant requirements
   - Find overlapping tasks
   - Detect repeated business rules

8. **Constitutional Compliance Review**
   - Verify compliance with all 11 CPR Constitutional Principles
   - Check naming conventions (snake_case, PascalCase, kebab-case)
   - Validate type safety approach
   - Confirm offline mode and i18n support
   - Review security and performance specifications

9. **Parallel Work Analysis**
   - Identify critical path (sequential dependencies)
   - Find tasks that can execute in parallel
   - Suggest team distribution (backend, frontend, QA)
   - Calculate potential time savings with parallelism
   - Recommend work packages for different developers

10. **Calculate Quality Score**
    - Start with 100 points
    - Deduct points based on severity:
      - CRITICAL issue: Immediate fail (blocks development)
      - HIGH issue: -20 points each
      - MEDIUM issue: -5 points each
      - LOW issue: -1 point each
    - Determine status: ≥90 = Ready, 70-89 = Needs Improvement, <70 = Not Ready

11. **Generate Analysis Report**
    - Create `analysis-report.md` with findings
    - Include quality score and issue breakdown
    - Document constitutional compliance status
    - Provide coverage analysis (requirements → tasks)
    - Include parallel work opportunities
    - Add actionable recommendations prioritized by severity

### Outputs
- ✅ `automation-report.json` - Automated specification analysis results (generated by tool)
- ✅ `analysis-report.md` - Comprehensive quality analysis report (AI-assisted)
- ✅ Quality score (0-100) with clear status
- ✅ Findings table with severity, location, and recommendations
- ✅ Constitutional compliance review (all 11 principles)
- ✅ Coverage analysis (requirements and tasks mapping)
- ✅ Parallel work analysis (critical path and opportunities)
- ✅ Prioritized recommendations for remediation
- ✅ `progress.md` updated with Phase 4 completion status

### Automation
- Tool: `framework/tools/phase-4-analyze.ps1` (to be created)
- Prompt: `framework/prompts/phase-4-analyze.md`
- Usage: 
  ```powershell
  .\framework\tools\phase-4-analyze.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
  ```
- The script validates Phase 3 completion and prepares for Phase 4
- Use GitHub Copilot with phase-4-analyze.md prompt to generate analysis report

### Success Criteria
- `analysis-report.md` exists with complete analysis
- Quality score calculated and documented
- All 11 constitutional principles reviewed
- All CRITICAL issues identified (if any)
- Coverage analysis shows requirements → tasks mapping
- Parallel work opportunities documented
- Clear next actions provided based on score:
  - **Score ≥ 90**: Approved for Phase 5 (Implementation)
  - **Score 70-89**: Must address HIGH and MEDIUM issues before Phase 5
  - **Score < 70 or any CRITICAL**: Blocked, must revisit Phases 1-3
- `progress.md` updated with Phase 4 completion

### Quality Thresholds
- **≥ 90/100**: ✅ Ready for Development - Proceed to Phase 5
- **70-89/100**: ⚠️ Needs Improvement - Fix major issues first
- **< 70/100**: ❌ Not Ready - Significant rework required
- **Any CRITICAL issue**: ❌ Blocked - Must resolve before proceeding

---

## Phase 5: Implement

### Purpose
Execute the implementation plan by creating code files, following task breakdown, and maintaining constitutional compliance throughout development.

### Inputs
- Phase 4 complete with quality score ≥ 90/100
- `description.md` - Feature requirements and specifications
- `implementation-plan.md` - Technical design and architecture
- `tasks.md` - Complete task breakdown with dependencies
- `endpoints.md` - API contracts
- `analysis-report.md` - Quality findings and recommendations
- Optional: `data-model.md`, `research.md`

### Process

#### Preparation (Automated)

Run automation tool:
```powershell
.\framework\tools\phase-5-implement.ps1 -FeatureNumber "0001" -FeatureName "feature-name"
```

**Tool Actions**:
1. Validates Phase 4 completion (quality score ≥ 90)
2. Checks all required specification files exist
3. Verifies cpr-api and cpr-ui repositories exist
4. Creates feature branches: `feature/####-<feature-name>`
5. Analyzes task breakdown (total, completed, parallel opportunities)
6. Generates implementation-summary.txt with guidance

#### Implementation (AI-Assisted)

Use GitHub Copilot with Phase 5 prompt:
```
@workspace Use framework/prompts/phase-5-implement.md to implement feature ####
```

**Implementation Flow**:

**Step 1: Load Context**
- Read tasks.md, implementation-plan.md, description.md, endpoints.md
- Understand task phases, dependencies, and parallel opportunities
- Review technology stack (cpr-api: .NET 8, cpr-ui: React 18)

**Step 2: Verify Prerequisites**
- cpr-api: Feature branch checked out, .NET 8 SDK available, solution compiles
- cpr-ui: Feature branch checked out, Node.js 20+, dependencies installed

**Step 3: Execute Phase 1 (Setup & Project Structure)**
- Backend: Database migration, domain entities, repository/service interfaces, DTOs
- Frontend: TypeScript types, DTOs, component folder structure
- Follow naming conventions (Constitutional Principle 9)
- Mark tasks complete in tasks.md: `[ ]` → `[x]`
- Git commit after phase: `git commit -m "feat(####): Phase 1 - Setup complete"`

**Step 4: Execute Phase 2 (Foundational Implementation)**
- Repository implementations
- Service layer implementations
- Base component implementations
- Validation rules and authorization policies
- Write tests before implementation code (TDD approach)
- Constitutional compliance: Type safety, API contracts, security
- Git commit: `git commit -m "feat(####): Phase 2 - Foundational implementation"`

**Step 5: Execute User Story Tasks (Phases 3+)**
For each user story:
- Backend: Controllers, endpoints, DTO mapping, authorization, validation
- Frontend: React Query hooks, components, forms, state management, offline sync
- Tests: Unit, integration, component, E2E
- Validate acceptance criteria from description.md
- Git commit per story: `git commit -m "feat(####): Implement US-00X - [story name]"`

**Step 6: Execute Polish Phase**
- Error handling refinements
- Loading states, empty states, error messages
- Accessibility (ARIA labels)
- Internationalization (i18n keys for all UI text)
- Performance optimization
- Code documentation
- Final validation tests

**Step 7: Final Validation**
- All tasks in tasks.md marked `[x]`
- All tests passing (unit, integration, E2E)
- Code compiles/builds successfully
- No linting errors
- Feature works end-to-end locally
- Constitutional compliance verified

#### Progress Tracking

**Update tasks.md**: Mark each task complete as implemented
**Update progress.md**: Update Phase 5 status after each major milestone

**Git Workflow**:
- Commit after each phase completion
- Push regularly to backup work
- Use conventional commits: `feat(####): Description`

### Automation Tool

**Script**: `framework/tools/phase-5-implement.ps1`

**Validation Steps**:
1. Checks Phase 4 complete (analysis-report.md exists, score ≥ 90)
2. Validates all required specification files
3. Verifies repository state (uncommitted changes warning)
4. Creates feature branches in cpr-api and cpr-ui
5. Parses task statistics (total, completed, remaining, parallel)
6. Generates implementation-summary.txt

**Options**:
- `-SkipBranchCreation`: Skip branch creation if already exists

### Outputs

**Code Deliverables**:
- Complete backend implementation in cpr-api feature branch
- Complete frontend implementation in cpr-ui feature branch
- All code compiles and builds successfully
- All tests passing (unit, integration, E2E)

**Documentation Updates**:
- Updated `tasks.md` (all tasks marked `[x]`)
- Updated `progress.md` (Phase 5 status complete)
- Optional: `implementation-summary.txt` (generated by tool)
- Optional: Test coverage reports

**Git Artifacts**:
- Clean commit history with descriptive messages
- Feature branches ready for pull requests
- All changes pushed to remote

### AI-Assisted Implementation

**GitHub Copilot Prompt**: `framework/prompts/phase-5-implement.md`

**Prompt Features**:
- Task-driven development guidance
- Phase-by-phase execution steps
- TDD approach (write tests first)
- Constitutional compliance checks
- Error handling strategies
- Progress tracking instructions
- Quality gate validation
- Git workflow best practices
- Example task implementation

**Implementation Principles**:
1. **Task-Driven**: Only implement what's in tasks.md
2. **Test-First**: Write tests before implementation code
3. **Type-Safe**: Strong typing in C#, no `any` in TypeScript
4. **Incremental**: Complete one task/phase at a time
5. **Constitutional**: Maintain all 11 principles throughout
6. **Traceable**: Mark tasks complete, commit regularly

### Success Criteria
- All tasks in tasks.md marked `[x]` (typically 60-80 tasks)
- Backend compiles with no errors or warnings
- Frontend builds successfully
- All unit tests pass (>80% coverage target)
- All integration tests pass
- All E2E tests pass
- Feature works end-to-end locally
- No linting errors
- All 11 constitutional principles maintained
- Git history clean with descriptive commits
- `progress.md` updated to Phase 5 complete
- Ready for Phase 6 (Code Review)

### Constitutional Compliance During Implementation

**Critical Principles to Maintain**:
- **Principle 2**: C# DTOs use `[JsonPropertyName]` for snake_case JSON
- **Principle 4**: Strong typing everywhere, validation attributes in C#
- **Principle 5**: IndexedDB caching, React Query persistent cache
- **Principle 6**: All UI text uses i18n keys, locale-aware formatting
- **Principle 7**: Comprehensive tests (unit, integration, E2E)
- **Principle 9**: Naming conventions (snake_case JSON, PascalCase C#, camelCase TS)
- **Principle 11**: UUID PKs, proper indexes, soft delete pattern

### Quality Gates

**Before Marking Task Complete**:
- Code compiles/parses successfully
- Tests pass (if applicable)
- No linting errors
- Follows constitutional principles

**Before Marking Phase Complete**:
- All phase tasks marked `[x]`
- Code compiles with no errors
- All tests pass
- Git committed and pushed

**Before Marking Feature Complete**:
- All 60-80 tasks marked `[x]`
- All acceptance criteria validated
- E2E tests pass
- Performance targets met (<200ms API, <1s UI)
- Security audit passed
- Ready for code review

### Time Estimates
- **Small Feature** (20-30 tasks): 1-2 weeks
- **Medium Feature** (40-60 tasks): 2-4 weeks
- **Large Feature** (70-100 tasks): 4-6 weeks

*Estimates assume 1-3 developers working with parallel execution*

---

## Phase 6: Code Review

### Purpose
Conduct comprehensive code review of the implemented feature to ensure quality, standards compliance, constitutional alignment, and readiness for testing.

### Inputs
- Phase 5 complete: All tasks marked `[x]` in tasks.md
- Feature branches with committed code in cpr-api and cpr-ui
- Code compiles/builds successfully
- All unit tests passing
- Specification documents from Phases 1-3

### Process

1. **Run Automation Tool**
   - Execute: `.\framework\tools\phase-6-review.ps1 -FeatureNumber "####" -FeatureName "feature-name"`
   - Tool validates:
     - Build/compilation status (both repositories)
     - Test execution results (pass/fail, coverage %)
     - Linting errors and warnings
     - Code complexity metrics
     - Git commit history quality
     - Task completion percentage
   - Generates `automation-review.json` with automated findings and baseline score

2. **AI-Assisted Comprehensive Review**
   - Use GitHub Copilot with `framework/prompts/phase-6-review.md`
   - Review automated findings from automation-review.json
   - Perform semantic analysis automation cannot detect:
     - Architecture compliance (layering, patterns)
     - Code quality (type safety, naming, complexity)
     - Constitutional compliance (all 11 principles)
     - Security vulnerabilities (authentication, authorization, validation)
     - Performance issues (N+1 queries, response times, bundle size)
     - Testing quality (coverage, test quality, edge cases)
     - Documentation completeness
     - Cross-repository consistency (DTOs, API contracts)

3. **Verify Implementation Completeness**
   - Cross-check against tasks.md (100% complete)
   - Cross-check against endpoints.md (all APIs implemented)
   - Cross-check against data-model.md (migrations, entities)
   - Validate all acceptance criteria from description.md met

4. **Calculate Review Score**
   - Start with 100 points
   - Deduct based on severity:
     - **CRITICAL**: Immediate fail (security vulnerabilities, build failures, contract mismatches)
     - **HIGH**: -15 points each (missing functionality, architecture violations, performance issues)
     - **MEDIUM**: -5 points each (code quality issues, naming violations, documentation gaps)
     - **LOW**: -1 point each (minor style issues, refactoring opportunities)
   - Final score = weighted average (40% automated, 60% AI semantic review)

5. **Generate Review Report**
   - Create `review-report.md` in specification folder
   - Include:
     - Executive summary and decision (APPROVED/CONDITIONAL/REJECTED)
     - Final score (0-100)
     - Review metrics table (build, tests, coverage, complexity)
     - Constitutional compliance status (11/11 principles)
     - Detailed findings by severity with location, description, remediation
     - Strengths and positive aspects
     - Prioritized recommendations
     - Clear next steps based on decision

6. **Make Approval Decision**
   - **≥ 85/100**: ✅ **APPROVED** - Proceed to Phase 7 (Testing)
   - **70-84/100**: ⚠️ **CONDITIONAL** - Fix HIGH issues before Phase 7
   - **< 70/100 or any CRITICAL**: ❌ **REJECTED** - Rework required, return to Phase 5

### Outputs
- ✅ `automation-review.json` - Automated validation results and metrics
- ✅ `review-report.md` - Comprehensive review findings and decision
- ✅ Quality score (0-100) with clear status
- ✅ Constitutional compliance review (all 11 principles)
- ✅ Detailed findings categorized by severity (CRITICAL/HIGH/MEDIUM/LOW)
- ✅ Prioritized recommendations for fixes
- ✅ Clear approval decision (APPROVED/CONDITIONAL/REJECTED)
- ✅ `progress.md` updated with Phase 6 completion status

### Automation
- Tool: `framework/tools/phase-6-review.ps1`
- Prompt: `framework/prompts/phase-6-review.md`
- Usage:
  ```powershell
  .\framework\tools\phase-6-review.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
  ```
- The script validates Phase 5 completion and runs automated checks
- Use GitHub Copilot with phase-6-review.md prompt to generate review report

### Success Criteria
- `automation-review.json` exists with complete automated findings
- `review-report.md` exists with comprehensive review
- Quality score calculated and justified
- All 11 constitutional principles reviewed
- All findings have severity, location, description, and remediation
- Clear decision made: APPROVED/CONDITIONAL/REJECTED
- If APPROVED: No CRITICAL issues, ≥ 85/100 score, ready for Phase 7
- If CONDITIONAL: HIGH issues documented, fix path clear
- If REJECTED: CRITICAL or multiple HIGH issues, rework plan provided
- `progress.md` updated with Phase 6 status and decision

### Review Quality Thresholds
- **≥ 85/100**: ✅ **APPROVED** - Proceed to Phase 7 (Testing)
- **70-84/100**: ⚠️ **CONDITIONAL** - Fix HIGH issues before Phase 7
- **< 70/100**: ❌ **REJECTED** - Significant rework required, return to Phase 5
- **Any CRITICAL issue**: ❌ **BLOCKED** - Must resolve immediately before proceeding

### Review Categories
1. **Architecture Review**: Layering, patterns, separation of concerns
2. **Code Quality Review**: Type safety, naming, complexity, SOLID principles
3. **Constitutional Compliance**: All 11 CPR principles verification
4. **Security Review**: Authentication, authorization, input validation, data protection
5. **Performance Review**: Database queries, API response times, bundle size
6. **Testing Review**: Coverage, test quality, edge cases
7. **Documentation Review**: Code comments, API docs, specification updates
8. **Consistency Review**: DTO alignment, API contracts, coding patterns
9. **Git History Review**: Commit quality, conventional commits, branch hygiene

### Time Estimates
- **Small Feature** (20-30 tasks): 1-2 hours review
- **Medium Feature** (40-60 tasks): 2-4 hours review
- **Large Feature** (70-100 tasks): 4-6 hours review

*AI-assisted review significantly faster than pure manual review*

---

## Phase 7: Test

### Purpose
Execute comprehensive testing strategy including integration tests, end-to-end tests, performance validation, security testing, and user acceptance testing to ensure the feature is production-ready.

### Inputs
- Phase 6 complete: Code review APPROVED (score ≥ 85/100)
- Working code in feature branches (cpr-api and cpr-ui)
- Unit tests passing with adequate coverage
- `description.md` with acceptance criteria
- `review-report.md` with approval decision

### Process

1. **Run Automation Tool**
   - Execute: `.\framework\tools\phase-7-test.ps1 -FeatureNumber "####" -FeatureName "feature-name"`
   - Tool prepares test environment:
     - Validates Phase 6 APPROVED status
     - Sets up test database
     - Starts backend API (test mode)
     - Starts frontend dev server
     - Validates test configuration
   - Generates `test-plan.md` from template with test scenarios

2. **Execute Integration Tests**
   - API integration tests (controller → service → repository → database)
   - External service integration tests (if applicable)
   - Cross-repository integration (API + UI together)
   - Verify all acceptance criteria from description.md
   - Test error scenarios and edge cases
   - Validate data persistence and retrieval

3. **Execute End-to-End (E2E) Tests**
   - Critical user journeys (happy paths)
   - Complete workflows from UI through to database
   - Multi-step scenarios
   - Cross-feature interactions
   - Browser compatibility (Chrome, Firefox, Edge)
   - Mobile responsive testing

4. **Performance Testing**
   - API endpoint response times (target: <200ms)
   - UI interaction responsiveness (target: <1s)
   - Database query performance (no N+1 queries)
   - Load testing (concurrent users)
   - Memory usage monitoring
   - Bundle size validation (<500KB initial load)

5. **Security Testing**
   - Authentication flow validation
   - Authorization enforcement (role/policy tests)
   - Input validation and sanitization
   - SQL injection prevention
   - XSS prevention
   - CSRF protection (if applicable)
   - Security headers validation
   - Sensitive data protection

6. **Offline Mode Testing** (Constitutional Principle 5)
   - Offline data access
   - Optimistic updates
   - Sync conflict resolution
   - IndexedDB caching
   - React Query persistence

7. **Internationalization Testing** (Constitutional Principle 6)
   - All UI text uses i18n keys
   - Multiple locale testing (en, es, fr, etc.)
   - Date/time formatting
   - Number/currency formatting
   - RTL language support (if applicable)

8. **Accessibility Testing**
   - Keyboard navigation
   - Screen reader compatibility
   - ARIA labels and roles
   - Color contrast
   - Focus management

9. **User Acceptance Testing (UAT)**
   - Stakeholder walkthrough
   - Validate against original requirements
   - Test in realistic scenarios
   - Gather feedback
   - Verify all acceptance criteria met

10. **Generate Test Report**
    - Use GitHub Copilot with `framework/prompts/phase-7-test.md`
    - Create `test-report.md` with:
      - Test execution summary
      - Coverage metrics (unit, integration, E2E)
      - Performance benchmarks
      - Security audit results
      - Issues found and resolution status
      - UAT feedback
      - Production readiness decision

11. **Make Production Readiness Decision**
    - **READY**: All tests pass, no blocking issues
    - **CONDITIONAL**: Minor issues found, can deploy with monitoring
    - **NOT READY**: Significant issues require fixes

### Outputs
- ✅ `test-plan.md` - Comprehensive test scenarios and checklists
- ✅ `test-report.md` - Complete test execution results
- ✅ `automation-test.json` - Automated test results and metrics
- ✅ Integration test execution logs
- ✅ E2E test recordings/screenshots (if failures)
- ✅ Performance benchmark results
- ✅ Security audit report
- ✅ UAT sign-off (if applicable)
- ✅ Production readiness decision (READY/CONDITIONAL/NOT READY)
- ✅ `progress.md` updated with Phase 7 completion status

### Automation
- Tool: `framework/tools/phase-7-test.ps1`
- Prompt: `framework/prompts/phase-7-test.md`
- Usage:
  ```powershell
  .\framework\tools\phase-7-test.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
  ```
- The script prepares test environment and generates test plan
- Use GitHub Copilot with phase-7-test.md prompt to execute tests and generate report

### Success Criteria
- All integration tests pass
- All E2E tests pass for critical journeys
- Performance targets met (API <200ms, UI <1s)
- Security tests pass with no vulnerabilities
- Offline mode works correctly
- All UI text internationalized
- Accessibility standards met (WCAG 2.1 AA)
- All acceptance criteria validated
- UAT approved by stakeholders
- `test-report.md` documents all results
- Production readiness decision made: READY/CONDITIONAL/NOT READY
- `progress.md` updated with Phase 7 status

### Testing Quality Thresholds

**Production Readiness Scores**:
- **≥90/100**: READY - Approved for production deployment
- **75-89/100**: CONDITIONAL - Staging deployment only, must reach READY for production
- **<75/100**: NOT READY - Blocked, return to earlier phases to fix issues

**Quality Criteria**:
- **Integration Tests**: 100% of API endpoints tested
- **E2E Tests**: All critical user journeys covered
- **Performance**: API <200ms (95th percentile), UI <1s
- **Security**: No HIGH or CRITICAL vulnerabilities
- **Accessibility**: WCAG 2.1 AA compliance
- **UAT**: Stakeholder approval obtained

### Test Categories
1. **Integration Tests**: API endpoints, service layer, data layer
2. **E2E Tests**: User journeys, workflows, cross-feature scenarios
3. **Performance Tests**: Response times, load testing, memory usage
4. **Security Tests**: Authentication, authorization, input validation, vulnerabilities
5. **Offline Tests**: Data access, sync, conflict resolution
6. **i18n Tests**: Multiple locales, formatting, RTL support
7. **Accessibility Tests**: Keyboard, screen reader, ARIA, contrast
8. **UAT**: Stakeholder validation, acceptance criteria verification

### Time Estimates
- **Small Feature** (20-30 tasks): 1-2 days testing
- **Medium Feature** (40-60 tasks): 2-4 days testing
- **Large Feature** (70-100 tasks): 4-7 days testing

*Estimates include test execution, bug fixes, and retesting*

### Production Readiness Decision

**READY for Phase 8 (Deploy)**:
- ✅ All tests pass
- ✅ Performance targets met
- ✅ No security vulnerabilities
- ✅ UAT approved
- ✅ No blocking issues

**CONDITIONAL**:
- ⚠️ Minor issues found
- ⚠️ Workarounds documented
- ⚠️ Monitoring plan in place
- ⚠️ Can deploy with close observation

**NOT READY**:
- ❌ Test failures
- ❌ Performance issues
- ❌ Security vulnerabilities
- ❌ UAT not approved
- ❌ Must fix before deployment

---

## Phase 8: Deploy

**Purpose**: Deploy feature to production with monitoring, rollback plan, and post-deployment validation

**Prerequisites**:
- Phase 7 complete with test-report.md showing READY or CONDITIONAL status
- Production readiness score ≥75/100 (CONDITIONAL) or ≥90/100 (READY)
- All CRITICAL and HIGH issues resolved
- UAT approval obtained
- Deployment plan reviewed and approved

**Inputs**:
- `test-report.md` with production readiness decision
- `automation-test.json` with test results
- Feature branches (feature/####-feature-name) in both repositories
- Implementation artifacts (code, tests, documentation)

**Process**:

1. **Run Automation Tool**
   - Execute: `.\framework\tools\phase-8-deploy.ps1 -FeatureNumber "####" -FeatureName "feature-name" -Environment "staging|production"`
   - Tool prepares deployment:
     - Validates Phase 7 READY/CONDITIONAL status
     - Checks for merge conflicts
     - Validates CI/CD pipeline status
     - Generates deployment checklist
     - Creates rollback plan
   - Generates `deployment-plan.md` from template

2. **Pre-Deployment Validation**
   - Verify all tests passing in CI/CD
   - Review database migration scripts (if any)
   - Verify environment variables configured
   - Check infrastructure capacity
   - Validate secrets/credentials
   - Review monitoring dashboards

3. **Merge to Main Branch**
   - Create pull request from feature branch → main
   - Code review (if not done in Phase 6)
   - Pass all CI/CD checks
   - Obtain approval from tech lead
   - Merge (squash or merge commit based on policy)
   - Tag release version (semantic versioning)

4. **Deploy to Staging**
   - Deploy backend API to staging environment
   - Deploy frontend UI to staging environment
   - Run database migrations (if applicable)
   - Smoke test critical paths
   - Validate integrations
   - Performance validation

5. **Staging Validation**
   - Execute smoke tests
   - Verify all API endpoints responding
   - Test critical user journeys
   - Check error logs
   - Validate monitoring/alerts
   - Performance baseline check

6. **Deploy to Production**
   - Schedule deployment window (off-peak hours if possible)
   - Notify stakeholders of deployment
   - Execute blue-green or rolling deployment
   - Deploy backend API to production
   - Deploy frontend UI to production
   - Run production database migrations (with backup)
   - Update configuration/feature flags

7. **Production Validation**
   - Execute smoke tests on production
   - Verify health check endpoints
   - Test critical user journeys
   - Check error logs and monitoring
   - Validate performance metrics
   - Test authentication and authorization
   - Verify data integrity

8. **Post-Deployment Monitoring**
   - Monitor error rates (first 15 minutes critical)
   - Monitor API response times
   - Monitor database query performance
   - Monitor user activity/adoption
   - Check application logs
   - Validate alerts functioning

9. **Rollback Decision** (if issues detected)
   - Evaluate severity of issues
   - If CRITICAL: Execute immediate rollback
   - If HIGH: Assess if hotfix possible
   - If MEDIUM/LOW: Monitor and plan fix
   - Document rollback execution if needed

10. **Update Documentation**
    - Update CHANGELOG.md
    - Update API documentation (if endpoints changed)
    - Update user documentation (if UI changed)
    - Document known issues (if CONDITIONAL deployment)
    - Update runbooks for operations team

11. **Stakeholder Communication**
    - Notify stakeholders of successful deployment
    - Share deployment report
    - Communicate known issues (if any)
    - Provide feedback channels
    - Schedule post-deployment review

12. **Generate Deployment Report**
    - Document deployment timeline
    - Record all validation results
    - Note any issues encountered
    - Document monitoring baseline
    - Include rollback plan status
    - Save as `deployment-report.md`

**Outputs**:
- Feature deployed to production
- `deployment-plan.md` - Pre-deployment checklist and rollback plan
- `automation-deploy.json` - Automated deployment validation results
- `deployment-report.md` - Complete deployment documentation
- Updated `progress.md` with Phase 8 complete
- Git tags for release version
- Updated CHANGELOG.md

**Automation**:
- `phase-8-deploy.ps1` validates prerequisites, generates deployment plan, validates environments
- AI prompt (`phase-8-deploy.md`) guides through deployment process and report generation

**Success Criteria**:
- ✅ Feature successfully deployed to production
- ✅ All smoke tests passing in production
- ✅ No critical errors in logs
- ✅ Performance within acceptable ranges
- ✅ Monitoring alerts configured
- ✅ Stakeholders notified
- ✅ Deployment report generated
- ✅ Feature available to users

**Deployment Strategies**:
1. **Blue-Green Deployment**: Two identical environments, switch traffic after validation
2. **Rolling Deployment**: Gradual rollout to servers, one at a time
3. **Canary Deployment**: Deploy to small subset of users first
4. **Feature Flags**: Deploy code but control activation via flags

**Rollback Plan**:
- Database rollback scripts prepared
- Previous version deployment artifacts saved
- Feature flags can disable new feature
- Monitoring alerts trigger automatic rollback (optional)
- Manual rollback procedure documented

**Monitoring Checklist**:
- Application error rate
- API response times (p50, p95, p99)
- Database query performance
- Infrastructure metrics (CPU, memory, disk)
- User activity metrics
- Business metrics (feature adoption)

**Time Estimates**:
- **Staging Deployment**: 30 minutes - 1 hour
- **Staging Validation**: 30 minutes - 1 hour
- **Production Deployment**: 30 minutes - 1 hour
- **Production Validation**: 1-2 hours
- **Post-Deployment Monitoring**: 24 hours active monitoring
- **Total**: 1-2 days for complete deployment cycle

### Deployment Decision Matrix

| Test Score | Status | Action |
|------------|--------|--------|
| ≥90/100 | READY | Approved for production deployment with standard process |
| 75-89/100 | CONDITIONAL | Staging deployment only - must address issues and reach READY before production |
| <75/100 | NOT READY | Blocked - return to Phase 5 or 6 to fix issues |

**Note**: Production deployment requires READY status (≥90/100). CONDITIONAL status allows staging deployment for additional validation but requires fixing identified issues before production release.

---

## Future Phases

_All 8 phases now defined. Framework complete for feature development lifecycle._

---

## Notes

- This workflow is being developed iteratively
- Each phase is tested and validated before moving to the next
- Automation tools prepare environment and execute checks; AI guides deployment process
- **Phases 1-8 complete**: Specify → Refine → Plan → Analyze → Implement → Review → Test → Deploy
- Framework covers complete feature lifecycle from specification to production deployment
