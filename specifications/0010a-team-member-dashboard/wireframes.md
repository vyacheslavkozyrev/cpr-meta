# Wireframes — Team Member Dashboard (0010a)

> **Coverage requirement**: every screen or interaction flow mentioned in `stories.md`
> must have a corresponding section below. Check stories.md before finalising this document.

---

## Team List Screen (US-001)

```mermaid
flowchart TD
    A["/team — Team List Page"] --> B{User role?}
    B -->|PeopleManager or Director| C[Fetch direct reports via GET /api/me/team]
    B -->|Other role| D[403 Forbidden page]
    C --> E{Reports found?}
    E -->|Yes| F["List of team member cards
    ─────────────────────────
    [Avatar] Full Name
             Job Title
    ─────────────────────────
    (click → /team/{employeeId})"]
    E -->|No| G["Empty state:
    'You have no direct reports.'"]
```

**Notes**
- Cards are listed alphabetically by last name.
- No pagination required — assumption: list fits on one screen for typical manager span of 2–15 reports.

---

## Team Member Dashboard Screen (US-002, US-003, US-010, US-011, US-012)

```mermaid
flowchart TD
    A["/team/{employeeId} — Dashboard"] --> B{Is direct report?}
    B -->|No| C[403 Forbidden]
    B -->|Yes| D["Header
    ─────────────────────────────────────────
    ← Back to Team   [Avatar] Full Name
                              Job Title · Position
    ─────────────────────────────────────────"]
    D --> E["Tab / Section Nav:
    [ Goals ] [ Feedback ] [ Skills ] [ Projects ]"]
    E --> F[Goals Section]
    E --> G[Feedback Section]
    E --> H[Skills Section]
    E --> I[Projects Section]
```

**Notes**
- Sections can be rendered as collapsible panels or tabs — layout decision left to UI implementation.
- The back link returns the manager to `/team`.

---

## Goals Section Layout (US-003, US-004, US-005, US-008, US-009)

```mermaid
flowchart TD
    A["Goals Section Header
    ─────────────────────────────
    Goals                [Suggest Goal ▶]
    ─────────────────────────────"] --> B{Goals exist?}
    B -->|No| C["Empty state: 'No goals yet.'"]
    B -->|Yes| D["Goal Card (repeated per goal)
    ─────────────────────────────────────────
    [Status badge] Goal Name            [▼ expand]
    Due: YYYY-MM-DD   Progress: 65%
    [Manager actions row — see below]
    ─────────────────────────────────────────"]
    D --> E{Goal status?}
    E -->|suggested| F["Badge: 'Suggested by you'
    Actions: [Delete]"]
    E -->|not_started or in_progress| G["Actions: [Mark as Completed] [Delete]
    (if deletion_request pending → [Approve Deletion] [Reject Deletion])"]
    E -->|achieved| H["Actions: [Delete]
    (if deletion_request pending → [Approve Deletion] [Reject Deletion])"]
    D --> I["Expanded view (on ▼ click):
    Description · Skill Category · Timeframe
    Tasks:
      ☑ Task name (completed)
      ☐ Task name (pending)"]
```

**Notes**
- The "Deletion Requested" label and Approve/Reject buttons replace normal actions when a pending deletion request exists.
- Suggested goals show the suggestion badge but no "Mark as Completed" action.
- The Delete action is always available to the manager regardless of status.

---

## Suggest Goal Form Flow (US-005)

```mermaid
sequenceDiagram
    actor Manager
    participant UI
    participant API

    Manager->>UI: Click "Suggest Goal"
    UI-->>Manager: Open modal form
    Manager->>UI: Fill name, description, skill category, timeframe, due date
    Manager->>UI: Click "Submit"
    UI->>API: POST /api/employees/{id}/goals
    alt Validation error
        API-->>UI: 400 with error details
        UI-->>Manager: Inline field errors
    else Success
        API-->>UI: 201 with new goal object
        UI-->>Manager: Close modal, prepend goal card (status: Suggested)
    end
```

---

## Accept / Reject Suggestion Flow — Employee View (US-006)

```mermaid
sequenceDiagram
    actor Employee
    participant UI
    participant API

    Note over UI: Employee goal list shows goal<br/>with "Suggested by [Manager]" badge
    Employee->>UI: Click "Accept"
    UI->>API: PATCH /api/goals/{id}/suggestion  {action: "accept"}
    API-->>UI: 200 with updated goal (status: not_started)
    UI-->>Employee: Remove suggestion badge, show normal goal card

    Employee->>UI: Click "Reject"
    UI->>API: PATCH /api/goals/{id}/suggestion  {action: "reject"}
    API-->>UI: 204 No Content
    UI-->>Employee: Remove goal card from list
```

---

## Goal Deletion Request Flow — Employee (US-007)

```mermaid
sequenceDiagram
    actor Employee
    participant UI
    participant API

    Employee->>UI: Click "Request Deletion" on a goal
    UI->>API: POST /api/goals/{id}/deletion-request
    API-->>UI: 201 Created
    UI-->>Employee: Goal card labelled "Deletion Requested"
                    Action changes to "Cancel Request"

    Employee->>UI: Click "Cancel Request"
    UI->>API: DELETE /api/goals/{id}/deletion-request
    API-->>UI: 204 No Content
    UI-->>Employee: Label removed, normal action buttons restored
```

---

## Goal Deletion Request Flow — Manager (US-008)

```mermaid
sequenceDiagram
    actor Manager
    participant UI
    participant API

    Note over UI: Goal card shows "Deletion Requested" label
    Manager->>UI: Click "Approve Deletion"
    UI->>API: PATCH /api/goals/{id}/deletion-request  {action: "approve"}
    API-->>UI: 204 No Content
    UI-->>Manager: Goal card removed from list

    Manager->>UI: Click "Reject Deletion"
    UI->>API: PATCH /api/goals/{id}/deletion-request  {action: "reject"}
    API-->>UI: 200 with updated goal
    UI-->>Manager: "Deletion Requested" label removed, normal actions restored
```

---

## Manager Direct Goal Deletion (US-009)

```mermaid
sequenceDiagram
    actor Manager
    participant UI
    participant API

    Manager->>UI: Click "Delete" on any goal
    UI-->>Manager: Confirmation dialog: "Delete this goal permanently?"
    Manager->>UI: Confirm
    UI->>API: DELETE /api/goals/{id}
    API-->>UI: 204 No Content
    UI-->>Manager: Goal card removed from list
```

---

## Feedback Section Layout (US-010)

```mermaid
flowchart TD
    A["Feedback Section"] --> B{Entries exist?}
    B -->|No| C["Empty state: 'No feedback received yet.'"]
    B -->|Yes| D["Feedback Entry (repeated, newest first)
    ─────────────────────────────────────────
    ★★★★☆  (rating / 5)
    Comment text...
    From: Submitter Name · Date: YYYY-MM-DD
    ─────────────────────────────────────────"]
```

---

## Skills Section Layout (US-011)

```mermaid
flowchart TD
    A["Skills Section"] --> B{Assessments exist?}
    B -->|No| C["Empty state: 'No skills assessed yet.'"]
    B -->|Yes| D["Skill Table
    ─────────────────────────────────────────────────
    Skill Name | Self-Assessment | Manager Assessment
    ─────────────────────────────────────────────────
    React       |      3         |        4
    TypeScript  |      2         | Not Assessed
    ─────────────────────────────────────────────────"]
    D --> E["Gap Analysis Panel (below table)
    ─────────────────────────────────────────
    Skills below target for [Position Name]:
    • TypeScript — current: 2 / required: 3
    ─────────────────────────────────────────"]
```

**Notes**
- Gap analysis panel is hidden if `GET /api/employees/{id}/gap-analysis` returns no gaps.

---

## Projects Section Layout (US-012)

```mermaid
flowchart TD
    A["Projects Section"] --> B{Assignments exist?}
    B -->|No| C["Empty state: 'No project assignments found.'"]
    B -->|Yes| D["Assignment Card (repeated)
    ─────────────────────────────────────────────
    [Current / Past badge]  Project Name
    Role: Senior Developer
    Start: 2025-01-01  End: Ongoing
    ─────────────────────────────────────────────"]
```

---

## Dashboard Screen — Loading and Error States

```mermaid
flowchart TD
    A[Navigate to /team/employeeId] --> B{Auth check}
    B -->|Not authenticated| C[Redirect to /login]
    B -->|Wrong role| D[403 page]
    B -->|Not a direct report| E[403 page]
    B -->|Authorized| F{API responses}
    F -->|Loading| G[Section skeletons / spinners per section]
    F -->|Partial error on one section| H["Section shows inline error message
    + Retry button for that section only"]
    F -->|All loaded| I[Populated dashboard]
```

**Notes**
- Each of the four sections loads independently; a failure in one section should not block the others.
- Empty state: shown per section when the data array is empty.
- Loading state: skeleton placeholder matching the section's expected height.
