# Wireframes — Project Team Management (0011)

> **Coverage requirement**: every screen or interaction flow mentioned in `stories.md`
> must have a corresponding section below.

---

## Project List Page (SolutionOwner / Director / Administrator)

```mermaid
flowchart TD
    A[Projects Page] --> B{Loading?}
    B -->|Loading| C[Skeleton rows]
    B -->|Empty| D[Empty state: 'No projects yet'\n+ 'Create Project' button]
    B -->|Error| E[Error banner + Retry]
    B -->|Success| F[Project List Table]

    F --> G[Filter bar: Status dropdown\nSearch by title/code\nSort by title or created_at]
    F --> H[Table: Code · Title · Status badge\nStart · End · Owner · Actions]
    H --> I[Row actions: View · Edit · Delete]
    H --> J['+ New Project' button top-right]

    I -->|View| K[Project Detail Page]
    I -->|Edit| L[Edit Project Drawer]
    I -->|Delete| M{Confirm archive dialog}
    M -->|Cancel| F
    M -->|Confirm| N[Soft-delete → remove from list]
    J --> O[Create Project Drawer]
```

**Notes**
- Status badge colours: `draft` = grey, `active` = green, `completed` = blue, `archived` = orange.
- SolutionOwner sees all projects but Edit/Delete row actions are only enabled for projects they own.
- Director and Administrator see all projects with full Edit/Delete access.

---

## Create / Edit Project Drawer

```mermaid
flowchart TD
    A[Drawer opens] --> B[Form fields]
    B --> C[Code: text input\n1–20 chars · required\nDisabled on edit]
    B --> D[Title: text input\n1–200 chars · required]
    B --> E[Description: textarea\nmax 2000 chars · optional]
    B --> F[Status: select\ndraft / active / completed / archived]
    B --> G[Start Date: date picker · optional]
    B --> H[End Date: date picker · optional\nmust be ≥ Start Date]
    B --> I[Save button]

    I --> J{Validate}
    J -->|Invalid| K[Inline field errors]
    J -->|409 code conflict| L[Banner: 'Code already in use']
    J -->|Success| M[Drawer closes · list refreshes]
```

**Notes**
- On Edit, `Code` field is read-only (disabled) — it cannot be changed.
- End Date picker disables dates before the selected Start Date.

---

## Project Detail Page

```mermaid
flowchart TD
    A[Project Detail Page /projects/:id] --> B{Loading?}
    B -->|Loading| C[Skeleton]
    B -->|404| D[Not Found screen]
    B -->|Success| E[Header: Code · Title · Status badge\nOwner · Start–End dates\nEdit button if permitted]

    E --> F[Tabs]
    F --> G[Tab: Roles & Team]
    F --> H[Tab: Team History]

    G --> I[Role list\nEach role: title + member count\n+ Manage Members button\n+ Edit/Delete role actions]
    I --> J['+ Add Role' button]
    J --> K[Add Role inline form]

    H --> L[Date picker: 'View composition as of'\ndefaults to today]
    L --> M[Filtered team table:\nRole · Employee · Start · End · Current badge]
```

**Notes**
- Edit button visible only if user has permission (own project for SolutionOwner; any for Director/Admin).
- The "Team History" tab sends `as_of` param to GET /api/projects/{id}/team when a date is selected.

---

## Manage Project Roles (within Project Detail)

```mermaid
flowchart TD
    A[Roles & Team tab] --> B[Role Card list]
    B --> C{Empty?}
    C -->|Yes| D['No roles defined yet'\n+ 'Add first role' CTA]
    C -->|No| E[Role Card:\ntitle · description · member count\nEdit pencil · Delete trash icon\n'Assign Member' button]

    E --> F[Edit Role inline form:\ntitle · description · Save]
    E --> G{Delete Role}
    G -->|Has active members| H[409 toast: 'Remove all members first']
    G -->|No members| I[Soft-delete role · card disappears]

    B --> J['+ Add Role' button → Add Role Form]
    J --> K[title required · description optional · Save]
    K --> L[New role card appears]
```

---

## Assign Team Member Flow (with Skills Panel)

```mermaid
sequenceDiagram
    actor User
    participant UI
    participant API

    User->>UI: Click 'Assign Member' on a role card
    UI->>UI: Open Assign Member drawer

    User->>UI: Search / select an employee
    UI->>API: GET /api/employees/{id}/skill-assessment
    API-->>UI: Skill assessments (skill title + self_assessment_value + manager_assessment_value)
    UI->>UI: Display skills panel alongside the form

    User->>UI: (optional) Enter start_date and end_date
    User->>UI: Click Assign
    UI->>API: POST /api/projects/{id}/roles/{roleId}/members
    API-->>UI: 201 Created
    UI->>UI: Close drawer · refresh role card member count
```

**Notes**
- Employee search is a typeahead against the employee directory.
- Skills panel shows skill name, self-assessment value, and manager-assessment value (if present) as a compact list.
- If the selected employee has no skills recorded, the panel shows "No skill assessments on record."
- Overlap conflict (409) shows an inline banner: "This employee already has an overlapping assignment for this role."

---

## Update Assignment Dates

```mermaid
flowchart TD
    A[Team member row] --> B[Edit icon click]
    B --> C[Inline date-range editor:\nStart Date · End Date]
    C --> D{Save}
    D -->|end_date < start_date| E[Field error: 'End must be on or after start']
    D -->|409 overlap| F[Banner: 'Dates overlap with an existing assignment']
    D -->|Success| G[Row updates with new dates]
```

---

## Remove Team Member Confirmation

```mermaid
flowchart TD
    A[Team member row] --> B[Remove icon click]
    B --> C{Confirm dialog:\n'Remove [Name] from [Role]?'\nHistory will be preserved.}
    C -->|Cancel| D[Dialog closes]
    C -->|Confirm| E[DELETE request]
    E --> F[Member row removed from current view\nRetained in Team History tab]
```

---

## Employee — My Projects Page

```mermaid
flowchart TD
    A[My Projects Page /me/projects] --> B{Loading?}
    B -->|Loading| C[Skeleton]
    B -->|Empty| D['You are not assigned to any projects.']
    B -->|Success| E[Project Assignment list]

    E --> F[Each card:\nProject Code · Title · Status badge\nRole title\nStart – End dates\nCurrent badge if is_current = true]
    F --> G[Filter: 'Current only' toggle]
```

**Notes**
- Available to all roles via the personal nav.
- "Current" badge uses `is_current` from the API response.

---

## People Manager — Direct Reports' Project Assignments

```mermaid
flowchart TD
    A[Team Member Profile page or\nTeam Dashboard] --> B[Projects section]
    B --> C{Loading?}
    C -->|Loading| D[Skeleton]
    C -->|Empty| E['No project assignments.']
    C -->|Success| F[Assignment list for the selected direct report]

    F --> G[Each row:\nProject Code · Title · Status badge\nRole title · Start – End · Current badge]
```

**Notes**
- Manager calls GET /api/employees/{id}/project-assignments for the selected direct report.
- Attempting to load assignments for a non-direct-report employee results in 403; UI shows "You don't have access to this employee's project data."

---

## SolutionOwner / Director / Admin — Employee Project Capacity View

```mermaid
flowchart TD
    A[Assign Member drawer\nor Employee Profile page] --> B[Project Assignments section]
    B --> C[Calls GET /api/employees/:id/project-assignments]
    C --> D{Response}
    D -->|Empty| E['Not currently assigned to any projects.']
    D -->|Assignments| F[Compact list:\nProject Code · Title · Role · Start–End · Current badge]
```

**Notes**
- This view is embedded in the Assign Member drawer (below the skills panel) so the user can see both the candidate's skills and their existing project load before assigning.
- SolutionOwner, Director, and Administrator all have access.
