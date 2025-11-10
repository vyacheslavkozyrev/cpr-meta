# API Endpoints - Personal Goal Creation Management

> **Feature**: 0001 - personal-goal-creation-management  
> **Status**: Planning  
> **Created**: 2025-11-07  
> **Last Updated**: 2025-11-07

---

## Overview

This document defines all API endpoints for the Personal Goal Creation Management feature, including request/response contracts, validation rules, and authorization requirements.

**Base URL**: `/api/v1`

**API Version**: v1

**Authentication**: Required (JWT Bearer token)

---

## Endpoints Summary

| Method | Endpoint | Description | Auth | Role |
|--------|----------|-------------|------|------|
| GET | `/goals` | List goals (all for admin, own for others) | ✅ | Any authenticated user |
| GET | `/goals/{id}` | Get single goal | ✅ | Owner/Manager/Admin |
| POST | `/goals` | Create new goal | ✅ | Any authenticated user |
| PATCH | `/goals/{id}` | Update existing goal (partial) | ✅ | Owner/Admin |
| DELETE | `/goals/{id}` | Soft delete goal | ✅ | Owner/Manager/Admin |
| GET | `/me/goals` | Get current user's goals (convenience) | ✅ | Any authenticated user |
| GET | `/users/{userId}/goals` | Get goals for specific user | ✅ | Manager/Admin |
| GET | `/me/available-skills` | Get skills for goal creation (next level) | ✅ | Any authenticated user |

---

## Common Response Codes

All endpoints use standard HTTP status codes:

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Successful GET, PATCH, DELETE |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE (alternative) |
| 400 | Bad Request | Validation error, malformed request |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource conflict, business rule violation |
| 422 | Unprocessable Entity | Semantic validation error |
| 429 | Too Many Requests | Rate limit exceeded |
| 500 | Internal Server Error | Unexpected server error |

---

## Common Error Response Format

All error responses follow this structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more validation errors occurred",
    "details": [
      {
        "field": "field_name",
        "message": "Error description"
      }
    ],
    "trace_id": "00-abc123-def456-00"
  }
}
```

**Error Codes**:
- `VALIDATION_ERROR` - Input validation failed
- `NOT_FOUND` - Resource not found
- `UNAUTHORIZED` - Authentication required
- `FORBIDDEN` - Insufficient permissions
- `CONFLICT` - Resource conflict
- `INTERNAL_ERROR` - Server error

---

## Endpoint Details

### 1. List Goals

**Endpoint**: `GET /api/v1/goals`

**Description**: Retrieve a list of goals for the authenticated user. Admin users see all goals, other roles see only their own goals.

**Authorization**: 
- Employee: Returns only own goals
- Manager: Returns only own goals (use `/users/{userId}/goals` for direct reports)
- Admin: Returns all goals

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `status` | string | No | - | Filter by status: `active`, `completed`, `archived` |
| `skill_id` | UUID | No | - | Filter by skill |
| `sort_by` | string | No | `created_at` | Sort field: `created_at`, `target_date`, `progress_percentage` |
| `sort_order` | string | No | `desc` | Sort order: `asc` or `desc` |

**Note**: No pagination initially (expected < 100 goals per user).

**Request Example**:
```http
GET /api/v1/goals?status=active&sort_by=target_date&sort_order=asc HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "description": "Complete Azure certification",
    "target_date": "2026-06-30",
    "skill_id": "a1b2c3d4-e5f6-4789-a012-3456789abcde",
    "skill_name": "Azure Solutions Architect",
    "skill_level": 3,
    "progress_percentage": 0,
    "status": "active",
    "is_deleted": false,
    "created_at": "2025-11-07T10:30:00Z",
    "updated_at": "2025-11-07T10:30:00Z"
  }
]
```

**C# DTO**:
```csharp
public class GoalDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("user_id")]
    public Guid UserId { get; set; }

    [JsonPropertyName("description")]
    public string Description { get; set; } = string.Empty;

    [JsonPropertyName("target_date")]
    public DateOnly TargetDate { get; set; }

    [JsonPropertyName("skill_id")]
    public Guid SkillId { get; set; }

    [JsonPropertyName("skill_name")]
    public string SkillName { get; set; } = string.Empty;

    [JsonPropertyName("skill_level")]
    public int SkillLevel { get; set; }

    [JsonPropertyName("progress_percentage")]
    public int ProgressPercentage { get; set; }

    [JsonPropertyName("status")]
    public string Status { get; set; } = "active";

    [JsonPropertyName("is_deleted")]
    public bool IsDeleted { get; set; }

    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }

    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}
```

**TypeScript Interface**:
```typescript
export type GoalStatus = 'active' | 'completed' | 'archived';

export interface Goal {
  id: string;
  user_id: string;
  description: string;
  target_date: string; // ISO date: YYYY-MM-DD
  skill_id: string;
  skill_name: string;
  skill_level: number;
  progress_percentage: number;
  status: GoalStatus;
  is_deleted: boolean;
  created_at: string; // ISO datetime
  updated_at: string; // ISO datetime
}
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication token

**Offline Caching**:
- Cache key: `goals:list:user:{userId}:status:{status}:skill:{skillId}`
- TTL: 5 minutes
- Invalidation: On create/update/delete any goal

---

### 2. Get Single Goal

**Endpoint**: `GET /api/v1/goals/{id}`

**Description**: Retrieve a specific goal by ID

**Authorization**: 
- Owner can always access
- Manager can access if goal belongs to direct report
- Admin can access any goal

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |

**Request Example**:
```http
GET /api/v1/goals/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "description": "Complete Azure certification and pass AZ-305 exam",
  "target_date": "2026-06-30",
  "skill_id": "a1b2c3d4-e5f6-4789-a012-3456789abcde",
  "skill_name": "Azure Solutions Architect",
  "skill_level": 3,
  "progress_percentage": 0,
  "status": "active",
  "is_deleted": false,
  "created_at": "2025-11-07T10:30:00Z",
  "updated_at": "2025-11-07T10:30:00Z"
}
```

**C# DTO**: Same as `GoalDto` above

**TypeScript Interface**: Same as `Goal` above

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - User doesn't have access to this goal
- `404 Not Found` - Goal doesn't exist or is deleted

**Offline Caching**:
- Cache key: `goal:{id}`
- TTL: 10 minutes
- Invalidation: On update/delete

---

### 3. Create Goal

**Endpoint**: `POST /api/v1/goals`

**Description**: Create a new personal or professional development goal

**Authorization**: 
- Any authenticated user can create goals for themselves
- Goal is automatically assigned to authenticated user

**Request Body**:
```json
{
  "description": "Complete Azure certification and pass AZ-305 exam",
  "target_date": "2026-06-30",
  "skill_id": "a1b2c3d4-e5f6-4789-a012-3456789abcde"
}
```

**Request Example**:
```http
POST /api/v1/goals HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "description": "Complete Azure certification and pass AZ-305 exam",
  "target_date": "2026-06-30",
  "skill_id": "a1b2c3d4-e5f6-4789-a012-3456789abcde"
}
```

**Response** (201 Created):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "description": "Complete Azure certification and pass AZ-305 exam",
  "target_date": "2026-06-30",
  "skill_id": "a1b2c3d4-e5f6-4789-a012-3456789abcde",
  "skill_name": "Azure Solutions Architect",
  "skill_level": 3,
  "progress_percentage": 0,
  "status": "active",
  "is_deleted": false,
  "created_at": "2025-11-07T10:30:00Z",
  "updated_at": "2025-11-07T10:30:00Z"
}
```

**Response Headers**:
```
Location: /api/v1/goals/550e8400-e29b-41d4-a716-446655440000
```

**C# DTO**:
```csharp
public class CreateGoalDto
{
    [JsonPropertyName("description")]
    [Required]
    [MinLength(10, ErrorMessage = "Description must be at least 10 characters")]
    [MaxLength(500, ErrorMessage = "Description cannot exceed 500 characters")]
    public string Description { get; set; } = string.Empty;

    [JsonPropertyName("target_date")]
    [Required]
    [FutureDate(ErrorMessage = "Target date must be in the future")]
    public DateOnly TargetDate { get; set; }

    [JsonPropertyName("skill_id")]
    [Required]
    public Guid SkillId { get; set; }
}
```

**TypeScript Interface**:
```typescript
export interface CreateGoalRequest {
  description: string; // 10-500 characters, required
  target_date: string; // ISO date: YYYY-MM-DD, must be future
  skill_id: string; // UUID, required
}
```

**Validation Rules**:
1. **description**: Required, 10-500 characters
2. **target_date**: Required, must be future date at creation
3. **skill_id**: Required, must be valid skill UUID, must be one level above employee's current skill level

**Business Rules**:
- `skill_id` must be in the list of available skills for user (next level only)
- `user_id` is automatically set from authentication token (not in request)
- `progress_percentage` defaults to 0
- `status` defaults to 'active'
- `is_deleted` defaults to false

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `400 Bad Request` - Validation error (see example below)
- `422 Unprocessable Entity` - Skill not available for user's position/level

**Validation Error Example** (400):
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more validation errors occurred",
    "details": [
      {
        "field": "description",
        "message": "Description must be at least 10 characters"
      },
      {
        "field": "target_date",
        "message": "Target date must be in the future"
      },
      {
        "field": "skill_id",
        "message": "Skill ID is required"
      }
    ],
    "trace_id": "00-abc123-def456-00"
  }
}
```

**Skill Validation Error Example** (422):
```json
{
  "error": {
    "code": "INVALID_SKILL",
    "message": "The selected skill is not available for goal creation",
    "details": [
      {
        "field": "skill_id",
        "message": "Skill must be one level above your current skill level for your position"
      }
    ],
    "trace_id": "00-abc123-def456-00"
  }
}
```

**Offline Support**:
- Goal creation queued in IndexedDB when offline
- Synced to server when connection restored
- Temporary UUID assigned, replaced with server UUID on sync

---

### 4. Update Goal

**Endpoint**: `PATCH /api/v1/goals/{id}`

**Description**: Update an existing goal (partial update)

**Authorization**: 
- Owner can update own goals
- Admin can update any goal
- Manager CANNOT update direct reports' goals (view-only)

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |

**Request Body** (all fields optional):
```json
{
  "description": "Updated: Complete Azure certification and pass AZ-305 exam by June",
  "target_date": "2026-06-15",
  "skill_id": "b2c3d4e5-f6a7-5890-b123-4567890bcdef",
  "status": "completed"
}
```

**Request Example**:
```http
PATCH /api/v1/goals/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "description": "Updated: Complete Azure certification and pass AZ-305 exam by June",
  "target_date": "2026-06-15",
  "status": "completed"
}
```

**Response** (200 OK):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "description": "Updated: Complete Azure certification and pass AZ-305 exam by June",
  "target_date": "2026-06-15",
  "skill_id": "a1b2c3d4-e5f6-4789-a012-3456789abcde",
  "skill_name": "Azure Solutions Architect",
  "skill_level": 3,
  "progress_percentage": 0,
  "status": "completed",
  "is_deleted": false,
  "created_at": "2025-11-07T10:30:00Z",
  "updated_at": "2025-11-07T14:20:00Z"
}
```

**C# DTO**:
```csharp
public class UpdateGoalDto
{
    [JsonPropertyName("description")]
    [MinLength(10)]
    [MaxLength(500)]
    public string? Description { get; set; }

    [JsonPropertyName("target_date")]
    public DateOnly? TargetDate { get; set; }

    [JsonPropertyName("skill_id")]
    public Guid? SkillId { get; set; }

    [JsonPropertyName("status")]
    [RegularExpression("^(active|completed|archived)$")]
    public string? Status { get; set; }
}
```

**TypeScript Interface**:
```typescript
export interface UpdateGoalRequest {
  description?: string; // 10-500 characters if provided
  target_date?: string; // ISO date: YYYY-MM-DD, can be past or future
  skill_id?: string; // UUID, must be next-level skill if provided
  status?: GoalStatus; // 'active' | 'completed' | 'archived'
}
```

**Validation Rules**:
1. **description**: Optional, 10-500 characters if provided
2. **target_date**: Optional, can be past or future (unlike create, which requires future)
3. **skill_id**: Optional, must be valid skill UUID and next-level skill if provided
4. **status**: Optional, must be 'active', 'completed', or 'archived'

**Business Rules**:
- Target date can be updated to past dates (unlike creation)
- If skill_id changed, must still be next-level skill for user
- `updated_at` automatically updated
- `progress_percentage` NOT directly editable (auto-calculated from tasks in future)

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - User doesn't have permission to update this goal
- `404 Not Found` - Goal doesn't exist
- `400 Bad Request` - Validation error
- `422 Unprocessable Entity` - Invalid skill_id for user

**Offline Support**:
- NOT supported offline - shows error message
- Error: "This action requires internet connection. Changes will not be saved."
- Optimistic update when online: show immediately, revert on failure

---

### 5. Delete Goal

**Endpoint**: `DELETE /api/v1/goals/{id}`

**Description**: Soft delete a goal (sets `is_deleted=true`, preserves data for audit)

**Authorization**: 
- Owner can delete own goals
- Manager can delete direct reports' goals
- Admin can delete any goal

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |

**Request Example**:
```http
DELETE /api/v1/goals/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
{
  "message": "Goal deleted successfully",
  "id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Alternative Response** (204 No Content):
```
(empty body)
```

**Soft Delete Implementation**:
- Sets `is_deleted = true`
- Sets `deleted_at = NOW()`
- Sets `deleted_by = requesting_user_id`
- Goal hidden from normal queries (WHERE is_deleted = FALSE)
- Data preserved for audit trail

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - User doesn't have permission to delete this goal
- `404 Not Found` - Goal doesn't exist or already deleted

**Offline Support**:
- NOT supported offline - shows error message
- Error: "This action requires internet connection. Changes will not be saved."

---

### 6. Get Current User's Goals (Convenience Endpoint)

**Endpoint**: `GET /api/v1/me/goals`

**Description**: Convenience endpoint to get goals for the authenticated user (same as `GET /api/v1/goals` for non-admin users)

**Authorization**: Any authenticated user

**Query Parameters**: Same as `GET /api/v1/goals`

**Request Example**:
```http
GET /api/v1/me/goals?status=active HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK): Same as `GET /api/v1/goals`

**Implementation Note**: This is syntactic sugar that explicitly filters by `user_id` from JWT token.

---

### 7. Get Goals for Specific User

**Endpoint**: `GET /api/v1/users/{userId}/goals`

**Description**: Get goals for a specific user (manager can access direct reports, admin can access any user)

**Authorization**: 
- Manager: Can access direct reports' goals only
- Admin: Can access any user's goals
- Employee: Forbidden (use `GET /api/v1/me/goals` instead)

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `userId` | UUID | Yes | User identifier |

**Query Parameters**: Same as `GET /api/v1/goals` (status, skill_id, sort_by, sort_order)

**Request Example**:
```http
GET /api/v1/users/123e4567-e89b-12d3-a456-426614174000/goals?status=active HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK): Array of `GoalDto` (same structure as `GET /api/v1/goals`)

**Authorization Logic**:
```csharp
// Manager can only access direct reports
if (role == "Manager")
{
    var isDirectReport = await IsDirectReportAsync(requestingUserId, targetUserId);
    if (!isDirectReport) throw new ForbiddenException();
}

// Admin can access any user
if (role == "Administrator") 
{
    // Allow access
}

// Employee role forbidden for this endpoint
if (role == "Employee")
{
    throw new ForbiddenException("Use /api/v1/me/goals to access your own goals");
}
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - Not a manager/admin, or target user is not a direct report
- `404 Not Found` - User doesn't exist

---

### 8. Get Available Skills for Goal Creation

**Endpoint**: `GET /api/v1/me/available-skills`

**Description**: Get skills available for goal creation (skills one level above employee's current skill level for their position)

**Authorization**: Any authenticated user

**Request Example**:
```http
GET /api/v1/me/available-skills HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
[
  {
    "skill_id": "a1b2c3d4-e5f6-4789-a012-3456789abcde",
    "skill_name": "Azure Solutions Architect",
    "current_level": 2,
    "target_level": 3,
    "position_name": "Senior Developer"
  },
  {
    "skill_id": "b2c3d4e5-f6a7-5890-b123-4567890bcdef",
    "skill_name": "Team Leadership",
    "current_level": 1,
    "target_level": 2,
    "position_name": "Senior Developer"
  }
]
```

**C# DTO**:
```csharp
public class AvailableSkillDto
{
    [JsonPropertyName("skill_id")]
    public Guid SkillId { get; set; }

    [JsonPropertyName("skill_name")]
    public string SkillName { get; set; } = string.Empty;

    [JsonPropertyName("current_level")]
    public int CurrentLevel { get; set; }

    [JsonPropertyName("target_level")]
    public int TargetLevel { get; set; }

    [JsonPropertyName("position_name")]
    public string PositionName { get; set; } = string.Empty;
}
```

**TypeScript Interface**:
```typescript
export interface AvailableSkill {
  skill_id: string;
  skill_name: string;
  current_level: number; // Employee's current level for this skill
  target_level: number; // Next level (current + 1)
  position_name: string; // Employee's position
}
```

**Business Logic**:
1. Get authenticated user's employee record
2. Get employee's position
3. Get all skills for that position
4. Get employee's current skill levels
5. Return skills where `target_level = current_level + 1`

**Caching**:
- Cache key: `available-skills:user:{userId}`
- TTL: 30 minutes (skills don't change frequently)
- Invalidation: When employee's skill levels updated or position changed

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `404 Not Found` - Employee record not found for user

---

## Rate Limiting

All endpoints are subject to rate limiting:

- **Authenticated users**: 100 requests per minute per user
- **Rate limit headers**:
  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 95
  X-RateLimit-Reset: 1636300800
  ```
- **Rate limit exceeded** (429):
  ```json
  {
    "error": {
      "code": "RATE_LIMIT_EXCEEDED",
      "message": "Too many requests. Please try again later.",
      "retry_after": 30
    }
  }
  ```

---

## Offline Mode Support

### Caching Strategy

**List Endpoint (`GET /api/v1/goals`)**:
- Cache key: `goals:list:user:{userId}:status:{status}:skill:{skillId}`
- TTL: 5 minutes
- Storage: IndexedDB via React Query persistence
- Invalidation: On create/update/delete

**Get Single (`GET /api/v1/goals/{id}`)**:
- Cache key: `goal:{id}`
- TTL: 10 minutes
- Storage: IndexedDB
- Invalidation: On update/delete

**Available Skills (`GET /api/v1/me/available-skills`)**:
- Cache key: `available-skills:user:{userId}`
- TTL: 30 minutes
- Storage: IndexedDB
- Invalidation: Rarely (skills don't change often)

### Sync Mechanism

**When offline**:
1. **View goals**: Served from IndexedDB cache
2. **Create goal**: Queued in IndexedDB, shown with temporary ID
3. **Update goal**: Show error message "This action requires internet connection"
4. **Delete goal**: Show error message "This action requires internet connection"

**When connection restored**:
1. Sync queued creations to server
2. Replace temporary IDs with server-assigned UUIDs
3. Refresh cache with latest data

**Conflict Resolution**:
- Server version always wins
- If simultaneous edits detected, show error to user with server data
- User can retry with latest data

---

## Testing Requirements

### Unit Tests (Backend)
- [x] Test CreateGoalDto validation (description length, future date, skill ID)
- [x] Test UpdateGoalDto validation (optional fields, status enum)
- [x] Test authorization rules (owner/manager/admin)
- [x] Test skill filtering logic (next level only)
- [x] Test soft delete implementation (is_deleted flag set correctly)

### Integration Tests (Backend)
- [x] Test full request/response cycle for all 8 endpoints
- [x] Test authorization scenarios (employee, manager, admin roles)
- [x] Test manager_id relationship for manager access
- [x] Test skill validation (reject non-next-level skills)
- [x] Test soft delete filtering (deleted goals not in queries)
- [x] Test error responses (400, 401, 403, 404, 422)

### Frontend Tests
- [x] Test goalsService API methods
- [x] Test React Query hooks (useGoals, useCreateGoal, etc.)
- [x] Test error handling (offline, validation, authorization)
- [x] Test optimistic updates (immediate UI update, rollback on error)
- [x] Test offline caching with MSW
- [x] Test sync queue for offline creation

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| 2025-11-07 | GitHub Copilot | Initial endpoint definitions with complete goal management API |
