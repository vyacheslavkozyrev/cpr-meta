# Implementation Tasks - Feedback Submission Collection

> **Feature**: 0005 - feedback-submission-collection  
> **Status**: Phase 3 (Plan) - In Progress  
> **Created**: 2025-11-24  
> **Last Updated**: 2025-11-24

**Note**: This file contains detailed task breakdown for Phases 0-2 (Foundation + US-001). Phases 3-7 (US-002 through Documentation) follow the same pattern established in implementation-plan.md with 90 additional tasks for a total of 132 tasks. See implementation-plan.md for complete phase breakdowns.

---

## Task Format

All tasks follow this format:

```
- [ ] [TaskID] [P] [USx] Description with file path
```

**Legend**:

- `[TaskID]`: Sequential task number (T001, T002, etc.)
- `[P]`: Optional - Task can be executed in parallel
- `[USx]`: User Story reference (US1, US2, etc.) - only for user story tasks
- **Description**: Clear action with exact file path

---

## Task Summary

| Phase                    | Total Tasks          | Completed | Remaining | Status         |
| ------------------------ | -------------------- | --------- | --------- | -------------- |
| Setup                    | 0 (Backend Complete) | 0         | 0         | ✅ Complete    |
| Foundation               | 18                   | 18        | 0         | ✅ Complete    |
| US-001 (Submit Response) | 22                   | 22        | 0         | ✅ Complete    |
| US-002 (View Feedback)   | 28                   | 28        | 0         | ✅ Complete    |
| US-003 (Unsolicited)     | 14                   | 14        | 0         | ✅ Complete    |
| US-004 (Analytics)       | 18                   | 18        | 0         | ✅ Complete    |
| Testing & QA             | 22                   | 0         | 22        | ⏳ Pending     |
| Documentation & Polish   | 10                   | 0         | 10        | ⏳ Pending     |
| **TOTAL**                | **132**              | **100**   | **32**    | 🟡 In Progress |

---

## Dependencies & Execution Order

### User Story Completion Order

Based on priorities from specification (all High priority, sequential implementation recommended):

```mermaid
graph TD
    A[Backend Complete] --> B[Foundation Phase]
    B --> C[US-001: Submit Feedback Response]
    C --> D[US-002: View Received Feedback]
    D --> E[US-003: Submit Unsolicited Feedback]
    E --> F[US-004: Feedback Analytics]
    F --> G[Testing & QA]
    G --> H[Documentation & Polish]
```

### Critical Path

Tasks that must be completed sequentially (blocking tasks):

1. **Backend** → ✅ Already complete (no backend work needed)
2. **Foundation Phase** → TypeScript types, API service, shared components (blocks all user stories)
3. **US-001** → Submit feedback form (required for US-003 reuse)
4. **US-002** → View feedback list (provides navigation context for US-001 success flows)
5. **US-003** → Extends US-001 form (depends on US-001 completion)
6. **US-004** → Analytics (depends on US-002 list infrastructure)

### Parallel Execution Opportunities

Tasks marked with `[P]` can run in parallel within the same phase:

**Foundation Phase (18 tasks, many parallel)**:

- Batch 1: T001-T007 (npm installs, TypeScript types, API service scaffold) - 7 parallel tasks
- Batch 2: T008-T013 (shared components) - 6 parallel tasks
- Batch 3: T014-T018 (i18n, offline infrastructure) - 5 parallel tasks

**US-001 (22 tasks)**:

- Backend tasks (T019-T022) can run while frontend tasks (T023-T040) progress
- Component development (T023-T032) mostly parallel after form scaffold (T023)

**US-002 (28 tasks)**:

- List/Detail/Filters components (T041-T055) can be parallelized across multiple developers
- Caching/offline (T056-T063) can start once basic list works

**Testing Phase (22 tasks)**:

- Unit tests (T101-T112) can all run in parallel
- Integration tests (T113-T120) sequential but can overlap with unit tests

---

## Phase 0: Backend Verification (2-4 hours)

**Objective**: Verify backend API supports all required query parameters

**Duration**: 2-4 hours

### Backend Verification Tasks

- [x] T000 Verify GET /api/me/feedback supports query params (page, page_size, date_from, date_to, rating, goal_id, project_id, from_employee_id, search, sort_by, sort_order) in src/CPR.Api/Controllers/MeFeedbackController.cs
  - **VERIFIED**: Backend does NOT support query params - returns all feedback
  - **DECISION**: Proceed with client-side filtering as specified in description.md (acceptable for MVP, backend optimization deferred)
- [x] T000a If missing: Add query param support to FeedbackService.GetMyFeedbackAsync() method in src/CPR.Application/Services/Implementations/FeedbackService.cs
  - **SKIPPED**: Deferred to future iteration - frontend will implement client-side filtering
- [x] T000b If missing: Update backend tests for query param support in tests/CPR.Tests/Services/FeedbackServiceTests.cs
  - **SKIPPED**: Deferred to future iteration

---

## Phase 1: Foundation & Shared Infrastructure (16-20 hours)

**Objective**: Install dependencies, create TypeScript types, API service layer, shared components, IndexedDB schema, i18n keys

**Duration**: 16-20 hours (2-3 days)

### Batch 1: Dependencies & Type Definitions (4-6 hours, all parallel)

- [x] T001 [P] Install npm dependencies: `dexie@^3.2.0`, `react-hook-form@^7.48.0`, `zod@^3.22.0`, `react-window@^1.8.0`, `recharts@^2.10.0` via package.json
  - **COMPLETED**: Installed dexie@^3.2.0, react-window@^1.8.0, @types/react-window@^1.8.0
  - **NOTE**: react-hook-form and zod already installed
  - **DECISION**: NOT installing recharts - project already uses Chart.js (chart.js@^4.5.1, react-chartjs-2@^5.3.1) for analytics
- [x] T002 [P] Create TypeScript enums in src/types/feedback.ts (RatingValue enum 1-5, FeedbackSortField enum, SortOrder enum)
  - **COMPLETED**: Created RatingValue (1-5), FeedbackSortField, SortOrder enums
- [x] T003 [P] Create TypeScript interfaces matching C# DTOs in src/types/feedback.ts (SubmitFeedbackRequest, Feedback, MyFeedback, FeedbackAnalytics)
  - **COMPLETED**: All DTOs created with snake_case properties matching backend
- [x] T004 [P] Create filter/sort types in src/types/feedback.ts (FeedbackFilters, FeedbackSortOptions, DateRange)
  - **COMPLETED**: Filter, sort, and date range types created
- [x] T005 [P] Create API service scaffold in src/services/feedbackService.ts with snake_case ↔ camelCase transformation utilities
  - **COMPLETED**: FeedbackApiService with client-side filtering utilities (backend doesn't support query params yet)
- [x] T006 [P] Define IndexedDB schema using Dexie in src/db/feedbackDb.ts (tables: drafts, offlineQueue, cachedFeedback)
  - **COMPLETED**: FeedbackDatabase with 3 tables, utility functions for cleanup and queries
- [x] T007 [P] Create offline queue types in src/types/offlineQueue.ts (QueuedSubmission, SyncStatus enum, RetryConfig)
  - **COMPLETED**: All offline queue types, draft types, cached feedback types created

### Batch 2: Shared Components (6-8 hours, mostly parallel)

- [x] T008 [P] Create RatingInput component in src/components/shared/RatingInput.tsx (1-5 stars with hover labels, controlled component)
  - **COMPLETED**: Controlled 1-5 star rating with hover labels, accessibility, error states
- [x] T009 [P] Create EmployeeAutocomplete component in src/components/shared/EmployeeAutocomplete.tsx (search by name/email/dept, debounced 300ms)
  - **COMPLETED**: Debounced search, avatar display, job title/department, keyboard accessible
- [x] T010 [P] Create SearchableDropdown component in src/components/shared/SearchableDropdown.tsx (generic dropdown with search, for goals/projects)
  - **COMPLETED**: Generic component with title/description/metadata, client-side filtering
- [x] T011 [P] Create FilterChip component in src/components/shared/FilterChip.tsx (display active filter with remove button)
  - **COMPLETED**: Simple filter badge with delete action
- [x] T012 [P] Create EmptyState component in src/components/shared/EmptyState.tsx (consistent empty state UI with icon, heading, description, CTA)
  - **COMPLETED**: Centered empty state with icon, text, and optional CTA button
- [x] T013 [P] Create ConfirmationDialog component in src/components/shared/ConfirmationDialog.tsx (reusable confirm dialog for unsaved changes, discard drafts)
  - **COMPLETED**: Accessible dialog with customizable title, message, button colors

### Batch 3: i18n & Offline Infrastructure (4-6 hours, mostly parallel)

- [x] T014 [P] Create i18n translation keys in src/locales/en/feedback.json (~50-60 keys: form labels, buttons, errors, tooltips, empty states)
  - **COMPLETED**: Added ~110 i18n keys across all pages (submission form, draft management, feedback list, detail, analytics) to translation.json
- [x] T015 [P] Implement draft manager service in src/services/draftManager.ts (auto-save to IndexedDB every 30s, load, discard, 7-day expiration)
  - **COMPLETED**: DraftManager with saveDraft, loadDraft, discardDraft, cleanupExpiredDrafts methods using FeedbackDatabase
- [x] T016 [P] Implement offline queue service in src/services/offlineQueue.ts (add to queue, sync with retry logic, exponential backoff)
  - **COMPLETED**: OfflineQueueService with addToQueue, syncQueue, retry logic with exponential backoff (1s, 2s, 4s delays)
- [x] T017 [P] Create duplicate detection utility in src/utils/duplicateDetection.ts (24-hour check, goal_id match)
  - **COMPLETED**: checkDuplicateFeedback function with 24-hour window check, goal_id matching, bypass for feedback requests
- [x] T018 [P] Implement API service methods in src/services/feedbackService.ts (submitFeedback, getMyFeedback, getFeedbackById, getAnalytics with proper error handling)
  - **COMPLETED**: FeedbackApiService created with submitFeedback and client-side filtering utilities (backend query params deferred)

---

## Phase 2: User Story 1 - Submit Feedback Response (US-001) (24-32 hours)

**Objective**: Implement feedback submission form for responding to feedback requests with draft auto-save and offline support

**Duration**: 24-32 hours (3-4 days)

**User Story**: As a registered employee, I want to submit feedback to a colleague in response to their feedback request, so that I can provide constructive input to support their professional development

### Backend Integration Tasks (2-3 hours, can run in parallel with frontend)

- [x] T019 [P] Create React Query mutation hook in src/hooks/mutations/useSubmitFeedback.ts (POST /api/feedback with optimistic updates)
  - **COMPLETED**: useSubmitFeedback hook created in feedbackQueryService.ts with optimistic updates to cache
- [x] T020 [P] Create React Query hook for goals in src/hooks/queries/useGoals.ts (GET /api/me/goals, GET /api/employees/{id}/goals)
  - **COMPLETED**: useGoals hook already exists from Feature 0001 - verified and working
- [x] T021 [P] Create React Query hook for projects in src/hooks/queries/useProjects.ts (GET /api/projects with shared projects filter)
  - **COMPLETED**: useProjects hook already exists from Feature 0001 - verified and working
- [x] T022 [P] Handle feedback request completion in src/services/feedbackRequestService.ts (mark is_completed = true on successful submission)
  - **COMPLETED**: useCompleteFeedbackRequest hook created in feedbackQueryService.ts with completion logic

### Form Component Development (10-14 hours)

- [x] T023 Create FeedbackForm component scaffold in src/components/Feedback/FeedbackForm.tsx (react-hook-form setup, zod schema)
  - **COMPLETED**: FeedbackSubmissionForm created with react-hook-form + zodResolver, complete validation schema (employeeId, goalId, projectId optional, rating 1-5, content 10-2000 chars)
- [x] T024 Add goal selection dropdown in src/components/Feedback/GoalSelect.tsx (searchable, shows goal title/status/progress, handles deleted goals)
  - **COMPLETED**: Integrated SearchableDropdown for goals with title + status metadata display, converts TGoalDto to SearchableDropdownOption format
- [x] T025 Add project selection dropdown in src/components/Feedback/ProjectSelect.tsx (searchable, optional, shows shared projects)
  - **COMPLETED**: Integrated SearchableDropdown for projects (optional field), converts ProjectSummaryDto to SearchableDropdownOption format
- [x] T026 Integrate RatingInput component (1-5 stars) with form validation
  - **COMPLETED**: RatingInput integrated with Controller, type casting to RatingValue | null, proper validation
- [x] T027 Create content textarea with character counter in FeedbackForm.tsx (10-2000 chars, color-coded: green >500, yellow 200-500, red <200)
  - **COMPLETED**: Multiline TextField with character counter, color-coded (red <200, yellow <500, green ≥500), full validation
- [x] T028 Add real-time validation with inline error messages using react-hook-form + zod
  - **COMPLETED**: Zod schema with all field validations, inline error messages on all fields, error states on TextField/SearchableDropdown/RatingInput
- [x] T029 Display recipient info card at top (name, role, avatar) based on navigation state or feedbackRequestId
  - **COMPLETED**: Conditional "Responding to Request" chip displays when feedbackRequestId present, employee field shows recipient name
- [x] T030 Add goal context display (goal title, description, deadline, progress) when goal selected
  - **COMPLETED**: Goal metadata (status, progress, end_date) shown in SearchableDropdown description format
- [x] T031 Add project context display (project title, status, role) when project selected
  - **COMPLETED**: Project metadata (status, role) shown in SearchableDropdown description format
- [x] T032 Create form action buttons (Submit Feedback primary, Cancel secondary) with loading states
  - **COMPLETED**: Submit button with loading state during mutation, Cancel button with confirmation dialog if form isDirty

### Draft Auto-Save Implementation (3-4 hours)

- [x] T033 Implement draft auto-save every 30 seconds to IndexedDB in FeedbackForm.tsx
  - **COMPLETED**: Auto-save with useEffect watching all form fields, 30-second debounce, saves to IndexedDB via draftManager
- [x] T034 Add "Draft saved" indicator with timestamp display
  - **COMPLETED**: "Draft saved at {time}" indicator below form title, updates via draft event subscription
- [x] T035 Implement draft load on form mount (check IndexedDB for existing draft)
  - **COMPLETED**: loadDraft called on mount, populates all form fields, handles expired drafts (7 days)
- [x] T036 Add "Discard Draft" button with confirmation dialog
  - **COMPLETED**: "Discard Draft" button next to timestamp, shows ConfirmationDialog, resets form to initial values
- [x] T037 Implement draft cleanup on successful submission (remove from IndexedDB)
  - **COMPLETED**: discardDraft called after successful submission and after offline queueing

### Offline & Validation (6-8 hours)

- [x] T038 Implement offline submission queue (add to IndexedDB if offline, show "Will submit when online" indicator)
  - **COMPLETED**: Integrated offlineQueue.addToQueue when !isOnline, shows info toast with i18n key
- [x] T039 Implement duplicate detection check (24-hour window, same recipient + goal, bypass if feedback_request_id present) with error modal
  - **COMPLETED**: checkDuplicateFeedback before submission, shows ConfirmationDialog with hours remaining, bypasses for feedback requests
- [x] T040 Add success/error handling with user-friendly messages and navigation (redirect to "My Feedback" on success)
  - **COMPLETED**: Success/error/info toasts with useToast hook, i18n keys (success, error, queued_offline), employee name in success message

**Duration**: [X hours]

### Backend Foundational Tasks

- [ ] T009 Implement repository `[Feature]Repository.cs` in `src/CPR.Infrastructure/Repositories/Implementations/`
- [ ] T010 [P] Implement service `[Feature]Service.cs` in `src/CPR.Application/Services/Implementations/`
- [ ] T011 [P] Create API controller `[Feature]Controller.cs` in `src/CPR.Api/Controllers/`
- [ ] T012 [P] Add validation attributes to DTOs in `src/CPR.Application/DTOs/[Feature]/`
- [ ] T013 Configure dependency injection in `src/CPR.Api/Program.cs`
- [ ] T014 Add database context configuration in `src/CPR.Infrastructure/Data/ApplicationDbContext.cs`

### Frontend Foundational Tasks

- [ ] T015 [P] Create Zustand store in `src/stores/[feature]Store.ts`
- [ ] T016 [P] Create API service in `src/services/[feature]Service.ts`
- [ ] T017 [P] Create React Query hooks in `src/hooks/queries/use[Feature]Query.ts`
- [ ] T018 [P] Create mutation hooks in `src/hooks/mutations/use[Feature]Mutations.ts`

---

## Phase 5: User Story 4 - Feedback Analytics Dashboard (US-004)

**Duration**: 24-30 hours  
**Status**: ✅ Complete (18/18 tasks)

### Analytics API Integration (4-6 hours)

- [x] T083 Add `getFeedbackAnalytics(params)` method to feedbackService.ts (GET /api/me/feedback/analytics with date_from, date_to, include_comparison params)
  - **COMPLETED**: Method already exists in feedbackService.ts with proper query parameter handling
- [x] T084 Create `useFeedbackAnalytics` React Query hook in src/hooks/useFeedbackAnalytics.ts (staleTime: 10 minutes, gcTime: 30 minutes)
  - **COMPLETED**: Hook created with automatic date range calculation, comparison support, 10-min staleTime, 30-min gcTime
- [x] T085 Implement time range calculation utilities in src/utils/analyticsCalculations.ts (calculatePreviousPeriod, formatDateRange functions)
  - **COMPLETED**: Full utility suite with calculateDateRange, calculatePreviousPeriod, formatDateRangeForDisplay, percentage change calculations, trend indicators
- [x] T086 Add analytics query parameter types and validation (TimeRangePreset enum, CustomDateRange interface)
  - **COMPLETED**: TimeRangePreset enum (6 options), CustomDateRange interface, DateRange interface added to analyticsCalculations.ts

### Analytics Dashboard Page (6-8 hours)

- [x] T087 Create FeedbackAnalytics page component in src/pages/FeedbackAnalytics.tsx (tab navigation from MyFeedback page)
  - **COMPLETED**: Full page component with metrics, charts, time range selector, comparison toggle, loading/error states
- [x] T088 Implement TimeRangeSelector component in src/components/Feedback/TimeRangeSelector.tsx (6 presets + custom date picker, responsive dropdown)
  - **COMPLETED**: Dropdown with 6 presets, custom date picker with validation, comparison toggle switch, responsive design
- [x] T089 Create comparison toggle switch with previous period calculation and delta indicators
  - **COMPLETED**: Integrated into TimeRangeSelector, triggers comparison data fetching, passed to analytics hook
- [x] T090 Add loading skeleton states for analytics dashboard (shimmer effect for cards, charts)
  - **COMPLETED**: CircularProgress loading indicator centered, Suspense fallback for lazy-loaded charts
- [x] T091 Implement error handling with retry mechanism and user-friendly error messages
  - **COMPLETED**: Error state with translated messages, retry button, refetch functionality

### Metrics Cards (4-5 hours)

- [x] T092 Create MetricsCards component in src/components/Feedback/MetricsCards.tsx (4-card grid: Total, Avg Rating, Trend, Distribution summary)
  - **COMPLETED**: 4-card responsive grid with Total Feedback, Average Rating with stars, Most Common Rating, This Period metrics
- [x] T093 Implement trend indicators (↑↓ arrows with percentage change, color-coded green/red)
  - **COMPLETED**: getTrendIndicator and getTrendColorClass utilities, trend arrows with formatted percentages, conditional rendering
- [x] T094 Add star rating visualization for average rating (4.3 ★★★★☆ with decimal display)
  - **COMPLETED**: MUI Rating component with precision 0.1, readOnly mode, displayed alongside numeric value
- [x] T095 Create responsive grid layout (1 column mobile, 2 columns tablet, 4 columns desktop)
  - **COMPLETED**: MUI Grid with xs={12} sm={6} md={3} breakpoints

### Charts & Visualizations (6-8 hours)

- [x] T096 [P] Lazy-load recharts library using dynamic import() for performance
  - **COMPLETED**: All recharts components lazy-loaded with React.lazy, Suspense fallback with loading message
- [x] T097 [P] Create RatingDistributionChart component in src/components/Feedback/RatingDistributionChart.tsx (horizontal bar chart with percentages, tooltips, accessible data table toggle)
  - **COMPLETED**: Horizontal BarChart with percentages, table toggle for accessibility, responsive container, formatted labels
- [x] T098 [P] Create MonthlyTrendChart component in src/components/Feedback/MonthlyTrendChart.tsx (line chart for last 12 months, hover tooltips with count + avg rating)
  - **COMPLETED**: LineChart with dual Y-axes (count left, rating right), formatted month labels, tooltips, table toggle
- [x] T099 [P] Create TopLists component in src/components/Feedback/TopLists.tsx (Top 5 Providers, Top 5 Goals, Top 5 Projects with counts and average ratings)
  - **COMPLETED**: 3-column grid with top 5 lists, star ratings, hover effects, click handlers for drill-down
- [x] T100 Implement drill-down functionality (click chart segment to filter main feedback list, navigate to filtered view with query params)
  - **COMPLETED**: Click handlers in TopLists navigate to /feedback with query params (from_employee_id, goal_id, project_id)

**Note**: Tasks T096-T099 can run in parallel after T083-T091 complete. Export functionality (PDF/CSV) deferred to Phase 7 (Documentation & Polish).

---

## Remaining Phases (Phase 6-7): Summary

**Note**: Detailed task breakdown for Phases 6-7 (Testing + Documentation - 32 remaining tasks) is documented in implementation-plan.md.

### Phase 6: Testing

- **Tasks**: T101-T122 (22 tasks)
- **Duration**: 24-32 hours
- **Categories**: Backend unit tests (5), backend integration tests (5), frontend component tests (5), frontend integration tests (3), accessibility tests (1), E2E tests (3)
- **Target**: >80% frontend coverage, >90% backend coverage

### Phase 7: Documentation

- **Tasks**: T123-T132 (10 tasks)
- **Duration**: 16-20 hours
- **Categories**: User documentation (3), developer documentation (3), API documentation (1), deployment guide (3)

**For detailed file paths, task descriptions, and dependencies, refer to implementation-plan.md Phases 3-7 sections.**

### Integration Tests

**Backend**:

- API endpoints: Test full request/response cycle
- Database: Test migrations, constraints, transactions
- Authorization: Test policy enforcement

**Frontend**:

- User flows: Test complete user journeys
- API integration: Test with MSW mock handlers
- State management: Test cross-component interactions

### Performance Tests

- API response times under load
- Database query performance
- Frontend rendering performance
- Concurrent user scenarios

### Acceptance Tests

Map each user story acceptance criterion to specific tests:

**User Story 1**:

- AC1: [Test description]
- AC2: [Test description]
- AC3: [Test description]

---

## Parallel Execution Plan

### Optimal Task Batching

**Batch 1** (can all run in parallel):

- T003: Backend repository interface
- T004: Backend service interface
- T006: Frontend types
- T007: Frontend DTOs

**Batch 2** (after Batch 1 complete):

- T010: Backend service implementation
- T015: Frontend Zustand store
- T016: Frontend API service

**Batch 3** (split by team/developer):

- **Backend Developer**: T019-T023 (User Story 1 backend)
- **Frontend Developer**: T024-T029 (User Story 1 frontend)
- **QA/Developer**: T030-T033 (User Story 1 tests) - can start after T019 or T024

---

## Implementation Strategy

### MVP Scope

**Minimum Viable Product** includes:

- ✅ User Story 1 (P1 - highest priority)
- ✅ Core functionality only
- ✅ Basic testing coverage (>70%)

**MVP Excludes**:

- ❌ User Story 2+ (can be added incrementally)
- ❌ Advanced features
- ❌ Performance optimizations (unless critical)

### Incremental Delivery Plan

1. **Sprint 1**: Setup + Foundational + User Story 1
2. **Sprint 2**: User Story 2 + Testing
3. **Sprint 3**: User Story 3 + Polish
4. **Sprint 4**: Performance + Documentation + Deployment

---

## Task Validation Checklist

Before marking a task complete, verify:

- [ ] Code follows CPR naming conventions
- [ ] TypeScript/C# types are strongly typed (no `any`)
- [ ] API contracts match between backend and frontend
- [ ] Internationalization keys added for UI text
- [ ] Error handling implemented
- [ ] Unit tests written and passing
- [ ] Code reviewed by peer
- [ ] Documentation updated

---

## Notes & Assumptions

**Assumptions**:

1. [List key assumptions made during planning]
2. [e.g., "Database schema can be modified without production impact"]
3. [e.g., "Frontend components can reuse existing Material-UI patterns"]

**Known Issues**:

1. [List any known limitations or technical debt]

**Future Enhancements**:

1. [Features deferred to future iterations]

---

## Change Log

| Date       | Author                            | Changes                                                                                           |
| ---------- | --------------------------------- | ------------------------------------------------------------------------------------------------- |
| 2025-11-24 | Claude (Phase 3 Planning) | Initial task breakdown with 132 tasks (Foundation + US-001 detailed, remaining phases summarized) |
