# User Stories — 360-Degree Feedback (0006)

## Out of Scope

The following are explicitly **not** part of this feature:

- **Self-assessment** — the subject employee filling in a self-assessment form as part of the cycle (deferred to F0007)
- **Integration with formal performance review cycles** — linking 360 results to official appraisals or performance ratings
- **Calibration sessions** — cross-manager calibration tooling or calibration dashboards
- **Automated scheduling and reminders** — no automatic due dates, email reminders, or notification system
- **Third-party HR system sync** — no HRIS or payroll system integration
- **Bulk cycle creation** — creating 360 cycles for multiple employees at once

---

## Stories

### US-001: Create a 360 Review Cycle

**As a** Director
**I want to** create a 360 review cycle for an employee in my department
**So that** I can initiate a structured multi-source feedback process for them

#### Acceptance Criteria

- [x] AC-001: A Director can POST to create a cycle with a required `title` (1–200 chars), required `subject_employee_id`, and optional `description` (max 2000 chars).
- [x] AC-002: The new cycle is created with status `draft`.
- [x] AC-003: The `subject_employee_id` must belong to an employee in the Director's department; if not, `403 Forbidden` is returned.
- [x] AC-004: Non-Director roles receive `403 Forbidden` when attempting to create a cycle.

---

### US-002: Open a Review Cycle for Nominations

**As a** Director
**I want to** transition a review cycle from `draft` to `open`
**So that** the subject employee and their manager can begin nominating reviewers

#### Acceptance Criteria

- [x] AC-005: A Director can PATCH the cycle status to `open` when it is currently `draft`.
- [x] AC-006: Only a Director can perform status transitions; other roles receive `403 Forbidden`.
- [x] AC-007: Attempting an invalid status transition (e.g., `draft` → `closed`) returns `409 Conflict` with detail `errors.review_cycle.invalid_transition`.
- [x] AC-008: The `opened_at` timestamp is recorded when the cycle transitions to `open`.

---

### US-003: Nominate Peers as Reviewer (Employee)

**As an** Employee
**I want to** nominate peers as reviewers for my own 360 cycle when it is `open`
**So that** relevant colleagues are invited to provide feedback on me

#### Acceptance Criteria

- [x] AC-009: An Employee can POST a nominee to their own cycle when the cycle status is `open`.
- [x] AC-010: The nominee must be an existing, active (non-deleted) employee; otherwise `404 Not Found` is returned.
- [x] AC-011: An employee cannot nominate themselves; attempting to do so returns `422 Unprocessable Entity` with detail `errors.review_nominee.self_nomination`.
- [x] AC-012: Duplicate nominees (same `reviewer_employee_id` on the same cycle) return `409 Conflict` with detail `errors.review_nominee.duplicate`.
- [x] AC-013: Nominations are rejected when the cycle status is not `open`, returning `409 Conflict` with detail `errors.review_cycle.nominations_closed`.

---

### US-004: Nominate Peers as Reviewer (PeopleManager)

**As a** PeopleManager
**I want to** nominate peers as reviewers for a direct report's 360 cycle when it is `open`
**So that** I can ensure comprehensive coverage of relevant reviewers

#### Acceptance Criteria

- [x] AC-014: A PeopleManager can POST a nominee to a direct report's cycle when the cycle status is `open`.
- [x] AC-015: The same uniqueness and self-nomination rules apply as for Employee nominations (AC-011, AC-012, AC-013).
- [x] AC-016: A PeopleManager attempting to add nominees to a cycle for an employee who is not their direct report receives `403 Forbidden`.

---

### US-005: Start the Review (Lock Nominations)

**As a** Director
**I want to** transition a review cycle from `open` to `in_progress`
**So that** nominations are locked and reviewers are formally invited to submit feedback

#### Acceptance Criteria

- [x] AC-017: A Director can PATCH the cycle status to `in_progress` when it is currently `open`.
- [x] AC-018: The cycle must have at least 2 nominees before transitioning to `in_progress`; if not, `422 Unprocessable Entity` is returned with detail `errors.review_cycle.insufficient_nominees`.
- [x] AC-019: After transitioning to `in_progress`, no new nominees can be added; attempts return `409 Conflict` with detail `errors.review_cycle.nominations_closed`.
- [x] AC-020: All nominees' status changes from `pending` to `invited` when the cycle moves to `in_progress`.
- [x] AC-021: The `started_at` timestamp is recorded when the cycle transitions to `in_progress`.

---

### US-006: Submit 360 Feedback as a Reviewer

**As a** Reviewer (any authenticated user nominated for a cycle)
**I want to** submit a rating and comments for the subject employee
**So that** my feedback is captured as part of their 360 review

#### Acceptance Criteria

- [x] AC-022: A nominated reviewer can POST a response to a cycle that is `in_progress`, including an `overall_rating` (integer 1–5) and `comments` (10–2000 characters).
- [x] AC-023: A reviewer can only submit one response per cycle; a second attempt returns `409 Conflict` with detail `errors.review_response.already_submitted`.
- [x] AC-024: A user who is not nominated for the cycle receives `403 Forbidden`.
- [x] AC-025: Responses are rejected when the cycle status is not `in_progress`; returns `409 Conflict` with detail `errors.review_cycle.not_accepting_responses`.
- [x] AC-026: Upon successful submission, the nominee's status is updated from `invited` to `submitted`.

---

### US-007: Close a Review Cycle

**As a** Director
**I want to** close a review cycle (transition from `in_progress` to `closed`)
**So that** results become available for viewing by the subject employee and their manager

#### Acceptance Criteria

- [x] AC-027: A Director can PATCH the cycle status to `closed` when it is currently `in_progress`.
- [x] AC-028: Once `closed`, no new responses can be submitted; attempts return `409 Conflict` with detail `errors.review_cycle.not_accepting_responses`.
- [x] AC-029: The `closed_at` timestamp is recorded when the cycle transitions to `closed`.

---

### US-008: View Own Aggregated 360 Results (Employee)

**As an** Employee
**I want to** view the aggregated and anonymized results of my closed 360 review cycle
**So that** I can understand how peers perceive my performance without knowing individual identities

#### Acceptance Criteria

- [x] AC-030: An Employee can GET aggregated results for their own closed cycle, including: average `overall_rating`, total response count, and an anonymized list of individual comments (without reviewer identity).
- [x] AC-031: Results are only available when cycle status is `closed`; otherwise `409 Conflict` is returned with detail `errors.review_cycle.results_not_available`.
- [x] AC-032: Individual reviewer identities (names, IDs) are never included in the Employee's results response.
- [x] AC-033: An Employee cannot access results for a cycle where they are not the subject; returns `403 Forbidden`.

---

### US-009: View Detailed 360 Results for Direct Report (PeopleManager)

**As a** PeopleManager
**I want to** view the detailed, attributed results of a direct report's closed 360 cycle
**So that** I can support their development with full context of who said what

#### Acceptance Criteria

- [x] AC-034: A PeopleManager can GET detailed results for a direct report's closed cycle, including each reviewer's `display_name`, their `overall_rating`, and their `comments`.
- [x] AC-035: Results are only available when cycle status is `closed`; otherwise `409 Conflict` is returned with detail `errors.review_cycle.results_not_available`.
- [x] AC-036: A PeopleManager cannot access results for a cycle whose subject is not their direct report; returns `403 Forbidden`.

---

### US-010: View Detailed 360 Results for Department Employee (Director)

**As a** Director
**I want to** view the detailed, attributed results of any employee's closed 360 cycle within my department
**So that** I can assess performance with full reviewer context across my department

#### Acceptance Criteria

- [x] AC-037: A Director can GET detailed results for any employee's closed cycle in their department, including each reviewer's `display_name`, `overall_rating`, and `comments`.
- [x] AC-038: Results are only available when cycle status is `closed`; otherwise `409 Conflict` is returned with detail `errors.review_cycle.results_not_available`.
- [x] AC-039: A Director cannot access results for cycles in departments outside their scope; returns `403 Forbidden`.

---

### US-011: List 360 Review Cycles (Director)

**As a** Director
**I want to** list all 360 review cycles for employees in my department
**So that** I can monitor the status of ongoing and past cycles

#### Acceptance Criteria

- [x] AC-040: A Director can GET a paginated list of cycles for their department, with optional filtering by `status`.
- [x] AC-041: Each list item includes: `id`, `title`, `subject_display_name`, `status`, `nominee_count`, `response_count`, `created_at`, `closed_at`.
- [x] AC-042: The list is sorted by `created_at` descending by default.

---

### US-012: List Own 360 Review Cycles (Employee)

**As an** Employee
**I want to** list my own 360 review cycles
**So that** I can track my review history and check cycle statuses

#### Acceptance Criteria

- [x] AC-043: An Employee can GET a paginated list of cycles where they are the subject, with optional filtering by `status`.
- [x] AC-044: Each list item includes: `id`, `title`, `status`, `nominee_count`, `response_count` (reviewer names excluded), `created_at`, `closed_at`.

---

### US-013: List Pending Review Requests (Reviewer)

**As a** nominated Reviewer (any authenticated user)
**I want to** list all 360 review cycles I have been invited to respond to
**So that** I know which feedback submissions are outstanding

#### Acceptance Criteria

- [x] AC-045: Any authenticated user can GET a list of cycles where they are nominated, their nominee status is `invited`, and the cycle status is `in_progress`.
- [x] AC-046: Each item includes: `cycle_id`, `cycle_title`, `subject_display_name` (no PII such as email address), `nominee_status`.
- [x] AC-047: Cycles where the reviewer has already submitted (nominee status = `submitted`) are excluded from this list.
