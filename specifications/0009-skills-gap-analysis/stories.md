# User Stories — Skills Gap Analysis & Development Planning (0009)

## Out of Scope

The following are explicitly **not** part of this feature:

- AI-generated development plan recommendations (deferred to F016)
- Manager assigning a target position on behalf of an employee
- Aggregate team-level gap analysis (e.g., "what skills are missing across the whole team")
- Historical gap snapshots — gap is always calculated live
- Gap analysis against positions in a different career track
- Exporting gap analysis to PDF or CSV
- Gap analysis for employees who have no position assigned (system shows an error state; no fallback)
- Filtering the gap view by skill category (all required skills are always shown)

---

## Stories

### US-001: View My Own Skills Gap Analysis

**As an** Employee (or any authenticated user)
**I want to** view a gap analysis comparing my manager-assessed skill values (`manager_assessment_value`) against the requirements of the next level position in my career track
**So that** I know exactly which skills I need to develop to advance to the next level

#### Acceptance Criteria

- [x] AC-001: The gap analysis page is accessible at `/gap-analysis` for the authenticated user's own profile.
- [x] AC-002: The page displays the employee's current position title and career track name at the top of the page.
- [x] AC-003: The next-level position is determined as the position with the next highest `sort_order` value within the same `career_track_id`; its title is displayed alongside the current position.
- [x] AC-004: If the employee has no current position assigned (`position_id` is null on their `employees` row), the page renders an error state with the message key `gap_analysis.no_position_assigned` and no chart or table is shown.
- [x] AC-005: If the employee's current position has the highest `sort_order` in its career track (no higher position exists), the page renders an informational state with message key `gap_analysis.at_highest_level` and no chart or table is shown.

---

### US-002: Visualize Skill Gaps with Chart and Table

**As an** Employee
**I want to** see my skill gaps displayed as both a radar chart and a detailed table
**So that** I can quickly identify the largest gaps at a glance and drill into specifics

#### Acceptance Criteria

- [x] AC-006: A radar/spider chart renders with one axis per required skill of the next-level position, overlaying two series: "Required Level" (from `position_to_skill`) and "Actual Level" (from `employee_to_skill.manager_assessment_value` when non-null; otherwise the position minimum level value).
- [x] AC-007: A skills table renders below the radar chart with the following columns: Skill Name, Category, Required Level, Actual Level, Gap, Mandatory.
- [x] AC-008: Rows where `gap > 0` (actual level value < required level value) are visually highlighted (e.g., warning colour); rows where `gap ≤ 0` display "Met" in the Gap column.
- [x] AC-009: Skills in the table are grouped by skill category, with a non-interactive category header row separating each group.
- [x] AC-010: When `manager_assessment_value` is `NULL` on the employee's `employee_to_skill` row (or no row exists), the Actual Level cell displays the position minimum level title followed by "(default)" and `assessment_source` is `"default"`.

---

### US-003: See Existing Goals Addressing My Gaps

**As an** Employee
**I want to** see which of my existing active goals are already targeting specific skill gaps
**So that** I understand my current development coverage and avoid duplicating effort

#### Acceptance Criteria

- [x] AC-011: For each skill row where `gap > 0`, any non-completed goals whose `related_skill_id` matches that skill's UUID are listed inline below the table row.
- [x] AC-012: Each linked goal displays the goal title and `progress_percent` formatted as a percentage (e.g., "45%").

---

### US-004: Create a Goal Directly from a Skill Gap (Employee)

**As an** Employee
**I want to** create a development goal directly from a skill gap row
**So that** I can quickly start addressing a gap without manually entering skill details

#### Acceptance Criteria

- [x] AC-013: Each skill row where `gap > 0` displays a "Create Goal" button; skill rows where the gap is met display no such button.
- [x] AC-014: Clicking "Create Goal" opens the goal creation modal pre-populated with: `title = "Improve [Skill Name] to [Required Level Title]"`, `related_skill_id` set to the skill's UUID, and `related_skill_level_id` set to the required level's UUID.
- [x] AC-015: On successful goal creation the new goal appears in the linked goals list for that skill row without a full page reload (React Query cache invalidation).
- [x] AC-016: The "Create Goal" button is visible only to Employees viewing their own gap analysis and PeopleManagers viewing a direct report's gap analysis; Directors and Administrators see no "Create Goal" buttons.

---

### US-005: PeopleManager Views a Direct Report's Gap Analysis

**As a** PeopleManager
**I want to** view the gap analysis for any of my direct reports
**So that** I can guide development conversations with factual, skill-level data

#### Acceptance Criteria

- [x] AC-017: A PeopleManager can navigate to `/employees/{id}/gap-analysis` for any employee whose `manager_id` equals the manager's own `employees.id`.
- [x] AC-018: The PeopleManager sees the same radar chart and skills table populated with the direct report's `manager_assessment_value` data, applying the same default-level fallback rule as AC-010.
- [x] AC-019: If the target employee is not a direct report of the requesting PeopleManager, the API returns `403 Forbidden` (`errors.auth.forbidden`).

---

### US-006: PeopleManager Creates a Goal for a Direct Report from a Gap

**As a** PeopleManager
**I want to** create a development goal for a direct report directly from their gap analysis page
**So that** I can proactively assign focused development goals during 1-on-1s or reviews

#### Acceptance Criteria

- [x] AC-020: On a direct report's gap analysis page, the PeopleManager sees "Create Goal" buttons on each skill row with `gap > 0`, identical in appearance to the Employee's own view.
- [x] AC-021: The goal creation form is pre-populated identically to AC-014; on submission, the goal's `employee_id` is set to the direct report's employee UUID (not the manager's).
- [x] AC-022: On successful creation, the new goal appears inline under the relevant skill row in the direct report's gap analysis page.

---

### US-007: Director Views Any Department Employee's Gap Analysis

**As a** Director
**I want to** view the gap analysis for any employee in my department
**So that** I can assess workforce readiness and identify skill gaps across the team

#### Acceptance Criteria

- [x] AC-023: A Director can navigate to `/employees/{id}/gap-analysis` for any employee whose `department_id` matches the Director's own department.
- [x] AC-024: The Director sees the same radar chart and skills table as the employee, with no "Create Goal" buttons (read-only view).
- [x] AC-025: If the target employee is not in the Director's department, the API returns `403 Forbidden` (`errors.auth.forbidden`).

---

### US-008: Administrator Views Any Employee's Gap Analysis

**As an** Administrator
**I want to** view the gap analysis for any employee in the system
**So that** I can audit development planning coverage and support compliance

#### Acceptance Criteria

- [x] AC-026: An Administrator can navigate to `/employees/{id}/gap-analysis` for any employee in the system without restriction.
- [x] AC-027: The Administrator sees the same read-only radar chart and skills table as the Director, with no "Create Goal" buttons.
