# CPR Project Constitution

> **Version**: 1.0.0  
> **Last Updated**: November 5, 2025  
> **Status**: Active  
> **Scope**: All CPR repositories (cpr-meta, cpr-api, cpr-ui)

This constitution defines the foundational principles, standards, and practices that govern the CPR (Career Progress Registry) project. It serves as the single source of truth for all development decisions, ensuring consistency, quality, and alignment across all repositories.

---

## Table of Contents

- [Core Principles](#core-principles)
  - [Principle 1: Specification-First Development](#principle-1-specification-first-development)
  - [Principle 2: API Contract Consistency](#principle-2-api-contract-consistency)
  - [Principle 3: API Standards & Security](#principle-3-api-standards--security)
  - [Principle 4: Type Safety Everywhere](#principle-4-type-safety-everywhere)
  - [Principle 5: Offline Mode](#principle-5-offline-mode)
  - [Principle 6: Internationalization](#principle-6-internationalization)
  - [Principle 7: Comprehensive Testing](#principle-7-comprehensive-testing)
  - [Principle 8: Performance-First React Development](#principle-8-performance-first-react-development)
  - [Principle 9: Strict Naming Conventions](#principle-9-strict-naming-conventions)
  - [Principle 10: Security & Data Privacy](#principle-10-security--data-privacy)
  - [Principle 11: Database Design Standards](#principle-11-database-design-standards)
- [Principle Priority and Conflict Resolution](#principle-priority-and-conflict-resolution)
- [Living Document](#living-document)
- [Quick Reference](#quick-reference)

---

## Core Principles

These are the foundational, non-negotiable principles that guide all development decisions in the CPR project. All team members, processes, and tools must honor these principles.

---

## Principle 1: Specification-First Development

### Statement
**Every feature and bug fix begins with a specification. No implementation without documentation.**

### Definition
All code changes that affect API contracts, UI behavior, or system functionality must be preceded by a specification document in the `cpr-meta` repository. Specifications serve as the single source of truth and ensure alignment between teams before implementation begins.

### Scope

**Requires Full Specification**:
- ✅ New features (API endpoints, UI components, business logic)
- ✅ Changes to existing API contracts (DTOs, request/response shapes)
- ✅ Changes to business rules or validation logic
- ✅ Bug fixes that affect API contracts or behavior
- ✅ Database schema changes

**Requires Lightweight Bug Specification** (in `cpr-meta/bugfixes/`):
- ✅ Bug fixes that modify expected behavior
- ✅ Fixes that change error messages or codes
- ✅ Performance improvements that alter response characteristics

**May Skip Specification** (use judgment):
- ⚠️ Typo fixes in documentation
- ⚠️ Code refactoring with no behavior change
- ⚠️ Dependency updates (unless breaking changes)
- ⚠️ Internal implementation optimizations

### Specification Locations

```
cpr-meta/
├── specs/
│   ├── [spec-001]-user-authentication/
│   │   ├── description.md           # Feature description & acceptance criteria
│   │   ├── implementation-plan.md   # Implementation phases and approach
│   │   ├── tasks.md                 # Task breakdown and checklist
│   │   ├── endpoints.md             # API endpoints (URLs, JSON request/response, errors)
│   │   └── progress.md              # Current implementation status
│   ├── [spec-002]-goal-management/
│   │   ├── description.md
│   │   ├── implementation-plan.md
│   │   ├── tasks.md
│   │   ├── endpoints.md
│   │   └── progress.md
│   └── ...
└── bugfixes/
    ├── [bug-001]-login-redirect-issue/
    │   ├── description.md           # Bug description, root cause, impact
    │   ├── endpoints.md             # Affected endpoints (if applicable)
    │   └── progress.md              # Fix status
    └── ...
```

**Specification Structure**:

Each feature specification is a self-contained folder with:

1. **`description.md`** (REQUIRED)
   - Feature overview and purpose
   - User stories
   - Acceptance criteria
   - Business rules
   - Non-functional requirements

2. **`implementation-plan.md`** (REQUIRED)
   - Technical approach
   - Implementation phases (Phase 1, Phase 2, etc.)
   - Dependencies and prerequisites
   - Risk assessment
   - Rollout strategy

3. **`tasks.md`** (REQUIRED)
   - Checklist of implementation tasks
   - Task assignments (if applicable)
   - Estimated effort
   - Task dependencies

4. **`endpoints.md`** (REQUIRED for API features)
   - Endpoint URLs and HTTP methods
   - Request body schemas (JSON format)
   - Response body schemas (JSON format)
   - Error responses with codes and messages (JSON format)
   - Query parameters and headers

5. **`progress.md`** (REQUIRED)
   - Current status (Not Started, In Progress, Completed)
   - Completion percentage
   - Completed tasks
   - Blockers and issues
   - Change log

6. **`analysis-report.md`** (REQUIRED before development)
   - Specification quality analysis
   - Gaps identification
   - Conflicts with existing features
   - Duplications detection
   - Overall quality rating (0-100)

**Naming Convention**:
- Spec number: `[spec-###]` - sequential, zero-padded (001, 002, etc.)
- Short description: kebab-case, concise (e.g., `user-authentication`, `goal-management`)
- Full folder name: `[spec-###]-short-description`

### Workflow

```
1. Create Specification
   │ Create all required files in cpr-meta/specs/[spec-###]-feature-name/
   │ - description.md (feature, acceptance criteria)
   │ - implementation-plan.md (phases, approach)
   │ - tasks.md (task breakdown)
   │ - endpoints.md (API contracts, if applicable)
   │ - progress.md (initial status)
   ↓
2. Analyze Specification (AUTOMATED + HUMAN REVIEW)
   │ 
   │ A. Run Automated Analysis
   │    Use AI with specification-analysis.md prompt:
   │    - Provide all spec files to AI
   │    - AI generates analysis-report.md using template
   │    - AI identifies: Gaps, Conflicts, Duplications, Quality Issues
   │    - AI assigns severity: Critical (0 pts), Major (-20 pts), Minor (-5 pts)
   │    - AI calculates overall rating: 100 - (sum of deductions)
   │    
   │    Tools:
   │    - Prompt: `prompts/specification-analysis.md`
   │    - Template: `templates/spec-analysis-report-template.md`
   │ 
   │ B. Review AI Analysis Results
   │    Human reviewer validates AI findings:
   │    - Verify identified issues are accurate
   │    - Add any missed issues
   │    - Adjust severity if needed
   │    - Update analysis-report.md with final assessment
   │
   │ C. If rating < 90/100: FIX SPECIFICATION
   │    - AI provides specific questions to guide fixes
   │    - Update description.md, endpoints.md, etc.
   │    - Re-run analysis until rating ≥ 90/100
   │    - Iterate until specification quality threshold met
   ↓
3. Review & Approve Specification
   │ Manual review by tech lead or architect
   │ Verify:
   │ - All required files present
   │ - analysis-report.md shows rating ≥ 90/100
   │ - No critical or unresolved major issues
   │ - Acceptance criteria are testable
   │ - Implementation plan is feasible
   │
   │ If approved: Mark in progress.md as "Ready for Development"
   ↓
4. Implementation
   │ Implement in cpr-api and/or cpr-ui
   │ Link specification in implementation PR
   │ Update tasks.md as tasks complete
   │ Update progress.md with completion percentage
   ↓
5. Testing
   │ Write and run tests per Principle 4 (Comprehensive Testing)
   │ - Unit tests (business logic)
   │ - Contract tests (API compliance with endpoints.md)
   │ - Integration tests (cross-component)
   │ - E2E tests (critical user flows)
   │
   │ Validate implementation matches specification
   ↓
6. Deployment
   │ Deploy to environments per deployment standards
   │ Update progress.md to "Completed"
   │ Document any deviations from spec in progress.md
```

### Specification Analysis Format

**File**: `analysis-report.md` (required in every spec folder)

**Structure**:

```markdown
# Specification Analysis: [Spec Name]

**Analyzed By**: [Name]  
**Analysis Date**: YYYY-MM-DD  
**Specification Version**: v1.0  

## Analysis Summary

- **Overall Rating**: 92/100 ✅ READY FOR DEVELOPMENT
- **Critical Issues**: 0
- **Major Issues**: 0
- **Minor Issues**: 2

---

## Gaps Analysis

### Gap 1: Missing Error Handling for Concurrent Updates [MINOR]
**Severity**: Minor (-5 points)  
**Location**: `endpoints.md` - PATCH /api/goals/{id}  
**Description**: Specification doesn't define behavior when two users update the same goal simultaneously.  
**Recommendation**: Add 409 Conflict response with optimistic concurrency control.  
**Status**: ✅ RESOLVED - Added to endpoints.md v1.1

### Gap 2: Undefined Pagination Limits
**Severity**: Minor (-5 points)  
**Location**: `endpoints.md` - GET /api/goals  
**Description**: No maximum page size specified.  
**Recommendation**: Add max page size (e.g., 100) and default (e.g., 20).  
**Status**: ⚠️ OPEN - Needs discussion

---

## Conflicts Analysis

### Conflict 1: None Detected
No conflicts with existing features or specifications.

---

## Duplications Analysis

### Duplication 1: None Detected
No significant duplication with existing functionality.

---

## Quality Issues

### Issue 1: Ambiguous Acceptance Criteria
**Severity**: N/A (No point deduction - clarified during analysis)  
**Location**: `description.md` - Acceptance Criteria #3  
**Description**: "Goals should be sortable" - unclear what sort fields are supported.  
**Recommendation**: Specify: sort by title, priority, createdAt, updatedAt.  
**Status**: ✅ RESOLVED - Clarified in description.md

---

## Rating Calculation

**Starting Score**: 100 points

**Deductions**:
- Gap 1 (Minor): -5 points
- Gap 2 (Minor): -5 points
- No conflicts: 0 points
- No duplications: 0 points
- No critical issues: 0 points

**Final Score**: 100 - 10 = **90/100**

**Status**: ✅ **READY FOR DEVELOPMENT** (≥ 90/100)

---

## Recommendations

1. Resolve Gap 2 (pagination limits) before Phase 2 implementation
2. Consider adding rate limiting specification for future iteration
3. Document sorting behavior more explicitly

---

## Sign-Off

- [ ] All critical issues resolved
- [ ] All major issues resolved or accepted as risks
- [ ] Minor issues documented and tracked
- [x] Overall rating ≥ 90/100
- [x] Specification approved for development

**Approved By**: [Tech Lead Name]  
**Approval Date**: YYYY-MM-DD
```

### Rating System

**Issue Severity Levels**:

| Severity | Point Deduction | Description | Examples |
|----------|----------------|-------------|----------|
| **Critical** | Blocks development (0 points) | Fundamental flaw, missing core requirement | Missing authentication spec, contradictory requirements |
| **Major** | -20 points | Significant gap or conflict | Undefined error handling, conflict with existing API |
| **Minor** | -5 points | Small gap or ambiguity | Missing optional field, unclear wording |

**Quality Thresholds**:
- **≥ 90/100**: ✅ Ready for Development
- **70-89/100**: ⚠️ Needs Improvement (fix major issues)
- **< 70/100**: ❌ Not Ready (significant rework required)

**No Critical Issues Allowed**: Specifications with any critical issues cannot proceed to development, regardless of score.

### Enforcement

**Specification Approval Requirements**:
- [ ] All required files present (description, implementation-plan, tasks, endpoints, progress, analysis-report)
- [ ] `analysis-report.md` exists with rating ≥ 90/100
- [ ] No unresolved critical issues
- [ ] No unresolved major issues (or explicitly accepted as risks)
- [ ] Tech lead or architect approval signature

**Pull Request Requirements**:
- PR template requires specification link
- Reviewers verify specification is approved (check `analysis-report.md` and `progress.md`)
- CI/CD validates specification compliance (contract tests)

**Consequences of Violation**:
- PR blocked until specification provided and approved
- No merge to `develop` or `main` without approved spec reference
- Exception process requires tech lead approval (see Exception Process section below)

### Why This Matters

- **Quality Gate**: Catches issues before coding starts (cheaper to fix)
- **Alignment**: Ensures frontend and backend teams build compatible features
- **Documentation**: Creates living documentation that stays current
- **Reduced Rework**: Identifies gaps and conflicts early
- **Predictability**: Clear expectations and quality bar before coding begins
- **Risk Management**: Critical issues surfaced and resolved upfront

---

## Principle 2: API Contract Consistency

### Statement
**DTOs and API contracts must remain consistent across cpr-meta specifications, cpr-api implementation, and cpr-ui consumption.**

### Definition
The shape of data exchanged between frontend and backend—including DTOs (Data Transfer Objects), API endpoints, error responses, and status codes—must be defined in `cpr-meta` and strictly honored by both `cpr-api` and `cpr-ui`. Internal domain models may differ, but the API boundary contract is immutable.

### Specification Format vs Wire Format

**IMPORTANT**: Specifications use different formats than the actual API:

| Aspect | Specification Format | Actual API Format |
|--------|---------------------|-------------------|
| **Location** | `specs/[spec-###]/endpoints.md` | HTTP requests/responses |
| **Schema Definition** | YAML or Markdown examples | N/A (schemas describe JSON) |
| **Request Body** | JSON examples in markdown | **JSON** over HTTP |
| **Response Body** | JSON examples in markdown | **JSON** over HTTP |
| **Purpose** | Human-readable documentation | Machine-to-machine communication |

**Why YAML in specs?**
- ✅ Easier to read and write
- ✅ Better for version control (cleaner diffs)
- ✅ Standard for OpenAPI/Swagger
- ✅ Can include comments

**Why JSON on the wire?**
- ✅ Native JavaScript support
- ✅ Universal API standard
- ✅ Smaller payload size
- ✅ Faster parsing

**Example**:

Specification (`endpoints.md`) uses YAML or JSON examples:
```yaml
# This is just documentation format
UserProfile:
  user_id: string (uuid)
  employee_id: string (uuid)
  email: string
```

Actual API sends/receives **JSON**:
```json
{
  "user_id": "679add6e-6c29-4e00-b6a5-b69c8e0f3445",
  "employee_id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "john.doe@example.com"
}
```

**Content-Type Headers**:
- Request: `Content-Type: application/json`
- Response: `Content-Type: application/json`

### What Must Be Consistent

#### 1. DTOs (Data Transfer Objects)
API request and response shapes defined in `endpoints.md` (documented in JSON examples):

**Specification** (`specs/[spec-###]/endpoints.md`):
```markdown
**Response (200 OK)**:
```json
{
  "user_id": "679add6e-6c29-4e00-b6a5-b69c8e0f3445",
  "employee_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_name": "john.doe",
  "display_name": "John Doe",
  "email": "john.doe@example.com",
  "position": {
    "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "title": "Senior Developer"
  }
}
```
```

**Actual API Response** (what cpr-api sends as JSON):
```http
HTTP/1.1 200 OK
Content-Type: application/json

{
  "user_id": "679add6e-6c29-4e00-b6a5-b69c8e0f3445",
  "employee_id": "550e8400-e29b-41d4-a716-446655440000",
  "user_name": "john.doe",
  "display_name": "John Doe",
  "email": "john.doe@example.com",
  "position": {
    "id": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
    "title": "Senior Developer"
  }
}
```

**Frontend Code** (what cpr-ui expects):
```typescript
type TPosition = {
  id: string;
  title: string;
}

interface IUserProfile {
  user_id: string;
  employee_id: string;
  user_name: string;
  display_name: string;
  email: string | null;
  position: TPosition;
}

// Fetch returns JSON automatically parsed
const response = await fetch('/api/users/me');
const profile: IUserProfile = await response.json();
```

**✅ Consistency Rule**: The JSON structure in the spec, the JSON returned by cpr-api, and the TypeScript interface in cpr-ui must all match exactly.

#### 2. API Endpoints
Endpoint paths, HTTP methods, query parameters, and response codes defined in `endpoints.md`:

**Format Example** (`specs/[spec-###]-feature-name/endpoints.md`):

```markdown
## POST /api/goals

Create a new goal for the authenticated user.

**Authentication**: Required (Bearer token)

**Request Body**:
```json
{
  "title": "Complete Q4 objectives",
  "description": "Finish all assigned tasks for Q4",
  "priority": 5,
  "visibility": "private"
}
```

**Request Schema**:
- `title` (string, required): Goal title (1-200 characters)
- `description` (string, optional): Detailed description (max 2000 characters)
- `priority` (integer, required): Priority level (1-10)
- `visibility` (string, required): "private" | "manager" | "public"

**Success Response (201 Created)**:
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "employeeId": "679add6e-6c29-4e00-b6a5-b69c8e0f3445",
  "title": "Complete Q4 objectives",
  "description": "Finish all assigned tasks for Q4",
  "priority": 5,
  "visibility": "private",
  "status": "not_started",
  "createdAt": "2025-11-05T10:30:00Z",
  "updatedAt": "2025-11-05T10:30:00Z"
}
```

**Error Responses**:

400 Bad Request - Invalid input:
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Missing required value",
  "status": 400,
  "detail": "Value cannot be null. (Parameter 'title')"
}
```

401 Unauthorized - Missing or invalid token:
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Authorization header is missing or invalid"
}
```
```

#### 3. Error Responses
Error format using **RFC 7807 ProblemDetails** (via Hellang.Middleware.ProblemDetails):

```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Invalid argument",
  "status": 400,
  "detail": "Specified argument was out of the range of valid values. (Parameter 'page')"
}
```

**Standard Error Mappings**:
- `ArgumentNullException` → 400 Bad Request ("Missing required value")
- `ArgumentOutOfRangeException` → 400 Bad Request ("Invalid argument")
- `UnauthorizedAccessException` → 401 Unauthorized
- `NotFoundException` → 404 Not Found
- Unhandled exceptions → 500 Internal Server Error

#### 4. RESTful API Standards

CPR API follows REST (Representational State Transfer) principles:

**Resource-Based URLs**:
```
✅ Good: /api/users/{id}
✅ Good: /api/goals/{goalId}/tasks/{taskId}
❌ Bad: /api/getUser?id={id}
❌ Bad: /api/goal_operations
```

**HTTP Methods (Verbs)**:
- **GET**: Retrieve resource(s) - MUST be idempotent and safe (no side effects)
- **POST**: Create new resource - NOT idempotent
- **PUT**: Replace entire resource - idempotent
- **PATCH**: Partially update resource - idempotent
- **DELETE**: Remove resource - idempotent

**URL Structure**:
```
/api/{version}/{resource}/{id}/{sub-resource}/{sub-id}
  │      │         │        │        │            │
  │      │         │        │        │            └─ Sub-resource ID (UUID)
  │      │         │        │        └─ Sub-resource (kebab-case)
  │      │         │        └─ Resource ID (UUID or identifier)
  │      │         └─ Resource name (plural, kebab-case)
  │      └─ Version (v1, v2, etc.)
  └─ API prefix

Examples:
✅ /api/v1/users/123e4567-e89b-41d4-a716-446655440000
✅ /api/v1/goals/550e8400-e29b-41d4-a716-446655440000/tasks
✅ /api/v1/skill-categories (kebab-case for multi-word resources)
```

**URL Parameters** (kebab-case):
```
✅ /api/v1/user-profiles/{id}
✅ /api/v1/project-assignments
✅ /api/v1/career-tracks
❌ /api/v1/user_profiles (snake_case - reserved for JSON)
❌ /api/v1/userProfiles (camelCase - reserved for TypeScript)
❌ /api/v1/UserProfiles (PascalCase - reserved for C#)
```

**Query Parameters** (snake_case):
```
✅ /api/v1/goals?page=1&per_page=20&sort_by=created_at&order=desc&unread_only=true
❌ /api/v1/goals?pageNumber=1&itemsPerPage=20
```

**HTTP Status Codes**:
- **2xx Success**:
  - **200 OK**: Successful GET, PATCH, PUT
  - **201 Created**: Successful POST (resource created), include `Location` header
  - **204 No Content**: Successful DELETE, no response body
- **4xx Client Errors**:
  - **400 Bad Request**: Validation error, malformed request
  - **401 Unauthorized**: Missing or invalid authentication
  - **403 Forbidden**: Authenticated but insufficient permissions
  - **404 Not Found**: Resource does not exist
  - **409 Conflict**: Resource conflict (duplicate, concurrent modification)
  - **422 Unprocessable Entity**: Semantically incorrect request
- **5xx Server Errors**:
  - **500 Internal Server Error**: Unexpected server error
  - **503 Service Unavailable**: Temporary outage, maintenance

**Idempotency**:
- GET, PUT, PATCH, DELETE: Multiple identical requests = same result
- POST: Multiple requests create multiple resources (NOT idempotent)
- Use idempotency keys for critical POST operations if needed

**Response Headers**:
```http
Content-Type: application/json; charset=utf-8
Location: /api/v1/goals/550e8400-... (for 201 Created)
```

#### 5. Date/Time Format

**All dates and times MUST be in UTC with ISO 8601 format**:

```json
{
  "created_at": "2025-11-05T10:30:00Z",      // ✅ UTC with Z suffix
  "updated_at": "2025-11-05T15:45:30.123Z",  // ✅ With milliseconds
  "deadline": "2025-12-31T23:59:59Z"         // ✅ End of day UTC
}

// ❌ Wrong formats:
{
  "created_at": "2025-11-05 10:30:00",           // Missing T separator and timezone
  "created_at": "2025-11-05T10:30:00+03:00",     // Local timezone (not UTC)
  "created_at": "11/05/2025",                    // US date format
  "created_at": 1730804400000                    // Unix timestamp (not ISO 8601)
}
```

**ISO 8601 Format**: `YYYY-MM-DDTHH:mm:ss.sssZ`
- `YYYY`: 4-digit year
- `MM`: 2-digit month (01-12)
- `DD`: 2-digit day (01-31)
- `T`: Date/time separator (literal character)
- `HH`: 2-digit hour (00-23)
- `mm`: 2-digit minute (00-59)
- `ss`: 2-digit second (00-59)
- `.sss`: Milliseconds (optional)
- `Z`: UTC timezone indicator (literal character, means +00:00)

**Why UTC?**
- ✅ No timezone confusion
- ✅ Consistent across all users and servers
- ✅ Easy to convert to user's local timezone in UI
- ✅ Database timestamps are already UTC

**Backend Implementation** (C#):
```csharp
public class GoalDto
{
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
}

// Serialize to UTC ISO 8601
var options = new JsonSerializerOptions
{
    PropertyNamingPolicy = null, // We use JsonPropertyName attributes
    Converters = { new JsonStringEnumConverter() }
};

// DateTime automatically serializes to ISO 8601 with Z
```

**Frontend Implementation** (TypeScript):
```typescript
interface IGoal {
  createdAt: string; // ISO 8601 UTC string
  updatedAt: string;
}

// Parse ISO 8601 to Date object
const goal: IGoal = await response.json();
const createdDate = new Date(goal.createdAt); // JavaScript Date object

// Display in user's local timezone
const localString = createdDate.toLocaleString(); // "11/5/2025, 1:30:00 PM"

// Format for display
const formatted = createdDate.toLocaleDateString('en-US', {
  year: 'numeric',
  month: 'short',
  day: 'numeric',
  hour: '2-digit',
  minute: '2-digit'
}); // "Nov 5, 2025, 01:30 PM"
```

**Database** (PostgreSQL):
```sql
-- Use TIMESTAMP (stored as UTC)
CREATE TABLE goals (
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Always insert/query in UTC
INSERT INTO goals (created_at) VALUES (NOW()); -- NOW() returns UTC
```

#### 6. JSON Naming Conventions

**All JSON field names must use snake_case**:

```json
// ✅ Correct: snake_case
{
  "user_id": "123",
  "display_name": "John Doe",
  "created_at": "2025-11-05T10:30:00Z",
  "is_active": true
}

// ❌ Wrong: camelCase (TypeScript convention, not JSON)
{
  "userId": "123",
  "displayName": "John Doe",
  "createdAt": "2025-11-05T10:30:00Z",
  "isActive": true
}

// ❌ Wrong: PascalCase (C# convention, not JSON)
{
  "UserId": "123",
  "DisplayName": "John Doe",
  "CreatedAt": "2025-11-05T10:30:00Z",
  "IsActive": true
}
```

**Why snake_case for JSON?**
- ✅ Language-agnostic standard
- ✅ Consistent with database column naming
- ✅ Common in RESTful APIs
- ✅ Avoids confusion between languages

**Mapping**:
- **C# (backend)**: PascalCase in code → snake_case in JSON (via JsonPropertyName attribute)
- **TypeScript (frontend)**: camelCase in code → snake_case in JSON (map on fetch)
- **Database**: snake_case columns → snake_case JSON (direct mapping)

**C# Implementation** (REQUIRED: Use `[JsonPropertyName]` attribute):
```csharp
using System.Text.Json.Serialization;

public class UserProfileDto
{
    [JsonPropertyName("user_id")]
    public string UserId { get; set; } = string.Empty;
    
    [JsonPropertyName("display_name")]
    public string DisplayName { get; set; } = string.Empty;
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
    
    [JsonPropertyName("is_active")]
    public bool IsActive { get; set; }
}

// ❌ Wrong: No JsonPropertyName attribute
public class UserProfileDto
{
    public string UserId { get; set; } // Would serialize as "UserId" in JSON
}
```

**Why `[JsonPropertyName]` is required**:
- Ensures snake_case in JSON regardless of serializer settings
- Makes contract explicit and visible in code
- Prevents breaking changes if global serializer settings change
- Self-documenting (shows exact JSON field name)

**TypeScript Implementation** (camelCase with mapping):
```typescript
// TypeScript interfaces use camelCase (JavaScript convention)
interface IUserProfile {
  userId: string;
  displayName: string;
  createdAt: string; // ISO 8601 UTC string from API
  isActive: boolean;
}

// API Service Layer: Map between snake_case JSON and camelCase TypeScript
export class UserApiService {
  async getUserProfile(userId: string): Promise<IUserProfile> {
    const response = await fetch(`/api/v1/users/${userId}`);
    const json = await response.json();
    return this.mapUserProfileFromApi(json);
  }
  
  private mapUserProfileFromApi(json: unknown): IUserProfile {
    // Type guard validation
    if (!this.isValidUserProfile(json)) {
      throw new Error('Invalid user profile response');
    }
    
    return {
      userId: json.user_id,
      displayName: json.display_name,
      createdAt: json.created_at,
      isActive: json.is_active
    };
  }
  
  private isValidUserProfile(json: unknown): json is Record<string, unknown> {
    return (
      typeof json === 'object' &&
      json !== null &&
      'user_id' in json &&
      'display_name' in json
    );
  }
  
  private mapUserProfileToApi(profile: Partial<IUserProfile>): Record<string, unknown> {
    const json: Record<string, unknown> = {};
    if (profile.displayName !== undefined) json.display_name = profile.displayName;
    if (profile.isActive !== undefined) json.is_active = profile.isActive;
    return json;
  }
  
  async updateUserProfile(userId: string, updates: Partial<IUserProfile>): Promise<IUserProfile> {
    const response = await fetch(`/api/v1/users/${userId}`, {
      method: 'PATCH',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(this.mapUserProfileToApi(updates))
    });
    const json = await response.json();
    return this.mapUserProfileFromApi(json);
  }
}
```

**Recommendation**: Create reusable mapper utilities or use libraries like `humps` or `snake-case-keys` for automatic conversion.

#### 7. Naming Conventions Summary

Complete naming standards across all layers:

| Layer | Convention | Examples | Notes |
|-------|-----------|----------|-------|
| **JSON Field Names** | `snake_case` | `user_id`, `created_at`, `is_active` | API contract standard |
| **URL Paths** | `kebab-case` | `/api/v1/user-profiles`, `/skill-categories` | Multi-word resources |
| **URL Parameters** | `{id}` | `/users/{userId}`, `/goals/{goalId}` | camelCase in path |
| **Query Parameters** | `snake_case` | `?page=1&per_page=20&sort_by=title` | Consistent with JSON |
| **HTTP Headers** | `Kebab-Case` | `Content-Type`, `Authorization` | HTTP standard |
| **C# Classes** | `PascalCase` | `UserProfile`, `GoalDto` | .NET convention |
| **C# Properties** | `PascalCase` | `UserId`, `CreatedAt` | .NET convention |
| **C# Fields** | `_camelCase` | `_userId`, `_repository` | Private fields |
| **C# Methods** | `PascalCase` | `GetUserById()`, `CreateGoal()` | .NET convention |
| **TypeScript Interfaces** | `PascalCase` | `UserProfile`, `ApiResponse` | TypeScript convention |
| **TypeScript Variables** | `camelCase` | `userId`, `createdAt` | JavaScript convention |
| **TypeScript Functions** | `camelCase` | `getUserById()`, `mapFromApi()` | JavaScript convention |
| **React Components** | `PascalCase` | `UserProfile`, `GoalList` | React convention |
| **Database Tables** | `snake_case` | `users`, `goal_tasks` | PostgreSQL convention |
| **Database Columns** | `snake_case` | `user_id`, `created_at` | PostgreSQL convention |
| **Files (general)** | `kebab-case` | `user-profile.ts`, `goal-service.cs` | Consistent across repos |
| **Folders** | `kebab-case` | `user-management/`, `api-services/` | Consistent across repos |

**Key Principle**: Each layer uses its own idiomatic convention. Map at boundaries (DTO serialization, API calls).

### What CAN Differ

**Internal Domain Models**: Backend and frontend may have different internal representations:

- **Backend (C#)**: `Goal` entity with PascalCase properties (`CreatedAt`, `UpdatedAt`, `IsDeleted`)
- **Frontend (TypeScript)**: `GoalViewModel` with camelCase properties (`isExpanded`, `isEditing`)
- **API Contract (JSON)**: `GoalDto` with snake_case fields (`created_at`, `updated_at`)

**Example of Full Stack Naming**:

```csharp
// Backend: C# Domain Entity (PascalCase)
public class Goal
{
    public Guid Id { get; set; }
    public string Title { get; set; }
    public DateTime CreatedAt { get; set; }
    public bool IsDeleted { get; set; }
}

// Backend: C# DTO for API (PascalCase properties, snake_case JSON)
public class GoalDto
{
    [JsonPropertyName("id")]
    public string Id { get; set; }
    
    [JsonPropertyName("title")]
    public string Title { get; set; }
    
    [JsonPropertyName("created_at")]
    public DateTime CreatedAt { get; set; }
}
```

```json
// API Contract: JSON (snake_case)
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "title": "Complete Q4 objectives",
  "created_at": "2025-11-05T10:30:00Z"
}
```

```typescript
// Frontend: TypeScript Interface (camelCase)
interface IGoal {
  id: string;
  title: string;
  createdAt: string;
}

// Frontend: TypeScript View Model (camelCase)
interface IGoalViewModel extends IGoal {
  isExpanded: boolean;
  isEditing: boolean;
}
```

```sql
-- Database: PostgreSQL (snake_case)
CREATE TABLE goals (
  id UUID PRIMARY KEY,
  title VARCHAR(200),
  created_at TIMESTAMP,
  is_deleted BOOLEAN
);
```

**Business Logic**: Implementation details can differ as long as the API contract is honored.

### Enforcement Mechanisms

#### 1. Contract Testing (Automated)
Located in `cpr-api/tests/CPR.ContractTests/`:

```csharp
[Fact]
public async Task PostGoal_ValidRequest_ReturnsCorrectSchema()
{
    // Arrange
    var client = CreateAuthenticatedClient();
    var createGoal = new { title = "Test Goal", /* ... */ };

    // Act
    var response = await client.PostAsJsonAsync("/api/goals", createGoal);

    // Assert
    Assert.Equal(HttpStatusCode.Created, response.StatusCode);
    
    var json = await response.Content.ReadAsStringAsync();
    SchemaValidator.ValidateJsonObject("goal.schema.json", json);
}
```

**Schema Validation**:
- JSON Schema files in `cpr-api/tests/CPR.ContractTests/schemas/`
- `SchemaValidator.cs` validates API responses against schemas
- Tests run on every commit

#### 2. Manual PR Review
**Reviewers check**:
- Does the API implementation match the OpenAPI spec?
- Does the UI code expect the documented response format?
- Are error codes consistent with standards?

**Review Checklist**:
- [ ] Implementation matches `endpoints.md` specification
- [ ] Request/response JSON format matches exactly
- [ ] HTTP status codes match specification
- [ ] Error responses follow RFC 7807 format
- [ ] Breaking changes documented and coordinated

#### 3. CI/CD Gates
**Deployment Blocked If**:
- Contract tests fail
- JSON schema validation fails
- Schema mismatches detected between spec and implementation

### Synchronization Strategy

**Source of Truth**: `cpr-meta/specs/[spec-###]-feature-name/endpoints.md`

**Flow**:
```
cpr-meta/specs/[spec-###]/endpoints.md
    ↓
    ├─→ cpr-api (implements contract)
    │       ↓
    │   (contract tests validate JSON schemas)
    │
    └─→ cpr-ui (consumes contract)
            ↓
        (integration tests validate)
```

**On Specification Change**:
1. Update `endpoints.md` in spec folder (e.g., `specs/[spec-023]-feature/endpoints.md`)
2. Update `progress.md` to track the change
3. Review and approve specification updates
4. Generate TypeScript types for `cpr-ui` (if automated)
5. Update JSON schemas in `cpr-api/tests/CPR.ContractTests/schemas/`
6. Implement changes in both repos
7. Update `tasks.md` to mark completion
8. Validate with contract tests
9. Update `progress.md` with completion status
10. Coordinate deployment

### Breaking Changes Protocol

**Definition**: A breaking change is any modification that could break existing clients:
- Removing or renaming fields
- Changing field types
- Removing endpoints
- Changing required fields
- Modifying error codes

**Process**:
1. Document breaking change in specification
2. Create ADR (Architecture Decision Record)
3. Plan deprecation timeline (minimum 6 months)
4. Add deprecation warnings to API responses
5. Version API if necessary (`/api/v2/`)
6. Coordinate frontend and backend deployments
7. Monitor for client errors after deployment

### Why This Matters

- **Integration Stability**: Frontend and backend stay in sync
- **Reduced Bugs**: Contract violations caught before production
- **Clear Contracts**: Both teams know exactly what to expect
- **Safe Refactoring**: Internal changes don't break integration
- **Automated Testing**: Machines verify consistency continuously

---

## Principle 3: API Standards & Security

### Statement
**All APIs must follow RESTful conventions, implement comprehensive validation and security controls, and use standardized error handling. Every endpoint must protect against common vulnerabilities and provide clear, actionable feedback.**

### Definition

APIs are the contract between systems. They must be:
- **RESTful**: Follow HTTP semantics and resource-oriented design
- **Secure**: Validate all inputs, sanitize outputs, implement rate limiting
- **Standard**: Use RFC 7807 for errors, consistent status codes, predictable structure
- **Idempotent**: Safe to retry without unintended side effects (where applicable)
- **Documented**: OpenAPI/Swagger specifications with examples

### Core Requirements

#### 1. RESTful Resource Design

**HTTP Methods**:
```
GET     - Retrieve resource(s) (safe, idempotent)
POST    - Create new resource
PUT     - Replace entire resource (idempotent)
PATCH   - Update partial resource
DELETE  - Remove resource (idempotent)
HEAD    - Get metadata only
OPTIONS - Discover allowed methods
```

**URL Structure**:
```
✅ Good: Resource-oriented, hierarchical
GET    /api/v1/users/{userId}
GET    /api/v1/users/{userId}/goals
POST   /api/v1/users/{userId}/goals
PATCH  /api/v1/goals/{goalId}
DELETE /api/v1/goals/{goalId}

❌ Bad: RPC-style, verb in URL
POST /api/v1/getUser
POST /api/v1/deleteGoal/{goalId}
GET  /api/v1/users/get/{userId}
```

**Status Codes** (consistent usage):
```
200 OK              - Successful GET, PATCH, PUT
201 Created         - Successful POST (resource created)
204 No Content      - Successful DELETE
400 Bad Request     - Client error (validation, malformed JSON)
401 Unauthorized    - Missing or invalid authentication
403 Forbidden       - Authenticated but not authorized
404 Not Found       - Resource doesn't exist
409 Conflict        - Resource state conflict (e.g., duplicate)
422 Unprocessable   - Semantic validation errors
429 Too Many Requests - Rate limit exceeded
500 Internal Error  - Server error (never expose stack traces)
503 Service Unavailable - Temporary unavailability
```

#### 2. Input Validation & Sanitization

**Server-Side Validation** (never trust client):
```csharp
// ASP.NET Core example
public class CreateGoalRequest
{
    [Required]
    [StringLength(200, MinimumLength = 3)]
    public string Title { get; set; }
    
    [Required]
    [Range(typeof(DateTime), "2025-01-01", "2030-12-31")]
    public DateTime TargetDate { get; set; }
    
    [Required]
    [RegularExpression(@"^[a-zA-Z0-9-_]+$")]
    public string Slug { get; set; }
}

[ApiController]
[Route("api/v1/goals")]
public class GoalsController : ControllerBase
{
    [HttpPost]
    public async Task<ActionResult<GoalDto>> CreateGoal(
        [FromBody] CreateGoalRequest request)
    {
        // Validation happens automatically via [ApiController]
        // If invalid, returns 400 with RFC 7807 problem details
        
        // Sanitize text inputs
        var sanitizedTitle = _sanitizer.Sanitize(request.Title);
        
        // Create goal with validated data
        var goal = await _goalService.CreateAsync(sanitizedTitle, request.TargetDate);
        return CreatedAtAction(nameof(GetGoal), new { id = goal.Id }, goal);
    }
}
```

**Input Sanitization**:
```csharp
// Prevent XSS and injection attacks
public class InputSanitizer
{
    public string Sanitize(string input)
    {
        if (string.IsNullOrWhiteSpace(input)) return string.Empty;
        
        // Remove HTML tags
        var noHtml = Regex.Replace(input, @"<[^>]*>", string.Empty);
        
        // Encode special characters
        var encoded = HtmlEncoder.Default.Encode(noHtml);
        
        // Trim whitespace
        return encoded.Trim();
    }
    
    public string SanitizeSql(string input)
    {
        // Use parameterized queries instead (this is just for logging)
        return input?.Replace("'", "''").Replace(";", "");
    }
}
```

#### 3. Rate Limiting

**Implementation**:
```csharp
// ASP.NET Core rate limiting middleware
public class RateLimitingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IMemoryCache _cache;
    private readonly int _maxRequests = 100; // per window
    private readonly TimeSpan _window = TimeSpan.FromMinutes(1);
    
    public async Task InvokeAsync(HttpContext context)
    {
        var clientId = GetClientIdentifier(context);
        var key = $"ratelimit:{clientId}";
        
        if (!_cache.TryGetValue(key, out int requestCount))
        {
            requestCount = 0;
        }
        
        if (requestCount >= _maxRequests)
        {
            context.Response.StatusCode = 429;
            context.Response.Headers.Add("Retry-After", "60");
            await context.Response.WriteAsync("Rate limit exceeded");
            return;
        }
        
        _cache.Set(key, requestCount + 1, _window);
        context.Response.Headers.Add("X-RateLimit-Limit", _maxRequests.ToString());
        context.Response.Headers.Add("X-RateLimit-Remaining", 
            (_maxRequests - requestCount - 1).ToString());
        
        await _next(context);
    }
    
    private string GetClientIdentifier(HttpContext context)
    {
        // Use user ID for authenticated requests
        if (context.User.Identity?.IsAuthenticated == true)
        {
            return context.User.FindFirst(ClaimTypes.NameIdentifier)?.Value ?? "unknown";
        }
        
        // Use IP for anonymous requests
        return context.Connection.RemoteIpAddress?.ToString() ?? "unknown";
    }
}
```

#### 4. RFC 7807 Problem Details

**All error responses must follow RFC 7807**:
```json
// 400 Bad Request
{
  "type": "https://api.cpr.local/problems/validation-error",
  "title": "validation_failed",
  "status": 400,
  "detail": "One or more validation errors occurred",
  "instance": "/api/v1/goals",
  "trace_id": "00-abc123-def456-00",
  "errors": {
    "title": [
      "Title is required",
      "Title must be between 3 and 200 characters"
    ],
    "targetDate": [
      "Target date must be in the future"
    ]
  }
}

// 404 Not Found
{
  "type": "https://api.cpr.local/problems/not-found",
  "title": "resource_not_found",
  "status": 404,
  "detail": "Goal with ID '123' was not found",
  "instance": "/api/v1/goals/123",
  "trace_id": "00-abc123-def456-00"
}

// 409 Conflict
{
  "type": "https://api.cpr.local/problems/conflict",
  "title": "resource_conflict",
  "status": 409,
  "detail": "A goal with this slug already exists",
  "instance": "/api/v1/goals",
  "trace_id": "00-abc123-def456-00",
  "conflicting_resource": "/api/v1/goals/existing-goal-slug"
}
```

**C# Implementation**:
```csharp
public class ProblemDetailsFactory
{
    public ProblemDetails CreateValidationProblem(
        HttpContext context,
        IDictionary<string, string[]> errors)
    {
        return new ValidationProblemDetails(errors)
        {
            Type = "https://api.cpr.local/problems/validation-error",
            Title = "validation_failed",
            Status = 400,
            Detail = "One or more validation errors occurred",
            Instance = context.Request.Path,
            Extensions =
            {
                ["trace_id"] = Activity.Current?.Id ?? context.TraceIdentifier
            }
        };
    }
    
    public ProblemDetails CreateNotFoundProblem(
        HttpContext context,
        string resourceType,
        string resourceId)
    {
        return new ProblemDetails
        {
            Type = "https://api.cpr.local/problems/not-found",
            Title = "resource_not_found",
            Status = 404,
            Detail = $"{resourceType} with ID '{resourceId}' was not found",
            Instance = context.Request.Path,
            Extensions =
            {
                ["trace_id"] = Activity.Current?.Id ?? context.TraceIdentifier
            }
        };
    }
}
```

#### 5. Idempotency

**Idempotent Operations** (safe to retry):
```
GET, PUT, DELETE, HEAD, OPTIONS, PATCH (with idempotency keys)
```

**POST Idempotency**:
```csharp
[HttpPost]
public async Task<ActionResult<GoalDto>> CreateGoal(
    [FromBody] CreateGoalRequest request,
    [FromHeader(Name = "Idempotency-Key")] string? idempotencyKey)
{
    if (!string.IsNullOrEmpty(idempotencyKey))
    {
        // Check if we've seen this key before
        var existing = await _cache.GetAsync<GoalDto>($"idempotency:{idempotencyKey}");
        if (existing != null)
        {
            // Return cached response
            return CreatedAtAction(nameof(GetGoal), new { id = existing.Id }, existing);
        }
    }
    
    var goal = await _goalService.CreateAsync(request);
    
    if (!string.IsNullOrEmpty(idempotencyKey))
    {
        // Cache response for 24 hours
        await _cache.SetAsync($"idempotency:{idempotencyKey}", goal, TimeSpan.FromHours(24));
    }
    
    return CreatedAtAction(nameof(GetGoal), new { id = goal.Id }, goal);
}
```

#### 6. Pagination

**Standardized Pagination**:
```csharp
public class PaginatedRequest
{
    [Range(1, int.MaxValue)]
    public int Page { get; set; } = 1;
    
    [Range(1, 100)]
    public int PageSize { get; set; } = 20;
    
    public string? SortBy { get; set; }
    public string? SortOrder { get; set; } = "asc";
}

public class PaginatedResponse<T>
{
    public IReadOnlyList<T> Items { get; set; } = Array.Empty<T>();
    public int Page { get; set; }
    public int PageSize { get; set; }
    public int TotalPages { get; set; }
    public int TotalItems { get; set; }
    public bool HasPrevious => Page > 1;
    public bool HasNext => Page < TotalPages;
}

[HttpGet]
public async Task<ActionResult<PaginatedResponse<GoalDto>>> GetGoals(
    [FromQuery] PaginatedRequest request)
{
    var (goals, totalCount) = await _goalService.GetPaginatedAsync(
        request.Page, 
        request.PageSize,
        request.SortBy,
        request.SortOrder);
    
    var response = new PaginatedResponse<GoalDto>
    {
        Items = goals,
        Page = request.Page,
        PageSize = request.PageSize,
        TotalPages = (int)Math.Ceiling(totalCount / (double)request.PageSize),
        TotalItems = totalCount
    };
    
    // Add Link headers for HATEOAS
    Response.Headers.Add("Link", BuildLinkHeader(request, response));
    
    return Ok(response);
}
```

#### 7. Security Headers

**Required Headers**:
```csharp
// Configure in Program.cs
app.Use(async (context, next) =>
{
    context.Response.Headers.Add("X-Content-Type-Options", "nosniff");
    context.Response.Headers.Add("X-Frame-Options", "DENY");
    context.Response.Headers.Add("X-XSS-Protection", "1; mode=block");
    context.Response.Headers.Add("Referrer-Policy", "no-referrer");
    context.Response.Headers.Add("Content-Security-Policy", 
        "default-src 'self'; script-src 'self'; style-src 'self' 'unsafe-inline'");
    
    await next();
});

// CORS configuration
app.UseCors(policy => policy
    .WithOrigins("https://cpr-ui.azurewebsites.net")
    .AllowedMethods("GET", "POST", "PUT", "PATCH", "DELETE")
    .AllowedHeaders("Content-Type", "Authorization", "Idempotency-Key")
    .AllowCredentials());
```

### Enforcement

#### 1. Automated Validation
- **Contract Tests**: Validate request/response schemas against OpenAPI specs
- **Security Scanning**: OWASP ZAP or similar for vulnerability testing
- **Rate Limit Tests**: Verify rate limiting works correctly
- **Integration Tests**: Test error responses follow RFC 7807

#### 2. Code Review Checklist
- [ ] All inputs validated on server side
- [ ] Text inputs sanitized to prevent XSS
- [ ] SQL queries use parameterized statements (never string concatenation)
- [ ] Rate limiting configured for all endpoints
- [ ] Error responses follow RFC 7807 format
- [ ] Status codes match RESTful semantics
- [ ] Idempotency keys supported for POST operations
- [ ] Security headers configured correctly
- [ ] CORS policy restricted to known origins
- [ ] No sensitive data in error messages or logs

#### 3. Security Audit
- Regular penetration testing
- Dependency vulnerability scanning (Dependabot, Snyk)
- Static analysis (SonarQube, CodeQL)
- Review Azure Security Center recommendations

### Why This Matters

- **Security First**: Prevent common vulnerabilities (OWASP Top 10)
- **Predictable Behavior**: Clients know what to expect from API design
- **Resilient Systems**: Rate limiting and idempotency prevent abuse and failures
- **Better DX**: Clear error messages help developers debug quickly
- **Compliance**: Input validation and sanitization meet regulatory requirements
- **Scalability**: Standardized pagination and caching patterns support growth

---

## Principle 4: Type Safety Everywhere

### Statement
**Use strong, explicit typing throughout the codebase. Minimize or eliminate runtime type errors through compile-time checks.**

### Definition
All code in CPR repositories must use TypeScript (frontend) or C# (backend) with strict type checking enabled. Type inference is allowed, but explicit types are preferred for public APIs, function signatures, and complex structures.

### Standards

#### Backend (cpr-api) - C# / .NET 8
```csharp
// ✅ Good: Explicit types, nullable reference types
public async Task<GoalDto?> GetGoalByIdAsync(Guid id, Guid ownerId)
{
    var goal = await _context.Goals
        .Where(g => g.Id == id && g.EmployeeId == ownerId)
        .FirstOrDefaultAsync();
    
    return goal != null ? MapToDto(goal) : null;
}

// ❌ Bad: Dynamic types, unclear nullability
public async Task<dynamic> GetGoalByIdAsync(object id, object ownerId)
{
    // Type safety lost
}
```

**C# Settings**:
- Nullable reference types enabled (`<Nullable>enable</Nullable>`)
- Warnings treated as errors in CI/CD
- No suppression of nullability warnings without justification

#### Frontend (cpr-ui) - TypeScript
```typescript
// ✅ Good: Explicit interface, no any
interface IUserProfile {
  userId: string;
  employeeId: string;
  userName: string;
  displayName: string;
  email: string | null;
  position: {
    id: string;
    title: string;
  };
}

async function fetchUserProfile(userId: string): Promise<IUserProfile> {
  const response = await fetch(`/api/users/${userId}`);
  return await response.json();
}

// ❌ Bad: any type, no validation
async function fetchUserProfile(userId: any): Promise<any> {
  // Type safety lost
}
```

**TypeScript Configuration** (`tsconfig.json`):
```json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictBindCallApply": true,
    "strictPropertyInitialization": true,
    "noImplicitThis": true,
    "alwaysStrict": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true,
    "noImplicitReturns": true,
    "noFallthroughCasesInSwitch": true
  }
}
```

### When `any` or `dynamic` is Allowed

**Acceptable Use Cases** (with justification):
- ✅ Third-party library with no type definitions (add comment explaining why)
- ✅ Truly dynamic data (e.g., JSON from external API) - immediately validate and convert to typed structure
- ✅ Generic utility functions where type is truly unknown - consider `unknown` instead

**Process for Exceptions**:
1. Document reason in code comment
2. Add runtime validation to compensate for lost type safety
3. Create issue to replace with proper types
4. Get approval in PR review

```typescript
// ✅ Acceptable: Third-party library, planned replacement
// TODO: Replace with typed library (Issue #123)
// eslint-disable-next-line @typescript-eslint/no-explicit-any
const legacyWidget: any = initLegacyWidget();

// ✅ Better: Use unknown and validate
function processUnknownData(data: unknown): ProcessedData {
  if (!isValidData(data)) {
    throw new Error("Invalid data structure");
  }
  return data as ProcessedData; // Type guard provides safety
}
```

### Type Generation from Specifications

**Goal**: Generate TypeScript types from OpenAPI schemas to ensure consistency.

**Future Implementation**:
- Use tools like `openapi-typescript` or `swagger-typescript-api`
- Generate types during build process
- Commit generated types or generate on-demand

**Example**:
```bash
# Generate TypeScript types from OpenAPI spec
npx openapi-typescript cpr-meta/specs/api/openapi.yaml \
  --output cpr-ui/src/types/generated/api.ts
```

### Enforcement

**CI/CD Checks**:
- TypeScript compilation with strict mode
- C# build with warnings as errors
- ESLint rule: `@typescript-eslint/no-explicit-any` set to `error`
- Code review requirement: Reviewers flag any `any` usage

**Pull Request Checklist**:
- [ ] No `any` types without documented justification
- [ ] Nullable types explicitly handled
- [ ] Public APIs have explicit type annotations
- [ ] Complex types use interfaces or type aliases

### Why This Matters

- **Early Error Detection**: Catch bugs at compile time, not runtime
- **Better IDE Support**: IntelliSense, autocomplete, refactoring
- **Self-Documenting**: Types serve as inline documentation
- **Refactoring Safety**: Compiler catches broken references
- **Integration Confidence**: Type mismatches caught before deployment

---

## Principle 5: Offline Mode

### Statement
**The UI must function with mocked API responses during development and testing. Every API endpoint must have a corresponding mock implementation.**

### Definition
The CPR UI must support offline development and testing using Mock Service Worker (MSW) to intercept API requests and return realistic mock data. Mock implementations must be created alongside real API endpoints and kept in sync with API contracts defined in specifications.

**Current Implementation Status**: ✅ MSW is already implemented and configured in `cpr-ui`. Mock handlers are available for existing API endpoints. Use `yarn start:mock` to run in offline mode.

### Why Mock APIs Matter

**Benefits**:
- **Parallel Development**: Frontend can develop features before backend is ready
- **Faster Development**: No need to run backend API locally
- **Reliable Testing**: Tests don't depend on external services or network
- **Isolated Testing**: UI tests run without database or authentication dependencies
- **Faster CI/CD**: Tests run in milliseconds, not seconds
- **Better Demos**: Showcase features without full infrastructure
- **Edge Case Testing**: Easy to simulate errors, slow responses, edge cases

### Mock Service Worker (MSW)

**Recommended Library**: MSW (Mock Service Worker)

**Why MSW?**
- ✅ Intercepts requests at network level (works with fetch, axios, etc.)
- ✅ Same mock code for development and testing
- ✅ No changes to application code
- ✅ Supports REST and GraphQL
- ✅ TypeScript support

**Installation** (`cpr-ui`):
```bash
yarn add msw --dev
```

**Note**: The CPR project uses **Yarn** as the package manager, not npm.

### Mock Implementation Structure

**Location**: `cpr-ui/src/mocks/`

```
cpr-ui/src/mocks/
├── handlers/
│   ├── auth.handlers.ts       # Authentication endpoints
│   ├── users.handlers.ts      # User management endpoints
│   ├── goals.handlers.ts      # Goals endpoints
│   ├── index.ts               # Export all handlers
│   └── ...
├── data/
│   ├── users.data.ts          # Mock user data
│   ├── goals.data.ts          # Mock goals data
│   └── ...
├── browser.ts                 # MSW browser setup (for dev mode)
├── server.ts                  # MSW server setup (for tests)
└── README.md                  # Mock API documentation
```

### MSW Setup

#### Browser Setup (Development Mode)

**File**: `cpr-ui/src/mocks/browser.ts`
```typescript
import { setupWorker } from 'msw/browser';
import { handlers } from './handlers';

// Setup worker for browser environment
export const worker = setupWorker(...handlers);
```

**File**: `cpr-ui/src/main.tsx`
```typescript
import { logger } from './utils/logger'

/**
 * Enable MSW (Mock Service Worker) if configured
 */
async function enableMocking() {
  if (import.meta.env['VITE_USE_MSW'] === 'true') {
    logger.msw('Initializing Mock Service Worker...')

    try {
      const { worker } = await import('./mocks/browser')

      await worker.start({
        onUnhandledRequest: 'warn', // Warn about unhandled requests
        serviceWorker: {
          url: '/mockServiceWorker.js',
        },
      })

      logger.msw('Mock Service Worker initialized successfully')
      logger.msw(`Mock Mode: ${import.meta.env['VITE_API_MODE']}`)
      logger.msw(
        `Mock User Role: ${import.meta.env['VITE_MOCK_USER_ROLE'] || 'employee'}`
      )
    } catch (error) {
      logger.error('Failed to initialize Mock Service Worker', { error })
    }
  }
}

// Initialize MSW before rendering the app
enableMocking().then(() => {
  createRoot(document.getElementById('root')!).render(
    <StrictMode>
      <ThemedApp />
    </StrictMode>
  )
})
```

**Public Folder**: Copy MSW service worker to `public/`
```bash
yarn dlx msw init public/ --save
```

**Note**: This is already configured in `cpr-ui`. The `msw` section in `package.json` specifies `workerDirectory: ["public"]`.

#### Server Setup (Testing)

**File**: `cpr-ui/src/mocks/server.ts`
```typescript
import { setupServer } from 'msw/node';
import { handlers } from './handlers';

// Setup server for Node.js environment (tests)
export const server = setupServer(...handlers);
```

**File**: `cpr-ui/src/test/setup.ts`
```typescript
import { beforeAll, afterEach, afterAll } from 'vitest';
import { server } from '../mocks/server';

// Start server before all tests
beforeAll(() => server.listen({ onUnhandledRequest: 'error' }));

// Reset handlers after each test
afterEach(() => server.resetHandlers());

// Clean up after all tests
afterAll(() => server.close());
```

**Vitest Config**: `vitest.config.ts`
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./src/test/setup.ts'],
  },
});
```

### Mock Handler Implementation

#### Basic Handler Example

**File**: `cpr-ui/src/mocks/handlers/goals.handlers.ts`
```typescript
import { http, HttpResponse } from 'msw';
import { mockGoals } from '../data/goals.data';

export const goalsHandlers = [
  // GET /api/v1/me/goals - List user's goals
  http.get('/api/v1/me/goals', ({ request }) => {
    const url = new URL(request.url);
    const page = parseInt(url.searchParams.get('page') || '1');
    const perPage = parseInt(url.searchParams.get('per_page') || '20');
    
    // Simulate pagination
    const start = (page - 1) * perPage;
    const end = start + perPage;
    const paginatedGoals = mockGoals.slice(start, end);
    
    return HttpResponse.json({
      items: paginatedGoals,
      total: mockGoals.length,
      page,
      per_page: perPage,
    });
  }),

  // GET /api/v1/goals/:id - Get goal by ID
  http.get('/api/v1/goals/:id', ({ params }) => {
    const { id } = params;
    const goal = mockGoals.find(g => g.id === id);
    
    if (!goal) {
      return HttpResponse.json(
        {
          type: 'https://tools.ietf.org/html/rfc7231#section-6.5.4',
          title: 'errors.not_found',
          status: 404,
          detail: 'errors.goal_not_found',
        },
        { status: 404 }
      );
    }
    
    return HttpResponse.json(goal);
  }),

  // POST /api/v1/goals - Create new goal
  http.post('/api/v1/goals', async ({ request }) => {
    const body = await request.json();
    
    // Validate required fields
    if (!body.title) {
      return HttpResponse.json(
        {
          type: 'https://tools.ietf.org/html/rfc7231#section-6.5.1',
          title: 'errors.validation_failed',
          status: 422,
          detail: 'errors.goal_title_required',
          errors: {
            title: [
              {
                key: 'validation.required',
                field: 'title',
              },
            ],
          },
        },
        { status: 422 }
      );
    }
    
    // Create new goal
    const newGoal = {
      id: crypto.randomUUID(),
      employee_id: 'mock-employee-id',
      title: body.title,
      description: body.description || null,
      priority: body.priority || 5,
      visibility: body.visibility || 'private',
      status: 'not_started',
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    };
    
    mockGoals.push(newGoal);
    
    return HttpResponse.json(newGoal, { status: 201 });
  }),

  // PATCH /api/v1/goals/:id - Update goal
  http.patch('/api/v1/goals/:id', async ({ params, request }) => {
    const { id } = params;
    const body = await request.json();
    const goalIndex = mockGoals.findIndex(g => g.id === id);
    
    if (goalIndex === -1) {
      return HttpResponse.json(
        {
          type: 'https://tools.ietf.org/html/rfc7231#section-6.5.4',
          title: 'errors.not_found',
          status: 404,
          detail: 'errors.goal_not_found',
        },
        { status: 404 }
      );
    }
    
    // Update goal
    mockGoals[goalIndex] = {
      ...mockGoals[goalIndex],
      ...body,
      updated_at: new Date().toISOString(),
    };
    
    return HttpResponse.json(mockGoals[goalIndex]);
  }),

  // DELETE /api/v1/goals/:id - Delete goal
  http.delete('/api/v1/goals/:id', ({ params }) => {
    const { id } = params;
    const goalIndex = mockGoals.findIndex(g => g.id === id);
    
    if (goalIndex === -1) {
      return HttpResponse.json(
        {
          type: 'https://tools.ietf.org/html/rfc7231#section-6.5.4',
          title: 'errors.not_found',
          status: 404,
          detail: 'errors.goal_not_found',
        },
        { status: 404 }
      );
    }
    
    mockGoals.splice(goalIndex, 1);
    
    return new HttpResponse(null, { status: 204 });
  }),
];
```

#### Mock Data Example

**File**: `cpr-ui/src/mocks/data/goals.data.ts`
```typescript
export const mockGoals = [
  {
    id: '550e8400-e29b-41d4-a716-446655440000',
    employee_id: '679add6e-6c29-4e00-b6a5-b69c8e0f3445',
    title: 'Complete Q4 objectives',
    description: 'Finish all assigned tasks for Q4',
    priority: 8,
    visibility: 'manager',
    status: 'in_progress',
    created_at: '2025-10-01T10:00:00Z',
    updated_at: '2025-11-01T15:30:00Z',
  },
  {
    id: 'a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6',
    employee_id: '679add6e-6c29-4e00-b6a5-b69c8e0f3445',
    title: 'Learn TypeScript',
    description: 'Master TypeScript for frontend development',
    priority: 6,
    visibility: 'private',
    status: 'not_started',
    created_at: '2025-11-05T09:00:00Z',
    updated_at: '2025-11-05T09:00:00Z',
  },
  // ... more mock goals
];
```

#### Combining Handlers

**File**: `cpr-ui/src/mocks/handlers/index.ts`
```typescript
import { authHandlers } from './auth.handlers';
import { usersHandlers } from './users.handlers';
import { goalsHandlers } from './goals.handlers';

export const handlers = [
  ...authHandlers,
  ...usersHandlers,
  ...goalsHandlers,
];
```

### Advanced Mock Patterns

#### 1. Simulating Delays

**Simulate network latency**:
```typescript
import { http, HttpResponse, delay } from 'msw';

http.get('/api/v1/goals', async () => {
  // Simulate 500ms network delay
  await delay(500);
  
  return HttpResponse.json(mockGoals);
});
```

#### 2. Simulating Errors

**Test error handling**:
```typescript
http.get('/api/v1/goals/:id', ({ params }) => {
  const { id } = params;
  
  // Simulate server error for specific ID
  if (id === 'error-test-id') {
    return HttpResponse.json(
      {
        type: 'https://tools.ietf.org/html/rfc7231#section-6.6.1',
        title: 'errors.server_error',
        status: 500,
        detail: 'errors.unexpected_error',
      },
      { status: 500 }
    );
  }
  
  // Normal response
  const goal = mockGoals.find(g => g.id === id);
  return HttpResponse.json(goal);
});
```

#### 3. Stateful Mocks

**Maintain state across requests**:
```typescript
// Use a Map to track state
const goalsState = new Map(mockGoals.map(g => [g.id, g]));

http.post('/api/v1/goals', async ({ request }) => {
  const body = await request.json();
  const newGoal = {
    id: crypto.randomUUID(),
    ...body,
    created_at: new Date().toISOString(),
  };
  
  goalsState.set(newGoal.id, newGoal);
  
  return HttpResponse.json(newGoal, { status: 201 });
});

http.get('/api/v1/goals', () => {
  const goals = Array.from(goalsState.values());
  return HttpResponse.json({ items: goals });
});
```

#### 4. Request-Specific Overrides in Tests

**Override handler for specific test**:
```typescript
import { server } from '@/mocks/server';
import { http, HttpResponse } from 'msw';

test('should handle empty goals list', async () => {
  // Override handler for this test only
  server.use(
    http.get('/api/v1/me/goals', () => {
      return HttpResponse.json({
        items: [],
        total: 0,
        page: 1,
        per_page: 20,
      });
    })
  );
  
  const { getByText } = render(<GoalsList />);
  expect(getByText('No goals found')).toBeInTheDocument();
});
```

### Testing with Mocks

#### Component Test Example

```typescript
import { render, screen, waitFor } from '@testing-library/react';
import { GoalsList } from './GoalsList';

describe('GoalsList', () => {
  it('should display list of goals', async () => {
    render(<GoalsList />);
    
    // Wait for API call to complete (mocked by MSW)
    await waitFor(() => {
      expect(screen.getByText('Complete Q4 objectives')).toBeInTheDocument();
      expect(screen.getByText('Learn TypeScript')).toBeInTheDocument();
    });
  });
  
  it('should handle API errors', async () => {
    // Override handler to return error
    server.use(
      http.get('/api/v1/me/goals', () => {
        return HttpResponse.json(
          {
            type: 'https://tools.ietf.org/html/rfc7231#section-6.6.1',
            title: 'errors.server_error',
            status: 500,
            detail: 'errors.unexpected_error',
          },
          { status: 500 }
        );
      })
    );
    
    render(<GoalsList />);
    
    await waitFor(() => {
      expect(screen.getByText(/Server error/i)).toBeInTheDocument();
    });
  });
});
```

### Synchronization with API Contracts

**CRITICAL**: Mock implementations must match specifications in `cpr-meta/specs/[spec-###]/endpoints.md`

**Workflow**:
1. **Specification Created**: `endpoints.md` defines API contract
2. **Mock Created**: Developer creates MSW handler matching contract
3. **Frontend Development**: UI developed using mocks
4. **Backend Implementation**: API implemented per specification
5. **Contract Tests**: Validate real API matches specification
6. **Integration Tests**: Validate UI works with real API

**Checklist for Mock Implementation**:
- [ ] Mock handler matches endpoint URL exactly (including path parameters)
- [ ] Request body schema matches specification
- [ ] Response body schema matches specification (including field names in snake_case)
- [ ] HTTP status codes match specification
- [ ] Error responses follow RFC 7807 format
- [ ] Query parameters handled as specified
- [ ] Headers included as specified (e.g., `Authorization`)

### Mock API Documentation

**File**: `cpr-ui/src/mocks/README.md`

Document available mock endpoints:

```markdown
# Mock API Documentation

This directory contains MSW handlers for mocking CPR API endpoints.

## Available Endpoints

### Authentication
- `POST /api/v1/auth/login` - User login
- `POST /api/v1/auth/logout` - User logout
- `GET /api/v1/auth/me` - Get current user

### Goals
- `GET /api/v1/me/goals` - List user's goals (paginated)
- `GET /api/v1/goals/:id` - Get goal by ID
- `POST /api/v1/goals` - Create new goal
- `PATCH /api/v1/goals/:id` - Update goal
- `DELETE /api/v1/goals/:id` - Delete goal

## Usage

### Mock Mode
MSW is automatically enabled in mock mode. Start with mock APIs:
```bash
# Basic mock mode (employee role)
yarn start:mock

# Test as different roles
yarn start:mock-manager
yarn start:mock-owner
yarn start:mock-director
yarn start:mock-admin
```

### Testing
MSW is configured in test setup. Run tests:
```bash
yarn test

# With coverage
yarn test:coverage

# With UI
yarn test:ui
```

### Local API Mode
To test against locally running backend API:
```bash
yarn start:local
```

### Development Environment
To test against remote dev environment API:
```bash
yarn start:dev
```

## Adding New Mocks

1. Create handler file in `handlers/` (e.g., `tasks.handlers.ts`)
2. Create mock data in `data/` (e.g., `tasks.data.ts`)
3. Implement handlers matching `cpr-meta/specs/[spec-###]/endpoints.md`
4. Export handlers in `handlers/index.ts`
5. Document new endpoints in this README
6. Test with `yarn start:mock`
```

### Environment Configuration

The CPR UI supports multiple environment modes, configured via `.env.*` files and Yarn scripts:

**Available Modes**:

1. **Mock Mode** (`.env.mock`) - MSW intercepting all API calls
   - Use Cases: Offline development, testing UI without backend, demos
   - Configuration: `VITE_API_MODE=mock`, `VITE_USE_MSW=true`, `VITE_ENABLE_STUB_AUTH=true`
   - API calls are intercepted by MSW and return mock data
   
2. **Local API Mode** (`.env.localapi`) - Real backend running locally
   - Use Cases: Full-stack development, testing with real database
   - Configuration: `VITE_API_MODE=localapi`, `VITE_USE_MSW=false`, `VITE_API_BASE_URL=http://localhost:5000/api`
   - Requires `cpr-api` running on localhost:5000
   
3. **Development Mode** (`.env.development`) - Remote development environment
   - Use Cases: Testing against shared dev environment
   - Configuration: `VITE_API_MODE=development`, `VITE_USE_MSW=false`
   - Points to Azure-hosted development API

**Yarn Scripts** (defined in `package.json`):

```json
{
  "scripts": {
    "start:mock": "set VITE_MOCK_USER_ROLE=employee && vite --mode mock",
    "start:mock-employee": "set VITE_MOCK_USER_ROLE=employee && vite --mode mock",
    "start:mock-manager": "set VITE_MOCK_USER_ROLE=people-manager && vite --mode mock",
    "start:mock-owner": "set VITE_MOCK_USER_ROLE=solution-owner && vite --mode mock",
    "start:mock-director": "set VITE_MOCK_USER_ROLE=director && vite --mode mock",
    "start:mock-admin": "set VITE_MOCK_USER_ROLE=administrator && vite --mode mock",
    "start:local": "vite --mode localapi",
    "start:dev": "vite --mode development"
  }
}
```

**Usage Examples**:

```bash
# Start with mock APIs (default employee role)
yarn start:mock

# Start with mock APIs as people manager
yarn start:mock-manager

# Start with local backend API (requires cpr-api running)
yarn start:local

# Start pointing to remote dev environment
yarn start:dev

# Run tests (always use MSW mocks)
yarn test

# Run tests with coverage
yarn test:coverage
```

**Mock User Roles**:
Mock mode supports testing different user roles without authentication:
- `employee` - Basic employee with minimal permissions
- `people-manager` - Can manage team members and reviews
- `solution-owner` - Can manage solutions and projects
- `director` - Can view organization-wide data
- `administrator` - Full system access

**Environment Files**:

```
cpr-ui/
├── .env.mock          # Mock mode configuration
├── .env.localapi      # Local API mode configuration
├── .env.development   # Development environment configuration
├── .env.production    # Production environment configuration
└── .env.example       # Template for local overrides
```

**Conditional Mock Enablement**:
```typescript
async function enableMocking() {
  // Only enable MSW if VITE_USE_MSW is true
  if (import.meta.env['VITE_USE_MSW'] === 'true') {
    const { worker } = await import('./mocks/browser');
    
    await worker.start({
      onUnhandledRequest: 'warn',
      serviceWorker: {
        url: '/mockServiceWorker.js',
      },
    });
    
    // Log mock configuration
    console.log(`Mock Mode: ${import.meta.env['VITE_API_MODE']}`);
    console.log(`Mock User Role: ${import.meta.env['VITE_MOCK_USER_ROLE'] || 'employee'}`);
  }
}
```

**Note**: `VITE_USE_MSW=true` is set in `.env.mock` file, which is loaded when running `yarn start:mock`.

### Enforcement

#### Frontend Requirements

**Pull Request Checklist**:
- [ ] New API endpoints have corresponding MSW handlers
- [ ] Mock responses match specification in `endpoints.md`
- [ ] Mock data is realistic and covers edge cases
- [ ] Error scenarios are mocked (404, 422, 500, etc.)
- [ ] Tests use MSW for API mocking (no manual fetch mocking)

**CI/CD Checks**:
- All frontend tests run using MSW mocks
- Tests pass without real backend running
- Mock handlers validate against specification contracts

**Code Review Requirements**:
- Reviewers verify mock matches specification
- Edge cases and error conditions covered
- Mock data is representative

### Why This Matters

- **Development Speed**: No waiting for backend, no local API setup
- **Reliable Tests**: Tests don't fail due to network issues or backend changes
- **Parallel Work**: Frontend and backend teams work independently
- **Better Coverage**: Easy to test error conditions and edge cases
- **Faster CI/CD**: Tests run in milliseconds without external dependencies
- **Demos**: Can showcase features without full infrastructure
- **Documentation**: Mocks serve as living documentation of API contracts

---

## Principle 6: Internationalization

### Statement
**The CPR application must support multiple languages. All user-facing text must be localizable, and API messages must use localization keys.**

### Definition
The CPR UI must be fully internationalized (i18n) to support users in different locales. All static text in the UI (titles, labels, buttons, messages) must be externalized to translation files. When the API returns user-facing messages, it must provide localization keys that the UI can translate, rather than hardcoded text.

### Supported Languages

The CPR application supports the following languages:

1. **English (en)** - Default language
2. **Spanish (es)** - Español
3. **French (fr)** - Français
4. **Belarusian (be)** - Беларуская

**Default Fallback**: If a translation is missing, fall back to English.

### UI Localization Standards

#### 1. No Hardcoded Text in Components

**❌ Bad - Hardcoded text**:
```typescript
<button>Save Changes</button>
<h1>User Profile</h1>
<p>Please enter your email address</p>
```

**✅ Good - Using translation keys**:
```typescript
<button>{t('common.save_changes')}</button>
<h1>{t('profile.title')}</h1>
<p>{t('profile.email_prompt')}</p>
```

#### 2. Translation File Structure

**Location**: `cpr-ui/src/locales/`

```
cpr-ui/src/locales/
├── en/
│   ├── common.json          # Common UI elements
│   ├── auth.json            # Authentication & authorization
│   ├── profile.json         # User profile
│   ├── goals.json           # Goals management
│   ├── errors.json          # Error messages
│   └── validation.json      # Form validation
├── es/
│   ├── common.json
│   ├── auth.json
│   └── ...
├── fr/
│   └── ...
└── be/
    └── ...
```

**Translation Key Naming Convention**: `namespace.category.key`

```json
// en/common.json
{
  "save": "Save",
  "cancel": "Cancel",
  "delete": "Delete",
  "confirm": "Confirm",
  "save_changes": "Save Changes",
  "discard_changes": "Discard Changes",
  "loading": "Loading...",
  "error": "Error",
  "success": "Success"
}

// en/goals.json
{
  "title": "Goals",
  "create_goal": "Create Goal",
  "edit_goal": "Edit Goal",
  "delete_goal": "Delete Goal",
  "goal_title": "Goal Title",
  "goal_description": "Description",
  "goal_priority": "Priority",
  "goal_status": "Status",
  "goal_created": "Goal created successfully",
  "goal_updated": "Goal updated successfully",
  "goal_deleted": "Goal deleted successfully"
}

// en/errors.json
{
  "network_error": "Network error. Please check your connection.",
  "unauthorized": "You are not authorized to perform this action.",
  "not_found": "The requested resource was not found.",
  "server_error": "Server error. Please try again later.",
  "validation_error": "Please correct the errors and try again."
}
```

#### 3. Internationalization Library

**Recommended**: `react-i18next` (for React applications)

**Setup** (`cpr-ui/src/i18n/config.ts`):
```typescript
import i18n from 'i18next';
import { initReactI18next } from 'react-i18next';
import LanguageDetector from 'i18next-browser-languagedetector';

// Import translation files
import enCommon from '../locales/en/common.json';
import enAuth from '../locales/en/auth.json';
import esCommon from '../locales/es/common.json';
import esAuth from '../locales/es/auth.json';
import frCommon from '../locales/fr/common.json';
import frAuth from '../locales/fr/auth.json';
import beCommon from '../locales/be/common.json';
import beAuth from '../locales/be/auth.json';

i18n
  .use(LanguageDetector) // Detect user language
  .use(initReactI18next) // Pass i18n to react-i18next
  .init({
    resources: {
      en: {
        common: enCommon,
        auth: enAuth,
        // ... other namespaces
      },
      es: {
        common: esCommon,
        auth: esAuth,
        // ... other namespaces
      },
      fr: {
        common: frCommon,
        auth: frAuth,
        // ... other namespaces
      },
      be: {
        common: beCommon,
        auth: beAuth,
        // ... other namespaces
      }
    },
    fallbackLng: 'en',
    defaultNS: 'common',
    interpolation: {
      escapeValue: false // React already escapes
    }
  });

export default i18n;
```

**Usage in Components**:
```typescript
import { useTranslation } from 'react-i18next';

function GoalForm() {
  const { t } = useTranslation(['goals', 'common']);
  
  return (
    <form>
      <h2>{t('goals:title')}</h2>
      <label>{t('goals:goal_title')}</label>
      <input type="text" placeholder={t('goals:goal_title')} />
      
      <button type="submit">{t('common:save')}</button>
      <button type="button">{t('common:cancel')}</button>
    </form>
  );
}
```

**Language Switching**:
```typescript
import { useTranslation } from 'react-i18next';

function LanguageSelector() {
  const { i18n } = useTranslation();
  
  const changeLanguage = (lang: string) => {
    i18n.changeLanguage(lang);
    localStorage.setItem('preferred-language', lang);
  };
  
  return (
    <select 
      value={i18n.language} 
      onChange={(e) => changeLanguage(e.target.value)}
    >
      <option value="en">English</option>
      <option value="es">Español</option>
      <option value="fr">Français</option>
      <option value="be">Беларуская</option>
    </select>
  );
}
```

#### 4. Dynamic Content with Interpolation

**Translations with variables**:
```json
// en/goals.json
{
  "goal_created_by": "Created by {{userName}} on {{date}}",
  "items_count": "{{count}} items",
  "items_count_plural": "{{count}} items"
}
```

**Usage**:
```typescript
const { t } = useTranslation('goals');

// Simple interpolation
<p>{t('goal_created_by', { userName: 'John Doe', date: '2025-11-05' })}</p>

// Pluralization
<p>{t('items_count', { count: 5 })}</p>
```

#### 5. Date and Number Formatting

**Use locale-aware formatting**:
```typescript
import { useTranslation } from 'react-i18next';

function GoalItem({ goal }: { goal: Goal }) {
  const { i18n } = useTranslation();
  
  // Format date according to user's locale
  const formattedDate = new Date(goal.createdAt).toLocaleDateString(
    i18n.language,
    { year: 'numeric', month: 'long', day: 'numeric' }
  );
  
  // Format number according to user's locale
  const formattedPriority = new Intl.NumberFormat(i18n.language).format(
    goal.priority
  );
  
  return (
    <div>
      <p>{formattedDate}</p>
      <p>Priority: {formattedPriority}</p>
    </div>
  );
}
```

### API Message Localization

#### The Problem with Hardcoded API Messages

**❌ Bad - API returns hardcoded English messages**:
```json
// API Response
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Validation Failed",
  "status": 422,
  "detail": "Goal title must be between 1 and 200 characters",
  "errors": {
    "title": ["Title is required", "Title is too long"]
  }
}
```

**Problem**: The UI cannot translate these messages for Spanish, French, or Belarusian users.

#### Solution: Return Localization Keys

**✅ Good - API returns localization keys with parameters**:
```json
// API Response
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "errors.validation_failed",
  "status": 422,
  "detail": "errors.goal_title_length",
  "detail_params": {
    "min": 1,
    "max": 200
  },
  "errors": {
    "title": [
      {
        "key": "validation.required",
        "field": "title"
      },
      {
        "key": "validation.max_length",
        "field": "title",
        "params": { "max": 200 }
      }
    ]
  }
}
```

**Translation Files**:
```json
// en/errors.json
{
  "validation_failed": "Validation Failed",
  "goal_title_length": "Goal title must be between {{min}} and {{max}} characters"
}

// en/validation.json
{
  "required": "{{field}} is required",
  "max_length": "{{field}} must not exceed {{max}} characters"
}
```

**Frontend Usage**:
```typescript
// Error type definitions
type TLocalizedError = {
  key: string;
  field?: string;
  params?: Record<string, unknown>;
};

interface IApiError {
  title: string;  // Translation key
  detail: string;  // Translation key
  detail_params?: Record<string, unknown>;
  errors?: Record<string, Array<TLocalizedError>>;
}

function handleApiError(error: IApiError) {
  const { t } = useTranslation(['errors', 'validation']);
  
  // Translate main error message
  const title = t(`errors:${error.title}`);
  const detail = t(`errors:${error.detail}`, error.detail_params);
  
  // Translate field errors
  const fieldErrors = Object.entries(error.errors || {}).map(([field, errors]) => {
    return errors.map(err => {
      const fieldName = t(`fields:${err.field || field}`);
      return t(`validation:${err.key}`, { 
        field: fieldName,
        ...err.params 
      });
    });
  });
  
  return { title, detail, fieldErrors };
}
```

#### Backend Implementation

**C# Example** (`cpr-api`):
```csharp
// Custom ProblemDetails class
public class LocalizedProblemDetails : ProblemDetails
{
    [JsonPropertyName("detail_params")]
    public Dictionary<string, object>? DetailParams { get; set; }
    
    [JsonPropertyName("errors")]
    public new Dictionary<string, List<LocalizedError>>? Errors { get; set; }
}

public class LocalizedError
{
    [JsonPropertyName("key")]
    public string Key { get; set; } = string.Empty;
    
    [JsonPropertyName("field")]
    public string? Field { get; set; }
    
    [JsonPropertyName("params")]
    public Dictionary<string, object>? Params { get; set; }
}

// Usage in controller
public class GoalsController : ControllerBase
{
    [HttpPost]
    public async Task<IActionResult> CreateGoal([FromBody] CreateGoalDto dto)
    {
        if (string.IsNullOrWhiteSpace(dto.Title))
        {
            return UnprocessableEntity(new LocalizedProblemDetails
            {
                Title = "errors.validation_failed",
                Status = 422,
                Detail = "errors.goal_title_required",
                Errors = new Dictionary<string, List<LocalizedError>>
                {
                    ["title"] = new List<LocalizedError>
                    {
                        new LocalizedError 
                        { 
                            Key = "validation.required",
                            Field = "title"
                        }
                    }
                }
            });
        }
        
        if (dto.Title.Length > 200)
        {
            return UnprocessableEntity(new LocalizedProblemDetails
            {
                Title = "errors.validation_failed",
                Status = 422,
                Detail = "errors.goal_title_length",
                DetailParams = new Dictionary<string, object>
                {
                    ["min"] = 1,
                    ["max"] = 200
                },
                Errors = new Dictionary<string, List<LocalizedError>>
                {
                    ["title"] = new List<LocalizedError>
                    {
                        new LocalizedError 
                        { 
                            Key = "validation.max_length",
                            Field = "title",
                            Params = new Dictionary<string, object> { ["max"] = 200 }
                        }
                    }
                }
            });
        }
        
        // ... proceed with creation
    }
}
```

#### Standard Error Localization Keys

**Error Response Structure**:
```json
{
  "title": "errors.{error_category}",
  "detail": "errors.{specific_error}",
  "detail_params": { /* interpolation values */ }
}
```

**Common Error Keys**:
- `errors.validation_failed` - Validation errors
- `errors.unauthorized` - Authentication required
- `errors.forbidden` - Insufficient permissions
- `errors.not_found` - Resource not found
- `errors.conflict` - Resource conflict
- `errors.server_error` - Internal server error

**Common Validation Keys**:
- `validation.required` - Field is required
- `validation.min_length` - Minimum length not met
- `validation.max_length` - Maximum length exceeded
- `validation.invalid_format` - Invalid format (email, UUID, etc.)
- `validation.out_of_range` - Value out of allowed range

### Enforcement

#### Frontend Requirements

**Pull Request Checklist**:
- [ ] No hardcoded user-facing text in components
- [ ] All text uses translation keys
- [ ] New translation keys added to all language files (en, es, fr, be)
- [ ] Dates and numbers formatted with locale awareness
- [ ] API error responses translated using keys

**CI/CD Checks**:
- ESLint rule to detect hardcoded strings in JSX (future)
- Translation completeness check (all keys present in all languages)

**Missing Translations**:
- All translation keys MUST have a fallback message in English
- If a key is missing in Spanish, French, or Belarusian, default to English translation
- Log warning in console (dev mode only) when fallback is used
- Track missing translations for future completion
- Never display raw translation keys (e.g., "errors.validation_failed") to users

#### Backend Requirements

**Pull Request Checklist**:
- [ ] API error responses use localization keys (not hardcoded messages)
- [ ] `LocalizedProblemDetails` used for all error responses
- [ ] Error keys follow naming convention (`errors.{category}.{specific}`)
- [ ] Translation parameters included when needed

**Exception**: System log messages (not user-facing) can remain in English.

### Language Detection and Persistence

**Priority Order**:
1. **User's stored preference** (from localStorage or user profile)
2. **Browser language** (from `Accept-Language` header or `navigator.language`)
3. **Default fallback** (English)

**Persistence**:
```typescript
// Save user preference
localStorage.setItem('preferred-language', 'es');

// On app initialization
const savedLanguage = localStorage.getItem('preferred-language');
if (savedLanguage) {
  i18n.changeLanguage(savedLanguage);
}

// Future: Save to user profile in backend
async function saveLanguagePreference(userId: string, language: string) {
  await fetch(`/api/v1/users/${userId}/preferences`, {
    method: 'PATCH',
    body: JSON.stringify({ language })
  });
}
```

### Testing Internationalization

**Test Checklist**:
- [ ] All UI screens tested in all supported languages
- [ ] Text does not overflow or wrap unexpectedly
- [ ] Dates and numbers display correctly for each locale
- [ ] Language switching works without page refresh
- [ ] API errors display translated messages
- [ ] Missing translation keys fall back to English

**Automated Tests**:
```typescript
describe('Internationalization', () => {
  it('should render in Spanish', () => {
    i18n.changeLanguage('es');
    const { getByText } = render(<GoalForm />);
    expect(getByText('Guardar')).toBeInTheDocument(); // "Save" in Spanish
  });
  
  it('should handle missing translation keys', () => {
    const { getByText } = render(<SomeComponent />);
    // Should fall back to English if key missing
  });
  
  it('should format dates according to locale', () => {
    i18n.changeLanguage('fr');
    const date = new Date('2025-11-05');
    const formatted = date.toLocaleDateString('fr');
    expect(formatted).toBe('05/11/2025'); // French date format
  });
});
```

### Why This Matters

- **Global Reach**: Support users in their native language
- **User Experience**: Users feel more comfortable in their language
- **Accessibility**: Language barriers removed for non-English speakers
- **Professional**: Shows attention to detail and user diversity
- **Scalability**: Easy to add more languages in the future
- **Consistency**: All messages localized, no mix of languages

---

## Principle 7: Comprehensive Testing

### Statement
**All code must be thoroughly tested. Maintain minimum 80% code coverage with a balanced test pyramid.**

### Definition
Testing is not optional. Every feature, bug fix, and refactoring must include appropriate tests. Tests serve as executable documentation, regression prevention, and design feedback.

### Test Pyramid

```
        /\
       /  \      E2E Tests (~10%)
      /____\     - Critical user journeys
     /      \    - Full system integration
    /________\   
   /          \  Integration Tests (~30%)
  /            \ - API endpoint tests
 /______________\- Contract tests
/                \
/                 \ Unit Tests (~60%)
/___________________\- Business logic
                      - Utility functions
                      - Component behavior
```

### Coverage Targets

#### Backend (cpr-api)
- **Minimum**: 80% overall code coverage
- **Critical Paths**: 100% coverage required for:
  - Authentication and authorization logic
  - Data validation
  - Business rules enforcement
  - Error handling

**Current State**: (To be measured and tracked)

#### Frontend (cpr-ui)
- **Minimum**: 80% overall code coverage
- **Critical Paths**: 100% coverage required for:
  - Form validation
  - State management logic
  - API integration layers
  - Authentication flows

**Current State**: (To be measured and tracked)

**Tool**: Vitest (based on `vitest.config.ts` in cpr-ui)

### Testing Strategies by Layer

#### 1. Unit Tests

**Purpose**: Test individual functions, classes, and components in isolation.

**Backend Example** (`cpr-api`):
```csharp
public class GoalServiceTests
{
    [Fact]
    public async Task CreateGoalAsync_ValidData_ReturnsGoalDto()
    {
        // Arrange
        var mockContext = CreateMockDbContext();
        var service = new GoalService(mockContext);
        var dto = new CreateGoalDto { Title = "Test Goal", Priority = 5 };
        var ownerId = Guid.NewGuid();

        // Act
        var result = await service.CreateGoalAsync(ownerId, dto);

        // Assert
        Assert.NotNull(result);
        Assert.Equal("Test Goal", result.Title);
        Assert.Equal(5, result.Priority);
    }
}
```

**Frontend Example** (`cpr-ui`):
```typescript
describe('GoalForm', () => {
  it('should validate required fields', () => {
    // Arrange
    const { getByRole, getByText } = render(<GoalForm />);
    
    // Act
    fireEvent.click(getByRole('button', { name: /submit/i }));
    
    // Assert
    expect(getByText('Title is required')).toBeInTheDocument();
  });
});
```

#### 2. Integration Tests

**Purpose**: Test interactions between components, database, and external services.

**Backend Example** (`cpr-api/tests/CPR.IntegrationTests/`):
```csharp
public class GoalsIntegrationTests : IClassFixture<CustomWebApplicationFactory>
{
    [Fact]
    public async Task CreateGoal_IntegrationFlow_Success()
    {
        // Arrange
        var client = CreateAuthenticatedClient();
        var createDto = new { title = "Integration Test Goal", priority = 5 };

        // Act
        var createResponse = await client.PostAsJsonAsync("/api/goals", createDto);
        var goalDto = await createResponse.Content.ReadFromJsonAsync<GoalDto>();
        var getResponse = await client.GetAsync($"/api/goals/{goalDto.Id}");

        // Assert
        Assert.Equal(HttpStatusCode.Created, createResponse.StatusCode);
        Assert.Equal(HttpStatusCode.OK, getResponse.StatusCode);
    }
}
```

#### 3. Contract Tests

**Purpose**: Validate API responses match OpenAPI specifications.

**Location**: `cpr-api/tests/CPR.ContractTests/`

**Pattern** (already implemented):
```csharp
[Fact]
public async Task GetGoals_ReturnsValidSchema()
{
    // Arrange
    var client = CreateAuthenticatedClient();

    // Act
    var response = await client.GetAsync("/api/me/goals");
    var json = await response.Content.ReadAsStringAsync();

    // Assert
    Assert.Equal(HttpStatusCode.OK, response.StatusCode);
    SchemaValidator.ValidateJson("goals.schema.json", json);
}
```

**Schema Files**: `cpr-api/tests/CPR.ContractTests/schemas/*.schema.json`

#### 4. End-to-End Tests

**Purpose**: Test complete user workflows across UI and API.

**Tool** (to be determined): Playwright, Cypress, or Selenium

**Example**:
```typescript
test('User can create and view goal', async ({ page }) => {
  // Login
  await page.goto('/login');
  await page.fill('[name="email"]', 'test@example.com');
  await page.fill('[name="password"]', 'password123');
  await page.click('button[type="submit"]');

  // Create goal
  await page.goto('/goals/new');
  await page.fill('[name="title"]', 'E2E Test Goal');
  await page.click('button[type="submit"]');

  // Verify goal appears
  await expect(page.locator('text=E2E Test Goal')).toBeVisible();
});
```

### Test Data Management

**Strategies**:
- **Unit Tests**: Mock data, test fixtures
- **Integration Tests**: Database seeding (see `cpr-api/tests/CPR.SeedTestData/`)
- **Contract Tests**: Minimal real data, cleanup after each test
- **E2E Tests**: Dedicated test database, reset between runs

**Cleanup Pattern** (from `GoalsContractTests.cs`):
```csharp
private async Task CleanupGoalsAsync()
{
    await using var scope = _factory.Services.CreateAsyncScope();
    var context = scope.ServiceProvider.GetRequiredService<CprDbContext>();
    
    await context.Goals
        .Where(g => g.EmployeeId.ToString() == TestEmployeeId)
        .ExecuteDeleteAsync();
        
    await context.SaveChangesAsync();
}
```

### Test Quality Standards

**Good Tests Are**:
- ✅ **Fast**: Run quickly (unit tests < 100ms, integration < 1s)
- ✅ **Isolated**: No dependencies on other tests
- ✅ **Repeatable**: Same result every time
- ✅ **Self-validating**: Clear pass/fail, no manual inspection
- ✅ **Timely**: Written with or before implementation

**Test Naming Convention**:
```csharp
// Pattern: MethodName_Scenario_ExpectedBehavior
[Fact]
public async Task CreateGoalAsync_InvalidPriority_ThrowsArgumentException()

[Fact]
public async Task GetGoalByIdAsync_NonExistentId_ReturnsNull()

[Fact]
public async Task UpdateGoalAsync_ValidData_UpdatesSuccessfully()
```

### Running Tests

**Backend** (`cpr-api`):
```bash
# Run all tests
dotnet test

# Run specific test project
dotnet test tests/CPR.UnitTests/

# Run with coverage
dotnet test /p:CollectCoverage=true
```

**Frontend** (`cpr-ui`):
```bash
# Run all tests (uses MSW mocks)
yarn test

# Run with coverage
yarn test:coverage

# Run with UI
yarn test:ui
```

**Note**: Frontend tests automatically use MSW for API mocking. No backend required.

### CI/CD Integration

**Pre-Merge Requirements**:
- [ ] All tests pass
- [ ] Coverage meets threshold (80%)
- [ ] No skipped tests without justification
- [ ] Contract tests validate API compliance

**Coverage Reporting**:
- Generate coverage reports on every PR
- Track coverage trends over time
- Block merge if coverage decreases

### Enforcement

**Pull Request Checklist**:
- [ ] New features include unit tests
- [ ] API changes include contract tests
- [ ] Bug fixes include regression tests
- [ ] Coverage threshold maintained or improved

**Review Criteria**:
- Tests actually test the functionality (not just placeholders)
- Edge cases and error conditions covered
- Tests are maintainable and readable

### Why This Matters

- **Confidence**: Deploy without fear of breaking things
- **Documentation**: Tests show how code is meant to be used
- **Regression Prevention**: Bugs stay fixed
- **Design Feedback**: Hard-to-test code is often poorly designed
- **Refactoring Safety**: Tests catch unintended changes

---

## Principle Priority and Conflict Resolution

When principles conflict, follow this priority order:

1. **Specification-First Development** - Document first, always
2. **API Contract Consistency** - Don't break the integration
3. **API Standards & Security** - Security is non-negotiable
4. **Type Safety Everywhere** - Catch errors early
5. **Offline Mode** - Mock APIs for fast, reliable development
6. **Internationalization** - Support all users in their language
7. **Comprehensive Testing** - Prove it works
8. **Performance-First React** - Optimize for user experience
9. **Strict Naming Conventions** - Maintain consistency and clarity
10. **Security & Data Privacy** - Protect user data and comply with regulations
11. **Database Design Standards** - Ensure data integrity and auditability

### Example Conflicts

**Scenario**: Urgent bug fix needed in production.

**Question**: Can we skip the specification to fix faster?

**Resolution**:
- **If bug affects API contract**: NO - write lightweight bug spec in `cpr-meta/bugfixes/`, then fix
- **If internal bug only**: YES - fix first, document in PR, add regression test
- **If security critical**: FIX IMMEDIATELY - document retroactively within 24 hours

**Scenario**: Third-party library requires `any` type.

**Question**: Can we violate type safety?

**Resolution**:
- YES - but document why, add runtime validation, create issue to replace
- Isolate the `any` usage to a thin wrapper layer
- Rest of codebase stays strictly typed

---

## Living Principles

These principles are not set in stone. They should evolve with the project.

**How to Propose Changes**:
1. Create issue in `cpr-meta` repository with label `constitution-amendment`
2. Describe proposed change and rationale
3. Discuss with team
4. Create PR with proposed changes to this document
5. Require approval from 2+ tech leads
6. Update version and last updated date
7. Communicate changes to all team members

**Last Reviewed**: November 5, 2025  
**Next Review**: February 5, 2026 (quarterly)

---

## Principle 8: Performance-First React Development

### Statement
**All React components must be optimized for performance. Avoid inline functions, inline styles, and unnecessary re-renders through proper use of `useCallback`, `useMemo`, and memoization patterns.**

### Definition

React performance issues compound quickly in large applications. Every component that re-renders unnecessarily causes its children to re-render as well. The CPR project enforces strict performance patterns:

- **No inline functions**: Event handlers must be wrapped in `useCallback`
- **No inline styles**: Style objects must be created with `useMemo` or factory functions
- **Stable references**: Props passed to children must maintain referential equality across renders
- **Memoization**: Expensive computations must use `useMemo`

### Core Requirements

#### 1. Event Handler Pattern

**Always use `useCallback` for event handlers**:

```typescript
// ❌ WRONG: Inline function creates new reference on every render
function UserCard({ user, onUpdate }: TUserCardProps) {
  return (
    <button onClick={() => onUpdate(user.id)}>
      Update
    </button>
  );
}

// ❌ WRONG: Function defined in render creates new reference
function UserCard({ user, onUpdate }: TUserCardProps) {
  const handleClick = () => {
    onUpdate(user.id);
  };
  
  return <button onClick={handleClick}>Update</button>;
}

// ✅ CORRECT: useCallback ensures stable reference
function UserCard({ user, onUpdate }: TUserCardProps) {
  const handleClick = useCallback(() => {
    onUpdate(user.id);
  }, [user.id, onUpdate]);
  
  return <button onClick={handleClick}>Update</button>;
}
```

**Event handler naming convention**:
```typescript
// Pattern: handle[ActionName]
const handleSubmit = useCallback(() => { ... }, [deps]);
const handleCancel = useCallback(() => { ... }, [deps]);
const handleInputChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => { ... }, [deps]);
const handleDeleteClick = useCallback(() => { ... }, [deps]);
```

#### 2. Style Object Pattern

**Never use inline styles or inline `sx` props**:

```typescript
// ❌ WRONG: Inline sx creates new object on every render
<Box sx={{ padding: 2, marginTop: 1 }}>Content</Box>

// ❌ WRONG: Inline style creates new object
<div style={{ display: 'flex', gap: '8px' }}>Content</div>

// ✅ CORRECT: Factory function with useMemo
type TUserCardStyleProps = {
  isActive: boolean;
  theme: Theme;
};

function getStyles({ isActive, theme }: TUserCardStyleProps) {
  return {
    container: {
      padding: theme.spacing(2),
      backgroundColor: isActive ? theme.palette.primary.light : theme.palette.grey[100],
      borderRadius: theme.shape.borderRadius
    },
    title: {
      fontSize: theme.typography.h6.fontSize,
      fontWeight: theme.typography.fontWeightBold
    }
  };
}

function UserCard({ user, isActive }: TUserCardProps) {
  const theme = useTheme();
  
  // Memoize styles - only recreate when dependencies change
  const styles = useMemo(
    () => getStyles({ isActive, theme }),
    [isActive, theme]
  );
  
  return (
    <Box sx={styles.container}>
      <Typography sx={styles.title}>{user.name}</Typography>
    </Box>
  );
}
```

**Alternative: Extract to separate file**:
```typescript
// userCard.styles.ts
export function getUserCardStyles(theme: Theme, isActive: boolean) {
  return {
    container: {
      padding: theme.spacing(2),
      backgroundColor: isActive ? theme.palette.primary.light : theme.palette.grey[100]
    }
  };
}

// UserCard.tsx
import { getUserCardStyles } from './userCard.styles';

function UserCard({ user, isActive }: TUserCardProps) {
  const theme = useTheme();
  const styles = useMemo(
    () => getUserCardStyles(theme, isActive),
    [theme, isActive]
  );
  
  return <Box sx={styles.container}>{/* ... */}</Box>;
}
```

#### 3. Expensive Computations

**Use `useMemo` for expensive calculations**:

```typescript
function GoalList({ goals, filters }: TGoalListProps) {
  // ❌ WRONG: Runs on every render
  const filteredGoals = goals.filter(goal => 
    goal.status === filters.status &&
    goal.title.toLowerCase().includes(filters.search.toLowerCase())
  );
  
  // ✅ CORRECT: Only recalculates when dependencies change
  const filteredGoals = useMemo(() => {
    return goals.filter(goal => 
      goal.status === filters.status &&
      goal.title.toLowerCase().includes(filters.search.toLowerCase())
    );
  }, [goals, filters.status, filters.search]);
  
  return <>{filteredGoals.map(goal => <GoalCard key={goal.id} goal={goal} />)}</>;
}
```

#### 4. Component Memoization

**Use `React.memo` for expensive components**:

```typescript
// Memoize component to prevent unnecessary re-renders
export const GoalCard = React.memo(function GoalCard({ goal, onUpdate }: TGoalCardProps) {
  const handleUpdate = useCallback(() => {
    onUpdate(goal.id);
  }, [goal.id, onUpdate]);
  
  return (
    <Card>
      <CardContent>
        <Typography>{goal.title}</Typography>
        <Button onClick={handleUpdate}>Update</Button>
      </CardContent>
    </Card>
  );
});

// Custom comparison function for complex props
export const GoalCard = React.memo(
  function GoalCard({ goal, onUpdate }: TGoalCardProps) {
    // ... component implementation
  },
  (prevProps, nextProps) => {
    // Only re-render if goal ID or title changed
    return prevProps.goal.id === nextProps.goal.id &&
           prevProps.goal.title === nextProps.goal.title;
  }
);
```

#### 5. Stable Dependencies

**Ensure callbacks passed as props are stable**:

```typescript
function ParentComponent() {
  const [data, setData] = useState<TData[]>([]);
  
  // ❌ WRONG: New function on every render
  const handleUpdate = (id: string) => {
    setData(prev => prev.map(item => 
      item.id === id ? { ...item, updated: true } : item
    ));
  };
  
  // ✅ CORRECT: Stable reference
  const handleUpdate = useCallback((id: string) => {
    setData(prev => prev.map(item => 
      item.id === id ? { ...item, updated: true } : item
    ));
  }, []); // No dependencies because we use functional setState
  
  return (
    <>
      {data.map(item => (
        <ChildComponent key={item.id} item={item} onUpdate={handleUpdate} />
      ))}
    </>
  );
}
```

### Enforcement

#### 1. ESLint Rules

```json
// .eslintrc.json
{
  "rules": {
    "@typescript-eslint/no-unused-vars": ["error", { "argsIgnorePattern": "^_" }],
    "react-hooks/rules-of-hooks": "error",
    "react-hooks/exhaustive-deps": "warn",
    "react/jsx-no-bind": ["error", {
      "allowArrowFunctions": false,
      "allowBind": false,
      "allowFunctions": false
    }],
    "react/no-unstable-nested-components": ["error", { "allowAsProps": false }]
  }
}
```

#### 2. Code Review Checklist

Performance Review Checklist:
- [ ] No inline arrow functions in JSX (`onClick={() => ...}`)
- [ ] All event handlers use `useCallback` with correct dependencies
- [ ] No inline `sx` props with object literals
- [ ] Style objects created with `useMemo` or factory functions
- [ ] Expensive computations wrapped in `useMemo`
- [ ] Component memoized with `React.memo` if it re-renders frequently
- [ ] Callbacks passed to children are stable (wrapped in `useCallback`)
- [ ] Dependencies arrays are complete and accurate

#### 3. Performance Testing

```typescript
// Use React DevTools Profiler in development
import { Profiler } from 'react';

function onRenderCallback(
  id: string,
  phase: 'mount' | 'update',
  actualDuration: number,
  baseDuration: number,
  startTime: number,
  commitTime: number
) {
  if (import.meta.env.DEV) {
    console.log(`${id} (${phase}) took ${actualDuration}ms`);
  }
}

function App() {
  return (
    <Profiler id="App" onRender={onRenderCallback}>
      <YourComponents />
    </Profiler>
  );
}
```

### Real-World Example

```typescript
// goalDashboard.styles.ts
export function getDashboardStyles(theme: Theme, isLoading: boolean) {
  return {
    container: {
      padding: theme.spacing(3),
      opacity: isLoading ? 0.6 : 1,
      transition: theme.transitions.create('opacity')
    },
    header: {
      marginBottom: theme.spacing(2),
      display: 'flex',
      justifyContent: 'space-between',
      alignItems: 'center'
    },
    grid: {
      display: 'grid',
      gridTemplateColumns: 'repeat(auto-fill, minmax(300px, 1fr))',
      gap: theme.spacing(2)
    }
  };
}

// GoalDashboard.tsx
import React, { useMemo, useCallback, useState } from 'react';
import { Box, Typography } from '@mui/material';
import { useTheme } from '@mui/material/styles';
import { getDashboardStyles } from './goalDashboard.styles';
import { GoalCard } from './GoalCard';
import type { TGoal } from '../types';

type TGoalDashboardProps = {
  goals: TGoal[];
  onGoalUpdate: (goalId: string) => void;
  onGoalDelete: (goalId: string) => void;
};

export const GoalDashboard = React.memo(function GoalDashboard({
  goals,
  onGoalUpdate,
  onGoalDelete
}: TGoalDashboardProps) {
  const theme = useTheme();
  const [isLoading, setIsLoading] = useState(false);
  
  // Memoize styles
  const styles = useMemo(
    () => getDashboardStyles(theme, isLoading),
    [theme, isLoading]
  );
  
  // Stable event handlers
  const handleUpdate = useCallback((goalId: string) => {
    setIsLoading(true);
    onGoalUpdate(goalId);
    // onGoalUpdate should handle loading state completion
  }, [onGoalUpdate]);
  
  const handleDelete = useCallback((goalId: string) => {
    setIsLoading(true);
    onGoalDelete(goalId);
  }, [onGoalDelete]);
  
  // Memoize sorted goals
  const sortedGoals = useMemo(() => {
    return [...goals].sort((a, b) => 
      new Date(b.createdAt).getTime() - new Date(a.createdAt).getTime()
    );
  }, [goals]);
  
  return (
    <Box sx={styles.container}>
      <Box sx={styles.header}>
        <Typography variant="h4">Goals Dashboard</Typography>
      </Box>
      
      <Box sx={styles.grid}>
        {sortedGoals.map(goal => (
          <GoalCard
            key={goal.id}
            goal={goal}
            onUpdate={handleUpdate}
            onDelete={handleDelete}
          />
        ))}
      </Box>
    </Box>
  );
});
```

### Why This Matters

- **Scalability**: Performance patterns prevent slowdowns as app grows
- **User Experience**: Fast, responsive UI keeps users engaged
- **Developer Experience**: Consistent patterns make code predictable
- **Debugging**: React DevTools can identify expensive renders easily
- **Maintainability**: Performance optimizations built in from the start

---

## Principle 9: Strict Naming Conventions

### Statement
**All code must follow strict, predictable naming conventions. Interfaces use `I` prefix, types use `T` prefix, enums use `E` prefix. Files use camelCase, components use PascalCase. Never use `any` type.**

### Definition

Naming conventions eliminate ambiguity and make code self-documenting. In the CPR project:

- **Interfaces**: Always prefix with `I` (e.g., `IUserService`, `IGoal`)
- **Types**: Always prefix with `T` (e.g., `TUser`, `TApiResponse`)
- **Enums**: Always prefix with `E` (e.g., `EUserRole`, `EThemeMode`)
- **Files**: Use camelCase (e.g., `userService.ts`, `goalMapper.ts`)
- **Components**: Use PascalCase (e.g., `LoginForm.tsx`, `GoalCard.tsx`)
- **Event Handlers**: Use `handle[ActionName]` pattern (e.g., `handleSubmit`, `handleDeleteClick`)
- **No `any` type**: Use `unknown` with type guards or explicit types

### Core Requirements

#### 1. TypeScript Naming

**Interfaces** (structural contracts):
```typescript
// ✅ CORRECT: I prefix
interface IUserService {
  getUser(id: string): Promise<IUser>;
  updateUser(id: string, data: Partial<IUser>): Promise<IUser>;
}

interface IGoal {
  id: string;
  title: string;
  createdAt: string;
}

interface IApiError {
  message: string;
  code: number;
}

// ❌ WRONG: No I prefix
interface UserService { ... }
interface Goal { ... }
interface ApiError { ... }
```

**Types** (aliases, unions, utility types):
```typescript
// ✅ CORRECT: T prefix
type TUser = {
  id: string;
  name: string;
  email: string;
};

type TApiResponse<T> = {
  data: T;
  error?: string;
};

type TGoalStatus = 'active' | 'completed' | 'archived';

type TUserRole = 'employee' | 'manager' | 'administrator';

// Component prop types
type TGoalCardProps = {
  goal: IGoal;
  onUpdate: (id: string) => void;
  onDelete: (id: string) => void;
};

// ❌ WRONG: No T prefix
type User = { ... };
type ApiResponse<T> = { ... };
type GoalStatus = 'active' | 'completed';
```

**Enums** (named constants):
```typescript
// ✅ CORRECT: E prefix
enum EUserRole {
  Employee = 'employee',
  Manager = 'manager',
  Administrator = 'administrator'
}

enum EThemeMode {
  Light = 'light',
  Dark = 'dark',
  System = 'system'
}

enum EHttpStatus {
  Ok = 200,
  Created = 201,
  BadRequest = 400,
  NotFound = 404
}

// ❌ WRONG: No E prefix
enum UserRole { ... }
enum ThemeMode { ... }
```

#### 2. File Naming

**TypeScript files** (camelCase):
```
✅ CORRECT:
src/services/userService.ts
src/mappers/goalMapper.ts
src/utils/dateFormatter.ts
src/hooks/useAuth.ts
src/config/apiConfig.ts

❌ WRONG:
src/services/UserService.ts
src/services/user-service.ts
src/mappers/GoalMapper.ts
```

**React components** (PascalCase):
```
✅ CORRECT:
src/components/LoginForm.tsx
src/components/GoalCard.tsx
src/components/UserProfile.tsx
src/pages/Dashboard.tsx

❌ WRONG:
src/components/loginForm.tsx
src/components/goal-card.tsx
src/components/user_profile.tsx
```

**Test files** (match source file name):
```
✅ CORRECT:
src/services/userService.ts
  ↓
src/services/userService.test.ts

src/components/GoalCard.tsx
  ↓
src/components/GoalCard.test.tsx

❌ WRONG:
UserService.test.ts
goalCard.spec.tsx
```

#### 3. Function and Variable Naming

**Functions and variables** (camelCase):
```typescript
// ✅ CORRECT
const getUserById = (id: string) => { ... };
const formatDate = (date: Date) => { ... };
const isValidEmail = (email: string) => { ... };

let currentUser: IUser | null = null;
const maxRetries = 3;
const apiBaseUrl = 'https://api.example.com';

// ❌ WRONG
const GetUserById = (id: string) => { ... }; // PascalCase (reserved for components/classes)
const format_date = (date: Date) => { ... }; // snake_case (Python convention)
const IsValidEmail = (email: string) => { ... };
```

**Event handlers** (`handle[ActionName]`):
```typescript
// ✅ CORRECT: handle prefix
const handleSubmit = useCallback(() => { ... }, []);
const handleCancel = useCallback(() => { ... }, []);
const handleInputChange = useCallback((e: React.ChangeEvent<HTMLInputElement>) => { ... }, []);
const handleDeleteClick = useCallback(() => { ... }, []);
const handleUserSelect = useCallback((userId: string) => { ... }, []);

// ❌ WRONG: No handle prefix or inconsistent naming
const onSubmit = useCallback(() => { ... }, []); // on prefix (use for props, not handlers)
const submit = useCallback(() => { ... }, []); // No prefix
const clickDelete = useCallback(() => { ... }, []); // Wrong order
```

**Component props** (camelCase for regular props, `on` prefix for callbacks):
```typescript
// ✅ CORRECT
type TGoalCardProps = {
  goal: IGoal;
  isActive: boolean;
  showActions: boolean;
  onUpdate: (id: string) => void;    // on prefix for callbacks
  onDelete: (id: string) => void;
  onSelect?: (id: string) => void;
};

// ❌ WRONG
type TGoalCardProps = {
  Goal: IGoal;              // PascalCase
  is_active: boolean;       // snake_case
  updateHandler: () => void; // handler suffix instead of on prefix
};
```

#### 4. The `any` Type Ban

**Never use `any`**. Use `unknown` with type guards:

```typescript
// ❌ WRONG: any type
function processApiResponse(response: any): IUser {
  return {
    id: response.id,
    name: response.name,
    email: response.email
  };
}

// ✅ CORRECT: unknown with type guard
function isUserResponse(value: unknown): value is Record<string, unknown> {
  return (
    typeof value === 'object' &&
    value !== null &&
    'id' in value &&
    'name' in value &&
    'email' in value &&
    typeof (value as Record<string, unknown>).id === 'string' &&
    typeof (value as Record<string, unknown>).name === 'string' &&
    typeof (value as Record<string, unknown>).email === 'string'
  );
}

function processApiResponse(response: unknown): IUser {
  if (!isUserResponse(response)) {
    throw new Error('Invalid user response format');
  }
  
  return {
    id: response.id as string,
    name: response.name as string,
    email: response.email as string
  };
}
```

**Use explicit types for records**:
```typescript
// ❌ WRONG: any in Record
const errorMap: Record<string, any> = { ... };

// ✅ CORRECT: explicit type
const errorMap: Record<string, IApiError> = { ... };

// ✅ CORRECT: unknown for truly dynamic data
const dynamicData: Record<string, unknown> = JSON.parse(jsonString);
```

### Comprehensive Naming Table

| Element | Convention | Example | Wrong |
|---------|-----------|---------|-------|
| Interface | `I` prefix, PascalCase | `IUserService`, `IGoal` | `UserService`, `Goal` |
| Type Alias | `T` prefix, PascalCase | `TUser`, `TApiResponse<T>` | `User`, `ApiResponse` |
| Enum | `E` prefix, PascalCase | `EUserRole`, `EThemeMode` | `UserRole`, `THEME_MODE` |
| Component File | PascalCase.tsx | `LoginForm.tsx`, `GoalCard.tsx` | `loginForm.tsx`, `goal-card.tsx` |
| Service File | camelCase.ts | `userService.ts`, `authService.ts` | `UserService.ts`, `auth_service.ts` |
| Component Props Type | `T[ComponentName]Props` | `TGoalCardProps`, `TUserProfileProps` | `GoalCardPropsType`, `IGoalCardProps` |
| Event Handler | `handle[ActionName]` | `handleSubmit`, `handleDeleteClick` | `onSubmit`, `clickDelete` |
| Callback Prop | `on[ActionName]` | `onUpdate`, `onDelete`, `onSelect` | `updateHandler`, `handleUpdate` |
| Boolean Variable | `is/has/should` prefix | `isActive`, `hasAccess`, `shouldRender` | `active`, `access`, `render` |
| Array Variable | Plural noun | `users`, `goals`, `errors` | `userList`, `goalArray` |
| Function | Verb + camelCase | `getUser`, `formatDate`, `validateEmail` | `user`, `date`, `email` |
| Constant | UPPER_SNAKE_CASE | `MAX_RETRIES`, `API_BASE_URL` | `maxRetries`, `apiBaseUrl` |

### Enforcement

#### 1. ESLint Rules

```json
// .eslintrc.json
{
  "rules": {
    "@typescript-eslint/no-explicit-any": "error",
    "@typescript-eslint/naming-convention": [
      "error",
      {
        "selector": "interface",
        "format": ["PascalCase"],
        "prefix": ["I"]
      },
      {
        "selector": "typeAlias",
        "format": ["PascalCase"],
        "prefix": ["T"]
      },
      {
        "selector": "enum",
        "format": ["PascalCase"],
        "prefix": ["E"]
      }
    ]
  }
}
```

#### 2. Code Review Checklist

Naming Review Checklist:
- [ ] All interfaces have `I` prefix
- [ ] All type aliases have `T` prefix
- [ ] All enums have `E` prefix
- [ ] Component files use PascalCase
- [ ] Service/util files use camelCase
- [ ] Event handlers use `handle[ActionName]` pattern
- [ ] Callback props use `on[ActionName]` pattern
- [ ] No `any` types (use `unknown` with type guards)
- [ ] Boolean variables use `is/has/should` prefix
- [ ] Constants use UPPER_SNAKE_CASE

#### 3. TypeScript Compiler

```json
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "strictFunctionTypes": true,
    "strictPropertyInitialization": true
  }
}
```

### Why This Matters

- **Instant Recognition**: Know at a glance whether something is an interface, type, or enum
- **Autocomplete**: IDE suggestions are clearer when prefixes differentiate categories
- **Type Safety**: Banning `any` forces proper type definitions
- **Consistency**: Every developer follows the same patterns
- **Refactoring**: Find all usages easily with consistent naming
- **Onboarding**: New developers learn conventions quickly

---

## Principle 10: Security & Data Privacy

### Statement
**All sensitive data must be protected. Never commit secrets to source control. Implement RBAC for all operations. Redact PII from logs. Follow Azure security best practices.**

### Definition

Security is non-negotiable. The CPR project handles employee career data, which includes personally identifiable information (PII). Every component must:

- **Protect secrets**: Use Azure Key Vault, never commit credentials
- **Implement RBAC**: Role-based access control for all operations
- **Redact PII**: Never log sensitive data
- **Audit everything**: Track who accessed what and when
- **Soft delete**: Never hard-delete user data (retention policies)
- **Encrypt in transit**: HTTPS everywhere
- **Encrypt at rest**: Azure SQL encryption, Azure Storage encryption

### Core Requirements

#### 1. Secrets Management

**Never commit secrets** to Git:

```bash
# .gitignore
.env
.env.*
appsettings.Development.json
secrets.json
*.pfx
*.key
```

**Use Azure Key Vault**:

```csharp
// Program.cs - Load secrets from Key Vault
var builder = WebApplication.CreateBuilder(args);

// Add Azure Key Vault
var keyVaultUrl = builder.Configuration["KeyVaultUrl"];
if (!string.IsNullOrEmpty(keyVaultUrl))
{
    builder.Configuration.AddAzureKeyVault(
        new Uri(keyVaultUrl),
        new DefaultAzureCredential());
}

// Access secrets
var connectionString = builder.Configuration["DatabaseConnectionString"]; // From Key Vault
var apiKey = builder.Configuration["ExternalApiKey"]; // From Key Vault
```

**Local development**:
```json
// appsettings.Development.json (NOT committed)
{
  "DatabaseConnectionString": "Server=localhost;Database=cpr;...",
  "KeyVaultUrl": "https://cpr-dev-kv.vault.azure.net/"
}
```

**CI/CD**:
```yaml
# Azure Pipeline - inject secrets
- task: AzureKeyVault@2
  inputs:
    azureSubscription: 'CPR-Production'
    KeyVaultName: 'cpr-prod-kv'
    SecretsFilter: '*'
```

#### 2. Role-Based Access Control (RBAC)

**Define roles clearly**:
```csharp
public enum EUserRole
{
    Employee = 0,       // Can view own data only
    PeopleManager = 1,  // Can view direct reports
    SolutionOwner = 2,  // Can view all employees
    Director = 3,       // Can view organization data
    Administrator = 4   // Full system access
}
```

**Enforce with policies**:
```csharp
// Configure authorization policies
builder.Services.AddAuthorization(options =>
{
    options.AddPolicy("CanViewGoals", policy =>
        policy.RequireRole("Employee", "PeopleManager", "SolutionOwner", "Director", "Administrator"));
    
    options.AddPolicy("CanManageUsers", policy =>
        policy.RequireRole("Administrator", "Director"));
    
    options.AddPolicy("CanViewAllGoals", policy =>
        policy.RequireRole("SolutionOwner", "Director", "Administrator"));
});

// Apply to controllers
[Authorize(Policy = "CanViewGoals")]
[HttpGet("{id}")]
public async Task<ActionResult<GoalDto>> GetGoal(string id)
{
    var userId = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
    
    // Additional check: users can only view their own goals unless they're managers
    var goal = await _goalService.GetByIdAsync(id);
    if (goal.UserId != userId && !User.IsInRole("SolutionOwner"))
    {
        return Forbid();
    }
    
    return Ok(goal);
}
```

**Frontend RBAC**:
```typescript
// useAuth.ts
export function useAuth() {
  const { user } = useAuthContext();
  
  const hasRole = useCallback((role: EUserRole) => {
    return user?.roles.includes(role) ?? false;
  }, [user]);
  
  const canViewAllGoals = useMemo(() => {
    return hasRole(EUserRole.SolutionOwner) ||
           hasRole(EUserRole.Director) ||
           hasRole(EUserRole.Administrator);
  }, [hasRole]);
  
  return { user, hasRole, canViewAllGoals };
}

// Component usage
function GoalList() {
  const { canViewAllGoals } = useAuth();
  
  return (
    <>
      {canViewAllGoals && <AdminControls />}
      <GoalGrid />
    </>
  );
}
```

#### 3. PII Redaction

**Never log sensitive data**:

```csharp
// ❌ WRONG: Logs PII
_logger.LogInformation("User {UserId} with email {Email} logged in", user.Id, user.Email);

// ✅ CORRECT: Redact PII
_logger.LogInformation("User {UserId} logged in", user.Id);

// ✅ CORRECT: Hash email for correlation
var emailHash = ComputeHash(user.Email);
_logger.LogInformation("User {UserId} ({EmailHash}) logged in", user.Id, emailHash);
```

**Redaction utility**:
```csharp
public class PiiRedactor
{
    public static string RedactEmail(string email)
    {
        if (string.IsNullOrEmpty(email)) return "[REDACTED]";
        
        var parts = email.Split('@');
        if (parts.Length != 2) return "[REDACTED]";
        
        // Show first char + *** + domain
        return $"{parts[0][0]}***@{parts[1]}";
    }
    
    public static string ComputeHash(string input)
    {
        using var sha256 = SHA256.Create();
        var bytes = Encoding.UTF8.GetBytes(input);
        var hash = sha256.ComputeHash(bytes);
        return Convert.ToBase64String(hash).Substring(0, 8);
    }
}
```

#### 4. Audit Trail

**Track all data access**:
```sql
CREATE TABLE audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  action VARCHAR(50) NOT NULL,  -- 'CREATE', 'READ', 'UPDATE', 'DELETE'
  resource_type VARCHAR(50) NOT NULL,  -- 'Goal', 'User', 'Review'
  resource_id UUID NOT NULL,
  timestamp TIMESTAMP NOT NULL DEFAULT NOW(),
  ip_address VARCHAR(45),
  user_agent TEXT,
  details JSONB
);
```

```csharp
public async Task LogAuditEvent(
    string userId,
    string action,
    string resourceType,
    string resourceId,
    string? details = null)
{
    var auditLog = new AuditLog
    {
        UserId = userId,
        Action = action,
        ResourceType = resourceType,
        ResourceId = resourceId,
        Timestamp = DateTime.UtcNow,
        IpAddress = _httpContext.Connection.RemoteIpAddress?.ToString(),
        UserAgent = _httpContext.Request.Headers["User-Agent"].ToString(),
        Details = details
    };
    
    await _context.AuditLogs.AddAsync(auditLog);
    await _context.SaveChangesAsync();
}
```

#### 5. Soft Delete

**Never hard-delete user data**:
```sql
-- All tables must have deleted_at column
CREATE TABLE goals (
  id UUID PRIMARY KEY,
  title VARCHAR(200),
  user_id UUID NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  deleted_at TIMESTAMP NULL,  -- NULL = not deleted
  deleted_by UUID NULL
);

-- Filter out deleted records by default
SELECT * FROM goals WHERE deleted_at IS NULL;

-- Soft delete
UPDATE goals SET deleted_at = NOW(), deleted_by = 'user-id' WHERE id = 'goal-id';

-- Compliance: Hard delete after retention period (e.g., 7 years)
DELETE FROM goals WHERE deleted_at < NOW() - INTERVAL '7 years';
```

```csharp
public class Goal
{
    public string Id { get; set; }
    public string Title { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public DateTime? DeletedAt { get; set; }  // Soft delete
    public string? DeletedBy { get; set; }
}

// Global query filter
modelBuilder.Entity<Goal>()
    .HasQueryFilter(g => g.DeletedAt == null);

// Soft delete
public async Task SoftDeleteGoalAsync(string id, string deletedBy)
{
    var goal = await _context.Goals.FindAsync(id);
    if (goal == null) throw new NotFoundException();
    
    goal.DeletedAt = DateTime.UtcNow;
    goal.DeletedBy = deletedBy;
    
    await _context.SaveChangesAsync();
    await _auditService.LogAuditEvent(deletedBy, "DELETE", "Goal", id);
}
```

### Enforcement

#### 1. Security Scanning

```yaml
# GitHub Actions / Azure Pipeline
- name: Run security scan
  run: |
    dotnet tool install --global security-scan
    security-scan --project CPR.Api.csproj --output sarif

- name: Dependency vulnerability scan
  uses: snyk/actions/dotnet@master
  env:
    SNYK_TOKEN: ${{ secrets.SNYK_TOKEN }}
```

#### 2. Code Review Checklist

Security Review Checklist:
- [ ] No secrets committed (check .env, appsettings.json)
- [ ] All secrets loaded from Azure Key Vault
- [ ] RBAC policies applied to all endpoints
- [ ] PII redacted from logs
- [ ] Audit trail logged for data access
- [ ] Soft delete implemented (no hard deletes)
- [ ] Input validation on all API endpoints
- [ ] SQL queries use parameterized statements
- [ ] HTTPS enforced
- [ ] CORS configured correctly

#### 3. Pre-Commit Hooks

```bash
# .git/hooks/pre-commit
#!/bin/sh

# Check for secrets
if git diff --cached | grep -i "password\|secret\|apikey"; then
  echo "ERROR: Potential secret detected!"
  exit 1
fi

# Check for PII logging
if git diff --cached | grep -i "LogInformation.*email\|LogInformation.*phone"; then
  echo "WARNING: Potential PII logging detected!"
  exit 1
fi
```

### Why This Matters

- **Compliance**: GDPR, CCPA, SOC 2 requirements
- **Trust**: Employees trust us with their career data
- **Legal Protection**: Audit trail for compliance audits
- **Recovery**: Soft delete allows data recovery
- **Incident Response**: PII redaction limits breach impact

---

## Principle 11: Database Design Standards

### Statement
**All database tables must use UUID primary keys, include audit columns (created_at, updated_at, deleted_at), implement soft delete semantics, and follow indexing best practices.**

### Definition

Database design impacts performance, data integrity, and compliance. The CPR project enforces strict database standards:

- **UUID Primary Keys**: Globally unique, no auto-increment race conditions
- **Audit Columns**: Track creation, updates, and deletions
- **Soft Delete**: Retention policies require reversible deletes
- **Indexing**: Strategic indexes for query performance
- **Migrations**: All schema changes versioned and tested
- **Naming**: snake_case for tables and columns

### Core Requirements

#### 1. Table Structure Template

**Every table must follow this template**:

```sql
CREATE TABLE table_name (
  -- Primary Key (UUID)
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Business columns
  column_name VARCHAR(255) NOT NULL,
  another_column INTEGER,
  
  -- Foreign Keys (UUID)
  user_id UUID NOT NULL REFERENCES users(id),
  
  -- Audit Columns (required)
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES users(id),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_by UUID NOT NULL REFERENCES users(id),
  deleted_at TIMESTAMP NULL,
  deleted_by UUID NULL REFERENCES users(id),
  
  -- Constraints
  CONSTRAINT uk_table_name_unique_column UNIQUE (unique_column),
  CONSTRAINT ck_table_name_status CHECK (status IN ('active', 'inactive'))
);

-- Indexes
CREATE INDEX idx_table_name_user_id ON table_name(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_table_name_deleted_at ON table_name(deleted_at) WHERE deleted_at IS NOT NULL;
```

#### 2. UUID Primary Keys

**Always use UUIDs, never auto-increment integers**:

```sql
-- ✅ CORRECT: UUID primary key
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title VARCHAR(200) NOT NULL
);

-- ❌ WRONG: Auto-increment integer
CREATE TABLE goals (
  id SERIAL PRIMARY KEY,  -- Sequential, predictable, collision-prone in distributed systems
  title VARCHAR(200) NOT NULL
);
```

**Why UUIDs**:
- Globally unique (no collisions across databases)
- Unpredictable (security: can't guess next ID)
- Distributed-friendly (can generate offline)
- Merge-friendly (no ID conflicts when merging databases)

#### 3. Audit Columns

**Track all changes**:

```sql
-- Required columns for all tables
created_at TIMESTAMP NOT NULL DEFAULT NOW(),
created_by UUID NOT NULL REFERENCES users(id),
updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
updated_by UUID NOT NULL REFERENCES users(id),
deleted_at TIMESTAMP NULL,
deleted_by UUID NULL REFERENCES users(id)
```

**Auto-update trigger**:
```sql
-- Function to auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to all tables
CREATE TRIGGER trg_goals_updated_at
BEFORE UPDATE ON goals
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

#### 4. Soft Delete Semantics

**Implement soft delete for all user data**:

```sql
-- Soft delete: Set deleted_at timestamp
UPDATE goals 
SET deleted_at = NOW(), deleted_by = 'user-id'
WHERE id = 'goal-id';

-- Query only non-deleted records
SELECT * FROM goals WHERE deleted_at IS NULL;

-- Include deleted records (admin view)
SELECT * FROM goals; -- No filter

-- Permanently delete after retention period (compliance job)
DELETE FROM goals 
WHERE deleted_at < NOW() - INTERVAL '7 years';
```

**Entity Framework global filter**:
```csharp
protected override void OnModelCreating(ModelBuilder modelBuilder)
{
    // Global query filter: exclude soft-deleted records
    modelBuilder.Entity<Goal>()
        .HasQueryFilter(g => g.DeletedAt == null);
    
    // To include deleted records explicitly
    var allGoals = await _context.Goals
        .IgnoreQueryFilters()
        .ToListAsync();
}
```

#### 5. Indexing Strategies

**Strategic indexes for performance**:

```sql
-- Index foreign keys (JOIN performance)
CREATE INDEX idx_goals_user_id ON goals(user_id) WHERE deleted_at IS NULL;

-- Index frequently filtered columns
CREATE INDEX idx_goals_status ON goals(status) WHERE deleted_at IS NULL;

-- Composite index for common query patterns
CREATE INDEX idx_goals_user_status ON goals(user_id, status) WHERE deleted_at IS NULL;

-- Partial index for soft-deleted records (audit queries)
CREATE INDEX idx_goals_deleted_at ON goals(deleted_at) WHERE deleted_at IS NOT NULL;

-- Full-text search index
CREATE INDEX idx_goals_title_fts ON goals USING GIN(to_tsvector('english', title));

-- Date range queries
CREATE INDEX idx_goals_created_at ON goals(created_at DESC) WHERE deleted_at IS NULL;
```

**Index best practices**:
- Index foreign keys (for JOINs)
- Index WHERE clause columns (if selective)
- Use partial indexes (WHERE deleted_at IS NULL)
- Avoid over-indexing (each index has write cost)
- Monitor slow queries and add indexes as needed

#### 6. Naming Conventions

**Use snake_case consistently**:

```sql
-- ✅ CORRECT: snake_case
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL,
  display_name VARCHAR(100),
  profile_image_url TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP NOT NULL
);

-- ❌ WRONG: camelCase, PascalCase
CREATE TABLE UserProfiles (
  Id UUID PRIMARY KEY,
  userId UUID NOT NULL,
  DisplayName VARCHAR(100),
  profileImageUrl TEXT
);
```

#### 7. Migrations

**All schema changes must be versioned migrations**:

```bash
# Entity Framework Core migrations
dotnet ef migrations add AddGoalStatusColumn
dotnet ef database update

# Migration file: 20250105_AddGoalStatusColumn.cs
public partial class AddGoalStatusColumn : Migration
{
    protected override void Up(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.AddColumn<string>(
            name: "status",
            table: "goals",
            type: "varchar(20)",
            nullable: false,
            defaultValue: "active");
        
        migrationBuilder.CreateIndex(
            name: "idx_goals_status",
            table: "goals",
            column: "status",
            filter: "deleted_at IS NULL");
    }
    
    protected override void Down(MigrationBuilder migrationBuilder)
    {
        migrationBuilder.DropIndex(
            name: "idx_goals_status",
            table: "goals");
        
        migrationBuilder.DropColumn(
            name: "status",
            table: "goals");
    }
}
```

**Migration best practices**:
- Never edit existing migrations
- Always include Up and Down methods
- Test migrations on staging before production
- Backup database before applying migrations
- Document breaking schema changes

### Real-World Example

```sql
-- Complete table with all standards
CREATE TABLE goals (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Business Columns
  title VARCHAR(200) NOT NULL,
  description TEXT,
  status VARCHAR(20) NOT NULL DEFAULT 'active',
  target_date DATE,
  completion_date DATE NULL,
  
  -- Foreign Keys
  user_id UUID NOT NULL REFERENCES users(id),
  manager_id UUID NULL REFERENCES users(id),
  
  -- Audit Columns
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES users(id),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_by UUID NOT NULL REFERENCES users(id),
  deleted_at TIMESTAMP NULL,
  deleted_by UUID NULL REFERENCES users(id),
  
  -- Constraints
  CONSTRAINT ck_goals_status CHECK (status IN ('active', 'completed', 'archived', 'cancelled')),
  CONSTRAINT ck_goals_completion_date CHECK (completion_date IS NULL OR completion_date >= target_date)
);

-- Indexes
CREATE INDEX idx_goals_user_id ON goals(user_id) WHERE deleted_at IS NULL;
CREATE INDEX idx_goals_status ON goals(status) WHERE deleted_at IS NULL;
CREATE INDEX idx_goals_target_date ON goals(target_date DESC) WHERE deleted_at IS NULL AND status = 'active';
CREATE INDEX idx_goals_deleted_at ON goals(deleted_at) WHERE deleted_at IS NOT NULL;
CREATE INDEX idx_goals_title_fts ON goals USING GIN(to_tsvector('english', title));

-- Triggers
CREATE TRIGGER trg_goals_updated_at
BEFORE UPDATE ON goals
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- Comments (documentation)
COMMENT ON TABLE goals IS 'Career goals set by employees and managers';
COMMENT ON COLUMN goals.status IS 'Goal lifecycle status: active, completed, archived, cancelled';
COMMENT ON COLUMN goals.deleted_at IS 'Soft delete timestamp (NULL = not deleted)';
```

### Enforcement

#### 1. Migration Review Checklist

Migration Review Checklist:
- [ ] UUID primary key (not SERIAL)
- [ ] All audit columns included (created_at, updated_at, etc.)
- [ ] Soft delete columns included (deleted_at, deleted_by)
- [ ] Foreign keys reference UUID columns
- [ ] Indexes created for foreign keys
- [ ] Partial indexes use WHERE deleted_at IS NULL
- [ ] Column names use snake_case
- [ ] Constraints named consistently (ck_*, uk_*, fk_*)
- [ ] Up and Down methods both implemented
- [ ] Migration tested on staging database

#### 2. Database Code Review

```sql
-- Run EXPLAIN to check query performance
EXPLAIN ANALYZE
SELECT * FROM goals 
WHERE user_id = '123e4567-e89b-12d3-a456-426614174000' 
AND deleted_at IS NULL;

-- Check for missing indexes
SELECT schemaname, tablename, attname
FROM pg_stats
WHERE schemaname = 'public' AND correlation < 0.1;

-- Check table sizes
SELECT 
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

#### 3. Automated Tests

```csharp
[Fact]
public async Task AllTables_HaveAuditColumns()
{
    // Verify all tables have required audit columns
    var tables = await _dbContext.Database.SqlQuery<string>(
        "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public'")
        .ToListAsync();
    
    foreach (var table in tables)
    {
        var columns = await _dbContext.Database.SqlQuery<string>(
            $"SELECT column_name FROM information_schema.columns WHERE table_name = '{table}'")
            .ToListAsync();
        
        Assert.Contains("created_at", columns);
        Assert.Contains("updated_at", columns);
        Assert.Contains("deleted_at", columns);
        Assert.Contains("created_by", columns);
    }
}
```

### Why This Matters

- **Data Integrity**: UUID PKs prevent ID collisions
- **Auditability**: Track who changed what and when
- **Compliance**: Soft delete meets retention requirements
- **Performance**: Strategic indexes speed up queries
- **Reversibility**: Soft delete allows data recovery
- **Consistency**: Standard structure across all tables
- **Debuggability**: Audit trail aids troubleshooting

---

## Summary

| Principle | What | Why | How |
|-----------|------|-----|-----|
| **1. Specification-First** | Document before coding | Alignment, reduced rework | Specs in cpr-meta, PR template enforcement |
| **2. API Contract Consistency** | DTOs match across repos | Integration stability | Contract tests, OpenAPI validation |
| **3. API Standards & Security** | RESTful design, validation, rate limiting | Security, predictability, resilience | RFC 7807, input sanitization, idempotency keys |
| **4. Type Safety** | Strong typing everywhere | Catch errors early | TypeScript strict, C# nullable types, no `any` |
| **5. Offline Mode** | Mock APIs with MSW | Fast development, reliable tests | MSW handlers matching endpoints.md |
| **6. Internationalization** | Support multiple languages | Global reach, better UX | react-i18next, localization keys from API |
| **7. Comprehensive Testing** | 80% coverage, test pyramid | Confidence, regression prevention | Unit/integration/contract/E2E tests |
| **8. Performance-First React** | Optimize components, avoid re-renders | Fast UI, scalability | useCallback, useMemo, getStyles factory |
| **9. Strict Naming Conventions** | I/T/E prefixes, consistent patterns | Instant recognition, maintainability | ESLint rules, I prefix for interfaces |
| **10. Security & Data Privacy** | Protect secrets, PII, implement RBAC | Compliance, trust, legal protection | Azure Key Vault, audit trail, soft delete |
| **11. Database Design Standards** | UUID PKs, audit columns, soft delete | Data integrity, auditability, compliance | Migrations, strategic indexing, snake_case |

**Remember**: These principles exist to make us deliver better software faster. They are guidelines, not obstacles. When in doubt, follow the spirit of the principle and discuss with the team.
