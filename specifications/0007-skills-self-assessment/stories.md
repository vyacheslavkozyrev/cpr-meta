# User Stories — Skills Self-Assessment (0007)

## Out of Scope

The following are explicitly **not** part of this feature:

- Manager-initiated assessments (a manager setting skill levels on behalf of another employee)
- Peer skill assessments (source = 'peer' entries are owned by other features)
- Assessment approval or sign-off workflow (no manager confirmation step in this feature)
- Notifications when an assessment is submitted or changed
- Historical timeline of skill level changes (only the latest assessment per skill is retained)
- Bulk export of skill assessment data
- Skill gap recommendations or learning resource suggestions
- Side-by-side comparison of multiple employees' assessments
- Assessing skills that are not required by the user's current position
- Assigning or changing a user's position from this screen
- **Target skill level** — the concept of setting a target level is removed; `employee_to_skill.is_target` and `source` columns do not exist in the schema (dropped by feature 0010). Target endpoints are not implemented.

---

## Stories

### US-001: View Skill Self-Assessment Dashboard

**As an** authenticated user (any role)
**I want to** see all skills required by my current position alongside my self-assessed values
**So that** I have a clear overview of where I stand against my role's expectations

#### Acceptance Criteria

- [ ] AC-001: The page header displays the user's current position title, career track, and career path.
- [ ] AC-002: All skills required by the current position (via `position_to_skill`) are listed and grouped by `skill_category`.
- [ ] AC-003: Each skill row displays: skill title, skill description, required proficiency level title for the current position, and the user's current self-assessment value (or "Not assessed").
- [ ] AC-004: The page is accessible to all authenticated roles.

---

### US-002: Self-Assess Current Skill Level

**As an** authenticated user (any role)
**I want to** record a numeric self-assessment value for each skill required by my position
**So that** I have an accurate self-portrait of my skills for career development planning

#### Acceptance Criteria

- [ ] AC-005: For each required skill, a numeric input field (type=number, min=0, step=0.1) is displayed in the "My Weight" column.
- [ ] AC-006: Typing a value and leaving the field (blur) immediately auto-saves the choice — no separate submit button is required.
- [ ] AC-007: The saved record is written to `employee_to_skill` with `self_assessment_value` populated; no `source` or `is_target` columns are written (those columns do not exist).
- [ ] AC-008: If an assessment record already exists for the skill, it is updated in place (upsert); no duplicate record is created. The unique constraint is `(employee_id, skill_id) WHERE is_deleted = FALSE`.
- [ ] AC-009: A notes text field (max 1,000 characters) is available alongside each skill input; the note auto-saves on field blur.

---

### US-003: ~~Set Target Skill Level~~ — REMOVED

> **Dropped by feature 0010.** The `is_target` and `source` columns that underpinned this story have been removed from `employee_to_skill`. The target-level endpoints (`PUT` and `DELETE /api/me/skill-assessment/skills/{skillId}/target`) are not implemented and return `404`.
>
> The AC-010–AC-013 acceptance criteria below are **out of scope** and must not be implemented.

~~AC-010, AC-011, AC-012, AC-013 — removed. See 0007 progress.md Amendment 2026-03-10.~~

---

### US-004: View Radar Chart

**As an** authenticated user (any role)
**I want to** see a radar/spider chart comparing my self-assessed values against my current and next position requirements
**So that** I can visually understand my skill gaps and progression path

#### Acceptance Criteria

- [ ] AC-014: A radar/spider chart renders on the assessment page with two labeled datasets:
  - **Dataset 1** (primary colour, solid): user's current `self_assessment_value` per skill (0 if not assessed).
  - **Dataset 2** (grey, dashed): required proficiency values for the next position in the career track (determined by the next higher `sort_order` in the same `career_track_id`).
- [ ] AC-015: If the user has no next position in their track (they hold the highest `sort_order`), Dataset 2 is omitted and a note "You are at the highest position in your track" appears near the chart.
- [ ] AC-016: Each chart axis corresponds to one skill required by the current position; axis labels show the skill title.
- [ ] AC-017: The chart updates in real-time as the user changes their self-assessed value without a page reload.

---

### US-005: Link Received Feedback as Evidence

**As an** authenticated user (any role)
**I want to** attach feedback I have received as evidence supporting my skill self-assessment
**So that** my self-rating is backed by external observations

#### Acceptance Criteria

- [ ] AC-018: For each skill, a "Link feedback" action opens a modal listing feedback items the current user has received (`to_employee_id = current employee`), showing sender name, rating, and a content excerpt.
- [ ] AC-019: The user can select one or more feedback items and attach them as evidence; each link is stored in `employee_skill_evidence`.
- [ ] AC-020: Feedback items already linked to the current skill are visually marked as selected in the modal and cannot be linked twice.
- [ ] AC-021: Attached feedback items are displayed below the skill row showing sender display name, star rating, and a truncated content excerpt (max 200 characters).
- [ ] AC-022: A "Remove" action on an evidence item unlinks it from the skill assessment (deletes the `employee_skill_evidence` record).

---

### US-006: PeopleManager Views Direct Reports' Assessments

**As a** PeopleManager
**I want to** see my direct reports' skill self-assessments
**So that** I can identify skill gaps and coaching opportunities across my team

#### Acceptance Criteria

- [ ] AC-023: A PeopleManager can navigate to a team skill overview page listing all direct reports (employees where `manager_id = current employee id`) with a summary row per person: name, position, count of assessed skills, and count of skills meeting the required level.
- [ ] AC-024: Clicking a direct report opens their full assessment page in **read-only** mode (no numeric inputs, no save actions, no "Link feedback" action).
- [ ] AC-025: The read-only view shows the radar chart, all self-assessment values with notes, and all linked feedback evidence items.

---

### US-007: Director and Administrator View Any Employee's Assessment

**As a** Director or Administrator
**I want to** view any employee's skill self-assessment
**So that** I can support organisation-level talent and succession decisions

#### Acceptance Criteria

- [ ] AC-026: A Director or Administrator can access any employee's skill assessment page in read-only mode via that employee's profile.
- [ ] AC-027: The read-only view is identical in layout and content to the manager read-only view (AC-024–AC-025).
