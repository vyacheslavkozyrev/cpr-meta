# Implementation Plan - Personal Goal Management

> **Feature**: 0001 - personal-goal-management  
> **Status**: Planning  
> **Created**: 2025-11-11  
> **Last Updated**: 2025-11-11

---

## Executive Summary

This implementation plan covers the frontend UI development for the Personal Goal Management feature (F001). The backend API is already implemented with full CRUD operations for goals and tasks. We will build a comprehensive React-based UI with goal list/detail views, task management, filtering/sorting capabilities, offline sync support, and complete internationalization. The implementation will follow the CPR Framework's constitutional principles, emphasizing type safety, performance optimization, and accessibility compliance

---

## Constitutional Compliance Check

Review against all 11 CPR Constitutional Principles:

### ✅ Principle 1: Specification-First Development
- [x] Complete specification exists in `description.md`
- [x] All requirements clearly documented
- [x] Stakeholder approval obtained

**Status**: PASS  
**Notes**: Phase 1 and Phase 2 completed with comprehensive specification (1200+ lines) including 5 user stories with 80+ acceptance criteria, 50+ edge cases, and UX flow diagrams. Stakeholder decisions documented in refinement-questions.md.

### ✅ Principle 2: API Contract Consistency
- [x] C# DTOs defined and match specification
- [x] TypeScript interfaces defined and match C# DTOs
- [x] JSON naming uses snake_case
- [x] Property mappings documented

**Status**: PASS  
**Notes**: Backend C# DTOs already exist (GoalDto, CreateGoalDto, UpdateGoalDto, TaskDto, etc.) with `[JsonPropertyName]` attributes. TypeScript interfaces defined in specification match C# DTOs exactly. All use snake_case JSON properties (employee_id, created_at, progress_percent, etc.).

### ✅ Principle 3: API Standards & Security
- [x] RESTful endpoints follow conventions
- [x] HTTP methods used correctly (GET, POST, PATCH, DELETE)
- [x] Standard status codes defined (200, 201, 204, 400, 401, 403, 404, 422, 500)
- [x] Error responses standardized
- [x] Authentication/authorization specified

**Status**: PASS  
**Notes**: API endpoints follow REST conventions. All endpoints require JWT authentication. Authorization enforced: users access own goals, managers/admins view team/org goals. Goal deletion is admin-only in v1. Error responses return consistent JSON structure with ProblemDetails.

### ✅ Principle 4: Type Safety Everywhere
- [x] C# DTOs use strong typing with validation attributes
- [x] TypeScript interfaces use strict types (no `any`)
- [x] Enums defined where applicable
- [x] Nullable types properly handled

**Status**: PASS  
**Notes**: C# DTOs use validation attributes (`[Required]`, `[MinLength]`, `[MaxLength]`, `[Range]`). TypeScript uses strict literals for enums (GoalStatus = 'open' | 'in_progress' | 'completed', GoalPriority = 1 | 2 | 3 | 4 | 5). All nullable types explicitly declared.

### ✅ Principle 5: Offline Mode
- [x] Offline capabilities identified
- [x] Data caching strategy defined
- [x] Sync mechanism specified
- [x] Conflict resolution approach documented

**Status**: PASS  
**Notes**: Read operations use cached data via React Query (24-hour cache). Write operations queue locally and sync on reconnection with retry logic (3 attempts, exponential backoff). Conflict resolution: server wins with user notification and option to save local as new goal. Offline indicators (header icon + banner) and sync status tracking implemented.

### ✅ Principle 6: Internationalization
- [x] All UI text externalizable
- [x] i18n keys defined in translation files
- [x] Locale-specific formatting identified (dates, numbers)
- [x] Translation strategy documented

**Status**: PASS  
**Notes**: All static UI text externalized with structured keys (goals.create.title, goals.list.empty_state). Date formatting respects user locale (MM/DD/YYYY vs DD/MM/YYYY). Progress percentages use locale-specific decimal separators. RTL support planned. Initial locales: en-US, en-GB, es-ES, fr-FR, de-DE, ja-JP. User-generated content (goal titles/descriptions) not translated.

### ✅ Principle 7: Comprehensive Testing
- [x] Unit test strategy defined
- [x] Integration test scenarios identified
- [x] Performance test requirements specified
- [x] Test coverage targets set

**Status**: PASS  
**Notes**: Unit tests for business logic, validation, and utilities (>80% coverage target). Integration tests for E2E workflows (create, edit, complete goals, offline sync). Performance tests with Lighthouse (TTI < 2s on 3G, list render < 500ms). Contract tests for API/UI consistency. 40+ test cases documented in specification.

### ✅ Principle 8: Performance-First React Development
- [x] Performance targets defined (load time, response time)
- [x] React Query caching strategy specified
- [x] Component optimization approach documented
- [x] Lazy loading identified where appropriate

**Status**: PASS  
**Notes**: Performance targets: Goals list API < 200ms (p95), goal creation < 150ms (p95), initial page load < 2s on 3G, TTI < 1.5s. React Query caching with 5-minute stale time, background refetch. Skeleton loaders for perceived performance. Optimistic updates for low-risk operations (task completion, progress). Virtual scrolling for large lists (100+ goals). Lazy load goal detail components.

### ✅ Principle 9: Strict Naming Conventions
- [x] JSON/API: snake_case verified
- [x] C# Properties: PascalCase with `[JsonPropertyName]` attributes
- [x] TypeScript: camelCase in code, snake_case in API types
- [x] Database: snake_case for tables/columns
- [x] URLs: kebab-case verified

**Status**: PASS  
**Notes**: All conventions followed. JSON: employee_id, created_at, is_completed. C#: EmployeeId, CreatedAt, IsCompleted. TypeScript variables: camelCase, API types: snake_case. Database: goals, goal_tasks, employee_id. URLs: /goals, /goals/{id}/tasks.

### ✅ Principle 10: Security & Data Privacy
- [x] Authentication requirements specified
- [x] Authorization rules defined (role-based, resource-based)
- [x] Data encryption approach documented
- [x] Privacy controls identified
- [x] Sensitive data handling specified

**Status**: PASS  
**Notes**: JWT authentication required for all endpoints. Authorization: users access own private goals, managers access team goals, admins access all + delete. Input sanitization prevents XSS. HTTPS only in production. Private goals never exposed to unauthorized users. API errors don't leak sensitive data.

### ✅ Principle 11: Database Design Standards
- [x] Entities use UUIDs for primary keys
- [x] Proper foreign key constraints defined
- [x] Indexes identified for performance
- [x] Normalization level appropriate
- [x] Migration strategy planned

**Status**: PASS (Backend Already Implemented)  
**Notes**: Database schema already exists with UUID primary keys, foreign key constraints (employee_id REFERENCES employees(id), goal_id REFERENCES goals(id) ON DELETE CASCADE). Indexes on employee_id, status, deadline, priority, created_at. Soft deletion with deleted_at. Trigger for automatic progress calculation. Migration needed only for order_index column addition to goal_tasks table.

---

## Technical Context

### Technology Stack

**Backend (cpr-api)** - Already Implemented:
- Framework: .NET 8 Web API
- Language: C# 12
- Database: PostgreSQL 16
- ORM: Entity Framework Core 8
- Authentication: Microsoft Entra External ID (JWT)
- Key Libraries: FluentValidation, AutoMapper (existing)
- Status: ✅ Backend complete with GoalsController, GoalService, GoalsRepository

**Frontend (cpr-ui)** - To Be Implemented:
- Framework: React 18
- Language: TypeScript 5
- State Management: Zustand (global state), React Query (server state)
- UI Library: Material-UI v6 (MUI)
- Build Tool: Vite
- Testing: Vitest, React Testing Library, Playwright (E2E)
- Key Libraries: 
  - react-i18next (internationalization)
  - react-hook-form (form management)
  - date-fns (date formatting/parsing)
  - @dnd-kit/core (drag-and-drop for task reordering)
  - react-router-dom v6 (routing)

### Architecture Patterns

**Backend Patterns** (Already Implemented):
- [x] Repository Pattern
- [x] Service Layer Pattern
- [x] Clean Architecture (Domain, Application, Infrastructure layers)
- [x] Dependency Injection

**Frontend Patterns** (To Implement):
- [x] Component Composition
- [x] Custom Hooks (useGoals, useTasks, useOfflineSync)
- [x] Service Layer (goalService.ts, taskService.ts)
- [x] Atomic Design (atoms, molecules, organisms, templates)
- [x] Container/Presenter Pattern

### Integration Points

1. **Authentication System**
   - Integration Type: JWT token from Microsoft Entra External ID
   - Impact: All API calls require valid JWT in Authorization header
   - Files Affected: src/services/apiClient.ts, src/hooks/useAuth.ts

2. **Skills Taxonomy System**
   - Integration Type: API call to GET /api/skills for autocomplete
   - Impact: Goal creation form needs skill selector with search
   - Files Affected: src/components/goals/GoalForm.tsx, src/services/skillService.ts
   - Status: Requires new API endpoint (skills autocomplete not implemented yet)

3. **User Preferences System**
   - Integration Type: API call to GET/PUT /api/user-preferences
   - Impact: Store default filter/sort settings across sessions
   - Files Affected: src/services/userPreferencesService.ts, src/hooks/useUserPreferences.ts
   - Status: Requires new API endpoint (user preferences API not implemented yet)

4. **Employee Management**
   - Integration Type: Existing employees table provides employee_id
   - Impact: Goals are owned by employees, visibility based on reporting hierarchy
   - Files Affected: No direct integration, uses employee_id from authenticated user

### Dependencies

**External Dependencies (Frontend - New npm packages)**:
- [x] @dnd-kit/core@^6.0.0 (drag-and-drop for task reordering)
- [x] @dnd-kit/sortable@^7.0.0 (sortable list utilities)
- [x] react-i18next@^13.0.0 (internationalization)
- [x] i18next@^23.0.0 (i18n core)
- [x] date-fns@^2.30.0 (date utilities)
- [x] react-hook-form@^7.45.0 (form state management)

**Internal Dependencies (Backend - New API endpoints needed)**:
- [ ] GET /api/skills?search={query}&limit=10 - Skills autocomplete for goal creation
- [ ] GET /api/user-preferences - Retrieve user preferences (filter/sort defaults)
- [ ] PUT /api/user-preferences - Save user preferences
- [ ] PATCH /api/goals/{id}/tasks/reorder - Batch update task order
- [ ] Database migration: Add order_index column to goal_tasks table

**Internal Dependencies (Frontend - Shared components needed)**:
- [ ] Skeleton loader component (if not exists)
- [ ] Toast notification system (if not exists)
- [ ] Confirmation modal component (if not exists)
- [ ] Empty state component (if not exists)
- [ ] Badge component for status/priority indicators

---

## Implementation Phases

### Phase 1: Foundation Setup & Data Model

**Duration**: 1-2 days

**Objectives**:
- Add order_index column to goal_tasks table
- Create TypeScript types matching backend DTOs
- Set up API service layer and React Query hooks
- Configure routing structure

**Deliverables**:
- [ ] Database migration for order_index column in goal_tasks
- [ ] TypeScript type definitions (GoalDto, GoalTaskDto, CreateGoalRequest, etc.)
- [ ] API service layer (goalService.ts, taskService.ts)
- [ ] React Query hooks (useGoals, useGoal, useTasks)
- [ ] Initial routing structure for goals pages

**Key Files** (Backend):
```
src/CPR.Infrastructure/Persistence/Migrations/XXXXXX_AddOrderIndexToGoalTasks.cs
```

**Key Files** (Frontend):
```
src/types/goal.types.ts
src/services/goalService.ts
src/services/taskService.ts
src/hooks/useGoals.ts
src/hooks/useTasks.ts
src/routes/GoalRoutes.tsx
```

---

### Phase 2: Backend API Enhancements

**Duration**: 1 day

**Objectives**:
- Implement skills autocomplete endpoint
- Implement user preferences endpoints
- Add task reorder endpoint

**Deliverables**:
- [ ] GET /api/skills?search={query}&limit=10 endpoint
- [ ] GET /api/user-preferences endpoint
- [ ] PUT /api/user-preferences endpoint
- [ ] PATCH /api/goals/{id}/tasks/reorder endpoint
- [ ] DTOs for skills and preferences

**Key Files** (Backend):
```
src/CPR.Api/Controllers/SkillsController.cs
src/CPR.Api/Controllers/UserPreferencesController.cs
src/CPR.Api/Controllers/GoalsController.cs (add reorder endpoint)
src/CPR.Application/Contracts/SkillDto.cs
src/CPR.Application/Contracts/UserPreferencesDto.cs
src/CPR.Application/Services/SkillService.cs
src/CPR.Application/Services/UserPreferencesService.cs
```

---

### Phase 3: Frontend Core - List & Detail Views

**Duration**: 4-5 days

**Objectives**:
- Implement goals list page with filtering and sorting
- Implement goal detail page with task management
- Create goal create/edit form
- Add offline detection

**Deliverables**:
- [ ] Goals list page (table/card view, filters, sorting, search)
- [ ] Goal detail page with task list
- [ ] Goal create/edit form with skill autocomplete
- [ ] Task CRUD operations (create, update, delete, complete)
- [ ] Offline status indicator

**Key Files** (Frontend):
```
src/pages/goals/GoalsListPage.tsx
src/pages/goals/GoalDetailPage.tsx
src/components/goals/GoalsList.tsx
src/components/goals/GoalCard.tsx
src/components/goals/GoalForm.tsx
src/components/goals/GoalFilters.tsx
src/components/goals/TaskList.tsx
src/components/goals/TaskItem.tsx
src/components/goals/TaskForm.tsx
src/components/common/OfflineIndicator.tsx
src/components/common/ConfirmDialog.tsx
```

---

### Phase 4: Advanced Features & Offline Support

**Duration**: 3-4 days

**Objectives**:
- Implement drag-and-drop task reordering
- Implement offline sync with queue management
- Add internationalization (English, Ukrainian)
- Add auto-save with debounce
- Implement optimistic UI updates

**Deliverables**:
- [ ] Drag-and-drop task reordering with @dnd-kit
- [ ] Offline sync queue with IndexedDB
- [ ] Auto-save with 2-second debounce
- [ ] Optimistic updates for all mutations
- [ ] English and Ukrainian translations
- [ ] User preferences persistence

**Key Files** (Frontend):
```
src/hooks/useOfflineSync.ts
src/hooks/useDebouncedSave.ts
src/services/offlineStorageService.ts
src/services/syncQueueService.ts
src/i18n/locales/en/goals.json
src/i18n/locales/uk/goals.json
src/components/goals/TaskList.tsx (enhance with drag-drop)
src/utils/optimisticUpdate.ts
src/store/offlineStore.ts
src/services/userPreferencesService.ts
```

---

### Phase 5: Testing, Performance & Polish

**Duration**: 2-3 days

**Objectives**:
- Write comprehensive unit tests
- Write integration tests for API service layer
- Write E2E tests for critical user flows
- Optimize performance (lazy loading, memoization)
- Conduct accessibility audit (WCAG AA)

**Deliverables**:
- [ ] Unit tests for components (>80% coverage)
- [ ] Unit tests for hooks (>80% coverage)
- [ ] Integration tests for API calls
- [ ] E2E tests: goal lifecycle, task management, offline sync, filters
- [ ] Performance optimization (React.memo, useMemo, lazy loading)
- [ ] Accessibility audit passed
- [ ] Documentation updated

**Key Files** (Testing):
```
src/components/goals/__tests__/GoalsList.test.tsx
src/components/goals/__tests__/GoalForm.test.tsx
src/components/goals/__tests__/TaskList.test.tsx
src/hooks/__tests__/useGoals.test.ts
src/hooks/__tests__/useTasks.test.ts
src/services/__tests__/goalService.test.ts
tests/e2e/goals/goal-lifecycle.spec.ts
tests/e2e/goals/task-management.spec.ts
tests/e2e/goals/offline-sync.spec.ts
tests/e2e/goals/filters-sorting.spec.ts
```

**Key Files** (Documentation):
```
README.md (update with goals feature documentation)
documents/goals-feature-guide.md (user guide)
```

---

## Data Model Changes

### New Entities

**Note**: The `goals` and `goal_tasks` tables already exist. This section documents the existing schema for reference.

#### Goal (Existing)

**Table**: `goals`

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `employee_id` | UUID | NOT NULL, FK → employees.id | Goal owner |
| `title` | VARCHAR(200) | NOT NULL | Goal title |
| `description` | TEXT | NULL | Detailed description |
| `category` | VARCHAR(50) | NOT NULL | Goal category (skill, career, project, personal) |
| `status` | VARCHAR(20) | NOT NULL | Goal status (not_started, in_progress, completed, on_hold, cancelled) |
| `priority` | VARCHAR(20) | NOT NULL | Goal priority (low, medium, high, critical) |
| `target_completion_date` | DATE | NULL | Target completion date |
| `actual_completion_date` | DATE | NULL | Actual completion date |
| `progress_percentage` | INT | NOT NULL DEFAULT 0 | Progress (0-100) |
| `related_skill_id` | UUID | NULL, FK → skills.id | Related skill |
| `created_by` | UUID | NULL, FK → users.id | User who created record |
| `created_at` | TIMESTAMPTZ | DEFAULT CURRENT_TIMESTAMP | Creation timestamp |
| `modified_by` | UUID | NULL, FK → users.id | User who last modified |
| `modified_at` | TIMESTAMPTZ | NULL | Last modification timestamp |
| `is_deleted` | BOOLEAN | DEFAULT FALSE | Soft delete flag |
| `deleted_by` | UUID | NULL, FK → users.id | User who deleted record |
| `deleted_at` | TIMESTAMPTZ | NULL | Deletion timestamp |

**Indexes**:
- `idx_goals_employee_id` on `employee_id`
- `idx_goals_status` on `status`
- `idx_goals_category` on `category`
- `idx_goals_related_skill_id` on `related_skill_id`

**C# Domain Model**: `src/CPR.Domain/Entities/Goal.cs` (already exists)

#### GoalTask (Existing)

**Table**: `goal_tasks`

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `goal_id` | UUID | NOT NULL, FK → goals.id | Parent goal |
| `title` | VARCHAR(200) | NOT NULL | Task title |
| `description` | TEXT | NULL | Task description |
| `is_completed` | BOOLEAN | NOT NULL DEFAULT FALSE | Completion status |
| `completed_at` | TIMESTAMP | NULL | Completion timestamp |
| `created_by` | UUID | NULL, FK → users.id | User who created record |
| `created_at` | TIMESTAMPTZ | DEFAULT CURRENT_TIMESTAMP | Creation timestamp |
| `modified_by` | UUID | NULL, FK → users.id | User who last modified |
| `modified_at` | TIMESTAMPTZ | NULL | Last modification timestamp |
| `is_deleted` | BOOLEAN | DEFAULT FALSE | Soft delete flag |
| `deleted_by` | UUID | NULL, FK → users.id | User who deleted record |
| `deleted_at` | TIMESTAMPTZ | NULL | Deletion timestamp |

**Indexes**:
- `idx_goal_tasks_goal_id` on `goal_id`

**C# Domain Model**: `src/CPR.Domain/Entities/GoalTask.cs` (already exists)

### Modified Entities

#### GoalTask (Add order_index column)

**Table**: `goal_tasks`

**New Column**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `order_index` | INT | NOT NULL DEFAULT 0 | Display order within goal |

**New Index**:
- `idx_goal_tasks_goal_id_order` on `(goal_id, order_index)` - Composite index for efficient ordering queries

### Database Migrations

**Migration Name**: `AddOrderIndexToGoalTasks`

**Changes**:
1. Add `order_index` INT column to `goal_tasks` table with DEFAULT 0
2. Update existing rows: `UPDATE goal_tasks SET order_index = ROW_NUMBER() OVER (PARTITION BY goal_id ORDER BY created_at)`
3. Create composite index `idx_goal_tasks_goal_id_order` on `(goal_id, order_index)`

**Rollback Strategy**:
1. Drop index `idx_goal_tasks_goal_id_order`
2. Drop column `order_index` from `goal_tasks`

---

## API Endpoints Summary

See `endpoints.md` for complete endpoint specifications.

**Existing Endpoints (Already Implemented)**:
- `POST /api/goals` - Create new goal
- `GET /api/me/goals` - List user's goals (with filtering)
- `GET /api/goals/{id}` - Get goal details with tasks
- `PATCH /api/goals/{id}` - Update goal
- `DELETE /api/goals/{id}` - Delete goal (admin only)
- `POST /api/goals/{id}/tasks` - Add task to goal
- `PATCH /api/goals/{id}/tasks/{taskId}` - Update task
- `DELETE /api/goals/{id}/tasks/{taskId}` - Delete task

**New Endpoints (To Be Implemented)**:
- `GET /api/skills?search={query}&limit=10` - Skills autocomplete
- `GET /api/user-preferences` - Get user preferences
- `PUT /api/user-preferences` - Save user preferences
- `PATCH /api/goals/{id}/tasks/reorder` - Batch update task order

---

## Risk Assessment

### Technical Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| Offline sync conflicts | Medium | Medium | Implement last-write-wins with user notification, store conflict resolution history |
| Large dataset performance (>500 goals) | Low | Medium | Implement pagination, virtual scrolling, aggressive caching, lazy load task details |
| Browser IndexedDB limitations | Low | High | Add fallback to localStorage, implement quota management, clear old sync queue items |
| Drag-drop performance on mobile | Medium | Low | Use CSS transforms, throttle reorder API calls, implement optimistic updates |
| Skills API latency affecting UX | Low | Low | Implement debounced search (300ms), cache recent searches, show loading state |
| Microsoft Entra External ID token expiry during long sessions | Medium | Medium | Implement token refresh, queue operations if refresh fails, show auth error modal |

### Dependencies & Blockers

1. **Skills Taxonomy System**
   - Status: Pending
   - Impact if delayed: Cannot implement goal-skill linking, autocomplete search unavailable
   - Mitigation: Use hardcoded skill list for Phase 3, integrate real API in Phase 4

2. **User Preferences API**
   - Status: Pending
   - Impact if delayed: Filter/sort preferences not persisted across sessions
   - Mitigation: Use localStorage temporarily, migrate to API when available

3. **Shared UI Components**
   - Status: Unknown (ConfirmDialog, OfflineIndicator, Toast, EmptyState)
   - Impact if delayed: Need to create components from scratch, increases Phase 3 duration
   - Mitigation: Create lightweight versions in goals module, refactor to shared later

---

## Performance Considerations

### Performance Targets

- API Response Time: < 200ms at 95th percentile (goals list, goal detail)
- API Response Time: < 500ms at 95th percentile (goal create/update with validation)
- Page Load Time: < 1500ms (initial goals list page load)
- Database Query Time: < 50ms (single goal fetch), < 100ms (filtered goals list)
- Concurrent Users: Support 100 concurrent users without degradation

### Optimization Strategies

**Backend**:
- [x] Database query optimization: Use composite indexes (employee_id, status), (goal_id, order_index)
- [x] Pagination for large datasets: Default 50 goals per page, max 100
- [x] Async operations: Repository methods use async/await pattern
- [ ] Caching strategy: Cache skills autocomplete results (5min TTL), user preferences (session-scoped)
- [ ] N+1 query prevention: Eager load tasks with goals when needed (Include in EF queries)

**Frontend**:
- [ ] React Query caching: 5-minute stale time for goals list, 30-second stale time for goal details
- [ ] Component lazy loading: Lazy load GoalDetailPage, task management components
- [ ] Memoization: Use React.memo for GoalCard, TaskItem; useMemo for filtered/sorted lists
- [ ] Virtual scrolling: Implement if goals list exceeds 100 items (use @tanstack/react-virtual)
- [ ] Debouncing: 300ms debounce for search input, 2s debounce for auto-save
- [ ] Image optimization: Use WebP for status/priority icons, lazy load images below fold
- [ ] Code splitting: Separate bundle for goals module to reduce initial load

---

## Security Considerations

### Authentication & Authorization

**Authentication**:
- Method: Microsoft Entra External ID (JWT tokens)
- Token storage: Memory only (not localStorage/cookies) - React state via Zustand
- Token expiration: 1 hour (configurable in Entra External ID)
- Token refresh: Automatic refresh before expiration via silent token renewal

**Authorization**:
- Role-based access control (RBAC):
  - All authenticated users: Create, read, update own goals
  - Manager role: Read direct reports' goals
  - Admin role: Delete any goal, view all goals
- Resource-based permissions:
  - Users can only modify their own goals
  - Managers can view (not edit) reports' goals
  - Goal deletion requires admin role
- Policy requirements: `AuthorizeAttribute` on controllers, policy-based authorization in service layer

### Data Protection

- [x] HTTPS enforced for all communications (API requires HTTPS)
- [x] Input validation: FluentValidation on all DTOs (title length, date ranges, enums)
- [x] SQL injection prevention: Entity Framework uses parameterized queries
- [x] XSS prevention: React auto-escapes content, CSP headers configured
- [ ] CSRF protection: SameSite cookies, anti-forgery tokens for state-changing operations
- [ ] Sensitive data: No PII in goals by design (employee_id is UUID reference)
- [ ] Rate limiting: Implement API rate limiting (10 req/sec per user, 100 req/min globally)
- [ ] Audit logging: Log goal creation/update/delete with user_id and timestamp

---

## Effort Estimation

### Backend (cpr-api)

| Phase | Estimated Hours | Actual Hours | Notes |
|-------|----------------|--------------|-------|
| Phase 1: Foundation (Migration) | 4 | - | order_index migration, testing, index creation |
| Phase 2: API Implementation | 8 | - | 4 new endpoints (skills, preferences, reorder) + DTOs + services |
| Phase 5: Testing | 6 | - | Unit tests for new endpoints, integration tests |
| **Total Backend** | **18** | - | **~2.5 days** |

### Frontend (cpr-ui)

| Phase | Estimated Hours | Actual Hours | Notes |
|-------|----------------|--------------|-------|
| Phase 1: Foundation | 12 | - | Types, services, hooks, routing setup |
| Phase 3: UI Implementation | 32 | - | 9 components, forms, pages, offline detection |
| Phase 4: Advanced Features | 24 | - | Drag-drop, offline sync, i18n, auto-save, optimistic updates |
| Phase 5: Testing & Polish | 20 | - | Unit tests, E2E tests, performance, accessibility |
| **Total Frontend** | **88** | - | **~11 days** |

### Overall Estimate

**Total Estimated Effort**: 106 hours (~13.5 days at 8 hours/day)

**Breakdown by Role**:
- Backend Developer: 18 hours (2.5 days)
- Frontend Developer: 88 hours (11 days)
- QA/Testing: Included in phase estimates above

**Critical Path**: Frontend development (11 days) - backend work can be parallelized

---

## Success Metrics

### Functional Metrics
- [ ] All 80+ acceptance criteria met from user stories US-001 to US-005
- [ ] All 5 user stories fully implemented and demoed
- [ ] Zero critical bugs in production after 1 week
- [ ] Zero P0/P1 bugs in production after 2 weeks

### Quality Metrics
- [ ] Backend code coverage > 80% (unit tests for new endpoints)
- [ ] Frontend code coverage > 80% (components, hooks, services)
- [ ] All unit tests passing (Vitest)
- [ ] All E2E tests passing (Playwright) - 4 critical flows
- [ ] Zero security vulnerabilities (OWASP scan, dependency audit)
- [ ] Accessibility score > 95 (Lighthouse, axe DevTools)
- [ ] Performance score > 90 (Lighthouse)
- [ ] Zero TypeScript errors, zero ESLint errors

### User Experience Metrics
- [ ] Goals list page loads in < 1.5s (95th percentile)
- [ ] Auto-save completes within 2s of last edit
- [ ] Offline sync queue processes within 5s of reconnection
- [ ] Drag-drop reorder feels responsive (< 100ms visual feedback)
- [ ] Search autocomplete shows results in < 500ms

### Adoption Metrics (Post-Launch)
- [ ] 50% of active users create at least 1 goal within first week
- [ ] 80% of goals have at least 1 task within first month
- [ ] Average 3-5 goals per active user within first month
- [ ] < 5% bounce rate on goals list page
- [ ] < 2% error rate on goal create/update operations

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
   - Decision: [To be decided/Decided on 2025-11-11: [decision]]

---

## References

- Specification: `specifications/0001-[feature-name]/description.md`
- Tasks: `specifications/0001-[feature-name]/tasks.md`
- Endpoints: `specifications/0001-[feature-name]/endpoints.md`
- Data Model: `specifications/0001-[feature-name]/data-model.md` (if applicable)
- Research: `specifications/0001-[feature-name]/research.md` (if applicable)
- Constitution: `constitution.md`
- Architecture: `architecture.md`

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| 2025-11-11 | [Name] | Initial plan created |
