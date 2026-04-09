# API Contracts — Project Team Management (0011)

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

## POST /api/projects

**Auth**: Required
**Role**: `SolutionOwner`, `Director`, `Administrator`

### Request Body

```json
{
  "code": "string — unique project code, e.g. PRJ-042",
  "title": "string — project name",
  "description": "string — optional",
  "status": "string — draft | active | completed | archived",
  "start_date": "date — ISO 8601 (YYYY-MM-DD), optional",
  "end_date": "date — ISO 8601 (YYYY-MM-DD), optional"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `code` | Yes | 1–20 characters; unique across non-deleted projects |
| `title` | Yes | 1–200 characters |
| `description` | No | max 2 000 characters |
| `status` | No | Enum: `draft`, `active`, `completed`, `archived`; defaults to `draft` |
| `start_date` | No | ISO date |
| `end_date` | No | ISO date; must be >= `start_date` when both provided |

### Response `201 Created`

```json
{
  "id": "uuid",
  "code": "string",
  "title": "string",
  "description": "string | null",
  "status": "draft",
  "start_date": "date | null",
  "end_date": "date | null",
  "owner_id": "uuid",
  "created_at": "timestamptz"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.code` / `errors.validation.title` / `errors.validation.end_date` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 409 | Conflict | `errors.project.code_conflict` |

---

## GET /api/projects

**Auth**: Required
**Role**: `SolutionOwner`, `Director`, `Administrator`

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number (1-based) |
| `per_page` | integer | 20 | Items per page (max 100) |
| `sort_by` | string | `created_at` | `title` or `created_at` |
| `sort_dir` | string | `desc` | `asc` or `desc` |
| `status` | string | — | Filter by status enum value |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "code": "string",
      "title": "string",
      "status": "string",
      "start_date": "date | null",
      "end_date": "date | null",
      "owner_id": "uuid"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_items": 45,
    "total_pages": 3
  }
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.per_page_max` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |

---

## GET /api/projects/{id}

**Auth**: Required
**Role**: `SolutionOwner`, `Director`, `Administrator`

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |

### Response `200 OK`

```json
{
  "id": "uuid",
  "code": "string",
  "title": "string",
  "description": "string | null",
  "status": "string",
  "start_date": "date | null",
  "end_date": "date | null",
  "owner_id": "uuid",
  "created_at": "timestamptz"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` |

---

## PATCH /api/projects/{id}

**Auth**: Required
**Role**: `SolutionOwner` (own projects only), `Director`, `Administrator`

All fields optional — only provided fields are updated.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |

### Request Body

```json
{
  "title": "string — optional",
  "description": "string — optional",
  "status": "string — draft | active | completed | archived, optional",
  "start_date": "date — ISO 8601, optional",
  "end_date": "date — ISO 8601, optional"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | No | 1–200 characters if provided |
| `description` | No | max 2 000 characters if provided |
| `status` | No | Enum: `draft`, `active`, `completed`, `archived` |
| `start_date` | No | ISO date |
| `end_date` | No | ISO date; must be >= `start_date` when both provided or when one is already persisted |
| `code` | — | Not accepted; returns 400 if included |

### Response `200 OK`

Same shape as GET /api/projects/{id}.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.code_immutable` / `errors.validation.end_date` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` |

---

## DELETE /api/projects/{id}

**Auth**: Required
**Role**: `SolutionOwner` (own projects only), `Director`, `Administrator`

Soft-deletes the project (`is_deleted = true`). Associated roles and team assignments are **not** cascaded.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |

### Response `204 No Content`

No response body.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` |

---

## GET /api/projects/{id}/roles

**Auth**: Required
**Role**: `SolutionOwner`, `Director`, `Administrator`

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |

### Response `200 OK`

```json
[
  {
    "id": "uuid",
    "project_id": "uuid",
    "title": "string",
    "description": "string | null",
    "member_count": 3
  }
]
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` |

---

## POST /api/projects/{id}/roles

**Auth**: Required
**Role**: `SolutionOwner` (own projects only), `Director`, `Administrator`

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |

### Request Body

```json
{
  "title": "string — role name, e.g. Tech Lead",
  "description": "string — optional"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | Yes | 1–100 characters |
| `description` | No | max 500 characters |

### Response `201 Created`

```json
{
  "id": "uuid",
  "project_id": "uuid",
  "title": "string",
  "description": "string | null"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.title` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` |

---

## PATCH /api/projects/{id}/roles/{roleId}

**Auth**: Required
**Role**: `SolutionOwner` (own projects only), `Director`, `Administrator`

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |
| `roleId` | uuid | Project role identifier |

### Request Body

```json
{
  "title": "string — optional",
  "description": "string — optional"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | No | 1–100 characters if provided |
| `description` | No | max 500 characters if provided |

### Response `200 OK`

Same shape as POST response.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.title` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` / `errors.project_role.not_found` |

---

## DELETE /api/projects/{id}/roles/{roleId}

**Auth**: Required
**Role**: `SolutionOwner` (own projects only), `Director`, `Administrator`

Soft-deletes the role. Fails with 409 if the role has non-deleted `project_teams` assignments.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |
| `roleId` | uuid | Project role identifier |

### Response `204 No Content`

No response body.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` / `errors.project_role.not_found` |
| 409 | Conflict | `errors.project_role.has_active_members` |

---

## GET /api/projects/{id}/team

**Auth**: Required
**Role**: `SolutionOwner`, `Director`, `Administrator`

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `as_of` | date (ISO 8601) | — | When provided, returns only assignments active on that date |

### Response `200 OK`

```json
[
  {
    "role": {
      "id": "uuid",
      "title": "string"
    },
    "assignments": [
      {
        "id": "uuid",
        "employee_id": "uuid",
        "display_name": "string",
        "start_date": "date | null",
        "end_date": "date | null",
        "is_current": true
      }
    ]
  }
]
```

**`is_current` logic**: `true` when today falls within `[start_date, end_date]` (inclusive), or when `start_date <= today` and `end_date IS NULL`, or when both dates are null.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` |

---

## POST /api/projects/{id}/roles/{roleId}/members

**Auth**: Required
**Role**: `SolutionOwner` (own projects only), `Director`, `Administrator`

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |
| `roleId` | uuid | Project role identifier |

### Request Body

```json
{
  "employee_id": "uuid — required",
  "start_date": "date — ISO 8601, optional",
  "end_date": "date — ISO 8601, optional"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `employee_id` | Yes | Must reference an existing, non-deleted employee |
| `start_date` | No | ISO date |
| `end_date` | No | ISO date; must be >= `start_date` when both provided |

### Response `201 Created`

```json
{
  "id": "uuid",
  "project_role_id": "uuid",
  "employee_id": "uuid",
  "display_name": "string",
  "start_date": "date | null",
  "end_date": "date | null",
  "is_current": true
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.employee_id` / `errors.validation.end_date` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` / `errors.project_role.not_found` / `errors.employee.not_found` |
| 409 | Conflict | `errors.project_member.overlap` |

---

## PATCH /api/projects/{id}/roles/{roleId}/members/{memberId}

**Auth**: Required
**Role**: `SolutionOwner` (own projects only), `Director`, `Administrator`

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |
| `roleId` | uuid | Project role identifier |
| `memberId` | uuid | Project team assignment identifier |

### Request Body

```json
{
  "start_date": "date — ISO 8601, optional",
  "end_date": "date — ISO 8601, optional"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `start_date` | No | ISO date |
| `end_date` | No | ISO date; resulting range must satisfy end_date >= start_date and must not overlap another active assignment of the same employee to the same role |

### Response `200 OK`

Same shape as POST /members response.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.end_date` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` / `errors.project_role.not_found` / `errors.project_member.not_found` |
| 409 | Conflict | `errors.project_member.overlap` |

---

## DELETE /api/projects/{id}/roles/{roleId}/members/{memberId}

**Auth**: Required
**Role**: `SolutionOwner` (own projects only), `Director`, `Administrator`

Soft-deletes the team assignment. The record is retained for historical queries.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Project identifier |
| `roleId` | uuid | Project role identifier |
| `memberId` | uuid | Project team assignment identifier |

### Response `204 No Content`

No response body.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.project.not_found` / `errors.project_role.not_found` / `errors.project_member.not_found` |

---

## GET /api/me/project-assignments

**Auth**: Required
**Role**: Any authenticated user

Returns all non-deleted project assignments for the authenticated user's `employee_id`.

### Response `200 OK`

```json
[
  {
    "id": "uuid",
    "project": {
      "id": "uuid",
      "code": "string",
      "title": "string",
      "status": "string",
      "start_date": "date | null",
      "end_date": "date | null"
    },
    "role": {
      "id": "uuid",
      "title": "string"
    },
    "start_date": "date | null",
    "end_date": "date | null",
    "is_current": true
  }
]
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |

---

## GET /api/employees/{id}/project-assignments

**Auth**: Required
**Role**: `SolutionOwner`, `Director`, `Administrator`; `PeopleManager` (direct reports only)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Target employee identifier |

### Response `200 OK`

Same shape as GET /api/me/project-assignments.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.employee.not_found` |
