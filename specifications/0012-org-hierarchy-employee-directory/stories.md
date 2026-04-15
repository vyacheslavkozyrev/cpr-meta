# User Stories — Org Hierarchy & Employee Directory (0012)

## Out of Scope

The following are explicitly **not** part of this feature:

- Creating, updating, or deleting employees or organisational relationships (read-only)
- Exporting the org chart as PDF, image, or any other format
- HRIS sync and automatic employee data synchronisation (deferred to F024)
- Calendar, availability, or scheduling display
- Headcount or team-level analytics (deferred to F015)
- Filtering directory by department, location, skill, or attributes beyond name and role
- Department hierarchy browser or tree view
- Messaging or notification sending from the directory

---

## Stories

### US-001: Browse Employee Directory

**As a** any authenticated user  
**I want to** search and browse a flat list of all employees  
**So that** I can find colleagues by name or role and quickly access their profiles

#### Acceptance Criteria

- [ ] AC-001: The directory page lists all active (non-deleted) employees; each card shows: avatar, display name, job title (position title), department name, city, country, and system role(s).
- [ ] AC-002: The list is paginated with a default page size of 20 and a maximum of 100; the response includes `total_items` and `total_pages`.
- [ ] AC-003: A search field filters employees by display name — case-insensitive, partial match — and results update on each input change.
- [ ] AC-004: A role filter dropdown restricts the list to a single system role: Employee, PeopleManager, Director, SolutionOwner, or Administrator; selecting "All Roles" removes the filter.
- [ ] AC-005: Search text and role filter are applied simultaneously when both are set.

---

### US-002: View Employee Profile

**As a** any authenticated user  
**I want to** view the complete profile of any employee  
**So that** I can understand their organisational context, contact them, and navigate to related colleagues

#### Acceptance Criteria

- [ ] AC-006: Clicking an employee card in the directory navigates to their profile page at `/employees/{id}`.
- [ ] AC-007: The profile page displays: avatar, display name, job title, department name, city, country, email, phone, hire date, career path name, career track name, and system role(s); fields that are null are hidden or shown as "—".
- [ ] AC-008: The profile page shows the employee's manager as a linked card (avatar, display name, job title); if no manager is assigned, the section displays "No manager assigned".
- [ ] AC-009: The profile page lists all direct reports as linked cards (avatar, display name, job title); if none exist, an empty state "No direct reports" is shown.
- [ ] AC-010: The profile page has a "View in org chart" button that navigates to the org chart page centred on that employee.

---

### US-003: View My Org Chart

**As a** any authenticated user  
**I want to** see an interactive org chart centred on myself  
**So that** I can visualise my immediate team context — manager, peers, and direct reports — at a glance

#### Acceptance Criteria

- [ ] AC-011: The org chart page opens in "My View" by default, displaying: the logged-in user (visually highlighted), their manager, their manager's manager, and all peers (other employees sharing the same manager).
- [ ] AC-012: Each org chart node displays: avatar, display name, and job title.
- [ ] AC-013: The direct reports of the logged-in user appear as child nodes; each child node has an expand/collapse toggle to reveal that person's own direct reports.
- [ ] AC-014: Clicking any node navigates to that employee's profile page.
- [ ] AC-015: A "Full Org Chart" tab is visible on the page and switches the view to the full company tree.

---

### US-004: Browse Full Org Chart

**As a** any authenticated user  
**I want to** view the full company org chart starting from the organisation root  
**So that** I can understand the complete reporting hierarchy and navigate to any employee

#### Acceptance Criteria

- [ ] AC-016: The full org chart renders from root employee(s) — those with no assigned manager; on first load, only root nodes and their direct children are visible.
- [ ] AC-017: Every non-leaf node displays an expand/collapse toggle; clicking expand reveals the node's direct children; expand/collapse state is maintained for the duration of the page session.
- [ ] AC-018: Each node displays: avatar, display name, and job title.
- [ ] AC-019: Clicking any node navigates to that employee's profile page.
- [ ] AC-020: A "My View" tab is visible on the full tree page and switches back to the org chart centred on the logged-in user.
