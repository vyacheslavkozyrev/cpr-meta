# User Stories — Performance Analytics & Reporting (0014)

## Out of Scope

The following are explicitly **not** part of this feature:

- Feedback score analytics (deferred — no trend charts for feedback ratings or volumes)
- Data export to CSV or PDF (deferred to a future feature)
- Team-level or org-level aggregate analytics views (covered by F015 — Manager Analytics Dashboard)
- Custom date-range picker (only fixed presets are supported)
- Predictive analytics or retention-risk scoring (F019)
- AI-generated insights or commentary on analytics data (F016/F017)
- Notifications triggered by analytics thresholds

---

## Stories

### US-001: Analytics Page in Navigation

**As an** authenticated user (any role)
**I want to** access a dedicated Analytics page from the left navigation sidebar
**So that** I can navigate directly to my historical performance data

#### Acceptance Criteria

- [x] AC-001: An "Analytics" navigation item appears in the left sidebar for all authenticated users (Employee, PeopleManager, Director, SolutionOwner, Administrator).
- [x] AC-002: Clicking the "Analytics" nav item routes to `/analytics`.
- [x] AC-003: The `/analytics` page has two scrollable sections: "Goals" and "Skill Progression".
- [x] AC-004: The page displays the authenticated user's own analytics data by default.

---

### US-002: Personal Goal Analytics

**As an** authenticated user (any role)
**I want to** view analytics on my goals for a selected time period
**So that** I have data-driven evidence to support my performance review and understand my goal completion trends

#### Acceptance Criteria

- [x] AC-005: The Goals section displays five stat cards: "Total Goals" (all non-deleted goals), "Created in Period", "Completed in Period", "Avg Days to Complete" (for goals completed in the period, rounded to 1 decimal), and "Overdue Goals" (deadline past and not completed at query time).
- [x] AC-006: The Goals section displays a "Completion Trend" bar chart showing monthly buckets within the selected period; each bucket shows the number of goals created and completed that month.
- [x] AC-007: The Goals section displays a "Goals by Status" donut chart showing the current distribution of all non-deleted goals across statuses: open, in_progress, completed.
- [x] AC-008: "Completion Rate" is computed as `completed_in_period / created_in_period` and displayed as a percentage stat card; when `created_in_period` is 0 the card displays "—".
- [x] AC-009: When the user has no goals, all stat cards display "0" or "—" and both charts display an empty-state message: "No goal data for this period".

---

### US-003: Personal Skill Progression Analytics

**As an** authenticated user (any role)
**I want to** view how my skill assessment values have changed over time and how my skill gaps are closing
**So that** I can track my development progress and identify skills that need more focus

#### Acceptance Criteria

- [x] AC-010: The Skill Progression section lists every skill the user has assessed (rows in `employee_to_skill`), showing: skill name, category, current self-assessment value, current manager assessment value (or "—" if none), required level for the employee's current position (or "—" if none), and computed gap (`required_level_value - self_assessment_value`; "—" if no requirement).
- [x] AC-011: For each skill, a sparkline chart plots `self_assessment_value` history data points (from `employee_skill_history`) within the selected period; if no history exists within the period the sparkline shows a flat line at the current value.
- [x] AC-012: If `manager_assessment_value` history exists for a skill within the period, the sparkline also plots manager assessment data points as a second series.
- [x] AC-013: A "Gap Closure Summary" card at the top of the section displays: total skills assessed, skills with open gaps (gap > 0), gaps closed within the period (gap was > 0 at start and is 0 or negative now), gaps worsened within the period, and average gap at start vs end of period.
- [x] AC-014: When the user has no skill assessments, the Skill Progression section displays an empty-state message: "No skill assessment data available".

---

### US-004: Team Member Analytics Tab

**As a** PeopleManager, Director, or Administrator
**I want to** view an Analytics tab on the Team Member Dashboard for a specific employee
**So that** I can review their historical goal completion and skill progression data alongside their other information

#### Acceptance Criteria

- [x] AC-015: The Team Member Dashboard page (`/team/:employeeId`) has a new "Analytics" tab visible to PeopleManager, Director, and Administrator roles.
- [x] AC-016: The Analytics tab renders the same Goals and Skill Progression sections as the personal Analytics page, but scoped to the viewed employee.
- [x] AC-017: The Analytics tab includes the time range selector with the same 5 presets.
- [x] AC-018: A PeopleManager can only view the Analytics tab for their own direct reports; the employee analytics API endpoints return 403 for any employee who is not a direct report of the requesting manager.
- [x] AC-019: A Director and Administrator can access the Analytics tab for any employee.
- [x] AC-020: The "Analytics" tab is not visible to Employee or SolutionOwner roles on the Team Member Dashboard.

---

### US-005: Time Range Selection

**As an** authenticated user (any role)
**I want to** select a fixed time range preset for analytics
**So that** I can focus on the period most relevant to my current goals or review cycle

#### Acceptance Criteria

- [x] AC-021: A time range selector is displayed at the top of every analytics view (personal and team-member tab) with five options: "Last 30 Days", "Last 90 Days", "Last 180 Days", "Last Quarter", "Last Year".
- [x] AC-022: The default selected preset is "Last 90 Days".
- [x] AC-023: Selecting a different preset immediately triggers new API requests and updates all charts and stat cards without a full page reload.
- [x] AC-024: The selected period is preserved in the URL query string as `?period=<value>` (e.g. `?period=last_90_days`) and is restored correctly on page reload or when the URL is shared.
- [x] AC-025: The API endpoints accept `period` with values `last_30_days`, `last_90_days`, `last_180_days`, `last_quarter`, `last_year`; default is `last_90_days` when the parameter is absent.
- [x] AC-026: The API returns HTTP 400 with error key `errors.analytics.invalid_period` when an unrecognised `period` value is supplied.

---

### US-006: Skill Assessment History Recording

**As** the system
**I want to** record a history snapshot every time an employee's skill assessment values change
**So that** analytics can show accurate progression over time

#### Acceptance Criteria

- [x] AC-027: When an `employee_to_skill` row is first created, a corresponding row is inserted into `employee_skill_history` capturing the initial `self_assessment_value`, `manager_assessment_value`, and `recorded_at = CURRENT_TIMESTAMP`.
- [x] AC-028: When `self_assessment_value` on an existing `employee_to_skill` row is updated, a new `employee_skill_history` row is inserted with the updated values and `recorded_at = CURRENT_TIMESTAMP`.
- [x] AC-029: When `manager_assessment_value` on an existing `employee_to_skill` row is updated, a new `employee_skill_history` row is inserted with the updated values and `recorded_at = CURRENT_TIMESTAMP`.
- [x] AC-030: `employee_skill_history` rows are never modified or deleted (neither soft nor hard); they form an immutable audit trail.
