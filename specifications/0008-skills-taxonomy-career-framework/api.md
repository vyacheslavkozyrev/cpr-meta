# API Contracts — Skills Taxonomy & Career Framework (0008)

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

## Shared Response Shapes

### CareerPathSummary

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null"
}
```

### CareerTrackSummary

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "career_path_id": "uuid",
  "career_path_title": "string"
}
```

### PositionSummary

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "expectations": "string | null",
  "sort_order": 0,
  "career_track_id": "uuid",
  "career_track_title": "string"
}
```

### SkillLevelSummary

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "value": 3
}
```

### SkillSummary

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "category_id": "uuid",
  "category_title": "string"
}
```

### PositionSkillRequirement

```json
{
  "id": "uuid",
  "skill_id": "uuid",
  "skill_title": "string",
  "category_id": "uuid",
  "category_title": "string",
  "skill_level_id": "uuid",
  "skill_level_title": "string",
  "skill_level_value": 3,
  "is_mandatory": true,
  "weight": 1.5,
  "rationale": "string | null"
}
```

---

## READ ENDPOINTS — All Authenticated Roles

---

## GET /api/taxonomy/career-paths

**Auth**: Required
**Role**: Any authenticated user

Returns all active career paths.

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number (1-based) |
| `per_page` | integer | 20 | Items per page (max 100) |
| `sort_by` | string | `title` | `title` or `created_at` |
| `sort_dir` | string | `asc` | `asc` or `desc` |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string | null"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_items": 5,
    "total_pages": 1
  }
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.per_page_max |
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/taxonomy/career-paths/{id}

**Auth**: Required
**Role**: Any authenticated user

Returns a career path with its active career tracks.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Career path identifier |

### Response `200 OK`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "tracks": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string | null"
    }
  ]
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 404 | Not Found | errors.career_paths.not_found |

---

## GET /api/taxonomy/career-tracks

**Auth**: Required
**Role**: Any authenticated user

Returns all active career tracks, optionally filtered by career path.

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `career_path_id` | uuid | — | Filter by parent career path |
| `page` | integer | 1 | Page number (1-based) |
| `per_page` | integer | 20 | Items per page (max 100) |
| `sort_by` | string | `title` | `title` or `created_at` |
| `sort_dir` | string | `asc` | `asc` or `desc` |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string | null",
      "career_path_id": "uuid",
      "career_path_title": "string"
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
| 400 | Validation Failed | errors.validation.per_page_max |
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/taxonomy/career-tracks/{id}

**Auth**: Required
**Role**: Any authenticated user

Returns a career track with its active positions.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Career track identifier |

### Response `200 OK`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "career_path_id": "uuid",
  "career_path_title": "string",
  "positions": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string | null",
      "expectations": "string | null"
    }
  ]
}
```

Positions in the `positions` array are sorted by `sort_order` ascending, then `title` ascending as a tiebreaker.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 404 | Not Found | errors.career_tracks.not_found |

---

## GET /api/taxonomy/positions/{id}

**Auth**: Required
**Role**: Any authenticated user

Returns a position with its active skill requirements.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Position identifier |

### Response `200 OK`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "expectations": "string | null",
  "career_track_id": "uuid",
  "career_track_title": "string",
  "career_path_id": "uuid",
  "career_path_title": "string",
  "skills": [
    {
      "id": "uuid",
      "skill_id": "uuid",
      "skill_title": "string",
      "category_id": "uuid",
      "category_title": "string",
      "skill_level_id": "uuid",
      "skill_level_title": "string",
      "skill_level_value": 3,
      "is_mandatory": true,
      "weight": 1.5,
      "rationale": "string | null"
    }
  ]
}
```

Only `position_to_skill` entries where the referenced `skill.is_deleted = false` are included in `skills`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 404 | Not Found | errors.positions.not_found |

---

## GET /api/taxonomy/skill-categories

**Auth**: Required
**Role**: Any authenticated user

Returns all active skill categories.

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `page` | integer | 1 | Page number (1-based) |
| `per_page` | integer | 20 | Items per page (max 100) |
| `sort_by` | string | `title` | `title` or `created_at` |
| `sort_dir` | string | `asc` | `asc` or `desc` |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string | null"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_items": 8,
    "total_pages": 1
  }
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/taxonomy/skills

**Auth**: Required
**Role**: Any authenticated user

Returns all active skills, optionally filtered by category.

### Query Parameters

| Param | Type | Default | Description |
|-------|------|---------|-------------|
| `category_id` | uuid | — | Filter by skill category |
| `page` | integer | 1 | Page number (1-based) |
| `per_page` | integer | 20 | Items per page (max 100) |
| `sort_by` | string | `title` | `title` or `created_at` |
| `sort_dir` | string | `asc` | `asc` or `desc` |

### Response `200 OK`

```json
{
  "data": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string | null",
      "category_id": "uuid",
      "category_title": "string"
    }
  ],
  "pagination": {
    "page": 1,
    "per_page": 20,
    "total_items": 40,
    "total_pages": 2
  }
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |

---

## GET /api/taxonomy/skills/{id}

**Auth**: Required
**Role**: Any authenticated user

Returns a skill with its proficiency levels.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Skill identifier |

### Response `200 OK`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "category_id": "uuid",
  "category_title": "string",
  "levels": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string | null",
      "value": 1
    }
  ]
}
```

`levels` are sorted by `value` ascending. Only active levels (skill `is_deleted = false`) are returned; if the skill itself is soft-deleted, respond 404.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 404 | Not Found | errors.skills.not_found |

---

## ADMIN WRITE ENDPOINTS — Administrator Role Only

> All endpoints below require `Administrator` role. Non-admin authenticated users receive `403 Forbidden`.

---

## POST /api/taxonomy/career-paths

**Auth**: Required
**Role**: Administrator

### Request Body

```json
{
  "title": "string — career path name",
  "description": "string | null — optional description"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | Yes | 1–200 characters; unique (case-insensitive) |
| `description` | No | max 1000 characters if provided |

### Response `201 Created`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.title_required / errors.validation.title_too_long / errors.validation.title_duplicate |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |

---

## PATCH /api/taxonomy/career-paths/{id}

**Auth**: Required
**Role**: Administrator

All fields optional — only provided fields are updated.

### Request Body

```json
{
  "title": "string — updated career path name",
  "description": "string | null — updated description"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | No | 1–200 characters if provided; unique (case-insensitive) |
| `description` | No | max 1000 characters if provided |

### Response `200 OK`

Returns the updated `CareerPathSummary`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.title_too_long / errors.validation.title_duplicate |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.career_paths.not_found |

---

## POST /api/taxonomy/career-tracks

**Auth**: Required
**Role**: Administrator

### Request Body

```json
{
  "title": "string — track name",
  "description": "string | null",
  "career_path_id": "uuid — parent career path"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | Yes | 1–200 characters |
| `description` | No | max 1000 characters if provided |
| `career_path_id` | Yes | Must reference an active (non-deleted) career path |

### Response `201 Created`

Returns the created `CareerTrackSummary`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.title_required / errors.validation.career_path_id_required / errors.validation.career_path_not_found |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |

---

## PATCH /api/taxonomy/career-tracks/{id}

**Auth**: Required
**Role**: Administrator

All fields optional — only provided fields are updated.

### Request Body

```json
{
  "title": "string",
  "description": "string | null",
  "career_path_id": "uuid"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | No | 1–200 characters if provided |
| `description` | No | max 1000 characters if provided |
| `career_path_id` | No | Must reference an active career path if provided |

### Response `200 OK`

Returns the updated `CareerTrackSummary`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.career_path_not_found |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.career_tracks.not_found |

---

## POST /api/taxonomy/positions

**Auth**: Required
**Role**: Administrator

### Request Body

```json
{
  "title": "string — position name",
  "description": "string | null",
  "expectations": "string | null",
  "sort_order": 0,
  "career_track_id": "uuid — parent career track"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | Yes | 1–200 characters |
| `description` | No | max 2000 characters if provided |
| `expectations` | No | max 2000 characters if provided |
| `sort_order` | No | Non-negative integer if provided; defaults to 0 |
| `career_track_id` | Yes | Must reference an active career track |

### Response `201 Created`

Returns the created `PositionSummary`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.title_required / errors.validation.career_track_not_found |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |

---

## PATCH /api/taxonomy/positions/{id}

**Auth**: Required
**Role**: Administrator

All fields optional — only provided fields are updated.

### Request Body

```json
{
  "title": "string",
  "description": "string | null",
  "expectations": "string | null",
  "sort_order": 0,
  "career_track_id": "uuid"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | No | 1–200 characters if provided |
| `description` | No | max 2000 characters if provided |
| `expectations` | No | max 2000 characters if provided |
| `sort_order` | No | Non-negative integer if provided |
| `career_track_id` | No | Must reference an active career track if provided |

### Response `200 OK`

Returns the updated `PositionSummary`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.career_track_not_found |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.positions.not_found |

---

## POST /api/taxonomy/skill-categories

**Auth**: Required
**Role**: Administrator

### Request Body

```json
{
  "title": "string — category name",
  "description": "string | null"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | Yes | 1–200 characters; unique (case-insensitive) |
| `description` | No | max 1000 characters if provided |

### Response `201 Created`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.title_required / errors.validation.title_duplicate |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |

---

## PATCH /api/taxonomy/skill-categories/{id}

**Auth**: Required
**Role**: Administrator

All fields optional — only provided fields are updated.

### Request Body

```json
{
  "title": "string",
  "description": "string | null"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | No | 1–200 characters if provided; unique (case-insensitive) |
| `description` | No | max 1000 characters if provided |

### Response `200 OK`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null"
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.title_duplicate |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.skill_categories.not_found |

---

## POST /api/taxonomy/skills

**Auth**: Required
**Role**: Administrator

Creates a skill and optionally its proficiency levels in one request.

### Request Body

```json
{
  "title": "string — skill name",
  "description": "string | null",
  "category_id": "uuid — parent skill category",
  "levels": [
    {
      "title": "string — level name",
      "description": "string | null",
      "value": 1
    }
  ]
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | Yes | 1–200 characters |
| `description` | No | max 1000 characters if provided |
| `category_id` | Yes | Must reference an active skill category |
| `levels` | No | Array; if provided, each entry must have `title` and a unique `value` (1–5) within the skill |
| `levels[].title` | Yes (if levels provided) | 1–100 characters |
| `levels[].description` | No | max 500 characters if provided |
| `levels[].value` | Yes (if levels provided) | Integer 1–5; unique within the skill |

### Response `201 Created`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "category_id": "uuid",
  "category_title": "string",
  "levels": [
    {
      "id": "uuid",
      "title": "string",
      "description": "string | null",
      "value": 1
    }
  ]
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.title_required / errors.validation.category_not_found / errors.validation.level_value_duplicate / errors.validation.level_value_out_of_range |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |

---

## PATCH /api/taxonomy/skills/{id}

**Auth**: Required
**Role**: Administrator

All fields optional — only provided fields are updated. Levels are managed via sub-resource endpoints below.

### Request Body

```json
{
  "title": "string",
  "description": "string | null",
  "category_id": "uuid"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | No | 1–200 characters if provided |
| `description` | No | max 1000 characters if provided |
| `category_id` | No | Must reference an active skill category if provided |

### Response `200 OK`

Returns the full skill object (with `levels` array, same as POST response).

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.category_not_found |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.skills.not_found |

---

## DELETE /api/taxonomy/skills/{id}

**Auth**: Required
**Role**: Administrator

Soft-deletes the skill (`is_deleted = true`). The skill is immediately excluded from all read-only views. Existing `employee_to_skill` and `goals` references in the DB are preserved.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Skill identifier |

### Response `204 No Content`

No response body.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.skills.not_found |

---

## POST /api/taxonomy/skills/{id}/levels

**Auth**: Required
**Role**: Administrator

Adds a proficiency level to an existing active skill.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Skill identifier |

### Request Body

```json
{
  "title": "string — level name",
  "description": "string | null",
  "value": 3
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | Yes | 1–100 characters |
| `description` | No | max 500 characters if provided |
| `value` | Yes | Integer 1–5; unique within the skill |

### Response `201 Created`

```json
{
  "id": "uuid",
  "title": "string",
  "description": "string | null",
  "value": 3
}
```

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.level_value_duplicate / errors.validation.level_value_out_of_range |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.skills.not_found |

---

## PATCH /api/taxonomy/skills/{id}/levels/{level_id}

**Auth**: Required
**Role**: Administrator

All fields optional — only provided fields are updated.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Skill identifier |
| `level_id` | uuid | Skill level identifier |

### Request Body

```json
{
  "title": "string",
  "description": "string | null",
  "value": 3
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `title` | No | 1–100 characters if provided |
| `description` | No | max 500 characters if provided |
| `value` | No | Integer 1–5; unique within the skill if provided |

### Response `200 OK`

Returns the updated `SkillLevelSummary`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.level_value_duplicate / errors.validation.level_value_out_of_range |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.skills.not_found / errors.skill_levels.not_found |

---

## POST /api/taxonomy/positions/{id}/skills

**Auth**: Required
**Role**: Administrator

Adds a skill requirement to a position.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Position identifier |

### Request Body

```json
{
  "skill_id": "uuid — must be active",
  "skill_level_id": "uuid — must belong to skill_id",
  "is_mandatory": false,
  "weight": 1.0,
  "rationale": "string | null"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `skill_id` | Yes | Must reference an active (non-deleted) skill |
| `skill_level_id` | Yes | Must belong to the specified `skill_id` |
| `is_mandatory` | Yes | Boolean |
| `weight` | No | Positive decimal if provided |
| `rationale` | No | max 500 characters if provided |

### Response `201 Created`

Returns the created `PositionSkillRequirement`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.skill_already_assigned / errors.validation.skill_deleted / errors.validation.skill_level_mismatch |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.positions.not_found |

---

## PATCH /api/taxonomy/positions/{id}/skills/{position_skill_id}

**Auth**: Required
**Role**: Administrator

Updates an existing position skill requirement. The `skill_id` cannot be changed — remove and re-add instead.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Position identifier |
| `position_skill_id` | uuid | Position-to-skill entry identifier |

### Request Body

```json
{
  "skill_level_id": "uuid — must belong to the existing skill",
  "is_mandatory": true,
  "weight": 1.5,
  "rationale": "string | null"
}
```

**Validation Rules**

| Field | Required | Constraints |
|-------|----------|-------------|
| `skill_level_id` | No | Must belong to the existing skill if provided |
| `is_mandatory` | No | Boolean if provided |
| `weight` | No | Positive decimal if provided |
| `rationale` | No | max 500 characters if provided |

### Response `200 OK`

Returns the updated `PositionSkillRequirement`.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 400 | Validation Failed | errors.validation.skill_level_mismatch |
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.positions.not_found / errors.position_skills.not_found |

---

## DELETE /api/taxonomy/positions/{id}/skills/{position_skill_id}

**Auth**: Required
**Role**: Administrator

Soft-deletes the position-to-skill entry. The skill requirement no longer appears in the position detail view.

### Path Parameters

| Param | Type | Description |
|-------|------|-------------|
| `id` | uuid | Position identifier |
| `position_skill_id` | uuid | Position-to-skill entry identifier |

### Response `204 No Content`

No response body.

### Error Responses

| Status | `title` | `detail` |
|--------|---------|---------|
| 401 | Unauthorized | errors.auth.required |
| 403 | Forbidden | errors.auth.forbidden |
| 404 | Not Found | errors.positions.not_found / errors.position_skills.not_found |
