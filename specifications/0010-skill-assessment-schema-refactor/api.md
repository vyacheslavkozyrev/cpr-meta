# Feature 0010 — API Contract Changes

## Summary of Changes

| Endpoint | Change |
|----------|--------|
| `GET /api/me/skill-assessment` | Response: add `self_assessment_value`, remove `target_level`, remove `weight` |
| `PUT /api/me/skill-assessment/skills/{skillId}` | Request: add required `self_assessment_value`; Response: same updates as GET |
| `DELETE /api/me/skill-assessment/skills/{skillId}` | No change to contract |
| `POST /api/me/skill-assessment/skills/{skillId}/evidence` | No change to contract |
| `DELETE /api/me/skill-assessment/skills/{skillId}/evidence/{feedbackId}` | No change to contract |
| `PUT /api/me/skill-assessment/skills/{skillId}/target` | **REMOVED** |
| `DELETE /api/me/skill-assessment/skills/{skillId}/target` | **REMOVED** |
| `GET /api/employees/{employeeId}/skill-assessment` | Response: add `self_assessment_value`, `manager_assessment_value`, remove `target_level`, remove `weight` |
| `PUT /api/employees/{employeeId}/skill-assessment/skills/{skillId}/manager-assessment` | **NEW** |
| `GET /api/me/team/skill-assessment-summary` | Response: remove `weight` |
| `PATCH /api/taxonomy/positions/{id}/skills/{position_skill_id}` | Request/Response: remove `weight` |
| `POST /api/taxonomy/positions/{id}/skills` | Request/Response: remove `weight` |

---

## Shared Response Shape — SkillItem

Every skill assessment GET endpoint returns skill items in this shape. Changes from current contract are marked.

```json
{
  "skill_id": "uuid",
  "skill_title": "string",
  "skill_description": "string | null",
  "required_level": {
    "id": "uuid",
    "title": "string",
    "value": 1
  },
  "next_position_required_level": { "id": "uuid", "title": "string", "value": 2 },
  "assessed": {
    "self_assessment_value": 3.5,     // RENAMED from persist_value; numeric, not null when row exists
    "manager_assessment_value": 4.0,  // NEW; numeric or null
    "notes": "string | null"
    // skill_level_id / skill_level_title / skill_level_value REMOVED from assessed object
  },
  // target_level REMOVED
  "evidence": [
    {
      "feedback_id": "uuid",
      "sender_display_name": "string",
      "rating": 4,
      "feedback_content": "string"
    }
  ]
}
```

**Note:** `assessed` is `null` if no self-assessment row exists for the skill. `manager_assessment_value` inside `assessed` is `null` until a manager sets it.

---

## 1. GET /api/me/skill-assessment

**Auth**: Any authenticated user
**Role**: None (own data)

### Response — 200 OK

```json
{
  "position": {
    "id": "uuid",
    "title": "string",
    "career_track": { "id": "uuid", "title": "string" },
    "career_path":  { "id": "uuid", "title": "string" }
  },
  "next_position": { "id": "uuid", "title": "string" } ,
  "employee": null,
  "skill_categories": [
    {
      "id": "uuid",
      "title": "string",
      "skills": [ /* SkillItem — see shared shape above */ ]
    }
  ]
}
```

### Errors

| Status | Condition |
|--------|-----------|
| 401 | Not authenticated |

---

## 2. PUT /api/me/skill-assessment/skills/{skillId}

**Auth**: Any authenticated user
**Role**: None (own data)

### Request Body

```json
{
  "self_assessment_value": 3.5,
  "notes": "string | null"
}
```

### Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| `self_assessment_value` | Yes | Numeric; must be > 0 |
| `notes` | No | Max 1000 characters |

### Response — 200 OK

Returns the full `SkillAssessmentResponseDto` (same shape as GET /api/me/skill-assessment).

### Errors

| Status | Condition |
|--------|-----------|
| 400 | Validation failure (`self_assessment_value` missing / ≤ 0; invalid `skill_level_id`) |
| 401 | Not authenticated |
| 404 | Skill not found or not required by the employee's current position |

---

## 3. DELETE /api/me/skill-assessment/skills/{skillId}

No contract change. Returns `204 No Content`.

---

## 4. PUT /api/me/skill-assessment/skills/{skillId}/target — REMOVED

Returns `404 Not Found`. Endpoint no longer exists.

---

## 5. DELETE /api/me/skill-assessment/skills/{skillId}/target — REMOVED

Returns `404 Not Found`. Endpoint no longer exists.

---

## 6. GET /api/employees/{employeeId}/skill-assessment

**Auth**: Authenticated
**Role**: `PeopleManager` (direct reports only), `Director`, `Administrator`

### Response — 200 OK

Same shape as `GET /api/me/skill-assessment` plus:
- `employee` object is populated: `{ "id": "uuid", "display_name": "string" }`
- Each `assessed` object includes `manager_assessment_value` (numeric or null).

### Errors

| Status | Condition |
|--------|-----------|
| 401 | Not authenticated |
| 403 | PeopleManager accessing a non-direct-report |
| 404 | Employee not found |

---

## 7. PUT /api/employees/{employeeId}/skill-assessment/skills/{skillId}/manager-assessment — NEW

**Auth**: Authenticated
**Role**: `PeopleManager` (direct reports only), `Director`, `Administrator`

### Request Body

```json
{
  "manager_assessment_value": 4.0
}
```

### Validation Rules

| Field | Required | Constraints |
|-------|----------|-------------|
| `manager_assessment_value` | Yes | Numeric; must be > 0 |

### Response — 200 OK

Returns the full `EmployeeSkillAssessmentResponseDto` (same shape as GET /api/employees/{employeeId}/skill-assessment).

### Errors

| Status | Condition |
|--------|-----------|
| 400 | `manager_assessment_value` missing, zero, or negative |
| 401 | Not authenticated |
| 403 | Caller does not have required role, or PeopleManager accessing non-direct-report |
| 404 | Employee or skill not found; or skill not required by employee's position |

---

## 8. PATCH /api/taxonomy/positions/{id}/skills/{position_skill_id}

**Change:** `weight` field removed from both request and response.

### Request Body (updated)

```json
{
  "skill_level_id": "uuid",
  "is_mandatory": true,
  "rationale": "string | null"
}
```

`weight` is no longer accepted. If submitted, it is **ignored** (no 400 error — silent drop).

### Response — 200 OK

```json
{
  "id": "uuid",
  "skill_id": "uuid",
  "skill_level_id": "uuid",
  "is_mandatory": true,
  "rationale": "string | null"
}
```

---

## 9. POST /api/taxonomy/positions/{id}/skills

**Change:** `weight` field removed from both request and response. Same treatment as PATCH above.
