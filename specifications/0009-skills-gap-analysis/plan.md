# Implementation Plan — Skills Gap Analysis & Development Planning (0009)

> **Deployment prerequisite**: Feature 0008 must be deployed first. Verify `positions.sort_order` exists before running implementation.

## Tasks

### [App] — DTOs and Application interfaces

- [x] T001 [App] Create GapAnalysis response DTOs (GapAnalysisDto, SkillGapDto, PositionSummaryDto, LinkedGoalDto, GapSummaryDto) — `source/cpr-api/src/CPR.Application/DTOs/GapAnalysis/GapAnalysisResponseDtos.cs`
- [x] T002 [App] Create IGapAnalysisRepository interface (GetGapAnalysisAsync, GetEmployeeRecordAsync, GetNextPositionAsync, GetPositionSkillsAsync, GetEmployeeSkillsAsync, GetLinkedGoalsAsync) — `source/cpr-api/src/CPR.Application/Repositories/IGapAnalysisRepository.cs`
- [x] T003 [App] Create IGapAnalysisService interface (GetMyGapAnalysisAsync, GetEmployeeGapAnalysisAsync) — `source/cpr-api/src/CPR.Application/Services/IGapAnalysisService.cs`

### [Infra] — Repository and service implementations

- [x] T004 [Infra] Implement GapAnalysisRepository using EF Core — queries positions, career_tracks, skills, skill_categories, skill_levels, position_to_skill, employee_to_skill (source='manager'), goals — `source/cpr-api/src/CPR.Infrastructure/Repositories/GapAnalysisRepository.cs`
- [x] T005 [Infra] Implement GapAnalysisService — gap calculation logic, assessment_source fallback to position default level, authorization checks (PeopleManager/Director/Administrator), 422 for no-position cases — `source/cpr-api/src/CPR.Infrastructure/Services/GapAnalysisService.cs`

### [Config] — DI registration

- [x] T006 [Config] Register IGapAnalysisRepository → GapAnalysisRepository and IGapAnalysisService → GapAnalysisService in DI — `source/cpr-api/src/CPR.Api/InfrastructureRegistrar.cs`

### [API] — Controllers

- [x] T007 [API] Add GET /api/me/gap-analysis endpoint to MeController (any authenticated role, resolves caller's employee record) — `source/cpr-api/src/CPR.Api/Controllers/MeController.cs`
- [x] T008 [API] Add GET /api/employees/{id}/gap-analysis endpoint to EmployeesController (PeopleManager/Director/Administrator; service enforces per-role target restrictions) — `source/cpr-api/src/CPR.Api/Controllers/EmployeesController.cs`

### [UI] — Types, DTOs, models, mappers

- [x] T009 [UI] Create GapAnalysis DTOs matching api.md snake_case wire format (TGapAnalysisDto, TSkillGapDto, TLinkedGoalDto, TGapSummaryDto) — `source/cpr-ui/src/dtos/GapAnalysisDto.ts`
- [x] T010 [UI] Create GapAnalysis domain models (camelCase: IGapAnalysis, ISkillGap, ILinkedGoal, IGapSummary) — `source/cpr-ui/src/models/GapAnalysis.ts`
- [x] T011 [UI] Create gapAnalysisMapper (mapGapAnalysis, mapSkillGap, mapLinkedGoal) — `source/cpr-ui/src/mappers/gapAnalysisMapper.ts`

### [UI] — API service and React Query hooks

- [x] T012 [UI] Create gapAnalysisApiService (getMyGapAnalysis, getEmployeeGapAnalysis) — `source/cpr-ui/src/services/api/gapAnalysisApiService.ts`
- [x] T013 [UI] Add gapAnalysis query keys (own, employee(id)) to queryKeys factory — `source/cpr-ui/src/config/queryClient.ts`
- [x] T014 [UI] Create gapAnalysisQueryService hooks (useMyGapAnalysis, useEmployeeGapAnalysis, useCreateGoalFromGap mutation with cache invalidation) — `source/cpr-ui/src/services/gapAnalysisQueryService.ts`

### [UI] — MSW mock handlers

- [x] T015 [UI] Create gapAnalysis mock data fixtures (own-profile response, employee response, error cases: no_position, at_highest_level, forbidden) — `source/cpr-ui/src/mocks/data/gapAnalysisMockData.ts`
- [x] T016 [UI] Create MSW handlers for GET /api/me/gap-analysis and GET /api/employees/:id/gap-analysis — `source/cpr-ui/src/mocks/handlers/gapAnalysisHandlers.ts`
- [x] T017 [UI] Register gapAnalysisHandlers in allHandlers array — `source/cpr-ui/src/mocks/handlers/index.ts`

### [UI] — i18n translation keys

- [x] T018 [UI] Add gap_analysis.* translation keys (no_position_assigned, at_highest_level, page_title, current_position, next_position, skills_table headers, gap_met, create_goal, linked_goals) — `source/cpr-ui/public/locales/en/translation.json`
- [x] T019 [UI] Add gap_analysis.* translation keys (Spanish) — `source/cpr-ui/public/locales/es/translation.json`
- [x] T020 [UI] Add gap_analysis.* translation keys (French) — `source/cpr-ui/public/locales/fr/translation.json`
- [x] T021 [UI] Add gap_analysis.* translation keys (Belarusian) — `source/cpr-ui/public/locales/be/translation.json`

### [UI] — Components and pages

- [x] T022 [UI] Create GapRadarChart component (Recharts RadarChart; two series Required/Actual; one axis per skill) — `source/cpr-ui/src/pages/gapAnalysis/components/GapRadarChart.tsx`
- [x] T023 [UI] Create SkillGapRow component (single table row: skill name, category badge, required/actual level, gap value or "Met", mandatory flag, linked goals list, conditional Create Goal button) — `source/cpr-ui/src/pages/gapAnalysis/components/SkillGapRow.tsx`
- [x] T024 [UI] Create SkillGapTable component (groups rows by category with non-interactive header rows; renders SkillGapRow per skill) — `source/cpr-ui/src/pages/gapAnalysis/components/SkillGapTable.tsx`
- [x] T025 [UI] Create CreateGoalFromGapModal component (reuses goal creation form; pre-populates title, related_skill_id, related_skill_level_id; employee_id is target employee for manager view) — `source/cpr-ui/src/pages/gapAnalysis/components/CreateGoalFromGapModal.tsx`
- [x] T026 [UI] Create GapAnalysisPage (own profile, /gap-analysis; handles loading skeleton, 422 error states, no-gap info state, radar + table layout) — `source/cpr-ui/src/pages/gapAnalysis/GapAnalysisPage.tsx`
- [x] T027 [UI] Create EmployeeGapAnalysisPage (manager/director view, /employees/:id/gap-analysis; same layout; hides Create Goal buttons for Director/Administrator) — `source/cpr-ui/src/pages/gapAnalysis/EmployeeGapAnalysisPage.tsx`

### [UI] — Route registration

- [x] T028 [UI] Register /gap-analysis (all authenticated) and /employees/:id/gap-analysis (PeopleManager, Director, Administrator RoleGuard) routes — `source/cpr-ui/src/routes/index.tsx`

### [Test] — Backend tests

- [x] T029 [Test] Unit tests for GapAnalysisService — gap calculation, assessment_source fallback, authorization enforcement, 422 for missing position — `source/cpr-api/tests/CPR.UnitTests/Services/GapAnalysisServiceTests.cs`
- [x] T030 [Test] Integration tests for gap analysis endpoints — happy path (own + employee), 401/403/404/422 error cases, PeopleManager non-direct-report 403, Director cross-department 403 — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/GapAnalysisEndpointTests.cs`

### [Test] — Frontend tests

- [x] T031 [Test] Unit tests for gapAnalysisMapper — mapGapAnalysis, mapSkillGap, assessment_source default handling — `source/cpr-ui/src/mappers/gapAnalysisMapper.test.ts`
- [x] T032 [Test] Unit tests for GapRadarChart — renders axes per skill, two data series, no-data state — `source/cpr-ui/src/pages/gapAnalysis/components/GapRadarChart.test.tsx`
- [x] T033 [Test] Unit tests for SkillGapTable — category grouping, gap highlight, "Met" display, "(default)" annotation tooltip, Create Goal button visibility by role — `source/cpr-ui/src/pages/gapAnalysis/components/SkillGapTable.test.tsx`
- [x] T034 [Test] Unit tests for GapAnalysisPage — loading skeleton, no-position error state, at-highest-level info state, full render with chart and table — `source/cpr-ui/src/pages/gapAnalysis/GapAnalysisPage.test.tsx`
- [x] T035 [Test] E2E test — Employee views own gap analysis; PeopleManager views direct report and creates a goal from a gap row — `source/cpr-ui/e2e/gapAnalysis.spec.ts`

---

## Rationale

T001–T003 establish the Application layer contracts before any implementation code references them — the repository interface (T002) must exist before GapAnalysisRepository (T004) can implement it, and the service interface (T003) before the service (T005). T004 is placed before T005 because the service depends on the repository. DI registration (T006) follows both implementations so there is no risk of registering an interface whose concrete type does not yet exist. On the frontend, DTOs (T009) must precede models (T010) and mappers (T011) because mappers reference both; the API service (T012) must precede query hooks (T014) since hooks call the service; and mock data (T015) must precede handlers (T016) so fixture objects are importable. Components are ordered leaf-to-composite: GapRadarChart and SkillGapRow are independent leaves; SkillGapTable composes SkillGapRow; CreateGoalFromGapModal is standalone; the two page components compose all sub-components and are therefore last before route registration. Tests are placed last as they can only be written against stable implementation files.

**Deployment dependency**: This feature reads `positions.sort_order` added by Feature 0008. 0008 must be deployed before 0009 is released to production.
