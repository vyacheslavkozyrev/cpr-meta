# Wireframes — 360-Degree Feedback (0006)

> **Coverage requirement**: every screen or interaction flow mentioned in `stories.md`
> must have a corresponding section below. Check stories.md before finalising this document.

---

## Director: Create Review Cycle (US-001)

```mermaid
flowchart TD
    A[Director: My Department Cycles] -->|Click 'New 360 Cycle'| B[Create Cycle Form]
    B --> C{Form Valid?}
    C -->|No| D[Inline validation errors]
    D --> B
    C -->|Yes| E[POST /api/review-cycles]
    E -->|201 Created| F[Cycle created — status: draft]
    F --> G[Redirect to Cycle Detail page]
    E -->|403 Forbidden| H[Error: subject not in your department]
    H --> B
```

**Notes**
- Fields: `title` (required, max 200 chars), `subject_employee_id` (required, searchable dropdown of dept employees), `description` (optional, max 2000 chars).
- The employee picker only shows employees within the Director's department.
- On creation the cycle lands in `draft` status — no reviewers can be added yet.

---

## Director: Cycle List (US-011)

```mermaid
flowchart TD
    A[Director: Department 360 Cycles] --> B{Cycles available?}
    B -->|Loading| C[Skeleton rows]
    B -->|Empty| D[Empty state: 'No cycles yet — create one']
    B -->|Success| E[Paginated table]
    E --> F[Row: title · subject · status badge · nominees · responses · created date]
    F -->|Click row| G[Cycle Detail]
    E --> H[Filter by status dropdown]
    E --> I['New 360 Cycle' button → Create form]
```

**Notes**
- Status badge colours: draft=grey, open=blue, in_progress=amber, closed=green.
- Default sort: `created_at` descending.

---

## Employee: My Cycles List (US-012)

```mermaid
flowchart TD
    A[Employee: My 360 Reviews] --> B{Cycles available?}
    B -->|Loading| C[Skeleton rows]
    B -->|Empty| D[Empty state: 'No 360 reviews have been started for you yet']
    B -->|Success| E[Paginated table]
    E --> F[Row: title · status badge · nominees · responses · created date]
    F -->|Click row — closed only| G[My Results view aggregated]
    F -->|Click row — non-closed| H[Cycle status info read-only]
    E --> I[Filter by status dropdown]
```

**Notes**
- Employee cannot create a cycle; the 'New' button is hidden.
- Clicking a non-closed cycle shows cycle title, status, and nominee count (read-only).
- Results link is only active for `closed` cycles.

---

## Cycle Detail — Nominations Panel (US-003, US-004, US-005)

```mermaid
flowchart TD
    A[Cycle Detail Page] --> B[Header: title · subject name · status badge]
    A --> C[Status Transition Controls — Director only]
    A --> D[Nominees Panel]

    C --> C1{Current Status}
    C1 -->|draft| C2['Open for Nominations' button]
    C1 -->|open| C3['Start Review' button]
    C1 -->|in_progress| C4['Close Cycle' button]
    C1 -->|closed| C5[No actions available]

    C2 -->|Click| C6[PATCH status → open]
    C3 -->|Click| C7{At least 2 nominees?}
    C7 -->|No| C8[Error toast: minimum 2 nominees required]
    C7 -->|Yes| C9[PATCH status → in_progress]
    C4 -->|Click| C10[Confirm dialog → PATCH status → closed]

    D --> D1{Cycle status = open?}
    D1 -->|Yes — Employee subject or PeopleManager| D2[Add Nominee form]
    D1 -->|No or no permission| D3[Read-only nominee list]
    D2 --> D4[Nominee employee search input]
    D4 -->|Submit| D5[POST /api/review-cycles/id/nominees]
    D5 -->|201| D6[Nominee added to list]
    D5 -->|409 duplicate| D7[Error: already nominated]
    D5 -->|422 self-nomination| D8[Error: cannot nominate yourself]
    D3 --> D9[List rows: name · status badge · nominated by]
    D9 -->|status=open| D10[Remove button → DELETE nominee]
```

**Notes**
- "Add Nominee" form shows only when cycle is `open` AND the current user is the subject employee OR their PeopleManager OR a Director.
- Nominee status badges: pending=grey, invited=blue, submitted=green.
- Director sees all nominee rows; PeopleManager sees all rows for direct report's cycle; Employee sees rows but without `nominated_by` details.
- Remove button visible only while cycle is `open`.

---

## Status Transition Flow (US-002, US-005, US-007)

```mermaid
sequenceDiagram
    actor Director
    participant UI
    participant API

    Director->>UI: Click 'Open for Nominations'
    UI->>API: PATCH /api/review-cycles/{id}/status {status: "open"}
    API-->>UI: 200 OK — updated cycle
    UI-->>Director: Status badge updates to 'Open'

    Director->>UI: Click 'Start Review'
    UI->>API: PATCH /api/review-cycles/{id}/status {status: "in_progress"}
    API-->>UI: 200 OK — updated cycle; all nominees → invited
    UI-->>Director: Status badge updates to 'In Progress'

    Director->>UI: Click 'Close Cycle' + confirm dialog
    UI->>API: PATCH /api/review-cycles/{id}/status {status: "closed"}
    API-->>UI: 200 OK — updated cycle
    UI-->>Director: Status badge updates to 'Closed'; results now accessible
```

---

## Reviewer: Pending Review Requests (US-013)

```mermaid
flowchart TD
    A[Reviewer: My Pending 360 Requests] --> B{Requests available?}
    B -->|Loading| C[Skeleton rows]
    B -->|Empty| D[Empty state: 'You have no pending 360 reviews to submit']
    B -->|Success| E[List of pending requests]
    E --> F[Row: cycle title · subject display name · status badge = Invited]
    F -->|Click| G[Reviewer Submission Form]
```

**Notes**
- Only shows requests where nominee status is `invited` and cycle is `in_progress`.
- Subject display name shown; no email or personal identifiers.
- Accessible from a global navigation item ("My Reviews").

---

## Reviewer: Submission Form (US-006)

```mermaid
sequenceDiagram
    actor Reviewer
    participant UI
    participant API

    Reviewer->>UI: Open submission form for a cycle
    UI->>API: GET /api/review-cycles/{id} (to show subject name + title)
    API-->>UI: 200 OK — cycle details
    UI-->>Reviewer: Form with: subject name, overall_rating (1–5 stars), comments textarea

    Reviewer->>UI: Fill in rating and comments, click Submit
    UI->>API: POST /api/review-cycles/{id}/responses {overall_rating, comments}
    API-->>UI: 201 Created
    UI-->>Reviewer: Success message — redirect to Pending Reviews list
    Note over UI,API: Nominee status updated to 'submitted' server-side
```

**Notes**
- Rating rendered as a 1–5 star selector; required.
- Comments textarea: min 10, max 2000 chars; character counter shown.
- Submit is disabled until both fields are valid.
- If cycle status is no longer `in_progress` (race condition), API returns 409 and UI shows error toast.

---

## Reviewer: Submission Form — States

```mermaid
flowchart TD
    A[Load Submission Form] --> B{Cycle data available?}
    B -->|Loading| C[Skeleton form]
    B -->|Error 403 not nominated| D[Error: You are not nominated for this cycle]
    B -->|Error 409 already submitted| E[Message: You have already submitted feedback for this cycle]
    B -->|Error 409 not in_progress| F[Message: This review cycle is no longer accepting responses]
    B -->|Success| G[Populated form — rating + comments]
```

---

## Employee: Aggregated Results View (US-008)

```mermaid
flowchart TD
    A[Employee clicks closed cycle] --> B[GET /api/review-cycles/id/results]
    B -->|Loading| C[Skeleton]
    B -->|409 not closed| D[Message: Results not yet available]
    B -->|403| E[Error: Access denied]
    B -->|200| F[Results Dashboard]

    F --> G[Average Rating — numeric + star display]
    F --> H[Response Count badge]
    F --> I[Anonymized Comments list]
    I --> J[Comment card: rating stars · comment text — no reviewer name]
```

**Notes**
- No reviewer names, roles, or IDs shown in any part of this view.
- If response count is 0 (edge case — cycle closed with no responses), show: "No feedback was submitted for this cycle."
- Comments displayed in random order to further protect anonymity.

---

## Manager / Director: Detailed Results View (US-009, US-010)

```mermaid
flowchart TD
    A[Manager or Director opens a closed cycle result] --> B[GET /api/review-cycles/id/results]
    B -->|Loading| C[Skeleton]
    B -->|409 not closed| D[Message: Results not yet available]
    B -->|403| E[Error: Access denied]
    B -->|200| F[Detailed Results Dashboard]

    F --> G[Summary: Average Rating · Response Count]
    F --> H[Individual Responses table]
    H --> I[Row: reviewer display name · rating stars · comments]
    F --> J[Subject info: name · department · position]
```

**Notes**
- Reviewer display names are shown in full (attributed view).
- PeopleManager sees this for direct reports only.
- Director sees this for all employees in their department.
- Empty state (no responses): "No reviewers submitted feedback before the cycle was closed."
