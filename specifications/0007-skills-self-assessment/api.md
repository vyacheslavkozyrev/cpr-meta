# API Specification — Skills Self-Assessment (0007)

All endpoints require a valid bearer token. JSON fields use snake_case. URL paths use kebab-case.

---

## GET /api/me/skill-assessment

Returns the authenticated user's full skill self-assessment for their current position, including chart data.

**Auth**: Required — all roles.

**Success response** `200 OK`

```json
{
  "position": {
    "id": "uuid",
    "title": "Senior Software Engineer",
    "career_track": {
      "id": "uuid",
      "title": "Backend Engineering"
    },
    "career_path": {
      "id": "uuid",
      "title": "Engineering"
    }
  },
  "next_position": {
    "id": "uuid",
    "title": "Staff Software Engineer"
  },
  "skill_categories": [
    {
      "id": "uuid",
      "title": "Technical Skills",
      "skills": [
        {
          "skill_id": "uuid",
          "skill_title": "TypeScript",
          "skill_description": "...",
          "required_level": {
            "id": "uuid",
            "title": "Advanced",
            "value": 4
          },
          "next_position_required_level": {
            "id": "uuid",
            "title": "Expert",
            "value": 5
          },
          "assessed": {
            "id": "uuid",
            "skill_level_id": "uuid",
            "skill_level_title": "Intermediate",
            "skill_level_value": 3,
            "notes": "Led API migration in Q3"
          },
          "target": {
            "id": "uuid",
            "skill_level_id": "uuid",
            "skill_level_title": "Advanced",
            "skill_level_value": 4
          },
          "evidence": [
            {
              "id": "uuid",
              "feedback_id": "uuid",
              "sender_display_name": "Alice Johnson",
              "rating": 4,
              "content_excerpt": "Great job leading the API review..."
            }
          ]
        }
      ]
    }
  ]
}
```

`next_position` is `null` when the user is at the highest `sort_order` in their track.
`assessed` and `target` are `null` when no record exists.
`next_position_required_level` is `null` when next position does not require this skill.

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |

---

## PUT /api/me/skill-assessment/skills/{skill_id}

Upsert the authenticated user's **current** self-assessed level for a skill. Creates or updates the `employee_to_skill` record with `source = 'self'`, `is_target = FALSE`.

**Auth**: Required — all roles.

**Path parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `skill_id` | UUID | ID of the skill being assessed |

**Request body**

```json
{
  "skill_level_id": "uuid",
  "notes": "Optional free-text up to 1000 chars"
}
```

**Validation rules**

| Field | Required | Rules |
|-------|----------|-------|
| `skill_level_id` | Yes | Must be a valid `skill_levels.id` belonging to the given `skill_id` |
| `notes` | No | Max 1,000 characters |

**Business rules**
- `skill_id` must be in the user's current position's `position_to_skill` set; otherwise `404`.
- If a target level record exists and its `value ≤` the new current level's `value`, the response is `422` — the client must clear or raise the target first.

**Success response** `200 OK`

```json
{
  "id": "uuid",
  "skill_id": "uuid",
  "skill_level_id": "uuid",
  "skill_level_title": "Intermediate",
  "skill_level_value": 3,
  "notes": "Led API migration in Q3"
}
```

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |
| 404 | `skill_not_found` | `skill_id` not in user's position requirements |
| 422 | `invalid_level` | `skill_level_id` does not belong to this skill |
| 422 | `target_conflict` | Current level would equal or exceed existing target level |

---

## DELETE /api/me/skill-assessment/skills/{skill_id}

Remove the authenticated user's current self-assessed level for a skill (`source = 'self'`, `is_target = FALSE`). Soft-deletes the record.

**Auth**: Required — all roles.

**Path parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `skill_id` | UUID | ID of the skill |

**Success response** `204 No Content`

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |
| 404 | `assessment_not_found` | No current assessment record found for this skill |

---

## PUT /api/me/skill-assessment/skills/{skill_id}/target

Upsert the authenticated user's **target** level for a skill (`source = 'self'`, `is_target = TRUE`).

**Auth**: Required — all roles.

**Path parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `skill_id` | UUID | ID of the skill |

**Request body**

```json
{
  "skill_level_id": "uuid"
}
```

**Validation rules**

| Field | Required | Rules |
|-------|----------|-------|
| `skill_level_id` | Yes | Must be a valid `skill_levels.id` belonging to `skill_id`; value must be strictly greater than the current assessed level value (if one exists) |

**Success response** `200 OK`

```json
{
  "id": "uuid",
  "skill_id": "uuid",
  "skill_level_id": "uuid",
  "skill_level_title": "Advanced",
  "skill_level_value": 4
}
```

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |
| 404 | `skill_not_found` | `skill_id` not in user's position requirements |
| 422 | `invalid_level` | `skill_level_id` does not belong to this skill |
| 422 | `target_too_low` | Target level value must be strictly greater than current assessed level value |

---

## DELETE /api/me/skill-assessment/skills/{skill_id}/target

Remove the authenticated user's target level for a skill (`source = 'self'`, `is_target = TRUE`). Soft-deletes the record.

**Auth**: Required — all roles.

**Path parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `skill_id` | UUID | ID of the skill |

**Success response** `204 No Content`

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |
| 404 | `target_not_found` | No target record found for this skill |

---

## POST /api/me/skill-assessment/skills/{skill_id}/evidence

Link a received feedback item as evidence for the authenticated user's skill assessment.

**Auth**: Required — all roles.

**Path parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `skill_id` | UUID | ID of the skill |

**Request body**

```json
{
  "feedback_id": "uuid"
}
```

**Validation rules**

| Field | Required | Rules |
|-------|----------|-------|
| `feedback_id` | Yes | Must be a valid `feedback.id` where `to_employee_id = current employee`; must not already be linked to this skill |

**Business rules**
- The `employee_to_skill` record (`source = 'self'`, `is_target = FALSE`) must already exist for this skill before evidence can be linked; returns `422` if not.

**Success response** `201 Created`

```json
{
  "id": "uuid",
  "feedback_id": "uuid",
  "sender_display_name": "Alice Johnson",
  "rating": 4,
  "content_excerpt": "Great job leading the API review..."
}
```

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |
| 404 | `skill_not_found` | Skill not in user's position requirements |
| 404 | `feedback_not_found` | Feedback item not found or not addressed to current user |
| 422 | `assessment_required` | No current self-assessment exists for this skill; assess first |
| 422 | `already_linked` | Feedback item already linked to this skill |

---

## DELETE /api/me/skill-assessment/skills/{skill_id}/evidence/{feedback_id}

Unlink a feedback item from the skill assessment evidence.

**Auth**: Required — all roles.

**Path parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `skill_id` | UUID | ID of the skill |
| `feedback_id` | UUID | ID of the feedback item to unlink |

**Success response** `204 No Content`

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |
| 404 | `evidence_not_found` | Link does not exist |

---

## GET /api/employees/{employee_id}/skill-assessment

Read-only view of an employee's skill self-assessment. Accessible to PeopleManagers (direct reports only), Directors, and Administrators.

**Auth**: Required — `PeopleManager`, `Director`, `Administrator`.

**Authorization rules**
- `PeopleManager`: `employee_id` must be a direct report (`employees.manager_id = current employee id`).
- `Director` / `Administrator`: any employee.

**Path parameters**

| Parameter | Type | Description |
|-----------|------|-------------|
| `employee_id` | UUID | ID of the employee whose assessment is being viewed |

**Success response** `200 OK` — same shape as `GET /api/me/skill-assessment` plus a top-level `employee` object:

```json
{
  "employee": {
    "id": "uuid",
    "display_name": "Jane Smith"
  },
  "position": { ... },
  "next_position": { ... },
  "skill_categories": [ ... ]
}
```

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |
| 403 | `forbidden` | Caller does not have access to this employee's data |
| 404 | `employee_not_found` | Employee not found |

---

## GET /api/me/team/skill-assessment-summary

Returns a summary of all direct reports' skill assessments for the authenticated PeopleManager.

**Auth**: Required — `PeopleManager`.

**Success response** `200 OK`

```json
{
  "team": [
    {
      "employee_id": "uuid",
      "display_name": "Jane Smith",
      "position_title": "Senior Software Engineer",
      "total_required_skills": 10,
      "assessed_skill_count": 8,
      "skills_meeting_requirement_count": 6
    }
  ]
}
```

**Error responses**

| Status | Code | Description |
|--------|------|-------------|
| 401 | `unauthorized` | Missing or invalid token |
| 403 | `forbidden` | Caller does not have the `PeopleManager` role |
