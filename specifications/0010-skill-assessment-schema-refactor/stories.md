# Feature 0010 — Skill Assessment Schema Refactor
## User Stories & Acceptance Criteria

---

## Out of Scope

- Manager assessment **approval workflow** (employee acknowledging or disputing a manager's rating) — deferred to a later feature.
- **Historical versioning UI** for assessment changes over time (`effective_date` column is retained in the DB but no version-history screen is in scope).
- **Bulk import / export** of assessment values.
- **Deletion** of manager assessment values (only upsert is in scope).
- **Peer assessment** values — only self-assessment and manager assessment are added in this feature.
- Changes to the career taxonomy **Admin screens** beyond removing `weight` from responses.
- Proficiency level dropdown (`skill_level_id` selection) on the self-assessment form — the employee provides only a raw numeric value.

---

## US-001 — Employee views their skill assessment without target level or weight

**As an** Employee,
**I want** the skill assessment page to show only my self-assessment numeric value and required level per skill,
**So that** the UI reflects the simplified data model without legacy target-level or weight concepts.

| # | Acceptance Criterion |
|---|----------------------|
| AC-001 | `GET /api/me/skill-assessment` returns `self_assessment_value` (numeric) in the assessed skill object when an assessment exists. |
| AC-002 | `GET /api/me/skill-assessment` does **not** include a `target_level` field anywhere in the response. |
| AC-003 | `GET /api/me/skill-assessment` does **not** include a `weight` field on any position-skill item. |
| AC-004 | The `/skills` UI page does not render a Target Level column or any target-level controls. |

---

## US-002 — Employee enters a numeric self-assessment value for each skill

**As an** Employee,
**I want** to type a numeric score into an input field for each skill on the /skills page,
**So that** I can record my self-assessed proficiency level as a precise number without selecting from a dropdown.

| # | Acceptance Criterion |
|---|----------------------|
| AC-005 | The `/skills` page "My Weight" column contains only a numeric input field (`type="number"`, min=0, step=0.1) — no proficiency level dropdown. |
| AC-006 | On blur of the numeric field, the row calls `PUT /api/me/skill-assessment/skills/{skillId}` with `{ self_assessment_value, notes }`. |
| AC-007 | If the numeric field is empty or ≤ 0, an inline validation error is shown below the field and no API call is made. |
| AC-008 | After a successful save, a "Saved ✓" indicator appears briefly in the row's actions cell. |
| AC-009 | `PUT /api/me/skill-assessment/skills/{skillId}` accepts `self_assessment_value` (numeric, > 0) and optional `notes`; `skill_level_id` is **not** required. |
| AC-010 | If `self_assessment_value` is missing, zero, or negative, the API returns `400 Bad Request` with a validation detail. |
| AC-011 | A successful `PUT` returns `200 OK` with the updated skill assessment response including `self_assessment_value`. |
| AC-012 | `DELETE /api/me/skill-assessment/skills/{skillId}` removes the row; subsequent `GET` returns `null` for that skill's assessed object. |

---

## US-003 — Employee links feedback as evidence on the /skills form

**As an** Employee,
**I want** to link received feedback items to a skill assessment row,
**So that** I can substantiate my self-assessed level with concrete evidence.

| # | Acceptance Criterion |
|---|----------------------|
| AC-013 | The `/skills` page shows a "Link feedback" button per skill row when an active self-assessment exists for that skill. |
| AC-014 | Clicking "Link feedback" opens the Evidence Modal listing the employee's received feedback items for selection. |
| AC-015 | `POST /api/me/skill-assessment/skills/{skillId}/evidence` accepts `{ "feedback_id": "<uuid>" }` and returns `200 OK`; the linked item appears in the evidence list below the skill row. |
| AC-016 | Linking the same feedback item twice to the same skill returns `409 Conflict`. |
| AC-017 | `DELETE /api/me/skill-assessment/skills/{skillId}/evidence/{feedbackId}` removes the evidence link; the item disappears without page reload. |
| AC-018 | Evidence links are stored in the `employee_skill_evidence` table (FK to `employee_to_skill.id` and FK to `feedback.id`). |
| AC-019 | In read-only mode (manager viewing the employee assessment page), evidence items are displayed but the remove button is hidden. |

---

## US-004 — Target-level endpoints are removed

**As an** Employee or system client,
**I want** the deprecated target-level endpoints to no longer exist,
**So that** clients do not inadvertently use an obsolete API surface.

| # | Acceptance Criterion |
|---|----------------------|
| AC-020 | `PUT /api/me/skill-assessment/skills/{skillId}/target` returns `404 Not Found` (endpoint removed). |
| AC-021 | `DELETE /api/me/skill-assessment/skills/{skillId}/target` returns `404 Not Found` (endpoint removed). |
| AC-022 | The `UpsertSkillTargetDto` and `TargetLevelDto` types are removed from the codebase with no compilation errors. |

---

## US-005 — PeopleManager records a manager assessment for a direct report

**As a** PeopleManager,
**I want** to enter a numeric manager-assessment value for each of my direct reports' skills,
**So that** I can provide an independent proficiency rating alongside the employee's self-assessment.

| # | Acceptance Criterion |
|---|----------------------|
| AC-023 | `PUT /api/employees/{employeeId}/skill-assessment/skills/{skillId}/manager-assessment` accepts `{ "manager_assessment_value": <number> }` and returns `200 OK` with the updated employee skill assessment. |
| AC-024 | Only users with `PeopleManager`, `Director`, or `Administrator` role may call this endpoint; others receive `403 Forbidden`. |
| AC-025 | A `PeopleManager` attempting to assess a non-direct-report receives `403 Forbidden`. |
| AC-026 | `Director` and `Administrator` can assess any employee's skill without restriction. |
| AC-027 | If `manager_assessment_value` is missing, zero, or negative, the API returns `400 Bad Request`. |
| AC-028 | If the skill does not exist or is not required by the employee's position, the API returns `404 Not Found`. |

---

## US-006 — PeopleManager views and sets manager assessments on the employee assessment page

**As a** PeopleManager,
**I want** to see a Manager Assessment column on the employee skill assessment page and enter values there,
**So that** I can record my assessment without leaving the assessment view.

| # | Acceptance Criterion |
|---|----------------------|
| AC-029 | `GET /api/employees/{employeeId}/skill-assessment` returns `manager_assessment_value` (numeric or null) in each skill's assessed object. |
| AC-030 | The `/employees/{employeeId}/skill-assessment` UI page displays a "Manager Assessment" column with a numeric input field (`type="number"`, min=0) per skill row. |
| AC-031 | A PeopleManager can type a numeric value and save on blur (calls `PUT /api/employees/{employeeId}/skill-assessment/skills/{skillId}/manager-assessment`). |
| AC-032 | Employees viewing the page see `manager_assessment_value` as read-only text; no input is rendered. |
| AC-033 | A "Saved ✓" indicator appears briefly after a successful manager assessment save. |

---

## US-007 — Weight column is removed from position_to_skill

**As an** Administrator or API consumer,
**I want** the `weight` column gone from `position_to_skill` and its API responses,
**So that** the schema reflects only meaningful, used data.

| # | Acceptance Criterion |
|---|----------------------|
| AC-034 | The `weight` column does not exist in the `position_to_skill` DB table after migration. |
| AC-035 | No API endpoint (taxonomy or skill assessment) returns a `weight` field on position-skill items. |
| AC-036 | `PATCH /api/taxonomy/positions/{id}/skills/{position_skill_id}` no longer accepts a `weight` field; submitting one is silently ignored. |
