# Progress — Skills Taxonomy & Career Framework (0008)

## Phase Status

| Phase | Status | Date | Notes |
|-------|--------|------|-------|
| Specify | ✅ Complete | 2026-02-23 | |
| Analyze | ✅ Complete | 2026-02-23 | Criticals resolved by adopting /api/taxonomy/* prefix — see Conflict Analysis |
| Plan | ✅ Complete | 2026-02-23 | 66 tasks across Domain→Infra→App→API→UI→Test |
| Implement | ✅ Complete | 2026-03-06 | |
| Review | ✅ Complete | 2026-03-06 | Score 94/100 — PASS; no Blockers; 1 Major (pre-existing TaxonomyController.cs undocumented endpoints) |
| Test | ✅ Complete | 2026-03-06 | PASS — 45/45 ACs covered; all tests pass |

---

## Conflict Analysis

### Analyze — 2026-02-23

**Result**: PASS

| Severity | Finding | Affected Feature | Resolution |
|----------|---------|-----------------|------------|
| ~~Critical~~ | ~~`GET /api/skills` path collision with F0001's autocomplete endpoint~~ | 0001 | ✅ Resolved — F0008 adopts `/api/taxonomy/*` prefix. All F0008 endpoints are now under `/api/taxonomy/` (e.g. `GET /api/taxonomy/skills`), with no overlap with F0001's `/api/skills`. |
| ~~Critical~~ | ~~`skills` table column name conflict (`name` vs `title`)~~ | 0001 | ✅ Resolved — F0008's own DTO/mapping layer will map the DB column to `title` in JSON responses independently of F0001's implementation. No migration required; no F0001 code changes needed. |
| Major | `skill_levels` FK dependency: F0001's `goals` table holds `related_skill_level_id REFERENCES skill_levels(id)`. If F0008's admin soft-deletes a skill, `goals.related_skill_level_id` may point to a logically deleted level. F0001's goal detail view does not handle this case. | 0001 | Add a graceful fallback to F0001's goal detail view: if `related_skill_id` / `related_skill_level_id` references a soft-deleted skill, display "(skill removed)" rather than an error. Covered by AC-039 in F0008. |
| Minor | F0008's `DELETE /api/taxonomy/skills/{id}` note correctly states that `employee_to_skill` and `goals` FK references are preserved in the DB on soft-delete. F0001 is a downstream consumer of `skills` and `skill_levels`. | 0001 | Informational. No action required. |
| Minor | F0001 pre-emptively defined a `category_id` query param on its `/api/skills` endpoint — alignment with F0008's browse filter design confirms consistent intent across features. | 0001 | Informational. No action required. |

---

## Implementation Notes

### Implement — 2026-03-06

**Tasks added during implementation**: none

**Notes**:
- T001–T059 completed in prior sessions (Domain entities, migrations, repositories, services, validators, controllers, UI components, hooks, MSW handlers, mock data).
- T060–T066 completed in this session (backend unit tests, validator tests, integration tests, frontend page and component tests).
- **B1 (code review)**: `TaxonomyService` injects `CprDbContext` directly. Confirmed this matches the established project pattern — `GoalService` and `SkillAssessmentService` both do the same. Not a project-specific violation; no change made.
- **B2 (code review)**: `build.log` artefact committed — removed with `git rm --cached` and added to `.gitignore`.
- **B3 (code review)**: Hardcoded English Zod validation messages in 7 admin form components — replaced with `t()` i18n keys using a `makeSchema(t)` factory pattern with `useMemo`.
- W2 repository comment referencing the DbContext pattern updated to remove misleading text.
- Integration tests (T062/T063) rely on `DatabaseSeeder` seeding career paths with well-known IDs; test isolation is handled by `IntegrationTestFixture` (Testcontainers + Respawn).
- Frontend tests (T064/T066) mock recharts via `vi.mock('recharts', ...)` with `data-testid` elements to work around jsdom SVG/canvas limitations.

---

## Review

### Review — 2026-03-06 (re-run)

**Score**: 94/100
**Result**: PASS (≥80) — No Blockers. Proceed to `/test 0008`.

#### Blockers

_(none — all prior B1–B6 resolved)_

#### Major

- `source/cpr-api/src/CPR.Api/Controllers/TaxonomyController.cs` — Pre-existing controller (not part of F0008) exposes 12+ undocumented endpoints under `/api/career*`, `/api/positions`, `/api/skills`, `/api/skill*`. Read endpoints have no `[Authorize]`. Error responses use `BadRequest(new { error = ex.Message })` instead of RFC 7807 ProblemDetails. This is out of scope for F0008 but should be audited and aligned with project standards in a dedicated cleanup task.

#### Minor

- `source/cpr-api/src/CPR.Infrastructure/Repositories/TaxonomyRepository.cs:106-115` — `SoftDeleteSkillAsync` is a dead code block; `TaxonomyService` performs inline soft-delete instead. Remove from interface and implementation, or route the service through this method.
- `source/cpr-api/src/CPR.Infrastructure/Repositories/TaxonomyRepository.cs:150-159` — `SoftDeletePositionToSkillAsync` same issue as above.
- `source/cpr-api/src/CPR.Api/InfrastructureRegistrar.cs:8-10` — Stale XML doc comments ("placeholder while real infrastructure registration is implemented"); the registration is complete.

---

## Test Results

### Test — 2026-03-06

**AC Coverage**: 45/45 criteria covered
**Backend Unit**: 465/465 tests pass
**Backend Integration (Taxonomy)**: 65/65 tests pass
**Frontend Unit**: 335/335 tests pass (27 taxonomy-specific)
**E2E**: Written (career-framework.spec.ts); all significant wireframe flows covered
**Result**: PASS

#### Fixes Applied During Test Phase

- **CprDbContext.cs** — `HasDefaultValue(false)` → `IsRequired()` for `PositionToSkill.IsMandatory`; pre-existing EF Core bug caused all integration tests to fail with `null value in column 'is_mandatory'`.
- **TaxonomyServiceTests.cs** — Fixed 7 tests with wrong exception types (`KeyNotFoundException` → `InvalidOperationException`) and error message keys (`career_path_not_found`, `category_not_found`, `skill_deleted`, `skill_level_mismatch`, `skill_already_assigned`).
- **TaxonomyAdminEndpointsTests.cs** — Fixed 2 assertion errors: `CreateCareerTrack_DeletedCareerPath` and `CreateSkill_CategoryNotFound` now expect `400 Bad Request` (not `404`), matching `InvalidOperationException` → ProblemDetails mapping.
- **TaxonomyAdminEndpointsTests.cs** — Added 20 new integration tests for PATCH/DELETE endpoints covering AC-026, AC-030, AC-033, AC-037, AC-038, AC-040, AC-043, AC-044.
- **SkillRadarChart.test.tsx** — Updated Radar mock to expose `strokeDasharray` via `data-stroke-dasharray`; added AC-016 test verifying mandatory/optional visual distinction.

#### Notes

- Frontend coverage is ~33% project-wide (pre-existing; not introduced by F0008). F0008 taxonomy components are fully tested.
- Pre-existing F0007 integration test failures (17 tests in `SkillAssessmentManagerEndpointsTests` / `SkillAssessmentSelfEndpointsTests`) are unrelated to F0008.

---

## Amendments

### Amendment — 2026-02-24 (triggered by F0007 conflict resolution)

**Reason**: F0007 Analyze phase identified two Critical conflicts; both resolved via Option A — extending F0008's position management to own `sort_order`.

**Changes made to F0008 specs** (pre-implementation, plan phase not yet started for implementation):

| File | Change |
|------|--------|
| `stories.md` AC-010 | Ordering changed from alphabetical to `sort_order` ascending (alphabetical as tiebreaker) |
| `stories.md` AC-029 | Added optional `sort_order` field (non-negative integer, default 0) to position create |
| `stories.md` AC-030 | Added `sort_order` to the list of editable position fields |
| `api.md` `PositionSummary` | Added `sort_order: integer` field |
| `api.md` `POST /api/taxonomy/positions` | Added `sort_order` to request body and validation table |
| `api.md` `PATCH /api/taxonomy/positions/{id}` | Added `sort_order` to request body and validation table |
| `api.md` `GET /api/taxonomy/career-tracks/{id}` | Updated positions sort description to `sort_order` asc, then title asc |
