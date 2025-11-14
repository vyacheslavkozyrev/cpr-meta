# API Endpoints - Feedback Request Management

> **Feature**: 0004 - feedback-request-management  
> **Status**: Planning  
> **Created**: 2025-11-13  
> **Last Updated**: 2025-11-13

---

## Overview

This document defines all API endpoints for the Feedback Request Management feature, including request/response contracts, validation rules, and authorization requirements.

**Base URL**: `/api/v1`

**API Version**: v1

**Authentication**: Required (JWT Bearer token)

---

## Endpoints Summary

| Method | Endpoint | Description | Auth | Role/Authorization |
|--------|----------|-------------|------|-------------------|
| POST | `/api/feedback/request` | Create feedback request with 1-20 recipients | ✅ | Any authenticated employee |
| GET | `/api/me/feedback/request` | List sent requests (requestor view) | ✅ | Authenticated user (own requests only) |
| GET | `/api/me/feedback/request/todo` | List todo requests (recipient view) | ✅ | Authenticated user (requests addressed to them) |
| PATCH | `/api/feedback/request/{id}` | Update due date or cancel request | ✅ | Requestor only |
| POST | `/api/feedback/request/{id}/recipient/{recipientId}/remind` | Send reminder to specific recipient | ✅ | Requestor only (48h cooldown) |
| DELETE | `/api/feedback/request/{id}/recipient/{recipientId}` | Partial cancellation (remove recipient) | ✅ | Requestor only |
| GET | `/api/team/feedback/request/sent` | Manager view: team's sent requests | ✅ | Managers only (read-only) |
| GET | `/api/team/feedback/request/received` | Manager view: team's received requests | ✅ | Managers only (read-only) |

---

## Common Response Codes

All endpoints use standard HTTP status codes:

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Successful GET, PUT, DELETE |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE (alternative) |
| 400 | Bad Request | Validation error, malformed request |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Authenticated but insufficient permissions |
| 404 | Not Found | Resource doesn't exist |
| 409 | Conflict | Resource already exists, business rule violation |
| 422 | Unprocessable Entity | Semantic validation error |
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

### 1. Create Feedback Request

**Endpoint**: `POST /api/feedback/request`

**Description**: Create a new feedback request from authenticated user to 1-20 employee recipients with optional project/goal context, message, and due date

**Authorization**: 
- Requires JWT authentication
- User can only create requests as themselves (requestor_id from JWT claims, not client input)
- Cannot request feedback from self
- Maximum 50 requests per user per 24 hours (rate limit)

**Query Parameters**:
| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | integer | No | 1 | Page number (1-based) |
| `page_size` | integer | No | 20 | Items per page (max: 100) |
| `sort_by` | string | No | `created_at` | Sort field |
| `sort_order` | string | No | `desc` | Sort order (`asc` or `desc`) |
| `status` | string | No | - | Filter by status |
| `search` | string | No | - | Search in name/description |

**Request Example**:
```http
GET /api/v1/[resource]?page=1&page_size=20&sort_by=created_at&sort_order=desc HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
{
  "data": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Example Resource",
      "description": "Resource description",
      "status": "active",
      "created_at": "2025-11-07T10:30:00Z",
      "updated_at": "2025-11-07T10:30:00Z",
      "user_id": "123e4567-e89b-12d3-a456-426614174000"
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

**C# DTO**:
```csharp
// Request (Query Parameters)
public class List[Resource]QueryDto
{
    public int Page { get; set; } = 1;
    
    [Range(1, 100)]
    public int PageSize { get; set; } = 20;
    
    public string? SortBy { get; set; }
    public string? SortOrder { get; set; }
    public string? Status { get; set; }
    public string? Search { get; set; }
}

// Response
public class Paginated[Resource]ResponseDto
{
    [JsonPropertyName("data")]
    public List<[Resource]Dto> Data { get; set; } = new();
    
    [JsonPropertyName("pagination")]
    public PaginationDto Pagination { get; set; } = new();
}

public class [Resource]Dto
{
    [JsonPropertyName("id")]
    public Guid Id { get; set; }
    
    [JsonPropertyName("name")]
    public string Name { get; set; } = string.Empty;
    
    [JsonPropertyName("description")]
    public string? Description { get; set; }
    
    [JsonPropertyName("status")]
    public string Status { get; set; } = string.Empty;
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("updated_at")]
    public DateTime UpdatedAt { get; set; }
    
    [JsonPropertyName("user_id")]
    public Guid UserId { get; set; }
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

**TypeScript Interface**:
```typescript
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
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication token
- `400 Bad Request` - Invalid query parameters (e.g., page_size > 100)

---

### 2. Get Single [Resource]

**Endpoint**: `GET /api/v1/[resource]/{id}`

**Description**: Retrieve a specific [resource] by ID

**Authorization**: 
- Requires authentication
- User must own the resource OR have Admin role

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Resource identifier |

**Request Example**:
```http
GET /api/v1/[resource]/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Example Resource",
  "description": "Detailed resource description",
  "status": "active",
  "created_at": "2025-11-07T10:30:00Z",
  "updated_at": "2025-11-07T10:30:00Z",
  "user_id": "123e4567-e89b-12d3-a456-426614174000"
}
```

**C# DTO**: Same as `[Resource]Dto` above

**TypeScript Interface**: Same as `ResourceDto` above

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - User doesn't own resource and isn't Admin
- `404 Not Found` - Resource doesn't exist

---

### 3. Create [Resource]

**Endpoint**: `POST /api/v1/[resource]`

**Description**: Create a new [resource]

**Authorization**: 
- Requires authentication
- Any authenticated user can create

**Request Body**:
```json
{
  "name": "New Resource",
  "description": "Resource description",
  "status": "active"
}
```

**Request Example**:
```http
POST /api/v1/[resource] HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "New Resource",
  "description": "Resource description",
  "status": "active"
}
```

**Response** (201 Created):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "New Resource",
  "description": "Resource description",
  "status": "active",
  "created_at": "2025-11-07T10:30:00Z",
  "updated_at": "2025-11-07T10:30:00Z",
  "user_id": "123e4567-e89b-12d3-a456-426614174000"
}
```

**Response Headers**:
```
Location: /api/v1/[resource]/550e8400-e29b-41d4-a716-446655440000
```

**C# DTO**:
```csharp
public class Create[Resource]Dto
{
    [JsonPropertyName("name")]
    [Required]
    [StringLength(100, MinimumLength = 1)]
    public string Name { get; set; } = string.Empty;
    
    [JsonPropertyName("description")]
    [StringLength(500)]
    public string? Description { get; set; }
    
    [JsonPropertyName("status")]
    [Required]
    [RegularExpression("^(active|inactive|pending)$")]
    public string Status { get; set; } = "active";
}
```

**TypeScript Interface**:
```typescript
export interface CreateResourceDto {
  name: string; // 1-100 characters
  description?: string | null; // max 500 characters
  status: 'active' | 'inactive' | 'pending';
}
```

**Validation Rules**:
- `name`: Required, 1-100 characters
- `description`: Optional, max 500 characters
- `status`: Required, must be one of: `active`, `inactive`, `pending`

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `400 Bad Request` - Validation error
- `409 Conflict` - Resource with same name already exists

**Validation Error Example** (400):
```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more validation errors occurred",
    "details": [
      {
        "field": "name",
        "message": "Name is required and must be 1-100 characters"
      },
      {
        "field": "status",
        "message": "Status must be one of: active, inactive, pending"
      }
    ]
  }
}
```

---

### 4. Update [Resource]

**Endpoint**: `PUT /api/v1/[resource]/{id}`

**Description**: Update an existing [resource]

**Authorization**: 
- Requires authentication
- User must own the resource OR have Admin role

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Resource identifier |

**Request Body**:
```json
{
  "name": "Updated Resource Name",
  "description": "Updated description",
  "status": "inactive"
}
```

**Request Example**:
```http
PUT /api/v1/[resource]/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
Content-Type: application/json

{
  "name": "Updated Resource Name",
  "description": "Updated description",
  "status": "inactive"
}
```

**Response** (200 OK):
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "name": "Updated Resource Name",
  "description": "Updated description",
  "status": "inactive",
  "created_at": "2025-11-07T10:30:00Z",
  "updated_at": "2025-11-07T12:45:00Z",
  "user_id": "123e4567-e89b-12d3-a456-426614174000"
}
```

**C# DTO**:
```csharp
public class Update[Resource]Dto
{
    [JsonPropertyName("name")]
    [Required]
    [StringLength(100, MinimumLength = 1)]
    public string Name { get; set; } = string.Empty;
    
    [JsonPropertyName("description")]
    [StringLength(500)]
    public string? Description { get; set; }
    
    [JsonPropertyName("status")]
    [Required]
    [RegularExpression("^(active|inactive|pending)$")]
    public string Status { get; set; } = string.Empty;
}
```

**TypeScript Interface**:
```typescript
export interface UpdateResourceDto {
  name: string; // 1-100 characters
  description?: string | null; // max 500 characters
  status: 'active' | 'inactive' | 'pending';
}
```

**Validation Rules**: Same as Create

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - User doesn't own resource and isn't Admin
- `404 Not Found` - Resource doesn't exist
- `400 Bad Request` - Validation error
- `409 Conflict` - Name conflict with another resource

---

### 5. Delete [Resource]

**Endpoint**: `DELETE /api/v1/[resource]/{id}`

**Description**: Delete a [resource]

**Authorization**: 
- Requires authentication
- User must own the resource OR have Admin role

**Path Parameters**:
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Resource identifier |

**Request Example**:
```http
DELETE /api/v1/[resource]/550e8400-e29b-41d4-a716-446655440000 HTTP/1.1
Host: api.cpr.example.com
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Response** (200 OK):
```json
{
  "message": "Resource deleted successfully",
  "id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Alternative Response** (204 No Content):
```
(empty body)
```

**Error Responses**:
- `401 Unauthorized` - Missing or invalid authentication
- `403 Forbidden` - User doesn't own resource and isn't Admin
- `404 Not Found` - Resource doesn't exist
- `409 Conflict` - Resource cannot be deleted (has dependencies)

---

## Business Rules

Document specific business rules that apply to these endpoints:

1. **[Rule Name]**: [Description]
   - Affected endpoints: [List]
   - Validation: [How enforced]

2. **Unique Names**: Resource names must be unique per user
   - Affected endpoints: POST, PUT
   - Validation: Check database before insert/update
   - Error: 409 Conflict

3. **Soft Delete**: Resources are soft-deleted (marked inactive)
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

**List Endpoint**:
- Cache key: `[resource]:list:user:{userId}:page:{page}:filters:{hash}`
- TTL: 5 minutes
- Invalidation: On create/update/delete

**Get Endpoint**:
- Cache key: `[resource]:{id}`
- TTL: 10 minutes
- Invalidation: On update/delete

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
  title: CPR API - Feedback Request Management
  version: 1.0.0
paths:
  /api/v1/[resource]:
    get:
      summary: List [resources]
      # ... (full OpenAPI spec)
```

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| 2025-11-13 | [Name] | Initial endpoint definitions |
