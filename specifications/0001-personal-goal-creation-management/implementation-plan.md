# Implementation Plan - Personal Goal Creation Management

> **Feature**: 0001 - personal-goal-creation-management  
> **Status**: Planning  
> **Created**: 2025-11-07  
> **Last Updated**: 2025-11-07

---

## Executive Summary

This implementation plan covers the Personal Goal Creation & Management feature, enabling employees to create skill-based development goals linked to career progression. The feature integrates with the existing skills taxonomy system, providing skill recommendations one level above the employee's current position. Implementation spans backend API endpoints, database migrations for soft delete support, and a comprehensive React UI with offline capabilities. The approach prioritizes constitutional compliance, particularly around type safety, API contracts, and offline-first design with optimistic UI updates.

---

## Constitutional Compliance Check

Review against all 11 CPR Constitutional Principles:

### ✅ Principle 1: Specification-First Development
- [x] Complete specification exists in `description.md`
- [x] All requirements clearly documented
- [x] Stakeholder approval obtained

**Status**: PASS  
**Notes**: Phase 1 (Specify) and Phase 2 (Refine) completed. All 10 clarifying questions answered by stakeholders. Specification version 2.0.0 approved for implementation.

### ✅ Principle 2: API Contract Consistency
- [x] C# DTOs defined and match specification
- [x] TypeScript interfaces defined and match C# DTOs
- [x] JSON naming uses snake_case
- [x] Property mappings documented

**Status**: PASS  
**Notes**: DTOs fully specified in description.md. CreateGoalDto, GoalDto, UpdateGoalDto, AvailableSkillDto in C#. Matching TypeScript interfaces with snake_case JSON property names via [JsonPropertyName] attributes.

### ✅ Principle 3: API Standards & Security
- [x] RESTful endpoints follow conventions
- [x] HTTP methods used correctly (GET, POST, PATCH, DELETE)
- [x] Standard status codes defined (200, 201, 400, 401, 403, 404, 500)
- [x] Error responses standardized
- [x] Authentication/authorization specified

**Status**: PASS  
**Notes**: 8 RESTful endpoints defined. JWT authentication required. Role-based authorization (Employee/Manager/Admin). Rate limiting: 100 req/min. Manager access via employees.manager_id FK.

### ✅ Principle 4: Type Safety Everywhere
- [x] C# DTOs use strong typing with validation attributes
- [x] TypeScript interfaces use strict types (no `any`)
- [x] Enums defined where applicable
- [x] Nullable types properly handled

**Status**: PASS  
**Notes**: C# DTOs use [Required], [MinLength], [MaxLength], [RegularExpression] attributes. TypeScript uses strict literal types (GoalStatus = 'active' | 'completed' | 'archived'). UpdateGoalDto uses nullable types for optional fields.

### ✅ Principle 5: Offline Mode
- [x] Offline capabilities identified
- [x] Data caching strategy defined
- [x] Sync mechanism specified
- [x] Conflict resolution approach documented

**Status**: PASS  
**Notes**: Goals cached in IndexedDB via React Query persistent cache. Offline: view/create only. Updates/deletes show error message. Optimistic updates online with rollback on failure. Server wins on sync conflicts.

### ✅ Principle 6: Internationalization
- [x] All UI text externalizable
- [x] i18n keys defined in translation files
- [x] Locale-specific formatting identified (dates, numbers)
- [x] Translation strategy documented

**Status**: PASS  
**Notes**: All labels/messages use i18n keys (goals.create, goals.status.active, etc.). Target dates formatted per user locale. Status values translatable. Tutorial text externalized for localization.

### ✅ Principle 7: Comprehensive Testing
- [x] Unit test strategy defined
- [x] Integration test scenarios identified
- [x] Performance test requirements specified
- [x] Test coverage targets set

**Status**: PASS  
**Notes**: Unit tests for validation, authorization, DTO mapping. Integration tests for CRUD workflows. Performance tests: 100 concurrent users, <200ms response (95th percentile). E2E tests for offline sync. Target: >80% coverage.

### ✅ Principle 8: Performance-First React Development
- [x] Performance targets defined (load time, response time)
- [x] React Query caching strategy specified
- [x] Component optimization approach documented
- [x] Lazy loading identified where appropriate

**Status**: PASS  
**Notes**: Goal list <1s load for 100 goals. React Query with staleTime=5min. Optimistic updates for immediate feedback. Virtual scrolling if needed. Tutorial lazy-loaded on first visit only.

### ✅ Principle 9: Strict Naming Conventions
- [x] JSON/API: snake_case verified
- [x] C# Properties: PascalCase with `[JsonPropertyName]` attributes
- [x] TypeScript: camelCase in code, snake_case in API types
- [x] Database: snake_case for tables/columns
- [x] URLs: kebab-case verified

**Status**: PASS  
**Notes**: All naming conventions followed. URLs: /api/v1/goals, /api/v1/me/available-skills. JSON: skill_id, target_date, progress_percentage. DB: goals table, is_deleted column.

### ✅ Principle 10: Security & Data Privacy
- [x] Authentication requirements specified
- [x] Authorization rules defined (role-based, resource-based)
- [x] Data encryption approach documented
- [x] Privacy controls identified
- [x] Sensitive data handling specified

**Status**: PASS  
**Notes**: JWT authentication required for all endpoints. RBAC: Employee (own goals), Manager (direct reports via manager_id), Admin (all). Input sanitization for XSS. Rate limiting 100 req/min. Soft delete preserves audit trail with deleted_by.

### ✅ Principle 11: Database Design Standards
- [x] Entities use UUIDs for primary keys
- [x] Proper foreign key constraints defined
- [x] Indexes identified for performance
- [x] Normalization level appropriate
- [x] Migration strategy planned

**Status**: PASS  
**Notes**: goals table uses UUID PK. FKs: user_id→users, skill_id→skills, deleted_by→users. Indexes on user_id, skill_id, status, is_deleted, created_at. Soft delete pattern. Migration adds is_deleted, deleted_at, deleted_by columns.

---

## Technical Context

### Technology Stack

**Backend (cpr-api)**:
- Framework: .NET 8 Web API
- Language: C# 12
- Database: PostgreSQL 16
- ORM: Entity Framework Core 8
- Authentication: JWT (existing)
- Key Libraries: FluentValidation, AutoMapper, Serilog

**Frontend (cpr-ui)**:
- Framework: React 18
- Language: TypeScript 5
- State Management: Zustand, React Query (TanStack Query v5)
- UI Library: Material-UI v6
- Build Tool: Vite
- Testing: Vitest, React Testing Library
- Key Libraries: react-hook-form, zod, date-fns, localforage (IndexedDB)

### Architecture Patterns

**Backend Patterns**:
- [x] Repository Pattern
- [x] Service Layer Pattern
- [x] Domain-Driven Design (Goal entity in Domain layer)
- [ ] CQRS (not applicable - simple CRUD)
- [x] Other: Authorization via custom attributes [Authorize(Roles)]

**Frontend Patterns**:
- [x] Component Composition (GoalList, GoalCard, GoalForm, etc.)
- [x] Custom Hooks (useGoals, useAvailableSkills, useOptimisticUpdate)
- [x] Context API (for tutorial state management)
- [ ] Higher-Order Components (not needed)
- [x] Other: Compound component pattern for GoalFilters

### Integration Points

List existing features/systems this feature integrates with:

1. **User Authentication System**
   - Integration Type: Dependency - JWT middleware
   - Impact: All endpoints require authenticated user
   - Files Affected: Controllers use [Authorize] attribute

2. **Employee Management System**
   - Integration Type: Database FK - employees.manager_id
   - Impact: Manager authorization depends on manager_id relationship
   - Files Affected: GoalsService checks manager_id for authorization

3. **Skills Taxonomy System**
   - Integration Type: Database FK - skills, positions tables
   - Impact: Available skills filtered by employee position and current skill level
   - Files Affected: SkillsService, GET /api/v1/me/available-skills endpoint

4. **Task Management System (Future)**
   - Integration Type: Event-driven - task completion triggers progress update
   - Impact: Progress percentage auto-calculated when tasks complete
   - Files Affected: GoalsService.UpdateProgress() method

### Dependencies

**External Dependencies**:
- [ ] New NuGet packages: None (using existing libraries)
- [ ] New npm packages: None (using existing libraries)
- [ ] External APIs: None

**Internal Dependencies**:
- [x] User authentication system (already exists)
- [x] Employee management with manager_id (already exists)
- [x] Skills taxonomy system (already exists)
- [ ] Task management system (future - for progress calculation)
- [x] Shared UI components (Button, TextField, DatePicker from MUI)
- [x] i18n framework (already configured)

---

## Implementation Phases

### Phase 1: Backend Foundation (2-3 days)

**Duration**: 2-3 days

**Objectives**:
- Create database schema with migration
- Implement domain models and DTOs
- Set up repository and service layers
- Implement core business logic

**Deliverables**:
- [x] Database migration for goals table (with soft delete columns)
- [x] Goal entity in Domain layer
- [x] CreateGoalDto, GoalDto, UpdateGoalDto, AvailableSkillDto
- [x] IGoalsRepository interface and implementation
- [x] GoalsService with business logic
- [x] Authorization logic (owner/manager/admin checks)
- [x] Unit tests for service layer (>80% coverage)
- [ ] TypeScript types and interfaces (cpr-ui)

**Key Files** (Backend):
```
src/CPR.Domain/Entities/Goal.cs
src/CPR.Application/DTOs/Goals/CreateGoalDto.cs
src/CPR.Application/DTOs/Goals/GoalDto.cs
src/CPR.Application/DTOs/Goals/UpdateGoalDto.cs
src/CPR.Application/DTOs/Goals/AvailableSkillDto.cs
src/CPR.Infrastructure/Repositories/Implementations/GoalsRepository.cs
src/CPR.Application/Interfaces/Repositories/IGoalsRepository.cs
src/CPR.Application/Services/Implementations/GoalsService.cs
src/CPR.Application/Interfaces/Services/IGoalsService.cs
src/CPR.Infrastructure/Data/Migrations/YYYYMMDDHHMMSS_AddGoalsTableWithSoftDelete.cs
```

**Key Files** (Frontend):
```
src/types/goals.ts
src/dtos/goals.ts
```

---

### Phase 2: Backend API Implementation (3-4 days)

**Duration**: 3-4 days

**Objectives**:
- Implement all CRUD API endpoints (8 endpoints)
- Add request validation with FluentValidation
- Implement authorization policies (owner/manager/admin)
- Add comprehensive error handling
- Implement available skills filtering logic

**Deliverables**:
- [ ] GoalsController with 8 endpoints implemented
- [ ] Request validation for all DTOs
- [ ] Authorization checks (owner, manager via manager_id, admin)
- [ ] Error responses standardized
- [ ] Skill filtering service for next-level skills
- [ ] Integration tests for all endpoints
- [ ] Postman collection or similar for API testing

**Key Files** (Backend):
```
src/CPR.Api/Controllers/GoalsController.cs
src/CPR.Application/Services/Implementations/GoalsService.cs
src/CPR.Application/Services/Implementations/SkillsService.cs (for available skills)
src/CPR.Application/Validators/CreateGoalDtoValidator.cs
src/CPR.Application/Validators/UpdateGoalDtoValidator.cs
src/CPR.Application/Authorization/GoalAuthorizationHandler.cs (if using policy-based)
tests/CPR.Tests/Integration/Controllers/GoalsControllerTests.cs
```

---

### Phase 3: Frontend UI Implementation (4-6 days)

**Duration**: 4-6 days

**Objectives**:
- Create React components for goal management
- Implement state management with Zustand
- Add API integration with React Query
- Implement offline support with IndexedDB
- Add optimistic updates for better UX
- Implement tutorial/onboarding flow
- Add internationalization

**Deliverables**:
- [ ] GoalsList component with filtering and sorting
- [ ] GoalForm component (create/edit)
- [ ] GoalCard component for individual goal display
- [ ] SkillSelect component with filtered skills
- [ ] Zustand store for tutorial state
- [ ] React Query hooks (useGoals, useCreateGoal, useUpdateGoal, useDeleteGoal)
- [ ] goalsService for API calls
- [ ] Offline caching configured in React Query
- [ ] Optimistic update logic with rollback
- [ ] Error handling and loading states
- [ ] Tutorial component (first-time users)
- [ ] i18n keys and translations

**Key Files** (Frontend):
```
src/components/Goals/GoalsList.tsx
src/components/Goals/GoalForm.tsx
src/components/Goals/GoalCard.tsx
src/components/Goals/GoalFilters.tsx
src/components/Goals/SkillSelect.tsx
src/components/Goals/TutorialDialog.tsx
src/stores/tutorialStore.ts
src/services/goalsService.ts
src/hooks/queries/useGoalsQuery.ts
src/hooks/queries/useAvailableSkillsQuery.ts
src/hooks/mutations/useGoalMutations.ts
src/utils/offline/goalsCacheConfig.ts
src/locales/en/goals.json
src/locales/en/tutorial.json
```

---

### Phase 4: Testing & Quality Assurance (3-4 days)

**Duration**: 3-4 days

**Objectives**:
- Write comprehensive unit tests (>80% coverage)
- Write integration tests for API workflows
- Perform performance testing (100 concurrent users)
- Conduct security review
- Perform accessibility audit
- Test offline sync scenarios

**Deliverables**:
- [ ] Backend unit tests for GoalsService (>80% coverage)
- [ ] Backend integration tests for GoalsController
- [ ] Frontend unit tests for all components
- [ ] Frontend integration tests for goal workflows
- [ ] Performance tests (load testing with 100 users)
- [ ] Security review checklist completed
- [ ] Accessibility audit (WCAG 2.1 AA)
- [ ] Offline sync tests (create offline, sync online)
- [ ] Authorization tests (employee/manager/admin roles)

**Key Files** (Testing):
```
tests/CPR.Tests/Services/GoalsServiceTests.cs
tests/CPR.Tests/Repositories/GoalsRepositoryTests.cs
tests/CPR.Tests/Integration/Controllers/GoalsControllerTests.cs
tests/CPR.Tests/Authorization/GoalAuthorizationTests.cs
src/components/Goals/__tests__/GoalsList.test.tsx
src/components/Goals/__tests__/GoalForm.test.tsx
src/components/Goals/__tests__/GoalCard.test.tsx
src/hooks/__tests__/useGoalsQuery.test.ts
src/services/__tests__/goalsService.test.ts
tests/performance/goals-load-test.js
```

---

### Phase 5: Documentation & Deployment (1-2 days)

**Duration**: 1-2 days

**Objectives**:
- Complete API documentation
- Update user documentation
- Test database migration in staging
- Prepare deployment checklist
- Create rollback plan

**Deliverables**:
- [ ] API endpoints documented (OpenAPI/Swagger)
- [ ] User guide updated with goal management instructions
- [ ] Migration tested in staging environment
- [ ] Deployment checklist completed
- [ ] Rollback script tested
- [ ] Release notes prepared
- [ ] Demo video or screenshots

**Key Files** (Documentation):
```
docs/api/goals-endpoints.md
docs/user-guide/personal-goals.md
docs/deployment/migration-guide.md
docs/deployment/rollback-procedures.md
RELEASE_NOTES.md
```

---

## Data Model Changes

### New Entities

#### Goal

**Table**: `goals` (snake_case)

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `user_id` | UUID | NOT NULL, FK → users(id) | Goal owner |
| `skill_id` | UUID | NOT NULL, FK → skills(id) | Target skill |
| `description` | VARCHAR(500) | NOT NULL, CHECK (length ≥ 10) | Goal description |
| `target_date` | DATE | NOT NULL | Target completion date |
| `progress_percentage` | INTEGER | DEFAULT 0, CHECK (0-100) | Completion progress |
| `status` | VARCHAR(20) | NOT NULL, DEFAULT 'active' | Goal status (active/completed/archived) |
| `is_deleted` | BOOLEAN | NOT NULL, DEFAULT FALSE | Soft delete flag |
| `deleted_at` | TIMESTAMP | NULL | When goal was deleted |
| `deleted_by` | UUID | NULL, FK → users(id) | Who deleted the goal |
| `created_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL, DEFAULT NOW() | Last update timestamp |

**Indexes**:
- `idx_goals_user_id` on `user_id` WHERE `is_deleted = FALSE` (for user goal queries)
- `idx_goals_skill_id` on `skill_id` (for skill-based filtering)
- `idx_goals_status` on `status` WHERE `is_deleted = FALSE` (for status filtering)
- `idx_goals_is_deleted` on `is_deleted` (for soft delete queries)
- `idx_goals_created_at` on `created_at DESC` (for sorting)

**Foreign Keys**:
- `user_id` → `users(id)` ON DELETE CASCADE
- `skill_id` → `skills(id)` ON DELETE RESTRICT
- `deleted_by` → `users(id)` ON DELETE SET NULL

**C# Domain Model**:
```csharp
// Location: src/CPR.Domain/Entities/Goal.cs
public class Goal
{
    public Guid Id { get; set; }
    public Guid UserId { get; set; }
    public Guid SkillId { get; set; }
    public string Description { get; set; } = string.Empty;
    public DateOnly TargetDate { get; set; }
    public int ProgressPercentage { get; set; } = 0;
    public string Status { get; set; } = "active";
    public bool IsDeleted { get; set; } = false;
    public DateTime? DeletedAt { get; set; }
    public Guid? DeletedBy { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    
    // Navigation properties
    public User User { get; set; } = null!;
    public Skill Skill { get; set; } = null!;
    public User? DeletedByUser { get; set; }
}
```

### Modified Entities

**No existing entities modified** - This feature adds a new `goals` table only.

### Database Migrations

**Migration Name**: `AddGoalsTableWithSoftDelete`

**Changes**:
1. Create `goals` table with all columns and constraints
2. Add indexes on user_id, skill_id, status, is_deleted, created_at
3. Add foreign key constraints to users and skills tables
4. Create trigger for auto-updating updated_at timestamp
5. No seed data required (goals are user-generated)

**Up Migration** (EF Core):
```csharp
migrationBuilder.CreateTable(
    name: "goals",
    columns: table => new
    {
        id = table.Column<Guid>(type: "uuid", nullable: false, defaultValueSql: "gen_random_uuid()"),
        user_id = table.Column<Guid>(type: "uuid", nullable: false),
        skill_id = table.Column<Guid>(type: "uuid", nullable: false),
        description = table.Column<string>(type: "character varying(500)", maxLength: 500, nullable: false),
        target_date = table.Column<DateOnly>(type: "date", nullable: false),
        progress_percentage = table.Column<int>(type: "integer", nullable: false, defaultValue: 0),
        status = table.Column<string>(type: "character varying(20)", maxLength: 20, nullable: false, defaultValue: "active"),
        is_deleted = table.Column<bool>(type: "boolean", nullable: false, defaultValue: false),
        deleted_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: true),
        deleted_by = table.Column<Guid>(type: "uuid", nullable: true),
        created_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "NOW()"),
        updated_at = table.Column<DateTime>(type: "timestamp with time zone", nullable: false, defaultValueSql: "NOW()")
    },
    constraints: table =>
    {
        table.PrimaryKey("pk_goals", x => x.id);
        table.ForeignKey("fk_goals_users_user_id", x => x.user_id, "users", "id", onDelete: ReferentialAction.Cascade);
        table.ForeignKey("fk_goals_skills_skill_id", x => x.skill_id, "skills", "id", onDelete: ReferentialAction.Restrict);
        table.ForeignKey("fk_goals_users_deleted_by", x => x.deleted_by, "users", "id", onDelete: ReferentialAction.SetNull);
        table.CheckConstraint("chk_goals_description_length", "char_length(description) >= 10");
        table.CheckConstraint("chk_goals_progress_range", "progress_percentage >= 0 AND progress_percentage <= 100");
        table.CheckConstraint("chk_goals_status", "status IN ('active', 'completed', 'archived')");
    });

migrationBuilder.CreateIndex(
    name: "idx_goals_user_id",
    table: "goals",
    column: "user_id",
    filter: "is_deleted = false");

migrationBuilder.CreateIndex(
    name: "idx_goals_skill_id",
    table: "goals",
    column: "skill_id");

migrationBuilder.CreateIndex(
    name: "idx_goals_status",
    table: "goals",
    column: "status",
    filter: "is_deleted = false");

migrationBuilder.CreateIndex(
    name: "idx_goals_is_deleted",
    table: "goals",
    column: "is_deleted");

migrationBuilder.CreateIndex(
    name: "idx_goals_created_at",
    table: "goals",
    column: "created_at")
    .Annotation("Npgsql:IndexSortOrder", new[] { SortOrder.Descending });
```

**Rollback Strategy**:
```csharp
migrationBuilder.DropTable(name: "goals");
```

**Rollback Impact**: All user-created goals will be lost. Rollback should only be used in development/staging. Production rollback requires data backup and migration to alternative storage.

---

## API Endpoints Summary

See `endpoints.md` for complete endpoint specifications.

**Quick Reference** (8 endpoints):
- `GET /api/v1/goals` - List all goals (admin) or user's goals with filtering
- `GET /api/v1/goals/{id}` - Get single goal by ID (owner/manager/admin)
- `POST /api/v1/goals` - Create new goal
- `PATCH /api/v1/goals/{id}` - Update existing goal (partial update)
- `DELETE /api/v1/goals/{id}` - Soft delete goal (sets is_deleted=true)
- `GET /api/v1/me/goals` - Get current user's goals (convenience endpoint)
- `GET /api/v1/users/{id}/goals` - Get goals for specific user (manager/admin only)
- `GET /api/v1/me/available-skills` - Get skills available for goal creation (next level only)

---

## Risk Assessment

### Technical Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| Database migration fails in production | Low | High | Test migration in staging environment, maintain rollback script, schedule deployment during low-traffic window |
| Performance degradation with 100+ goals per user | Medium | Medium | Implement proper indexing (already planned), early performance testing with 10K goals, optimize queries with EXPLAIN ANALYZE |
| Offline sync conflicts (simultaneous edits) | Medium | Low | Clear error messaging to user, server version wins (simpler), log conflicts for analysis |
| Manager authorization logic complexity | Low | Medium | Thorough unit tests for manager_id relationship checks, integration tests with real employee hierarchy |
| Skill filtering logic incorrect (wrong skill levels) | Medium | Medium | Comprehensive unit tests for skill level calculation, manual QA with test positions, document expected behavior clearly |
| IndexedDB compatibility issues | Low | Low | Fallback to memory-only caching if IndexedDB unavailable, test on multiple browsers, graceful degradation |
| Tutorial component interferes with UX | Low | Low | Make tutorial dismissible, only show on first visit, provide "Show tutorial again" option in settings |

### Dependencies & Blockers

List any dependencies on external teams, services, or features:

1. **User Authentication System**
   - Status: Complete (already exists)
   - Impact if delayed: N/A - blocking dependency already resolved
   - Mitigation: N/A

2. **Employee Management System (manager_id relationship)**
   - Status: Complete (already exists)
   - Impact if delayed: Cannot implement manager authorization
   - Mitigation: N/A - already exists

3. **Skills Taxonomy System**
   - Status: Complete (already exists)
   - Impact if delayed: Cannot filter skills by level or position
   - Mitigation: N/A - already exists

4. **Task Management System (for progress calculation)**
   - Status: Future Enhancement
   - Impact if delayed: Progress percentage will remain manual/placeholder (set to 0)
   - Mitigation: Implement progress as editable field initially, auto-calculate when tasks system available

---

## Performance Considerations

### Performance Targets

- **API Response Time**: < 200ms at 95th percentile for all goal endpoints
- **Page Load Time**: < 1 second for goal list with up to 100 goals
- **Database Query Time**: < 50ms for indexed queries (user_id, skill_id)
- **Concurrent Users**: Support 100 concurrent users without degradation
- **UI Rendering**: < 100ms to render goal list after data received

### Optimization Strategies

**Backend**:
- [x] Database query optimization with proper indexes (user_id, skill_id, status, created_at)
- [ ] In-memory caching for available skills (changes infrequently) using IMemoryCache
- [ ] No pagination needed initially (expected < 100 goals per user), add later if needed
- [x] Async operations for all database calls (EF Core async methods)
- [ ] Query optimization: use `.AsNoTracking()` for read-only queries
- [ ] Soft delete filter applied at repository level (WHERE is_deleted = FALSE)
- [ ] Avoid N+1 queries by including related entities (Skill) with `.Include()`

**Frontend**:
- [x] React Query caching with 5-minute staleTime (goals don't change frequently)
- [x] IndexedDB persistence for offline access
- [ ] Lazy load Tutorial component (code splitting) - only load on first visit
- [x] Memoization of filtered/sorted goals with useMemo
- [ ] Optimistic updates for immediate feedback (create/update/delete)
- [ ] No virtual scrolling needed initially (< 100 goals expected), add if needed
- [ ] Debounce filter/search inputs (300ms) to reduce re-renders

**Query Optimization Examples**:
```csharp
// Good: Single query with related data
var goals = await _context.Goals
    .AsNoTracking()
    .Include(g => g.Skill)
    .Where(g => g.UserId == userId && !g.IsDeleted)
    .OrderByDescending(g => g.CreatedAt)
    .ToListAsync();

// Bad: N+1 query (avoid this)
var goals = await _context.Goals.Where(g => g.UserId == userId).ToListAsync();
foreach (var goal in goals) {
    var skill = await _context.Skills.FindAsync(goal.SkillId); // N+1 problem
}
```

---

## Security Considerations

### Authentication & Authorization

**Authentication**:
- Method: JWT Bearer tokens (existing system)
- Token storage: HttpOnly cookies (secure, not accessible via JavaScript)
- Token expiration: 60 minutes with refresh token
- All endpoints require `[Authorize]` attribute

**Authorization Rules**:
1. **Employee Role**: 
   - Can CRUD own goals only (UserId == ClaimsPrincipal.UserId)
   - Cannot access other users' goals
   
2. **Manager Role**:
   - Can CRUD own goals
   - Can view direct reports' goals (via employees.manager_id relationship)
   - Cannot modify direct reports' goals (view-only for managers per spec clarification)
   
3. **Administrator Role**:
   - Can CRUD all goals
   - Can soft delete any goal
   - Can view deleted goals for audit

**Authorization Implementation**:
```csharp
// Service-level authorization
public async Task<GoalDto> GetGoalAsync(Guid goalId, Guid requestingUserId, string[] roles)
{
    var goal = await _repository.GetByIdAsync(goalId);
    if (goal == null) throw new NotFoundException();
    
    // Owner can always access
    if (goal.UserId == requestingUserId) return goal;
    
    // Admin can always access
    if (roles.Contains("Administrator")) return goal;
    
    // Manager can access direct reports' goals
    if (roles.Contains("Manager"))
    {
        var isDirectReport = await _employeeRepository.IsDirectReportAsync(requestingUserId, goal.UserId);
        if (isDirectReport) return goal;
    }
    
    throw new ForbiddenException();
}
```

**Rate Limiting**:
- 100 requests per minute per user for goal endpoints
- Implemented via middleware (ASP.NET Core Rate Limiting)

### Data Protection

- [x] Sensitive data encrypted at rest (PostgreSQL encryption at rest)
- [x] HTTPS enforced for all communications (TLS 1.2+)
- [x] Input validation and sanitization (FluentValidation + HtmlSanitizer for description)
- [x] SQL injection prevention (EF Core parameterized queries)
- [x] XSS prevention (React auto-escaping + CSP headers)
- [x] CSRF protection (SameSite cookies + anti-forgery tokens)
- [x] No sensitive data in logs (goal descriptions may contain personal info - sanitize logs)

**Input Sanitization**:
```csharp
public class CreateGoalDtoValidator : AbstractValidator<CreateGoalDto>
{
    public CreateGoalDtoValidator()
    {
        RuleFor(x => x.Description)
            .NotEmpty()
            .Length(10, 500)
            .Must(BeValidHtml).WithMessage("Description contains invalid HTML or scripts");
        
        RuleFor(x => x.TargetDate)
            .GreaterThan(DateOnly.FromDateTime(DateTime.UtcNow))
            .WithMessage("Target date must be in the future");
        
        RuleFor(x => x.SkillId)
            .NotEmpty()
            .Must(BeValidSkillForUser).WithMessage("Invalid skill for your position and level");
    }
}
```

---

## Effort Estimation

### Backend (cpr-api)

| Phase | Estimated Hours | Actual Hours | Notes |
|-------|----------------|--------------|-------|
| Phase 1: Foundation | 16-20 hours | - | Database migration, domain model, DTOs, repository/service scaffolding |
| Phase 2: API Implementation | 24-32 hours | - | 8 endpoints, validation, authorization, skill filtering logic, error handling |
| Phase 4: Testing (Backend) | 16-20 hours | - | Unit tests (services, repositories), integration tests (controllers), authorization tests |
| **Total Backend** | **56-72 hours** | - | **~7-9 days** |

### Frontend (cpr-ui)

| Phase | Estimated Hours | Actual Hours | Notes |
|-------|----------------|--------------|-------|
| Phase 1: Foundation | 8-12 hours | - | TypeScript types, DTOs, service layer setup |
| Phase 3: UI Implementation | 32-48 hours | - | 6 components, state management, API integration, offline support, optimistic updates, tutorial, i18n |
| Phase 4: Testing (Frontend) | 16-24 hours | - | Component tests, hook tests, integration tests, accessibility audit |
| **Total Frontend** | **56-84 hours** | - | **~7-10.5 days** |

### Cross-Functional Tasks

| Task | Estimated Hours | Actual Hours | Notes |
|------|----------------|--------------|-------|
| Phase 5: Documentation | 8-12 hours | - | API docs, user guide, deployment checklist, release notes |
| Performance Testing | 4-6 hours | - | Load testing with 100 concurrent users, query optimization |
| Security Review | 4-6 hours | - | Authorization testing, input validation review, penetration testing basics |
| **Total Cross-Functional** | **16-24 hours** | - | **~2-3 days** |

### Overall Estimate

**Total Estimated Effort**: 128-180 hours (16-22.5 days at 8 hours/day)

**Realistic Timeline**: 3-4 weeks with 1-2 developers

**Breakdown by Role**:
- Backend Developer: 56-72 hours (~7-9 days)
- Frontend Developer: 56-84 hours (~7-10.5 days)
- QA/Testing: 16-24 hours (~2-3 days, can overlap with development)
- DevOps/Documentation: 16-24 hours (~2-3 days)

**Assumptions**:
- Developers are familiar with CPR codebase and tech stack
- No major blockers or dependencies
- Includes 20% buffer for unexpected issues
- Code review time included in estimates
- Assumes parallel work (backend and frontend can progress simultaneously after contracts defined)

---

## Success Metrics

### Functional Metrics
- [ ] All acceptance criteria met
- [ ] All user stories implemented
- [ ] Zero critical bugs in production

### Quality Metrics
- [ ] Code coverage > 80%
- [ ] All tests passing
- [ ] Zero security vulnerabilities
- [ ] Accessibility score > 95

### Performance Metrics
- [ ] API response time targets met
- [ ] Page load time targets met
- [ ] No performance regressions

---

## Open Questions & Decisions Needed

All questions resolved during Phase 2 (Refine). No open questions remain.

### Decisions Made (for reference):

1. **Manager Edit Permissions**
   - Context: Can managers edit direct reports' goals or only view?
   - Options: (a) View only, (b) Full edit access
   - Decision: **View only** - Managers can view but not edit direct reports' goals. Goals are personal to the employee.
   - Decided: 2025-11-07 (Phase 2)

2. **Offline Update/Delete Support**
   - Context: Should users be able to update/delete goals offline?
   - Options: (a) Queue offline, (b) Show error message
   - Decision: **Show error message** - Updates and deletes require internet connection. Only view and create supported offline.
   - Decided: 2025-11-07 (Phase 2)

3. **Progress Calculation**
   - Context: How is progress_percentage calculated?
   - Options: (a) Manual entry, (b) Auto-calculate from tasks
   - Decision: **Auto-calculate from tasks** - When task management system is available, progress auto-updates. Until then, set to 0.
   - Decided: 2025-11-07 (Phase 2)

4. **Skill Filtering Logic**
   - Context: Which skills should appear in goal creation dropdown?
   - Options: (a) All skills, (b) Next level only, (c) All higher levels
   - Decision: **Next level only** - Show skills one level above employee's current level for their position.
   - Decided: 2025-11-07 (Phase 2)

5. **Soft Delete Implementation**
   - Context: Hard delete or soft delete for goals?
   - Options: (a) Hard delete, (b) Soft delete
   - Decision: **Soft delete** - Use is_deleted flag to preserve audit trail. Add deleted_at and deleted_by fields.
   - Decided: 2025-11-07 (Phase 2)

---

## References

- Specification: `specifications/0001-personal-goal-creation-management/description.md`
- Tasks: `specifications/0001-personal-goal-creation-management/tasks.md`
- Endpoints: `specifications/0001-personal-goal-creation-management/endpoints.md`
- Data Model: `specifications/0001-personal-goal-creation-management/data-model.md`
- Research: `specifications/0001-personal-goal-creation-management/research.md`
- Constitution: `../../constitution.md`
- Architecture: `../../architecture.md`

---

## Change Log

| Date | Author | Changes |
|------|--------|---------|
| 2025-11-07 | GitHub Copilot | Initial plan created using phase-3-plan.md prompt |
| 2025-11-07 | GitHub Copilot | Completed all sections with real content from spec |
