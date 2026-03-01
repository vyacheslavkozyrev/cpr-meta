# API Contracts — 360-Degree Feedback (0006)

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

## POST /api/review-cycles

**Auth**: Required
**Role**: `Director`

Creates a new 360 review cycle in `draft` status for an employee in the Director's department.

### Request Body

```json
{
  "title": "string — cycle name, e.g. 'Q2 2026 360 Review'",
  "subject_employee_id": "uuid — the employee being reviewed",
  "description": "string|null — optional context for the cycle"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | Yes | 1–200 characters |
| `subject_employee_id` | Yes | Must be a valid, active employee in the Director's department |
| `description` | No | Max 2000 characters if provided |

### Response `201 Created`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string|null",
  "subject_employee_id": "uuid",
  "subject_display_name": "string",
  "department_id": "uuid",
  "status": "draft",
  "nominee_count": 0,
  "response_count": 0,
  "opened_at": null,
  "started_at": null,
  "closed_at": null,
  "created_at": "timestamptz",
  "created_by": "uuid"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.title` / `errors.validation.subject_employee_id` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.employee.not_found` |

---

## GET /api/review-cycles

**Auth**: Required
**Role**: `Director` (sees all cycles in their department), `PeopleManager` (sees cycles for direct reports), `Employee` (sees own cycles as subject)

Returns a paginated list of review cycles scoped to the caller's role.

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number (1-based) |
| `per_page` | integer | 20 | Items per page (max 100) |
| `status` | string | — | Filter by status: `draft`, `open`, `in_progress`, `closed` |
| `sort_dir` | string | `desc` | `asc` or `desc` (sorted by `created_at`) |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "subject_display_name": "string",
      "status": "draft|open|in_progress|closed",
      "nominee_count": 0,
      "response_count": 0,
      "created_at": "timestamptz",
      "closed_at": "timestamptz|null"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_items": 10,
    "total_pages": 1
  }
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.per_page_max` |
| 401 | Unauthorized | `errors.auth.required` |

---

## GET /api/review-cycles/{id}

**Auth**: Required
**Role**: `Director` (any cycle in their dept), `PeopleManager` (direct report's cycle), `Employee` (own cycle as subject)

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Review cycle identifier |

### Response `200 OK`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string|null",
  "subject_employee_id": "uuid",
  "subject_display_name": "string",
  "department_id": "uuid",
  "status": "draft|open|in_progress|closed",
  "nominee_count": 3,
  "response_count": 2,
  "opened_at": "timestamptz|null",
  "started_at": "timestamptz|null",
  "closed_at": "timestamptz|null",
  "created_at": "timestamptz",
  "created_by": "uuid"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.review_cycle.not_found` |

---

## PATCH /api/review-cycles/{id}/status

**Auth**: Required
**Role**: `Director`

Transitions the cycle through its lifecycle: `draft` → `open` → `in_progress` → `closed`.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Review cycle identifier |

### Request Body

```json
{
  "status": "string — target status: open | in_progress | closed"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `status` | Yes | One of: `open`, `in_progress`, `closed` |

**Allowed Transitions**

| From | To | Side Effects |
|------|----|-------------|
| `draft` | `open` | Sets `opened_at` |
| `open` | `in_progress` | Sets `started_at`; all nominees' status → `invited`; requires ≥ 2 nominees |
| `in_progress` | `closed` | Sets `closed_at` |

### Response `200 OK`

```json
{
  "id": "uuid",
  "title": "string",
  "status": "open|in_progress|closed",
  "opened_at": "timestamptz|null",
  "started_at": "timestamptz|null",
  "closed_at": "timestamptz|null"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.status` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.review_cycle.not_found` |
| 409 | Conflict | `errors.review_cycle.invalid_transition` |
| 422 | Unprocessable Entity | `errors.review_cycle.insufficient_nominees` |

---

## POST /api/review-cycles/{id}/nominees

**Auth**: Required
**Role**: `Employee` (own cycle only), `PeopleManager` (direct report's cycle only), `Director` (any dept cycle)

Adds a reviewer nominee to an `open` cycle.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Review cycle identifier |

### Request Body

```json
{
  "reviewer_employee_id": "uuid — the employee to add as a reviewer"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `reviewer_employee_id` | Yes | Must be a valid, active employee; must not be the cycle subject |

### Response `201 Created`

```json
{
  "id": "uuid",
  "cycle_id": "uuid",
  "reviewer_employee_id": "uuid",
  "reviewer_display_name": "string",
  "nominated_by": "uuid",
  "status": "pending",
  "created_at": "timestamptz"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.review_cycle.not_found` / `errors.employee.not_found` |
| 409 | Conflict | `errors.review_nominee.duplicate` / `errors.review_cycle.nominations_closed` |
| 422 | Unprocessable Entity | `errors.review_nominee.self_nomination` |

---

## DELETE /api/review-cycles/{id}/nominees/{nominee_id}

**Auth**: Required
**Role**: `Employee` (own cycle only), `PeopleManager` (direct report's cycle only), `Director` (any dept cycle)

Removes a nominee from an `open` cycle. Soft-deletes the nominee record.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Review cycle identifier |
| `nominee_id` | uuid | Nominee record identifier |

### Response `204 No Content`

No response body.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.review_cycle.not_found` / `errors.review_nominee.not_found` |
| 409 | Conflict | `errors.review_cycle.nominations_closed` |

---

## GET /api/review-cycles/{id}/nominees

**Auth**: Required
**Role**: `Director` (any dept cycle), `PeopleManager` (direct report's cycle), `Employee` (own cycle as subject)

Returns all nominees for a cycle.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Review cycle identifier |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "reviewer_employee_id": "uuid",
      "reviewer_display_name": "string",
      "nominated_by": "uuid",
      "nominated_by_display_name": "string",
      "status": "pending|invited|submitted",
      "created_at": "timestamptz"
    }
  ]
}
```

**Note**: `nominated_by` fields are omitted from the response when the caller is the subject `Employee`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.review_cycle.not_found` |

---

## POST /api/review-cycles/{id}/responses

**Auth**: Required
**Role**: Any authenticated user who is a nominated reviewer for the cycle

Submits feedback for a cycle that is `in_progress`.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Review cycle identifier |

### Request Body

```json
{
  "overall_rating": "integer — 1 to 5 inclusive",
  "comments": "string — substantive feedback text"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `overall_rating` | Yes | Integer 1–5 inclusive |
| `comments` | Yes | 10–2000 characters |

### Response `201 Created`

```json
{
  "id": "uuid",
  "cycle_id": "uuid",
  "nominee_id": "uuid",
  "overall_rating": 4,
  "comments": "string",
  "created_at": "timestamptz"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | `errors.validation.overall_rating` / `errors.validation.comments` |
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.review_cycle.not_found` |
| 409 | Conflict | `errors.review_response.already_submitted` / `errors.review_cycle.not_accepting_responses` |

---

## GET /api/review-cycles/{id}/results

**Auth**: Required
**Role**: `Employee` (own cycle — receives aggregated/anonymized view), `PeopleManager` (direct report's cycle — receives detailed view), `Director` (any dept cycle — receives detailed view)

Returns 360 results. The response shape differs based on the caller's role.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Review cycle identifier |

### Response `200 OK` — Aggregated (Employee view)

```json
{
  "view": "aggregated",
  "cycle_id": "uuid",
  "cycle_title": "string",
  "status": "closed",
  "average_rating": 4.2,
  "response_count": 5,
  "comments": [
    {
      "overall_rating": 4,
      "comments": "string — anonymized, no reviewer info"
    }
  ]
}
```

### Response `200 OK` — Detailed (PeopleManager / Director view)

```json
{
  "view": "detailed",
  "cycle_id": "uuid",
  "cycle_title": "string",
  "subject_display_name": "string",
  "status": "closed",
  "average_rating": 4.2,
  "response_count": 5,
  "responses": [
    {
      "reviewer_display_name": "string",
      "reviewer_employee_id": "uuid",
      "overall_rating": 4,
      "comments": "string",
      "submitted_at": "timestamptz"
    }
  ]
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.review_cycle.not_found` |
| 409 | Conflict | `errors.review_cycle.results_not_available` |

---

## GET /api/me/review-requests

**Auth**: Required
**Role**: Any authenticated user

Returns all 360 review cycles where the caller is a nominated reviewer with status `invited` and the cycle is `in_progress`. (Pending submissions.)

### Response `200 OK`

```json
{
  "data": [
    {
      "cycle_id": "uuid",
      "cycle_title": "string",
      "subject_display_name": "string",
      "nominee_status": "invited",
      "cycle_started_at": "timestamptz"
    }
  ]
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
