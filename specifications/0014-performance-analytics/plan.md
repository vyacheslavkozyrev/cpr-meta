# Plan — Performance Analytics & Reporting (0014)

## Task List

### [Migration]

- [x] T001 [Migration] Create EF Core migration Up/Down for `employee_skill_history` table with indexes — `source/cpr-api/src/CPR.Infrastructure/Migrations/20260430000000_AddEmployeeSkillHistory.cs`

### [Domain]

- [x] T002 [Domain] Add `EmployeeSkillHistory` entity class extending `AuditableEntity` — `source/cpr-api/src/CPR.Domain/Entities/EmployeeSkillHistory.cs`
- [x] T003 [Domain] Add `IAnalyticsRepository` interface with methods for goal analytics, skill analytics, and history writes — `source/cpr-api/src/CPR.Domain/Repositories/IAnalyticsRepository.cs`

### [Infra]

- [x] T004 [Infra] Register `EmployeeSkillHistory` DbSet and EF model mapping in `CprDbContext` — `source/cpr-api/src/CPR.Infrastructure/Data/CprDbContext.cs`
- [x] T005 [Infra] Implement `AnalyticsRepository` with goal stats queries, skill analytics queries, and `AddSkillHistorySnapshotAsync` write method — `source/cpr-api/src/CPR.Infrastructure/Repositories/AnalyticsRepository.cs`
- [x] T006 [Infra] Hook `AddSkillHistorySnapshotAsync` into `SkillAssessmentService` — call on first create and on every update to `self_assessment_value` or `manager_assessment_value` — `source/cpr-api/src/CPR.Infrastructure/Services/SkillAssessmentService.cs`

### [App]

- [x] T007 [App] Add `AnalyticsPeriod` enum and `PeriodResolver` helper that converts a period string to `(DateTimeOffset start, DateTimeOffset end)` — `source/cpr-api/src/CPR.Application/DTOs/Analytics/AnalyticsPeriod.cs`
- [x] T008 [App] Add `GoalAnalyticsDto` response record (stats, goals_by_status, completion_trend) — `source/cpr-api/src/CPR.Application/DTOs/Analytics/GoalAnalyticsDto.cs`
- [x] T009 [App] Add `SkillAnalyticsDto` response record (gap_closure_summary, skills list with history) — `source/cpr-api/src/CPR.Application/DTOs/Analytics/SkillAnalyticsDto.cs`
- [x] T010 [App] Add `IAnalyticsService` interface with `GetGoalAnalyticsAsync` and `GetSkillAnalyticsAsync` overloads for self and employee-scoped access — `source/cpr-api/src/CPR.Application/Services/IAnalyticsService.cs`
- [x] T011 [App] Add `AnalyticsPeriodValidator` (FluentValidation) that validates the `period` query parameter and maps to `errors.analytics.invalid_period` on failure — `source/cpr-api/src/CPR.Application/Validators/AnalyticsPeriodValidator.cs`
- [x] T012 [App] Implement `AnalyticsService` — resolve period, delegate queries to `IAnalyticsRepository`, compute derived fields (completion_rate, avg_days, gap, gap_closure_summary), enforce PeopleManager direct-report RBAC check — `source/cpr-api/src/CPR.Infrastructure/Services/AnalyticsService.cs`

### [API]

- [x] T013 [API] Add `AnalyticsController` with four endpoints: `GET /api/me/analytics/goals`, `GET /api/me/analytics/skills`, `GET /api/employees/{id}/analytics/goals`, `GET /api/employees/{id}/analytics/skills`; apply `[Authorize]` and role checks per `api.md` — `source/cpr-api/src/CPR.Api/Controllers/AnalyticsController.cs`

### [Infra — DI]

- [x] T014 [Infra] Register `IAnalyticsRepository`/`AnalyticsRepository` and `IAnalyticsService`/`AnalyticsService` in `InfrastructureRegistrar` — `source/cpr-api/src/CPR.Api/InfrastructureRegistrar.cs`

### [UI]

- [x] T015 [UI] Add analytics DTO types mirroring the four API response shapes (`TGoalAnalyticsDto`, `TSkillAnalyticsDto`, history sub-types) — `source/cpr-ui/src/dtos/analytics.dtos.ts`
- [x] T016 [UI] Add analytics domain model types (`IGoalAnalytics`, `ISkillAnalytics`, `ISkillRow`, `IGapClosureSummary`) and `EAnalyticsPeriod` enum — `source/cpr-ui/src/models/analytics.models.ts`
- [x] T017 [UI] Add `analyticsMapper` pure functions mapping DTOs to domain models — `source/cpr-ui/src/mappers/analyticsMapper.ts`
- [x] T018 [UI] Add `analyticsApiService` with `getMyGoalAnalytics`, `getMySkillAnalytics`, `getEmployeeGoalAnalytics`, `getEmployeeSkillAnalytics` — `source/cpr-ui/src/services/api/analyticsApiService.ts`
- [x] T019 [UI] Add `useMyGoalAnalytics` and `useMySkillAnalytics` React Query hooks (for personal analytics page) — `source/cpr-ui/src/hooks/useAnalytics.ts`
- [x] T020 [UI] Add `useEmployeeGoalAnalytics` and `useEmployeeSkillAnalytics` React Query hooks (for team member tab) — `source/cpr-ui/src/hooks/useEmployeeAnalytics.ts`
- [x] T021 [UI] Add MSW handlers for all four analytics endpoints (personal + employee-scoped, with period variants) — `source/cpr-ui/src/mocks/handlers/analyticsHandlers.ts`
- [x] T022 [UI] Register analytics handlers in the mock index — `source/cpr-ui/src/mocks/handlers/index.ts`
- [x] T023 [UI] Add `TimeRangeSelectorProps` component (MUI `ToggleButtonGroup`, 5 presets, syncs with URL `?period=` query param) — `source/cpr-ui/src/components/analytics/TimeRangeSelector.tsx`
- [x] T024 [UI] Add `GoalStatCards` component (six stat cards: Total Goals, Created, Completed, Avg Days, Overdue, Completion Rate) with loading skeletons and empty state — `source/cpr-ui/src/components/analytics/GoalStatCards.tsx`
- [x] T025 [UI] Add `GoalCompletionTrendChart` component (Recharts bar chart, monthly buckets, two series: Created/Completed) — `source/cpr-ui/src/components/analytics/GoalCompletionTrendChart.tsx`
- [x] T026 [UI] Add `GoalsByStatusChart` component (Recharts donut/pie chart for open/in_progress/completed distribution) — `source/cpr-ui/src/components/analytics/GoalsByStatusChart.tsx`
- [x] T027 [UI] Add `GapClosureSummaryCard` component (skills assessed, with gaps, closed, worsened, avg gap start/end) — `source/cpr-ui/src/components/analytics/GapClosureSummaryCard.tsx`
- [x] T028 [UI] Add `SkillHistorySparkline` component (compact Recharts `LineChart`, self series solid, manager series dashed, required level reference line, gap colour coding) — `source/cpr-ui/src/components/analytics/SkillHistorySparkline.tsx`
- [x] T029 [UI] Add `SkillProgressionList` component (list of skill rows with `SkillHistorySparkline`, empty state) — `source/cpr-ui/src/components/analytics/SkillProgressionList.tsx`
- [x] T030 [UI] Add `AnalyticsContent` shared component composing `TimeRangeSelector`, Goals section, and Skill Progression section; accepts `employeeId` prop (undefined = personal view) — `source/cpr-ui/src/components/analytics/AnalyticsContent.tsx`
- [x] T031 [UI] Add `AnalyticsPage` (route `/analytics`): wraps `AnalyticsContent` with personal scope — `source/cpr-ui/src/pages/analytics/AnalyticsPage.tsx`
- [x] T032 [UI] Add `AnalyticsTabSection` for the Team Member Dashboard: wraps `AnalyticsContent` scoped to `employeeId`; RBAC-gates rendering (PeopleManager/Director/Administrator only) — `source/cpr-ui/src/pages/team/components/AnalyticsTabSection.tsx`
- [x] T033 [UI] Update `TeamMemberDashboardPage` to add the "Analytics" tab using MUI `Tabs`/`Tab`, rendering `AnalyticsTabSection`; tab is omitted for Employee/SolutionOwner roles — `source/cpr-ui/src/pages/team/TeamMemberDashboardPage.tsx`
- [x] T034 [UI] Register the `analytics` route (`/analytics`) in the app router — `source/cpr-ui/src/routes/index.tsx`
- [x] T035 [UI] Add "Analytics" nav item to the sidebar navigation component — `source/cpr-ui/src/components/layout/Sidebar.tsx`
- [x] T036 [UI] Add analytics i18n keys for all UI strings and error keys — `source/cpr-ui/public/locales/en/translation.json`

### [Test]

- [x] T037 [Test] Unit tests for `AnalyticsService` — period resolution, goal stat computation, gap computation, PeopleManager RBAC enforcement, 403 for non-direct-report, empty-data edge cases — `source/cpr-api/tests/CPR.UnitTests/AnalyticsServiceTests.cs`
- [x] T038 [Test] Integration tests for all four analytics endpoints — 200 happy paths, 400 invalid period, 401 unauthenticated, 403 wrong role, 404 employee not found — `source/cpr-api/tests/CPR.IntegrationTests/AnalyticsControllerTests.cs`
- [x] T039 [Test] Unit tests for `analyticsMapper` (DTO → model mapping, null-field handling, gap colour derivation) — `source/cpr-ui/src/tests/services/analyticsMapper.test.ts`
- [x] T040 [Test] Component tests for `TimeRangeSelector` — default preset rendered, selection fires callback, URL `?period=` param updated — `source/cpr-ui/src/tests/components/analytics/TimeRangeSelector.test.tsx`
- [x] T041 [Test] Component tests for `GoalStatCards` — populated data, empty state ("0"/"—"), loading skeletons — `source/cpr-ui/src/tests/components/analytics/GoalStatCards.test.tsx`
- [x] T042 [Test] Component tests for `SkillProgressionList` — populated rows, empty state message, gap colour coding applied correctly — `source/cpr-ui/src/tests/components/analytics/SkillProgressionList.test.tsx`
- [x] T043 [Test] Page-level test for `AnalyticsPage` with MSW: personal analytics loads, period change triggers new requests, URL param preserved on reload — `source/cpr-ui/src/tests/components/analytics/AnalyticsPage.test.tsx`
- [x] T044 [Test] Component test for `AnalyticsTabSection` — tab visible for PeopleManager/Director/Administrator, hidden for Employee/SolutionOwner, 403 shows inline error card — `source/cpr-ui/src/tests/components/analytics/AnalyticsTabSection.test.tsx`

---

## Rationale

**Migration before domain/infra**: `employee_skill_history` must exist in the DB before any entity or repository references it; the migration is therefore the first task.

**History write in `SkillAssessmentService` (T006)**: The existing service already owns the write path for `employee_to_skill`; augmenting it to also insert a history snapshot on create/update co-locates the business invariant (AC-027–029) with the mutation that triggers it, avoiding a separate event-dispatch mechanism and keeping the feature self-contained.

**`AnalyticsPeriod` helper before DTOs (T007 before T008–T009)**: Both response DTOs embed `period_start`/`period_end` fields derived from the period enum; the resolver must exist before the DTOs and service are written.

**Shared `AnalyticsContent` component (T030) before the page and tab (T031–T033)**: The personal page and the team-member tab both render identical Goals and Skill Progression sections with only a scope difference (`employeeId` prop); extracting the shared component first eliminates duplication and keeps both consumers thin.

**Tab refactor of `TeamMemberDashboardPage` (T033) after `AnalyticsTabSection` (T032)**: The existing page uses collapsible `Paper` sections; T033 converts it to an MUI `Tabs`/`Tab` layout. Completing `AnalyticsTabSection` first means the tab content exists before the surrounding tab shell is wired up.
