# Plan — Skill Assessment Schema Refactor (0010)

## Tasks

### Migration

- [x] T001 [Migration] Create EF Core migration `20260310000001_RefactorSkillAssessmentSchema` with Up/Down methods: delete `is_target = TRUE` rows, null-guard `persist_value`, rename `persist_value` → `self_assessment_value` (NOT NULL DEFAULT 0), add `manager_assessment_value` (NUMERIC NULL), drop index `UX_employee_to_skill_self`, drop columns `source` and `is_target`, drop index `UX_employee_to_skill_employee_skill_effective`, create index `UX_employee_to_skill_employee_skill` on `(employee_id, skill_id) WHERE is_deleted = FALSE`, drop `position_to_skill.weight` — `source/cpr-api/src/CPR.Infrastructure/Migrations/20260310000001_RefactorSkillAssessmentSchema.cs`

### Domain

- [x] T002 [Domain] Update `EmployeeToSkill` entity: rename `PersistValue` → `SelfAssessmentValue` (decimal, required), add `ManagerAssessmentValue` (decimal?, nullable), remove `Source` (string?) and `IsTarget` (bool) properties — `source/cpr-api/src/CPR.Domain/Entities/EmployeeToSkill.cs`
- [x] T003 [Domain] Update `PositionToSkill` entity: remove `Weight` (decimal?) property — `source/cpr-api/src/CPR.Domain/Entities/PositionToSkill.cs`

### Infrastructure — EF Core Configuration

- [x] T004 [Infra] Update `CprDbContext.OnModelCreating`: replace `PersistValue`/`Source`/`IsTarget` column configs with `SelfAssessmentValue` (column `self_assessment_value`, NOT NULL) and `ManagerAssessmentValue` (column `manager_assessment_value`, nullable); drop `UX_employee_to_skill_self` index definition, add `UX_employee_to_skill_employee_skill` partial unique index `(employee_id, skill_id) WHERE is_deleted = FALSE`; remove `Weight` column config from `PositionToSkill` entity configuration — `source/cpr-api/src/CPR.Infrastructure/Data/CprDbContext.cs`

### Application — Interfaces, DTOs, Validators

- [x] T005 [App] Update `ISkillAssessmentRepository`: replace `EmployeeSkillRow` projection fields (`PersistValue`/`Source`/`IsTarget`) with `SelfAssessmentValue`/`ManagerAssessmentValue`; add `Task UpsertManagerAssessmentAsync(Guid employeeId, Guid skillId, decimal value, CancellationToken ct)` method signature; remove any target-level projection types — `source/cpr-api/src/CPR.Application/Repositories/ISkillAssessmentRepository.cs`
- [x] T006 [App] Update `ISkillAssessmentService`: remove `UpsertTargetAsync` and `DeleteTargetAsync` method signatures; add `Task<SkillAssessmentResponseDto> UpsertManagerAssessmentAsync(Guid actorId, Guid employeeId, Guid skillId, decimal value, CancellationToken ct)` signature — `source/cpr-api/src/CPR.Application/Services/ISkillAssessmentService.cs`
- [x] T007 [App] Update `SkillAssessmentRequestDtos`: rename `UpsertSkillAssessmentDto.SkillLevelId` → `SelfAssessmentValue` (decimal); remove `UpsertSkillTargetDto` record; add `UpsertManagerAssessmentDto { ManagerAssessmentValue (decimal) }` record — `source/cpr-api/src/CPR.Application/DTOs/SkillAssessment/SkillAssessmentRequestDtos.cs`
- [x] T008 [App] Update `SkillAssessmentResponseDtos`: replace `AssessedLevelDto` fields (`SkillLevelId`/`Title`/`Value`) with `SelfAssessmentValue` (decimal) and `ManagerAssessmentValue` (decimal?); remove `TargetLevelDto` record; remove `Target` property from `SkillItemDto` — `source/cpr-api/src/CPR.Application/DTOs/SkillAssessment/SkillAssessmentResponseDtos.cs`
- [x] T009 [App] Update `SkillAssessmentDtoValidator`: replace `skill_level_id` rule with `SelfAssessmentValue > 0` validation; add `UpsertManagerAssessmentDtoValidator` requiring `ManagerAssessmentValue > 0`; remove `UpsertSkillTargetDtoValidator` — `source/cpr-api/src/CPR.Application/Validators/SkillAssessmentDtoValidator.cs`
- [x] T010 [App] Update `PositionDtos`: remove `Weight` (decimal?) property from `PositionSkillRequirementDto`, `AddPositionSkillDto`, and `UpdatePositionSkillDto` — `source/cpr-api/src/CPR.Application/DTOs/Taxonomy/PositionDtos.cs`

### Infrastructure — Repository and Service Implementations

- [x] T011 [Infra] Update `SkillAssessmentRepository`: update all LINQ projections to map `SelfAssessmentValue`/`ManagerAssessmentValue` instead of `PersistValue`/`Source`/`IsTarget`; remove target-level query branches; implement `UpsertManagerAssessmentAsync` — find the `employee_to_skill` row for `(employeeId, skillId)` where `is_deleted = FALSE`, update `manager_assessment_value`, return updated assessment — `source/cpr-api/src/CPR.Infrastructure/Repositories/SkillAssessmentRepository.cs`
- [x] T012 [Infra] Update `SkillAssessmentService`: remove `UpsertTargetAsync` and `DeleteTargetAsync` implementations; update `UpsertCurrentLevelAsync` to set `SelfAssessmentValue` (not `PersistValue`); implement `UpsertManagerAssessmentAsync` with RBAC: `PeopleManager` restricted to direct reports (403 if not), `Director`/`Administrator` unrestricted, 404 if skill row not found; update upsert guard condition from `source = 'self'` to row-existence check — `source/cpr-api/src/CPR.Infrastructure/Services/SkillAssessmentService.cs`
- [x] T013 [Infra] Update `TaxonomyRepository`: remove `Weight` from `PositionToSkill` LINQ projections and any explicit weight assignments in position-skill create/update methods — `source/cpr-api/src/CPR.Infrastructure/Repositories/TaxonomyRepository.cs`
- [x] T014 [Infra] Update `TaxonomyService`: remove `Weight` from position-skill create and update logic; ensure incoming `weight` values from DTOs are not written to the entity — `source/cpr-api/src/CPR.Infrastructure/Services/TaxonomyService.cs`

### API

- [x] T015 [API] Update `SkillAssessmentController`: remove `PutTarget` and `DeleteTarget` action methods (or replace with explicit `404 Not Found` stubs); add `PUT /api/employees/{employeeId}/skill-assessment/skills/{skillId}/manager-assessment` action with `[RequireRole("PeopleManager", "Director", "Administrator")]` calling `ISkillAssessmentService.UpsertManagerAssessmentAsync`; ensure `GET /api/employees/{employeeId}/skill-assessment` returns the updated response DTO shape — `source/cpr-api/src/CPR.Api/Controllers/SkillAssessmentController.cs`
- [x] T016 [API] Update `TaxonomyController`: verify no explicit `weight` mapping remains in position-skill action methods; if any, remove them — weight removal in DTO (T010) handles model binding automatically — `source/cpr-api/src/CPR.Api/Controllers/TaxonomyController.cs`

### Config

- [x] T017 [Config] Update `documents/data.md`: revise `employee_to_skill` block replacing `persist_value`/`source`/`is_target` entries with `self_assessment_value NUMERIC NOT NULL DEFAULT 0` and `manager_assessment_value NUMERIC NULL`, update unique index entry; remove `weight NUMERIC NULL` from `position_to_skill` block; add `employee_skill_evidence` section documenting the existing join table — `documents/data.md`

### UI — Types

- [x] T018 [UI] Update `skillAssessment.types.ts`: in `IAssessedLevel` replace `skillLevelId`/`title`/`value` fields with `selfAssessmentValue` (number) and `managerAssessmentValue` (number | null); remove `ITargetLevel` interface; remove `target` property from `ISkillItem`; add `IUpsertSelfAssessmentRequest { self_assessment_value: number; notes?: string }` and `IUpsertManagerAssessmentRequest { manager_assessment_value: number }` request types — `source/cpr-ui/src/types/skillAssessment.types.ts`
- [x] T019 [UI] Update `taxonomy.types.ts`: remove `weight` (number?) field from `IPositionSkillRequirement`, `IAddPositionSkillRequest`, and `IUpdatePositionSkillRequest` interfaces — `source/cpr-ui/src/types/taxonomy.types.ts`

### UI — API Services

- [x] T020 [UI] Update `skillAssessmentService.ts`: change `upsertCurrentLevel` to POST `{ self_assessment_value, notes }` (remove `skill_level_id`); remove `upsertTarget` and `deleteTarget` methods; add `upsertManagerAssessment(employeeId: string, skillId: string, dto: IUpsertManagerAssessmentRequest)` method calling `PUT /api/employees/{employeeId}/skill-assessment/skills/{skillId}/manager-assessment` — `source/cpr-ui/src/services/skillAssessmentService.ts`
- [x] T021 [UI] Update `taxonomyService.ts`: remove `weight` from position-skill request payloads in `addPositionSkill` and `updatePositionSkill` methods — `source/cpr-ui/src/services/taxonomyService.ts`

### UI — React Query Hooks

- [x] T022 [UI] Update `skillAssessmentQueryService.ts`: remove `useUpsertTarget` and `useDeleteTarget` mutation hooks; add `useUpsertManagerAssessment` mutation hook calling `skillAssessmentService.upsertManagerAssessment` with `onSuccess` cache invalidation for `employeeAssessment(employeeId)` query key; update `useUpsertCurrentLevel` mutation to use updated request shape — `source/cpr-ui/src/services/skillAssessmentQueryService.ts`

### UI — MSW Mocks

- [x] T023 [UI] Update `skillAssessmentHandlers.ts`: replace target endpoint handlers with 404 stubs; add handler for `PUT /api/employees/:employeeId/skill-assessment/skills/:skillId/manager-assessment` returning updated mock response; update existing handler response shapes to use `self_assessment_value`/`manager_assessment_value` instead of `skill_level_id`/`value`/`title` — `source/cpr-ui/src/mocks/handlers/skillAssessmentHandlers.ts`
- [x] T024 [UI] Update `skillAssessmentMockData.ts`: replace `assessed` object shape (`skill_level_id`/`title`/`value`/`target`) with `self_assessment_value` (number) and `manager_assessment_value` (number | null); remove target-level mock data — `source/cpr-ui/src/mocks/data/skillAssessmentMockData.ts`
- [x] T025 [UI] Update `taxonomyHandlers.ts`: remove `weight` field from position-skill objects in mock responses for `POST`/`PATCH /api/taxonomy/positions/:id/skills` handlers — `source/cpr-ui/src/mocks/handlers/taxonomyHandlers.ts`
- [x] T026 [UI] Update `taxonomyMockData.ts`: remove `weight` field from all `position_skills` mock objects — `source/cpr-ui/src/mocks/data/taxonomyMockData.ts`

### UI — Components and Pages

- [x] T027 [UI] Update `AssessmentSkillRow.tsx`: replace proficiency level `<Select>` / `skill_level_id` state with a numeric `<TextField type="number" inputProps={{ min: 0, step: 0.1 }}>`; bind value to `self_assessment_value`; trigger `PUT` on blur with `{ self_assessment_value, notes }`; show inline validation error if value ≤ 0; remove target-level control and any `is_target`/`source` references — `source/cpr-ui/src/components/skillAssessment/AssessmentSkillRow.tsx`
- [x] T028 [UI] Update `AssessmentRadarChart.tsx` (or `AssessmentSkillsRadarChart.tsx`): update data mapping to read `selfAssessmentValue` (or `self_assessment_value`) instead of `skill_level_id`/`value`; keep two series (Required Level + Actual Level); remove any third "target" series — `source/cpr-ui/src/components/skillAssessment/AssessmentRadarChart.tsx`
- [x] T029 [UI] Update `SkillAssessmentPage.tsx`: remove Target Level column header and any target-level UI cells from the skills table; remove any import or usage of target mutation hooks — `source/cpr-ui/src/pages/skillAssessment/SkillAssessmentPage.tsx`
- [x] T030 [UI] Update `EmployeeAssessmentPage.tsx`: add "Manager Assessment" column to the skills table — render a numeric `<TextField type="number" inputProps={{ min: 0 }}>` for `PeopleManager`/`Director`/`Administrator` callers (save on blur via `useUpsertManagerAssessment`); render read-only text for Employee-role viewers; show "Saved ✓" indicator (2 s) on success; show inline error on 400/403 — `source/cpr-ui/src/pages/skillAssessment/EmployeeAssessmentPage.tsx`
- [x] T031 [UI] Update `SkillRequirementsTable.tsx`: remove "Weight" column header and weight value cells from the position skills table — `source/cpr-ui/src/components/taxonomy/SkillRequirementsTable.tsx`
- [x] T032 [UI] Update `PositionDetailPage.tsx`: remove any direct weight rendering or weight-related state that was not already handled by `SkillRequirementsTable`; verify the page compiles and renders correctly after weight removal — `source/cpr-ui/src/pages/taxonomy/PositionDetailPage.tsx`
- [x] T033 [UI] Update `public/locales/en/translation.json`: remove i18n keys for target-level controls (e.g. `targetLevel`, `setTargetLevel`, `deleteTarget`); add keys for manager assessment column heading, "Manager Assessment" label, and any new validation messages — `source/cpr-ui/public/locales/en/translation.json`

### Tests

- [x] T034 [Test] Update `SkillAssessmentServiceTests.cs`: remove unit tests for `UpsertTargetAsync`/`DeleteTargetAsync`; add unit tests for `UpsertManagerAssessmentAsync` covering: happy path (direct report), 403 when PeopleManager targets non-direct-report, 404 when skill row not found, Director/Admin unrestricted access; update existing tests to use `SelfAssessmentValue` instead of `PersistValue`/`SkillLevelId` — `source/cpr-api/tests/CPR.UnitTests/Services/SkillAssessmentServiceTests.cs`
- [x] T035 [Test] Update `SkillAssessmentValidatorTests.cs`: remove tests for `UpsertSkillTargetDto`; add tests for `UpsertManagerAssessmentDto` (valid, zero, negative); update `UpsertSkillAssessmentDto` tests to validate `self_assessment_value` field — `source/cpr-api/tests/CPR.UnitTests/Validators/SkillAssessmentValidatorTests.cs`
- [x] T036 [Test] Update `SkillAssessmentSelfEndpointsTests.cs`: update request bodies from `{ skill_level_id }` to `{ self_assessment_value }`; update GET response assertions to check `self_assessment_value`/`manager_assessment_value` instead of `skill_level_id`/`title`/`target`; add tests that `PUT .../target` and `DELETE .../target` return 404 — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/SkillAssessmentSelfEndpointsTests.cs`
- [x] T037 [Test] Update `SkillAssessmentManagerEndpointsTests.cs`: add integration tests for `PUT /api/employees/{id}/skill-assessment/skills/{skillId}/manager-assessment` covering: 200 OK (PeopleManager → direct report), 403 (PeopleManager → non-direct-report), 400 (missing/zero value), 403 (Employee role), 200 OK (Director), 200 OK (Administrator); update existing GET assertions to use new response shape — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/SkillAssessmentManagerEndpointsTests.cs`
- [x] T038 [Test] Update `AssessmentSkillRowTests.test.tsx`: replace level-selector interaction tests with numeric input tests (valid number, empty, zero shows validation); remove target-level tests; add blur-to-save and "Saved ✓" indicator tests using the new `self_assessment_value` request shape — `source/cpr-ui/src/__tests__/components/skillAssessment/AssessmentSkillRowTests.test.tsx`
- [x] T039 [Test] Update `AssessmentRadarChartTests.test.tsx`: update data props to pass `selfAssessmentValue` instead of `skill_level_id`/`value`; verify two-series rendering (Required + Actual); remove any third-series (target) assertions — `source/cpr-ui/src/__tests__/components/skillAssessment/AssessmentRadarChartTests.test.tsx`
- [x] T040 [Test] Update `SkillAssessmentPage.test.tsx`: remove Target Level column existence tests; verify numeric input renders instead of dropdown; update mock data to new response shape — `source/cpr-ui/src/__tests__/pages/skillAssessment/SkillAssessmentPage.test.tsx`
- [x] T041 [Test] Update `TeamAndReadOnlyTests.test.tsx`: add tests verifying "Manager Assessment" column renders on `EmployeeAssessmentPage`; verify numeric input visible to manager role; verify read-only text visible to employee role; verify "Saved ✓" indicator appears after successful save — `source/cpr-ui/src/__tests__/pages/skillAssessment/TeamAndReadOnlyTests.test.tsx`
- [x] T042 [Test] Update `PositionDetailPage.test.tsx`: remove Weight column existence assertions; verify skills table renders without weight column after mock data update — `source/cpr-ui/src/__tests__/pages/taxonomy/PositionDetailPage.test.tsx`

---

## Rationale

**Ordering**: The migration (T001) runs first so the live DB schema matches the domain model changes that follow. Domain entities (T002–T003) must precede the EF Core `OnModelCreating` configuration (T004) since the configuration references entity properties. Application-layer interfaces and DTOs (T005–T010) must be updated before Infrastructure implementations (T011–T014) because the repositories and services implement those interfaces — compiling the Infrastructure project before App is updated would produce build errors. API controllers (T015–T016) follow naturally once service contracts are settled. The `data.md` documentation update (T017) is independent and safe to defer until after backend tasks are complete.

**Refactor vs. new feature**: Because all files already exist, the code will not compile cleanly mid-refactor until both the App interfaces (T005–T006) and the Infra implementations (T011–T012) are updated in the same batch. Implementors should apply T002–T014 as a single backend pass, verify `dotnet build src/CPR.sln`, then proceed to T015–T016.

**Target endpoints**: The `PUT`/`DELETE .../target` endpoints are removed (T015) and should return `404 Not Found` with a standard ProblemDetails body so existing API consumers receive a clear signal. This matches the contract specified in US-004.

**Weight removal**: Because `weight` is dropped both at the DB level (T001 migration) and in the PositionToSkill entity (T003), the downstream chain — PositionDtos (T010) → TaxonomyRepository/Service (T013–T014) → TaxonomyController (T016) → Frontend types/service (T019, T021) → MSW mocks (T025–T026) → UI table (T031–T032) — must all be updated consistently. The EF Core strict-mode nullable annotation (`<Nullable>enable</Nullable>`) will surface any missed weight references as build errors.

**DB discrepancy**: The live PostgreSQL database returned by `db-inspector` shows different columns than those tracked by EF Core migrations (the live DB appears to predate the EF migration history). The migration T001 must be authored using `dotnet ef migrations add` against the EF model (not raw SQL), so that EF's model snapshot is updated in sync. The migration should include `migrationBuilder.Sql(...)` for the data-manipulation steps (DELETE target rows, UPDATE nulls) that EF cannot express as model changes.
