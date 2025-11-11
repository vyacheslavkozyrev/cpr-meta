# API Endpoints - Personal Goal Management (Detailed Specifications)

> **Feature**: 0001 - personal-goal-management  
> **Status**: Planning  
> **Created**: 2025-11-11

---

## Overview

Comprehensive API endpoint specifications for the Personal Goal Management feature. All endpoints already exist in the backend except for four new endpoints marked as **(NEW)**.

**Base URL**: `/api`

**Authentication**: Microsoft Entra External ID (JWT Bearer token)

---

## Existing Endpoints (Already Implemented)

### 1. Create Goal

**Endpoint**: `POST /api/goals`

**Description**: Create a new personal goal for the authenticated user

**Authorization**: Requires authentication (Employee role)

**Request Body**:
```json
{
  "title": "Master React Performance Optimization",
  "description": "Deep dive into React performance patterns...",
  "category": "skill",
  "priority": "high",
  "target_completion_date": "2025-12-31",
  "related_skill_id": "a1b2c3d4-e5f6-4789-0abc-def123456789"
}
```

**Response** (201 Created):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "employee_id": "123e4567-e89b-12d3-a456-426614174000",
  "title": "Master React Performance Optimization",
  "description": "Deep dive into React performance patterns...",
  "category": "skill",
  "status": "not_started",
  "priority": "high",
  "target_completion_date": "2025-12-31",
  "actual_completion_date": null,
  "progress_percentage": 0,
  "related_skill_id": "a1b2c3d4-e5f6-4789-0abc-def123456789",
  "created_at": "2025-11-11T10:30:00Z",
  "modified_at": "2025-11-11T10:30:00Z",
  "is_deleted": false,
  "tasks": []
}
```

**C# DTO** (src/CPR.Application/Contracts/GoalDto.cs):
```csharp
public class CreateGoalDto
{
    [JsonPropertyName("title")]
    [Required]
    [StringLength(200, MinimumLength = 3)]
    public string Title { get; set; } = string.Empty;
    
    [JsonPropertyName("description")]
    [StringLength(2000)]
    public string? Description { get; set; }
    
    [JsonPropertyName("category")]
    [Required]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public GoalCategory Category { get; set; }
    
    [JsonPropertyName("priority")]
    [Required]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public GoalPriority Priority { get; set; }
    
    [JsonPropertyName("target_completion_date")]
    public DateTime? TargetCompletionDate { get; set; }
    
    [JsonPropertyName("related_skill_id")]
    public Guid? RelatedSkillId { get; set; }
}

public enum GoalCategory
{
    [EnumMember(Value = "skill")] Skill,
    [EnumMember(Value = "career")] Career,
    [EnumMember(Value = "project")] Project,
    [EnumMember(Value = "personal")] Personal
}

public enum GoalPriority
{
    [EnumMember(Value = "low")] Low,
    [EnumMember(Value = "medium")] Medium,
    [EnumMember(Value = "high")] High,
    [EnumMember(Value = "critical")] Critical
}
```

**TypeScript Interface**:
```typescript
export interface CreateGoalDto {
  title: string; // 3-200 characters
  description?: string | null; // max 2000 characters
  category: 'skill' | 'career' | 'project' | 'personal';
  priority: 'low' | 'medium' | 'high' | 'critical';
  target_completion_date?: string | null; // ISO 8601 date
  related_skill_id?: string | null; // UUID
}

export interface GoalDto {
  id: string;
  employee_id: string;
  title: string;
  description: string | null;
  category: 'skill' | 'career' | 'project' | 'personal';
  status: 'not_started' | 'in_progress' | 'completed' | 'on_hold' | 'cancelled';
  priority: 'low' | 'medium' | 'high' | 'critical';
  target_completion_date: string | null;
  actual_completion_date: string | null;
  progress_percentage: number; // 0-100
  related_skill_id: string | null;
  created_at: string;
  modified_at: string;
  is_deleted: boolean;
  tasks: GoalTaskDto[];
}
```

**Validation Rules**:
- `title`: Required, 3-200 characters
- `description`: Optional, max 2000 characters
- `category`: Required, one of: skill, career, project, personal
- `priority`: Required, one of: low, medium, high, critical
- `target_completion_date`: Optional, must be future date if provided
- `related_skill_id`: Optional, must reference valid skill if provided

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `400 Bad Request` - Validation errors
- `404 Not Found` - Related skill ID not found

---

### 2. List User's Goals

**Endpoint**: `GET /api/me/goals`

**Description**: Retrieve authenticated user's goals with optional filtering and sorting

**Authorization**: Requires authentication (Employee role)

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `status` | string | No | - | Filter by status (comma-separated) |
| `category` | string | No | - | Filter by category (comma-separated) |
| `priority` | string | No | - | Filter by priority (comma-separated) |
| `search` | string | No | - | Search in title/description |
| `sort_by` | string | No | `created_at` | Sort field: created_at, modified_at, target_completion_date, title, priority, progress_percentage |
| `sort_order` | string | No | `desc` | Sort order: asc or desc |
| `include_tasks` | boolean | No | false | Include tasks in response |

**Request Example**:
```http
GET /api/me/goals?status=in_progress,not_started&category=skill&sort_by=priority&sort_order=desc&include_tasks=true HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
[
  {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "employee_id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "Master React Performance Optimization",
    "description": "Deep dive into React performance patterns...",
    "category": "skill",
    "status": "in_progress",
    "priority": "high",
    "target_completion_date": "2025-12-31",
    "actual_completion_date": null,
    "progress_percentage": 40,
    "related_skill_id": "a1b2c3d4-e5f6-4789-0abc-def123456789",
    "created_at": "2025-11-01T10:30:00Z",
    "modified_at": "2025-11-11T14:20:00Z",
    "is_deleted": false,
    "tasks": [
      {
        "id": "task-1",
        "goal_id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Study React.memo and useMemo",
        "description": "Understand when and how to use memoization",
        "is_completed": true,
        "completed_at": "2025-11-05T16:00:00Z",
        "order_index": 0,
        "created_at": "2025-11-01T10:35:00Z",
        "modified_at": "2025-11-05T16:00:00Z"
      },
      {
        "id": "task-2",
        "goal_id": "550e8400-e29b-41d4-a716-446655440000",
        "title": "Implement lazy loading for components",
        "description": "Use React.lazy and Suspense",
        "is_completed": false,
        "completed_at": null,
        "order_index": 1,
        "created_at": "2025-11-01T10:36:00Z",
        "modified_at": "2025-11-01T10:36:00Z"
      }
    ]
  }
]
```

**TypeScript Interface**:
```typescript
export interface ListGoalsQuery {
  status?: string; // comma-separated: 'not_started,in_progress'
  category?: string; // comma-separated: 'skill,career'
  priority?: string; // comma-separated: 'high,critical'
  search?: string;
  sort_by?: 'created_at' | 'modified_at' | 'target_completion_date' | 'title' | 'priority' | 'progress_percentage';
  sort_order?: 'asc' | 'desc';
  include_tasks?: boolean;
}

export interface GoalTaskDto {
  id: string;
  goal_id: string;
  title: string;
  description: string | null;
  is_completed: boolean;
  completed_at: string | null;
  order_index: number;
  created_at: string;
  modified_at: string;
}
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `400 Bad Request` - Invalid query parameters

---

### 3. Get Goal Details

**Endpoint**: `GET /api/goals/{id}`

**Description**: Retrieve specific goal by ID with all tasks

**Authorization**: 
- Requires authentication
- User must be goal owner OR manager OR admin

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |

**Request Example**:
```http
GET /api/goals/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK): Same as single goal object in list response (includes tasks by default)

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `403 Forbidden` - User not authorized to view this goal
- `404 Not Found` - Goal doesn't exist

---

### 4. Update Goal

**Endpoint**: `PATCH /api/goals/{id}`

**Description**: Update goal properties (partial update)

**Authorization**: 
- Requires authentication
- User must be goal owner

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |

**Request Body** (all fields optional):
```json
{
  "title": "Updated title",
  "description": "Updated description",
  "status": "in_progress",
  "priority": "critical",
  "target_completion_date": "2025-12-15",
  "actual_completion_date": null,
  "progress_percentage": 60,
  "related_skill_id": "new-skill-id"
}
```

**Response** (200 OK): Updated goal object

**C# DTO**:
```csharp
public class UpdateGoalDto
{
    [JsonPropertyName("title")]
    [StringLength(200, MinimumLength = 3)]
    public string? Title { get; set; }
    
    [JsonPropertyName("description")]
    [StringLength(2000)]
    public string? Description { get; set; }
    
    [JsonPropertyName("status")]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public GoalStatus? Status { get; set; }
    
    [JsonPropertyName("priority")]
    [JsonConverter(typeof(JsonStringEnumConverter))]
    public GoalPriority? Priority { get; set; }
    
    [JsonPropertyName("target_completion_date")]
    public DateTime? TargetCompletionDate { get; set; }
    
    [JsonPropertyName("actual_completion_date")]
    public DateTime? ActualCompletionDate { get; set; }
    
    [JsonPropertyName("progress_percentage")]
    [Range(0, 100)]
    public int? ProgressPercentage { get; set; }
    
    [JsonPropertyName("related_skill_id")]
    public Guid? RelatedSkillId { get; set; }
}
```

**TypeScript Interface**:
```typescript
export interface UpdateGoalDto {
  title?: string;
  description?: string | null;
  status?: 'not_started' | 'in_progress' | 'completed' | 'on_hold' | 'cancelled';
  priority?: 'low' | 'medium' | 'high' | 'critical';
  target_completion_date?: string | null;
  actual_completion_date?: string | null;
  progress_percentage?: number; // 0-100
  related_skill_id?: string | null;
}
```

**Business Rules**:
- If `status` changes to `completed`, `actual_completion_date` is auto-set to current timestamp
- If `actual_completion_date` is set, `status` auto-changes to `completed`
- `progress_percentage` is auto-calculated from task completion but can be manually overridden

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `403 Forbidden` - User not authorized to update this goal
- `404 Not Found` - Goal doesn't exist
- `400 Bad Request` - Validation errors

---

### 5. Delete Goal

**Endpoint**: `DELETE /api/goals/{id}`

**Description**: Soft-delete goal (sets is_deleted flag)

**Authorization**: 
- Requires authentication
- **Admin role only**

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |

**Request Example**:
```http
DELETE /api/goals/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (204 No Content): Empty body

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `403 Forbidden` - User doesn't have Admin role
- `404 Not Found` - Goal doesn't exist

---

### 6. Add Task to Goal

**Endpoint**: `POST /api/goals/{id}/tasks`

**Description**: Create a new task for a goal

**Authorization**: 
- Requires authentication
- User must be goal owner

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |

**Request Body**:
```json
{
  "title": "Complete React Performance course",
  "description": "Finish all modules on Frontend Masters"
}
```

**Response** (201 Created):
```json
{
  "id": "task-123",
  "goal_id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Complete React Performance course",
  "description": "Finish all modules on Frontend Masters",
  "is_completed": false,
  "completed_at": null,
  "order_index": 2,
  "created_at": "2025-11-11T10:30:00Z",
  "modified_at": "2025-11-11T10:30:00Z"
}
```

**C# DTO**:
```csharp
public class CreateGoalTaskDto
{
    [JsonPropertyName("title")]
    [Required]
    [StringLength(200, MinimumLength = 1)]
    public string Title { get; set; } = string.Empty;
    
    [JsonPropertyName("description")]
    [StringLength(1000)]
    public string? Description { get; set; }
}
```

**TypeScript Interface**:
```typescript
export interface CreateGoalTaskDto {
  title: string; // 1-200 characters
  description?: string | null; // max 1000 characters
}
```

**Business Rules**:
- `order_index` auto-assigned as max(order_index) + 1 for the goal
- Adding task recalculates goal's `progress_percentage`

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `403 Forbidden` - User not authorized to modify this goal
- `404 Not Found` - Goal doesn't exist
- `400 Bad Request` - Validation errors

---

### 7. Update Task

**Endpoint**: `PATCH /api/goals/{id}/tasks/{taskId}`

**Description**: Update task properties (partial update)

**Authorization**: 
- Requires authentication
- User must be goal owner

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |
| `taskId` | UUID | Yes | Task identifier |

**Request Body** (all fields optional):
```json
{
  "title": "Updated task title",
  "description": "Updated description",
  "is_completed": true
}
```

**Response** (200 OK): Updated task object

**C# DTO**:
```csharp
public class UpdateGoalTaskDto
{
    [JsonPropertyName("title")]
    [StringLength(200, MinimumLength = 1)]
    public string? Title { get; set; }
    
    [JsonPropertyName("description")]
    [StringLength(1000)]
    public string? Description { get; set; }
    
    [JsonPropertyName("is_completed")]
    public bool? IsCompleted { get; set; }
}
```

**TypeScript Interface**:
```typescript
export interface UpdateGoalTaskDto {
  title?: string;
  description?: string | null;
  is_completed?: boolean;
}
```

**Business Rules**:
- If `is_completed` changes to `true`, `completed_at` is auto-set to current timestamp
- If `is_completed` changes to `false`, `completed_at` is set to `null`
- Updating task completion recalculates goal's `progress_percentage`

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `403 Forbidden` - User not authorized to modify this goal
- `404 Not Found` - Goal or task doesn't exist
- `400 Bad Request` - Validation errors

---

### 8. Delete Task

**Endpoint**: `DELETE /api/goals/{id}/tasks/{taskId}`

**Description**: Permanently delete a task

**Authorization**: 
- Requires authentication
- User must be goal owner

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |
| `taskId` | UUID | Yes | Task identifier |

**Request Example**:
```http
DELETE /api/goals/550e8400-e29b-41d4-a716-446655440000/tasks/task-123 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (204 No Content): Empty body

**Business Rules**:
- Deleting task recalculates goal's `progress_percentage`
- Deleting task reorders remaining tasks (fills gap in order_index)

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `403 Forbidden` - User not authorized to modify this goal
- `404 Not Found` - Goal or task doesn't exist

---

## New Endpoints (To Be Implemented)

### 9. Skills Autocomplete **(NEW)**

**Endpoint**: `GET /api/skills`

**Description**: Search skills for autocomplete in goal creation form

**Authorization**: Requires authentication (Employee role)

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `search` | string | Yes | - | Search query (min 2 characters) |
| `limit` | integer | No | 10 | Max results (max 50) |

**Request Example**:
```http
GET /api/skills?search=react&limit=10 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
[
  {
    "id": "skill-1",
    "name": "React",
    "category": "frontend",
    "description": "JavaScript library for building user interfaces"
  },
  {
    "id": "skill-2",
    "name": "React Native",
    "category": "mobile",
    "description": "Framework for building native mobile apps"
  }
]
```

**C# DTO**:
```csharp
public class SkillDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }
    
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;
    
    [JsonPropertyName("category")]
    public string Category { get; set; } = string.Empty;
    
    [JsonPropertyName("description")]
    public string? Description { get; set; }
}
```

**TypeScript Interface**:
```typescript
export interface SkillDto {
  id: string;
  name: string;
  category: string;
  description: string | null;
}

export interface SkillsSearchQuery {
  search: string; // min 2 characters
  limit?: number; // max 50
}
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `400 Bad Request` - Search query too short (< 2 characters)

---

### 10. Get User Preferences **(NEW)**

**Endpoint**: `GET /api/user-preferences`

**Description**: Retrieve user's saved preferences for goals page (filters, sort, view mode)

**Authorization**: Requires authentication (Employee role)

**Request Example**:
```http
GET /api/user-preferences HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
{
  "goals_default_filters": {
    "status": ["in_progress", "not_started"],
    "category": null,
    "priority": null
  },
  "goals_default_sort": {
    "sort_by": "priority",
    "sort_order": "desc"
  },
  "goals_view_mode": "card"
}
```

**C# DTO**:
```csharp
public class UserPreferencesDto
{
    [JsonPropertyName("goals_default_filters")]
    public GoalsFilters? GoalsDefaultFilters { get; set; }
    
    [JsonPropertyName("goals_default_sort")]
    public GoalsSortOptions? GoalsDefaultSort { get; set; }
    
    [JsonPropertyName("goals_view_mode")]
    public string? GoalsViewMode { get; set; } // "card" or "table"
}

public class GoalsFilters
{
    [JsonPropertyName("status")]
    public List<string>? Status { get; set; }
    
    [JsonPropertyName("category")]
    public List<string>? Category { get; set; }
    
    [JsonPropertyName("priority")]
    public List<string>? Priority { get; set; }
}

public class GoalsSortOptions
{
    [JsonPropertyName("sort_by")]
    public string? SortBy { get; set; }
    
    [JsonPropertyName("sort_order")]
    public string? SortOrder { get; set; } // "asc" or "desc"
}
```

**TypeScript Interface**:
```typescript
export interface UserPreferencesDto {
  goals_default_filters: {
    status: string[] | null;
    category: string[] | null;
    priority: string[] | null;
  } | null;
  goals_default_sort: {
    sort_by: string;
    sort_order: 'asc' | 'desc';
  } | null;
  goals_view_mode: 'card' | 'table' | null;
}
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `404 Not Found` - User has no saved preferences (return default empty object)

---

### 11. Save User Preferences **(NEW)**

**Endpoint**: `PUT /api/user-preferences`

**Description**: Save or update user's preferences for goals page

**Authorization**: Requires authentication (Employee role)

**Request Body**:
```json
{
  "goals_default_filters": {
    "status": ["in_progress"],
    "category": ["skill", "career"],
    "priority": null
  },
  "goals_default_sort": {
    "sort_by": "target_completion_date",
    "sort_order": "asc"
  },
  "goals_view_mode": "table"
}
```

**Response** (200 OK): Updated preferences object (same as GET response)

**C# DTO**: Same as UserPreferencesDto above

**TypeScript Interface**: Same as UserPreferencesDto above

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `400 Bad Request` - Invalid preference values

---

### 12. Reorder Tasks **(NEW)**

**Endpoint**: `PATCH /api/goals/{id}/tasks/reorder`

**Description**: Batch update task order (for drag-and-drop)

**Authorization**: 
- Requires authentication
- User must be goal owner

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Goal identifier |

**Request Body**:
```json
{
  "task_order": [
    {
      "task_id": "task-3",
      "order_index": 0
    },
    {
      "task_id": "task-1",
      "order_index": 1
    },
    {
      "task_id": "task-2",
      "order_index": 2
    }
  ]
}
```

**Response** (200 OK):
```json
{
  "message": "Task order updated successfully",
  "updated_count": 3
}
```

**C# DTO**:
```csharp
public class ReorderTasksDto
{
    [JsonPropertyName("task_order")]
    [Required]
    [MinLength(1)]
    public List<TaskOrderItem> TaskOrder { get; set; } = new();
}

public class TaskOrderItem
{
    [JsonPropertyName("task_id")]
    [Required]
    public Guid TaskId { get; set; }
    
    [JsonPropertyName("order_index")]
    [Required]
    [Range(0, int.MaxValue)]
    public int OrderIndex { get; set; }
}
```

**TypeScript Interface**:
```typescript
export interface ReorderTasksDto {
  task_order: TaskOrderItem[];
}

export interface TaskOrderItem {
  task_id: string;
  order_index: number; // >= 0
}
```

**Business Rules**:
- All tasks in request must belong to the specified goal
- `order_index` values must be sequential starting from 0
- If any task_id is invalid, entire operation fails (transactional)

**Error Responses**:
- `401 Unauthorized` - Missing or invalid JWT token
- `403 Forbidden` - User not authorized to modify this goal
- `404 Not Found` - Goal doesn't exist
- `400 Bad Request` - Validation errors (invalid task IDs, non-sequential indices)

---

## Rate Limiting

All endpoints are subject to rate limiting:

- **Authenticated users**: 100 requests per minute per user
- **Burst limit**: 20 requests per 10 seconds
- **Rate limit headers** (included in all responses):
  ```
  X-RateLimit-Limit: 100
  X-RateLimit-Remaining: 95
  X-RateLimit-Reset: 1636300800
  ```

**Rate limit exceeded** (429 Too Many Requests):
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

## Error Response Format

All error responses follow this consistent structure:

```json
{
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": [
      {
        "field": "field_name",
        "message": "Field-specific error message"
      }
    ],
    "trace_id": "00-abc123-def456-00"
  }
}
```

**Standard Error Codes**:
- `VALIDATION_ERROR` - Input validation failed (400)
- `UNAUTHORIZED` - Authentication required or failed (401)
- `FORBIDDEN` - Insufficient permissions (403)
- `NOT_FOUND` - Resource not found (404)
- `CONFLICT` - Resource conflict or business rule violation (409)
- `RATE_LIMIT_EXCEEDED` - Too many requests (429)
- `INTERNAL_ERROR` - Unexpected server error (500)

---

## Testing Requirements

### Backend Unit Tests
- [ ] Test request validation for all DTOs
- [ ] Test authorization rules (owner, manager, admin)
- [ ] Test business logic (progress calculation, auto-dates)
- [ ] Test error responses for all failure scenarios

### Backend Integration Tests
- [ ] Test full request/response cycle for each endpoint
- [ ] Test database constraints (foreign keys, unique constraints)
- [ ] Test filtering, sorting, and pagination
- [ ] Test transaction rollback on errors

### Frontend Tests
- [ ] Test API service methods (goalService.ts, taskService.ts)
- [ ] Test error handling and retry logic
- [ ] Test MSW mock handlers for all endpoints
- [ ] Test offline queue and sync mechanism

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| 2025-11-11 | Agent | Initial comprehensive endpoint specifications |
