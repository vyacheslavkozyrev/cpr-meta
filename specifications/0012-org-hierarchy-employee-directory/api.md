# API Contracts — Org Hierarchy & Employee Directory (0012)

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

## Shared Types

### `EmployeeSummary`

Used in directory listings and as linked cards inside profile responses.

```json
{
  "id": "uuid",
  "display_name": "string",
  "position_title": "string | null",
  "department_name": "string | null",
  "avatar_url": "string | null"
}
```

### `OrgNode`

Used inside org chart responses.

```json
{
  "id": "uuid",
  "display_name": "string",
  "position_title": "string | null",
  "department_name": "string | null",
  "avatar_url": "string | null"
}
```

---

## GET /api/employees/{id} — Employee Profile

**Auth**: Required  
**Role**: Any authenticated user

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Employee identifier |

### Response `200 OK`

```json
{
  "id": "uuid",
  "display_name": "string",
  "user_name": "string",
  "phone": "string | null",
  "avatar_url": "string | null",
  "hire_date": "date | null",
  "position_id": "uuid | null",
  "position_title": "string | null",
  "department_id": "uuid | null",
  "department_name": "string | null",
  "location_id": "uuid | null",
  "location_city": "string | null",
  "location_country": "string | null",
  "career_path_title": "string | null",
  "career_track_title": "string | null",
  "roles": ["string"],
  "manager": {
    "id": "uuid",
    "display_name": "string",
    "position_title": "string | null",
    "avatar_url": "string | null"
  },
  "direct_reports": [
    {
      "id": "uuid",
      "display_name": "string",
      "position_title": "string | null",
      "avatar_url": "string | null"
    }
  ]
}
```

**Notes**:
- `manager` is `null` when the employee has no manager (root node).
- `direct_reports` is an empty array `[]` when no direct reports exist.
- `career_path_title` and `career_track_title` are derived from the employee's current `position_id` via the career track → career path chain; null if position is unassigned.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 404 | Not Found | `errors.employees.not_found` |

---

## GET /api/org-chart/{employee_id} — Org Context (Centred View)

Returns the org context centred on a specific employee: their manager's manager, their manager, the employee themselves, peers (siblings), and their direct reports.

Used for both "My View" (where `employee_id` = the calling user's employee ID) and viewing another employee's context via the "View in org chart" button on a profile page.

**Auth**: Required  
**Role**: Any authenticated user

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `employee_id` | uuid | The employee to centre the view on |

### Response `200 OK`

```json
{
  "self": {
    "id": "uuid",
    "display_name": "string",
    "position_title": "string | null",
    "department_name": "string | null",
    "avatar_url": "string | null"
  },
  "managers_manager": {
    "id": "uuid",
    "display_name": "string",
    "position_title": "string | null",
    "department_name": "string | null",
    "avatar_url": "string | null"
  },
  "manager": {
    "id": "uuid",
    "display_name": "string",
    "position_title": "string | null",
    "department_name": "string | null",
    "avatar_url": "string | null"
  },
  "peers": [
    {
      "id": "uuid",
      "display_name": "string",
      "position_title": "string | null",
      "department_name": "string | null",
      "avatar_url": "string | null"
    }
  ],
  "direct_reports": [
    {
      "id": "uuid",
      "display_name": "string",
      "position_title": "string | null",
      "department_name": "string | null",
      "avatar_url": "string | null"
    }
  ]
}
```

**Notes**:
- `managers_manager` is `null` when the employee's manager has no manager.
- `manager` is `null` when the employee is a root node; in that case `peers` is `[]`.
- `peers` includes all employees who share the same manager, **excluding** the centred employee themselves.
- `direct_reports` is `[]` when the employee has no direct reports.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 404 | Not Found | `errors.employees.not_found` |

---

## GET /api/org-chart — Full Company Tree

Returns the full company org chart as a hierarchical tree. All nodes are included in a single response; the client handles expand/collapse in memory.

**Auth**: Required  
**Role**: Any authenticated user

### Response `200 OK`

Returns an array of root nodes (employees with no manager), each with a recursive `children` structure.

```json
[
  {
    "id": "uuid",
    "display_name": "string",
    "position_title": "string | null",
    "department_name": "string | null",
    "avatar_url": "string | null",
    "children": [
      {
        "id": "uuid",
        "display_name": "string",
        "position_title": "string | null",
        "department_name": "string | null",
        "avatar_url": "string | null",
        "children": []
      }
    ]
  }
]
```

**Notes**:
- Leaf nodes have `children: []`.
- Most companies have a single root; the response is an array to handle edge cases (e.g. multiple orphan top-level employees during data migration).

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
