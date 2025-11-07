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
src/CPR.Domain/Entities/[FeatureName].cs
src/CPR.Application/DTOs/[FeatureName]/
src/CPR.Infrastructure/Repositories/[FeatureName]Repository.cs
src/CPR.Application/Services/[FeatureName]Service.cs
```

**Key Files** (Frontend):
```
src/types/[featureName].ts
src/dtos/[featureName].ts
```

---

### Phase 2: Backend API Implementation

**Duration**: [X days/weeks]

**Objectives**:
- Implement API endpoints
- Add business logic
- Implement validation
- Add authorization

**Deliverables**:
- [ ] API endpoints implemented and tested
- [ ] Request validation added
- [ ] Business rules enforced
- [ ] Authorization policies applied
- [ ] Error handling implemented
- [ ] API documentation updated

**Key Files** (Backend):
```
src/CPR.Api/Controllers/[FeatureName]Controller.cs
src/CPR.Application/Services/Implementations/[FeatureName]Service.cs
src/CPR.Infrastructure/Repositories/Implementations/[FeatureName]Repository.cs
```

---

### Phase 3: Frontend UI Implementation

**Duration**: [X days/weeks]

**Objectives**:
- Create UI components
- Implement state management
- Add API integration
- Implement offline support

**Deliverables**:
- [ ] React components created
- [ ] Zustand stores implemented
- [ ] React Query hooks created
- [ ] API service layer implemented
- [ ] Offline caching configured
- [ ] Error handling and loading states
- [ ] Internationalization added

**Key Files** (Frontend):
```
src/components/[FeatureName]/
src/stores/[featureName]Store.ts
src/services/[featureName]Service.ts
src/hooks/queries/use[FeatureName]Query.ts
src/hooks/mutations/use[FeatureName]Mutations.ts
src/locales/en/[featureName].json
```

---

### Phase 4: Testing & Quality Assurance

**Duration**: [X days/weeks]

**Objectives**:
- Write unit tests
- Write integration tests
- Perform performance testing
- Conduct security review

**Deliverables**:
- [ ] Backend unit tests (>80% coverage)
- [ ] Frontend unit tests (>80% coverage)
- [ ] Integration tests
- [ ] Performance benchmarks met
- [ ] Security review completed
- [ ] Accessibility audit passed

**Key Files** (Testing):
```
tests/CPR.Tests/[FeatureName]/
src/components/[FeatureName]/__tests__/
```

---

### Phase 5: Documentation & Deployment

**Duration**: [X days/weeks]

**Objectives**:
- Complete API documentation
- Update user documentation
- Prepare deployment
- Create migration guides

**Deliverables**:
- [ ] API endpoints documented
- [ ] User guide updated
- [ ] Migration scripts tested
- [ ] Deployment checklist completed
- [ ] Rollback plan documented

---

## Data Model Changes

### New Entities

#### [Entity Name]

**Table**: `[table_name]` (snake_case)

**Columns**:
| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier |
| `created_at` | TIMESTAMP | NOT NULL | Creation timestamp |
| `updated_at` | TIMESTAMP | NOT NULL | Last update timestamp |
| `[field_name]` | [TYPE] | [CONSTRAINTS] | [Description] |

**Indexes**:
- `idx_[table]_[column]` on `[column_name]`

**Foreign Keys**:
- `[fk_column]` → `[referenced_table].[referenced_column]`

**C# Domain Model**:
```csharp
// Location: src/CPR.Domain/Entities/[EntityName].cs
public class [EntityName]
{
    public Guid Id { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    // Additional properties
}
```

### Modified Entities

List any existing entities that will be modified, with details of changes.

### Database Migrations

**Migration Name**: `Add[FeatureName]Tables`

**Changes**:
1. Create `[table_name]` table
2. Add indexes
3. Add foreign key constraints
4. Seed initial data (if applicable)

**Rollback Strategy**:
[Describe how to rollback this migration]

---

## API Endpoints Summary

See `endpoints.md` for complete endpoint specifications.

**Quick Reference**:
- `GET /api/v1/[resource]` - List all items
- `GET /api/v1/[resource]/{id}` - Get single item
- `POST /api/v1/[resource]` - Create new item
- `PUT /api/v1/[resource]/{id}` - Update existing item
- `DELETE /api/v1/[resource]/{id}` - Delete item

---

## Risk Assessment

### Technical Risks

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|---------------------|
| [Risk description] | [Low/Med/High] | [Low/Med/High] | [How to mitigate] |

### Dependencies & Blockers

List any dependencies on external teams, services, or features:

1. **[Dependency Name]**
   - Status: [Pending/In Progress/Complete]
   - Impact if delayed: [Description]
   - Mitigation: [Backup plan]

---

## Performance Considerations

### Performance Targets

- API Response Time: < [X]ms at 95th percentile
- Page Load Time: < [X]ms
- Database Query Time: < [X]ms
- Concurrent Users: Support [X] concurrent users

### Optimization Strategies

**Backend**:
- [ ] Database query optimization
- [ ] Caching strategy (Redis, in-memory)
- [ ] Pagination for large datasets
- [ ] Async operations where appropriate

**Frontend**:
- [ ] React Query caching
- [ ] Component lazy loading
- [ ] Memoization of expensive computations
- [ ] Virtual scrolling for large lists

---

## Security Considerations

### Authentication & Authorization

**Authentication**:
- Method: [JWT/OAuth/etc.]
- Token storage: [HttpOnly cookies/localStorage/etc.]
- Token expiration: [Duration]

**Authorization**:
- Role-based access control (RBAC)
- Resource-based permissions
- Policy requirements

### Data Protection

- [ ] Sensitive data encrypted at rest
- [ ] HTTPS enforced for all communications
- [ ] Input validation and sanitization
- [ ] SQL injection prevention (parameterized queries)
- [ ] XSS prevention (React escaping, CSP headers)
- [ ] CSRF protection

---

## Effort Estimation

### Backend (cpr-api)

| Phase | Estimated Hours | Actual Hours | Notes |
|-------|----------------|--------------|-------|
| Phase 1: Foundation | [X] | - | |
| Phase 2: API Implementation | [X] | - | |
| Phase 4: Testing | [X] | - | |
| **Total Backend** | **[X]** | - | |

### Frontend (cpr-ui)

| Phase | Estimated Hours | Actual Hours | Notes |
|-------|----------------|--------------|-------|
| Phase 1: Foundation | [X] | - | |
| Phase 3: UI Implementation | [X] | - | |
| Phase 4: Testing | [X] | - | |
| **Total Frontend** | **[X]** | - | |

### Overall Estimate

**Total Estimated Effort**: [X] hours ([Y] days at [Z] hours/day)

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

List any unresolved questions or decisions needed before implementation:

1. **[Question/Decision]**
   - Context: [Why this matters]
   - Options: [List alternatives]
   - Recommendation: [Preferred option]
   - Decision: [To be decided/Decided on 2025-11-07: [decision]]

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
| 2025-11-07 | [Name] | Initial plan created |
