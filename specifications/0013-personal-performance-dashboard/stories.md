# User Stories — Personal Performance Dashboard (0013)

## Out of Scope

The following are explicitly **not** part of this feature:

- Widget layout persistence to a backend API (order, position — remains client-side only)
- Role-based widget visibility differences (all authenticated roles see the same widgets)
- Real-time / WebSocket dashboard updates (data fetches on mount with stale-time caching)
- Date range filtering shared across all widgets (each widget controls its own period independently)
- Drill-down navigation from widgets to full detail pages (links may exist but full detail views belong to their own features)
- 360-degree review cycle widget (belongs to F006)
- Project assignments widget (belongs to F011)
- Achievement badges widget (belongs to F020)

---

## Stories

### US-001: View Personal Performance Dashboard

**As an** authenticated user (any role)
**I want to** see a consolidated dashboard of my performance data when I log in
**So that** I have a single starting point for tracking my career health at a glance

#### Acceptance Criteria

- [x] AC-001: The dashboard is accessible at `/dashboard` to all authenticated roles (Employee, PeopleManager, Director, SolutionOwner, Administrator).
- [x] AC-002: The root path `/` redirects to `/dashboard` after a successful login.
- [x] AC-003: The page title reads the i18n key `navigation.dashboard` — no hardcoded text.
- [x] AC-004: Each widget renders independently; a failure in one widget does not prevent other widgets from loading.

---

### US-002: View Summary Statistics Cards

**As an** authenticated user
**I want to** see at-a-glance counts for Goals Completed, Feedback Received, and Skills Assessed
**So that** I can quickly gauge my overall progress without reading detailed widget content

#### Acceptance Criteria

- [x] AC-005: Three summary stat cards are displayed: **Goals Completed**, **Feedback Received**, **Skills Assessed**.
- [x] AC-006: The values are loaded from `GET /api/dashboard/summary` — no hardcoded mock values.
- [x] AC-007: Each card shows a loading skeleton while data is fetching.
- [x] AC-008: If the summary request fails, each card shows an error state with a retry option.

---

### US-003: View Goals Summary Widget

**As an** authenticated user
**I want to** see an overview of my goals — counts, recent list, and progress trend
**So that** I can track whether I am on track with my development goals

#### Acceptance Criteria

- [x] AC-009: The Goals widget shows counts for active, completed, and overdue goals sourced from `GET /api/dashboard/goals-summary`.
- [x] AC-010: A list of up to 5 most recent goals is displayed, each showing title, status, progress percentage, and deadline.
- [x] AC-011: A period selector (week / month / quarter / year) updates the goals trend chart without reloading the page.
- [x] AC-012: An overdue goal is visually distinguished (e.g., colour or label).
- [x] AC-013: When the user has no goals, an empty state message with a call-to-action to create a goal is shown.

---

### US-004: View Feedback Summary Widget

**As an** authenticated user
**I want to** see a summary of feedback I have received, including ratings and recent entries
**So that** I can monitor the quality and volume of feedback I am getting over time

#### Acceptance Criteria

- [x] AC-014: The Feedback widget shows total received, pending requests count, and average rating for the selected period, sourced from `GET /api/dashboard/feedback-summary`.
- [x] AC-015: A list of up to 5 most recent feedback entries is shown, each displaying sender name, star rating, goal title (or "No linked goal" label if `goal_id` is null), and date.
- [x] AC-016: Feedback items where `goal_id` is null are **not** excluded — the backend uses a LEFT JOIN on the goals table.
- [x] AC-017: A rating distribution chart (1–5 stars) is rendered, reflecting the real distribution from the API response.
- [x] AC-018: A period selector (week / month / quarter / year) refetches data for the selected window.

---

### US-005: View Pending Feedback Requests Widget

**As an** authenticated user
**I want to** see how many feedback requests are awaiting my response
**So that** I do not miss requests from colleagues who need my input

#### Acceptance Criteria

- [x] AC-019: The Feedback Requests widget shows the count of pending requests assigned to the current user.
- [x] AC-020: A "View Requests" button is present and navigates to the feedback requests page.
- [x] AC-021: When there are no pending requests, a confirmation message ("No pending requests") is shown.

---

### US-006: View Skill Progress Widget

**As an** authenticated user
**I want to** see my skill assessment progress broken down by category
**So that** I can identify which skill areas are well-assessed and which have gaps

#### Acceptance Criteria

- [x] AC-022: The Skills widget shows total available skills, assessed skills count, and assessment progress percentage sourced from `GET /api/dashboard/skills-summary`.
- [x] AC-023: A breakdown by skill category is shown (category name, total skills, assessed skills, average level).
- [x] AC-024: A list of up to 10 most recently assessed skills is shown, each displaying skill name, level value, and assessment date.
- [x] AC-025: The recent assessments list displays only fields returned by the API (`skill_id`, `skill_name`, `level`, `assessed_at`) — no phantom fields (`assessor_name`, `category`, `category_id`).

---

### US-007: View Activity Feed Widget

**As an** authenticated user
**I want to** see a chronological timeline of my recent activity
**So that** I have context for what I have been working on and what happened lately

#### Acceptance Criteria

- [x] AC-026: The Activity Feed widget shows activities sourced from `GET /api/dashboard/activity`, sorted by timestamp descending.
- [x] AC-027: Activity types displayed: `goal_created`, `goal_completed`, `goal_updated`, `feedback_received`, `feedback_requested`, `skill_assessed`.
- [x] AC-028: `feedback_received` activities are included for feedback with no linked goal — the backend does not use an INNER JOIN on the goals table in the activity feed query.
- [x] AC-029: A day-range filter (7 / 10 / 14 / 30 days) is available and updates the feed without a page reload.
- [x] AC-030: The feed is paginated; scrolling or a "Load more" action fetches the next page.
- [x] AC-031: The widget title is rendered via an i18n key — no hardcoded English string.
- [x] AC-032: When there are no activities in the selected range, an empty state message is shown.

---

### US-008: Customise Visible Widgets

**As an** authenticated user
**I want to** show or hide individual dashboard widgets
**So that** I can focus on the sections most relevant to my workflow

#### Acceptance Criteria

- [x] AC-033: A settings button on the dashboard page opens a widget visibility panel.
- [x] AC-034: Each of the five widgets (Goals, Feedback, Feedback Requests, Skills, Activity Feed) can be toggled on or off independently.
- [x] AC-035: A "Reset layout" option restores all widgets to visible.
- [x] AC-036: Widget visibility state is client-side only and does not need to survive a page refresh.

---

### US-009: Dashboard API Envelope Consistency

**As a** developer
**I want to** the dashboard service layer to follow the same `apiClient` response envelope pattern as every other service
**So that** the dashboard works correctly against the real API and does not silently fail when mock data is removed

#### Acceptance Criteria

- [x] AC-037: `dashboardService.ts` calls `apiClient.get<{ data: T }>('/endpoint')` and reads `response.data.data` — not `response.data` directly.
- [x] AC-038: All five MSW mock handlers for dashboard endpoints return responses wrapped in `{ data: <payload>, success: true, message: "OK" }`.
- [x] AC-039: DTO type parameters in `dashboardService.ts` are declared as `{ data: IDashboardSummaryDto }` (and equivalents) to reflect the envelope.
