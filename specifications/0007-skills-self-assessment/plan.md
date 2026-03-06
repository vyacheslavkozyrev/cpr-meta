# Implementation Plan — Skills Self-Assessment (0007)

> **Note on existing entities**: `Position`, `EmployeeToSkill`, `SkillLevel`, `Skill`, `PositionToSkill`, and related career-framework entities already exist (created in `20250910193406_CreateDatabaseSchema` and managed by F0008). Tasks T002–T003 **add properties to existing files** rather than recreating them. The F0008 `SkillRadarChart` component may already exist when F0007 is implemented; T022 should reuse it rather than duplicate it.
>
> **Pre-migration check required (T001)**: The Analyze phase identified a Major conflict — existing `source = 'self'` rows in `employee_to_skill` with duplicate `(employee_id, skill_id, is_target)` tuples will cause the partial unique index to fail. The migration must include a pre-condition guard or data-cleanup step for non-production environments.

---

## Task List

### Migration

- [x] T001 [Migration] Create EF migration `AddSkillAssessmentSchema` — `ALTER TABLE positions ADD COLUMN sort_order`, `IX_positions_career_track_sort_order` index; `ALTER TABLE employee_to_skill ADD COLUMN notes`, `UX_employee_to_skill_self` partial unique index `WHERE source = 'self'`; `CREATE TABLE employee_skill_evidence` with `IX_employee_skill_evidence_assessment_id` and `UX_employee_skill_evidence_assessment_feedback`; include rollback SQL in a comment block — `cpr-api/src/CPR.Infrastructure/Data/Migrations/AddSkillAssessmentSchema.cs`

---

### Domain

- [x] T002 [Domain] Add `SortOrder` property (`int`) to existing `Position` entity — `cpr-api/src/CPR.Domain/Entities/Position.cs`
- [x] T003 [Domain] Add `Notes` property (`string?`) and `Evidence` navigation collection (`ICollection<EmployeeSkillEvidence>`) to existing `EmployeeToSkill` entity — `cpr-api/src/CPR.Domain/Entities/EmployeeToSkill.cs`
- [x] T004 [Domain] Create `EmployeeSkillEvidence` entity inheriting `AuditableEntity` — properties: `EmployeeToSkillId` (Guid), `FeedbackId` (Guid); navigations: `EmployeeToSkill`, `Feedback` — `cpr-api/src/CPR.Domain/Entities/EmployeeSkillEvidence.cs`
- [x] T005 [Domain] Create `ISkillAssessmentRepository` interface — methods: `GetAssessmentAsync(employeeId)`, `UpsertCurrentLevelAsync(...)`, `DeleteCurrentLevelAsync(...)`, `UpsertTargetLevelAsync(...)`, `DeleteTargetLevelAsync(...)`, `LinkEvidenceAsync(...)`, `UnlinkEvidenceAsync(...)`, `GetTeamSummaryAsync(managerId)` — `cpr-api/src/CPR.Domain/Repositories/ISkillAssessmentRepository.cs`
- [x] T006 [Domain] Create `ISkillAssessmentService` interface — mirrors all api.md operations, returns DTOs — `cpr-api/src/CPR.Application/Services/ISkillAssessmentService.cs`

---

### Infrastructure

- [x] T007 [Infra] Update `CprDbContext` — add `DbSet<EmployeeSkillEvidence> EmployeeSkillEvidences`; extend `Position` `OnModelCreating` config with `sort_order` column mapping and composite index; extend `EmployeeToSkill` config with `notes` column and partial unique index (`HasFilter("source = 'self'")`); add full `EmployeeSkillEvidence` entity config (table name, column names, FKs to `employee_to_skill` and `feedback`, unique index, soft-delete filter) — `cpr-api/src/CPR.Infrastructure/Data/CprDbContext.cs`
- [x] T008 [Infra] Implement `SkillAssessmentRepository` — implement all `ISkillAssessmentRepository` methods using `CprDbContext`; upsert via `FindAsync` + update or `Add`; eager-load `PositionToSkill`, `SkillLevel`, `EmployeeToSkill`, `EmployeeSkillEvidence` in `GetAssessmentAsync`; next-position query: `positions WHERE career_track_id = X AND sort_order > current ORDER BY sort_order LIMIT 1` — `cpr-api/src/CPR.Infrastructure/Data/Repositories/SkillAssessmentRepository.cs`
- [x] T009 [Infra] Implement `SkillAssessmentService` — implement `ISkillAssessmentService`; enforce business rules: skill must be in `position_to_skill` for employee's position (else 404); target value must be strictly greater than current assessed value (else 422 `target_too_low`); feedback must have `to_employee_id = current employee` (else 404); `employee_to_skill` record must exist before linking evidence (else 422 `assessment_required`); no duplicate evidence (else 422 `already_linked`); map entities to DTOs; use `ISkillAssessmentRepository` for all persistence — `cpr-api/src/CPR.Infrastructure/Services/SkillAssessmentService.cs`

---

### Application

- [x] T010 [App] Create `SkillAssessmentResponseDtos` — `SkillAssessmentResponseDto` (position, next_position, skill_categories), `PositionBriefDto`, `NextPositionDto`, `SkillCategoryGroupDto`, `SkillItemDto` (with required_level, next_position_required_level, assessed, target, evidence), `AssessedLevelDto`, `TargetLevelDto`, `EvidenceItemDto`; `TeamSkillSummaryResponseDto`, `TeamMemberSummaryDto`; `EmployeeSkillAssessmentResponseDto` (adds `employee` field); all properties decorated `[JsonPropertyName]` — `cpr-api/src/CPR.Application/DTOs/SkillAssessment/SkillAssessmentResponseDtos.cs`
- [x] T011 [App] Create `SkillAssessmentRequestDtos` — `UpsertSkillAssessmentDto` (`skill_level_id`, `notes?`), `UpsertSkillTargetDto` (`skill_level_id`), `LinkEvidenceDto` (`feedback_id`); all decorated `[JsonPropertyName]` — `cpr-api/src/CPR.Application/DTOs/SkillAssessment/SkillAssessmentRequestDtos.cs`
- [x] T012 [App] Create `SkillAssessmentDtoValidator` — FluentValidation rules: `UpsertSkillAssessmentDto` (`skill_level_id` required non-empty Guid; `notes` max 1,000 characters); `UpsertSkillTargetDto` (`skill_level_id` required non-empty Guid); `LinkEvidenceDto` (`feedback_id` required non-empty Guid) — `cpr-api/src/CPR.Application/Validators/SkillAssessmentDtoValidator.cs`

---

### API

- [x] T013 [API] Create `SkillAssessmentController` — `[Route("api/skill-assessment")]`; `[HttpGet("~/api/me/skill-assessment")]` (all roles); `[HttpPut("~/api/me/skill-assessment/skills/{skillId}")]` (all roles, returns 200 `AssessedLevelDto`); `[HttpDelete("~/api/me/skill-assessment/skills/{skillId}")]` (all roles, 204); `[HttpPut("~/api/me/skill-assessment/skills/{skillId}/target")]` (all roles, 200 `TargetLevelDto`); `[HttpDelete("~/api/me/skill-assessment/skills/{skillId}/target")]` (all roles, 204); `[HttpPost("~/api/me/skill-assessment/skills/{skillId}/evidence")]` (all roles, 201 `EvidenceItemDto`); `[HttpDelete("~/api/me/skill-assessment/skills/{skillId}/evidence/{feedbackId}")]` (all roles, 204); `[HttpGet("~/api/me/team/skill-assessment-summary")]` (PeopleManager policy); `[HttpGet("~/api/employees/{employeeId}/skill-assessment")]` (PeopleManager, Director, Administrator policies) — `cpr-api/src/CPR.Api/Controllers/SkillAssessmentController.cs`
- [x] T014 [API] Register `ISkillAssessmentRepository → SkillAssessmentRepository` and `ISkillAssessmentService → SkillAssessmentService` as `AddScoped` in `AddInfrastructure()` — `cpr-api/src/CPR.Api/InfrastructureRegistrar.cs`

---

### UI — Types & Services

- [x] T015 [UI] Create TypeScript types — `ISkillAssessmentResponse`, `IPositionBrief`, `INextPosition`, `ISkillCategoryGroup`, `ISkillItem`, `IAssessedLevel`, `ITargetLevel`, `IEvidenceItem`; `ITeamSkillSummaryResponse`, `ITeamMemberSummary`; `IEmployeeSkillAssessmentResponse`; request types `IUpsertSkillAssessmentRequest`, `IUpsertSkillTargetRequest`, `ILinkEvidenceRequest`; all fields in snake_case matching API wire format — `cpr-ui/src/types/skillAssessment.types.ts`
- [x] T016 [UI] Create `skillAssessmentService.ts` — `SkillAssessmentApiService` class with methods: `getMyAssessment()`, `upsertCurrentLevel(skillId, dto)`, `deleteCurrentLevel(skillId)`, `upsertTarget(skillId, dto)`, `deleteTarget(skillId)`, `linkEvidence(skillId, dto)`, `unlinkEvidence(skillId, feedbackId)`, `getEmployeeAssessment(employeeId)`, `getTeamSummary()`; export singleton `skillAssessmentApiService` — `cpr-ui/src/services/skillAssessmentService.ts`
- [x] T017 [UI] Create `skillAssessmentQueryService.ts` — `useMySkillAssessment()` query (staleTime 2 min); `useEmployeeSkillAssessment(employeeId)` query; `useTeamSkillSummary()` query; mutations `useUpsertCurrentLevel`, `useDeleteCurrentLevel`, `useUpsertTarget`, `useDeleteTarget`, `useLinkEvidence`, `useUnlinkEvidence` — each mutation calls `invalidateQueries` on the relevant assessment query key after success — `cpr-ui/src/services/skillAssessmentQueryService.ts`

---

### UI — MSW Mocks

- [x] T018 [UI] Create skill assessment mock data — one `ISkillAssessmentResponse` fixture (position → track → path, next position, 2 skill categories with 3–4 skills each, mix of assessed/unassessed/targeted); one `ITeamSkillSummaryResponse` with 3 team members; consistent UUIDs shared with F0008 taxonomy mock data where applicable — `cpr-ui/src/mocks/data/skillAssessmentMockData.ts`
- [x] T019 [UI] Create MSW handlers for all skill assessment endpoints — `GET */api/me/skill-assessment`, `PUT/DELETE */api/me/skill-assessment/skills/:skillId`, `PUT/DELETE */api/me/skill-assessment/skills/:skillId/target`, `POST/DELETE */api/me/skill-assessment/skills/:skillId/evidence/:feedbackId?`, `GET */api/me/team/skill-assessment-summary`, `GET */api/employees/:employeeId/skill-assessment`; simulate 422 target conflict and 422 assessment_required scenarios — `cpr-ui/src/mocks/handlers/skillAssessmentHandlers.ts`
- [x] T020 [UI] Register `skillAssessmentHandlers` in MSW handler index — spread `...skillAssessmentHandlers` into `allHandlers` — `cpr-ui/src/mocks/handlers/index.ts`

---

### UI — Components

- [x] T021 [UI] Create `EvidenceList` — renders a list of attached evidence items below a skill row; each item: sender display name, star rating (MUI `Rating` read-only), content excerpt truncated to 200 chars, "Remove" `IconButton`; triggers `useUnlinkEvidence` on remove; empty state hidden (list not rendered if empty); read-only mode hides Remove button — `cpr-ui/src/components/skillAssessment/EvidenceList.tsx`
- [x] T022 [UI] Create `AssessmentRadarChart` — radar/spider chart with three labelled datasets (blue solid = current position required; green solid = self-assessed; grey dashed = next position required); if F0008's `SkillRadarChart` already exists, compose or extend it rather than duplicate; "highest position" banner rendered below chart when `next_position` is null; chart axes = current-position skill titles; missing assessed values default to 0; re-renders on `data` prop change — `cpr-ui/src/components/skillAssessment/AssessmentRadarChart.tsx`
- [x] T023 [UI] Create `EvidenceModal` — MUI `Dialog`; opens for a specific skill; fetches feedback list via `GET /api/me/feedback`; renders search filter input + feedback list rows with sender name, star rating, content excerpt; checkboxes; already-linked items pre-checked and disabled; Save button calls `useLinkEvidence` for each newly checked item; empty state "No feedback received yet"; Cancel closes without changes — `cpr-ui/src/components/skillAssessment/EvidenceModal.tsx`
- [x] T024 [UI] Create `AssessmentSkillRow` — MUI `TableRow`; columns: skill title + description tooltip, required level badge, current level `Select` dropdown (skill_levels ordered by value ASC; "Not assessed" placeholder), target level `Select` dropdown ("No target set" placeholder; "Clear target" option), notes `TextField` multiline; auto-saves current level on dropdown `onChange` (calls `useUpsertCurrentLevel`), notes on `onBlur`; target on dropdown `onChange` (calls `useUpsertTarget`; "Clear target" calls `useDeleteTarget`); saving spinner + "Saved ✓" indicator per row; inline 422 error message; read-only mode renders all fields as plain text/static badges — `cpr-ui/src/components/skillAssessment/AssessmentSkillRow.tsx`
- [x] T025 [UI] Create `AssessmentSkillCategorySection` — renders a labelled `TableContainer` section for one skill category; heading row with category title; maps `skills` array to `AssessmentSkillRow` components; passes `readOnly` prop through — `cpr-ui/src/components/skillAssessment/AssessmentSkillCategorySection.tsx`
- [x] T026 [UI] Create `TeamSkillOverviewTable` — MUI `Table` with columns: Name, Position, Assessed (x/total), Meeting Requirement (x/total); rows are direct reports from `ITeamMemberSummary[]`; clickable rows navigate to `/skills/employees/:employeeId/assessment`; loading skeleton (3 rows); empty state "No direct reports found" — `cpr-ui/src/components/skillAssessment/TeamSkillOverviewTable.tsx`

---

### UI — Pages

- [x] T027 [UI] Create `SkillAssessmentPage` — route `/skills/assessment`; fetches `useMySkillAssessment()`; renders MUI `Container`: position/track/path header (Typography), `AssessmentRadarChart`, then `AssessmentSkillCategorySection` per category; full-page loading skeleton; empty state "No skills required for your current position"; error state with retry button — `cpr-ui/src/pages/skillAssessment/SkillAssessmentPage.tsx`
- [x] T028 [UI] Create `EmployeeAssessmentPage` — route `/skills/employees/:employeeId/assessment`; fetches `useEmployeeSkillAssessment(employeeId)`; renders read-only banner "Viewing assessment for: [display_name]"; same layout as `SkillAssessmentPage` with `readOnly={true}` passed to all child components; 403/404 error states — `cpr-ui/src/pages/skillAssessment/EmployeeAssessmentPage.tsx`
- [x] T029 [UI] Create `TeamSkillOverviewPage` — route `/skills/team`; fetches `useTeamSkillSummary()`; heading "Team Skill Overview"; renders `TeamSkillOverviewTable`; loading/empty/error states — `cpr-ui/src/pages/skillAssessment/TeamSkillOverviewPage.tsx`

---

### UI — i18n & Routes

- [x] T030 [UI] Add skill assessment i18n keys to English translation file — keys under `pages.skillAssessment.*` (title, header labels, empty states, error messages), `pages.teamSkillOverview.*` (title, column headers, empty state), `pages.employeeAssessment.*` (read-only banner, title), `components.assessmentSkillRow.*` (placeholders "Not assessed" / "No target set", "Clear target", saving/saved/error indicators, validation message "Target level must be higher than your current level"), `components.evidenceModal.*` (title, search placeholder, empty state, save/cancel buttons) — `cpr-ui/public/locales/en/translation.json`
- [x] T031 [UI] Register skill assessment routes in the router — `/skills/assessment` (all authenticated roles under `AppLayout`); `/skills/team` wrapped in `<RoleGuard allowedRoles={[UserRole.PEOPLE_MANAGER]}>` ; `/skills/employees/:employeeId/assessment` wrapped in `<RoleGuard allowedRoles={[UserRole.PEOPLE_MANAGER, UserRole.DIRECTOR, UserRole.ADMINISTRATOR]}>` — `cpr-ui/src/routes/index.tsx`

---

### Tests

- [x] T032 [Test] Unit tests for `SkillAssessmentService` — test `GetAssessmentAsync`: returns correct grouped structure, null next_position when at highest sort_order, null assessed/target when no record exists; test `UpsertCurrentLevelAsync`: happy path, 404 when skill not in position_to_skill, 422 `target_conflict` when target value ≤ new current value; test `UpsertTargetAsync`: happy path, 422 `target_too_low`; test `LinkEvidenceAsync`: happy path, 422 `assessment_required`, 422 `already_linked`, 404 `feedback_not_found`; test `GetTeamSummaryAsync`: correct counts — `cpr-api/tests/CPR.UnitTests/Services/SkillAssessmentServiceTests.cs`
- [x] T033 [Test] Unit tests for `SkillAssessmentDtoValidator` — `UpsertSkillAssessmentDto`: valid input passes; missing `skill_level_id` fails; `notes` at exactly 1,000 chars passes; `notes` at 1,001 chars fails; `UpsertSkillTargetDto`: missing `skill_level_id` fails; `LinkEvidenceDto`: missing `feedback_id` fails — `cpr-api/tests/CPR.UnitTests/Validators/SkillAssessmentValidatorTests.cs`
- [x] T034 [Test] Integration tests for self-assessment personal endpoints — `GET /api/me/skill-assessment`: 200 with correct shape, 401 without token; `PUT .../skills/{id}`: 200 on upsert, 422 `target_conflict`, 404 `skill_not_found`, 422 `invalid_level`; `DELETE .../skills/{id}`: 204 success, 404 `assessment_not_found`; `PUT .../skills/{id}/target`: 200 success, 422 `target_too_low`; `DELETE .../skills/{id}/target`: 204, 404; `POST .../evidence`: 201 with evidence item, 422 `assessment_required`, 422 `already_linked`; `DELETE .../evidence/{feedbackId}`: 204, 404 — `cpr-api/tests/CPR.IntegrationTests/Controllers/SkillAssessmentSelfEndpointsTests.cs`
- [x] T035 [Test] Integration tests for manager and admin read endpoints — `GET /api/employees/{id}/skill-assessment`: 200 for `PeopleManager` requesting a direct report, 403 for `PeopleManager` requesting a non-direct-report, 403 for `Employee` role, 200 for `Director`, 200 for `Administrator`, 404 for unknown employee ID; `GET /api/me/team/skill-assessment-summary`: 200 for `PeopleManager`, 403 for `Employee` role, 403 for `Director` — `cpr-api/tests/CPR.IntegrationTests/Controllers/SkillAssessmentManagerEndpointsTests.cs`
- [x] T036 [Test] Frontend tests for `SkillAssessmentPage` — renders position header with MSW mock data; skill categories displayed; dropdowns render all levels; selecting a level calls the upsert mutation; notes field blur triggers save; "Link feedback" opens `EvidenceModal`; selecting feedback in modal and saving calls link mutation; evidence appears under skill row; Remove evidence calls unlink mutation; radar chart renders — `cpr-ui/src/__tests__/pages/skillAssessment/SkillAssessmentPage.test.tsx`
- [x] T037 [Test] Frontend tests for `TeamSkillOverviewPage` and `EmployeeAssessmentPage` — team table renders 3 rows from mock data; row click navigates to employee assessment route; employee assessment page renders in read-only mode (no `Select` dropdowns present, no "Link feedback" button, read-only banner visible); 403 renders error state — `cpr-ui/src/__tests__/pages/skillAssessment/TeamAndReadOnlyTests.test.tsx`

---

## Rationale

The single migration (T001) opens the plan because `sort_order`, `notes`, and `employee_skill_evidence` must exist in the schema before EF Core mappings reference them; the Major conflict finding requires a pre-condition guard against existing duplicate self-assessment rows that would violate the new partial unique index. Entity updates (T002–T004) come before EF Core configuration (T007) because `OnModelCreating` must reference the entity properties being mapped; `EmployeeSkillEvidence` is a new entity while `Position` and `EmployeeToSkill` are existing files from F0008 that receive only additive property changes. The repository interface (T005) and service interface (T006) are defined before their implementations (T008–T009) so that consumers in Application and API layers can code against abstractions; the service implementation (T009) references DTOs from Application layer — this is valid because Infrastructure has a compile-time dependency on Application. DTOs (T010–T011) are defined before the validator (T012) because `FluentValidation` generic types reference concrete DTO classes. On the frontend, mock data (T018) is seeded before MSW handlers (T019) reference it; leaf components (`EvidenceList`, `AssessmentRadarChart`, `AssessmentSkillRow`) are implemented before the composing section and page components that import them; `AssessmentRadarChart` (T022) explicitly adapts rather than duplicates the F0008 `SkillRadarChart` component per the Analyze minor conflict guidance. i18n keys (T030) and route registration (T031) are last in the UI group because they depend on knowing the complete string surface area and page component export names.
