# API Endpoints: [Feature Name]

> **Specification**: [spec-###]-[short-description]  
> **Created**: YYYY-MM-DD  
> **API Version**: v1

## Table of Contents
- [Overview](#overview)
- [Authentication](#authentication)
- [Endpoints](#endpoints)
- [Data Models](#data-models)
- [Error Responses](#error-responses)

## Overview

[Brief description of the API endpoints in this specification]

**Base URL**: `/api/v1`  
**Content-Type**: `application/json`  
**Date Format**: ISO 8601 UTC (YYYY-MM-DDTHH:mm:ss.sssZ)  
**Naming Convention**: snake_case for all JSON fields

## Authentication

All endpoints require authentication unless explicitly marked as public.

**Method**: Bearer Token (JWT)  
**Header**: `Authorization: Bearer <token>`

### Required Roles
- **[Role Name]**: [Permission description]
- **[Role Name]**: [Permission description]

## Endpoints

### 1. Create [Resource]

Creates a new [resource] with the provided data.

---

**Endpoint**: `POST /api/v1/[resource-collection]`

**Authorization**: Required  
**Roles**: `[Role1]`, `[Role2]`

#### Request Body

```json
{
  "field_name": "string",
  "another_field": 123,
  "nested_object": {
    "nested_field": "value"
  },
  "array_field": ["item1", "item2"]
}
```

#### Request Schema

| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| `field_name` | string | Yes | 1-100 chars | [Description] |
| `another_field` | integer | Yes | > 0 | [Description] |
| `nested_object.nested_field` | string | No | - | [Description] |
| `array_field` | string[] | No | Max 10 items | [Description] |

#### Success Response

**Status**: `201 Created`  
**Location Header**: `/api/v1/[resource-collection]/{id}`

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "field_name": "string",
  "another_field": 123,
  "nested_object": {
    "nested_field": "value"
  },
  "array_field": ["item1", "item2"],
  "created_at": "2025-11-05T14:30:00.000Z",
  "updated_at": "2025-11-05T14:30:00.000Z"
}
```

#### Error Responses

**400 Bad Request** - Invalid request format
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Bad Request",
  "status": 400,
  "detail": "The request body is malformed",
  "instance": "/api/v1/[resource-collection]",
  "traceId": "00-trace-id-00"
}
```

**422 Unprocessable Entity** - Validation failed
```json
{
  "type": "https://tools.ietf.org/html/rfc4918#section-11.2",
  "title": "Validation Failed",
  "status": 422,
  "detail": "One or more validation errors occurred",
  "instance": "/api/v1/[resource-collection]",
  "traceId": "00-trace-id-00",
  "errors": {
    "field_name": ["Field name is required"],
    "another_field": ["Another field must be greater than 0"]
  }
}
```

**403 Forbidden** - Insufficient permissions
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.3",
  "title": "Forbidden",
  "status": 403,
  "detail": "User does not have permission to create this resource",
  "instance": "/api/v1/[resource-collection]",
  "traceId": "00-trace-id-00"
}
```

#### Example Request

```bash
curl -X POST https://api.example.com/api/v1/[resource-collection] \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "field_name": "Example",
    "another_field": 42
  }'
```

---

### 2. Get [Resource] by ID

Retrieves a single [resource] by its unique identifier.

---

**Endpoint**: `GET /api/v1/[resource-collection]/{id}`

**Authorization**: Required  
**Roles**: `[Role1]`, `[Role2]`

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier of the resource |

#### Query Parameters

None

#### Success Response

**Status**: `200 OK`

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "field_name": "string",
  "another_field": 123,
  "nested_object": {
    "nested_field": "value"
  },
  "array_field": ["item1", "item2"],
  "created_at": "2025-11-05T14:30:00.000Z",
  "updated_at": "2025-11-05T14:30:00.000Z"
}
```

#### Error Responses

**404 Not Found** - Resource does not exist
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Not Found",
  "status": 404,
  "detail": "Resource with id '3fa85f64-5717-4562-b3fc-2c963f66afa6' not found",
  "instance": "/api/v1/[resource-collection]/3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "traceId": "00-trace-id-00"
}
```

#### Example Request

```bash
curl -X GET https://api.example.com/api/v1/[resource-collection]/3fa85f64-5717-4562-b3fc-2c963f66afa6 \
  -H "Authorization: Bearer <token>"
```

---

### 3. List [Resources]

Retrieves a paginated list of [resources] with optional filtering and sorting.

---

**Endpoint**: `GET /api/v1/[resource-collection]`

**Authorization**: Required  
**Roles**: `[Role1]`, `[Role2]`

#### Query Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `page` | integer | No | 1 | Page number (1-indexed) |
| `page_size` | integer | No | 20 | Items per page (1-100) |
| `sort_by` | string | No | created_at | Field to sort by |
| `sort_order` | string | No | desc | Sort order: `asc` or `desc` |
| `filter_field` | string | No | - | Filter by field value |
| `search` | string | No | - | Search query |

**Allowed sort_by values**: `created_at`, `updated_at`, `field_name`

#### Success Response

**Status**: `200 OK`

```json
{
  "items": [
    {
      "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
      "field_name": "string",
      "another_field": 123,
      "created_at": "2025-11-05T14:30:00.000Z",
      "updated_at": "2025-11-05T14:30:00.000Z"
    }
  ],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total_items": 45,
    "total_pages": 3,
    "has_previous": false,
    "has_next": true
  }
}
```

#### Error Responses

**400 Bad Request** - Invalid query parameters
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Bad Request",
  "status": 400,
  "detail": "Invalid query parameter",
  "instance": "/api/v1/[resource-collection]",
  "traceId": "00-trace-id-00",
  "errors": {
    "page_size": ["Page size must be between 1 and 100"]
  }
}
```

#### Example Request

```bash
curl -X GET "https://api.example.com/api/v1/[resource-collection]?page=1&page_size=20&sort_by=created_at&sort_order=desc" \
  -H "Authorization: Bearer <token>"
```

---

### 4. Update [Resource]

Updates an existing [resource] with the provided data.

---

**Endpoint**: `PUT /api/v1/[resource-collection]/{id}`

**Authorization**: Required  
**Roles**: `[Role1]`, `[Role2]`

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier of the resource |

#### Request Body

```json
{
  "field_name": "string",
  "another_field": 123,
  "nested_object": {
    "nested_field": "value"
  },
  "array_field": ["item1", "item2"]
}
```

**Note**: All fields are required (full replacement). For partial updates, use PATCH.

#### Success Response

**Status**: `200 OK`

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "field_name": "string",
  "another_field": 123,
  "nested_object": {
    "nested_field": "value"
  },
  "array_field": ["item1", "item2"],
  "created_at": "2025-11-05T14:30:00.000Z",
  "updated_at": "2025-11-05T14:35:00.000Z"
}
```

#### Error Responses

Same as Create endpoint, plus:

**404 Not Found** - Resource does not exist

**409 Conflict** - Concurrent modification detected
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.8",
  "title": "Conflict",
  "status": 409,
  "detail": "The resource has been modified by another user",
  "instance": "/api/v1/[resource-collection]/3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "traceId": "00-trace-id-00"
}
```

#### Example Request

```bash
curl -X PUT https://api.example.com/api/v1/[resource-collection]/3fa85f64-5717-4562-b3fc-2c963f66afa6 \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "field_name": "Updated",
    "another_field": 99
  }'
```

---

### 5. Partial Update [Resource]

Partially updates an existing [resource] with only the provided fields.

---

**Endpoint**: `PATCH /api/v1/[resource-collection]/{id}`

**Authorization**: Required  
**Roles**: `[Role1]`, `[Role2]`

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier of the resource |

#### Request Body

```json
{
  "field_name": "string"
}
```

**Note**: Only included fields will be updated. Omitted fields remain unchanged.

#### Success Response

**Status**: `200 OK`

```json
{
  "id": "3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "field_name": "Updated value",
  "another_field": 123,
  "created_at": "2025-11-05T14:30:00.000Z",
  "updated_at": "2025-11-05T14:40:00.000Z"
}
```

#### Error Responses

Same as Update endpoint.

---

### 6. Delete [Resource]

Deletes an existing [resource].

---

**Endpoint**: `DELETE /api/v1/[resource-collection]/{id}`

**Authorization**: Required  
**Roles**: `[Role1]`, `[Role2]`

#### Path Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | Yes | Unique identifier of the resource |

#### Success Response

**Status**: `204 No Content`

No response body.

#### Error Responses

**404 Not Found** - Resource does not exist

**409 Conflict** - Resource cannot be deleted due to dependencies
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.8",
  "title": "Conflict",
  "status": 409,
  "detail": "Cannot delete resource because it has dependent resources",
  "instance": "/api/v1/[resource-collection]/3fa85f64-5717-4562-b3fc-2c963f66afa6",
  "traceId": "00-trace-id-00"
}
```

#### Example Request

```bash
curl -X DELETE https://api.example.com/api/v1/[resource-collection]/3fa85f64-5717-4562-b3fc-2c963f66afa6 \
  -H "Authorization: Bearer <token>"
```

---

## Data Models

### [ResourceName]

Complete representation of a [resource].

```json
{
  "id": "uuid",
  "field_name": "string",
  "another_field": 123,
  "nested_object": {
    "nested_field": "string"
  },
  "array_field": ["string"],
  "created_at": "2025-11-05T14:30:00.000Z",
  "updated_at": "2025-11-05T14:30:00.000Z"
}
```

| Field | Type | Nullable | Description |
|-------|------|----------|-------------|
| `id` | UUID | No | Unique identifier |
| `field_name` | string | No | [Description] |
| `another_field` | integer | No | [Description] |
| `nested_object` | object | Yes | [Description] |
| `nested_object.nested_field` | string | Yes | [Description] |
| `array_field` | string[] | Yes | [Description] |
| `created_at` | datetime | No | Creation timestamp (ISO 8601 UTC) |
| `updated_at` | datetime | No | Last update timestamp (ISO 8601 UTC) |

### PaginatedResponse<T>

Standard paginated response wrapper.

```json
{
  "items": [T],
  "pagination": {
    "page": 1,
    "page_size": 20,
    "total_items": 100,
    "total_pages": 5,
    "has_previous": false,
    "has_next": true
  }
}
```

## Error Responses

All errors follow RFC 7807 Problem Details format.

### Standard Error Structure

```json
{
  "type": "string (URI)",
  "title": "string",
  "status": 400,
  "detail": "string",
  "instance": "string (URI)",
  "traceId": "string",
  "errors": {
    "field_name": ["error message"]
  }
}
```

### HTTP Status Codes

| Code | Meaning | Usage |
|------|---------|-------|
| 200 | OK | Successful GET, PUT, PATCH |
| 201 | Created | Successful POST |
| 204 | No Content | Successful DELETE |
| 400 | Bad Request | Malformed request, invalid syntax |
| 401 | Unauthorized | Missing or invalid authentication |
| 403 | Forbidden | Insufficient permissions |
| 404 | Not Found | Resource does not exist |
| 409 | Conflict | Concurrent modification, constraint violation |
| 422 | Unprocessable Entity | Validation failed |
| 500 | Internal Server Error | Unexpected server error |

## Rate Limiting

[If applicable, describe rate limiting]

- **Limit**: X requests per minute
- **Headers**: 
  - `X-RateLimit-Limit`: Total allowed requests
  - `X-RateLimit-Remaining`: Remaining requests
  - `X-RateLimit-Reset`: UTC timestamp when limit resets

## Versioning

**Current Version**: v1

API version is specified in the URL path: `/api/v1/[endpoint]`

Breaking changes will result in a new version (v2, v3, etc.).

## Notes

- All timestamps are in ISO 8601 UTC format
- All IDs use UUID v4 format
- All JSON fields use snake_case naming
- Dates without time are represented as ISO 8601 date strings (YYYY-MM-DD)
- Boolean values are lowercase: `true`, `false`
- Null values are represented as `null`, not omitted (unless specified otherwise)

---

**Last Updated**: YYYY-MM-DD
