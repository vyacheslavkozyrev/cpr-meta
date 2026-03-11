# API Contracts — Skills Gap Analysis & Development Planning (0009)

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

## GET /api/me/gap-analysis

Returns a live skills gap analysis for the authenticated user, comparing their manager-approved skill assessments against the requirements of the next-level position in their career track.

**Auth**: Required
**Role**: Any authenticated user

### Response `200 OK`

```json
{
  "current_position": {
    "id": "uuid",
    "title": "string",
    "sort_order": 2,
    "career_track": {
      "id": "uuid",
      "title": "string"
    }
  },
  "next_position": {
    "id": "uuid",
    "title": "string",
    "sort_order": 3
  },
  "skill_gaps": [
    {
      "skill": {
        "id": "uuid",
        "title": "string",
        "category": {
          "id": "uuid",
          "title": "string"
        }
      },
      "required_level": {
        "id": "uuid",
        "title": "string",
        "value": 4
      },
      "actual_level": {
        "id": "uuid",
        "title": "string",
        "value": 2
      },
      "gap": 2,
      "is_mandatory": true,
      "assessment_source": "manager",
      "linked_goals": [
        {
          "id": "uuid",
          "title": "string",
          "progress_percentage": 45.0,
          "status": "in_progress"
        }
      ]
    }
  ],
  "summary": {
    "total_skills": 10,
    "skills_met": 4,
    "skills_with_gap": 6,
    "mandatory_gaps": 3
  }
}
```

**Response field notes**

| Field | Description |
|-------|-------------|
| `next_position` | `null` if the employee is already at the highest `sort_order` in their career track — in this case `skill_gaps` is `[]` and `summary` counts are all `0`. |
| `gap` | Integer: `required_level.value − actual_level.value`. Negative or zero means the requirement is met. |
| `assessment_source` | `"manager"` — `manager_assessment_value IS NOT NULL` on the employee's `employee_to_skill` row; `"default"` — `manager_assessment_value IS NULL`, minimum skill level used. (The `source` column no longer exists — superseded by feature 0010.) |
| `linked_goals` | Non-completed goals (`is_completed = false`) where `related_skill_id` matches the skill UUID. |

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 422 | Unprocessable Entity | `errors.gap_analysis.no_position_assigned` |

---

## GET /api/employees/{id}/gap-analysis

Returns a live skills gap analysis for a specific employee. Accessible by PeopleManagers (direct reports only), Directors (same department only), and Administrators (unrestricted).

**Auth**: Required
**Role**: `PeopleManager`, `Director`, `Administrator`

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Target employee UUID (`employees.id`) |

### Response `200 OK`

Same shape as `GET /api/me/gap-analysis`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | `errors.auth.required` |
| 403 | Forbidden | `errors.auth.forbidden` |
| 404 | Not Found | `errors.employee.not_found` |
| 422 | Unprocessable Entity | `errors.gap_analysis.no_position_assigned` |

**Authorization logic**

| Role | Allowed targets |
|------|----------------|
| `PeopleManager` | Employees where `employees.manager_id = caller's employees.id` |
| `Director` | Employees where `employees.department_id = caller's employees.department_id` |
| `Administrator` | Any employee |

---

## Goal Creation (Reused from F001)

Goal creation from a skill gap reuses the existing `POST /api/goals` endpoint (specified in F001). No new endpoint is added.

**Pre-populated fields supplied by the UI:**

| Field | Value |
|-------|-------|
| `employee_id` | Authenticated employee's UUID (own view) or direct report's UUID (manager view) |
| `title` | `"Improve [Skill Name] to [Required Level Title]"` |
| `related_skill_id` | UUID of the skill with the gap |
| `related_skill_level_id` | UUID of the required skill level |

All other fields (deadline, description, visibility, etc.) remain editable by the user in the modal before submission.
