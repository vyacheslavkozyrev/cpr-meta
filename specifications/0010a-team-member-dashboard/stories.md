# User Stories — Team Member Dashboard (0010a)

## Out of Scope

The following are explicitly **not** part of this feature:

- Email or in-app notifications for suggested goals, deletion requests, or goal status changes
- Bulk actions on multiple goals at once (e.g. mark all as completed)
- Manager editing goal fields other than status (name, description, dates, skill category)
- Creating, editing, or deleting feedback entries on behalf of a team member
- Modifying a team member's skill self-assessment value
- Team-level analytics or aggregated charts across all direct reports (deferred to F015)
- AI-assisted goal suggestions (deferred to F016)
- Viewing indirect reports (skip-level) — only immediate direct reports are accessible
- Pagination or filtering on the goals, feedback, or projects sections
- 360-degree review responses (`review_responses` from F006) in the Feedback section — deferred to a future dashboard enhancement

---

## Stories

### US-001: View Direct Reports List

**As a** PeopleManager or Director
**I want to** see a list of my direct reports
**So that** I can navigate to each person's individual dashboard

#### Acceptance Criteria

- [ ] AC-001: The team list page is accessible only to users with the `PeopleManager` or `Director` role; any other role receives a 403 response.
- [ ] AC-002: The page lists every employee whose `manager_id` equals the authenticated user's id.
- [ ] AC-003: Each list item displays the team member's full name and job title.
- [ ] AC-004: Clicking a list item navigates to that team member's individual dashboard.
- [ ] AC-005: When the authenticated user has no direct reports the page displays an empty-state message.

---

### US-002: Team Member Dashboard Layout

**As a** PeopleManager or Director
**I want to** see a consolidated dashboard for one of my direct reports
**So that** I can assess their status across all development dimensions in one place

#### Acceptance Criteria

- [ ] AC-006: The dashboard URL is `/team/{employeeId}`; accessing it for an employee who is not a direct report of the authenticated user returns a 403 response.
- [ ] AC-007: The dashboard header displays the team member's full name, job title, and current position (from the career framework).
- [ ] AC-008: The dashboard is divided into four named sections: **Goals**, **Feedback**, **Skills**, and **Projects**.

---

### US-003: View Team Member Goals

**As a** PeopleManager or Director
**I want to** view all goals of a direct report including full detail and tasks
**So that** I can understand their development progress and active work

#### Acceptance Criteria

- [ ] AC-009: The Goals section lists all non-deleted goals for the team member — including goals with status `suggested` and goals with a pending deletion request — showing name, status, due date, and progress percentage for each.
- [ ] AC-010: Expanding a goal reveals its full details: description, linked skill category, timeframe, and all tasks with their individual completion status.
- [ ] AC-011: Goals with status `suggested` are visually labelled "Suggested by you" (visible to the manager who suggested them) or "Suggested by [manager name]" (visible to other managers viewing).
- [ ] AC-012: Goals that have a pending deletion request are visually labelled "Deletion Requested".

---

### US-004: Mark Team Member Goal as Completed

**As a** PeopleManager or Director
**I want to** mark a direct report's goal as Completed
**So that** I can officially record the completion of their work

#### Acceptance Criteria

- [ ] AC-013: A "Mark as Completed" action is available on any goal in the team member's Goals section whose current status is `not_started` or `in_progress`.
- [ ] AC-014: Confirming the action updates the goal's status to `completed` immediately and the UI reflects the new status without a page reload.
- [ ] AC-015: The "Mark as Completed" action is not displayed for goals already in `completed` or `suggested` status.

---

### US-005: Suggest a Goal for a Team Member

**As a** PeopleManager or Director
**I want to** create a suggested goal for a direct report
**So that** I can guide their development with concrete, structured goals

#### Acceptance Criteria

- [ ] AC-016: A "Suggest Goal" button is present in the Goals section header of the team member's dashboard.
- [ ] AC-017: The form includes: name (required), description (optional), skill category (optional), timeframe (required, enum: `week` / `month` / `quarter` / `year`), and due date (optional).
- [ ] AC-018: On successful submission the goal is persisted with `status = suggested` and `suggested_by_id` set to the authenticated user's id.
- [ ] AC-019: The new suggested goal appears immediately in both the manager's view and the employee's own goal list, visually marked as a manager suggestion.

---

### US-006: Accept or Reject a Suggested Goal (Employee)

**As an** Employee
**I want to** accept or reject a goal suggested by my manager
**So that** I can take ownership of my own development plan

#### Acceptance Criteria

- [ ] AC-020: Goals with status `suggested` show "Accept" and "Reject" action buttons only to the employee who owns the goal (the `user_id`).
- [ ] AC-021: Accepting a suggested goal changes its status to `not_started`, clears the suggestion indicator, and `suggested_by_id` is retained for audit purposes.
- [ ] AC-022: Rejecting a suggested goal soft-deletes it; the goal no longer appears in either the employee's or the manager's view.
- [ ] AC-023: After acceptance or rejection the "Accept" and "Reject" buttons are no longer displayed.

---

### US-007: Request Goal Deletion (Employee)

**As an** Employee
**I want to** request deletion of one of my own goals
**So that** my manager can review and confirm the removal

#### Acceptance Criteria

- [ ] AC-024: A "Request Deletion" action is available to the employee on their own goals with status `not_started`, `in_progress`, or `completed` that do not already have a pending deletion request.
- [ ] AC-025: Submitting the request creates a `goal_deletion_requests` record with `status = pending` and the goal is visually marked "Deletion Requested" in the employee's view.
- [ ] AC-026: While a deletion request is pending the employee cannot submit another deletion request for the same goal; the "Request Deletion" action is replaced by a "Cancel Request" action.
- [ ] AC-027: The employee can cancel a pending deletion request via the "Cancel Request" action, which removes the `goal_deletion_requests` record and restores the normal goal view.

---

### US-008: Approve or Reject Goal Deletion (Manager)

**As a** PeopleManager or Director
**I want to** approve or reject a direct report's goal deletion request
**So that** I remain in control of their development plan

#### Acceptance Criteria

- [ ] AC-028: Goals labelled "Deletion Requested" in the manager's view show "Approve Deletion" and "Reject Deletion" action buttons.
- [ ] AC-029: Approving the deletion soft-deletes the goal and all its tasks; the goal no longer appears in either the manager's or employee's view.
- [ ] AC-030: Rejecting the deletion resolves the `goal_deletion_requests` record with `status = rejected`, removes the "Deletion Requested" label, and the goal returns to its pre-request visual state.

---

### US-009: Manager Direct Goal Deletion

**As a** PeopleManager or Director
**I want to** directly delete a direct report's goal without requiring employee confirmation
**So that** I can immediately remove irrelevant or outdated goals

#### Acceptance Criteria

- [ ] AC-031: A "Delete" action is available to the manager on any goal in the team member's Goals section regardless of its status.
- [ ] AC-032: On confirmation, the goal and all its tasks are soft-deleted; the goal no longer appears in either view.
- [ ] AC-033: If a pending `goal_deletion_requests` record exists for the goal it is also resolved (set to `approved`) when the manager deletes the goal directly.

---

### US-010: View Team Member Feedback

**As a** PeopleManager or Director
**I want to** view all feedback received by a direct report
**So that** I can assess their performance and identify patterns

#### Acceptance Criteria

- [ ] AC-034: The Feedback section displays all feedback entries received by the team member including: rating (1–5), comment text, submitter's full name, and submission date.
- [ ] AC-035: Feedback entries are listed in reverse chronological order (most recent first).
- [ ] AC-036: If no feedback has been received an empty-state message is displayed.

---

### US-011: View Team Member Skill Levels and Gap Analysis

**As a** PeopleManager or Director
**I want to** view a direct report's self-assessed and manager-assessed skill levels together with their gap analysis
**So that** I can understand their current proficiency and development needs at a glance

#### Acceptance Criteria

- [ ] AC-037: The Skills section lists every skill the team member has been assessed on, showing the skill name, self-assessment value, and manager-assessment value side by side.
- [ ] AC-038: Skills where no assessment has been recorded show "Not Assessed" for the respective column.
- [ ] AC-039: The gap analysis summary — skills below the required level for the employee's current or target position — is shown within the Skills section, reusing the `GET /api/employees/{id}/gap-analysis` endpoint.

---

### US-012: View Team Member Project Assignments

**As a** PeopleManager or Director
**I want to** view a direct report's current and historical project assignments
**So that** I can understand their workload and project history

#### Acceptance Criteria

- [ ] AC-040: The Projects section lists all project assignments for the team member including: project name, role title, start date, end date (or "Ongoing"), and assignment status (`Current` / `Past`).
- [ ] AC-041: Assignments with no end date or a future end date are labelled "Current"; assignments with a past end date are labelled "Past".
- [ ] AC-042: If no project assignments exist an empty-state message is displayed.
