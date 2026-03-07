# Progress — Skills Taxonomy & Career Framework (0008)

## Phase Status

| Phase | Status | Date | Notes |
|-------|--------|------|-------|
| Specify | ✅ Complete | 2026-02-23 | |
| Analyze | ✅ Complete | 2026-02-23 | Criticals resolved by adopting /api/taxonomy/* prefix — see Conflict Analysis |
| Plan | ✅ Complete | 2026-02-23 | 66 tasks across Domain→Infra→App→API→UI→Test |
| Implement | ✅ Complete | 2026-03-06 | |
| Review | ⏳ Pending | | |
| Test | ⏳ Pending | | |

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

_Populated by `/review 0008`_

---

## Test Results

_Populated by `/test 0008`_

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
