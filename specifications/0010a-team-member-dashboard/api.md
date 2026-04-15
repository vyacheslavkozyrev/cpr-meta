# API Contracts — Team Member Dashboard (0010a)

## Error Response Format (RFC 7807 ProblemDetails)

All error responses use this shape:

```json
{
  "type": "https://tools.ietf.org/html/rfc7807",
  "title": "Validation Failed",
  "status": 400,
  "detail": "errors.validation.[field]"
}
```

The `detail` field always contains an **i18n key**, never hardcoded English text.

---

## Reused Endpoints (no changes required)

The following endpoints defined in earlier features are consumed as-is by this feature.
No contract changes are needed — role-access already permits PeopleManager/Director.

| Endpoint | Defined in |
|----------|------------|
| `GET /api/employees/{id}/skill-assessment` | F010 — Skill Assessment Schema Refactor |
| `GET /api/employees/{id}/gap-analysis` | F009 — Skills Gap Analysis |
| `GET /api/employees/{id}/project-assignments` | F011 — Project Team Management |

---

## New Endpoints

---

### GET /api/me/team

Returns the list of employees who report directly to the authenticated user.

**Auth**: Required
**Role**: `PeopleManager`, `Director`

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "full_name": "string",
      "job_title": "string",
      "position_id": "uuid",
      "position_name": "string"
    }
  ]
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |

---

### GET /api/employees/{id}/goals

> **Supersedes F005**: F005 registered this path for fetching an employee's goal list for feedback context. This F0010a contract is the authoritative definition. The richer response shape (adds `suggested_by_id`, `suggested_by_name`, `has_pending_deletion_request`, `tasks[]`) is backward-compatible — consumers only need to add new fields; no existing fields are removed or renamed.

Returns all non-deleted goals (including `suggested` status and goals with pending deletion requests) for the specified employee. Accessible by the employee's direct manager or Director.

**Auth**: Required
**Role**: `PeopleManager` or `Director` (must be the employee's direct manager); or `Employee` (own goals only — for suggested goal visibility)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Target employee's user id |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "name": "string",
      "description": "string | null",
      "status": "not_started | in_progress | completed | suggested",
      "timeframe": "week | month | quarter | year",
      "due_date": "date | null",
      "progress_percentage": 0,
      "skill_category_id": "uuid | null",
      "skill_category_name": "string | null",
      "suggested_by_id": "uuid | null",
      "suggested_by_name": "string | null",
      "has_pending_deletion_request": false,
      "tasks": [
        {
          "id": "uuid",
          "name": "string",
          "is_completed": false
        }
      ]
    }
  ]
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.employee.not_found |

---

### POST /api/employees/{id}/goals

Creates a new goal with `status = suggested` on behalf of the target employee. Used by managers to suggest goals.

**Auth**: Required
**Role**: `PeopleManager` or `Director` (must be the employee's direct manager)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Target employee's user id |

### Request Body

```json
{
  "name": "string",
  "description": "string | null",
  "skill_category_id": "uuid | null",
  "timeframe": "week | month | quarter | year",
  "due_date": "date | null"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `name` | Yes | 1–200 characters |
| `description` | No | max 2000 characters if provided |
| `skill_category_id` | No | Must reference a valid skill category if provided |
| `timeframe` | Yes | One of: `week`, `month`, `quarter`, `year` |
| `due_date` | No | ISO 8601 date; must be today or future if provided |

### Response `201 Created`

```json
{
  "id": "uuid",
  "name": "string",
  "description": "string | null",
  "status": "suggested",
  "timeframe": "week | month | quarter | year",
  "due_date": "date | null",
  "progress_percentage": 0,
  "skill_category_id": "uuid | null",
  "skill_category_name": "string | null",
  "suggested_by_id": "uuid",
  "suggested_by_name": "string",
  "has_pending_deletion_request": false,
  "tasks": []
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.[field] |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.employee.not_found |

---

### PATCH /api/goals/{id}/suggestion

Allows the goal owner (employee) to accept or reject a suggested goal.

**Auth**: Required
**Role**: `Employee` (must be the `user_id` of the goal)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Goal id |

### Request Body

```json
{
  "action": "accept | reject"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `action` | Yes | One of: `accept`, `reject` |

### Response — Accept `200 OK`

```json
{
  "id": "uuid",
  "status": "not_started",
  "suggested_by_id": "uuid"
}
```

### Response — Reject `204 No Content`

No response body.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.action |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.goal.not_found |
| 409 | Conflict | errors.goal.not_suggested |

---

### POST /api/goals/{id}/deletion-request

Creates a deletion request for a goal. The goal owner (employee) uses this to request manager approval for deletion.

**Auth**: Required
**Role**: `Employee` (must be the `user_id` of the goal)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Goal id |

### Response `201 Created`

```json
{
  "id": "uuid",
  "goal_id": "uuid",
  "status": "pending",
  "created_at": "datetime"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.goal.not_found |
| 409 | Conflict | errors.goal.deletion_request_already_pending |

---

### DELETE /api/goals/{id}/deletion-request

Cancels a pending deletion request. Used by the employee to withdraw their request.

**Auth**: Required
**Role**: `Employee` (must be the `user_id` of the goal)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Goal id |

### Response `204 No Content`

No response body.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.goal.not_found |
| 409 | Conflict | errors.goal.no_pending_deletion_request |

---

### PATCH /api/goals/{id}/deletion-request

Manager approves or rejects a pending deletion request.

**Auth**: Required
**Role**: `PeopleManager` or `Director` (must be the employee's direct manager)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Goal id |

### Request Body

```json
{
  "action": "approve | reject"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `action` | Yes | One of: `approve`, `reject` |

### Response — Approve `204 No Content`

No response body. (Goal is soft-deleted.)

### Response — Reject `200 OK`

```json
{
  "id": "uuid",
  "status": "not_started | in_progress | completed",
  "has_pending_deletion_request": false
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.action |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.goal.not_found |
| 409 | Conflict | errors.goal.no_pending_deletion_request |

---

### GET /api/employees/{id}/feedback

Returns all feedback entries received by the specified employee. Accessible by the employee's direct manager or Director.

**Auth**: Required
**Role**: `PeopleManager` or `Director` (must be the employee's direct manager)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Target employee's user id |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "rating": 4,
      "comment": "string | null",
      "submitted_by_id": "uuid",
      "submitted_by_name": "string",
      "created_at": "datetime"
    }
  ]
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.employee.not_found |

---

## Modified Endpoints

---

### PATCH /api/goals/{id} — Extended

Existing endpoint defined in F001. Extended to allow `PeopleManager` and `Director` to set `status = completed` on a direct report's goal ("Mark as Completed").

**Auth**: Required
**Role**: `Employee` (own goals, all fields) **or** `PeopleManager` / `Director` (direct reports' goals, `status` field only)

> All existing request/response fields remain unchanged. The only addition is that a manager may send `{ "status": "completed" }` for a goal belonging to their direct report. Any other field update by a non-owner returns `403 Forbidden`.
> Authorization broadened from F001's "Admin only" to include `PeopleManager` and `Director` for direct-report goals.

---

### DELETE /api/goals/{id} — Extended

Existing endpoint defined in F001. Extended to allow `PeopleManager` and `Director` to delete a direct report's goal directly.

**Auth**: Required
**Role**: `Employee` (own goals) **or** `PeopleManager` / `Director` (direct reports' goals)

> All existing behavior is unchanged. When a manager deletes a goal that has a pending `goal_deletion_requests` record, the API resolves that record with `status = approved` as part of the same operation.
> Authorization broadened from F001's "Admin only" to include `PeopleManager` and `Director` for direct-report goals.
