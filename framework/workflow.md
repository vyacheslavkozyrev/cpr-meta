# CPR Feature Development Workflow

> **Status**: In Development  
> **Current Phase**: Phase 2 (Refine) - Definition Complete  
> **Last Updated**: 2025-11-06

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

## Future Phases

### Phase 4: Analyze (Not Yet Defined)
_To be defined after Phase 3 is validated_

### Phase 5: Implement (Not Yet Defined)
_To be defined after Phase 4 is validated_

### Phase 6: Code Review (Not Yet Defined)
_To be defined after Phase 5 is validated_

### Phase 7: Test (Not Yet Defined)
_To be defined after Phase 6 is validated_

### Phase 8: Deploy (Not Yet Defined)
_To be defined after Phase 7 is validated_

---

## Notes

- This workflow is being developed iteratively
- Each phase will be tested and validated before moving to the next
- Automation tools will be created for each phase as needed
