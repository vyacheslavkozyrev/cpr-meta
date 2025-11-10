---
phase: 5_implement
purpose: Execute implementation by processing tasks, creating code files, and tracking progress
applies_to: code implementation in cpr-api and cpr-ui
related_documents:
  - ../workflow.md
  - phase-4-analyze.md
  - ../../constitution.md
---

# Phase 5: Implement Feature - GitHub Copilot Prompt

## User Input

```text
$ARGUMENTS
```

You **MUST** consider user input before proceeding (if not empty).

## Context

You are helping to implement a feature for the CPR (Career Progress Registry) project. This is **Phase 5: Implement**, where we execute the implementation plan by creating code files, following the task breakdown, and maintaining constitutional compliance throughout development.

**Prerequisites**:
- Phase 1-4 completed: Specification approved with quality score ≥ 90
- `tasks.md` contains complete task breakdown (63+ tasks typical)
- `implementation-plan.md` defines technical approach
- `analysis-report.md` confirms no blocking issues
- Feature branches created in cpr-api and cpr-ui repositories

**Your Mission**: Execute implementation tasks systematically, following TDD principles, respecting dependencies, and maintaining type safety across all layers.

---

## IMPORTANT: Operating Constraints

**CONSTITUTIONAL COMPLIANCE**: Every code change must align with the 11 CPR Constitutional Principles. Non-negotiable.

**TASK-DRIVEN DEVELOPMENT**: Only implement what's specified in tasks.md. No scope creep, no "while I'm here" changes.

**TDD APPROACH**: Write tests before implementation code where specified. Red → Green → Refactor.

**TYPE SAFETY EVERYWHERE**: Strong typing in C#, no `any` in TypeScript, validation at all boundaries.

**INCREMENTAL PROGRESS**: Check off tasks in tasks.md as completed. Track progress in progress.md.

---

## Implementation Workflow

### Step 1: Load Implementation Context

**Read Required Files**:
1. `tasks.md` - Complete task list with dependencies and parallel markers
2. `implementation-plan.md` - Tech stack, architecture patterns, integration points
3. `description.md` - Feature requirements, DTOs, API contracts
4. `endpoints.md` - API specifications
5. `analysis-report.md` - Quality findings and recommendations

**Read Optional Files** (if present):
- `data-model.md` - Database schema
- `research.md` - Technical decisions
- `progress.md` - Current phase status

**Understand**:
- Total task count and phase breakdown
- Critical path and dependencies
- Parallel execution opportunities (tasks marked [P])
- File paths for each task
- Technology stack for each repository (cpr-api vs cpr-ui)

---

### Step 2: Verify Prerequisites

**Check Repository State**:

For **cpr-api**:
- [ ] Feature branch exists: `feature/####-<feature-name>`
- [ ] .NET 8 SDK available
- [ ] PostgreSQL 16 connection string in appsettings.Development.json
- [ ] CPR.sln compiles successfully
- [ ] Existing tests pass

For **cpr-ui**:
- [ ] Feature branch exists: `feature/####-<feature-name>`
- [ ] Node.js 20+ installed
- [ ] Dependencies installed (`npm install`)
- [ ] Vite dev server starts
- [ ] Existing tests pass (`npm test`)

**If Prerequisites Fail**:
- Report specific missing prerequisite
- Suggest fix command
- Stop until resolved

---

### Step 3: Parse Task Structure

**Extract from tasks.md**:

```markdown
## Phase X: [Phase Name]

- [ ] T001 [P] [US1] Description with file path
- [ ] T002 [US1] Description with file path (depends on T001)
- [ ] T003 [P] [US2] Description with file path
```

**Parse**:
- **Task ID**: T001, T002, etc.
- **Parallel Marker**: [P] = can run concurrently with other [P] tasks
- **User Story**: [US1] = related user story (if applicable)
- **Description**: What to implement
- **File Path**: Exact location (absolute path)
- **Dependencies**: Implicit from order, explicit from task notes

**Build Execution Plan**:
1. Group tasks by phase
2. Identify critical path (sequential tasks)
3. Identify parallel opportunities ([P] tasks)
4. Determine execution order within each phase

---

### Step 4: Execute Phase 1 (Setup & Project Structure)

**Typical Phase 1 Tasks** (adapt to actual tasks.md):

**Backend (cpr-api)**:
- T001: Create database migration
- T002: Create domain entity
- T003: [P] Create repository interface
- T004: [P] Create service interface
- T005: [P] Create DTOs

**Frontend (cpr-ui)**:
- T006: [P] Create TypeScript types
- T007: [P] Create TypeScript DTOs
- T008: [P] Create component folder structure

**Execution Rules**:
- Sequential tasks: Run in order (T001 → T002)
- Parallel tasks: Can implement simultaneously (T003, T004, T005)
- Respect file paths from tasks.md
- Follow naming conventions (Constitutional Principle 9)

**Example Task Execution**:

```
Task: T002 - Create domain entity `Goal.cs` in `src/CPR.Domain/Entities/`

1. Read description.md for Goal entity specification
2. Create file: src/CPR.Domain/Entities/Goal.cs
3. Implement entity with:
   - UUID primary key (Guid Id)
   - Required properties (UserId, Description, SkillId, TargetDate)
   - Soft delete pattern (IsDeleted, DeletedAt, DeletedBy)
   - Audit fields (CreatedAt, UpdatedAt)
   - Navigation properties (User, Skill, DeletedByUser)
4. Add XML documentation comments
5. Mark task complete: Change `- [ ] T002` to `- [x] T002` in tasks.md
```

**After Phase 1**:
- [ ] All Phase 1 tasks marked complete in tasks.md
- [ ] All created files compile/parse successfully
- [ ] Git commit: "feat(0001): Phase 1 - Setup complete"
- [ ] Update progress.md Phase 5 status

---

### Step 5: Execute Phase 2 (Foundational Implementation)

**Typical Phase 2 Tasks**:
- Repository implementations
- Service layer implementations
- Base component implementations
- Validation rules
- Authorization policies

**TDD Approach** (if test tasks present):
1. Read test task specification
2. Create test file with test cases
3. Run tests (expect failures - RED)
4. Implement minimum code to pass (GREEN)
5. Refactor for quality (REFACTOR)
6. Mark both test and implementation tasks complete

**Constitutional Compliance Checks**:
- ✅ **Principle 2**: DTOs use snake_case JSON via [JsonPropertyName]
- ✅ **Principle 4**: Strong typing, no `any`, validation attributes
- ✅ **Principle 9**: Naming conventions followed
- ✅ **Principle 11**: Database access uses proper ORM patterns

**After Phase 2**:
- [ ] All Phase 2 tasks marked complete
- [ ] Unit tests written and passing
- [ ] Code compiles with no warnings
- [ ] Git commit: "feat(0001): Phase 2 - Foundational implementation"
- [ ] Update progress.md

---

### Step 6: Execute User Story Tasks (Phase 3+)

**For Each User Story** (US-001, US-002, etc.):

**Backend Tasks**:
1. Controller/endpoint implementation
2. Request/response DTO mapping
3. Authorization checks
4. Validation logic
5. Error handling
6. Integration tests

**Frontend Tasks**:
1. React Query hooks (data fetching)
2. Form components (if applicable)
3. Display components
4. State management (Zustand)
5. Offline sync logic (IndexedDB)
6. Component tests

**Execution Order**:
1. Backend API endpoint (provides contract)
2. Frontend API client/hook (consumes contract)
3. Frontend UI components (uses hook)
4. Tests for both layers

**Parallel Opportunities**:
- Different user stories can be implemented concurrently
- Backend and frontend can work in parallel after API contract defined
- Independent components can be built simultaneously

**After Each User Story**:
- [ ] All US tasks marked complete
- [ ] Acceptance criteria validated (refer to description.md)
- [ ] Manual testing performed
- [ ] Git commit: "feat(0001): Implement US-00X - [story name]"

---

### Step 7: Execute Phase 4+ (Polish & Validation)

**Polish Tasks**:
- Error handling refinements
- Loading states and spinners
- Empty states and error messages
- Accessibility improvements (ARIA labels)
- Internationalization (i18n keys)
- Performance optimization
- Code documentation

**Validation Tasks**:
- E2E tests
- Performance tests
- Security tests
- Accessibility audits
- Code review checklist

**Final Checks**:
- [ ] All tasks in tasks.md marked complete
- [ ] All tests passing (unit, integration, E2E)
- [ ] No console errors or warnings
- [ ] Build succeeds in both repositories
- [ ] Feature works end-to-end locally
- [ ] Constitutional compliance verified

---

## Progress Tracking

### Update tasks.md After Each Task

**Before**:
```markdown
- [ ] T042 [US3] Implement GoalForm component in src/components/Goals/GoalForm.tsx
```

**After**:
```markdown
- [x] T042 [US3] Implement GoalForm component in src/components/Goals/GoalForm.tsx
```

### Update progress.md Regularly

After each phase or significant milestone:

```markdown
## Phase 5: Implement

**Status**: 🟡 In Progress
**Started**: 2025-11-07
**Completed**: -

### Progress
- [x] Phase 1: Setup (8/8 tasks)
- [x] Phase 2: Foundational (15/15 tasks)
- [x] User Story 1 (12/12 tasks)
- [x] User Story 2 (10/10 tasks)
- [ ] User Story 3 (0/8 tasks) ← Currently working
- [ ] User Story 4 (0/6 tasks)
- [ ] User Story 5 (0/4 tasks)
- [ ] Polish (0/5 tasks)

**Tasks Completed**: 45/63 (71%)
**Estimated Completion**: 2025-11-12
```

---

## Git Workflow

### Commit Strategy

**Commit After Each Phase**:
```bash
git add .
git commit -m "feat(0001): Phase 1 - Setup complete

- Created Goal entity with soft delete pattern
- Added repository and service interfaces
- Defined DTOs with proper JSON naming
- Created TypeScript types matching C# DTOs

Tasks: T001-T008 complete"
```

**Commit Message Format**:
```
<type>(<scope>): <subject>

<body>

Tasks: T001-T008 complete
```

**Types**: feat, fix, test, refactor, docs, chore  
**Scope**: Feature number (e.g., 0001)

### Push Regularly

```bash
git push origin feature/0001-personal-goal-creation-management
```

Push after each phase completion to backup work and enable team review.

---

## Error Handling

### Compilation Errors

**If code doesn't compile**:
1. Read error message carefully
2. Check type mismatches (common with DTOs)
3. Verify imports/using statements
4. Check naming conventions (PascalCase vs camelCase vs snake_case)
5. Review constitutional principles
6. Fix and recompile
7. Do NOT mark task complete until compilation succeeds

### Test Failures

**If tests fail**:
1. Read test failure message
2. Identify which acceptance criterion failed
3. Review implementation against specification
4. Fix implementation (not test, unless test is wrong)
5. Re-run tests
6. Do NOT mark task complete until tests pass

### Dependency Issues

**If task blocked by dependency**:
1. Check if prerequisite task is complete
2. If not, complete prerequisite first
3. If prerequisite fails, stop and report
4. Do NOT skip dependencies

---

## Quality Gates

### Before Marking Phase Complete

- [ ] All phase tasks marked [x] in tasks.md
- [ ] Code compiles with no errors
- [ ] All tests pass (unit + integration)
- [ ] No linting errors
- [ ] Constitutional compliance maintained
- [ ] Git committed and pushed

### Before Marking Feature Complete

- [ ] All 63 tasks (or total count) marked [x]
- [ ] All acceptance criteria validated
- [ ] E2E tests pass
- [ ] Performance targets met (<200ms API, <1s UI)
- [ ] Security audit passed
- [ ] Code reviewed (self-review at minimum)
- [ ] Documentation complete
- [ ] Ready for Phase 6 (Code Review)

---

## Constitutional Compliance During Implementation

### Principle 1: Specification-First ✅
- Follow tasks.md exactly
- Reference description.md for requirements
- Do not implement features not in spec

### Principle 2: API Contract Consistency ✅
- C# DTOs match TypeScript interfaces
- JSON uses snake_case (UserId → user_id)
- Use [JsonPropertyName] attributes in C#

### Principle 3: API Standards & Security ✅
- RESTful endpoints as specified
- JWT authentication required
- Authorization checks in controllers
- Rate limiting configured

### Principle 4: Type Safety ✅
- C#: Use validation attributes, no nullable warnings
- TypeScript: Strict mode, no `any`, proper typing

### Principle 5: Offline Mode ✅
- IndexedDB caching implemented
- React Query persistent cache configured
- Sync conflict resolution as specified

### Principle 6: Internationalization ✅
- All UI text uses i18n keys
- Date/number formatting locale-aware
- Translation files updated

### Principle 7: Comprehensive Testing ✅
- Unit tests for services and utilities
- Integration tests for API endpoints
- Component tests for React components
- E2E tests for critical paths

### Principle 8: Performance-First React ✅
- React Query for data fetching
- Optimistic updates
- Proper memoization (useMemo, useCallback)
- Virtual scrolling if needed

### Principle 9: Strict Naming Conventions ✅
- JSON: snake_case
- C# Properties: PascalCase
- TypeScript: camelCase
- Database: snake_case
- URLs: kebab-case

### Principle 10: Security & Privacy ✅
- Input sanitization
- XSS prevention
- Authorization at all boundaries
- Audit trail maintained

### Principle 11: Database Design ✅
- UUID primary keys
- Proper foreign keys
- Indexes for performance
- Soft delete pattern

---

## Completion Criteria

### Phase 5 Complete When:

1. ✅ All tasks in tasks.md marked [x]
2. ✅ All code files created at specified paths
3. ✅ Backend compiles successfully
4. ✅ Frontend builds successfully
5. ✅ All tests pass (unit, integration, E2E)
6. ✅ Feature works end-to-end locally
7. ✅ Git history clean with descriptive commits
8. ✅ progress.md updated to Phase 5 complete
9. ✅ Ready for Phase 6 (Code Review)

### Output Deliverables:

- ✅ Complete implementation in cpr-api feature branch
- ✅ Complete implementation in cpr-ui feature branch
- ✅ Updated tasks.md (all tasks marked [x])
- ✅ Updated progress.md (Phase 5 status complete)
- ✅ Test coverage report (optional but recommended)
- ✅ Implementation notes (any deviations or decisions documented)

---

## Next Actions After Phase 5

**If Implementation Successful**:
1. Mark Phase 5 complete in progress.md
2. Create pull request in cpr-api
3. Create pull request in cpr-ui
4. Proceed to Phase 6: Code Review
5. Schedule team review meeting

**If Issues Encountered**:
1. Document blockers in progress.md
2. Create GitHub issues for unresolved problems
3. Update analysis-report.md if new findings
4. Seek technical lead guidance
5. Do NOT mark Phase 5 complete

---

## Example: Implementing Task T042

**Task**: `- [ ] T042 [US3] Implement GoalForm component in src/components/Goals/GoalForm.tsx`

**Steps**:

1. **Read Context**:
   - Check description.md for GoalForm requirements (fields, validation, behavior)
   - Check implementation-plan.md for React patterns (react-hook-form, zod)
   - Check endpoints.md for POST /api/v1/goals request schema

2. **Create File**: `cpr-ui/src/components/Goals/GoalForm.tsx`

3. **Implement Component**:
```typescript
import { useForm } from 'react-hook-form';
import { zodResolver } from '@hookform/resolvers/zod';
import { z } from 'zod';
import { CreateGoalDto } from '../../dtos/goal';
import { useCreateGoal } from '../../hooks/useGoals';

const goalSchema = z.object({
  description: z.string().min(10).max(500),
  target_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  skill_id: z.string().uuid(),
});

export const GoalForm: React.FC = () => {
  const { register, handleSubmit, formState: { errors } } = useForm<CreateGoalDto>({
    resolver: zodResolver(goalSchema),
  });
  
  const createGoal = useCreateGoal();

  const onSubmit = (data: CreateGoalDto) => {
    createGoal.mutate(data);
  };

  // ... rest of component
};
```

4. **Verify**:
   - Component compiles
   - Types match CreateGoalDto
   - Form validation works
   - Follows Constitutional Principles

5. **Mark Complete**: Update tasks.md: `- [x] T042 ...`

6. **Commit**: `git commit -m "feat(0001): Implement GoalForm component (T042)"`

---

## Tips for Efficient Implementation

1. **Batch Similar Tasks**: Implement all DTOs together, all repositories together, etc.
2. **Use Copilot Autocomplete**: Let AI suggest boilerplate code
3. **Copy-Paste-Modify**: Reuse patterns from existing features
4. **Test Frequently**: Don't wait until end to run tests
5. **Commit Often**: Small commits easier to review and revert
6. **Read Specs Carefully**: Avoid rework by following requirements exactly
7. **Ask Questions**: If specification unclear, clarify before implementing

---

*End of Phase 5 Prompt*
