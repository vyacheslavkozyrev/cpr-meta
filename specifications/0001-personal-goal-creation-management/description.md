---
type: feature_specification
feature_number: 0001
feature_name: personal-goal-creation-management
version: 2.0.0
created: 2025-11-07
last_updated: 2025-11-07
status: refined
phase: 2_refine
repositories:
  - cpr-meta
  - cpr-api
  - cpr-ui
related_documents:
  - ../../constitution.md
  - ../../architecture.md
---

# Personal Goal Creation & Management

> **Specification ID**: SPEC-0001  
> **Feature**: personal-goal-creation-management  
> **Priority**: High  
> **Complexity**: Medium

## Executive Summary

Users can create, update, delete, and track personal and professional development goals with descriptions, target dates, categories, and progress tracking. The system enforces goal ownership with manager/admin override capabilities while ensuring proper authorization and validation. This feature provides the foundation for employee development tracking and performance management.

**Business Impact**: Enables structured employee development tracking, increasing engagement and providing measurable progress metrics for career growth.

---

## Core User Stories

### US-001: Create Personal Goal
**As a** CPR user (Administrator, Manager, or Employee)  
**I want** to create a new personal or professional development goal  
**So that** I can track my career progress and development objectives

**Acceptance Criteria**:
- [ ] User can input goal description (max 500 characters)
- [ ] User can set a target date (must be future date)
- [ ] User selects a skill from dropdown populated with skills from next skill level for their position
- [ ] Skill dropdown shows only skills one level above employee's current skill level
- [ ] System validates all required fields before saving
- [ ] System assigns unique UUID to new goal
- [ ] System records creation timestamp and user ID
- [ ] First-time users see tutorial/onboarding flow explaining goal creation
- [ ] Tutorial explains how goals relate to skill advancement and career progression

### US-002: View My Goals
**As a** CPR user  
**I want** to view all my goals  
**So that** I can track my development objectives

**Acceptance Criteria**:
- [ ] User can view list of all their goals (expected: dozens, max ~100)
- [ ] Goals display description, skill, target date, progress percentage, and status
- [ ] Goals can be filtered by skill or status (active, completed, archived)
- [ ] System shows only goals owned by current user (unless manager/admin)
- [ ] UI loads within 1 second with up to 100 goals
- [ ] No pagination needed (expected goal count per user: < 100)

### US-003: Update Goal Progress
**As a** CPR user  
**I want** to update my goal's description, target date, or skill  
**So that** I can keep my development plan current

**Acceptance Criteria**:
- [ ] User can modify goal description
- [ ] User can change target date (can update even if previous date passed)
- [ ] User can change target skill from dropdown (same filtering: next level skills)
- [ ] Updates show immediately in UI (optimistic update), then sync to server
- [ ] If sync fails, UI reverts to previous state and shows error
- [ ] Progress percentage updates automatically when associated tasks are completed
- [ ] System validates updates before saving
- [ ] System records updated_at timestamp
- [ ] Only goal owner can update (unless manager/admin override)

### US-004: Delete Goal
**As a** CPR user  
**I want** to delete a goal  
**So that** I can remove outdated or irrelevant objectives

**Acceptance Criteria**:
- [ ] User can delete their own goals
- [ ] System prompts for confirmation before deletion
- [ ] Manager can delete direct report goals
- [ ] Admin can delete any goal
- [ ] Deletion is soft delete (sets is_deleted flag, preserves record)
- [ ] Deleted goals are hidden from UI but retained in database for audit
- [ ] Deleted goals include deleted_at timestamp and deleted_by user_id

### US-005: Manager View Employee Goals
**As a** Manager  
**I want** to view goals of my direct reports  
**So that** I can support their development and track team progress

**Acceptance Criteria**:
- [ ] Manager can view all goals of direct reports
- [ ] Manager can filter by employee or skill
- [ ] System enforces manager-employee relationship via employees.manager_id
- [ ] Manager relationship determined by employees table: employee.manager_id references manager's employee record
- [ ] Only direct reports' goals visible (no skip-level access unless admin)
- [ ] Manager can add comments or feedback (future enhancement noted)

### US-006: Offline Goal Management
**As a** CPR user  
**I want** to manage goals when offline  
**So that** I can work without internet connectivity

**Acceptance Criteria**:
- [ ] Goals cached in IndexedDB for offline viewing
- [ ] User can create goals offline (queued for sync)
- [ ] User can view cached goals offline
- [ ] When attempting offline update/delete, system displays error message explaining offline limitation
- [ ] Error message: "This action requires internet connection. Changes will not be saved."
- [ ] When connection restored, offline-created goals sync to server
- [ ] Sync conflicts (simultaneous edits) show error to user, server version wins
- [ ] Offline indicator shows current sync status in UI

---

## Business Rules

1. **Goal Ownership**: Users can only create, view, update, and delete their own goals unless they are managers (can manage direct reports' goals) or administrators (can manage all goals)
2. **Target Date Validation**: Goal target dates must be in the future at creation time; existing goals can update target date to any date (past or future)
3. **Description Length**: Goal descriptions must be between 10 and 500 characters to ensure meaningful content without verbosity
4. **Authorization Hierarchy**: Employees < Managers < Administrators, with each level inheriting lower-level permissions plus additional capabilities
5. **Data Integrity**: All goal operations maintain referential integrity with user records and audit trails with created_at/updated_at timestamps
6. **Skill-Based Goals**: Goals must be associated with a skill one level above employee's current skill level for their position
7. **Soft Delete Only**: All deletions are soft deletes with is_deleted flag; records retained for audit compliance
8. **Progress Automation**: Progress percentage calculated automatically based on completed tasks associated with goal
9. **Manager Relationship**: Manager access determined via employees.manager_id referencing manager's employee record
10. **Offline Limitations**: Goal updates and deletes require internet connection; only creation and viewing supported offline

---

## Technical Requirements

### Performance
- API response time < 200ms (95th percentile) for goal CRUD operations
- UI goal list rendering < 1 second for up to 100 goals
- Database queries use proper indexing on user_id and created_at fields

### Security
- All endpoints require JWT authentication
- Authorization enforced at API level (owner, manager, admin roles)
- Input sanitization on all goal description fields to prevent XSS
- Rate limiting: 100 requests per minute per user for goal endpoints

### Offline Mode (Constitutional Principle 5)
- Goal list cached locally in IndexedDB for offline viewing
- Goal creation queued locally when offline, synced when connection restored
- Goal updates and deletes NOT supported offline - display error message
- Error message for offline update/delete: "This action requires internet connection. Changes will not be saved."
- Conflict resolution for create: server wins if simultaneous creation, show error to user
- Optimistic updates for online edits: show immediately, revert on failure
- Offline indicator shows current sync status in UI

### Internationalization (Constitutional Principle 6)
- All UI labels and messages externalized using i18n framework
- Date formatting respects user's locale (target dates)
- Goal categories support translation keys
- Error messages available in multiple languages

---

## API Design (Constitutional Principles 2, 3, 9)

### Endpoints
```
GET    /api/v1/goals                     # List all goals (admin) or user's goals
POST   /api/v1/goals                     # Create new goal
GET    /api/v1/goals/{id}                # Get specific goal
PATCH  /api/v1/goals/{id}                # Update goal (partial update)
DELETE /api/v1/goals/{id}                # Soft delete goal (sets is_deleted=true)
GET    /api/v1/me/goals                  # Get current user's goals (convenience endpoint)
GET    /api/v1/users/{id}/goals          # Get goals for specific user (manager/admin only)
GET    /api/v1/me/available-skills       # Get skills available for goal creation (next level skills)
```

### Request/Response Examples

**POST /api/v1/goals**
```json
Request:
{
  "description": "Complete Azure certification",
  "target_date": "2026-06-30",
  "skill_id": "a1b2c3d4-e5f6-4789-a012-3456789abcde"
}

Response (201 Created):
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
  "created_at": "2025-11-07T10:30:00Z",
  "updated_at": "2025-11-07T10:30:00Z",
  "is_deleted": false
}
```

**GET /api/v1/me/available-skills**
```json
Response (200 OK):
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

---

## Data Model (Constitutional Principle 11)

### Goals Table
```sql
CREATE TABLE goals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id),
  skill_id UUID NOT NULL REFERENCES skills(id),
  description VARCHAR(500) NOT NULL CHECK (char_length(description) >= 10),
  target_date DATE NOT NULL,
  progress_percentage INTEGER DEFAULT 0 CHECK (progress_percentage >= 0 AND progress_percentage <= 100),
  status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'completed', 'archived')),
  is_deleted BOOLEAN DEFAULT FALSE NOT NULL,
  deleted_at TIMESTAMP,
  deleted_by UUID REFERENCES users(id),
  created_at TIMESTAMP DEFAULT NOW() NOT NULL,
  updated_at TIMESTAMP DEFAULT NOW() NOT NULL
);

CREATE INDEX idx_goals_user_id ON goals(user_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_goals_skill_id ON goals(skill_id);
CREATE INDEX idx_goals_status ON goals(status) WHERE is_deleted = FALSE;
CREATE INDEX idx_goals_is_deleted ON goals(is_deleted);
CREATE INDEX idx_goals_created_at ON goals(created_at DESC);
```

### Employees Table (Existing - Referenced for Manager Relationship)
```sql
-- employees table structure (existing)
employees (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  manager_id UUID REFERENCES employees(id),  -- Manager relationship
  position_id UUID REFERENCES positions(id),
  ...
);
```

### Business Constraints
- `user_id` must reference existing user
- `skill_id` must reference skill one level above employee's current level
- `description` length between 10-500 characters
- `target_date` must be future at creation, can be updated to any date
- `status` restricted to: active, completed, archived
- `progress_percentage` between 0-100, auto-calculated from tasks
- `is_deleted` enables soft delete pattern
- `deleted_at` and `deleted_by` track deletion audit trail

---

## Type Safety (Constitutional Principles 2, 4, 9)

### C# DTOs (cpr-api)
```csharp
namespace CPR.Application.DTOs;

public class CreateGoalDto
{
    [JsonPropertyName("description")]
    [Required]
    [MinLength(10)]
    [MaxLength(500)]
    public string Description { get; set; } = string.Empty;

    [JsonPropertyName("target_date")]
    [Required]
    public DateOnly TargetDate { get; set; }

    [JsonPropertyName("skill_id")]
    [Required]
    public Guid SkillId { get; set; }
}

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

### TypeScript Interfaces (cpr-ui)
```typescript
export type GoalStatus = 'active' | 'completed' | 'archived';

export interface CreateGoalRequest {
  description: string;
  target_date: string; // ISO date format: YYYY-MM-DD
  skill_id: string;
}

export interface Goal {
  id: string;
  user_id: string;
  description: string;
  target_date: string;
  skill_id: string;
  skill_name: string;
  skill_level: number;
  progress_percentage: number;
  status: GoalStatus;
  is_deleted: boolean;
  created_at: string; // ISO datetime
  updated_at: string; // ISO datetime
}

export interface UpdateGoalRequest {
  description?: string;
  target_date?: string;
  skill_id?: string;
  status?: GoalStatus;
}

export interface AvailableSkill {
  skill_id: string;
  skill_name: string;
  current_level: number;
  target_level: number;
  position_name: string;
}
```

---

## Testing Strategy (Constitutional Principle 7)

### Unit Tests
- **Goal Validation**: Test description length (min 10, max 500), future date validation on creation, skill_id validation
- **Skill Level Logic**: Verify only skills one level above current level are available
- **Authorization Logic**: Test owner, manager (via employees.manager_id), and admin permission checks
- **DTO Mapping**: Verify C# entity to DTO conversion preserves all fields correctly
- **Business Rules**: Test goal ownership rules, hierarchy permissions, data constraints
- **Soft Delete**: Verify is_deleted flag set correctly, deleted goals filtered from queries
- **Progress Calculation**: Test automatic progress percentage update when tasks complete

### Integration Tests
- **Goal CRUD Workflow**: Create → Read → Update → Soft Delete full lifecycle
- **Authorization Scenarios**: Employee accessing own goals, manager accessing reports' goals via manager_id, admin accessing all goals
- **Database Constraints**: Test FK constraints (user_id, skill_id), check constraints (status enum), soft delete filtering
- **API Contract**: Verify request/response JSON matches TypeScript interfaces
- **Skill Filtering**: Verify /api/v1/me/available-skills returns only next-level skills for employee's position
- **Optimistic Updates**: Test UI immediate update with server sync and rollback on failure

### Performance Tests
- **Load Test**: 100 concurrent users creating/reading goals, verify < 200ms response time
- **Query Performance**: Test goal list endpoint with 10,000 goals across 1,000 users
- **Indexing**: Verify queries use indexes (user_id, created_at, category)

### End-to-End Tests
- **Goal Creation Flow**: User logs in → sees tutorial (first time) → creates goal with skill selection → views in list → updates → soft deletes
- **Manager View**: Manager logs in → views direct reports' goals via manager_id → filters by skill/status
- **Offline Sync**: Create goal offline → go online → verify sync → attempt offline update → see error message → sync completes
- **Optimistic Update**: User edits goal → sees immediate change → network fails → sees rollback and error

---

## Success Metrics

- **Adoption Rate**: 80% of active users create at least one goal within first 30 days
- **Completion Time**: 95% of users complete goal creation in < 2 minutes
- **API Performance**: 95th percentile response time < 200ms for all goal endpoints
- **User Satisfaction**: Goal management feature rated ≥ 4.0/5.0 in user surveys
- **Data Quality**: < 5% of goals have validation errors or require correction after creation

---

## Constitutional Compliance ✅

- [x] **Principle 1**: Specification-First Development - Complete specification before implementation
- [x] **Principle 2**: API Contract Consistency - C# DTOs match TypeScript interfaces with snake_case JSON
- [x] **Principle 3**: RESTful API Standards - Proper HTTP methods, status codes, kebab-case URLs
- [x] **Principle 4**: Type Safety (C# + TypeScript) - Strongly typed DTOs with validation attributes
- [x] **Principle 5**: Offline Mode Support - IndexedDB caching, queue-based sync, conflict resolution
- [x] **Principle 6**: Internationalization - i18n framework, locale-specific date formatting, translatable categories
- [x] **Principle 7**: Comprehensive Testing - Unit, integration, performance, and E2E tests defined
- [x] **Principle 8**: Performance Requirements - < 200ms API response, < 1s UI rendering, indexed queries
- [x] **Principle 9**: Naming Conventions (snake_case JSON) - All JSON fields use snake_case, C# uses PascalCase with attributes
- [x] **Principle 10**: Security & Privacy - JWT auth, role-based authorization, input sanitization, rate limiting
- [x] **Principle 11**: Database Design Standards - UUID PKs, proper FKs, check constraints, indexes on user_id/created_at

---

## Dependencies & Assumptions

**Dependencies:**
- User authentication system (JWT tokens)
- User management system (users table with id, role)
- Employee management system (employees table with user_id, manager_id, position_id)
- Skills taxonomy system (skills, skill_levels, positions tables)
- Task management system (for progress calculation via task completion)
- Authorization middleware (role-based access control)
- PostgreSQL database (version 14+)

**Assumptions:**
- User roles (Employee, Manager, Administrator) are already defined and enforced
- Manager-employee relationships maintained via employees.manager_id
- Employees table links users to positions via position_id
- Skills and skill levels defined for each position
- Employee's current skill levels are tracked in system
- Users have stable internet connectivity for updates/deletes (offline only for view/create)
- Browser supports IndexedDB for offline storage
- Date inputs use ISO 8601 format (YYYY-MM-DD)
- Tutorial/onboarding system exists for first-time user guidance

---

**Next Phase**: Phase 2 (Refine) - Detailed requirements analysis

**GitHub Copilot Instructions**: This specification follows CPR constitutional principles and framework standards. Ready for Phase 2 refinement.
