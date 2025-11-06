# Tasks: [Feature Name]

> **Specification**: [spec-###]-[short-description]  
> **Created**: YYYY-MM-DD  
> **Last Updated**: YYYY-MM-DD

## Task Breakdown

### Phase 1: [Phase Name]

#### Backend Tasks

- [ ] **TASK-001**: Create database migration for [table_name]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: None
  - **Details**: Create migration file with table schema, indexes, and constraints
  - **Acceptance**: Migration runs successfully on dev database

- [ ] **TASK-002**: Create [EntityName] entity model
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-001
  - **Details**: Define entity with properties, navigation properties, and configurations
  - **Acceptance**: Entity properly maps to database table

- [ ] **TASK-003**: Create [EntityName] repository
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-002
  - **Details**: Implement repository with CRUD operations and custom queries
  - **Acceptance**: Repository methods work with in-memory database

- [ ] **TASK-004**: Create [ServiceName] service
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-003
  - **Details**: Implement business logic and validation
  - **Acceptance**: Service logic passes unit tests

- [ ] **TASK-005**: Create DTOs for [Resource]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-002
  - **Details**: Create request/response DTOs with validation attributes
  - **Acceptance**: DTOs properly serialize/deserialize with snake_case

- [ ] **TASK-006**: Create [ControllerName] controller
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-004, TASK-005
  - **Details**: Implement controller endpoints with proper HTTP methods, status codes
  - **Acceptance**: Endpoints return correct responses for happy path

- [ ] **TASK-007**: Add error handling to [ControllerName]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-006
  - **Details**: Handle validation, not found, authorization errors with ProblemDetails
  - **Acceptance**: Errors return proper RFC 7807 responses

- [ ] **TASK-008**: Write unit tests for [ServiceName]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-004
  - **Details**: Test all service methods, edge cases, error scenarios
  - **Acceptance**: >80% code coverage, all tests pass

- [ ] **TASK-009**: Write integration tests for [ControllerName]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-006
  - **Details**: Test endpoints end-to-end with test database
  - **Acceptance**: All integration tests pass

- [ ] **TASK-010**: Create JSON schema for [Resource]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-005
  - **Details**: Define JSON schema matching DTO structure
  - **Acceptance**: Schema validates sample valid/invalid JSON

- [ ] **TASK-011**: Write contract tests for [Resource]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-010, TASK-009
  - **Details**: Test API responses against JSON schema
  - **Acceptance**: Contract tests pass for all endpoints

#### Frontend Tasks

- [ ] **TASK-012**: Create TypeScript types for [Resource]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-005
  - **Details**: Define TypeScript interfaces matching API DTOs
  - **Acceptance**: Types properly represent all fields with correct types

- [ ] **TASK-013**: Create API service methods for [Resource]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-012
  - **Details**: Implement fetch methods with proper error handling
  - **Acceptance**: Service methods successfully call API endpoints

- [ ] **TASK-014**: Create React Query hooks for [Resource]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-013
  - **Details**: Implement useQuery and useMutation hooks
  - **Acceptance**: Hooks handle loading, error, success states

- [ ] **TASK-015**: Create [ComponentName] component
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-014
  - **Details**: Build React component with props, state, event handlers
  - **Acceptance**: Component renders correctly with mock data

- [ ] **TASK-016**: Add form validation to [ComponentName]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-015
  - **Details**: Implement client-side validation with error messages
  - **Acceptance**: Form validates input and shows appropriate errors

- [ ] **TASK-017**: Add loading and error states to [ComponentName]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-015
  - **Details**: Show loading spinners, error messages, retry options
  - **Acceptance**: Component handles all async states gracefully

- [ ] **TASK-018**: Write unit tests for [ComponentName]
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-017
  - **Details**: Test component rendering, interactions, edge cases
  - **Acceptance**: >80% coverage, all tests pass

- [ ] **TASK-019**: Add [ComponentName] to navigation/routing
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-017
  - **Details**: Create route, add menu item, handle navigation
  - **Acceptance**: Component accessible via navigation

#### Documentation Tasks

- [ ] **TASK-020**: Update Swagger documentation
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-006
  - **Details**: Add XML comments to controller actions
  - **Acceptance**: Swagger UI shows complete endpoint documentation

- [ ] **TASK-021**: Update API documentation
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-020
  - **Details**: Document new endpoints in cpr-api/documents/endpoints.md
  - **Acceptance**: Documentation matches implementation

- [ ] **TASK-022**: Update database documentation
  - **Estimate**: [hours/days]
  - **Assignee**: [Name or TBD]
  - **Dependencies**: TASK-001
  - **Details**: Document new tables in cpr-api/documents/data.md
  - **Acceptance**: Schema documentation is complete and accurate

### Phase 2: [Phase Name]

[Repeat task structure for Phase 2]

### Phase 3: [Phase Name]

[Repeat task structure for Phase 3]

## Task Summary

### By Phase
- **Phase 1**: X tasks (Y hours)
- **Phase 2**: X tasks (Y hours)
- **Phase 3**: X tasks (Y hours)
- **Total**: X tasks (Y hours)

### By Type
- **Backend**: X tasks
- **Frontend**: X tasks
- **Testing**: X tasks
- **Documentation**: X tasks

### By Status
- **Not Started**: X tasks
- **In Progress**: X tasks
- **Completed**: X tasks
- **Blocked**: X tasks

## Task Dependencies Graph

```
TASK-001 (Migration)
    ↓
TASK-002 (Entity)
    ↓
TASK-003 (Repository) ──→ TASK-004 (Service)
    ↓                           ↓
TASK-005 (DTOs) ───────────────┤
    ↓                           ↓
TASK-010 (Schema)      TASK-006 (Controller)
    ↓                           ↓
TASK-011 (Contract)    TASK-007 (Error Handling)
                                ↓
TASK-012 (TS Types) ←───────────┤
    ↓
TASK-013 (API Service)
    ↓
TASK-014 (React Query)
    ↓
TASK-015 (Component)
    ↓
TASK-017 (States)
```

## Blocked Tasks

### TASK-XXX: [Task Name]
**Blocked By**: [Reason or dependency]  
**Resolution**: [Action needed to unblock]  
**Priority**: [High/Medium/Low]

## Completed Tasks

### TASK-XXX: [Task Name]
**Completed**: YYYY-MM-DD  
**Completed By**: [Name]  
**Notes**: [Any relevant notes about completion]

## Task Notes

### General Notes
- [Important considerations for all tasks]
- [Common patterns to follow]
- [Resources or references]

### Per-Task Notes

#### TASK-XXX
- [Additional context or considerations]
- [Related decisions or discussions]

## Estimation Accuracy

| Phase | Estimated | Actual | Variance |
|-------|-----------|--------|----------|
| Phase 1 | [hours] | [hours] | [+/- %] |
| Phase 2 | [hours] | [hours] | [+/- %] |
| Phase 3 | [hours] | [hours] | [+/- %] |

## Risk Items

- **[Task ID]**: [Risk description and mitigation]
- **[Task ID]**: [Risk description and mitigation]

## Questions and Decisions

### Q: [Question about task approach]
**A**: [Answer/decision]  
**Date**: YYYY-MM-DD  
**Decided By**: [Name]

### Q: [Question about task approach]
**A**: [Answer/decision]  
**Date**: YYYY-MM-DD  
**Decided By**: [Name]

---

**Last Updated**: YYYY-MM-DD  
**Next Review**: YYYY-MM-DD
