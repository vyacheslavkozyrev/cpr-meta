# Wireframes — Skills Self-Assessment (0007)

---

## Screen 1: Self-Assessment Dashboard (Employee View)

```
flowchart TD
    A["🏠 Header: Position Title · Career Track · Career Path"]
    A --> B["📊 Radar Chart\n(current position req | self-assessed | next position req)"]
    B --> C["Skill Category: Technical Skills"]
    C --> D["Skill Row: TypeScript\n  Required: Advanced (4) | Your level: [▼ Intermediate (3)] | Target: [▼ Advanced (4)]\n  Notes: [_________________________] (auto-save on blur)\n  Evidence: [feedback snippet] [+ Link feedback]"]
    D --> E["Skill Row: API Design\n  Required: Proficient (3) | Your level: [▼ Not assessed] | Target: [▼ No target]\n  ..."]
    E --> F["Skill Category: Soft Skills"]
    F --> G["Skill Row: Communication\n  ..."]
```

**Notes:**
- Level selectors are dropdowns populated from `skill_levels.value` ASC.
- Changes auto-save on selection change (current level) or field blur (notes).
- "Link feedback" button opens the Evidence Modal (Screen 3).
- The radar chart sits at the top of the page and re-renders on every auto-save.

---

## Screen 2: Radar Chart Detail

```
flowchart TD
    subgraph Chart["Radar / Spider Chart"]
        direction LR
        L1["● Blue — Current position required levels"]
        L2["● Green — Your self-assessed levels"]
        L3["◌ Grey dashed — Next position required levels"]
    end
    Chart --> N1["Axes = one per required skill (title as label)"]
    Chart --> N2["Values = skill_level.value (1–5)"]
    Chart --> N3["[If no next position] Banner:\n'You are at the highest position in your track'"]
```

**Notes:**
- All three datasets share the same set of axes (current position skills).
- Skills with no self-assessment default to value 0 on Dataset 2.
- Dataset 3 uses the next position's `position_to_skill` entries; skills not required by that position default to 0.

---

## Screen 3: Evidence Linking Modal

```
flowchart TD
    A["Modal: Link Feedback as Evidence for [Skill Name]"]
    A --> B["Search / filter by sender name or keyword"]
    B --> C["Feedback List\n  ─────────────────────────────────────────\n  [✓] Alice Johnson · ★★★★☆ · 'Great job leading the API review...'\n  [ ] Bob Chen    · ★★★☆☆ · 'Solid work on the TypeScript migration...'\n  ─────────────────────────────────────────"]
    C --> D{"User action"}
    D -->|"Click [Save]"| E["POST /api/me/skill-assessment/skills/{id}/evidence\nauto-save each selected item"]
    D -->|"Click [Cancel]"| F["Close modal, no changes"]
    E --> G["Modal closes · evidence items appear beneath skill row"]
```

**Notes:**
- Already-linked feedback items show a checkmark and cannot be double-linked.
- The modal lists only feedback where `to_employee_id = current employee`.
- If no feedback is available, an empty state "No feedback received yet" is shown.

---

## Screen 4: Manager Team Skill Overview (PeopleManager View)

```
flowchart TD
    A["Team Skill Overview — [Manager Name]"]
    A --> B["Table: Direct Reports\n  ┌───────────────┬──────────────────┬──────────┬──────────────┐\n  │ Name          │ Position         │ Assessed │ Meeting Req. │\n  ├───────────────┼──────────────────┼──────────┼──────────────┤\n  │ Jane Smith    │ Sr. SW Engineer  │ 8 / 10   │ 6 / 10       │\n  │ Bob Chen      │ SW Engineer      │ 5 / 10   │ 3 / 10       │\n  └───────────────┴──────────────────┴──────────┴──────────────┘"]
    B --> C{"Click row"}
    C --> D["Employee Assessment Page (read-only)"]
```

---

## Screen 5: Employee Assessment Page (Read-Only View for Manager / Director / Admin)

```
flowchart TD
    A["[Read-Only Banner] Viewing assessment for: Jane Smith"]
    A --> B["Header: Position · Track · Path"]
    B --> C["Radar Chart (same 3 datasets, no interaction)"]
    C --> D["Skill Category: Technical Skills"]
    D --> E["Skill Row: TypeScript\n  Required: Advanced (4) | Assessed: Intermediate (3) | Target: Advanced (4)\n  Notes: 'Led API migration in Q3'\n  Evidence: [Alice Johnson · ★★★★☆ · 'Great job...']]"]
    E --> F["... additional skills ..."]
```

**Notes:**
- No dropdowns, no save buttons, no "Link feedback" or "Clear target" actions.
- All data is displayed as plain text / static badges.

---

## Flow 1: Auto-Save Current Level

```sequenceDiagram
    participant U as User
    participant UI as React UI
    participant API as PUT /api/me/skill-assessment/skills/{skill_id}

    U->>UI: Selects skill level from dropdown
    UI->>UI: Show saving spinner on row
    UI->>API: PUT { skill_level_id, notes }
    alt success
        API-->>UI: 200 OK { assessed_skill }
        UI->>UI: Hide spinner, show "Saved" tick
        UI->>UI: Re-render radar chart with new value
    else validation error (target ≤ current)
        API-->>UI: 422 { error: "Target level must be higher than your current level" }
        UI->>UI: Revert selection, show inline error message
    else server error
        API-->>UI: 500
        UI->>UI: Revert selection, show "Save failed — please try again"
    end
```

---

## Flow 2: Link Feedback as Evidence

```sequenceDiagram
    participant U as User
    participant UI as React UI
    participant API_GET as GET /api/me/feedback
    participant API_POST as POST /api/me/skill-assessment/skills/{skill_id}/evidence

    U->>UI: Clicks "Link feedback" on skill row
    UI->>API_GET: GET /api/me/feedback
    API_GET-->>UI: 200 OK [feedback list]
    UI->>UI: Open evidence modal with list
    U->>UI: Selects one or more feedback items, clicks Save
    loop for each selected feedback_id
        UI->>API_POST: POST { feedback_id }
        API_POST-->>UI: 201 Created { evidence_item }
    end
    UI->>UI: Close modal, append evidence items under skill row
```
