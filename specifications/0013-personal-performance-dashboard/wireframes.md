# Wireframes — Personal Performance Dashboard (0013)

> **Coverage requirement**: every screen or interaction flow mentioned in `stories.md`
> must have a corresponding section below. Check stories.md before finalising this document.

---

## Dashboard Page Layout

```mermaid
flowchart TD
    A[Dashboard Page /dashboard] --> B[Page Header]
    B --> B1["Title: 'Dashboard' (i18n)"]
    B --> B2[Settings Button → Widget Visibility Panel]
    A --> C[Summary Statistics Row]
    C --> C1[Goals Completed Card]
    C --> C2[Feedback Received Card]
    C --> C3[Skills Assessed Card]
    A --> D[Widgets Grid 2-column responsive]
    D --> D1[Goals Summary Widget]
    D --> D2[Feedback Summary Widget]
    D --> D3[Feedback Requests Widget]
    D --> D4[Skill Progress Widget]
    D --> D5[Activity Feed Widget]
```

**Notes**
- Grid collapses to single column on `xs` breakpoint.
- Each widget slot is only rendered if the widget is toggled visible.
- Summary cards always visible (not individually toggleable).

---

## Summary Statistics Cards

```mermaid
flowchart TD
    A[UserStatisticsCards] -->|GET /api/dashboard/summary| B{Loading?}
    B -->|Yes| C[Skeleton × 3]
    B -->|Error| D[Error chip × 3 + Retry]
    B -->|Success| E[3 stat cards with real values]
    E --> E1["Goals Completed — value from summary.goals.completed"]
    E --> E2["Feedback Received — value from summary.feedback.total_received"]
    E --> E3["Skills Assessed — value from summary.skills.assessed_skills"]
```

**Notes**
- Trend chip text must be driven by API data — no hardcoded "+2 this month" strings.
- Cards use `success`, `info`, `primary` colour tokens respectively.

---

## Goals Summary Widget

```mermaid
flowchart TD
    A[GoalSummaryWidget] -->|GET /api/dashboard/goals-summary?period=month| B{State}
    B -->|Loading| C[Skeleton]
    B -->|Error| D[Error + Retry]
    B -->|Empty — no goals| E[Empty state: 'No goals yet' + Create Goal CTA]
    B -->|Success| F[Widget content]
    F --> F1[Stat chips: Active / Completed / Overdue]
    F --> F2[Period selector: week / month / quarter / year]
    F --> F3[Progress trend Line chart]
    F --> F4[Recent goals list — up to 5 rows]
    F4 --> F4a[Title · Status chip · Progress bar · Deadline]
    F4 --> F4b[Overdue badge if deadline past and not completed]
```

---

## Feedback Summary Widget

```mermaid
flowchart TD
    A[FeedbackSummaryWidget] -->|GET /api/dashboard/feedback-summary?period=month| B{State}
    B -->|Loading| C[Skeleton]
    B -->|Error| D[Error + Retry]
    B -->|Empty| E[Empty state: 'No feedback received yet']
    B -->|Success| F[Widget content]
    F --> F1["Stats: Total received · Pending requests · Avg rating"]
    F --> F2[Period selector: week / month / quarter / year]
    F --> F3[Rating distribution Bar chart 1–5 stars]
    F --> F4[Recent feedback list — up to 5 rows]
    F4 --> F4a["Sender name · Star rating · Goal title OR 'No linked goal' · Date"]
```

**Notes**
- Feedback rows where `goal_id` is null must render "No linked goal" label, never be absent from the list.

---

## Feedback Requests Widget

```mermaid
flowchart TD
    A[FeedbackRequestsWidget] -->|pending count from feedback API| B{Pending count}
    B -->|0| C["'No pending requests' message"]
    B -->|> 0| D[Count badge + 'View Requests' button]
    D -->|click| E[Navigate to /feedback-requests]
```

---

## Skill Progress Widget

```mermaid
flowchart TD
    A[SkillProgressWidget] -->|GET /api/dashboard/skills-summary| B{State}
    B -->|Loading| C[Skeleton]
    B -->|Error| D[Error + Retry]
    B -->|Success| F[Widget content]
    F --> F1["Stats: Total skills · Assessed · Progress %"]
    F --> F2[Category breakdown list]
    F2 --> F2a["Category name · Assessed/Total · Avg level"]
    F --> F3[Recent assessments list — up to 10 rows]
    F3 --> F3a["Skill name · Level value · Date assessed"]
```

**Notes**
- Recent assessments list renders only `skill_name`, `level`, `assessed_at` — no `assessor_name`, `category`, or `category_id` fields (not in API response).

---

## Activity Feed Widget

```mermaid
flowchart TD
    A[ActivityFeedWidget] -->|GET /api/dashboard/activity?days=10&page=1&per_page=20| B{State}
    B -->|Loading| C[Skeleton timeline rows]
    B -->|Error| D[Error + Retry]
    B -->|Empty| E["'No recent activity' empty state"]
    B -->|Success| F[Timeline list]
    F --> F1[Day filter: 7 / 10 / 14 / 30]
    F --> F2[Activity rows sorted by timestamp desc]
    F2 --> F2a[Icon · Title · Description · Relative time]
    F --> F3[Load more / pagination control]
```

**Notes**
- Widget title rendered from i18n key — no hardcoded "Activity Feed" string.
- `feedback_received` activities appear even when the originating feedback has no linked goal.

---

## Widget Visibility Panel

```mermaid
flowchart TD
    A[Settings button click] --> B[Overlay / drawer opens]
    B --> C[Toggle row per widget × 5]
    C --> C1[Goals]
    C --> C2[Feedback]
    C --> C3[Feedback Requests]
    C --> C4[Skills]
    C --> C5[Activity Feed]
    B --> D[Reset layout button]
    D --> E[All 5 widgets set to visible]
```

**Notes**
- State is Zustand client-only; not persisted to backend or localStorage.
- Toggle changes take effect immediately without page reload.

---

## Dashboard Load Flow (Sequence)

```mermaid
sequenceDiagram
    actor User
    participant UI as DashboardPage
    participant API as cpr-api

    User->>UI: Navigate to /dashboard
    UI->>API: GET /api/dashboard/summary
    UI->>API: GET /api/dashboard/goals-summary?period=month
    UI->>API: GET /api/dashboard/feedback-summary?period=month
    UI->>API: GET /api/dashboard/skills-summary
    UI->>API: GET /api/dashboard/activity?days=10
    Note over UI: All requests fire in parallel (React Query)
    API-->>UI: summary response { data: {...}, success: true }
    API-->>UI: goals-summary response { data: {...}, success: true }
    API-->>UI: feedback-summary response { data: {...}, success: true }
    API-->>UI: skills-summary response { data: {...}, success: true }
    API-->>UI: activity response { data: {...}, success: true }
    UI-->>User: Widgets populate independently as each response arrives
```

**Notes**
- Each widget transitions from skeleton → content independently.
- A widget failure renders its own error state; other widgets are unaffected.
- All responses are unwrapped via `response.data.data` (envelope pattern).

---

## Widget Error / Empty States

```mermaid
flowchart TD
    A[Widget mounts] --> B{API result}
    B -->|isLoading| C[Skeleton overlay inside widget card]
    B -->|isError| D[Error icon + message + Retry button]
    B -->|success — empty data| E[Empty state illustration + contextual CTA]
    B -->|success — has data| F[Populated widget content]
```
