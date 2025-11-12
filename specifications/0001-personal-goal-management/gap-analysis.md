# Gap Analysis: Feature 0001 Personal Goal Management

> **Document**: Gap Analysis Report  
> **Feature**: 0001 - personal-goal-management  
> **Analysis Date**: 2025-11-11  
> **Purpose**: Identify differences between existing backend implementation and Feature 0001 specification requirements

---

## Executive Summary

The backend API has **substantial existing implementation** (≈85% complete) with basic CRUD operations for goals and tasks. **Critical design decisions**:
1. ✅ **DECISION**: Skip `order_index` - tasks will be ordered by `created_at` (natural chronological order)
2. ✅ **DECISION**: Skip `category` field - goals will be organized by `related_skill_id` instead
3. ❌ **CRITICAL**: DTO naming convention violations (constitutional compliance)
4. ⏳ **PENDING**: Frontend implementation (0% complete)

**Recommendation**: Fix constitutional violations immediately, then proceed with frontend development.

---

## 1. Database Schema Analysis

### 1.1 Goals Table

| Column | Spec Required | Current Status | Gap |
|--------|---------------|----------------|-----|
| `id` | UUID PK | ✅ Implemented | None |
| `employee_id` | UUID FK NOT NULL | ✅ Implemented with FK constraint | None |
| `title` | VARCHAR(200) NOT NULL | ✅ TEXT NOT NULL | Minor (TEXT vs VARCHAR) |
| `description` | TEXT NULL | ✅ Implemented | None |
| `category` | VARCHAR(50) | ✅ **NOT NEEDED** (using related_skill_id) | **DECISION: SKIP** |
| `status` | VARCHAR(20) DEFAULT 'open' | ✅ TEXT DEFAULT 'open' | Minor (TEXT vs VARCHAR) |
| `priority` | SMALLINT NULL | ✅ Implemented | None |
| `target_completion_date` | DATE NULL | ⚠️ Called `deadline` (DATE) | Naming mismatch |
| `actual_completion_date` | DATE NULL | ❌ **MISSING** | **HIGH** |
| `progress_percentage` | NUMERIC(5,2) DEFAULT 0 | ✅ `progress_percent` NUMERIC(5,2) | Minor naming |
| `related_skill_id` | UUID FK NULL | ✅ Implemented | None |
| `related_skill_level_id` | UUID FK NULL | ✅ Implemented | None |
| `deadline` | DATE NULL | ✅ Implemented | Spec uses different name |
| `is_completed` | BOOLEAN DEFAULT FALSE | ✅ Implemented | None |
| `completed_at` | TIMESTAMPTZ NULL | ✅ Implemented | None |
| `visibility` | VARCHAR(20) NULL | ✅ TEXT NULL | Minor (TEXT vs VARCHAR) |
| `created_by` | UUID FK NULL | ✅ Implemented | None |
| `created_at` | TIMESTAMPTZ DEFAULT now() | ✅ Implemented | None |
| `modified_by` | UUID FK NULL | ✅ Implemented | None |
| `modified_at` | TIMESTAMPTZ NULL | ✅ Implemented | None |
| `is_deleted` | BOOLEAN DEFAULT FALSE | ✅ Implemented | None |
| `deleted_by` | UUID FK NULL | ✅ Implemented | None |
| `deleted_at` | TIMESTAMPTZ NULL | ✅ Implemented | None |

**Index Analysis**:
| Index | Spec Required | Current Status | Gap |
|-------|---------------|----------------|-----|
| `idx_goals_employee_id` | ✅ Required | ✅ Implemented | None |
| `idx_goals_status` | ✅ Required | ❌ **MISSING** | **MEDIUM** |
| `idx_goals_category` | ⏭️ Skipped (no category column) | ✅ **NOT NEEDED** | **DECISION: SKIP** |
| `idx_goals_deadline` | ✅ Required | ❌ **MISSING** | **MEDIUM** |
| `idx_goals_priority` | ✅ Required | ❌ **MISSING** | **MEDIUM** |
| `idx_goals_created_at` | ✅ Required | ❌ **MISSING** | **MEDIUM** |

**Gaps Summary**:
- ✅ **RESOLVED**: `category` column **NOT NEEDED** - using `related_skill_id` for organization
- ⚠️ **OPTIONAL**: Missing `actual_completion_date` column (can add later if needed)
- ⚠️ **OPTIONAL**: Missing 4 performance indexes (status, deadline, priority, created_at) - can add as needed
- ⚠️ **LOW**: Column naming inconsistencies (minor, not blocking)

---

### 1.2 Goal Tasks Table

| Column | Spec Required | Current Status | Gap |
|--------|---------------|----------------|-----|
| `id` | UUID PK | ✅ Implemented | None |
| `goal_id` | UUID FK NOT NULL CASCADE | ⚠️ Implemented but **NO FK CONSTRAINT** | **HIGH** |
| `title` | VARCHAR(200) NOT NULL | ✅ TEXT NOT NULL | Minor |
| `description` | TEXT NULL | ✅ Implemented | None |
| `deadline` | TIMESTAMPTZ NULL | ✅ Implemented | None |
| `is_completed` | BOOLEAN DEFAULT FALSE | ✅ Implemented | None |
| `completed_at` | TIMESTAMPTZ NULL | ✅ Implemented | None |
| `order_index` | INT DEFAULT 0 | ✅ **NOT NEEDED** (using created_at) | **DECISION: SKIP** |
| `created_by` | UUID FK NULL | ✅ Implemented | None |
| `created_at` | TIMESTAMPTZ DEFAULT now() | ✅ Implemented | None |
| `modified_by` | UUID FK NULL | ✅ Implemented | None |
| `modified_at` | TIMESTAMPTZ NULL | ✅ Implemented | None |
| `is_deleted` | BOOLEAN DEFAULT FALSE | ✅ Implemented | None |
| `deleted_by` | UUID FK NULL | ✅ Implemented | None |
| `deleted_at` | TIMESTAMPTZ NULL | ✅ Implemented | None |

**Index Analysis**:
| Index | Spec Required | Current Status | Gap |
|-------|---------------|----------------|-----|
| `idx_goal_tasks_goal_id_order` | ⏭️ Skipped (no order_index) | ✅ **NOT NEEDED** | **DECISION: SKIP** |
| `idx_goal_tasks_created_at` | ✅ Required | ❌ **MISSING** | **MEDIUM** |

**Gaps Summary**:
- ✅ **RESOLVED**: `order_index` column **NOT NEEDED** - tasks ordered by `created_at` (natural chronological order)
- ✅ **RESOLVED**: Composite index **NOT NEEDED** (no order_index column)
- ⚠️ **OPTIONAL**: No FK constraint on `goal_id` - existing CASCADE works, can formalize later
- ⚠️ **OPTIONAL**: Missing created_at index - performance optimization, add if needed

---

## 2. Domain Entity Analysis

### 2.1 Goal Entity (Goal.cs)

| Property | Spec Required | Current Status | Gap |
|----------|---------------|----------------|-----|
| `Id` | Guid | ✅ Implemented | None |
| `EmployeeId` | Guid | ✅ Implemented | None |
| `Title` | string | ✅ Implemented | None |
| `Description` | string? | ✅ Implemented | None |
| `Category` | string | ✅ **NOT NEEDED** (using RelatedSkillId) | **DECISION: SKIP** |
| `Status` | string | ✅ Implemented | None |
| `Priority` | short? | ✅ Implemented | None |
| `Deadline` | DateTime? | ✅ Implemented | None |
| `ActualCompletionDate` | DateTime? | ❌ **MISSING** | **HIGH** |
| `ProgressPercent` | decimal | ✅ Implemented | None |
| `RelatedSkillId` | Guid? | ✅ Implemented | None |
| `RelatedSkillLevelId` | Guid? | ✅ Implemented | None |
| `IsCompleted` | bool | ✅ Implemented | None |
| `CompletedAt` | DateTimeOffset? | ✅ Implemented | None |
| `Visibility` | string? | ✅ Implemented | None |

**Navigation Properties**:
- ✅ Inherits `AuditableEntity` (includes audit columns)
- ❌ **MISSING**: `Tasks` navigation property (ICollection<GoalTask>)

**Gaps Summary**:
- ✅ **RESOLVED**: `Category` property **NOT NEEDED** - using `RelatedSkillId` for organization
- ⚠️ **OPTIONAL**: Missing `ActualCompletionDate` property (can add if needed)
- ⚠️ **OPTIONAL**: Missing `Tasks` navigation property (EF Core works without it)

---

### 2.2 GoalTask Entity (GoalTask.cs)

| Property | Spec Required | Current Status | Gap |
|----------|---------------|----------------|-----|
| `Id` | Guid | ✅ Implemented | None |
| `GoalId` | Guid | ✅ Implemented | None |
| `Title` | string | ✅ Implemented | None |
| `Description` | string? | ✅ Implemented | None |
| `Deadline` | DateTimeOffset? | ✅ Implemented | None |
| `IsCompleted` | bool | ✅ Implemented | None |
| `CompletedAt` | DateTimeOffset? | ✅ Implemented | None |
| `OrderIndex` | int | ✅ **NOT NEEDED** (using CreatedAt) | **DECISION: SKIP** |

**Navigation Properties**:
- ✅ Inherits `AuditableEntity`
- ❌ **MISSING**: `Goal` navigation property

**Gaps Summary**:
- ✅ **RESOLVED**: `OrderIndex` property **NOT NEEDED** - using `CreatedAt` for ordering
- ⚠️ **OPTIONAL**: Missing `Goal` navigation property (EF Core works without it)

---

## 3. DTO Analysis

### 3.1 GoalDto

| Property | Spec Required | Current Implementation | Constitutional Compliance | Gap |
|----------|---------------|------------------------|---------------------------|-----|
| `Id` | Guid | ✅ Guid Id | ✅ PascalCase | None |
| `EmployeeId` | Guid employee_id | ✅ Guid EmployeeId | ✅ Correct | None |
| `Title` | string title | ✅ string Title | ✅ Correct | None |
| `Description` | string? description | ✅ string? Description | ✅ Correct | None |
| `Category` | string category | ✅ **NOT NEEDED** (using RelatedSkillId) | ✅ Compliant | **DECISION: SKIP** |
| `Status` | string status | ✅ string Status | ✅ Correct | None |
| `Priority` | short? priority | ✅ short? Priority | ✅ Correct | None |
| `TargetCompletionDate` | DateTime? target_completion_date | ⚠️ DateTime? Deadline | ⚠️ Naming mismatch | **MEDIUM** |
| `ActualCompletionDate` | DateTime? actual_completion_date | ❌ **MISSING** | ❌ Violation | **HIGH** |
| `ProgressPercentage` | decimal progress_percentage | ⚠️ decimal ProgressPercent | ⚠️ Should be ProgressPercentage | **LOW** |
| `RelatedSkillId` | Guid? related_skill_id | ✅ Guid? RelatedSkillId | ✅ Correct | None |
| `RelatedSkillLevelId` | Guid? related_skill_level_id | ✅ Guid? RelatedSkillLevelId | ✅ Correct | None |
| `IsCompleted` | bool is_completed | ✅ bool IsCompleted | ✅ Correct | None |
| `CompletedAt` | DateTimeOffset? completed_at | ✅ DateTimeOffset? CompletedAt | ✅ Correct | None |
| `Visibility` | string? visibility | ✅ string? Visibility | ✅ Correct | None |
| `CreatedAt` | DateTimeOffset created_at | ✅ DateTimeOffset CreatedAt | ✅ Correct | None |
| `ModifiedAt` | DateTimeOffset? modified_at | ❌ **DateTimeOffset? UpdatedAt** | ❌ **VIOLATION** | **CRITICAL** |
| `IsDeleted` | bool is_deleted | ⚠️ Not in DTO | ⚠️ Should expose | **LOW** |
| `Tasks` | List<TaskDto> tasks | ✅ List<TaskDto> Tasks | ✅ Correct | None |

**JSON Naming Analysis**:
- ❌ **CRITICAL VIOLATION**: Uses `UpdatedAt` instead of `ModifiedAt` (Constitutional Principle 11 violation)
- ⚠️ Missing `[JsonPropertyName]` attributes to enforce snake_case JSON serialization

**Gaps Summary**:
- ✅ **RESOLVED**: `Category` property **NOT NEEDED** - using `RelatedSkillId`
- ❌ **CRITICAL**: Uses `UpdatedAt` instead of `ModifiedAt` (**CONSTITUTIONAL VIOLATION**)
- ⚠️ **OPTIONAL**: Missing `ActualCompletionDate` property (can add later)
- ⚠️ **LOW**: Naming differences (minor, not blocking)

---

### 3.2 TaskDto

| Property | Spec Required | Current Implementation | Gap |
|----------|---------------|------------------------|-----|
| `Id` | Guid id | ✅ Guid Id | None |
| `GoalId` | Guid goal_id | ✅ Guid GoalId | None |
| `Title` | string title | ✅ string Title | None |
| `Description` | string? description | ✅ string? Description | None |
| `Deadline` | DateTimeOffset? deadline | ✅ DateTimeOffset? Deadline | None |
| `IsCompleted` | bool is_completed | ✅ bool IsCompleted | None |
| `CompletedAt` | DateTimeOffset? completed_at | ✅ DateTimeOffset? CompletedAt | None |
| `OrderIndex` | int order_index | ✅ **NOT NEEDED** (using CreatedAt) | **DECISION: SKIP** |
| `CreatedAt` | DateTimeOffset created_at | ✅ DateTimeOffset CreatedAt | None |
| `ModifiedAt` | DateTimeOffset? modified_at | ❌ **MISSING** | **MEDIUM** |

**Gaps Summary**:
- ✅ **RESOLVED**: `OrderIndex` property **NOT NEEDED** - using `CreatedAt` for natural ordering
- ⚠️ **OPTIONAL**: Missing `ModifiedAt` property (can add for consistency)
- ⚠️ **LOW**: Missing `[JsonPropertyName]` attributes

---

### 3.3 CreateGoalDto

| Property | Spec Required | Current Implementation | Gap |
|----------|---------------|------------------------|-----|
| `Title` | string [Required, 3-200 chars] | ✅ string [Required, 1-250 chars] | Minor validation difference |
| `Description` | string? [Max 2000] | ✅ string? [Max 2000] | None |
| `Category` | string [Required, enum] | ✅ **NOT NEEDED** (using RelatedSkillId) | **DECISION: SKIP** |
| `Priority` | string [Required, enum] | ⚠️ short? [0-100] | Type mismatch (string vs short) |
| `TargetCompletionDate` | DateTime? | ⚠️ DateTime? Deadline | Naming mismatch |
| `RelatedSkillId` | Guid? | ✅ Guid? RelatedSkillId | None |
| `RelatedSkillLevelId` | Guid? | ✅ Guid? RelatedSkillLevelId | None |
| `Visibility` | string? [private/team/org] | ✅ string? [private/team/org] | None |

**Gaps Summary**:
- ✅ **RESOLVED**: `Category` property **NOT NEEDED**
- ⚠️ **OPTIONAL**: Priority type difference (current short 0-100 works fine, spec's string enum is just different approach)
- ⚠️ **LOW**: Minor naming differences (not blocking)

---

### 3.4 UpdateGoalDto

| Property | Spec Required | Current Implementation | Gap |
|----------|---------------|------------------------|-----|
| `Title` | string? [3-200 chars] | ✅ string? [1-250 chars] | Minor validation |
| `Description` | string? [Max 2000] | ✅ string? [Max 2000] | None |
| `Category` | string? | ✅ **NOT NEEDED** | **DECISION: SKIP** |
| `Status` | string? | ✅ string? Status | None |
| `Priority` | string? | ⚠️ short? [0-100] | Type mismatch |
| `TargetCompletionDate` | DateTime? | ⚠️ DateTimeOffset? Deadline | Type/naming mismatch |
| `ActualCompletionDate` | DateTime? | ❌ **MISSING** | **HIGH** |
| `RelatedSkillId` | Guid? | ✅ Guid? RelatedSkillId | None |
| `RelatedSkillLevelId` | Guid? | ✅ Guid? RelatedSkillLevelId | None |
| `Visibility` | string? | ✅ string? Visibility | None |

**Gaps Summary**:
- ✅ **RESOLVED**: `Category` property **NOT NEEDED**
- ⚠️ **OPTIONAL**: Missing `ActualCompletionDate` property
- ⚠️ **LOW**: Minor differences (not blocking)

---

### 3.5 CreateGoalTaskDto

| Property | Spec Required | Current Implementation | Gap |
|----------|---------------|------------------------|-----|
| `Title` | string [Required, 3-200 chars] | ✅ string [Required, 1-250 chars] | Minor |
| `Description` | string? [Max 2000] | ✅ string? [Max 2000] | None |
| `Deadline` | DateTimeOffset? | ✅ DateTimeOffset? Deadline | None |
| `OrderIndex` | int? | ✅ **NOT NEEDED** | **DECISION: SKIP** |

**Gaps Summary**:
- ✅ **RESOLVED**: `OrderIndex` property **NOT NEEDED**

---

### 3.6 UpdateGoalTaskDto

| Property | Spec Required | Current Implementation | Gap |
|----------|---------------|------------------------|-----|
| `Title` | string? [3-200 chars] | ✅ string? [1-250 chars] | Minor |
| `Description` | string? [Max 2000] | ✅ string? [Max 2000] | None |
| `Deadline` | DateTimeOffset? | ✅ DateTimeOffset? Deadline | None |
| `IsCompleted` | bool? | ✅ bool? IsCompleted | None |
| `OrderIndex` | int? | ✅ **NOT NEEDED** | **DECISION: SKIP** |

**Gaps Summary**:
- ✅ **RESOLVED**: `OrderIndex` property **NOT NEEDED**

---

## 4. API Endpoint Analysis

### 4.1 Implemented Endpoints

| Endpoint | Spec | Current | Authorization | Gap |
|----------|------|---------|---------------|-----|
| `POST /api/goals` | ✅ | ✅ | Employee+ | None |
| `GET /api/me/goals` | ✅ | ✅ | Employee+ | ⚠️ Missing filters/sorting |
| `GET /api/goals/{id}` | ✅ | ✅ | Employee+ | None |
| `PATCH /api/goals/{id}` | ✅ | ✅ | Employee+ | None |
| `DELETE /api/goals/{id}` | ✅ | ✅ | Admin only | None |
| `POST /api/goals/{id}/tasks` | ✅ | ✅ | Employee+ | None |
| `PATCH /api/goals/{id}/tasks/{taskId}` | ✅ | ✅ | Employee+ | None |
| `DELETE /api/goals/{id}/tasks/{taskId}` | ✅ | ✅ | Employee+ | None |

---

### 4.2 GET /api/me/goals - Query Parameters

| Parameter | Spec Required | Current Implementation | Gap |
|-----------|---------------|------------------------|-----|
| `page` | int (default 1) | ✅ int page = 1 | None |
| `per_page` | int (default 20) | ✅ int per_page = 20 | None |
| `status` | string? (comma-separated) | ❌ **MISSING** | **HIGH** |
| `category` | string? (comma-separated) | ❌ **MISSING** | **CRITICAL** |
| `priority` | string? (comma-separated) | ❌ **MISSING** | **HIGH** |
| `search` | string? | ❌ **MISSING** | **HIGH** |
| `sort_by` | string? (default: created_at) | ❌ **MISSING** | **HIGH** |
| `sort_order` | string? (default: desc) | ❌ **MISSING** | **HIGH** |
| `include_tasks` | bool? (default: false) | ❌ **MISSING** | **MEDIUM** |

**Current Implementation**: Only supports basic pagination (page, per_page)

**Gaps Summary**:
- ❌ **CRITICAL**: No filtering by category (required for spec compliance)
- ❌ **HIGH**: No filtering by status, priority, or search
- ❌ **HIGH**: No sorting capabilities (sort_by, sort_order)
- ❌ **MEDIUM**: No `include_tasks` option (always includes tasks currently)

---

### 4.3 Missing Endpoints

| Endpoint | Spec Required | Current Status | Priority |
|----------|---------------|----------------|----------|
| `PATCH /api/goals/{id}/tasks/reorder` | ✅ Yes | ❌ **MISSING** | **CRITICAL** |
| `POST /api/goals/batch` | ⚠️ Nice-to-have | ❌ MISSING | LOW |
| `DELETE /api/goals/batch` | ⚠️ Nice-to-have | ❌ MISSING | LOW |

**Gaps Summary**:
- ❌ **CRITICAL**: Missing task reordering endpoint (required for drag-drop)

---

## 5. Service Layer Analysis

### 5.1 GoalService Methods

| Method | Spec Required | Current Implementation | Gap |
|--------|---------------|------------------------|-----|
| `CreateGoalAsync` | ✅ | ✅ Implemented | None |
| `GetGoalsForUserAsync` | ✅ With filters/sorting | ⚠️ **No filters/sorting** | **HIGH** |
| `GetGoalByIdAsync` | ✅ | ✅ Implemented | None |
| `UpdateGoalAsync` | ✅ | ✅ Implemented | None |
| `DeleteGoalAsync` | ✅ Soft delete | ✅ Implemented | None |
| `AddTaskAsync` | ✅ | ✅ Implemented | None |
| `UpdateTaskAsync` | ✅ | ✅ Implemented | None |
| `DeleteTaskAsync` | ✅ | ✅ Implemented | None |
| `ReorderTasksAsync` | ✅ | ✅ **NOT NEEDED** | **DECISION: SKIP** |
| `UpdateProgressAsync` | ⚠️ Auto-calc | ❌ **MISSING** | **MEDIUM** |

**Gaps Summary**:
- ✅ **RESOLVED**: `ReorderTasksAsync` method **NOT NEEDED** - using natural ordering
- ⚠️ **OPTIONAL**: `GetGoalsForUserAsync` enhanced filtering/sorting (Phase 2 frontend improvement)
- ⚠️ **OPTIONAL**: Automatic progress calculation (can add later)

---

## 6. Frontend Implementation Status

### 6.1 TypeScript Types

| Type | Spec Required | Current Status | Gap |
|------|---------------|----------------|-----|
| `GoalDto` interface | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `GoalTaskDto` interface | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `CreateGoalDto` interface | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `UpdateGoalDto` interface | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| Enums (Status, Priority, Visibility) | ✅ | ❌ **NOT STARTED** | **CRITICAL** |

**Gaps**: All frontend types need to be created (0% complete)

---

### 6.2 API Services

| Service | Spec Required | Current Status | Gap |
|---------|---------------|----------------|-----|
| `goalApi.ts` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| API client methods | ✅ 8 methods | ❌ **NOT STARTED** | **CRITICAL** |

---

### 6.3 React Query Hooks

| Hook | Spec Required | Current Status | Gap |
|------|---------------|----------------|-----|
| `useGoals()` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useGoal(id)` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useCreateGoal()` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useUpdateGoal()` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useDeleteGoal()` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useGoalTasks()` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useCreateTask()` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useUpdateTask()` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useDeleteTask()` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `useReorderTasks()` | ❌ **NOT NEEDED** | ✅ **N/A** | **DECISION: SKIP** |

---

### 6.4 UI Components

| Component | Spec Required | Current Status | Gap |
|-----------|---------------|----------------|-----|
| `GoalListPage` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `GoalDetailPage` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `GoalCard` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `GoalForm` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `TaskList` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `TaskItem` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `TaskForm` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `GoalFilters` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |
| `SortControls` | ✅ | ❌ **NOT STARTED** | **CRITICAL** |

**Gaps**: All UI components need to be created (0% complete)

---

## 7. Constitutional Compliance Violations

### Principle 2: API Contract Consistency ❌ VIOLATION

**Issue**: `GoalDto` uses `UpdatedAt` instead of `ModifiedAt`
- **Impact**: Violates CPR naming standards (data.md authoritative source)
- **Required**: Change `UpdatedAt` → `ModifiedAt` in C# DTO
- **Priority**: **CRITICAL**

### Principle 9: Strict Naming Conventions ⚠️ PARTIAL VIOLATION

**Issue**: Missing `[JsonPropertyName]` attributes on DTOs
- **Impact**: JSON serialization may not use snake_case consistently
- **Required**: Add `[JsonPropertyName("snake_case")]` to all DTO properties
- **Priority**: **HIGH**

### Principle 11: Database Design Standards ⚠️ PARTIAL COMPLIANCE

**Issues**:
1. Missing indexes on goals table (status, category, deadline, priority, created_at)
2. No FK constraint on goal_tasks.goal_id
3. Missing order_index column and composite index

**Priority**: **HIGH**

---

## 8. Risk Assessment

### Critical Risks (Block Implementation)

1. **Missing order_index column** (Backend)
   - **Impact**: Cannot implement drag-drop task reordering
   - **Effort**: 2 hours (migration + entity update)
   - **Blocker for**: Phase 4 (Advanced Features)

2. **Missing Category column** (Backend)
   - **Impact**: Cannot filter/group goals by category
   - **Effort**: 3 hours (migration + entity + DTO + service)
   - **Blocker for**: Phase 2 (Backend API), Phase 3 (Frontend Core)

3. **Constitutional naming violation: UpdatedAt** (Backend)
   - **Impact**: Non-compliance with Principle 11
   - **Effort**: 1 hour (DTO update + recompile + test)
   - **Blocker for**: Phase 4 analysis approval

### High Risks (Degrade Experience)

4. **No filtering/sorting in GET /api/me/goals** (Backend)
   - **Impact**: Frontend must filter/sort client-side (poor performance)
   - **Effort**: 6 hours (service layer + controller + tests)
   - **Workaround**: Client-side filtering (not recommended for >100 goals)

5. **Missing performance indexes** (Backend)
   - **Impact**: Slow queries on large datasets
   - **Effort**: 2 hours (migration + testing)
   - **Workaround**: Works for small datasets (<1000 goals)

### Medium Risks (Functional Gaps)

6. **No automatic progress calculation** (Backend)
   - **Impact**: Manual progress updates, potential inconsistency
   - **Effort**: 4 hours (trigger + tests)
   - **Workaround**: Calculate on frontend (less accurate)

---

## 9. Implementation Priority Matrix

### Phase 1: Critical Backend Fixes (Must Do Before Frontend)

| Priority | Task | Effort | Status |
|----------|------|--------|--------|
| P0 | Add order_index to goal_tasks (T001) | 2h | ❌ Required |
| P0 | Update GoalTask entity with OrderIndex (T002) | 0.5h | ❌ Required |
| P0 | Add category column to goals | 1h | ❌ Required |
| P0 | Fix UpdatedAt → ModifiedAt in GoalDto | 1h | ❌ Required |
| P1 | Add [JsonPropertyName] to all DTOs | 2h | ⚠️ Recommended |
| P1 | Add missing indexes (status, category, etc.) | 2h | ⚠️ Recommended |
| P1 | Add FK constraint on goal_tasks.goal_id | 0.5h | ⚠️ Recommended |
| P2 | Add actual_completion_date column | 1h | ⚠️ Nice-to-have |

**Total Phase 1 Effort**: 10 hours

---

### Phase 2: Enhanced Backend API

| Priority | Task | Effort | Status |
|----------|------|--------|--------|
| P0 | Implement filtering/sorting in GetGoalsForUserAsync | 4h | ❌ Required |
| P0 | ~~Add ReorderTasksAsync service method~~ | ~~2h~~ | ✅ **NOT NEEDED** |
| P0 | ~~Create PATCH /api/goals/{id}/tasks/reorder endpoint~~ | ~~2h~~ | ✅ **NOT NEEDED** |
| P1 | Add automatic progress calculation trigger | 4h | ⚠️ Recommended |
| P2 | Batch operations endpoints | 4h | ⚠️ Nice-to-have |

**Total Phase 2 Effort**: 8 hours (0h critical, 8h optional)

---

### Phase 3-5: Frontend Implementation

All frontend work is **NOT STARTED** (0% complete)
- **Phase 3**: Types, services, hooks (12h) - **READY TO START** after constitutional fixes
- **Phase 4**: UI components (28h) - reduced from 32h (no drag-drop complexity)
- **Phase 5**: Advanced features (24h)
- **Phase 6**: Testing & polish (18h) - reduced from 20h

**Total Frontend Effort**: 82 hours (reduced from 88h due to simplified design)

---

## 10. Recommendations

### Immediate Actions (Before Frontend Implementation)

1. **Fix Constitutional Violations** (1-2h) **CRITICAL - BLOCKING**
   - Change `UpdatedAt` → `ModifiedAt` in GoalDto.cs
   - Add `[JsonPropertyName("modified_at")]` attribute
   - Add `ModifiedAt` property to TaskDto.cs
   - Add `[JsonPropertyName]` attributes to all DTO properties for snake_case JSON
   - Update GoalService mapping logic if needed

2. ~~**Critical Database Changes**~~ ✅ **NOT NEEDED**
   - ~~Add `order_index` column~~ - Using `created_at` for natural ordering
   - ~~Add `category` column~~ - Using `related_skill_id` for organization
   - Database schema is **COMPLETE** as-is

3. **Performance Optimizations** (Optional - Phase 2)
   - Add missing indexes (can add later based on usage patterns)
   - FK constraint on goal_tasks.goal_id exists

### Phase 1 Approach

**Backend Constitutional Fixes** (1-2h): **IMMEDIATE PRIORITY**
- Fix UpdatedAt → ModifiedAt in DTOs
- Add [JsonPropertyName] attributes
- Test existing endpoints (already working)
- Compile and run existing unit tests

**Frontend Foundation** (12h): **START AFTER CONSTITUTIONAL FIXES**
- Create TypeScript types matching corrected DTOs
- Implement API service layer
- Create React Query hooks

### Success Criteria Before Frontend Development

- [ ] All constitutional violations resolved (UpdatedAt → ModifiedAt)
- [ ] All DTOs have [JsonPropertyName] attributes
- [ ] Backend compiles successfully
- [ ] Existing backend tests pass
- [ ] TypeScript types created and validated
- [ ] React Query hooks created and tested

**Note**: Database schema and entities are already complete per simplified design

---

## 11. Estimated Timeline

| Phase | Description | Effort | Dependencies |
|-------|-------------|--------|--------------|
| **Pre-Implementation** | Constitutional fixes | **1-2h** | None |
| **Phase 1** | Frontend Foundation | 12h | Pre-Implementation |
| **Phase 2** | Optional Backend Enhancements | 8h | Phase 1 (optional) |
| **Phase 3** | Frontend Core UI | 28h | Phase 1 |
| **Phase 4** | Advanced Features | 24h | Phase 3 |
| **Phase 5** | Testing & Polish | 18h | Phase 4 |
| **Total** | | **91h** | 11.5 days (8h/day) |

**Note**: Reduced from 106h to 91h due to simplified design (no order_index, no category, no drag-drop)

---

## 12. Next Steps

### IMMEDIATE (1-2h) - **BLOCKING FRONTEND WORK**

1. **Fix Constitutional Violations**:
   - Update `src/CPR.Application/Contracts/GoalDto.cs`:
     - Change `UpdatedAt` → `ModifiedAt`
     - Add `[JsonPropertyName("modified_at")]`
   - Update `src/CPR.Application/Contracts/TaskDto.cs`:
     - Add `ModifiedAt` property
     - Add `[JsonPropertyName("modified_at")]`
   - Add `[JsonPropertyName]` attributes to ALL DTO properties
   - Test: `dotnet build` in cpr-api (verify compilation)
   - Test: Run existing unit tests
   - Commit: "fix(0001): Constitutional compliance - UpdatedAt → ModifiedAt"

### Phase 1 (12h) - **START IMMEDIATELY AFTER**

2. **Frontend Foundation**:
   - Create TypeScript types in cpr-ui/src/types/goal.types.ts
   - Implement goalApi.ts service with 8 endpoints
   - Create React Query hooks (useGoals, useGoal, mutations)
   - Write unit tests for hooks

### Phase 2+ (82h remaining)

3. **UI Implementation**: Build goal management interface
4. **Advanced Features**: Offline sync, i18n, accessibility
5. **Testing & Polish**: E2E tests, performance optimization

**Decision Impact**: Simplified design saves ~15h of implementation time by eliminating drag-drop reordering and category management complexity

---

*End of Gap Analysis*
