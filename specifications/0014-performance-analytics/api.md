# API Contracts — Performance Analytics & Reporting (0014)

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

## Shared: Period Query Parameter

All four analytics endpoints accept the following query parameter:

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `period` | string (enum) | `last_90_days` | Time range for analytics |

**Valid `period` values**

| Value | Description |
|-------|-------------|
| `last_30_days` | Rolling 30 days back from today |
| `last_90_days` | Rolling 90 days back from today |
| `last_180_days` | Rolling 180 days back from today |
| `last_quarter` | The most recently completed calendar quarter (Q1=Jan–Mar, etc.) |
| `last_year` | The most recently completed calendar year (Jan 1 – Dec 31) |

An unrecognised value returns **400** with `errors.analytics.invalid_period`.

---

## GET /api/me/analytics/goals

**Auth**: Required
**Role**: Any authenticated user

Returns goal analytics for the authenticated user.

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `period` | string | `last_90_days` | See Shared section above |

### Response `200 OK`

```json
{
  "period": "last_90_days",
  "period_start": "2025-11-01T00:00:00Z",
  "period_end": "2026-01-30T23:59:59Z",
  "stats": {
    "total_goals": 12,
    "created_in_period": 5,
    "completed_in_period": 4,
    "open_goals": 3,
    "in_progress_goals": 5,
    "overdue_goals": 1,
    "completion_rate": 0.80,
    "overdue_rate": 0.083,
    "avg_days_to_complete": 38.2
  },
  "goals_by_status": {
    "open": 3,
    "in_progress": 5,
    "completed": 4
  },
  "completion_trend": [
    { "period_label": "2025-11", "created": 2, "completed": 1 },
    { "period_label": "2025-12", "created": 2, "completed": 2 },
    { "period_label": "2026-01", "created": 1, "completed": 1 }
  ]
}
```

**Field notes**
- `total_goals`: count of all non-deleted goals belonging to the employee (not period-bounded).
- `created_in_period`: goals where `created_at` falls within `[period_start, period_end]`.
- `completed_in_period`: goals where `completed_at` falls within `[period_start, period_end]`.
- `open_goals` / `in_progress_goals`: current status of all non-deleted, non-completed goals.
- `overdue_goals`: non-deleted goals where `deadline < NOW()` and `is_completed = FALSE`.
- `completion_rate`: `completed_in_period / created_in_period`; `null` when `created_in_period = 0`.
- `overdue_rate`: `overdue_goals / total_goals`; `null` when `total_goals = 0`.
- `avg_days_to_complete`: average `(completed_at - created_at)` in days for goals completed in the period; `null` when `completed_in_period = 0`.
- `completion_trend`: one entry per calendar month within the period; `period_label` format `YYYY-MM`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.analytics.invalid_period |
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/me/analytics/skills

**Auth**: Required
**Role**: Any authenticated user

Returns skill progression analytics for the authenticated user.

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `period` | string | `last_90_days` | See Shared section above |

### Response `200 OK`

```json
{
  "period": "last_90_days",
  "period_start": "2025-11-01T00:00:00Z",
  "period_end": "2026-01-30T23:59:59Z",
  "gap_closure_summary": {
    "skills_assessed": 10,
    "skills_with_gaps": 3,
    "gaps_closed_in_period": 1,
    "gaps_worsened_in_period": 0,
    "avg_gap_at_period_start": 1.5,
    "avg_gap_at_period_end": 1.0
  },
  "skills": [
    {
      "skill_id": "uuid",
      "skill_title": "TypeScript",
      "category_title": "Frontend",
      "current_self_assessment": 4.0,
      "current_manager_assessment": 3.5,
      "required_level": 4.0,
      "gap": 0.0,
      "history": [
        {
          "recorded_at": "2025-11-15T10:00:00Z",
          "self_assessment_value": 3.0,
          "manager_assessment_value": null
        },
        {
          "recorded_at": "2025-12-20T14:30:00Z",
          "self_assessment_value": 3.5,
          "manager_assessment_value": 3.0
        }
      ]
    }
  ]
}
```

**Field notes**
- `skills`: all skills for which the employee has an `employee_to_skill` record (not soft-deleted).
- `required_level`: the `skill_levels.value` (numeric 1–5) from `position_to_skill` for the employee's current `position_id`; `null` if the employee has no position or the skill is not required for that position.
- `gap`: `required_level - current_self_assessment`; `null` when `required_level` is null; `0` when self-assessment meets or exceeds requirement.
- `history`: `employee_skill_history` rows for this skill within `[period_start, period_end]`, ordered by `recorded_at` ascending; may be an empty array if no changes occurred in the period.
- `current_manager_assessment`: `null` if no manager assessment has been provided.
- `gap_closure_summary.avg_gap_at_period_start`: average gap computed using the oldest `employee_skill_history` entry within the period for each skill (or current value if no history in period); only skills with a `required_level` are included.
- `gap_closure_summary.avg_gap_at_period_end`: average gap using current `self_assessment_value` vs `required_level`; only skills with a `required_level` are included.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.analytics.invalid_period |
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/employees/{id}/analytics/goals

**Auth**: Required
**Role**: PeopleManager (own direct reports only), Director, Administrator

Returns goal analytics for the specified employee.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Employee identifier |

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `period` | string | `last_90_days` | See Shared section above |

### Response `200 OK`

Same shape as `GET /api/me/analytics/goals`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.analytics.invalid_period |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.employees.not_found |

---

## GET /api/employees/{id}/analytics/skills

**Auth**: Required
**Role**: PeopleManager (own direct reports only), Director, Administrator

Returns skill progression analytics for the specified employee.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Employee identifier |

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `period` | string | `last_90_days` | See Shared section above |

### Response `200 OK`

Same shape as `GET /api/me/analytics/skills`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.analytics.invalid_period |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.employees.not_found |
