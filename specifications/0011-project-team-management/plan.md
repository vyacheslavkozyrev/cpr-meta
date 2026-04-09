# Plan — Project Team Management (0011)

## Tasks

### [Migration]

- [ ] T001 [Migration] Create EF Core migration `AddProjectLifecycleAndAssignmentDates` — adds `status`/`start_date`/`end_date` to `projects`; adds `start_date`/`end_date` to `project_teams`; drops `UX_project_teams_role_employee`; adds `CK_projects_status`, `CK_projects_date_range`, `CK_project_teams_date_range` constraints and `IX_projects_status` partial index — `source/cpr-api/src/CPR.Infrastructure/Migrations/20260407000001_AddProjectLifecycleAndAssignmentDates.cs`

### [Domain]

- [ ] T002 [Domain] Add `Status`, `StartDate`, `EndDate` properties to `Project` entity — `source/cpr-api/src/CPR.Domain/Entities/Project.cs`
- [ ] T003 [Domain] Add `StartDate`, `EndDate` properties to `ProjectTeam` entity — `source/cpr-api/src/CPR.Domain/Entities/ProjectTeam.cs`

### [Infra]

- [ ] T004 [Infra] Configure new `Project` and `ProjectTeam` columns, `CHECK` constraints, and `IX_projects_status` index in `CprDbContext.OnModelCreating` — `source/cpr-api/src/CPR.Infrastructure/Data/CprDbContext.cs`
- [ ] T005 [Infra] Add `UpdateTeamMemberAsync` and `HasOverlappingAssignmentAsync` methods to `IProjectRepository` — `source/cpr-api/src/CPR.Application/Repositories/IProjectRepository.cs`
- [ ] T006 [Infra] Implement `UpdateTeamMemberAsync` and `HasOverlappingAssignmentAsync` in `ProjectRepository` — `source/cpr-api/src/CPR.Infrastructure/Repositories/ProjectRepository.cs`

### [App]

- [ ] T007 [App] Update `ProjectDto` (add `Status`, `StartDate`, `EndDate`; remove navigation `Roles`/`Team`); add `ProjectListItemDto` (list-view shape) and `PagedResultDto<T>` — `source/cpr-api/src/CPR.Application/Contracts/ProjectDto.cs`
- [ ] T008 [App] Update `ProjectRoleDto` to add `MemberCount` field — `source/cpr-api/src/CPR.Application/Contracts/ProjectRoleDto.cs`
- [ ] T009 [App] Update `ProjectTeamDto` (add `StartDate`, `EndDate`, `IsCurrent`, `DisplayName`); add `ProjectTeamGroupDto` (assignments grouped by role) and `ProjectAssignmentDto` (for `/me` and `/employees/{id}` endpoints) — `source/cpr-api/src/CPR.Application/Contracts/ProjectTeamDto.cs`
- [ ] T010 [App] Update `CreateProjectDto` (add `Status`, `StartDate`, `EndDate`; remove `OwnerId`/`SponsorId` — owner auto-set from auth user per AC-006) — `source/cpr-api/src/CPR.Application/Contracts/CreateProjectDto.cs`
- [ ] T011 [App] Update `UpdateProjectDto` to PATCH semantics (all fields nullable; `Code` field triggers 400 per AC-015) — `source/cpr-api/src/CPR.Application/Contracts/UpdateProjectDto.cs`
- [ ] T012 [App] Update `CreateProjectRoleDto` (add validation attributes for title length 1–100, description max 500); update `UpdateProjectRoleDto` to nullable PATCH semantics — `source/cpr-api/src/CPR.Application/Contracts/CreateProjectRoleDto.cs`
- [ ] T013 [App] Update `UpdateProjectRoleDto` to nullable PATCH semantics (nullable `Title` and `Description`) — `source/cpr-api/src/CPR.Application/Contracts/UpdateProjectRoleDto.cs`
- [ ] T014 [App] Update `CreateProjectTeamDto` to add `StartDate`/`EndDate`; add `PatchProjectTeamDto` (nullable date fields for PATCH assignment) — `source/cpr-api/src/CPR.Application/Contracts/CreateProjectTeamDto.cs`
- [ ] T015 [App] Add `ProjectListQueryDto` (page, per_page, sort_by, sort_dir, status filter) — `source/cpr-api/src/CPR.Application/Contracts/ProjectListQueryDto.cs`
- [ ] T016 [App] Update `IProjectService` with complete method signatures (paginated list, ownership-scoped PATCH/DELETE, grouped team with as_of, member PATCH, `/me` and `/employees/{id}` assignment queries) — `source/cpr-api/src/CPR.Application/Services/IProjectService.cs`
- [ ] T017 [App] Add `ProjectValidators.cs` with FluentValidation validators for `CreateProjectDto`, `UpdateProjectDto`, `CreateProjectRoleDto`, `CreateProjectTeamDto`, and `PatchProjectTeamDto` — `source/cpr-api/src/CPR.Application/Validators/ProjectValidators.cs`
- [ ] T018 [App] Rewrite `ProjectService` with full spec implementation — ownership RBAC (SolutionOwner own projects only; Director/Administrator any), overlap detection via `IProjectRepository`, `is_current` computation, paginated/sorted list, grouped team view, 409 error exceptions for code conflict / active-member delete / date overlap — `source/cpr-api/src/CPR.Infrastructure/Services/ProjectService.cs`

### [API]

- [ ] T019 [API] Rewrite `ProjectsController` — PATCH verbs, role-scoped member routes (`/roles/{roleId}/members`), remove `[RequireRole]` attribute from write actions (RBAC enforced in service), 409 `ProblemDetails` for code conflict / active members / overlap, `[FromQuery] ProjectListQueryDto` binding, `as_of` query param on team endpoint — `source/cpr-api/src/CPR.Api/Controllers/ProjectsController.cs`
- [ ] T020 [API] Add `GET /api/me/project-assignments` endpoint (accessible to all authenticated roles; returns `ProjectAssignmentDto[]`) to `MeController` — `source/cpr-api/src/CPR.Api/Controllers/MeController.cs`
- [ ] T021 [API] Add `GET /api/employees/{id}/project-assignments` endpoint (Director/Admin/SolutionOwner any employee; PeopleManager direct reports only; Employee 403); add `SolutionOwner` to allowed roles on existing `GET /api/employees/{id}/skill-assessment` (resolves Major conflict AC-033) — `source/cpr-api/src/CPR.Api/Controllers/EmployeesController.cs`

### [UI]

- [ ] T022 [UI] Add TypeScript types for projects (`ProjectStatus` enum, `ProjectListItem`, `Project`, `ProjectRole`, `ProjectTeamEntry`, `ProjectTeamGroup`, `ProjectAssignment`) — `source/cpr-ui/src/types/project.types.ts`
- [ ] T023 [UI] Add project API service (createProject, getProjects, getProject, patchProject, deleteProject, getProjectRoles, createProjectRole, patchProjectRole, deleteProjectRole, getProjectTeam, assignMember, patchMemberDates, removeMember, getMyProjectAssignments, getEmployeeProjectAssignments) — `source/cpr-ui/src/services/projectService.ts`
- [ ] T024 [UI] Add `useProjects`, `useProject`, `useCreateProject`, `usePatchProject`, `useDeleteProject` React Query hooks — `source/cpr-ui/src/hooks/useProjects.ts`
- [ ] T025 [UI] Add `useProjectRoles`, `useCreateProjectRole`, `usePatchProjectRole`, `useDeleteProjectRole` hooks — `source/cpr-ui/src/hooks/useProjectRoles.ts`
- [ ] T026 [UI] Add `useProjectTeam`, `useAssignMember`, `usePatchMemberDates`, `useRemoveMember` hooks — `source/cpr-ui/src/hooks/useProjectTeam.ts`
- [ ] T027 [UI] Add `useMyProjectAssignments` and `useEmployeeProjectAssignments` hooks — `source/cpr-ui/src/hooks/useProjectAssignments.ts`
- [ ] T028 [UI] Add MSW mock handlers for all project endpoints (projects CRUD, roles CRUD, team member CRUD, assignment queries) with mock data fixtures — `source/cpr-ui/src/mocks/handlers/projectHandlers.ts`
- [ ] T029 [UI] Register `projectHandlers` in MSW handler index — `source/cpr-ui/src/mocks/handlers/index.ts`
- [ ] T030 [UI] Add `ProjectListPage` (data table with status badge, status filter, sort by title/created_at, pagination, row actions: View / Edit / Delete with confirmation) — `source/cpr-ui/src/pages/ProjectListPage.tsx`
- [ ] T031 [UI] Add `CreateEditProjectDrawer` (form: code required/read-only on edit, title, description, status enum, start/end dates with end≥start validation; 409 code-conflict error display) — `source/cpr-ui/src/components/projects/CreateEditProjectDrawer.tsx`
- [ ] T032 [UI] Add `ProjectDetailPage` (header: code, title, status badge, owner, dates; tabs: "Roles & Team" and "Team History" with as_of date filter) — `source/cpr-ui/src/pages/ProjectDetailPage.tsx`
- [ ] T033 [UI] Add `ProjectRolesSection` (role cards with title, description, member count, Edit/Delete actions; inline Add Role form; 409 toast when deleting role with active members) — `source/cpr-ui/src/components/projects/ProjectRolesSection.tsx`
- [ ] T034 [UI] Add `AssignMemberDrawer` (employee search, skills panel via `GET /api/employees/{id}/skill-assessment`, optional date range fields, 409 overlap error display; Update Assignment Dates inline form) — `source/cpr-ui/src/components/projects/AssignMemberDrawer.tsx`
- [ ] T035 [UI] Add `MyProjectsPage` (table of own project assignments: project code/title/status badge, role title, dates, "Current" badge; "Current only" toggle filter) — `source/cpr-ui/src/pages/MyProjectsPage.tsx`
- [ ] T036 [UI] Add project i18n keys to English translation (`projects.*`, `project_roles.*`, `project_team.*`, error keys) — `source/cpr-ui/public/locales/en/translation.json`
- [ ] T037 [UI] Add project i18n keys to Belarusian translation (same key set, translated) — `source/cpr-ui/public/locales/be/translation.json`
- [ ] T038 [UI] Add project i18n keys to Spanish translation — `source/cpr-ui/public/locales/es/translation.json`
- [ ] T039 [UI] Add project i18n keys to French translation — `source/cpr-ui/public/locales/fr/translation.json`
- [ ] T040 [UI] Register `ProjectListPage`, `ProjectDetailPage`, and `MyProjectsPage` routes in router — `source/cpr-ui/src/routes/index.tsx`

### [Test]

- [ ] T041 [Test] Add unit tests for `ProjectService` — CreateProject ownership assignment, PatchProject code-immutable 400, PatchProject ownership scoping (SolutionOwner vs Director), overlap detection returning 409, `is_current` computation edge cases, delete cascade-exclusion of roles/team — `source/cpr-api/tests/CPR.UnitTests/Services/ProjectServiceTests.cs`
- [ ] T042 [Test] Add integration tests for `ProjectsController` — happy paths for all 13 endpoints; 403 for Employee/PeopleManager on create/list; 403 SolutionOwner on other owner's project; 409 code conflict; 409 active-member delete; 409 date overlap; 404 not found; pagination response shape — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/ProjectsControllerTests.cs`
- [ ] T043 [Test] Add integration tests for project-assignment endpoints — `GET /api/me/project-assignments` (all roles); `GET /api/employees/{id}/project-assignments` (Director/SolutionOwner any; PeopleManager direct-report only; PeopleManager non-direct-report 403; Employee 403) — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/ProjectAssignmentTests.cs`
- [ ] T044 [Test] Add frontend component tests for `ProjectListPage` (renders list, applies status filter, delete confirmation dialog, empty state) — `source/cpr-ui/src/pages/ProjectListPage.test.tsx`
- [ ] T045 [Test] Add frontend component tests for `MyProjectsPage` (renders assignments, shows Current badge, toggle filter hides non-current) — `source/cpr-ui/src/pages/MyProjectsPage.test.tsx`

---

## Rationale

**Migration must precede domain updates**: T001 runs first because EF Core migrations must be created from the updated entity model — updating the entity (T002–T003) and EF config (T004) enables the migration scaffold, and the resulting migration file must exist before the database can be updated.

**Repository extension before service**: `HasOverlappingAssignmentAsync` (T005–T006) must be defined before `ProjectService` (T018) calls it; the service layer depends on the repository interface.

**DTOs before service and controller**: All response/request contracts (T007–T015) must be finalized before `IProjectService` (T016), validators (T017), `ProjectService` (T018), and controllers (T019–T021) reference them — downstream layers compile against these types.

**EmployeesController change bundles two concerns** (T021): Adding `SolutionOwner` to `skill-assessment` and adding the `project-assignments` endpoint are in the same file; bundling avoids two partial edits to the same controller and resolves the Major Analyze conflict before the UI's `AssignMemberDrawer` (T034) depends on it.

**UI ordering mirrors dependency graph**: Types (T022) → service (T023) → hooks (T024–T027) → MSW handlers (T028–T029) → pages/components (T030–T035) → i18n keys (T036–T039) → route registration (T040). MSW handlers must precede pages because pages render under the mock provider in tests. Route registration (T040) is last because it references page components that must already exist.
