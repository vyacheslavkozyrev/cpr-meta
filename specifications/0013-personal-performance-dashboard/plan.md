# Implementation Plan — Personal Performance Dashboard (0013)

> **Prerequisite**: F0010 migration (`self_assessment_value` column present on `employee_to_skill`,
> `source` and `is_target` columns dropped) must be applied before running these tasks.
> The `level` field in `recent_assessments` is sourced from `employee_to_skill.self_assessment_value`.

## Tasks

### Backend — Infrastructure

- [x] T001 [Infra] Fix `GetFeedbackSummaryAsync` — replace INNER JOIN on Goals with a LEFT JOIN so feedback items where `goal_id` is null are included in `recent_feedback` (returns `null` for `goal_title`) — `source/cpr-api/src/CPR.Infrastructure/Services/DashboardService.cs`
- [x] T002 [Infra] Fix `GetActivityFeedAsync` — replace INNER JOIN on Goals with a LEFT JOIN for `feedback_received` activity items so feedback without a linked goal appears in the activity feed — `source/cpr-api/src/CPR.Infrastructure/Services/DashboardService.cs`

### Frontend — Service & Mock Layer

- [x] T003 [UI] Fix envelope pattern in `dashboardService.ts` — **SKIPPED**: `apiClient` puts raw JSON body into `response.data` directly; no nested envelope exists in this codebase. Current code is correct. — change all 5 `apiClient.get<TDto>()` calls to `apiClient.get<{ data: TDto }>()` and update each `response.data` read to `response.data.data` — `source/cpr-ui/src/services/api/dashboardService.ts`
- [x] T004 [UI] Update `dashboardHandlers.ts` — wrap all 5 mock response bodies in `{ data: <payload>, success: true, message: "OK" }` envelope AND remove phantom fields (`assessorName`, `category`, `categoryId`) from `generateMockSkillsSummary` `recentAssessments` items — `source/cpr-ui/src/mocks/handlers/dashboardHandlers.ts`

### Frontend — Components & Pages

- [x] T005 [UI] Wire `useDashboardSummary` in `DashboardPage.tsx` — remove hardcoded `userStats` object, call `useDashboardSummary()`, map `summary.goals.completed`, `summary.feedback.total_received`, `summary.skills.assessed_skills` to the three `UserStatisticsCards` props — `source/cpr-ui/src/pages/dashboard/DashboardPage.tsx`
- [x] T006 [UI] Fix hardcoded "Activity Feed" title in `ActivityFeedWidget.tsx` — replace `Activity Feed` string literal at line 405 with `{t('dashboard.widgets.activityFeed')}` (key already exists in all locale files) — `source/cpr-ui/src/components/dashboard/widgets/ActivityFeedWidget.tsx`

### Tests — Backend

- [x] T007 [Test] Update `DashboardServiceTests.cs` — add unit test cases verifying that `GetFeedbackSummaryAsync` and `GetActivityFeedAsync` include feedback items where `goal_id` is null — `source/cpr-api/tests/CPR.UnitTests/DashboardServiceTests.cs`
- [x] T008 [Test] Update `DashboardControllerTests.cs` — add integration test for `GET /api/dashboard/feedback-summary` and `GET /api/dashboard/activity` confirming feedback with null `goal_id` is present in the response — `source/cpr-api/tests/CPR.IntegrationTests/DashboardControllerTests.cs`

### Tests — Frontend

- [x] T009 [Test] Create `DashboardPage.test.tsx` — verify stat cards receive live API data (mock returns via MSW envelope), not hardcoded values; cover loading skeleton and error state — `source/cpr-ui/src/pages/dashboard/DashboardPage.test.tsx`
- [x] T010 [Test] Update `FeedbackSummaryWidget.test.tsx` — verify that a feedback item with `goal_title: null` renders the "No linked goal" label (not blank or excluded) — `source/cpr-ui/src/tests/components/dashboard/FeedbackSummaryWidget.test.tsx`
- [x] T011 [Test] Update `ActivityFeedWidget.test.tsx` — verify widget title renders from i18n key (`dashboard.widgets.activityFeed`), not hardcoded; verify empty-state message renders when feed is empty — `source/cpr-ui/src/tests/components/dashboard/ActivityFeedWidget.test.tsx`

---

## Rationale

Tasks are ordered back-to-front: backend LEFT JOIN fixes (T001–T002) must land before frontend tests can assert the correct API behaviour against integration tests. The service-layer envelope fix (T003) must precede the MSW handler update (T004) so that mock and real API responses share the same shape when the page component is updated (T005). T006 is a one-line UI-only fix with no dependencies on the other tasks and can be done at any point in the UI layer. All test tasks (T007–T011) come last and depend on the implementation tasks in their respective layers being complete. No migration is needed — this feature adds no new tables or columns.

---

## Layer Tags

| Tag | Scope |
|-----|-------|
| `[Infra]` | DashboardService bug fixes (LEFT JOIN) |
| `[UI]` | dashboardService envelope, MSW handlers, DashboardPage wiring, ActivityFeedWidget i18n |
| `[Test]` | Backend unit + integration tests; frontend component tests |
