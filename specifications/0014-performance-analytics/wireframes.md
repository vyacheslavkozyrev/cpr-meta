# Wireframes — Performance Analytics & Reporting (0014)

> **Coverage requirement**: every screen or interaction flow mentioned in `stories.md`
> must have a corresponding section below.

---

## Personal Analytics Page — `/analytics`

```mermaid
flowchart TD
    NAV["Left Sidebar\n─────────────\nDashboard\nGoals\nFeedback\nSkills\n► Analytics\nTeam"]
    PAGE["Analytics Page\n─────────────────────────────────────────"]

    RANGE["Time Range Selector\n[ Last 30 Days ] [ Last 90 Days* ] [ Last 180 Days ] [ Last Quarter ] [ Last Year ]"]

    GOALS_SECTION["── Goals ─────────────────────────────────────"]
    STATS_ROW["Stat Cards Row\n┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐\n│ Total    │ │ Created  │ │Completed │ │ Avg Days │ │ Overdue  │\n│ Goals    │ │in Period │ │in Period │ │to Complete│ │  Goals   │\n│   12     │ │    5     │ │    4     │ │  38.2    │ │    1     │\n└──────────┘ └──────────┘ └──────────┘ └──────────┘ └──────────┘"]
    COMPLETION_RATE["Completion Rate: 80%"]

    CHART_ROW["Charts Row\n┌─────────────────────────────┐  ┌─────────────────┐\n│  Completion Trend (Bar)     │  │ Goals by Status │\n│  Created ■  Completed ■     │  │  (Donut Chart)  │\n│  Monthly buckets            │  │  open / in prog │\n│                             │  │  / completed    │\n└─────────────────────────────┘  └─────────────────┘"]

    SKILLS_SECTION["── Skill Progression ─────────────────────────"]
    GAP_SUMMARY["Gap Closure Summary Card\n┌────────────────────────────────────────────┐\n│ Assessed: 10 │ With Gaps: 3 │ Closed: 1   │\n│ Worsened: 0  │ Avg Gap Start: 1.5 → End: 1.0│\n└────────────────────────────────────────────┘"]
    SKILL_LIST["Skill Rows\n┌──────────────────────────────────────────────────────────────┐\n│ TypeScript (Frontend) Self: 4.0  Mgr: 3.5  Req: 4.0  Gap: 0 │\n│ [sparkline: self ──── mgr ···· ]                             │\n├──────────────────────────────────────────────────────────────┤\n│ System Design (Architecture) Self: 2.5  Mgr: —  Req: 4.0  Gap: 1.5│\n│ [sparkline: self ──── ]                                      │\n└──────────────────────────────────────────────────────────────┘"]

    NAV --> PAGE
    PAGE --> RANGE
    RANGE --> GOALS_SECTION
    GOALS_SECTION --> STATS_ROW
    STATS_ROW --> COMPLETION_RATE
    GOALS_SECTION --> CHART_ROW
    PAGE --> SKILLS_SECTION
    SKILLS_SECTION --> GAP_SUMMARY
    SKILLS_SECTION --> SKILL_LIST
```

**Notes**
- The "Analytics" sidebar item is active when the current route starts with `/analytics`.
- Time range selector renders as a segmented button group (MUI `ToggleButtonGroup`).
- The default selected preset is "Last 90 Days" (marked with `*` above).
- The Completion Trend bar chart uses monthly buckets; the x-axis shows abbreviated month labels (e.g., "Nov", "Dec").
- The Donut chart shows the current status distribution (not period-bounded).

---

## Personal Analytics Page — Empty States

```mermaid
flowchart TD
    LOAD["Load /analytics"]
    CHECK_GOALS{Goals data\navailable?}
    CHECK_SKILLS{Skill assessments\navailable?}

    GOALS_EMPTY["Goals section:\n'No goal data for this period'\n(all stat cards show 0 or —,\nboth charts hidden)"]
    GOALS_DATA["Goals section: populated charts + stat cards"]

    SKILLS_EMPTY["Skill Progression section:\n'No skill assessment data available'\n(gap summary and skill list hidden)"]
    SKILLS_DATA["Skill Progression section: populated"]

    LOAD --> CHECK_GOALS
    CHECK_GOALS -->|"created_in_period = 0\nand total_goals = 0"| GOALS_EMPTY
    CHECK_GOALS -->|Data present| GOALS_DATA
    LOAD --> CHECK_SKILLS
    CHECK_SKILLS -->|"No assessments"| SKILLS_EMPTY
    CHECK_SKILLS -->|Data present| SKILLS_DATA
```

**Notes**
- Each section loads and renders independently; one section being empty does not affect the other.
- Loading state uses MUI `Skeleton` cards/charts while API calls are in-flight.
- Error state (API failure): shows a retry button with message "Could not load analytics data".

---

## Team Member Dashboard — Analytics Tab

```mermaid
flowchart TD
    TMD["Team Member Dashboard\n/team/:employeeId"]
    TABS["Tabs: [ Overview ] [ Goals ] [ Skills ] [ Feedback ] [ Analytics ]"]
    VISIBLE{"Role of\ncurrent user?"}

    HIDDEN["'Analytics' tab not rendered"]
    ANALYTICS_TAB["Analytics Tab Content"]

    RANGE2["Time Range Selector (same as personal page)"]
    GOALS2["Goals Section (scoped to employee)"]
    SKILLS2["Skill Progression Section (scoped to employee)"]

    AUTH{"PeopleManager:\nis employee\na direct report?"}
    FORBIDDEN["API returns 403\nUI shows 'Access denied'"]
    ALLOWED["Full analytics content rendered"]

    TMD --> TABS
    TABS --> VISIBLE
    VISIBLE -->|"PeopleManager\nDirector\nAdministrator"| ANALYTICS_TAB
    VISIBLE -->|"Employee\nSolutionOwner"| HIDDEN
    ANALYTICS_TAB --> RANGE2
    RANGE2 --> GOALS2
    RANGE2 --> SKILLS2
    ANALYTICS_TAB --> AUTH
    AUTH -->|"Not a direct report\n(PeopleManager only)"| FORBIDDEN
    AUTH -->|"Is direct report\nOR Director/Admin"| ALLOWED
```

**Notes**
- The "Analytics" tab is positioned last in the tab bar on the Team Member Dashboard.
- The tab is omitted from the DOM entirely (not just disabled) for Employee and SolutionOwner roles.
- 403 responses are caught at the hook level; the tab shows an inline error card, not a full-page error.

---

## Time Range Selection — Interaction Flow

```mermaid
sequenceDiagram
    actor User
    participant UI as Analytics Page
    participant Router as React Router
    participant API

    User->>UI: Selects "Last 180 Days"
    UI->>Router: Update URL → ?period=last_180_days
    UI->>API: GET /api/me/analytics/goals?period=last_180_days
    UI->>API: GET /api/me/analytics/skills?period=last_180_days
    note over UI: Charts/cards show skeleton while loading
    API-->>UI: 200 goal analytics payload
    API-->>UI: 200 skill analytics payload
    UI-->>User: Charts and stat cards update in-place
```

**Notes**
- Both API requests are fired in parallel (Promise.all / separate React Query queries).
- URL update happens synchronously before the API calls, so a page refresh restores the correct preset.
- If the user changes the preset again while requests are in-flight, the previous responses are discarded (React Query handles this via `queryKey` invalidation).

---

## Skill Row — Sparkline Detail

```mermaid
flowchart TD
    ROW["Skill Row: [Skill Name] [Category]"]
    META["Self: 3.5  |  Mgr: 3.0  |  Required: 4.0  |  Gap: 0.5"]
    SPARK["Sparkline Chart\n(width ~200px, height ~40px)\nSelf series  ────────\nMgr series   ··········\nX-axis: time within period"]

    ROW --> META
    ROW --> SPARK
```

**Notes**
- Sparklines use Recharts `LineChart` (already in the project dependency tree) with no axes labels to keep them compact.
- Self-assessment line: solid primary colour. Manager assessment line: dashed secondary colour.
- The required level is shown as a horizontal reference line if applicable.
- Gap value is colour-coded: green if gap ≤ 0, amber if 0 < gap ≤ 1, red if gap > 1.
