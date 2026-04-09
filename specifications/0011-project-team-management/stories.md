# User Stories — Project Team Management (0011)

## Out of Scope

The following are explicitly **not** part of this feature:

- Setting or changing the project `sponsor_id` — deferred to a future feature
- Automated project code generation — codes are always entered manually
- Budget, effort estimation, or capacity planning calculations
- Notifications or reminders related to project assignments or milestone dates
- Integration with external project management tools (Jira, Azure DevOps, etc.)
- Multiple owners per project
- Project templates
- HRIS synchronisation for projects (F024)
- Searching or filtering employees by skill when browsing the full employee list

---

## Stories

### US-001: Create a New Project

**As a** SolutionOwner, Director, or Administrator
**I want to** create a project with a unique code, title, optional description, status, and optional date range
**So that** I have a named container to manage team composition and staffing decisions

#### Acceptance Criteria

- [ ] AC-001: POST /api/projects is accessible only by `SolutionOwner`, `Director`, and `Administrator`; `Employee` and `PeopleManager` roles receive 403.
- [ ] AC-002: Request must include `code` (1–20 chars, required) and `title` (1–200 chars, required); `description` (max 2000 chars) is optional.
- [ ] AC-003: `status` must be one of `draft`, `active`, `completed`, `archived`; defaults to `draft` when omitted.
- [ ] AC-004: `code` must be unique across non-deleted projects; a duplicate code returns 409 with `errors.project.code_conflict`.
- [ ] AC-005: When both `start_date` and `end_date` are provided, `end_date` must be >= `start_date`; violation returns 400 with `errors.validation.end_date`.
- [ ] AC-006: The created project's `owner_id` is automatically set to the authenticated user's `employee_id`.
- [ ] AC-007: Successful creation returns 201 with the full project object including `id`, `code`, `title`, `description`, `status`, `start_date`, `end_date`, and `owner_id`.

---

### US-002: Browse the Project List

**As a** SolutionOwner, Director, or Administrator
**I want to** view a paginated list of all projects with optional status filtering
**So that** I can find projects to manage and get an overview of organisational project activity

#### Acceptance Criteria

- [ ] AC-008: GET /api/projects returns all non-deleted projects for `SolutionOwner`, `Director`, and `Administrator`; `Employee` and `PeopleManager` receive 403.
- [ ] AC-009: List supports optional `status` query param to filter by project status (`draft`, `active`, `completed`, `archived`).
- [ ] AC-010: List supports pagination (`page`, `per_page` max 100) and sorting by `title` (asc/desc) or `created_at` (asc/desc); default sort is `created_at desc`.
- [ ] AC-011: Each list item includes `id`, `code`, `title`, `status`, `start_date`, `end_date`, and `owner_id`.

---

### US-003: View Project Detail

**As a** SolutionOwner, Director, or Administrator
**I want to** view the full details of a single project
**So that** I can review project information and navigate to team management

#### Acceptance Criteria

- [ ] AC-012: GET /api/projects/{id} returns project fields: `id`, `code`, `title`, `description`, `status`, `start_date`, `end_date`, `owner_id`, `created_at`.
- [ ] AC-013: Returns 404 if the project does not exist or is soft-deleted.
- [ ] AC-014: `Employee` and `PeopleManager` roles receive 403.

---

### US-004: Edit a Project

**As a** SolutionOwner (own project), Director, or Administrator
**I want to** update a project's title, description, status, or dates
**So that** the project record stays accurate over its lifecycle

#### Acceptance Criteria

- [ ] AC-015: PATCH /api/projects/{id} accepts partial updates to `title`, `description`, `status`, `start_date`, `end_date`; the `code` field cannot be changed after creation (400 if included).
- [ ] AC-016: A `SolutionOwner` can only PATCH projects where `owner_id` equals their `employee_id`; attempting to edit another owner's project returns 403.
- [ ] AC-017: `Director` and `Administrator` can PATCH any project regardless of ownership.
- [ ] AC-018: Validation rules from US-001 apply to all updated fields (status enum, end_date >= start_date).

---

### US-005: Archive a Project

**As a** SolutionOwner (own project), Director, or Administrator
**I want to** soft-delete a project so it is no longer active
**So that** history is preserved without the project appearing in active lists

#### Acceptance Criteria

- [ ] AC-019: DELETE /api/projects/{id} soft-deletes the project (sets `is_deleted = TRUE`); returns 204 No Content on success.
- [ ] AC-020: A `SolutionOwner` can only delete their own projects; attempting to delete another owner's project returns 403.
- [ ] AC-021: `Director` and `Administrator` can delete any project.
- [ ] AC-022: Soft-deleting a project does not cascade to associated `project_roles` or `project_teams` rows; those records retain their own `is_deleted` state.

---

### US-006: Manage Project Roles

**As a** SolutionOwner (own project), Director, or Administrator
**I want to** define, rename, and remove the roles that exist within a project (e.g., Tech Lead, Product Manager)
**So that** team members can be assigned to meaningful responsibilities

#### Acceptance Criteria

- [ ] AC-023: GET /api/projects/{id}/roles returns all non-deleted project roles for the project.
- [ ] AC-024: POST /api/projects/{id}/roles creates a role with `title` (required, 1–100 chars) and optional `description` (max 500 chars); returns 201 with the new role object.
- [ ] AC-025: A `SolutionOwner` can only manage roles on projects they own; attempting to manage roles on another owner's project returns 403.
- [ ] AC-026: `Director` and `Administrator` can manage roles on any project.
- [ ] AC-027: PATCH /api/projects/{id}/roles/{roleId} updates `title` and/or `description`; returns 200 with the updated role.
- [ ] AC-028: DELETE /api/projects/{id}/roles/{roleId} soft-deletes the role; returns 409 with `errors.project_role.has_active_members` if the role has non-deleted `project_teams` assignments.

---

### US-007: Assign a Team Member

**As a** SolutionOwner (own project), Director, or Administrator
**I want to** assign an employee to a project role with an optional date range
**So that** team composition is tracked over time with accurate start and end dates

#### Acceptance Criteria

- [ ] AC-029: POST /api/projects/{id}/roles/{roleId}/members requires `employee_id` (UUID, required); `start_date` and `end_date` are optional.
- [ ] AC-030: `end_date` must be >= `start_date` if both are provided; violation returns 400 with `errors.validation.end_date`.
- [ ] AC-031: Assigning the same employee to the same role where date ranges overlap (or both are null) returns 409 with `errors.project_member.overlap`.
- [ ] AC-032: A `SolutionOwner` can only assign members to roles on their own projects; 403 otherwise. `Director` and `Administrator` can assign to any project.
- [ ] AC-033: The Assign Member form in the UI fetches and displays the candidate employee's skill assessments (proficiency levels per skill) via the existing GET /api/employees/{id}/skill-assessment endpoint before the assignment is submitted.

---

### US-008: Remove a Team Member

**As a** SolutionOwner (own project), Director, or Administrator
**I want to** remove a team member from a project role
**So that** the team composition reflects who is actually working on the project

#### Acceptance Criteria

- [ ] AC-034: DELETE /api/projects/{id}/roles/{roleId}/members/{memberId} soft-deletes the assignment; returns 204 No Content.
- [ ] AC-035: A `SolutionOwner` can only remove members from their own projects; `Director` and `Administrator` can remove from any.
- [ ] AC-036: The removed assignment record is retained in the database with its original date range, making it visible in historical queries.

---

### US-009: Update Team Member Assignment Dates

**As a** SolutionOwner (own project), Director, or Administrator
**I want to** update the start and/or end date of a team member's assignment
**So that** the date range accurately reflects their actual period of involvement

#### Acceptance Criteria

- [ ] AC-037: PATCH /api/projects/{id}/roles/{roleId}/members/{memberId} accepts `start_date` and/or `end_date`; returns 200 with the updated assignment.
- [ ] AC-038: Validation: `end_date` >= `start_date` if both provided (400 with `errors.validation.end_date`).
- [ ] AC-039: Updated date range must not create an overlap with another active assignment of the same employee to the same role; returns 409 with `errors.project_member.overlap` if it does.
- [ ] AC-040: A `SolutionOwner` can only update assignments on their own projects; `Director` and `Administrator` can update any.

---

### US-010: View Project Team Composition (Current and Historical)

**As a** SolutionOwner, Director, or Administrator
**I want to** see all team member assignments for a project — past, current, and future — grouped by role
**So that** I understand how the team has evolved and plan accordingly

#### Acceptance Criteria

- [ ] AC-041: GET /api/projects/{id}/team returns all non-deleted assignments grouped by `project_role`, each entry including `employee_id`, `display_name`, `start_date`, `end_date`, and `is_current`.
- [ ] AC-042: `is_current` is `true` when today's date falls within [start_date, end_date] (inclusive), or when both dates are null, or when start_date <= today and end_date is null.
- [ ] AC-043: Accepts optional `as_of` (ISO date string) query param; when provided, returns only assignments where `start_date <= as_of AND (end_date IS NULL OR end_date >= as_of)`.

---

### US-011: View Own Project Assignments (Employee)

**As any** authenticated user
**I want to** see the list of projects I am assigned to, including my role and assignment dates
**So that** I can track my current and past project involvement

#### Acceptance Criteria

- [ ] AC-044: GET /api/me/project-assignments returns all non-deleted `project_teams` entries for the authenticated user's `employee_id`, including `project` (id, code, title, status, start_date, end_date) and `role` (id, title) and `start_date`, `end_date`, `is_current`.
- [ ] AC-045: `is_current` uses the same logic as AC-042.
- [ ] AC-046: All roles (`Employee`, `PeopleManager`, `SolutionOwner`, `Director`, `Administrator`) can call this endpoint.

---

### US-012: View an Employee's Project Assignments

**As a** PeopleManager (direct reports only), SolutionOwner, Director, or Administrator
**I want to** see which projects a specific employee is assigned to
**So that** I can understand their workload and make informed staffing decisions

#### Acceptance Criteria

- [ ] AC-047: GET /api/employees/{id}/project-assignments is accessible by `Director` and `Administrator` for any employee.
- [ ] AC-048: `SolutionOwner` can call this endpoint for any employee (to support staffing decisions).
- [ ] AC-049: `PeopleManager` can call this endpoint only for their direct reports (`manager_id` in `employees` table equals the authenticated user's `employee_id`); accessing a non-direct-report returns 403.
- [ ] AC-050: `Employee` role receives 403.
- [ ] AC-051: Response has the same shape as GET /api/me/project-assignments.
