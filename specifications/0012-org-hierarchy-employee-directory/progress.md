# Progress — Org Hierarchy & Employee Directory (0012)

## Phase Status

| Phase | Status | Date | Notes |
|-------|--------|------|-------|
| Specify | ✅ Complete | 2026-04-07 | |
| Analyze | ✅ Complete | 2026-04-09 | PASS — all conflicts resolved; see Conflict Analysis |
| Plan | ✅ Complete | 2026-04-09 | |
| Implement | ⏳ Pending | | |
| Review | ⏳ Pending | | |
| Test | ⏳ Pending | | |

---

## Conflict Analysis

### Analyze — 2026-04-09

**Result**: PASS (after spec amendments — 2026-04-09)

| Severity | Finding | Affected Feature | Resolution |
|----------|---------|-----------------|------------|
| Critical | **`EmployeeSummaryDto` shape collision** with `FeedbackDtos.cs` (0004/0005). | 0004, 0005 | **Resolved (b)**: 0012 uses a distinct DTO family (`OrgNodeDto`, `EmployeeProfileDto`). Existing `EmployeeSummaryDto` in 0004/0005 untouched. |
| Critical | **`GET /api/employees` — functional overlap with `GET /api/employees/search` (0004).** | 0004 | **Resolved**: `GET /api/employees` removed from 0012 scope. This feature's new endpoints are `GET /api/org-chart` and `GET /api/org-chart/{employee_id}`. Employee search/listing remains owned by 0004. |
| Major | **`users.email` migration load-bearing for 0004/0005.** | 0004, 0005 | **Resolved**: `email` column removed from 0012 schema migration and API responses. `users` table stays minimal. Org chart displays `display_name` + `position_title` only. |
| Major | **Route constraint ambiguity: `GET /api/employees/{id}` vs `direct-reports` literal.** | 0004 | **Resolved**: `GET /api/employees/{id}` removed from 0012 scope. Conflict no longer applies. |
| Minor | **`GET /api/employees/{id}/gap-analysis` etc. share `/api/employees/{id}/...` namespace.** | 0009, 0010, 0011 | No action required. |
| Minor | **`locations` table** already exists and is seeded. | — | No action required. |

---

## Implementation Notes

_Populated by `/implement 0012`_

---

## Review

_Populated by `/review 0012`_

---

## Test Results

_Populated by `/test 0012`_

---

## Amendments

### 2026-04-09 — Spec amendments during Analyze

- **api.md**: Removed `GET /api/employees` (paged directory listing) — this feature's API surface is `GET /api/org-chart` and `GET /api/org-chart/{employee_id}` only. Employee search remains owned by 0004.
- **api.md**: Removed `email` field from `GET /api/employees/{id}` response. Org chart/profile shows `display_name` + `position_title`; no email in users table.
- **schema.md**: Removed `email TEXT NULL` column from `0012_AddEmployeeDirectoryFields` migration.
