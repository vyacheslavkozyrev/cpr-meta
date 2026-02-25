# Wireframes — Skills Taxonomy & Career Framework (0008)

> **Coverage requirement**: every screen or interaction flow mentioned in `stories.md`
> must have a corresponding section below. Check stories.md before finalising this document.

---

## Career Paths List Page (US-001)

```mermaid
flowchart TD
    A[Career Framework Page] --> B{Data loaded?}
    B -->|Loading| C[Skeleton cards × 3]
    B -->|Empty| D[Empty state\n'No career paths have been configured yet.']
    B -->|Error| E[Error banner + Retry button]
    B -->|Success| F[Page Header: 'Career Framework']
    F --> G[Grid of Career Path Cards]
    G --> H[Career Path Card\ntitle · description · arrow icon]
    H -->|Click| I[Navigate to Career Path Detail]
    F --> J{Admin role?}
    J -->|Yes| K[+ Add Career Path button]
    K -->|Click| L[Create Career Path Modal]
```

**Notes**

- Cards are sorted alphabetically by title.
- Description is truncated to 2 lines with an ellipsis; full text shown in the detail view.
- The "+ Add Career Path" button is only visible to users with the `Administrator` role.

---

## Career Path Detail Page (US-002)

```mermaid
flowchart TD
    A[Career Path Detail] --> B[Breadcrumb: Career Framework › Path Title]
    A --> C[Path Title + Description]
    A --> D{Tracks available?}
    D -->|None| E[Empty state\n'No tracks in this path yet.']
    D -->|Yes| F[Career Tracks List]
    F --> G[Track Card\ntitle · description · arrow icon]
    G -->|Click| H[Navigate to Career Track Detail]
    A --> I{Admin role?}
    I -->|Yes| J[Edit Path button · + Add Track button]
    J -->|Edit| K[Edit Career Path Modal]
    J -->|Add Track| L[Create Career Track Modal\npre-filled with this path]
```

**Notes**

- Breadcrumb allows navigation back to the Career Paths list.
- Track cards are sorted alphabetically by title.

---

## Career Track Detail Page — Position Progression Ladder (US-003)

```mermaid
flowchart TD
    A[Career Track Detail] --> B[Breadcrumb: Career Framework › Path › Track]
    A --> C[Track Title + Description]
    A --> D{Positions available?}
    D -->|None| E[Empty state\n'No positions defined for this track.']
    D -->|Yes| F[Vertical Progression Ladder]
    F --> G[Position Card — Most Senior\ntitle · short description · expectations excerpt]
    G --> H[Connector arrow ↓]
    H --> I[Position Card — Mid Level]
    I --> J[Connector arrow ↓]
    J --> K[Position Card — Most Junior]
    G -->|Click| L[Navigate to Position Detail]
    I -->|Click| L
    K -->|Click| L
    A --> M{Admin role?}
    M -->|Yes| N[+ Add Position button]
    N -->|Click| O[Create Position Modal\npre-filled with this track]
```

**Notes**

- Positions are ordered alphabetically by title (ascending). The visual ladder reads top = senior, bottom = junior to indicate career progression direction.
- Each position card shows title, description (2-line truncated), and the first line of expectations.
- "Expectations" field is expanded inline on click (accordion) before navigating to full detail.

---

## Position Detail Page (US-004, US-005)

```mermaid
flowchart TD
    A[Position Detail] --> B[Breadcrumb: Career Framework › Path › Track › Position]
    A --> C[Position Title + Description + Expectations]
    A --> D{Skills available?}
    D -->|None| E[Empty state\n'No skill requirements defined for this position.']
    D -->|Yes| F[Radar Chart — Skill Spider Web]
    F --> G[Axes = individual skills\nValue = required level value 1–5\nColour per skill category\nSolid = mandatory · Dashed = optional]
    A --> H[Skill Requirements Table]
    H --> I[Columns: Category · Skill · Required Level · Mandatory · Weight · Rationale]
    I -->|Click Skill name| J[Skill Detail Side Panel]
    A --> K{Admin role?}
    K -->|Yes| L[Edit Position button · Manage Skills button]
    L -->|Edit| M[Edit Position Modal]
    L -->|Manage Skills| N[Position Skills Management Panel]
```

**Notes**

- The radar chart is rendered using a radar/spider chart library (e.g., Recharts RadarChart or Chart.js Radar).
- Skills grouped by category; each category polygon is drawn in a distinct colour with a legend.
- If a position has only 1 or 2 skills, the chart degrades gracefully to a bar chart.
- Clicking a skill name in the table opens a side panel (not a new page) showing skill title, description, category, and all proficiency levels in ascending order.

---

## Skill Detail Side Panel (US-005)

```mermaid
flowchart TD
    A[Skill Detail Side Panel] --> B[Skill Title]
    A --> C[Category badge]
    A --> D[Skill Description]
    A --> E[Proficiency Levels section]
    E --> F[Level row: value · title · description\nordered 1 → 5]
    A --> G[Close button × ]
```

**Notes**

- Opens as a right-side drawer/panel overlaying the position detail page.
- Does not navigate away from the position detail.
- The currently required level for the position is highlighted.

---

## Position Detail — Loading / Error States

```mermaid
flowchart TD
    A[Load Position Detail] --> B{API response}
    B -->|Loading| C[Skeleton: title block + chart placeholder + table skeleton rows]
    B -->|404| D[Not Found message + Back to Track button]
    B -->|Error| E[Error banner + Retry button]
    B -->|Success| F[Populated Position Detail]
```

---

## Admin: Career Framework Management (US-006–US-011)

The admin management UI is a dedicated section under **Settings > Career Framework**, organised with tabs.

```mermaid
flowchart TD
    A[Settings › Career Framework] --> B[Tab: Career Paths]
    A --> C[Tab: Career Tracks]
    A --> D[Tab: Positions]
    A --> E[Tab: Skill Categories]
    A --> F[Tab: Skills]

    B --> B1[Table of career paths\n title · description · row actions]
    B1 --> B2[+ Add Career Path → Modal]
    B1 --> B3[Edit icon → Edit Modal]

    C --> C1[Table of career tracks\n title · career path · description · row actions]
    C1 --> C2[+ Add Career Track → Modal]
    C1 --> C3[Edit icon → Edit Modal]

    D --> D1[Table of positions\n title · career track · description · row actions]
    D1 --> D2[+ Add Position → Modal]
    D1 --> D3[Edit icon → Edit Modal]
    D1 --> D4[Skills icon → Position Skills Panel]

    E --> E1[Table of skill categories\n title · description · row actions]
    E1 --> E2[+ Add Category → Modal]
    E1 --> E3[Edit icon → Edit Modal]

    F --> F1[Table of skills\n title · category · levels count · status · row actions]
    F1 --> F2[+ Add Skill → Modal]
    F1 --> F3[Edit icon → Edit Modal]
    F1 --> F4[Delete icon → Soft Delete Confirmation]
    F1 --> F5[Levels icon → Skill Levels Panel]
```

**Notes**

- All tables support sorting by column headers and text-search filtering by title.
- Soft-deleted skills are hidden from this table by default; a "Show deleted" toggle reveals them (read-only, no restore in this feature).
- Row actions are icon buttons with tooltips.

---

## Admin Flow: Create / Edit Career Path (US-006)

```mermaid
sequenceDiagram
    actor Admin
    participant UI
    participant API

    Admin->>UI: Click "+ Add Career Path"
    UI-->>Admin: Open Create Career Path Modal\n(Title*, Description)
    Admin->>UI: Fill form → Submit
    UI->>API: POST /api/career-paths { title, description }
    alt Success 201
        API-->>UI: Created career path object
        UI-->>Admin: Close modal · refresh list · success toast
    else 400 Duplicate Title
        API-->>UI: 400 ProblemDetails (errors.validation.title_duplicate)
        UI-->>Admin: Inline error on Title field
    else 422 Validation
        API-->>UI: 400 ProblemDetails
        UI-->>Admin: Inline field errors
    end
```

---

## Admin Flow: Create Skill with Proficiency Levels (US-010)

```mermaid
sequenceDiagram
    actor Admin
    participant UI
    participant API

    Admin->>UI: Click "+ Add Skill"
    UI-->>Admin: Open Create Skill Modal\n(Title*, Description, Category*)
    Admin->>UI: Add proficiency levels (value 1–5, title*, description)
    Admin->>UI: Submit
    UI->>API: POST /api/skills { title, description, category_id, levels: [...] }
    alt Success 201
        API-->>UI: Created skill with levels
        UI-->>Admin: Close modal · refresh list · success toast
    else 400 Validation
        API-->>UI: 400 ProblemDetails
        UI-->>Admin: Inline field errors (including per-level errors)
    end
```

---

## Admin Flow: Soft-Delete Skill (US-010)

```mermaid
sequenceDiagram
    actor Admin
    participant UI
    participant API

    Admin->>UI: Click Delete icon on skill row
    UI-->>Admin: Confirmation dialog\n"This will hide the skill from all views.\nExisting employee records referencing this skill are preserved."
    Admin->>UI: Confirm Delete
    UI->>API: DELETE /api/skills/{id}
    alt Success 204
        API-->>UI: 204 No Content
        UI-->>Admin: Remove row from table · success toast
    else 404
        API-->>UI: 404 ProblemDetails
        UI-->>Admin: Error toast "Skill not found"
    end
```

---

## Admin Flow: Manage Position Skill Requirements (US-011)

```mermaid
sequenceDiagram
    actor Admin
    participant UI
    participant API

    Admin->>UI: Click "Skills" icon on a position row
    UI-->>Admin: Open Position Skills Panel\n(list of current skill requirements + Add Skill button)
    Admin->>UI: Click "+ Add Skill Requirement"
    UI-->>Admin: Skill form row: Skill dropdown*, Level dropdown*, Mandatory toggle, Weight, Rationale
    Admin->>UI: Fill and Save
    UI->>API: POST /api/positions/{id}/skills { skill_id, skill_level_id, is_mandatory, weight, rationale }
    alt Success 201
        API-->>UI: Updated skill requirement
        UI-->>Admin: Add row to skill list · success toast
    else 400 Duplicate Skill
        API-->>UI: 400 (errors.validation.skill_already_assigned)
        UI-->>Admin: Inline error on Skill dropdown
    else 400 Deleted Skill
        API-->>UI: 400 (errors.validation.skill_deleted)
        UI-->>Admin: Inline error on Skill dropdown
    end
```

**Notes**

- The Skill dropdown filters to only active (non-deleted) skills.
- The Level dropdown is populated dynamically based on the selected skill's proficiency levels.
- Editing a row (skill level, mandatory, weight, rationale) uses PATCH inline; skill itself cannot be changed — remove and re-add instead.

---

## Admin: Skills Management — Proficiency Levels Sub-Panel (US-010)

```mermaid
flowchart TD
    A[Skills Table row] -->|Click Levels icon| B[Skill Levels Side Panel]
    B --> C[Skill title + category]
    B --> D[Levels list ordered by value]
    D --> E[Level row: value badge · title · description · Edit pencil icon]
    E -->|Click Edit| F[Inline edit row: value · title · description · Save · Cancel]
    B --> G[+ Add Level button]
    G -->|Click| H[New level form row: value · title* · description · Save]
```

**Notes**

- Level value must be an integer 1–5 and unique within the skill.
- At least one level should exist before the skill can be assigned to a position.
