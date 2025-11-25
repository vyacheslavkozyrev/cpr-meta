# API Endpoints - Feedback Submission Collection

> **Feature**: 0005 - feedback-submission-collection  
> **Status**: Planning  
> **Created**: 2025-11-24  
> **Last Updated**: 2025-11-24

---

## Overview

This document defines all API endpoints for the Feedback Submission Collection feature, including request/response contracts, validation rules, and authorization requirements.

**Base URL**: `/api/v1`

**API Version**: v1

**Authentication**: Required (JWT Bearer token)

---

## Endpoints Summary

| Method | Endpoint                     | Description                                                                            | Auth        | Backend Status                       |
| ------ | ---------------------------- | -------------------------------------------------------------------------------------- | ----------- | ------------------------------------ |
| POST   | `/api/feedback`              | Submit feedback to another employee                                                    | ✅ Required | ✅ Implemented                       |
| GET    | `/api/me/feedback`           | Get all feedback addressed to authenticated user (with filtering, sorting, pagination) | ✅ Required | ✅ Implemented (verify query params) |
| GET    | `/api/me/feedback/{id}`      | Get single feedback item by ID                                                         | ✅ Required | ✅ Implemented (implicit)            |
| GET    | `/api/me/feedback/analytics` | Get feedback analytics summary                                                         | ✅ Required | ⚠️ To Be Verified                    |
| GET    | `/api/employees/{id}/goals`  | Get goals for specific employee (for unsolicited feedback)                             | ✅ Required | ⚠️ To Be Verified                    |

**Notes**:

- All endpoints already implemented in backend (cpr-api)
- This document specifies complete request/response contracts for frontend implementation
- TypeScript interfaces must be created to match C# DTOs

---

## Common Response Codes

All endpoints use standard HTTP status codes:

| Code | Meaning               | Usage                                            |
| ---- | --------------------- | ------------------------------------------------ |
| 200  | OK                    | Successful GET, PUT, DELETE                      |
| 201  | Created               | Successful POST                                  |
| 204  | No Content            | Successful DELETE (alternative)                  |
| 400  | Bad Request           | Validation error, malformed request              |
| 401  | Unauthorized          | Missing or invalid authentication                |
| 403  | Forbidden             | Authenticated but insufficient permissions       |
| 404  | Not Found             | Resource doesn't exist                           |
| 409  | Conflict              | Resource already exists, business rule violation |
| 422  | Unprocessable Entity  | Semantic validation error                        |
| 500  | Internal Server Error | Unexpected server error                          |

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

### 1. Submit Feedback Response

**Endpoint**: `POST /api/feedback`

**Description**: Submit feedback for a colleague (with or without a feedback request)

**Authorization**:

- Requires authentication (JWT Bearer token)
- User must be an active employee
- Cannot submit feedback for self (`to_employee_id` cannot equal current user ID)

**Request Headers**:

```
Authorization: Bearer <jwt_token>
Content-Type: application/json
```

**Request Body**:

```json
{
  "feedback_request_id": "550e8400-e29b-41d4-a716-446655440000",
  "goal_id": "123e4567-e89b-12d3-a456-426614174001",
  "project_id": "987fcdeb-51a2-43c1-9d2e-123456789abc",
  "to_employee_id": "234e5678-e89b-12d3-a456-426614174002",
  "content": "Great work on the Q4 presentation! Your communication skills have improved significantly.",
  "rating": 5
}
```

**Field Requirements**:
| Field | Type | Required | Constraints | Notes |
|-------|------|----------|-------------|-------|
| `feedback_request_id` | UUID | No | Must exist, must be for current user | If provided, auto-fills goal/project/employee from request |
| `goal_id` | UUID | No* | Must exist, must be accessible | *Required if no feedback_request_id |
| `project_id` | UUID | No | Must exist, must be accessible | Optional context |
| `to_employee_id` | UUID | Yes | Must exist, cannot be current user | Recipient |
| `content` | string | Yes | 10-2000 characters | Feedback text |
| `rating` | integer | Yes | 1-5 | Star rating |

**Validation Rules**:

1. **Self-Feedback Prevention**: `to_employee_id` cannot equal authenticated user ID → 400 Bad Request
2. **Duplicate Prevention**: Same user cannot submit multiple feedback for same goal/project/employee within 24 hours → 409 Conflict
3. **Content Length**: 10-2000 characters → 400 Bad Request
4. **Rating Range**: 1-5 stars → 400 Bad Request
5. **Goal/Project Context**: At least one of `goal_id` or `project_id` required if no `feedback_request_id` → 400 Bad Request
6. **Feedback Request Validation**: If `feedback_request_id` provided, must exist and be addressed to current user → 404 Not Found
7. **Employee Existence**: `to_employee_id` must exist in system → 404 Not Found

**Response** (201 Created):

```json
{
  "id": "660f9511-f39c-52e5-b827-557766551111",
  "feedback_request_id": "550e8400-e29b-41d4-a716-446655440000",
  "goal": {
    "id": "123e4567-e89b-12d3-a456-426614174001",
    "title": "Improve Public Speaking Skills"
  },
  "project": {
    "id": "987fcdeb-51a2-43c1-9d2e-123456789abc",
    "name": "Q4 Marketing Campaign"
  },
  "from_employee": {
    "id": "111e2222-e89b-12d3-a456-426614174003",
    "first_name": "Alice",
    "last_name": "Johnson",
    "email": "alice.johnson@company.com",
    "department": "Marketing"
  },
  "to_employee": {
    "id": "234e5678-e89b-12d3-a456-426614174002",
    "first_name": "Bob",
    "last_name": "Smith",
    "email": "bob.smith@company.com",
    "department": "Sales"
  },
  "content": "Great work on the Q4 presentation! Your communication skills have improved significantly.",
  "rating": 5,
  "created_at": "2025-11-24T14:30:00Z",
  "updated_at": "2025-11-24T14:30:00Z"
}
```

**Side Effects**:

1. If `feedback_request_id` provided, marks request as completed (status → 'completed', completed_at → now())
2. Increments feedback count for goal/project (if applicable)
3. Triggers notification to recipient (depending on notification settings)
4. Updates recipient's feedback analytics (average rating, total feedback count)

**C# DTOs** (Backend - src/CPR.Application/Contracts/FeedbackDtos.cs):

```csharp
// Request DTO
public class SubmitFeedbackRequestDto
{
    [JsonPropertyName("feedback_request_id")]
    public Guid? FeedbackRequestId { get; set; }

    [JsonPropertyName("goal_id")]
    public Guid? GoalId { get; set; }

    [JsonPropertyName("project_id")]
    public Guid? ProjectId { get; set; }

    [JsonPropertyName("to_employee_id")]
    [Required(ErrorMessage = "Recipient employee ID is required")]
    public Guid ToEmployeeId { get; set; }

    [Required(ErrorMessage = "Feedback content is required")]
    [StringLength(2000, MinimumLength = 10, ErrorMessage = "Content must be between 10 and 2000 characters")]
    [JsonPropertyName("content")]
    public string Content { get; set; } = string.Empty;

    [Required(ErrorMessage = "Rating is required")]
    [Range(1, 5, ErrorMessage = "Rating must be between 1 and 5")]
    [JsonPropertyName("rating")]
    public int Rating { get; set; }
}

// Response DTO
public class FeedbackDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("feedback_request_id")]
    public Guid? FeedbackRequestId { get; set; }

    [JsonPropertyName("goal")]
    public GoalSummaryDto? Goal { get; set; }

    [JsonPropertyName("project")]
    public ProjectSummaryDto? Project { get; set; }

    [JsonPropertyName("from_employee")]
    public EmployeeSummaryDto FromEmployee { get; set; } = null!;

    [JsonPropertyName("to_employee")]
    public EmployeeSummaryDto ToEmployee { get; set; } = null!;

    [JsonPropertyName("content")]
    public string Content { get; set; } = string.Empty;

    [JsonPropertyName("rating")]
    public int Rating { get; set; }

    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }

    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

// Supporting DTOs
public class EmployeeSummaryDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("first_name")]
    public string FirstName { get; set; } = string.Empty;

    [JsonPropertyName("last_name")]
    public string LastName { get; set; } = string.Empty;

    [JsonPropertyName("email")]
    public string Email { get; set; } = string.Empty;

    [JsonPropertyName("department")]
    public string? Department { get; set; }
}

public class GoalSummaryDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("title")]
    public string Title { get; set; } = string.Empty;
}

public class ProjectSummaryDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;
}
```

**TypeScript Interfaces** (Frontend - src/types/feedback.ts):

```typescript
// Request interface
export interface SubmitFeedbackRequest {
  feedback_request_id?: string;
  goal_id?: string;
  project_id?: string;
  to_employee_id: string;
  content: string;
  rating: number;
}

// Response interface
export interface Feedback {
  id: string;
  feedback_request_id?: string;
  goal?: GoalSummary;
  project?: ProjectSummary;
  from_employee: EmployeeSummary;
  to_employee: EmployeeSummary;
  content: string;
  rating: number;
  created_at: string;
  updated_at: string;
}

// Supporting interfaces
export interface EmployeeSummary {
  id: string;
  first_name: string;
  last_name: string;
  email: string;
  department?: string;
}

export interface GoalSummary {
  id: string;
  title: string;
}

export interface ProjectSummary {
  id: string;
  name: string;
}
```

**Error Responses**:

400 Bad Request (Validation Error):

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more validation errors occurred",
    "details": [
      {
        "field": "content",
        "message": "Content must be between 10 and 2000 characters"
      },
      {
        "field": "rating",
        "message": "Rating must be between 1 and 5"
      }
    ],
    "trace_id": "00-abc123-def456-00"
  }
}
```

400 Bad Request (Self-Feedback):

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Cannot submit feedback for yourself",
    "trace_id": "00-abc123-def456-00"
  }
}
```

404 Not Found:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Employee with ID '234e5678-e89b-12d3-a456-426614174002' not found",
    "trace_id": "00-abc123-def456-00"
  }
}
```

409 Conflict (Duplicate):

```json
{
  "error": {
    "code": "CONFLICT",
    "message": "You have already submitted feedback for this goal/project/employee within the last 24 hours",
    "trace_id": "00-abc123-def456-00"
  }
}
```

---

### 2. List My Received Feedback

**Endpoint**: `GET /api/me/feedback`

**Description**: Retrieve paginated list of feedback received by the authenticated user with optional filtering

**Authorization**:

- Requires authentication (JWT Bearer token)
- Returns only feedback where `to_employee_id` matches authenticated user

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | integer | No | 1 | Page number (1-based) |
| `page_size` | integer | No | 20 | Items per page (1-100) |
| `date_from` | ISO 8601 | No | - | Start date filter (created_at >= date_from) |
| `date_to` | ISO 8601 | No | - | End date filter (created_at <= date_to) |
| `rating` | integer | No | - | Filter by rating (1-5) |
| `goal_id` | UUID | No | - | Filter by goal |
| `project_id` | UUID | No | - | Filter by project |
| `from_employee_id` | UUID | No | - | Filter by feedback giver |
| `search` | string | No | - | Search in content (case-insensitive) |
| `sort_by` | string | No | `created_at` | Sort field: `created_at`, `rating`, `updated_at` |
| `sort_order` | string | No | `desc` | Sort order: `asc` or `desc` |

**Request Example**:

```http
GET /api/me/feedback?page=1&page_size=20&rating=5&goal_id=123e4567-e89b-12d3-a456-426614174001&sort_by=created_at&sort_order=desc HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):

```json
{
  "data": [
    {
      "id": "660f9511-f39c-52e5-b827-557766551111",
      "feedback_request_id": "550e8400-e29b-41d4-a716-446655440000",
      "goal": {
        "id": "123e4567-e89b-12d3-a456-426614174001",
        "title": "Improve Public Speaking Skills"
      },
      "project": {
        "id": "987fcdeb-51a2-43c1-9d2e-123456789abc",
        "name": "Q4 Marketing Campaign"
      },
      "from_employee": {
        "id": "111e2222-e89b-12d3-a456-426614174003",
        "first_name": "Alice",
        "last_name": "Johnson",
        "email": "alice.johnson@company.com",
        "department": "Marketing"
      },
      "content": "Great work on the Q4 presentation! Your communication skills have improved significantly.",
      "rating": 5,
      "created_at": "2025-11-24T14:30:00Z",
      "updated_at": "2025-11-24T14:30:00Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total_items": 45,
    "total_pages": 3
  }
}
```

**⚠️ VERIFICATION REQUIRED**: Backend may not support all query parameters. Task T000 (Backend Verification) will confirm which filters are implemented. If missing, options are:

1. Add backend support (estimated 2-4 hours)
2. Implement client-side filtering in frontend for MVP (performance acceptable for <1000 items)

**C# DTOs** (Backend - src/CPR.Application/Contracts/FeedbackDtos.cs):

```csharp
// Query Parameters DTO (to be verified/created)
public class ListMyFeedbackQueryDto
{
    public int Page { get; set; } = 1;

    [Range(1, 100)]
    public int PageSize { get; set; } = 20;

    [JsonPropertyName("date_from")]
    public DateTime? DateFrom { get; set; }

    [JsonPropertyName("date_to")]
    public DateTime? DateTo { get; set; }

    [Range(1, 5)]
    public int? Rating { get; set; }

    [JsonPropertyName("goal_id")]
    public Guid? GoalId { get; set; }

    [JsonPropertyName("project_id")]
    public Guid? ProjectId { get; set; }

    [JsonPropertyName("from_employee_id")]
    public Guid? FromEmployeeId { get; set; }

    public string? Search { get; set; }

    [JsonPropertyName("sort_by")]
    public string SortBy { get; set; } = "created_at";

    [JsonPropertyName("sort_order")]
    public string SortOrder { get; set; } = "desc";
}

// Response DTO
public class PaginatedMyFeedbackResponseDto
{
    [JsonPropertyName("data")]
    public List<MyFeedbackDto> Data { get; set; } = new();

    [JsonPropertyName("pagination")]
    public PaginationDto Pagination { get; set; } = new();
}

// MyFeedbackDto (existing - excludes to_employee since it's always current user)
public class MyFeedbackDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("feedback_request_id")]
    public Guid? FeedbackRequestId { get; set; }

    [JsonPropertyName("goal")]
    public GoalSummaryDto? Goal { get; set; }

    [JsonPropertyName("project")]
    public ProjectSummaryDto? Project { get; set; }

    [JsonPropertyName("from_employee")]
    public EmployeeSummaryDto FromEmployee { get; set; } = null!;

    [JsonPropertyName("content")]
    public string Content { get; set; } = string.Empty;

    [JsonPropertyName("rating")]
    public int Rating { get; set; }

    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }

    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
}

public class PaginationDto
{
    [JsonPropertyName("page")]
    public int Page { get; set; }

    [JsonPropertyName("page_size")]
    public int PageSize { get; set; }

    [JsonPropertyName("total_items")]
    public int TotalItems { get; set; }

    [JsonPropertyName("total_pages")]
    public int TotalPages { get; set; }
}
```

**TypeScript Interfaces** (Frontend - src/types/feedback.ts):

```typescript
// Query parameters interface
export interface ListMyFeedbackQuery {
  page?: number;
  page_size?: number;
  date_from?: string; // ISO 8601
  date_to?: string; // ISO 8601
  rating?: number;
  goal_id?: string;
  project_id?: string;
  from_employee_id?: string;
  search?: string;
  sort_by?: "created_at" | "rating" | "updated_at";
  sort_order?: "asc" | "desc";
}

// Response interface
export interface PaginatedMyFeedbackResponse {
  data: MyFeedback[];
  pagination: Pagination;
}

// MyFeedback (received feedback - excludes to_employee)
export interface MyFeedback {
  id: string;
  feedback_request_id?: string;
  goal?: GoalSummary;
  project?: ProjectSummary;
  from_employee: EmployeeSummary;
  content: string;
  rating: number;
  created_at: string;
  updated_at: string;
}

export interface Pagination {
  page: number;
  page_size: number;
  total_items: number;
  total_pages: number;
}
```

**Error Responses**:

400 Bad Request (Invalid Parameters):

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Invalid query parameters",
    "details": [
      {
        "field": "rating",
        "message": "Rating must be between 1 and 5"
      },
      {
        "field": "page_size",
        "message": "Page size must be between 1 and 100"
      }
    ],
    "trace_id": "00-abc123-def456-00"
  }
}
```

---

### 3. Get Single Feedback Detail

**Endpoint**: `GET /api/me/feedback/{id}`

**Description**: Retrieve detailed information for a single feedback item received by the authenticated user

**Authorization**:

- Requires authentication (JWT Bearer token)
- Feedback must be addressed to authenticated user (to_employee_id check)

\*\*Path Parameters
// Request (Query Parameters)
export interface ListResourceQuery {
page?: number;
page_size?: number;
sort_by?: string;
sort_order?: 'asc' | 'desc';
status?: string;
search?: string;
}

// Response
export interface PaginatedResourceResponse {
data: ResourceDto[];
pagination: Pagination;
}

export interface ResourceDto {
id: string;
name: string;
description: string | null;
status: string;
created_at: string; // ISO 8601
updated_at: string; // ISO 8601
user_id: string;
}

export interface Pagination {
page: number;
page_size: number;
total_items: number;
total_pages: number;
}

````

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication token
- `400 Bad Request` - Invalid query parameters (e.g., page_size > 100)



**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Feedback identifier |

**Request Example**:
```http
GET /api/me/feedback/660f9511-f39c-52e5-b827-557766551111 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
````

**Response** (200 OK):

```json
{
  "id": "660f9511-f39c-52e5-b827-557766551111",
  "feedback_request_id": "550e8400-e29b-41d4-a716-446655440000",
  "goal": {
    "id": "123e4567-e89b-12d3-a456-426614174001",
    "title": "Improve Public Speaking Skills"
  },
  "project": {
    "id": "987fcdeb-51a2-43c1-9d2e-123456789abc",
    "name": "Q4 Marketing Campaign"
  },
  "from_employee": {
    "id": "111e2222-e89b-12d3-a456-426614174003",
    "first_name": "Alice",
    "last_name": "Johnson",
    "email": "alice.johnson@company.com",
    "department": "Marketing"
  },
  "content": "Great work on the Q4 presentation! Your communication skills have improved significantly.",
  "rating": 5,
  "created_at": "2025-11-24T14:30:00Z",
  "updated_at": "2025-11-24T14:30:00Z"
}
```

**C# DTO**: Same as `MyFeedbackDto` from endpoint 2

**TypeScript Interface**: Same as `MyFeedback` from endpoint 2

**Error Responses**:

404 Not Found:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Feedback with ID '660f9511-f39c-52e5-b827-557766551111' not found or not accessible",
    "trace_id": "00-abc123-def456-00"
  }
}
```

403 Forbidden (if trying to access someone else's feedback):

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "You do not have permission to view this feedback",
    "trace_id": "00-abc123-def456-00"
  }
}
```

---

### 4. Get My Feedback Analytics

**Endpoint**: `GET /api/me/feedback/analytics`

**Description**: Get analytics and statistics for received feedback (average rating, total count, rating distribution, trends)

**Authorization**:

- Requires authentication (JWT Bearer token)
- Returns analytics for authenticated user only

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `date_from` | ISO 8601 | No | - | Start date for analytics window |
| `date_to` | ISO 8601 | No | - | End date for analytics window |
| `goal_id` | UUID | No | - | Filter analytics by specific goal |
| `project_id` | UUID | No | - | Filter analytics by specific project |

**Request Example**:

```http
GET /api/me/feedback/analytics?date_from=2024-01-01&date_to=2024-12-31 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):

```json
{
  "period": {
    "start": "2024-01-01T00:00:00Z",
    "end": "2024-12-31T23:59:59Z"
  },
  "summary": {
    "total_feedback": 45,
    "average_rating": 4.2,
    "rating_distribution": {
      "1": 2,
      "2": 3,
      "3": 8,
      "4": 12,
      "5": 20
    },
    "unique_contributors": 15
  },
  "by_goal": [
    {
      "goal": {
        "id": "123e4567-e89b-12d3-a456-426614174001",
        "title": "Improve Public Speaking Skills"
      },
      "count": 12,
      "average_rating": 4.5
    },
    {
      "goal": {
        "id": "234e5678-e89b-12d3-a456-426614174002",
        "title": "Master Project Management"
      },
      "count": 8,
      "average_rating": 4.0
    }
  ],
  "by_project": [
    {
      "project": {
        "id": "987fcdeb-51a2-43c1-9d2e-123456789abc",
        "name": "Q4 Marketing Campaign"
      },
      "count": 15,
      "average_rating": 4.3
    }
  ],
  "trends": {
    "monthly": [
      {
        "month": "2024-01",
        "count": 3,
        "average_rating": 4.0
      },
      {
        "month": "2024-02",
        "count": 5,
        "average_rating": 4.2
      },
      {
        "month": "2024-03",
        "count": 7,
        "average_rating": 4.5
      }
    ]
  },
  "recent_feedback_preview": [
    {
      "id": "660f9511-f39c-52e5-b827-557766551111",
      "from_employee": {
        "id": "111e2222-e89b-12d3-a456-426614174003",
        "first_name": "Alice",
        "last_name": "Johnson"
      },
      "rating": 5,
      "content_snippet": "Great work on the Q4 presentation!...",
      "created_at": "2025-11-24T14:30:00Z"
    }
  ]
}
```

**⚠️ VERIFICATION REQUIRED**: This endpoint may need to be created in backend. Estimated effort: 8-12 hours for full analytics implementation.

**C# DTOs** (Backend - to be created):

```csharp
// Query Parameters
public class FeedbackAnalyticsQueryDto
{
    [JsonPropertyName("date_from")]
    public DateTime? DateFrom { get; set; }

    [JsonPropertyName("date_to")]
    public DateTime? DateTo { get; set; }

    [JsonPropertyName("goal_id")]
    public Guid? GoalId { get; set; }

    [JsonPropertyName("project_id")]
    public Guid? ProjectId { get; set; }
}

// Response DTO
public class FeedbackAnalyticsDto
{
    [JsonPropertyName("period")]
    public AnalyticsPeriodDto Period { get; set; } = null!;

    [JsonPropertyName("summary")]
    public AnalyticsSummaryDto Summary { get; set; } = null!;

    [JsonPropertyName("by_goal")]
    public List<GoalAnalyticsDto> ByGoal { get; set; } = new();

    [JsonPropertyName("by_project")]
    public List<ProjectAnalyticsDto> ByProject { get; set; } = new();

    [JsonPropertyName("trends")]
    public TrendsDto Trends { get; set; } = null!;

    [JsonPropertyName("recent_feedback_preview")]
    public List<FeedbackPreviewDto> RecentFeedbackPreview { get; set; } = new();
}

public class AnalyticsPeriodDto
{
    [JsonPropertyName("start")]
    public DateTime Start { get; set; }

    [JsonPropertyName("end")]
    public DateTime End { get; set; }
}

public class AnalyticsSummaryDto
{
    [JsonPropertyName("total_feedback")]
    public int TotalFeedback { get; set; }

    [JsonPropertyName("average_rating")]
    public double AverageRating { get; set; }

    [JsonPropertyName("rating_distribution")]
    public Dictionary<int, int> RatingDistribution { get; set; } = new();

    [JsonPropertyName("unique_contributors")]
    public int UniqueContributors { get; set; }
}

public class GoalAnalyticsDto
{
    [JsonPropertyName("goal")]
    public GoalSummaryDto Goal { get; set; } = null!;

    [JsonPropertyName("count")]
    public int Count { get; set; }

    [JsonPropertyName("average_rating")]
    public double AverageRating { get; set; }
}

public class ProjectAnalyticsDto
{
    [JsonPropertyName("project")]
    public ProjectSummaryDto Project { get; set; } = null!;

    [JsonPropertyName("count")]
    public int Count { get; set; }

    [JsonPropertyName("average_rating")]
    public double AverageRating { get; set; }
}

public class TrendsDto
{
    [JsonPropertyName("monthly")]
    public List<MonthlyTrendDto> Monthly { get; set; } = new();
}

public class MonthlyTrendDto
{
    [JsonPropertyName("month")]
    public string Month { get; set; } = string.Empty; // YYYY-MM

    [JsonPropertyName("count")]
    public int Count { get; set; }

    [JsonPropertyName("average_rating")]
    public double AverageRating { get; set; }
}

public class FeedbackPreviewDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("from_employee")]
    public EmployeeSummaryDto FromEmployee { get; set; } = null!;

    [JsonPropertyName("rating")]
    public int Rating { get; set; }

    [JsonPropertyName("content_snippet")]
    public string ContentSnippet { get; set; } = string.Empty; // First 100 chars

    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
}
```

**TypeScript Interfaces** (Frontend - src/types/feedback.ts):

```typescript
// Query parameters
export interface FeedbackAnalyticsQuery {
  date_from?: string; // ISO 8601
  date_to?: string; // ISO 8601
  goal_id?: string;
  project_id?: string;
}

// Response interface
export interface FeedbackAnalytics {
  period: AnalyticsPeriod;
  summary: AnalyticsSummary;
  by_goal: GoalAnalytics[];
  by_project: ProjectAnalytics[];
  trends: Trends;
  recent_feedback_preview: FeedbackPreview[];
}

export interface AnalyticsPeriod {
  start: string;
  end: string;
}

export interface AnalyticsSummary {
  total_feedback: number;
  average_rating: number;
  rating_distribution: Record<number, number>;
  unique_contributors: number;
}

export interface GoalAnalytics {
  goal: GoalSummary;
  count: number;
  average_rating: number;
}

export interface ProjectAnalytics {
  project: ProjectSummary;
  count: number;
  average_rating: number;
}

export interface Trends {
  monthly: MonthlyTrend[];
}

export interface MonthlyTrend {
  month: string; // YYYY-MM
  count: number;
  average_rating: number;
}

export interface FeedbackPreview {
  id: string;
  from_employee: EmployeeSummary;
  rating: number;
  content_snippet: string;
  created_at: string;
}
```

**Error Responses**:

400 Bad Request (Invalid Date Range):

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "date_from must be before date_to",
    "trace_id": "00-abc123-def456-00"
  }
}
```

---

### 5. Get Employee's Goals (for Goal Selection)

**Endpoint**: `GET /api/employees/{employee_id}/goals`

**Description**: Retrieve active goals for a specific employee (used when selecting goal context while giving feedback)

**Authorization**:

- Requires authentication (JWT Bearer token)
- Goals must be publicly visible or user must have permission to view employee's goals
- Typically used when giving feedback to show relevant goal options

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `employee_id` | UUID | Yes | Employee identifier |

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `status` | string | No | `active` | Filter by goal status (active, completed, archived) |

**Request Example**:

```http
GET /api/employees/234e5678-e89b-12d3-a456-426614174002/goals?status=active HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):

```json
{
  "data": [
    {
      "id": "123e4567-e89b-12d3-a456-426614174001",
      "title": "Improve Public Speaking Skills",
      "description": "Deliver at least 3 presentations to large audiences",
      "status": "active",
      "progress": 66,
      "target_date": "2025-12-31",
      "created_at": "2025-01-15T10:00:00Z"
    },
    {
      "id": "234e5678-e89b-12d3-a456-426614174002",
      "title": "Master Project Management",
      "description": "Complete PMP certification",
      "status": "active",
      "progress": 45,
      "target_date": "2025-06-30",
      "created_at": "2025-02-01T10:00:00Z"
    }
  ]
}
```

**⚠️ VERIFICATION REQUIRED**: This endpoint may already exist in F001 (Goals). If not, estimated effort: 4-6 hours to add with proper authorization.

**C# DTOs** (Backend - likely in CPR.Application.Contracts.GoalDtos.cs):

```csharp
// Response DTO
public class EmployeeGoalsResponseDto
{
    [JsonPropertyName("data")]
    public List<GoalSummaryDto> Data { get; set; } = new();
}

public class GoalDetailDto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }

    [JsonPropertyName("title")]
    public string Title { get; set; } = string.Empty;

    [JsonPropertyName("description")]
    public string? Description { get; set; }

    [JsonPropertyName("status")]
    public string Status { get; set; } = string.Empty;

    [JsonPropertyName("progress")]
    public int Progress { get; set; } // 0-100

    [JsonPropertyName("target_date")]
    public DateTime? TargetDate { get; set; }

    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
}
```

**TypeScript Interfaces** (Frontend - src/types/goals.ts or src/types/feedback.ts):

```typescript
// Response interface
export interface EmployeeGoalsResponse {
  data: GoalDetail[];
}

export interface GoalDetail {
  id: string;
  title: string;
  description?: string;
  status: "active" | "completed" | "archived";
  progress: number; // 0-100
  target_date?: string; // ISO 8601
  created_at: string;
}
```

**Error Responses**:

404 Not Found:

```json
{
  "error": {
    "code": "NOT_FOUND",
    "message": "Employee with ID '234e5678-e89b-12d3-a456-426614174002' not found",
    "trace_id": "00-abc123-def456-00"
  }
}
```

403 Forbidden (if goals are private):

```json
{
  "error": {
    "code": "FORBIDDEN",
    "message": "You do not have permission to view this employee's goals",
    "trace_id": "00-abc123-def456-00"
  }
}
```

---

## Business Rules

Key business rules enforced by these endpoints:

1. **Self-Feedback Prevention**: Users cannot submit feedback for themselves (to_employee_id ≠ current user ID). Enforced in POST /api/feedback with 400 Bad Request.

2. **Duplicate Feedback Prevention**: A user cannot submit multiple feedback items for the same goal/project/employee combination within 24 hours. Enforced with 409 Conflict.

3. **Feedback Request Auto-Completion**: When feedback is submitted via feedback_request_id, the related FeedbackRequest status automatically changes to 'completed' and completed_at timestamp is set.

4. **Context Requirement**: Feedback must have at least one context (goal_id, project_id, or feedback_request_id). Enforced in POST /api/feedback validation.

5. **Authorization Scope**: GET /api/me/feedback only returns feedback where to_employee_id matches authenticated user (data isolation).

6. **Rating Normalization**: All ratings must be integers 1-5 (no decimals, no 0, no >5). Enforced via [Range(1,5)] validation.

7. **Content Length**: Feedback content must be 10-2000 characters (prevents empty or excessive feedback). Enforced via [StringLength(2000, MinimumLength=10)].

8. **Employee Existence**: All referenced employee IDs (to_employee_id, from_employee_id in queries) must exist in the system. Enforced with 404 Not Found.

9. **Goal/Project Visibility**: Users can only link feedback to goals/projects they have access to (active goals for the employee, projects they're members of).

10. **Analytics Privacy**: GET /api/me/feedback/analytics only returns aggregated data for the authenticated user's received feedback (no access to others' analytics).

---

## Integration Points

These endpoints integrate with other CPR features:

### Feature 0004 (Feedback Request Management)

- POST /api/feedback accepts `feedback_request_id` parameter
- When feedback is submitted via request, the request status is automatically updated to 'completed'
- Feedback form can pre-fill goal/project/employee from the request context

### Feature 0001 (Personal Goal Management)

- POST /api/feedback links to goals via `goal_id`
- GET /api/employees/{employee_id}/goals provides goal selection options
- Goal analytics show feedback received per goal

### Feature 0011 (Project Management)

- POST /api/feedback links to projects via `project_id`
- Project dashboards can display feedback metrics
- Team feedback aggregated by project

### Authentication System (Microsoft Entra External ID)

- All endpoints require valid JWT Bearer token
- `from_employee_id` is derived from JWT claims (not user-supplied)
- Authorization checks enforce data isolation (users only see their own received feedback)

### Dashboard (Feature TBD)

- GET /api/me/feedback/analytics provides summary cards
- Recent feedback preview shown on dashboard
- Trend charts visualize feedback over time

---

## Notes

1. **snake_case JSON Convention**: All JSON property names use snake_case (`feedback_request_id`, `created_at`) per CPR project standards. C# DTOs use [JsonPropertyName] attributes to map PascalCase properties.

2. **Backend Status**:

   - ✅ POST /api/feedback - **IMPLEMENTED** (FeedbackController.cs)
   - ✅ GET /api/me/feedback - **IMPLEMENTED** (MeFeedbackController.cs)
   - ⚠️ Query parameter support (page, page_size, filters, search, sort) - **TO BE VERIFIED** (Task T000)
   - ⚠️ GET /api/me/feedback/analytics - **TO BE IMPLEMENTED** (estimated 8-12 hours)
   - ⚠️ GET /api/employees/{id}/goals - **TO BE VERIFIED** (may exist in F001, otherwise 4-6 hours)

3. **Frontend Implementation**: All frontend code (React components, TypeScript types, API services) is NEW and part of this feature implementation.

4. **Error Handling**: Frontend should handle all HTTP status codes gracefully:

   - 401: Redirect to login
   - 403: Show "Access Denied" message
   - 404: Show "Not Found" message
   - 409: Show specific duplicate feedback error
   - 400: Display validation errors inline on form fields
   - 500: Show generic error message with retry option

5. **Performance Considerations**:

   - GET /api/me/feedback should implement pagination (default page_size=20, max=100)
   - Analytics endpoint should cache results (5-minute staleTime in React Query)
   - Search/filter should debounce user input (500ms delay)
   - Virtual scrolling recommended for lists >50 items

6. **Future Enhancements** (Out of Scope for Initial Implementation):

   - Feedback editing (PATCH /api/feedback/{id})
   - Feedback deletion (DELETE /api/feedback/{id})
   - Bulk feedback operations
   - Feedback templates
   - AI-powered feedback suggestions
   - Export feedback to PDF/CSV
   - Advanced analytics (sentiment analysis, word clouds)
   - Affected endpoints: [List]
   - Validation: [How enforced]

7. **Unique Names**: Resource names must be unique per user

   - Affected endpoints: POST, PUT
   - Validation: Check database before insert/update
   - Error: 409 Conflict

8. **Soft Delete**: Resources are soft-deleted (marked inactive)
   - Affected endpoints: DELETE
   - Implementation: Set `deleted_at` timestamp, keep data

---

## Rate Limiting

All endpoints are subject to rate limiting:

- **Authenticated users**: 100 requests per minute
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

**List My Feedback Endpoint** (GET /api/me/feedback):

- Cache key: `feedback:list:user:{userId}:page:{page}:filters:{hash}`
- TTL: 5 minutes (staleTime in React Query)
- Invalidation: On new feedback submission (POST /api/feedback)
- Cache Size: Last 100 items in IndexedDB for offline access

**Get Single Feedback Endpoint** (GET /api/me/feedback/{id}):

- Cache key: `feedback:{id}`
- TTL: 10 minutes
- Invalidation: When feedback is updated (rarely, feedback is immutable in MVP)

**Analytics Endpoint** (GET /api/me/feedback/analytics):

- Cache key: `feedback:analytics:user:{userId}:period:{start}-{end}`
- TTL: 5 minutes (analytics don't change frequently)
- Invalidation: On new feedback submission

### Sync Mechanism

When offline:

1. Queue mutations (POST, PUT, DELETE) in IndexedDB
2. Show optimistic UI updates
3. On reconnect, replay queued mutations
4. Handle conflicts with "last write wins" or prompt user

---

## Testing Requirements

### Unit Tests (Backend)

- [ ] Test request validation (invalid inputs)
- [ ] Test authorization rules
- [ ] Test business logic
- [ ] Test error responses

### Integration Tests (Backend)

- [ ] Test full request/response cycle
- [ ] Test database constraints
- [ ] Test pagination
- [ ] Test filtering and sorting

### Frontend Tests

- [ ] Test API service methods
- [ ] Test error handling
- [ ] Test MSW mock handlers
- [ ] Test offline queue

---

## OpenAPI/Swagger Specification

```yaml
openapi: 3.0.0
info:
  title: CPR API - Feedback Submission & Collection
  version: 1.0.0
  description: API endpoints for submitting and viewing feedback
servers:
  - url: https://api.cpr.example.com
    description: Production
  - url: https://api-dev.cpr.example.com
    description: Development
paths:
  /api/feedback:
    post:
      summary: Submit feedback response
      operationId: submitFeedback
      tags: [Feedback]
      security:
        - bearerAuth: []
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: "#/components/schemas/SubmitFeedbackRequest"
      responses:
        "201":
          description: Feedback submitted successfully
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/Feedback"
        "400":
          $ref: "#/components/responses/BadRequest"
        "401":
          $ref: "#/components/responses/Unauthorized"
        "404":
          $ref: "#/components/responses/NotFound"
        "409":
          $ref: "#/components/responses/Conflict"

  /api/me/feedback:
    get:
      summary: List my received feedback
      operationId: listMyFeedback
      tags: [My Feedback]
      security:
        - bearerAuth: []
      parameters:
        - name: page
          in: query
          schema:
            type: integer
            default: 1
        - name: page_size
          in: query
          schema:
            type: integer
            default: 20
            maximum: 100
        # ... additional parameters
      responses:
        "200":
          description: Paginated list of feedback
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/PaginatedMyFeedbackResponse"

  /api/me/feedback/{id}:
    get:
      summary: Get single feedback detail
      operationId: getMyFeedback
      tags: [My Feedback]
      security:
        - bearerAuth: []
      parameters:
        - name: id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        "200":
          description: Feedback details
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/MyFeedback"
        "404":
          $ref: "#/components/responses/NotFound"

  /api/me/feedback/analytics:
    get:
      summary: Get my feedback analytics
      operationId: getMyFeedbackAnalytics
      tags: [My Feedback]
      security:
        - bearerAuth: []
      parameters:
        - name: date_from
          in: query
          schema:
            type: string
            format: date-time
        - name: date_to
          in: query
          schema:
            type: string
            format: date-time
      responses:
        "200":
          description: Feedback analytics
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/FeedbackAnalytics"

  /api/employees/{employee_id}/goals:
    get:
      summary: Get employee goals
      operationId: getEmployeeGoals
      tags: [Goals]
      security:
        - bearerAuth: []
      parameters:
        - name: employee_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        "200":
          description: Employee goals
          content:
            application/json:
              schema:
                $ref: "#/components/schemas/EmployeeGoalsResponse"

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT

  schemas:
    SubmitFeedbackRequest:
      type: object
      required: [to_employee_id, content, rating]
      properties:
        feedback_request_id:
          type: string
          format: uuid
        goal_id:
          type: string
          format: uuid
        project_id:
          type: string
          format: uuid
        to_employee_id:
          type: string
          format: uuid
        content:
          type: string
          minLength: 10
          maxLength: 2000
        rating:
          type: integer
          minimum: 1
          maximum: 5

    # ... additional schemas

  responses:
    BadRequest:
      description: Validation error
      content:
        application/json:
          schema:
            $ref: "#/components/schemas/ErrorResponse"
    Unauthorized:
      description: Missing or invalid authentication
    NotFound:
      description: Resource not found
    Conflict:
      description: Resource conflict
```

---

## Change Log

| Date       | Author                            | Changes                                                                                      |
| ---------- | --------------------------------- | -------------------------------------------------------------------------------------------- |
| 2025-11-24 | GitHub Copilot (Phase 3 Planning) | Initial endpoint definitions for Feature 0005                                                |
| 2025-11-24 | GitHub Copilot (Phase 3 Planning) | Added full API specifications with C# DTOs and TypeScript interfaces                         |
| 2025-11-24 | GitHub Copilot (Phase 3 Planning) | Documented backend implementation status (existing vs. to-be-verified vs. to-be-implemented) |
