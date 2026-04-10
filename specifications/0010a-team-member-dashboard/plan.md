# Implementation Plan — Team Member Dashboard (0010a)

## Tasks

- [ ] T001 [Migration] Create migration to extend goals.status CHECK constraint — add 'SUGGESTED' to allowed values — `source/cpr-api/src/CPR.Infrastructure/Migrations/20260409000000_AddGoalSuggestedStatus.cs`
- [ ] T002 [Domain] Add nullable `SuggestedById` property to Goal entity — `source/cpr-api/src/CPR.Domain/Entities/Goal.cs`
- [ ] T003 [Domain] Create GoalDeletionRequest entity — map to existing DB table columns: goal_id, requested_by_id, reason, status, reviewed_by_id, reviewed_at, created_at — `source/cpr-api/src/CPR.Domain/Entities/GoalDeletionRequest.cs`
- [ ] T004 [Infra] Update CprDbContext — add GoalDeletionRequests DbSet, configure GoalDeletionRequest entity mapping, add SuggestedById column mapping to Goal configuration — `source/cpr-api/src/CPR.Infrastructure/Data/CprDbContext.cs`
- [ ] T005 [Infra] Create GoalDeletionRequestRepository — GetPendingByGoalIdAsync, AddAsync, UpdateStatusAsync, DeleteAsync — `source/cpr-api/src/CPR.Infrastructure/Repositories/GoalDeletionRequestRepository.cs`
- [ ] T006 [Infra] Update GoalsRepository — add GetEmployeeGoalsForManagerAsync (includes tasks, pending deletion-request flag, suggested_by join) — `source/cpr-api/src/CPR.Infrastructure/Repositories/GoalsRepository.cs`
- [ ] T007 [App] Add IGoalDeletionRequestRepository interface — `source/cpr-api/src/CPR.Application/Repositories/IGoalDeletionRequestRepository.cs`
- [ ] T008 [App] Update IGoalsRepository — add GetEmployeeGoalsForManagerAsync signature — `source/cpr-api/src/CPR.Application/Repositories/IGoalsRepository.cs`
- [ ] T009 [App] Update GoalDto — add suggested_by_id, suggested_by_name, has_pending_deletion_request, tasks[] (each with id, name, is_completed) — `source/cpr-api/src/CPR.Application/Contracts/GoalDto.cs`
- [ ] T010 [App] Add SuggestGoalDto request DTO (name, description, skill_category_id, timeframe, due_date) — `source/cpr-api/src/CPR.Application/Contracts/SuggestGoalDto.cs`
- [ ] T011 [App] Add GoalSuggestionActionDto (action: accept | reject) — `source/cpr-api/src/CPR.Application/Contracts/GoalSuggestionActionDto.cs`
- [ ] T012 [App] Add GoalDeletionRequestDto response DTO (id, goal_id, status, created_at) — `source/cpr-api/src/CPR.Application/Contracts/GoalDeletionRequestDto.cs`
- [ ] T013 [App] Add GoalDeletionActionDto (action: approve | reject) — `source/cpr-api/src/CPR.Application/Contracts/GoalDeletionActionDto.cs`
- [ ] T014 [App] Add TeamMemberDto response DTO (id, full_name, job_title, position_id, position_name) — `source/cpr-api/src/CPR.Application/Contracts/TeamMemberDto.cs`
- [ ] T015 [App] Add SuggestGoalDtoValidator (name 1–200, description ≤2000, timeframe enum, due_date ≥ today) — `source/cpr-api/src/CPR.Application/Validators/SuggestGoalDtoValidator.cs`
- [ ] T016 [App] Add GoalSuggestionActionDtoValidator (action must be accept or reject) — `source/cpr-api/src/CPR.Application/Validators/GoalSuggestionActionDtoValidator.cs`
- [ ] T017 [App] Add GoalDeletionActionDtoValidator (action must be approve or reject) — `source/cpr-api/src/CPR.Application/Validators/GoalDeletionActionDtoValidator.cs`
- [ ] T018 [App] Update IGoalService — add SuggestGoalAsync, AcceptSuggestionAsync, RejectSuggestionAsync, MarkCompletedByManagerAsync, GetEmployeeGoalsForManagerAsync, DeleteGoalByManagerAsync — `source/cpr-api/src/CPR.Application/Services/IGoalService.cs`
- [ ] T019 [App] Add IGoalDeletionRequestService interface — RequestDeletionAsync, CancelDeletionRequestAsync, ApproveDeletionAsync, RejectDeletionAsync — `source/cpr-api/src/CPR.Application/Services/IGoalDeletionRequestService.cs`
- [ ] T020 [App] Add ITeamService interface — GetDirectReportsAsync(managerEmployeeId) — `source/cpr-api/src/CPR.Application/Services/ITeamService.cs`
- [ ] T021 [App] Update IFeedbackService — add GetEmployeeFeedbackForManagerAsync(employeeId, managerEmployeeId) — `source/cpr-api/src/CPR.Application/Services/IFeedbackService.cs`
- [ ] T022 [Infra] Update GoalService — implement SuggestGoalAsync (status=SUGGESTED, suggested_by_id set), AcceptSuggestionAsync, RejectSuggestionAsync (soft-delete), MarkCompletedByManagerAsync (status=COMPLETED), GetEmployeeGoalsForManagerAsync (direct-report auth check), extend DeleteGoalAsync for manager access and pending-deletion-request resolution — `source/cpr-api/src/CPR.Infrastructure/Services/GoalService.cs`
- [ ] T023 [Infra] Create GoalDeletionRequestService — enforce direct-report ownership, one-pending-request constraint, status transitions (PENDING→APPROVED soft-deletes goal, PENDING→REJECTED restores) — `source/cpr-api/src/CPR.Infrastructure/Services/GoalDeletionRequestService.cs`
- [ ] T024 [Infra] Create TeamService — GetDirectReportsAsync queries employees WHERE manager_id = currentEmployee.Id, joins users and positions for display fields — `source/cpr-api/src/CPR.Infrastructure/Services/TeamService.cs`
- [ ] T025 [Infra] Update FeedbackService — implement GetEmployeeFeedbackForManagerAsync with direct-report authorization check; map content→comment, from_employee_id→submitted_by_id at DTO layer — `source/cpr-api/src/CPR.Infrastructure/Services/FeedbackService.cs`
- [ ] T026 [Infra] Register GoalDeletionRequestRepository, IGoalDeletionRequestService/GoalDeletionRequestService, ITeamService/TeamService in DI container — `source/cpr-api/src/CPR.Api/InfrastructureRegistrar.cs`
- [ ] T027 [API] Create TeamController — GET /api/me/team (PeopleManager, Director); verify route does not shadow GET /api/me/team/skill-assessment-summary (F007) — `source/cpr-api/src/CPR.Api/Controllers/TeamController.cs`
- [ ] T028 [API] Update EmployeesController — add GET /api/employees/{id}/goals (PeopleManager/Director for reports, Employee for own), POST /api/employees/{id}/goals (PeopleManager/Director), GET /api/employees/{id}/feedback (PeopleManager/Director) — `source/cpr-api/src/CPR.Api/Controllers/EmployeesController.cs`
- [ ] T029 [API] Update GoalsController — add PATCH /goals/{id}/suggestion (Employee, goal owner only), POST /goals/{id}/deletion-request (Employee), DELETE /goals/{id}/deletion-request (Employee), PATCH /goals/{id}/deletion-request (PeopleManager/Director); extend PATCH /{id} and DELETE /{id} handlers for manager access to direct-report goals — `source/cpr-api/src/CPR.Api/Controllers/GoalsController.cs`
- [ ] T030 [UI] Add team DTO types — ITeamMemberDto (id, full_name, job_title, position_id, position_name) — `source/cpr-ui/src/dtos/TeamMemberDto.ts`
- [ ] T031 [UI] Update GoalDto — add suggested_by_id, suggested_by_name, has_pending_deletion_request, tasks: IGoalTaskDto[] — `source/cpr-ui/src/dtos/GoalDto.ts`
- [ ] T032 [UI] Add Team model types — ITeamMember (camelCase) — `source/cpr-ui/src/models/TeamMember.ts`
- [ ] T033 [UI] Update Goal model — add suggestedById, suggestedByName, hasPendingDeletionRequest, tasks: IGoalTask[] — `source/cpr-ui/src/models/Goal.ts`
- [ ] T034 [UI] Add teamMemberMapper — mapTeamMember(dto) and mapTeamMemberGoal(dto) pure functions — `source/cpr-ui/src/mappers/teamMemberMapper.ts`
- [ ] T035 [UI] Create teamService — getMyTeam, getEmployeeGoals, suggestGoal, getEmployeeFeedback HTTP calls — `source/cpr-ui/src/services/teamService.ts`
- [ ] T036 [UI] Update goalsService — add acceptSuggestion, rejectSuggestion, requestDeletion, cancelDeletionRequest, approveDeletion, rejectDeletion — `source/cpr-ui/src/services/goalsService.ts`
- [ ] T037 [UI] Create teamQueryService — useMyTeam, useEmployeeGoals, useSuggestGoal, useEmployeeFeedback React Query hooks with appropriate staleTime/invalidation — `source/cpr-ui/src/services/teamQueryService.ts`
- [ ] T038 [UI] Update goalsQueryService — add useGoalSuggestionAction, useGoalDeletionRequest, useCancelGoalDeletionRequest, useGoalDeletionAction mutations; invalidate goal queries on success — `source/cpr-ui/src/services/goalsQueryService.ts`
- [ ] T039 [UI] Create MSW handlers for team endpoints (GET /api/me/team, GET /api/employees/:id/goals, POST /api/employees/:id/goals, GET /api/employees/:id/feedback) — `source/cpr-ui/src/mocks/handlers/teamHandlers.ts`
- [ ] T040 [UI] Update MSW handlers for goal suggestion and deletion-request endpoints — `source/cpr-ui/src/mocks/handlers/goalsHandlers.ts`
- [ ] T041 [UI] Create TeamMemberCard component (avatar, full name, job title, clickable → dashboard) — `source/cpr-ui/src/pages/team/components/TeamMemberCard.tsx`
- [ ] T042 [UI] Create GoalsSectionManager component — goal cards with manager actions (Mark as Completed, Delete, Approve/Reject Deletion, Suggest Goal button, expandable task list) — `source/cpr-ui/src/pages/team/components/GoalsSectionManager.tsx`
- [ ] T043 [UI] Create SuggestGoalModal component — form with name, description, skill category select, timeframe select, due date picker; React Hook Form + Zod validation — `source/cpr-ui/src/pages/team/components/SuggestGoalModal.tsx`
- [ ] T044 [UI] Create FeedbackSectionManager component — list of received feedback entries (rating stars, comment, submitter name, date) sorted newest-first — `source/cpr-ui/src/pages/team/components/FeedbackSectionManager.tsx`
- [ ] T045 [UI] Create SkillsSectionManager component — skill table (self-assessment | manager-assessment) plus gap analysis panel; reuses useEmployeeSkillAssessment and useEmployeeGapAnalysis hooks — `source/cpr-ui/src/pages/team/components/SkillsSectionManager.tsx`
- [ ] T046 [UI] Create ProjectsSectionManager component — project assignment cards (Current/Past badge, project name, role, date range) — `source/cpr-ui/src/pages/team/components/ProjectsSectionManager.tsx`
- [ ] T047 [UI] Update GoalCard — add Suggested badge + Accept/Reject buttons (employee view), Deletion Requested badge + Approve/Reject Deletion buttons (manager view), Request Deletion / Cancel Request actions (employee view) — `source/cpr-ui/src/pages/goals/components/GoalCard.tsx`
- [ ] T048 [UI] Create TeamListPage — fetch direct reports, render TeamMemberCard list, empty state — `source/cpr-ui/src/pages/team/TeamListPage.tsx`
- [ ] T049 [UI] Create TeamMemberDashboardPage — header with member info, four collapsible sections composing GoalsSectionManager, FeedbackSectionManager, SkillsSectionManager, ProjectsSectionManager — `source/cpr-ui/src/pages/team/TeamMemberDashboardPage.tsx`
- [ ] T050 [UI] Add team dashboard i18n keys to English translation file (team_list.*, team_dashboard.*, goal_actions.*, feedback_section.*, skills_section.*, projects_section.*) — `source/cpr-ui/public/locales/en/translation.json`
- [ ] T051 [UI] Register /team and /team/:employeeId routes under RoleGuard (EUserRole.PEOPLE_MANAGER, EUserRole.DIRECTOR) — `source/cpr-ui/src/routes/index.tsx`
- [ ] T052 [Test] Unit tests for GoalService — SuggestGoalAsync, AcceptSuggestionAsync, RejectSuggestionAsync, MarkCompletedByManagerAsync, DeleteGoalByManagerAsync — `source/cpr-api/tests/CPR.UnitTests/Services/GoalServiceTests.cs`
- [ ] T053 [Test] Unit tests for GoalDeletionRequestService — RequestDeletionAsync, CancelDeletionRequestAsync, ApproveDeletionAsync, RejectDeletionAsync — `source/cpr-api/tests/CPR.UnitTests/Services/GoalDeletionRequestServiceTests.cs`
- [ ] T054 [Test] Unit tests for TeamService — GetDirectReportsAsync (manager gets own reports, wrong manager returns empty) — `source/cpr-api/tests/CPR.UnitTests/Services/TeamServiceTests.cs`
- [ ] T055 [Test] Integration tests for TeamController and new EmployeesController endpoints — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/TeamControllerTests.cs`
- [ ] T056 [Test] Integration tests for GoalsController new endpoints (suggestion and deletion-request) — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/GoalsControllerTests.cs`
- [ ] T057 [Test] Component tests for TeamListPage (renders reports, empty state, navigation) — `source/cpr-ui/src/pages/team/TeamListPage.test.tsx`
- [ ] T058 [Test] Component tests for TeamMemberDashboardPage (section rendering, 403 redirect, loading states) — `source/cpr-ui/src/pages/team/TeamMemberDashboardPage.test.tsx`
- [ ] T059 [Test] Component tests for GoalCard — suggested/deletion-pending states and action button visibility per role — `source/cpr-ui/src/pages/goals/components/GoalCard.test.tsx`

---

## Rationale

**Migration is minimal.** The DB inspector revealed that `goals.suggested_by_id` (FK → users) already exists on the table and `goal_deletion_requests` already exists as a fully-populated table. The only required schema change is extending the `goals.status` CHECK constraint to permit `'SUGGESTED'` (T001).

**GoalDeletionRequest entity maps to an existing divergent schema.** The live `goal_deletion_requests` table uses `reason`, `reviewed_by_id`, and `reviewed_at` instead of the `resolved_by_id`/`resolved_at`/full-audit-columns described in `schema.md`. The entity in T003 maps to the actual DB columns, not the spec's idealized form; `schema.md` should be amended as a follow-up. Because the table has no `is_deleted` column, deletion request cancellation (T023) uses a hard DELETE on the row.

**DTO field names differ from column names throughout.** Three mappings that must be applied at the service/DTO layer: `goals.title` → `name`, `feedback.content` → `comment`, `feedback.from_employee_id` → `submitted_by_id`. All are documented in `api.md` and must be implemented in service mapping logic (T022, T025), not as column renames.

**F009 and F011 endpoints are reused unchanged.** `GET /api/employees/{id}/gap-analysis` and `GET /api/employees/{id}/project-assignments` are already implemented; SkillsSectionManager (T045) and ProjectsSectionManager (T046) call them directly. These features are deployment prerequisites — if either is not yet deployed, those sections will degrade gracefully with an error state.

**Route ordering must be verified at T027.** ASP.NET Core resolves more-specific routes correctly, but `GET /api/me/team` must be registered in TeamController without a wildcard suffix that could absorb `/api/me/team/skill-assessment-summary` (F007). Confirm both routes resolve independently before marking T027 complete.
