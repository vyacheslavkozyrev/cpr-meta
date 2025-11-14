# Implementation Plan - Feedback Request Management

> **Feature**: 0004 - feedback-request-management  
> **Status**: Planning  
> **Created**: 2025-11-13  
> **Last Updated**: 2025-11-13

---

## Executive Summary

This implementation plan outlines the development of the Feedback Request Management feature (F004), which enables employees to proactively request structured feedback from multiple colleagues (1-20 recipients per request) with project/goal context, custom messages, and due dates. The feature uses a multi-recipient model with a junction table (`feedback_request_recipients`) to track per-recipient status, implements manager read-only team views, and provides comprehensive notification support including calendar integration (.ics files). The technical approach follows CPR's specification-first methodology with clean architecture on .NET 8 backend, React 18 + TypeScript frontend, offline-first capabilities via React Query and localStorage, and comprehensive testing coverage targeting >80%.

---

## Constitutional Compliance Check

Review against all 11 CPR Constitutional Principles:

### ✅ Principle 1: Specification-First Development
- [x] Complete specification exists in `description.md`
- [x] All requirements clearly documented
- [x] Stakeholder approval obtained

**Status**: PASS  
**Notes**: Phase 2 refinement completed on 2025-11-13 with 10 clarifying questions answered by stakeholder. Specification includes 4 user stories (US-001 through US-004), comprehensive acceptance criteria, multi-recipient model architecture, manager views, API contracts, database schema, and UI mockups.

### ✅ Principle 2: API Contract Consistency
- [x] C# DTOs defined and match specification
- [x] TypeScript interfaces defined and match C# DTOs
- [x] JSON naming uses snake_case
- [x] Property mappings documented

**Status**: PASS  
**Notes**: Specification includes complete DTOs: `CreateFeedbackRequestDto` (employee_ids array for multi-recipient), `FeedbackRequestDto` (with recipients array), `FeedbackRequestRecipientDto`, `UpdateFeedbackRequestDto`, `FeedbackRequestListDto`, and pagination/summary DTOs. All use `[JsonPropertyName]` attributes with snake_case. TypeScript interfaces mirror C# contracts exactly.

### ✅ Principle 3: API Standards & Security
- [x] RESTful endpoints follow conventions
- [x] HTTP methods used correctly (GET, POST, PUT, PATCH, DELETE)
- [x] Standard status codes defined (200, 201, 204, 400, 401, 403, 404, 429, 500)
- [x] Error responses standardized
- [x] Authentication/authorization specified

**Status**: PASS  
**Notes**: 7 RESTful endpoints defined: POST /api/feedback/request (create), GET /api/me/feedback/request (sent list), GET /api/me/feedback/request/todo (inbox), PATCH /api/feedback/request/{id} (update), POST /api/feedback/request/{id}/recipient/{recipientId}/remind (per-recipient reminder), DELETE /api/feedback/request/{id}/recipient/{recipientId} (partial cancellation), plus 2 manager endpoints (GET /api/team/feedback/request/sent and /received). All require JWT auth. Rate limiting: 50 requests/day per user, 48-hour reminder cooldown. Authorization ensures users can only create as themselves and view own data; managers have read-only access to direct reports.

### ✅ Principle 4: Type Safety Everywhere
- [x] C# DTOs use strong typing with validation attributes
- [x] TypeScript interfaces use strict types (no `any`)
- [x] Enums defined where applicable
- [x] Nullable types properly handled

**Status**: PASS  
**Notes**: C# DTOs include validation: [Required], [MinLength(1)], [MaxLength(20)] on employee_ids array, [StringLength(500)] on message, [RegularExpression] on status. Nullable types explicit (Guid?, string?, DateTimeOffset?). TypeScript interfaces use strict union types for status ('pending' | 'partial' | 'complete' | 'cancelled') and proper null handling (string | null). No `any` types used.

### ✅ Principle 5: Offline Mode
- [x] Offline capabilities identified
- [x] Data caching strategy defined
- [x] Sync mechanism specified
- [x] Conflict resolution approach documented

**Status**: PASS  
**Notes**: Offline support includes: (1) Request creation queued in localStorage, synced on reconnection with retry every 30 seconds (max 3 attempts), (2) Auto-save drafts to localStorage every 30 seconds with 7-day retention, (3) Cache last 50 sent requests and 20 todo requests for offline viewing (React Query TTL), (4) Optimistic UI updates with rollback on sync failure, (5) Conflict detection: if request cancelled server-side during offline period, notify user on sync and refresh list.

### ✅ Principle 6: Internationalization
- [x] All UI text externalizable
- [x] i18n keys defined in translation files
- [x] Locale-specific formatting identified (dates, numbers)
- [x] Translation strategy documented

**Status**: PASS  
**Notes**: All labels, buttons, messages, placeholders, validation errors, and toast notifications require i18n keys in `public/locales/{lang}/feedback.json`. Date formatting uses user's locale (MM/DD/YYYY vs DD/MM/YYYY). Relative dates ("2 days ago") use i18n library. Email notification templates support recipient's language preference. Character limit (500) applies universally, no byte limits.

### ✅ Principle 7: Comprehensive Testing
- [x] Unit test strategy defined
- [x] Integration test scenarios identified
- [x] Performance test requirements specified
- [x] Test coverage targets set

**Status**: PASS  
**Notes**: Comprehensive testing strategy documented: (1) Backend unit tests for service layer (40+ test cases covering create, list, update, reminder, multi-recipient logic), (2) Backend integration tests for API controllers (25+ test cases for all endpoints), (3) Frontend unit tests for components (form validation, submission, duplicate detection), (4) E2E tests for complete workflows (create, view, respond, remind flows), (5) Performance tests (100 concurrent creates <500ms, 500 concurrent lists <200ms). Target coverage: >80% for both backend and frontend.

### ✅ Principle 8: Performance-First React Development
- [x] Performance targets defined (load time, response time)
- [x] React Query caching strategy specified
- [x] Component optimization approach documented
- [x] Lazy loading identified where appropriate

**Status**: PASS  
**Notes**: Performance targets: API GET <200ms (95th percentile), API POST <500ms, list page initial render <100ms, data display <500ms for 20 items. React Query caching: staleTime 5 minutes for lists, infinite cache for request details, optimistic updates for mutations. Employee search debounced at 300ms. Pagination supports 10,000+ requests via cursor-based pagination. Skeleton loaders during initial load. Virtual scrolling for large recipient lists (6+ recipients collapsed initially).

### ✅ Principle 9: Strict Naming Conventions
- [x] JSON/API: snake_case verified
- [x] C# Properties: PascalCase with `[JsonPropertyName]` attributes
- [x] TypeScript: camelCase in code, snake_case in API types
- [x] Database: snake_case for tables/columns
- [x] URLs: kebab-case verified

**Status**: PASS  
**Notes**: Naming verified throughout specification: JSON uses snake_case (employee_ids, feedback_request_id, created_at, last_reminder_at), C# properties are PascalCase with [JsonPropertyName("employee_ids")], TypeScript interfaces use snake_case matching API, database tables are snake_case (feedback_requests, feedback_request_recipients), URLs are kebab-case (/api/feedback/request, /api/me/feedback/request/todo).

### ✅ Principle 10: Security & Data Privacy
- [x] Authentication requirements specified
- [x] Authorization rules defined (role-based, resource-based)
- [x] Data encryption approach documented
- [x] Privacy controls identified
- [x] Sensitive data handling specified

**Status**: PASS  
**Notes**: Security requirements comprehensive: (1) JWT authentication required for all endpoints, employee context derived from token (not client input), (2) Authorization: users can only create requests as themselves, view only their sent/received requests; managers see direct reports only (read-only), (3) Rate limiting: 50 requests/day per user, 48-hour reminder cooldown per recipient, (4) XSS prevention: message content sanitized with HTML purifier before storage, escaped on display, (5) SQL injection prevention: parameterized queries via EF Core, (6) Input validation: server-side validation for all fields, employee existence checks, goal/project validity checks.

### ✅ Principle 11: Database Design Standards
- [x] Entities use UUIDs for primary keys
- [x] Proper foreign key constraints defined
- [x] Indexes identified for performance
- [x] Normalization level appropriate
- [x] Migration strategy planned

**Status**: PASS  
**Notes**: Database design follows standards: (1) UUIDs for all primary keys (feedback_requests.id, feedback_request_recipients.id) with DEFAULT gen_random_uuid(), (2) Foreign keys with proper cascades: requestor_id/employee_id → CASCADE, project_id/goal_id → SET NULL, (3) 10 indexes for performance: requestor lookup, employee lookup, due date sorting, project/goal filtering, recipient pending status, (4) Junction table (feedback_request_recipients) for many-to-many normalization, (5) Unique constraint (feedback_request_id, employee_id) prevents duplicate recipients, (6) CHECK constraints for business rules (due_date >= created_at), (7) Soft delete support (is_deleted, deleted_at), (8) Audit fields (created_at, updated_at, created_by, updated_by, deleted_by), (9) Triggers for updated_at auto-update.

---

## Technical Context

### Technology Stack

**Backend (cpr-api)**:
- Framework: .NET 8 Web API
- Language: C# 12
- Database: PostgreSQL 16
- ORM: Entity Framework Core 8
- Authentication: JWT Bearer Token (existing auth system)
- Key Libraries:
  - FluentValidation (for DTO validation)
  - Hangfire or Quartz.NET (for scheduled reminder jobs)
  - HtmlSanitizer (for XSS prevention in message content)
  - Npgsql (PostgreSQL driver)

**Frontend (cpr-ui)**:
- Framework: React 18
- Language: TypeScript 5
- State Management: Zustand (global state), React Query (server state)
- UI Library: Material-UI v6
- Build Tool: Vite
- Testing: Vitest, React Testing Library
- Key Libraries:
  - react-hook-form (form management)
  - date-fns (date manipulation)
  - react-i18next (internationalization)
  - MSW (Mock Service Worker for testing/dev)
  - lodash.debounce (search debouncing)

### Architecture Patterns

**Backend Patterns**:
- [x] Repository Pattern (IFeedbackRequestRepository for data access abstraction)
- [x] Service Layer Pattern (FeedbackRequestService for business logic)
- [x] Clean Architecture (Domain → Application → Infrastructure → API layers)
- [ ] CQRS (not applicable - standard CRUD operations sufficient)
- [x] Other: Background Job Pattern (for automatic reminders via Hangfire/Quartz)

**Frontend Patterns**:
- [x] Component Composition (FeedbackRequestForm composed of EmployeeSelect, DatePicker, MessageInput)
- [x] Custom Hooks (useFeedbackRequests, useSentRequests, useTodoRequests, useReminderSend)
- [ ] Context API (not needed - React Query + Zustand sufficient)
- [ ] Higher-Order Components (not needed - prefer hooks)
- [x] Other: Service Layer Pattern (feedbackRequestService.ts for API calls)

### Integration Points

List existing features/systems this feature integrates with:

1. **F001 - Personal Goal Management**
   - Integration Type: Optional foreign key relationship (feedback_requests.goal_id → goals.id)
   - Impact: Users can associate feedback requests with specific goals; goal detail page shows "Request Feedback" action
   - Files Affected:
     - `src/CPR.Domain/Entities/Goal.cs` (navigation property)
     - `src/components/Goals/GoalDetailPage.tsx` (add "Request Feedback" button)
     - `src/types/goal.ts` (GoalDto may need feedback_request_count)

2. **F011 - Project Team Management**
   - Integration Type: Optional foreign key relationship (feedback_requests.project_id → projects.id)
   - Impact: Users can associate feedback requests with specific projects
   - Files Affected:
     - `src/CPR.Domain/Entities/Project.cs` (navigation property)
     - `src/types/project.ts` (ProjectDto may need feedback_request_count)

3. **Employee Directory / User Management**
   - Integration Type: Required foreign key relationships (requestor_id, employee_id → employees.id)
   - Impact: Employee search autocomplete requires active employee list API; manager views use manager_id relationships
   - Files Affected:
     - Requires GET /api/employees/search endpoint with filtering (department, location, role)
     - `src/CPR.Domain/Entities/Employee.cs` (manager_id relationship)
     - `src/components/shared/EmployeeSelect.tsx` (reusable autocomplete component)

4. **Notification System**
   - Integration Type: Event-driven notification triggers
   - Impact: Creating requests, sending reminders, and receiving responses all trigger in-app and email notifications
   - Files Affected:
     - `src/CPR.Application/Services/Interfaces/INotificationService.cs`
     - Notification templates for emails (with .ics calendar file generation)
     - In-app notification center (bell icon badge increment)

5. **Feedback Submission System (Existing)**
   - Integration Type: Foreign key link (feedback.feedback_request_id → feedback_requests.id)
   - Impact: Feedback responses link back to originating request; submitting feedback marks recipient as completed
   - Files Affected:
     - `src/CPR.Domain/Entities/Feedback.cs` (add feedback_request_id column)
     - ALTER TABLE feedback ADD COLUMN feedback_request_id migration
     - `src/CPR.Application/Services/Implementations/FeedbackService.cs` (update logic to mark recipient completed)

### Dependencies

**External Dependencies**:
- **New NuGet packages**:
  - HtmlSanitizer (1.0.x) - For XSS prevention in message content
  - Hangfire (1.8.x) OR Quartz.NET (3.x) - For scheduled automatic reminder jobs
  - (Optional) iCal.NET (4.x) - For generating .ics calendar files for email reminders
- **New npm packages**:
  - lodash.debounce (4.x) - For search input debouncing
  - (All other libraries already in project: react-hook-form, date-fns, react-i18next, MSW)
- **External APIs**:
  - Email service (e.g., SendGrid, already integrated) - For sending reminder and notification emails with .ics attachments

**Internal Dependencies**:
- **Features that must exist first**:
  - Employee directory with search capability (GET /api/employees/search with filters)
  - Notification system (in-app and email)
  - JWT authentication with employee context
  - F001 Goals (optional association) - can proceed without, association added later
  - F011 Projects (optional association) - can proceed without, association added later
  - Existing Feedback entity (to add feedback_request_id foreign key)
- **Shared components/services needed**:
  - EmployeeSelect component (reusable employee autocomplete)
  - DatePicker component (Material-UI DatePicker wrapper)
  - Toast notification system (for success/error messages)
  - API client with JWT injection
  - React Query configuration and hooks
  - i18n configuration and translation files

---

## Implementation Phases

### Phase 1: Foundation & Setup

**Duration**: 2-3 days

**Objectives**:
- Create database schema for multi-recipient feedback requests (feedback_requests parent + feedback_request_recipients junction table)
- Implement domain entities with navigation properties
- Define complete DTO contracts (C# with validation attributes + TypeScript interfaces)
- Set up repository and service interfaces
- Create EF Core configurations and migrations

**Deliverables**:
- [ ] Database migration for `feedback_requests` table (requestor_id, project_id, goal_id, message, due_date, audit fields)
- [ ] Database migration for `feedback_request_recipients` junction table (employee_id, is_completed, responded_at, last_reminder_at)
- [ ] Database migration to ALTER `feedback` table (add feedback_request_id FK column)
- [ ] Indexes created (10 total: requestor lookup, employee lookup, due_date sorting, project/goal filtering, recipient status)
- [ ] Domain entities: `FeedbackRequest.cs` and `FeedbackRequestRecipient.cs` with navigation properties
- [ ] C# DTOs: `CreateFeedbackRequestDto`, `FeedbackRequestDto`, `FeedbackRequestRecipientDto`, `UpdateFeedbackRequestDto`, `FeedbackRequestListDto`, pagination/summary DTOs
- [ ] TypeScript interfaces: matching all C# DTOs with snake_case properties
- [ ] Repository interfaces: `IFeedbackRequestRepository` (CRUD + complex queries for multi-recipient filtering)
- [ ] Service interfaces: `IFeedbackRequestService` (business logic methods)
- [ ] EF Core entity configurations with Fluent API (foreign keys, indexes, constraints, unique constraint on junction table)

**Key Files** (Backend - cpr-api):
```
src/CPR.Domain/Entities/FeedbackRequest.cs
src/CPR.Domain/Entities/FeedbackRequestRecipient.cs
src/CPR.Application/Contracts/FeedbackRequestDtos.cs
src/CPR.Application/Interfaces/Repositories/IFeedbackRequestRepository.cs
src/CPR.Application/Interfaces/Services/IFeedbackRequestService.cs
src/CPR.Infrastructure/Data/Configurations/FeedbackRequestConfiguration.cs
src/CPR.Infrastructure/Data/Configurations/FeedbackRequestRecipientConfiguration.cs
src/CPR.Infrastructure/Data/Migrations/[Timestamp]_AddFeedbackRequestManagement.cs
```

**Key Files** (Frontend - cpr-ui):
```
src/types/feedbackRequest.ts
src/types/dtos/feedbackRequestDtos.ts
```

---

### Phase 2: Backend API Implementation

**Duration**: 4-5 days

**Objectives**:
- Implement 7 RESTful API endpoints for multi-recipient feedback requests
- Add business logic in service layer (duplicate detection, multi-recipient status aggregation, reminder throttling)
- Implement FluentValidation rules for DTOs
- Add JWT authorization with employee context extraction
- Implement rate limiting (50 requests/day per user)
- Add comprehensive error handling with specific error codes

**Deliverables**:
- [ ] POST /api/feedback/request - Create request with 1-20 recipients, duplicate detection (partial vs full)
- [ ] GET /api/me/feedback/request - List sent requests with pagination, filtering (all/pending/partial/complete), sorting
- [ ] GET /api/me/feedback/request/todo - List todo requests (inbox) with pagination, filtering, sorting
- [ ] PATCH /api/feedback/request/{id} - Update due date or cancel entire request (soft delete)
- [ ] POST /api/feedback/request/{id}/recipient/{recipientId}/remind - Send reminder to specific recipient (48-hour cooldown)
- [ ] DELETE /api/feedback/request/{id}/recipient/{recipientId} - Partial cancellation (remove individual recipient)
- [ ] GET /api/team/feedback/request/sent - Manager view of team's sent requests (read-only)
- [ ] GET /api/team/feedback/request/received - Manager view of team's received requests (read-only)
- [ ] Repository implementation with complex EF Core queries (multi-recipient aggregation, per-recipient status)
- [ ] Service implementation with business rules (no self-requests, duplicate prevention, reminder cooldown validation)
- [ ] FluentValidation validators for all DTOs (employee_ids 1-20, message <=500 chars, due_date future check)
- [ ] Authorization policies (user can only create as self, view own data; managers see direct reports only)
- [ ] Rate limiting middleware (50 req/day tracking, 48-hour reminder cooldown per recipient)
- [ ] Error handling with specific error codes and messages (400/401/403/404/429/500)
- [ ] Notification triggers (create → notify all recipients, remind → notify specific recipient, respond → notify requestor)

**Key Files** (Backend - cpr-api):
```
src/CPR.Api/Controllers/FeedbackRequestController.cs
src/CPR.Api/Controllers/FeedbackRequestManagerController.cs
src/CPR.Application/Services/Implementations/FeedbackRequestService.cs
src/CPR.Application/Validators/CreateFeedbackRequestDtoValidator.cs
src/CPR.Application/Validators/UpdateFeedbackRequestDtoValidator.cs
src/CPR.Infrastructure/Repositories/Implementations/FeedbackRequestRepository.cs
src/CPR.Api/Middleware/FeedbackRequestRateLimitMiddleware.cs
```

---

### Phase 3: Frontend UI Implementation

**Duration**: 6-7 days

**Objectives**:
- Create feedback request UI components (form with multi-recipient select, sent list, todo list, manager team views)
- Implement React Query for server state management with offline caching
- Implement Zustand store for form draft auto-save (localStorage)
- Build reusable EmployeeSelect component with advanced filtering (department, location, role)
- Integrate API service layer with error handling and retry logic
- Implement i18n for all user-facing text

**Deliverables**:
- [ ] FeedbackRequestForm component with multi-recipient selection, project/goal autocomplete, message input, due date picker
- [ ] EmployeeMultiSelect component with debounced search (300ms), filter chips (dept/location/role), 3-line results, max 20 recipients
- [ ] SentRequestsList component with pagination, status filter (all/pending/partial/complete), sorting, per-recipient status badges
- [ ] TodoRequestsList component with pagination, urgency indicators (overdue/due today/due soon), respond button
- [ ] FeedbackRequestCard component (expandable, shows recipients, action buttons: remind, cancel, view feedback)
- [ ] ManagerTeamRequests component with sent/received sub-tabs (read-only view)
- [ ] React Query hooks: useSentRequests, useTodoRequests, useCreateRequest, useSendReminder, useCancelRequest
- [ ] API service layer: feedbackRequestService.ts with all 7 endpoint wrappers
- [ ] Zustand store: feedbackRequestDraftStore.ts for auto-save every 30 seconds to localStorage
- [ ] Offline support: queued request creation, cached lists (last 50 sent, last 20 todo), sync on reconnect
- [ ] i18n keys in public/locales/{lang}/feedbackRequest.json (labels, errors, toasts, placeholders)
- [ ] Toast notifications for success/error (create, remind, cancel, respond actions)
- [ ] Loading states with skeleton loaders, optimistic updates for mutations
- [ ] Form validation with real-time error display, character counter (500 chars), due date warnings (<3 days)

**Key Files** (Frontend - cpr-ui):
```
src/components/FeedbackRequest/FeedbackRequestForm.tsx
src/components/FeedbackRequest/EmployeeMultiSelect.tsx
src/components/FeedbackRequest/SentRequestsList.tsx
src/components/FeedbackRequest/TodoRequestsList.tsx
src/components/FeedbackRequest/FeedbackRequestCard.tsx
src/components/FeedbackRequest/ManagerTeamRequests.tsx
src/components/FeedbackRequest/RecipientStatusBadge.tsx
src/hooks/queries/useSentRequests.ts
src/hooks/queries/useTodoRequests.ts
src/hooks/mutations/useCreateFeedbackRequest.ts
src/hooks/mutations/useSendReminder.ts
src/hooks/mutations/useCancelRequest.ts
src/services/feedbackRequestService.ts
src/stores/feedbackRequestDraftStore.ts
src/locales/en/feedbackRequest.json
src/locales/es/feedbackRequest.json (if multi-language)
```

---

### Phase 4: Testing & Quality Assurance

**Duration**: 3-4 days

**Objectives**:
- Write comprehensive backend unit tests for service layer (40+ test cases for multi-recipient logic)
- Write backend integration tests for API controllers (25+ test cases for all endpoints)
- Write frontend component tests (form validation, submission, duplicate detection, multi-recipient UI)
- Write E2E tests for complete user workflows
- Perform load testing (100 concurrent creates, 500 concurrent lists)
- Conduct security audit (XSS, SQL injection, auth bypass, rate limit bypass)

**Deliverables**:
- [ ] Backend service unit tests: CreateAsync (11 cases), GetSentAsync (7 cases), GetTodoAsync (7 cases), UpdateAsync (5 cases), SendReminderAsync (5 cases), multi-recipient aggregation (5 cases)
- [ ] Backend controller integration tests: POST /feedback/request (6 cases), GET /me/feedback/request (5 cases), GET /todo (4 cases), PATCH (4 cases), remind/cancel (6 cases)
- [ ] Frontend component tests: FeedbackRequestForm (form rendering, validation, submission, duplicate detection - 15 cases)
- [ ] Frontend hook tests: useSentRequests, useTodoRequests, useCreateRequest mutation tests
- [ ] E2E tests: Create request flow (7 steps), View sent flow (6 steps), Respond flow (7 steps), Remind flow (4 steps)
- [ ] Performance tests: 100 concurrent POST requests <500ms, 500 concurrent GET requests <200ms, pagination with 10,000 requests efficient
- [ ] Security audit: XSS prevention verified (message sanitization), SQL injection tests (parameterized queries), auth bypass attempts (JWT required), rate limit enforcement (50/day, 48h cooldown)
- [ ] Accessibility audit: WCAG 2.1 AA compliance, keyboard navigation, screen reader support
- [ ] Code coverage reports: Backend >80%, Frontend >80%

**Key Files** (Testing):
```
tests/CPR.Application.Tests/Services/FeedbackRequestServiceTests.cs
tests/CPR.Api.Tests/Controllers/FeedbackRequestControllerTests.cs
tests/CPR.Api.Tests/Controllers/FeedbackRequestManagerControllerTests.cs
src/components/FeedbackRequest/__tests__/FeedbackRequestForm.test.tsx
src/components/FeedbackRequest/__tests__/EmployeeMultiSelect.test.tsx
src/components/FeedbackRequest/__tests__/SentRequestsList.test.tsx
src/hooks/__tests__/useSentRequests.test.ts
tests/e2e/feedback-request-workflows.spec.ts
tests/performance/feedback-request-load.spec.ts
```

---

### Phase 5: Documentation & Deployment

**Duration**: 2 days

**Objectives**:
- Complete API documentation with Swagger/OpenAPI annotations
- Update user-facing documentation and help guides
- Set up background job scheduler for automatic reminders (Hangfire/Quartz)
- Test database migrations in staging environment
- Prepare deployment scripts and rollback procedures
- Configure monitoring and alerting

**Deliverables**:
- [ ] Swagger/OpenAPI documentation for all 7 endpoints with request/response examples
- [ ] User guide: "How to Request Feedback" (with screenshots of multi-recipient form)
- [ ] User guide: "Managing Your Feedback Requests" (sent list, reminders, cancellation)
- [ ] User guide: "Manager Team View" (for managers with direct reports)
- [ ] Background job setup: Hangfire/Quartz configuration for automatic reminders (3 days before, 1 day before due date)
- [ ] Database migration tested in staging (feedback_requests, feedback_request_recipients, indexes)
- [ ] Deployment checklist: NuGet/npm packages, environment variables, database migration, background job scheduler start
- [ ] Rollback plan: Migration down scripts, data backup procedure, feature flag configuration
- [ ] Monitoring: API endpoint metrics (response times, error rates), background job monitoring (reminder success/failure rates)
- [ ] Alerting: Rate limit threshold alerts, failed reminder job alerts, database query performance alerts

**Key Files** (Documentation & Deployment):
```
src/CPR.Api/Controllers/FeedbackRequestController.cs (Swagger annotations)
docs/user-guides/feedback-requests.md
docs/user-guides/manager-team-feedback-view.md
docs/deployment/feedback-request-deployment-checklist.md
docs/deployment/rollback-procedures.md
src/CPR.Infrastructure/BackgroundJobs/FeedbackRequestReminderJob.cs
appsettings.Production.json (Hangfire/Quartz configuration)
```

---

## Data Model Changes

### New Entities

#### FeedbackRequest (Parent Request)

**Table**: `feedback_requests` (snake_case)

**Purpose**: Stores feedback request metadata (one row per request, supports 1-20 recipients via junction table)

**Key Relationships**:
- Has many `feedback_request_recipients` (junction table for multi-recipient model)
- Belongs to `employees` (requestor)
- Optionally references `projects` and `goals`

See `data-model.md` for complete SQL schema, EF Core configurations, and repository patterns.

---

#### FeedbackRequestRecipient (Junction Table)

**Table**: `feedback_request_recipients` (snake_case)

**Purpose**: Tracks individual recipient status within a multi-recipient feedback request

**Key Relationships**:
- Belongs to `feedback_requests` (parent request)
- Belongs to `employees` (recipient)
- Unique constraint on (feedback_request_id, employee_id) prevents duplicate recipients

**Critical Fields**:
- `is_completed`: BOOLEAN (false = pending, true = responded or cancelled)
- `responded_at`: TIMESTAMP (null = pending, not null = responded)
- `last_reminder_at`: TIMESTAMP (tracks 48-hour reminder cooldown per recipient)

See `data-model.md` for complete SQL schema.

---

### Modified Entities

#### Feedback (Existing Entity - Add Foreign Key Link)

**Table**: `feedback` (existing)

**Changes**:
- Add column: `feedback_request_id UUID NULL REFERENCES feedback_requests(id) ON DELETE SET NULL`
- Add index: `idx_feedback_request_link` on `feedback_request_id` WHERE NOT NULL
- Purpose: Links feedback responses back to originating request; enables "View Feedback" button in sent requests

**Migration**:
```sql
ALTER TABLE feedback ADD COLUMN feedback_request_id UUID NULL;
ALTER TABLE feedback ADD CONSTRAINT fk_feedback_request_link 
  FOREIGN KEY (feedback_request_id) REFERENCES feedback_requests(id) ON DELETE SET NULL;
CREATE INDEX idx_feedback_request_link ON feedback(feedback_request_id) 
  WHERE feedback_request_id IS NOT NULL;
```

**C# Model Update**:
```csharp
// Update: src/CPR.Domain/Entities/Feedback.cs
public class Feedback
{
    // ... existing properties ...
    
    public Guid? FeedbackRequestId { get; set; } // NEW
    public virtual FeedbackRequest? FeedbackRequest { get; set; } // NEW navigation property
}
```

---

### Database Migrations

**Migration Name**: `AddFeedbackRequestManagement`

**Changes**:
1. Create `feedback_requests` table with 6 columns + audit fields + soft delete fields
2. Create `feedback_request_recipients` junction table with 5 columns + audit fields
3. ALTER `feedback` table to add `feedback_request_id` column and foreign key
4. Create 10 indexes for performance (requestor, employee, due_date, project, goal, recipient status, pending status)
5. Add unique constraint on `feedback_request_recipients(feedback_request_id, employee_id)`
6. Add CHECK constraints: `due_date >= created_at::date`, `message` length <= 500 chars
7. Create triggers for `updated_at` auto-update on both tables

**Rollback Strategy**:
1. Drop triggers for `updated_at`
2. Drop all 10 indexes
3. Remove foreign key from `feedback.feedback_request_id`
4. Drop column `feedback.feedback_request_id`
5. Drop table `feedback_request_recipients` (CASCADE will handle FK constraints)
6. Drop table `feedback_requests` (CASCADE will handle FK constraints)
7. No data loss concern (new feature, no existing data to preserve)

---

## API Endpoints Summary

See `endpoints.md` for complete endpoint specifications with request/response schemas, validation rules, and examples.

**Quick Reference (7 Endpoints)**:
- `POST /api/feedback/request` - Create feedback request with 1-20 recipients
- `GET /api/me/feedback/request` - List sent requests (with pagination, filtering, sorting)
- `GET /api/me/feedback/request/todo` - List todo/inbox requests (recipient view)
- `PATCH /api/feedback/request/{id}` - Update due date or cancel entire request
- `POST /api/feedback/request/{id}/recipient/{recipientId}/remind` - Send reminder to specific recipient
- `DELETE /api/feedback/request/{id}/recipient/{recipientId}` - Partial cancellation (remove one recipient)
- `GET /api/team/feedback/request/sent` - Manager view of team's sent requests (read-only)
- `GET /api/team/feedback/request/received` - Manager view of team's received requests (read-only)

---

## Risk Assessment

### Technical Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| **Multi-recipient query performance** - Aggregating status across 20 recipients per request could slow list queries with 10,000+ requests | Medium | High | (1) Use optimized EF Core queries with proper indexes on junction table, (2) Test with 10,000 requests + 100,000 recipients, (3) Implement database query caching for sent/todo lists (5-minute TTL), (4) Consider materialized view if performance issues arise |
| **Background job failures** - Hangfire/Quartz automatic reminders may fail silently, causing missed notifications | Low | Medium | (1) Implement retry logic (3 attempts), (2) Log all failures to monitoring system, (3) Create alerting dashboard for job failure rates, (4) Fallback: manual reminder button always available |
| **Duplicate detection complexity** - Detecting partial duplicates (some recipients overlap) requires complex set comparison logic | Medium | Low | (1) Implement server-side set comparison algorithm, (2) Test exhaustively with edge cases (1 overlap, all overlap, no overlap), (3) Provide clear UI messaging for partial vs full duplicates, (4) Allow users to proceed with warning for partial duplicates |
| **Rate limiting bypass** - Users might attempt to circumvent 50 requests/day limit via API manipulation | Low | Low | (1) Implement server-side rate limiting in middleware (not client-enforced), (2) Track by employee_id from JWT (not client input), (3) Store rate limit state in Redis/database (not in-memory), (4) Return 429 with clear retry-after header |
| **Manager authorization complexity** - Determining manager-direct report relationships requires recursive queries if org hierarchy is deep | Low | Medium | (1) Use simple `employees.manager_id` lookup (non-recursive), (2) Explicitly state manager views are one-level only (no grandchildren), (3) Document limitation in user guide, (4) Future enhancement: recursive CTE if needed |
| **Calendar .ics generation** - Generating valid .ics files for email reminders may have compatibility issues across email clients | Medium | Low | (1) Use established library (iCal.NET), (2) Test .ics files with Gmail, Outlook, Apple Mail, (3) Include both .ics attachment and "Add to Calendar" link, (4) Provide plain-text alternative in email |
| **Offline sync conflicts** - User creates request offline, another user creates duplicate while first is offline, sync fails on reconnect | Low | Medium | (1) Detect conflict on sync, (2) Show user conflict resolution UI: "Similar request created - keep both or view existing?", (3) Log conflicts for analytics, (4) Educate users via toast: "Request saved offline, will sync when online" |

### Dependencies & Blockers

**Blocking Dependencies** (must exist before implementation):
1. **Employee Directory API** - Requires GET /api/employees/search endpoint with filters (department, location, role) for EmployeeMultiSelect component
   - Owner: User Management team
   - Status: Exists or needs to be created
   - Impact: Phase 3 frontend blocked without this

2. **Notification System** - Requires INotificationService with email sending capability and .ics attachment support
   - Owner: Infrastructure team
   - Status: Exists but may need .ics generation enhancement
   - Impact: Phase 2 backend notification triggers blocked

3. **JWT Authentication** - Requires employee_id extraction from JWT token claims
   - Owner: Auth team
   - Status: Should exist
   - Impact: All endpoints require this for authorization

**Non-Blocking Dependencies** (optional associations):
4. **F001 Goals** - Optional goal_id association
   - Status: Can proceed without, association added later if goals feature incomplete
   
5. **F011 Projects** - Optional project_id association
   - Status: Can proceed without, association added later if projects feature incomplete

---

## Performance Considerations

### Performance Targets

- **API Response Time**: <200ms at 95th percentile for GET requests, <500ms for POST requests
- **Page Load Time**: Initial render <100ms (skeleton loaders), data display <500ms for 20 items
- **Database Query Time**: List queries <150ms (with proper indexes), aggregation queries <200ms
- **Concurrent Users**: Support 100 concurrent request creations without degradation, 500 concurrent list views
- **Search Responsiveness**: Employee autocomplete results in <300ms (with 300ms debounce)

### Optimization Strategies

**Backend**:
- [x] Database query optimization: 10 strategic indexes (requestor, employee, due_date, project, goal, recipient status, pending status)
- [x] Pagination: Cursor-based pagination for lists (supports 10,000+ requests efficiently)
- [x] Async operations: All database queries use async/await pattern
- [x] Complex query optimization: Multi-recipient status aggregation uses single query with GROUP BY (not N+1)
- [x] Caching strategy: React Query on frontend caches API responses (5-minute staleTime for lists)
- [ ] Future optimization: Consider Redis caching for high-traffic employee search if needed
- [ ] Future optimization: Materialized view for aggregated request statistics if dashboard becomes bottleneck

**Frontend**:
- [x] React Query caching: staleTime 5 minutes for lists, infinite cache for details, optimistic updates for mutations
- [x] Component optimization: Skeleton loaders during initial load (perceived performance)
- [x] Debouncing: Employee search debounced at 300ms to reduce API calls
- [x] Virtual scrolling: Recipient list collapsed to "Show more" link if >6 recipients (avoids rendering 20 items unnecessarily)
- [x] Pagination: 20 items per page (not loading all 10,000 requests at once)
- [ ] Future: Lazy load FeedbackRequestCard expanded content (only load when user clicks expand)

---

## Security Considerations

### Authentication & Authorization

**Authentication**:
- Method: JWT Bearer Token (existing CPR auth system)
- Token storage: HttpOnly cookies (secure, not accessible to JavaScript)
- Token expiration: 24 hours (refreshed automatically)
- Employee context extraction: `employee_id` from JWT claims (NOT from client input)

**Authorization**:
- **Resource-based access control**:
  - Users can only create requests as themselves (requestor_id derived from JWT, not client)
  - Users can only view their own sent requests (filtered by requestor_id = JWT.employee_id)
  - Users can only view requests addressed to them (filtered by recipient employee_id = JWT.employee_id)
  - Managers can view direct reports' requests (filtered by employees.manager_id = JWT.employee_id), READ-ONLY
- **Rate limiting policies**:
  - Maximum 50 feedback requests per user per day (tracked by requestor_id + created_at date)
  - Maximum 1 manual reminder per recipient per 48 hours (tracked by last_reminder_at + recipient_id)
- **Authorization enforcement**: All checks at API controller level (before service layer), throw 403 Forbidden if unauthorized

### Data Protection

- [x] Sensitive data encrypted at rest: Database uses TLS encryption (PostgreSQL standard)
- [x] HTTPS enforced for all communications: API requires HTTPS in production (HTTP rejected)
- [x] Input validation and sanitization:
  - employee_ids: Validated against employees table (exist, not deleted, not self)
  - message: HTML tags stripped with HtmlSanitizer library, length validated (<=500 chars)
  - due_date: Validated as future date (>= today)
  - project_id/goal_id: Validated against respective tables (exist, accessible to user)
- [x] SQL injection prevention: EF Core uses parameterized queries (no raw SQL concatenation)
- [x] XSS prevention: React auto-escapes all output, message content sanitized before storage, CSP headers configured
- [x] CSRF protection: JWT in HttpOnly cookie, SameSite=Strict attribute, no CSRF token needed for Bearer auth
- [x] Authorization bypass prevention: requestor_id always from JWT (ignore client input), employee_id validated in database

---

## Effort Estimation

### Backend (cpr-api)

| Phase | Estimated Hours | Actual Hours | Notes |
|-------|----------------|--------------|-------|
| Phase 1: Foundation (DB, entities, DTOs) | 16-20 | - | 3 migrations (2 tables + 1 ALTER), 2 entities, 8 DTOs, EF configs, indexes |
| Phase 2: API Implementation (7 endpoints) | 28-36 | - | 7 endpoints, service logic, validation, auth, rate limiting, notifications |
| Phase 4: Backend Testing | 20-24 | - | Service unit tests (40+ cases), controller integration tests (25+ cases) |
| Phase 5: Deployment Setup | 8-10 | - | Hangfire/Quartz background jobs, migration testing, monitoring |
| **Total Backend** | **72-90** | - | ~9-11 days at 8 hrs/day |

### Frontend (cpr-ui)

| Phase | Estimated Hours | Actual Hours | Notes |
|-------|----------------|--------------|-------|
| Phase 1: Foundation (Types) | 4-6 | - | TypeScript interfaces (8 types), DTO matching |
| Phase 3: UI Implementation | 44-52 | - | 6 components (multi-select complex), 5 hooks, service layer, Zustand store, offline, i18n |
| Phase 4: Frontend Testing | 16-20 | - | Component tests (25+ cases), hook tests, E2E flows (4 scenarios) |
| **Total Frontend** | **64-78** | - | ~8-10 days at 8 hrs/day |

### Overall Estimate

| Category | Hours | Days (8h/day) |
|----------|-------|---------------|
| Backend | 72-90 | 9-11 |
| Frontend | 64-78 | 8-10 |
| **Total** | **136-168** | **17-21 days** |

**Assumptions**:
- 1 senior backend developer (full-time)
- 1 senior frontend developer (full-time)
- Parallel execution where possible (Phases 1-2 backend while Phase 3 frontend)
- Employee search endpoint exists or requires +4-8 hours if needs to be created
- Notification system .ics generation requires +4-6 hours if not existing

**Adjusted Timeline** (with parallel work):
- **Phase 1** (Backend foundation): 2-3 days
- **Phase 2** (Backend API): 4-5 days (can start while Phase 1 finishing)
- **Phase 3** (Frontend UI): 6-7 days (can start after Phase 1, parallel with Phase 2)
- **Phase 4** (Testing): 3-4 days (both developers)
- **Phase 5** (Deployment): 2 days (both developers)
- **TOTAL CALENDAR TIME**: **14-18 days** with parallel work

---

## Success Metrics

### Functional Metrics (Implementation Complete)
- [ ] All acceptance criteria met for 4 user stories (US-001 through US-004, including US-002B manager view)
- [ ] All 7 API endpoints implemented and functional
- [ ] Multi-recipient model working (1-20 recipients per request)
- [ ] Per-recipient status tracking functional
- [ ] Duplicate detection working (partial and full duplicates)
- [ ] Auto-save drafts working (30-second interval, 7-day retention)
- [ ] Calendar .ics generation working in email reminders
- [ ] Manager team views working (read-only, direct reports only)
- [ ] Zero critical bugs in production after 2-week stabilization period

### Quality Metrics (Code Quality)
- [ ] Backend code coverage >80% (service layer + controllers)
- [ ] Frontend code coverage >80% (components + hooks)
- [ ] All unit tests passing (130+ total test cases)
- [ ] All integration tests passing (25+ API endpoint tests)
- [ ] All E2E tests passing (4 complete user workflows)
- [ ] Zero TypeScript `any` types (strict type safety enforced)
- [ ] Zero linting errors (ESLint + Prettier for frontend, StyleCop for backend)
- [ ] Accessibility audit passed (WCAG 2.1 AA compliance)
- [ ] Security audit passed (XSS, SQL injection, auth bypass tests)

### Performance Metrics (Production Monitoring)
- [ ] API GET requests <200ms at 95th percentile (measured over 7 days)
- [ ] API POST requests <500ms at 95th percentile (measured over 7 days)
- [ ] Page load time <500ms for list rendering (20 items)
- [ ] Employee search autocomplete <300ms response time
- [ ] Support 100 concurrent request creations without errors
- [ ] Support 500 concurrent list views without degradation
- [ ] No database query timeout errors (queries <5 seconds)

### Adoption Metrics (Post-Launch - 3 months)
- [ ] 70% of employees create at least one feedback request within first 3 months
- [ ] 80% of feedback requests receive response within due date (or 14 days if no due date)
- [ ] 30% increase in total feedback submissions compared to pre-feature baseline
- [ ] Average 3-5 feedback requests per user per month
- [ ] Manager view adoption: 50% of managers access team view within first month
- [ ] User satisfaction survey: >4.0/5.0 rating for feedback request experience

### Business Metrics (Post-Launch - 6 months)
- [ ] Feedback request feature supports performance review preparation for 80% of employees
- [ ] Reduction in informal feedback request emails (measured by email traffic analysis)
- [ ] Increase in cross-functional feedback (measured by department diversity in recipients)
- [ ] Positive impact on employee engagement scores related to feedback culture
- [ ] Zero security vulnerabilities
- [ ] Accessibility score > 95

### Performance Metrics
- [ ] API response time targets met
- [ ] Page load time targets met
- [ ] No performance regressions

---

## Open Questions & Decisions Needed

List any unresolved questions or decisions needed before implementation:

1. **[Question/Decision]**
   - Context: [Why this matters]
   - Options: [List alternatives]
   - Recommendation: [Preferred option]
   - Decision: [To be decided/Decided on 2025-11-13: [decision]]

---

## References

- Specification: `specifications/0004-[feature-name]/description.md`
- Tasks: `specifications/0004-[feature-name]/tasks.md`
- Endpoints: `specifications/0004-[feature-name]/endpoints.md`
- Data Model: `specifications/0004-[feature-name]/data-model.md` (if applicable)
- Research: `specifications/0004-[feature-name]/research.md` (if applicable)
- Constitution: `constitution.md`
- Architecture: `architecture.md`

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| 2025-11-13 | [Name] | Initial plan created |
