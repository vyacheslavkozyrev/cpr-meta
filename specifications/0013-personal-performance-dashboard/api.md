# API Contracts — Personal Performance Dashboard (0013)

All five endpoints already exist in `DashboardController.cs`. This document formalises their contracts and captures the bug fixes required before they are spec-compliant.

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

## GET /api/dashboard/summary

**Auth**: Required
**Role**: Any authenticated user

### Query Parameters

| Param | Type | Default | Constraints |
|-------|------|---------|-------------|
| `period` | string | `month` | `week`, `month`, `quarter`, `year` |

### Response `200 OK`

```json
{
  "goals": {
    "total": 12,
    "active": 8,
    "completed": 3,
    "overdue": 1,
    "completion_rate": 75.0
  },
  "feedback": {
    "total_received": 15,
    "pending_requests": 3,
    "average_rating": 4.2,
    "recent_count": 5
  },
  "skills": {
    "total_skills": 20,
    "assessed_skills": 16,
    "assessment_progress": 80.0,
    "average_level": 3.2
  },
  "activity": {
    "total_activities": 25,
    "recent_activities": 8
  }
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.period |
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/dashboard/goals-summary

**Auth**: Required
**Role**: Any authenticated user

### Query Parameters

| Param | Type | Default | Constraints |
|-------|------|---------|-------------|
| `period` | string | `month` | `week`, `month`, `quarter`, `year` |

### Response `200 OK`

```json
{
  "statistics": {
    "total": 9,
    "active": 5,
    "completed": 3,
    "overdue": 1,
    "completion_rate": 75.0,
    "average_progress": 65.0
  },
  "recent_goals": [
    {
      "id": "uuid",
      "title": "string",
      "status": "string",
      "progress": 0.65,
      "deadline": "2025-12-31T00:00:00.000Z",
      "is_overdue": false
    }
  ],
  "progress_trend": [
    {
      "period": "2025-10-01",
      "created": 3,
      "completed": 2
    }
  ]
}
```

**Notes**
- `recent_goals`: up to 5 entries, ordered by `created_at` desc.
- `progress`: `0.0`–`1.0` range.
- `progress_trend`: one entry per calendar month within the selected period.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.period |
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/dashboard/feedback-summary

**Auth**: Required
**Role**: Any authenticated user

### Query Parameters

| Param | Type | Default | Constraints |
|-------|------|---------|-------------|
| `period` | string | `month` | `week`, `month`, `quarter`, `year` |

### Response `200 OK`

```json
{
  "statistics": {
    "total_received": 15,
    "pending_requests": 3,
    "average_rating": 4.2,
    "rating_distribution": {
      "1": 0,
      "2": 1,
      "3": 2,
      "4": 6,
      "5": 6
    }
  },
  "recent_feedback": [
    {
      "id": "uuid",
      "from_employee_id": "uuid",
      "from_employee_name": "Sarah Johnson",
      "goal_title": "string or null",
      "rating": 5,
      "created_at": "2025-10-14T10:00:00.000Z"
    }
  ],
  "rating_trend": [
    {
      "period": "2025-10-01",
      "average_rating": 4.2,
      "count": 3
    }
  ]
}
```

**Notes**
- `goal_title` is `null` when the feedback has no linked goal — frontend renders "No linked goal" label.
- `recent_feedback`: up to 5 entries; includes feedback with `goal_id = null` (LEFT JOIN — **bug fix required**).
- `rating_distribution`: all keys 1–5 always present, value is 0 if no ratings at that level.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.period |
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/dashboard/skills-summary

**Auth**: Required
**Role**: Any authenticated user

### Response `200 OK`

```json
{
  "statistics": {
    "total_skills": 22,
    "assessed_skills": 16,
    "assessment_progress": 72.7,
    "average_level": 3.2,
    "skill_gaps": 6
  },
  "skill_categories": [
    {
      "category_id": "uuid",
      "category_name": "Technical Skills",
      "total_skills": 8,
      "assessed_skills": 6,
      "average_level": 3.5
    }
  ],
  "recent_assessments": [
    {
      "skill_id": "uuid",
      "skill_name": "React",
      "level": 4,
      "assessed_at": "2025-10-13T10:00:00.000Z"
    }
  ]
}
```

**Notes**
- `recent_assessments`: up to 10 entries, ordered by `assessed_at` desc.
- `recent_assessments` items contain **only** `skill_id`, `skill_name`, `level`, `assessed_at` — no `assessor_name`, `category`, or `category_id`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/dashboard/activity

**Auth**: Required
**Role**: Any authenticated user

### Query Parameters

| Param | Type | Default | Constraints |
|-------|------|---------|-------------|
| `days` | integer | `10` | 1–30 inclusive |
| `page` | integer | `1` | ≥ 1 |
| `per_page` | integer | `20` | 1–50 inclusive |

### Response `200 OK`

```json
{
  "items": [
    {
      "id": "uuid",
      "type": "goal_completed",
      "title": "string",
      "description": "string",
      "timestamp": "2025-10-15T09:00:00.000Z",
      "metadata": {
        "goal_id": "uuid or null",
        "feedback_id": "uuid or null",
        "skill_id": "uuid or null",
        "from_user_id": "uuid or null",
        "rating": "integer or null"
      }
    }
  ],
  "total": 25,
  "page": 1,
  "per_page": 20
}
```

**Notes**
- `type` enum values: `goal_created`, `goal_completed`, `goal_updated`, `feedback_received`, `feedback_requested`, `skill_assessed`.
- `feedback_received` items are included even when the originating feedback has no linked goal (LEFT JOIN — **bug fix required**).
- Items ordered by `timestamp` descending.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.days |
| 401 | Unauthorized | errors.auth.required |
