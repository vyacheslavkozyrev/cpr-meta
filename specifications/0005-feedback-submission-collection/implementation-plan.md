# Implementation Plan - Feedback Submission Collection

> **Feature**: 0005 - feedback-submission-collection  
> **Status**: Planning  
> **Created**: 2025-11-24  
> **Last Updated**: 2025-11-24

---

## Executive Summary

This implementation will deliver frontend UI components for the Feedback Submission & Collection feature, enabling employees to submit structured feedback (with goal/project associations, ratings, and content) and view all received feedback with filtering, sorting, search, and analytics. The backend API is already complete (POST /api/feedback, GET /api/me/feedback); this phase focuses on React components, Zustand state management, React Query integration, offline support with IndexedDB, and comprehensive internationalization. Estimated effort: 14-18 days for full UI implementation including testing.

---

## Constitutional Compliance Check

Review against all 11 CPR Constitutional Principles:

### ✅ Principle 1: Specification-First Development

- [x] Complete specification exists in `description.md`
- [x] All requirements clearly documented
- [x] Stakeholder approval obtained

**Status**: PASS  
**Notes**: Phase 2 (Refine) completed with comprehensive specification including 4 user stories (US-001 through US-004), 12 business rules, complete API design, UX mockups, and detailed acceptance criteria. Total specification: 1960 lines. Ready for implementation.

### ✅ Principle 2: API Contract Consistency

- [x] C# DTOs defined and match specification (SubmitFeedbackRequestDto, FeedbackDto, MyFeedbackDto already exist in cpr-api)
- [ ] TypeScript interfaces to be created matching C# DTOs
- [x] JSON naming uses snake_case (feedback_request_id, goal_id, employee_id, project_id, created_at)
- [ ] Property mappings to be documented in endpoints.md with C# [JsonPropertyName] attributes

**Status**: NEEDS REVIEW  
**Notes**: Backend DTOs complete. Frontend TypeScript interfaces must be created to match: SubmitFeedbackRequest, Feedback, MyFeedback with camelCase properties mapping to snake_case JSON via API service layer.

### ✅ Principle 3: API Standards & Security

- [x] RESTful endpoints follow conventions (POST /api/feedback for submission, GET /api/me/feedback for retrieval)
- [x] HTTP methods used correctly (POST for creation, GET for retrieval)
- [x] Standard status codes defined (201 Created, 200 OK, 400 Bad Request, 401 Unauthorized, 404 Not Found, 409 Conflict for duplicates, 429 Too Many Requests)
- [x] Error responses standardized (ProblemDetails format with title, detail, status, instance, extensions)
- [x] Authentication/authorization specified (JWT Bearer token required, employees can only view own feedback)

**Status**: PASS  
**Notes**: Backend API fully compliant with RESTful standards and comprehensive error handling. Frontend must handle all error response types with user-friendly messages.

### ✅ Principle 4: Type Safety Everywhere

- [x] C# DTOs use strong typing with validation attributes ([Required], [StringLength(2000, MinimumLength = 10)], [Range(1, 5)])
- [ ] TypeScript interfaces to use strict types (no `any`) - must enable strict mode in tsconfig.json
- [ ] Enums to be defined for rating labels (1-5 scale with descriptive labels: Needs Improvement through Outstanding)
- [x] Nullable types properly handled (Guid? for optional project_id, feedback_request_id)

**Status**: NEEDS REVIEW  
**Notes**: Backend strongly typed. Frontend must create: (1) Rating enum type with 1-5 values, (2) All interfaces with explicit types, (3) No use of `any` type, (4) Proper null/undefined handling for optional fields.

### ✅ Principle 5: Offline Mode

- [x] Offline capabilities identified (submission form, feedback list, analytics)
- [x] Data caching strategy defined (IndexedDB for last 100 feedback items + offline submission queue + drafts)
- [x] Sync mechanism specified (delta sync with last_sync timestamp, retry logic with 3 attempts + exponential backoff)
- [x] Conflict resolution approach documented (deleted goal/employee error handling, user-friendly error messages with resolution options)

**Status**: PASS  
**Notes**: Comprehensive offline strategy: (1) Draft auto-save every 30s to IndexedDB with 7-day expiration, (2) Offline submission queue with status tracking, (3) Visual sync indicators ("Offline", "Syncing", "Last synced: X ago"), (4) Failed submissions after 3 retries prompt user with "Retry" button. Must implement IndexedDB schema and sync workers.

### ✅ Principle 6: Internationalization

- [x] All UI text externalizable (labels, placeholders, buttons, error messages, validation messages, empty states, tooltips)
- [x] i18n keys defined with clear naming convention (feedback.submit.title, feedback.list.empty_state, feedback.rating.label_1)
- [x] Locale-specific formatting identified (dates: MM/DD/YYYY vs DD/MM/YYYY, rating averages: "4.2" vs "4,2")
- [x] Translation strategy documented (English primary, support for es-ES, fr-FR, de-DE; user-generated content not translated)

**Status**: PASS  
**Notes**: Must create locales/en/feedback.json with ~50-60 translation keys covering all UI text. Date formatting using date-fns with user locale. Rating labels ("Needs Improvement" through "Outstanding") must be translated. Character counter and validation messages localized.

### ✅ Principle 7: Comprehensive Testing

- [x] Unit test strategy defined (Vitest + React Testing Library for components, Zustand store tests, API service mock tests)
- [x] Integration test scenarios identified (submission flow with API, filter/sort functionality, offline queue sync, draft auto-save)
- [x] Performance test requirements specified (submission < 300ms, list load < 200ms, search < 500ms, analytics < 1.5s)
- [x] Test coverage targets set (>80% for all components, stores, hooks, services)

**Status**: PASS  
**Notes**: Testing approach: (1) Component tests with user interaction scenarios, (2) Store tests for state management logic, (3) React Query hooks with MSW for API mocking, (4) Offline queue integration tests, (5) Accessibility tests with jest-axe, (6) Performance tests with Lighthouse CI.

### ✅ Principle 8: Performance-First React Development

- [x] Performance targets defined (My Feedback page < 2s on 3G, submission < 300ms, search debounced at 500ms)
- [x] React Query caching strategy specified (staleTime: 5 minutes for feedback list, gcTime: 30 minutes, prefetching for detail pages)
- [x] Component optimization approach documented (React.memo for feedback cards, useMemo for filter/sort logic, useCallback for handlers)
- [x] Lazy loading identified (analytics dashboard lazy-loaded, feedback detail page code-split, chart library (recharts) lazy-loaded)

**Status**: PASS  
**Notes**: Performance optimizations: (1) Virtual scrolling for long feedback lists (react-window), (2) Debounced search at 500ms, (3) Optimistic updates for submissions, (4) Image lazy loading for avatars, (5) React Query query invalidation strategies. Must measure Core Web Vitals (LCP < 2.5s, FID < 100ms, CLS < 0.1).

### ✅ Principle 9: Strict Naming Conventions

- [x] JSON/API: snake_case verified (feedback_request_id, goal_id, employee_id, project_id, from_employee_id, to_employee_id, created_at)
- [x] C# Properties: PascalCase with `[JsonPropertyName]` attributes (FeedbackRequestId → feedback_request_id, GoalId → goal_id)
- [x] TypeScript: camelCase in code (feedbackRequestId, goalId), snake_case in API types via mapping layer
- [x] Database: snake_case for tables/columns (feedback table, feedback_request_id column, created_at column)
- [x] URLs: kebab-case verified (/api/feedback, /api/me/feedback, frontend routes: /feedback, /feedback/:id, /feedback/analytics)

**Status**: PASS  
**Notes**: All naming conventions strictly followed. Frontend API service layer must map between camelCase (TypeScript) and snake_case (JSON) using transformation utilities. File names: kebab-case (feedback-list.tsx, feedback-form.tsx). Component names: PascalCase (FeedbackList, FeedbackForm).

### ✅ Principle 10: Security & Data Privacy

- [x] Authentication requirements specified (JWT Bearer token required for all endpoints, 401 Unauthorized if missing/invalid)
- [x] Authorization rules defined (employees can only: submit feedback to others (not self), view feedback addressed to them; managers cannot view reports' feedback unless shared; admins read-only for auditing)
- [x] Data encryption approach documented (HTTPS enforced for all API calls, plain text content sanitized to remove control characters, no HTML allowed)
- [x] Privacy controls identified (feedback visibility restricted to recipient via to_employee_id check, no public feedback exposure)
- [x] Sensitive data handling specified (input sanitization removes control characters, XSS prevention via React automatic escaping, CSRF tokens on state-changing requests, rate limiting: 30 requests/minute per user)

**Status**: PASS  
**Notes**: Security measures: (1) Self-feedback prevention (client + server validation), (2) Content sanitization (backend removes control characters, frontend displays as plain text), (3) Audit logging (created_by, created_at, IP address), (4) Rate limiting prevents abuse, (5) SQL injection prevented via EF Core parameterized queries.

### ✅ Principle 11: Database Design Standards

- [x] Entities use UUIDs for primary keys (feedback.id is UUID)
- [x] Proper foreign key constraints defined (feedback_request_id → feedback_requests.id ON DELETE SET NULL, goal_id → goals.id ON DELETE SET NULL, from_employee_id/to_employee_id → employees.id ON DELETE CASCADE)
- [x] Indexes identified for performance (idx_feedback_to_employee for recipient queries, idx_feedback_goal for goal-based filtering, idx_feedback_created_at for time-range queries, composite index on (to_employee_id, created_at) for pagination)
- [x] Normalization level appropriate (3NF: feedback table references goals, projects, employees via foreign keys; no redundant data stored)
- [x] Migration strategy planned (feedback table already exists from backend implementation; no new migrations needed for this UI-only phase)

**Status**: PASS  
**Notes**: Database schema already complete from backend implementation (Feature F005 API). No database changes required for frontend-only phase. If data model changes needed in future, follow EF Core migration process: (1) Update entity, (2) Generate migration, (3) Test in dev, (4) Apply to staging, (5) Apply to production with rollback plan.

---

## Technical Context

### Technology Stack

**Backend (cpr-api)**:

- Framework: .NET 9.0 Web API (existing, no changes needed)
- Language: C# 13 (existing, no changes needed)
- Database: PostgreSQL 16 (existing, no changes needed)
- ORM: Entity Framework Core 9.0 (existing, no changes needed)
- Authentication: JWT Bearer tokens via Microsoft Entra External ID (existing, no changes needed)
- Key Libraries: Already implemented (no new backend libraries required for this UI-only phase)

**Frontend (cpr-ui)**:

- Framework: React 18
- Language: TypeScript 5
- State Management: Zustand (global state), React Query (server state)
- UI Library: Material-UI v6 (MUI)
- Build Tool: Vite
- Testing: Vitest, React Testing Library, MSW (Mock Service Worker)
- Key Libraries:
  - `dexie` (v3.2+) - IndexedDB wrapper for offline queue, drafts, and caching
  - `date-fns` (v2.30+) - Date formatting and locale support
  - `react-hook-form` (v7.48+) - Form state management with validation
  - `zod` (v3.22+) - Schema validation for forms
  - `react-window` (v1.8+) - Virtual scrolling for large feedback lists
  - `recharts` (v2.10+) - Charts for analytics dashboard (lazy-loaded)
  - `react-i18next` (existing) - Internationalization
  - `axios` (existing) - HTTP client

### Architecture Patterns

**Backend Patterns** (Already Implemented):

- [x] Repository Pattern (IFeedbackRepository, FeedbackRepository)
- [x] Service Layer Pattern (IFeedbackService, FeedbackService)
- [x] Clean Architecture (Domain, Application, Infrastructure, API layers)
- [x] Dependency Injection (ASP.NET Core DI container)

**Frontend Patterns** (To Be Implemented):

- [x] Component Composition (presentational components + container components)
- [x] Custom Hooks (useSubmitFeedback, useMyFeedback, useFeedbackFilters, useOfflineQueue)
- [x] React Query for Server State (queries for GET, mutations for POST)
- [x] Zustand for Client State (filter preferences, UI state)
- [x] Service Layer Pattern (feedbackService.ts for API calls)
- [x] Adapter Pattern (snake_case ↔ camelCase transformation in API service)
- [x] Observer Pattern (offline queue sync events, draft auto-save)
- [x] Repository Pattern for Offline Storage (IndexedDB repositories)

### Integration Points

1. **F004 - Feedback Request Management**

   - Integration Type: API linkage (feedback_request_id foreign key), shared navigation flow
   - Impact: When submitting feedback in response to request, system marks request as completed (is_completed = true, responded_at timestamp updated). Feedback submission form accessed from feedback request todo list and detail pages.
   - Files Affected:
     - Backend: src/CPR.Application/Services/Implementations/FeedbackService.cs (already handles feedback_request_id linking)
     - Frontend (new): src/components/Feedback/FeedbackForm.tsx (accepts pre-populated feedbackRequestId, goalId from navigation state)
     - Frontend (existing): src/components/FeedbackRequests/RequestDetail.tsx (adds "Respond" button linking to feedback form)

2. **F001 - Personal Goal Management**

   - Integration Type: API call to GET /api/me/goals for goal selection dropdown, deep linking from goal detail pages
   - Impact: Feedback submission form includes searchable goal dropdown showing user's goals. Goal detail pages provide "Give Feedback" action. Feedback list can filter by goal.
   - Files Affected:
     - Frontend (new): src/services/feedbackService.ts (calls GET /api/me/goals for recipient's goals)
     - Frontend (existing): src/components/Goals/GoalDetail.tsx (adds "Give Feedback" action button)
     - Frontend (new): src/components/Feedback/GoalSelect.tsx (dropdown component with goal search)

3. **F011 - Project Team Management**

   - Integration Type: API call to GET /api/projects for project selection dropdown
   - Impact: Optional project association on feedback submission. Feedback can be filtered by project. Displays project context (title, status, role) on feedback cards and detail pages.
   - Files Affected:
     - Frontend (new): src/services/feedbackService.ts (fetches shared projects between submitter and recipient)
     - Frontend (new): src/components/Feedback/ProjectSelect.tsx (project dropdown component)

4. **Authentication & User Profile System**

   - Integration Type: JWT Bearer token authentication, current user profile (GET /api/me)
   - Impact: All feedback API calls require authentication. Current user profile determines feedback submission authorization and visibility (can only view own received feedback).
   - Files Affected:
     - Frontend (existing): src/services/apiClient.ts (adds Authorization header with JWT token)
     - Frontend (existing): src/hooks/queries/useCurrentUser.ts (provides authenticated user context)
     - Frontend (new): src/components/Feedback/\* (all components require authenticated context)

5. **Dashboard System**
   - Integration Type: Dashboard widget integration, navigation links
   - Impact: Dashboard displays feedback summary widget (total count, average rating, recent feedback). Widget links to "My Feedback" page. Analytics data from GET /api/me/feedback feeds dashboard metrics.
   - Files Affected:
     - Frontend (existing): src/components/Dashboard/DashboardLayout.tsx (adds feedback summary widget)
     - Frontend (new): src/components/Feedback/FeedbackSummaryWidget.tsx (dashboard widget component)

### Dependencies

**External Dependencies**:

- [ ] New NuGet packages: None (backend complete)
- [x] New npm packages:
  - `dexie@^3.2.0` - IndexedDB wrapper for offline queue and drafts
  - `react-hook-form@^7.48.0` - Form state management
  - `zod@^3.22.0` - Schema validation
  - `react-window@^1.8.0` - Virtual scrolling for performance
  - `recharts@^2.10.0` - Charts for analytics (lazy-loaded)
- [ ] External APIs: None (all APIs internal to CPR backend)

**Internal Dependencies**:

- [x] F004 - Feedback Request Management (Completed) - Required for feedback request linkage and navigation flow
- [x] F001 - Personal Goal Management API (Partially Complete) - GET /api/me/goals endpoint exists, used for goal selection dropdown
- [x] Authentication System (Complete) - JWT token authentication and user profile endpoints required
- [ ] Shared components needed (to be created or verified):
  - EmployeeAutocomplete component (for recipient selection in unsolicited feedback)
  - SearchableDropdown component (for goal and project selection)
  - RatingInput component (1-5 star input with hover labels)
  - LoadingState component (consistent loading UI)
  - ErrorBoundary component (error handling wrapper)
  - EmptyState component (consistent empty state UI)
  - FilterChip component (active filter display)
  - PaginationControls component (reusable pagination)
  - ConfirmationDialog component (unsaved changes, discard drafts)

---

## Implementation Phases

### Phase 1: Foundation & Setup (Frontend Only)

**Duration**: 2-3 days

**Objectives**:

- Install npm dependencies (dexie, react-hook-form, zod, react-window, recharts)
- Create TypeScript interfaces matching backend DTOs
- Set up IndexedDB schema for offline support (Dexie)
- Create API service layer for feedback endpoints
- Set up i18n translation files
- Create shared components (EmployeeAutocomplete, RatingInput, etc.)

**Deliverables**:

- [x] Backend already complete (no changes needed)
- [ ] npm packages installed and configured
- [ ] TypeScript interfaces created matching C# DTOs (SubmitFeedbackRequest, Feedback, MyFeedback)
- [ ] IndexedDB schema defined (drafts, offline queue, cached feedback)
- [ ] API service layer scaffolded (feedbackService.ts with snake_case ↔ camelCase mapping)
- [ ] i18n translation keys defined (locales/en/feedback.json)
- [ ] Shared components created (RatingInput, EmployeeAutocomplete, SearchableDropdown)

**Key Files** (Backend):

```
Backend already complete - no files to create
```

**Key Files** (Frontend):

```
src/types/feedback.ts
src/dtos/feedback.ts
src/services/feedbackService.ts
src/services/offlineQueue.ts
src/db/feedbackDb.ts (Dexie schema)
src/components/shared/RatingInput.tsx
src/components/shared/EmployeeAutocomplete.tsx
src/components/shared/SearchableDropdown.tsx
src/locales/en/feedback.json
```

---

### Phase 2: User Story 1 - Submit Feedback Response (US-001)

**Duration**: 3-4 days

**Objectives**:

- Implement feedback submission form for responding to feedback requests
- Add goal and project selection dropdowns with search
- Implement real-time validation and character counter
- Add draft auto-save functionality (IndexedDB, 30s interval)
- Implement offline submission queue with retry logic

**Deliverables**:

- [ ] FeedbackForm component with all form fields (goal, project, rating, content)
- [ ] Goal and project selection dropdowns with search/autocomplete
- [ ] Real-time validation (10-2000 chars, required fields, inline errors)
- [ ] Character counter with color coding (green/yellow/red)
- [ ] Draft auto-save to IndexedDB every 30 seconds
- [ ] Duplicate detection logic (24-hour check, bypassed for feedback requests)
- [ ] Offline submission queue with IndexedDB storage
- [ ] Success/error handling with user-friendly messages
- [ ] Integration with feedback request completion (marks request as completed)
- [ ] React Query mutation for POST /api/feedback with optimistic updates

**Key Files** (Frontend):

```
src/components/Feedback/FeedbackForm.tsx
src/components/Feedback/GoalSelect.tsx
src/components/Feedback/ProjectSelect.tsx
src/hooks/mutations/useSubmitFeedback.ts
src/hooks/queries/useGoals.ts
src/hooks/queries/useProjects.ts
src/services/draftManager.ts
src/services/duplicateDetection.ts
```

---

### Phase 3: User Story 2 - View Received Feedback (US-002)

**Duration**: 4-5 days

**Objectives**:

- Implement "My Feedback" list page with card-based layout and pagination
- Add comprehensive filtering (date range, rating, goal, project, provider) with LocalStorage persistence
- Add sorting options (date, rating, provider name, goal title)
- Implement search functionality (content search, debounced 500ms)
- Create feedback detail page with full content and metadata
- Add analytics summary section (total count, average rating, rating distribution)
- Implement offline caching with IndexedDB (last 100 items, delta sync)

**Deliverables**:

- [ ] FeedbackList component with card layout and pagination (20 items/page)
- [ ] Filter sidebar with all filter types (date, rating, goal, project, provider)
- [ ] Filter persistence to LocalStorage (survives browser restart)
- [ ] Active filter chips display with "Clear All" option
- [ ] Sort dropdown with 6 sort options
- [ ] Search input with debouncing (500ms) and highlighting
- [ ] FeedbackDetail page with full feedback content and context
- [ ] Empty state with onboarding content and "Request Feedback" CTA
- [ ] Analytics summary cards (metrics, charts)
- [ ] IndexedDB caching with delta sync (last_sync timestamp)
- [ ] "Last synced" indicator with manual refresh button
- [ ] Virtual scrolling for performance (react-window) if list > 50 items
- [ ] React Query for GET /api/me/feedback with pagination and filtering

**Key Files** (Frontend):

```
src/components/Feedback/FeedbackList.tsx
src/components/Feedback/FeedbackCard.tsx
src/components/Feedback/FeedbackDetail.tsx
src/components/Feedback/FeedbackFilters.tsx
src/components/Feedback/FilterChips.tsx
src/components/Feedback/FeedbackSearch.tsx
src/components/Feedback/FeedbackSummary.tsx
src/components/Feedback/EmptyFeedbackState.tsx
src/hooks/queries/useMyFeedback.ts
src/hooks/useFeedbackFilters.ts
src/stores/feedbackFiltersStore.ts
src/services/feedbackCache.ts
src/utils/feedbackFiltering.ts
src/utils/feedbackSorting.ts
```

---

### Phase 4: User Story 3 - Submit Unsolicited Feedback (US-003)

**Duration**: 2-3 days

**Objectives**:

- Extend FeedbackForm to support unsolicited feedback (proactive submission without feedback request)
- Add recipient selection with EmployeeAutocomplete component
- Make goal selection optional ("Skip goal association" checkbox for general feedback)
- Implement validation (no self-feedback, recipient must be valid employee)
- Add duplicate detection for unsolicited feedback (24-hour window, exact goal match or null goal)
- Create navigation entry points (employee profile page, goal detail page, main navigation, dashboard widget)

**Deliverables**:

- [ ] Enhanced FeedbackForm component to support both solicited and unsolicited modes
- [ ] EmployeeAutocomplete component for recipient selection (search by name, email, department)
- [ ] Self-feedback prevention (client-side + server-side validation)
- [ ] Optional goal selection with "Skip goal association" checkbox
- [ ] Dynamic goal fetching based on selected recipient (GET /api/employees/{id}/goals)
- [ ] Duplicate detection for unsolicited feedback (same recipient + goal + 24 hours)
- [ ] Navigation links from employee profile, goal detail, main nav, dashboard
- [ ] Separate routing for unsolicited feedback form (/feedback/new vs /feedback/respond/:requestId)

**Key Files** (Frontend):

```
src/components/Feedback/FeedbackForm.tsx (enhanced to support both modes)
src/components/Feedback/RecipientSelect.tsx
src/components/shared/EmployeeAutocomplete.tsx
src/hooks/queries/useEmployeeGoals.ts
src/utils/selfFeedbackValidation.ts
src/pages/NewFeedbackPage.tsx
```

---

### Phase 5: User Story 4 - Feedback Analytics & Insights (US-004)

**Duration**: 3-4 days

**Objectives**:

- Create analytics dashboard with comprehensive metrics and visualizations
- Implement time range selector (Last 30 days, Last 90 days, YTD, All time, Custom)
- Add comparison view (current period vs previous period with delta indicators)
- Create interactive charts (rating distribution bar chart, feedback by month line chart)
- Implement drill-down capabilities (click chart to filter feedback list)
- Add export functionality (PDF report, CSV data export)
- Lazy-load recharts library for performance

**Deliverables**:

- [ ] FeedbackAnalytics page with tab navigation (Feedback List | Analytics)
- [ ] Metrics cards: Total Feedback, Average Rating, Feedback by Time, Rating Distribution
- [ ] Top lists: Top 5 providers, Top 5 goals, Top 5 projects (with counts and averages)
- [ ] Time range selector with 6 preset options + custom date picker
- [ ] Comparison toggle with previous period calculation and delta indicators
- [ ] Interactive bar chart for rating distribution (horizontal bars with percentages)
- [ ] Line chart for feedback count per month (last 12 months)
- [ ] Drill-down functionality (click chart segment to filter main feedback list)
- [ ] Export to PDF (generates report with all analytics, charts, summary)
- [ ] Export to CSV (raw feedback data with columns: date, provider, goal, project, rating, content)
- [ ] Accessible data tables ("View as Table" toggle for screen readers)
- [ ] Lazy-load recharts library (code-splitting for performance)

**Key Files** (Frontend):

```
src/components/Feedback/FeedbackAnalytics.tsx
src/components/Feedback/MetricsCards.tsx
src/components/Feedback/RatingDistributionChart.tsx
src/components/Feedback/FeedbackTrendChart.tsx
src/components/Feedback/TopProvidersList.tsx
src/components/Feedback/TimeRangeSelector.tsx
src/components/Feedback/ComparisonView.tsx
src/hooks/queries/useFeedbackAnalytics.ts
src/utils/analyticsCalculations.ts
src/utils/exportToPdf.ts
src/utils/exportToCsv.ts
```

---

### Phase 6: Testing & Quality Assurance

**Duration**: 3-4 days

**Objectives**:

- Write comprehensive unit tests for all components, hooks, stores, services
- Write integration tests for critical user flows (submission, viewing, filtering, offline sync)
- Perform performance testing (load times, API response times, virtual scrolling)
- Conduct accessibility audit (WCAG 2.1 AA compliance, keyboard navigation, screen readers)
- Security testing (XSS prevention, CSRF tokens, rate limiting)
- Cross-browser testing (Chrome, Firefox, Safari, Edge)
- Mobile responsiveness testing (iOS Safari, Android Chrome)

**Deliverables**:

- [ ] Unit tests for all components (>80% coverage target)
- [ ] Unit tests for hooks (useSubmitFeedback, useMyFeedback, useFeedbackFilters)
- [ ] Unit tests for Zustand stores (feedbackFiltersStore)
- [ ] Unit tests for services (feedbackService, offlineQueue, draftManager)
- [ ] Integration tests for submission flow (form validation, API call, success/error handling)
- [ ] Integration tests for offline queue (submission, retry logic, sync on reconnect)
- [ ] Integration tests for draft auto-save (30s interval, load on return, discard)
- [ ] Integration tests for filtering and sorting (LocalStorage persistence)
- [ ] Performance tests: FeedbackList load time < 2s on 3G
- [ ] Performance tests: POST /api/feedback < 300ms (95th percentile)
- [ ] Performance tests: GET /api/me/feedback < 200ms (95th percentile)
- [ ] Accessibility tests with jest-axe (no violations)
- [ ] Keyboard navigation tests (tab order, focus management, keyboard shortcuts)
- [ ] Screen reader tests (ARIA labels, announcements, alt text)
- [ ] Cross-browser compatibility tests
- [ ] Mobile responsiveness tests (breakpoints: 320px, 768px, 1024px, 1440px)

**Key Files** (Testing):

```
tests/CPR.Tests/Controllers/FeedbackControllerTests.cs (backend - already exists)
tests/CPR.Tests/Services/FeedbackServiceTests.cs (backend - already exists)
src/components/Feedback/__tests__/FeedbackForm.test.tsx
src/components/Feedback/__tests__/FeedbackList.test.tsx
src/components/Feedback/__tests__/FeedbackDetail.test.tsx
src/components/Feedback/__tests__/FeedbackAnalytics.test.tsx
src/hooks/__tests__/useSubmitFeedback.test.ts
src/hooks/__tests__/useMyFeedback.test.ts
src/services/__tests__/feedbackService.test.ts
src/services/__tests__/offlineQueue.test.ts
src/services/__tests__/draftManager.test.ts
src/stores/__tests__/feedbackFiltersStore.test.ts
src/__tests__/integration/feedbackSubmission.test.tsx
src/__tests__/integration/offlineQueue.test.tsx
src/__tests__/performance/feedbackList.perf.test.tsx
src/__tests__/accessibility/feedback.a11y.test.tsx
```

---

### Phase 7: Documentation, Polish & Deployment

**Duration**: 2-3 days

**Objectives**:

- Complete user documentation (help guides, tooltips, onboarding)
- Finalize i18n translations (English complete, prepare for Spanish, French, German)
- Perform final code review and refactoring
- Complete accessibility polish (ARIA labels, focus indicators, contrast ratios)
- Prepare deployment checklist and rollback plan
- Create feature toggle for gradual rollout

**Deliverables**:

- [ ] User help documentation (how to submit feedback, view feedback, use analytics)
- [ ] In-app tooltips and contextual help for all form fields
- [ ] Complete i18n translation keys (all English text externalized to locales/en/feedback.json)
- [ ] Translation templates prepared for Spanish, French, German (keys without values)
- [ ] Code review completed (peer review, style guide compliance)
- [ ] Accessibility polish: ARIA labels, focus indicators, keyboard shortcuts documented
- [ ] Performance optimization final pass (lazy loading, code splitting, bundle size analysis)
- [ ] Feature toggle implementation (gradual rollout capability)
- [ ] Deployment checklist: build verification, smoke tests, rollback procedures
- [ ] Monitoring and alerting setup (error tracking, performance metrics)
- [ ] Release notes prepared (user-facing changes, screenshots, benefits)
- [ ] Training materials for stakeholders (demo video, quick start guide)

**Key Files** (Documentation & Deployment):

```
documents/user-guides/feedback-submission-guide.md
documents/user-guides/feedback-analytics-guide.md
src/locales/en/feedback.json (complete)
src/locales/es/feedback.json (template)
src/locales/fr/feedback.json (template)
src/locales/de/feedback.json (template)
src/components/Feedback/FeedbackHelpTooltips.tsx
RELEASE_NOTES.md
DEPLOYMENT_CHECKLIST.md
```

---

## Data Model Changes

### NO DATABASE CHANGES REQUIRED

**Rationale**: The backend API for Feedback Submission & Collection is already fully implemented with complete database schema. This Phase 3 plan focuses exclusively on **frontend UI implementation**. All backend components exist:

- ✅ `feedback` table already created with all required columns
- ✅ Foreign key constraints already in place (goal_id, project_id, from_employee_id, to_employee_id, feedback_request_id)
- ✅ Indexes already created for query performance
- ✅ C# domain models (Feedback entity) already defined
- ✅ EF Core configurations already implemented
- ✅ Database migrations already applied to production

**Existing Database Schema** (for reference, see `data-model.md`):

**Table**: `feedback`

**Key Columns**:

- `id` (UUID, PRIMARY KEY)
- `goal_id` (UUID, FK to goals.id, ON DELETE SET NULL)
- `project_id` (UUID, FK to projects.id, ON DELETE SET NULL, NULLABLE)
- `from_employee_id` (UUID, FK to employees.id, ON DELETE CASCADE)
- `to_employee_id` (UUID, FK to employees.id, ON DELETE CASCADE)
- `content` (TEXT, 10-2000 characters)
- `rating` (INTEGER, 1-5 scale)
- `feedback_request_id` (UUID, FK to feedback_requests.id, ON DELETE SET NULL, NULLABLE)
- `created_at` (TIMESTAMP WITH TIME ZONE)
- `updated_at` (TIMESTAMP WITH TIME ZONE)

**Existing Indexes**:

- `idx_feedback_to_employee` on `to_employee_id` (for recipient queries)
- `idx_feedback_goal` on `goal_id` (for goal-based filtering)
- `idx_feedback_created_at` on `created_at` (for time-range queries)
- `idx_feedback_to_employee_created_at` on `(to_employee_id, created_at)` (composite for pagination)

**No Migrations Required**: This implementation phase does not require any database migrations or schema changes.

---

## API Endpoints Summary

See `endpoints.md` for complete endpoint specifications with DTOs, validation rules, and examples.

**Backend API Endpoints** (Already Implemented in cpr-api):

| Method | Endpoint                | Purpose                                          | Auth           | Status                    |
| ------ | ----------------------- | ------------------------------------------------ | -------------- | ------------------------- |
| POST   | `/api/feedback`         | Submit feedback from one employee to another     | Required (JWT) | ✅ Implemented            |
| GET    | `/api/me/feedback`      | Get all feedback addressed to authenticated user | Required (JWT) | ✅ Implemented            |
| GET    | `/api/me/feedback/{id}` | Get single feedback item by ID                   | Required (JWT) | ✅ Implemented (implicit) |

**Note**: The specification describes additional query parameters for filtering, sorting, and pagination on `GET /api/me/feedback`. Current backend implementation returns basic list. **Action Required**: Verify backend supports query parameters: `page`, `page_size`, `date_from`, `date_to`, `rating`, `goal_id`, `project_id`, `from_employee_id`, `search`, `sort_by`, `sort_order`. If not implemented, either (1) add backend support, or (2) implement client-side filtering/sorting in frontend (less efficient for large datasets).

**Frontend Routes** (To Be Implemented):

| Route                          | Component             | Purpose                                        | Access        |
| ------------------------------ | --------------------- | ---------------------------------------------- | ------------- |
| `/feedback`                    | FeedbackListPage      | View all received feedback with filters/search | Authenticated |
| `/feedback/:id`                | FeedbackDetailPage    | View single feedback item details              | Authenticated |
| `/feedback/analytics`          | FeedbackAnalyticsPage | View feedback analytics and insights           | Authenticated |
| `/feedback/new`                | NewFeedbackPage       | Submit unsolicited feedback                    | Authenticated |
| `/feedback/respond/:requestId` | RespondFeedbackPage   | Submit feedback in response to request         | Authenticated |

---

## Risk Assessment

### Technical Risks

| Risk                                                                                    | Probability | Impact | Mitigation Strategy                                                                                                                                                                                           |
| --------------------------------------------------------------------------------------- | ----------- | ------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Backend API missing filtering/pagination query params                                   | Medium      | Medium | (1) Verify backend implementation against spec, (2) If missing, implement client-side filtering for MVP (with note to add backend support later), (3) Frontend pagination can be client-side with cached data |
| IndexedDB browser compatibility issues (older browsers)                                 | Low         | Medium | (1) Use Dexie.js (excellent browser compatibility), (2) Feature detection with graceful degradation (no offline if IndexedDB unavailable), (3) Test on Safari, Firefox, Chrome, Edge                          |
| Performance issues with large feedback datasets (>1000 items)                           | Medium      | High   | (1) Implement virtual scrolling (react-window) for lists >50 items, (2) Use React Query pagination with window size 20, (3) Debounce search at 500ms, (4) Lazy-load analytics dashboard and charts            |
| Offline sync conflicts (user submits feedback offline, goal/employee deleted meanwhile) | Medium      | Low    | (1) Server returns 404 Not Found with clear message, (2) Frontend displays user-friendly error: "Goal no longer available. Please select a different goal.", (3) Allow user to edit and resubmit              |
| Draft auto-save causing performance issues (frequent IndexedDB writes)                  | Low         | Low    | (1) Debounce saves at 30s (not every keystroke), (2) Use Dexie's efficient upsert, (3) Monitor performance with React DevTools Profiler                                                                       |
| Translation key management becomes unwieldy (50-60 keys)                                | Low         | Low    | (1) Use structured namespacing (feedback.submit._, feedback.list._), (2) Create i18n key documentation, (3) Use TypeScript for type-safe translation keys                                                     |
| Accessibility issues not caught until final audit                                       | Medium      | Medium | (1) Use jest-axe during development (automated a11y testing), (2) Test with keyboard navigation early and often, (3) Use ARIA best practices from start (not retrofit later)                                  |
| Bundle size bloat from new dependencies (recharts, dexie, react-window)                 | Medium      | Low    | (1) Lazy-load recharts (analytics dashboard code-split), (2) Tree-shake unused dexie features, (3) Monitor bundle size with webpack-bundle-analyzer, (4) Target: keep total bundle increase <150KB gzipped    |

### Dependencies & Blockers

**Potential Blockers**:

1. **Backend API Query Parameters**

   - Status: NEEDS VERIFICATION
   - Impact if missing: Frontend must implement client-side filtering/sorting (less efficient, limited scalability)
   - Mitigation: (1) Check backend implementation now, (2) If missing, create backend task to add query param support, (3) Implement client-side filtering for MVP with TODO to migrate to server-side

2. **EmployeeAutocomplete Component**

   - Status: UNKNOWN (may not exist as shared component)
   - Impact if missing: 2-3 additional hours to create from scratch
   - Mitigation: (1) Search codebase for existing employee search/autocomplete components, (2) If exists, refactor for reusability, (3) If not, create as shared component in Phase 1

3. **GET /api/me/goals Endpoint**

   - Status: PARTIALLY COMPLETE (exists but may not support querying other employees' goals)
   - Impact if missing: Cannot fetch recipient's goals for feedback submission form
   - Mitigation: (1) Verify endpoint supports GET /api/employees/{id}/goals, (2) If not, add backend endpoint or use workaround (fetch via different route)

4. **Feature Toggle System**
   - Status: UNKNOWN (may not have feature toggle infrastructure)
   - Impact if missing: Cannot do gradual rollout (all-or-nothing deployment)
   - Mitigation: (1) Check if feature toggle system exists, (2) If not, use environment variable for simple on/off toggle, (3) Consider LaunchDarkly or similar for future

---

## Performance Considerations

### Performance Targets

**API Performance** (Backend - Already Achieved):

- ✅ POST /api/feedback submission: < 300ms at 95th percentile
- ✅ GET /api/me/feedback list: < 200ms at 95th percentile (20 items with includes)
- ✅ Database queries: < 50ms for indexed queries
- ✅ Concurrent users: Support 100+ concurrent users

**Frontend Performance** (To Be Achieved):

- My Feedback page initial load: < 2s on 3G network (including data fetch + rendering)
- Feedback submission success: < 300ms perceived time (with optimistic updates)
- Search results display: < 500ms after debounce (client-side search on cached data)
- Analytics dashboard render: < 1.5s with 12 months of data
- Virtual scrolling: 60 FPS for lists >50 items
- Offline sync: < 5s to sync queued submissions on reconnection
- Core Web Vitals:
  - LCP (Largest Contentful Paint): < 2.5s
  - FID (First Input Delay): < 100ms
  - CLS (Cumulative Layout Shift): < 0.1

### Optimization Strategies

**Backend** (Already Optimized):

- ✅ Database indexes on `to_employee_id`, `created_at`, `goal_id` for fast queries
- ✅ Pagination support to limit result sets (20 items per page)
- ✅ Async/await operations throughout service layer
- ✅ Entity Framework query optimization (proper includes, projections)

**Frontend** (To Be Implemented):

- [x] **React Query caching**:
  - staleTime: 5 minutes for feedback list (data doesn't change frequently)
  - gcTime: 30 minutes (keep in memory for navigation)
  - Prefetch feedback detail on card hover (instant navigation)
  - Query invalidation on successful submission (automatic list refresh)
- [x] **Component optimization**:
  - React.memo for FeedbackCard (prevent re-renders when parent updates)
  - useMemo for filter/sort computations (expensive operations)
  - useCallback for event handlers (stable references for child components)
- [x] **Code splitting**:
  - Lazy-load analytics dashboard (React.lazy + Suspense)
  - Lazy-load recharts library (reduces initial bundle)
  - Route-based code splitting (separate bundles per page)
- [x] **Virtual scrolling**:
  - Use react-window for lists >50 items
  - Only render visible feedback cards + buffer (10 items above/below)
  - Reduces DOM nodes from 1000+ to ~30 (massive performance gain)
- [x] **Debouncing**:
  - Search input debounced at 500ms (reduces re-renders)
  - Draft auto-save debounced at 30s (reduces IndexedDB writes)
- [x] **Image optimization**:
  - Lazy-load avatar images (loading="lazy" attribute)
  - Use avatar placeholders while loading
  - Optimize avatar dimensions (40px for cards, 80px for detail)
- [x] **Bundle size optimization**:
  - Tree-shake unused lodash functions
  - Use production builds (minification, dead code elimination)
  - Analyze with webpack-bundle-analyzer
  - Target: <150KB gzipped increase from dependencies

---

## Security Considerations

### Authentication & Authorization

**Authentication** (Already Implemented):

- Method: JWT Bearer tokens via Microsoft Entra External ID
- Token storage: HttpOnly cookies (secure, not accessible to JavaScript)
- Token expiration: 60 minutes (with refresh token support)
- Authentication required for ALL feedback endpoints (401 Unauthorized if missing)

**Authorization** (Already Implemented Backend, To Be Enforced Frontend):

- **Submission Rules**:
  - Users can submit feedback to ANY other employee (not self)
  - Self-feedback prevention enforced at both client (form disabled) and server (400 Bad Request)
- **Viewing Rules**:
  - Users can ONLY view feedback addressed to them (to_employee_id = current_user)
  - Managers CANNOT view direct reports' feedback unless explicitly shared
  - Admins have read-only access for auditing purposes
- **Rate Limiting** (Backend):
  - 30 requests per minute per user (429 Too Many Requests if exceeded)
  - Prevents spam and abuse

### Data Protection

**Backend Security** (Already Implemented):

- ✅ HTTPS enforced for all API communications (TLS 1.2+)
- ✅ Input validation with DataAnnotations ([Required], [StringLength], [Range])
- ✅ Content sanitization removes control characters (backend text cleaning)
- ✅ SQL injection prevention via EF Core parameterized queries (no raw SQL)
- ✅ Audit logging (created_by, created_at, IP address for all submissions)
- ✅ Feedback content stored as plain text (no HTML tags allowed)

**Frontend Security** (To Be Implemented):

- [x] **XSS Prevention**:
  - Use React's automatic escaping for all user-generated content
  - Display feedback content as plain text (not dangerouslySetInnerHTML)
  - Sanitize search query input before highlighting
  - Set Content Security Policy (CSP) headers
- [x] **CSRF Protection**:
  - Include anti-CSRF tokens on all state-changing requests (POST /api/feedback)
  - Verify tokens on backend (already implemented in ASP.NET Core)
- [x] **Sensitive Data Handling**:
  - Do not log feedback content to console or error tracking
  - Clear IndexedDB drafts after submission or 7-day expiration
  - No sensitive data in URL parameters (use POST body or state)
- [x] **Input Validation** (Client-Side):
  - Character count validation (10-2000 chars) with real-time feedback
  - Rating validation (1-5 range, required)
  - Recipient validation (cannot be self, must be valid employee)
  - Goal validation (must belong to recipient if provided)
- [x] **Offline Security**:
  - IndexedDB data encrypted by browser (OS-level encryption)
  - Clear offline queue after successful sync
  - Do not store sensitive tokens in IndexedDB (only in HttpOnly cookies)
- [x] **Rate Limiting (Frontend)**:
  - Duplicate submission prevention (24-hour window check)
  - Debounced search (500ms) to reduce API load
  - Throttled offline sync retries (exponential backoff)

---

## Effort Estimation

### Backend (cpr-api)

| Phase                     | Estimated Hours | Actual Hours | Notes                                             |
| ------------------------- | --------------- | ------------ | ------------------------------------------------- |
| Backend Complete          | 0               | ✅ Completed | API already fully implemented (F005 backend done) |
| Verification & Adjustment | 2-4             | -            | Verify query params support, add if missing       |
| **Total Backend**         | **2-4**         | -            | **Minimal backend work required**                 |

### Frontend (cpr-ui)

| Phase                                           | Estimated Hours | Actual Hours | Notes                                                                                          |
| ----------------------------------------------- | --------------- | ------------ | ---------------------------------------------------------------------------------------------- |
| **Phase 1: Foundation & Setup**                 | **16-20**       | -            | npm packages, TypeScript types, IndexedDB schema, API service, shared components, i18n keys    |
| - Install dependencies                          | 1-2             | -            | npm install, configure dexie, zod, react-hook-form, react-window                               |
| - TypeScript interfaces                         | 2-3             | -            | SubmitFeedbackRequest, Feedback, MyFeedback, FilterOptions, SortOptions                        |
| - IndexedDB schema                              | 2-3             | -            | Dexie schema for drafts, offline queue, cached feedback                                        |
| - API service layer                             | 3-4             | -            | feedbackService.ts with snake_case ↔ camelCase mapping                                         |
| - Shared components                             | 6-8             | -            | RatingInput, EmployeeAutocomplete, SearchableDropdown, FilterChip                              |
| - i18n translation keys                         | 2-3             | -            | ~50-60 keys for all UI text                                                                    |
| **Phase 2: US-001 Submit Feedback Response**    | **24-32**       | -            | Feedback submission form with draft auto-save, offline queue, duplicate detection              |
| - FeedbackForm component                        | 8-10            | -            | Form with react-hook-form, zod validation, character counter, real-time validation             |
| - Goal & project selection                      | 4-6             | -            | Searchable dropdowns with API integration                                                      |
| - Draft auto-save                               | 3-4             | -            | IndexedDB storage, 30s debounce, load/discard UI                                               |
| - Offline submission queue                      | 5-7             | -            | IndexedDB queue, retry logic with exponential backoff, sync status indicators                  |
| - Duplicate detection                           | 2-3             | -            | 24-hour check, error modal, bypass for feedback requests                                       |
| - React Query mutation                          | 2-3             | -            | useSubmitFeedback hook with optimistic updates                                                 |
| **Phase 3: US-002 View Received Feedback**      | **32-40**       | -            | Feedback list with filtering, sorting, search, detail page, analytics summary, offline caching |
| - FeedbackList & cards                          | 8-10            | -            | Card layout, pagination (20/page), empty state, avatar display                                 |
| - Filter sidebar                                | 8-10            | -            | Date range, rating, goal, project, provider filters with LocalStorage persistence              |
| - Search & sorting                              | 4-5             | -            | Debounced search (500ms), 6 sort options, result highlighting                                  |
| - FeedbackDetail page                           | 4-5             | -            | Full content display, metadata, context (goal, project), navigation                            |
| - Analytics summary                             | 4-6             | -            | Metrics cards (total, average, distribution), mini charts                                      |
| - Offline caching                               | 4-6             | -            | IndexedDB cache (last 100 items), delta sync, "last synced" indicator                          |
| - Virtual scrolling                             | 2-3             | -            | react-window integration for lists >50 items                                                   |
| **Phase 4: US-003 Submit Unsolicited Feedback** | **16-20**       | -            | Extend FeedbackForm, recipient selection, optional goal, navigation entry points               |
| - Enhanced FeedbackForm                         | 6-8             | -            | Support both solicited/unsolicited modes, conditional fields                                   |
| - Recipient selection                           | 4-5             | -            | EmployeeAutocomplete, dynamic goal fetching, self-feedback prevention                          |
| - Optional goal logic                           | 2-3             | -            | "Skip goal association" checkbox, null goal handling                                           |
| - Navigation entry points                       | 4-5             | -            | Links from employee profile, goal detail, main nav, dashboard widget                           |
| **Phase 5: US-004 Feedback Analytics**          | **24-30**       | -            | Analytics dashboard with charts, time range selector, comparison view, drill-down, export      |
| - Analytics page layout                         | 4-5             | -            | Tab navigation, metrics grid, responsive layout                                                |
| - Metrics cards                                 | 4-5             | -            | Total, average, distribution, trends with delta indicators                                     |
| - Charts (recharts)                             | 6-8             | -            | Rating distribution bar chart, feedback by month line chart, lazy-loaded                       |
| - Top lists                                     | 3-4             | -            | Top providers, goals, projects with counts and averages                                        |
| - Time range & comparison                       | 4-5             | -            | Selector with 6 presets + custom, comparison logic with previous period                        |
| - Drill-down & export                           | 4-6             | -            | Click to filter, export to PDF/CSV, accessible data tables                                     |
| **Phase 6: Testing & QA**                       | **24-32**       | -            | Unit tests, integration tests, performance tests, accessibility audit                          |
| - Component unit tests                          | 10-12           | -            | All components (form, list, detail, analytics) with React Testing Library                      |
| - Hook & service tests                          | 4-6             | -            | Custom hooks, API service, offline queue, draft manager, Zustand stores                        |
| - Integration tests                             | 6-8             | -            | Submission flow, offline sync, filtering, draft auto-save                                      |
| - Performance tests                             | 2-3             | -            | Load time benchmarks, Core Web Vitals measurement                                              |
| - Accessibility audit                           | 2-4             | -            | jest-axe, keyboard navigation, screen reader testing                                           |
| **Phase 7: Documentation & Deployment**         | **16-20**       | -            | User guides, i18n finalization, code review, deployment prep                                   |
| - User documentation                            | 4-5             | -            | Help guides, tooltips, onboarding content                                                      |
| - i18n finalization                             | 3-4             | -            | Complete English, prepare translation templates                                                |
| - Code review & polish                          | 4-6             | -            | Peer review, refactoring, accessibility polish                                                 |
| - Deployment prep                               | 5-7             | -            | Feature toggle, deployment checklist, monitoring, release notes                                |
| **Total Frontend**                              | **152-194**     | -            | **Estimated 152-194 hours**                                                                    |

### Overall Estimate

**Total Estimated Effort**: **154-198 hours** (frontend-focused)

**Breakdown**:

- Backend verification: 2-4 hours
- Frontend implementation: 152-194 hours

**Timeline Estimates** (assuming 1 full-time frontend developer at 8 hours/day):

- **Optimistic**: 154 hours = 19 days = **~4 weeks**
- **Realistic**: 176 hours (midpoint) = 22 days = **~4.5 weeks**
- **Conservative**: 198 hours = 25 days = **~5 weeks**

**Buffer Recommendation**: Add 20-25% buffer for unknowns (e.g., unexpected API issues, design iterations, stakeholder feedback):

- **With Buffer**: 198 hours + 25% = **~248 hours** = **31 days** = **~6 weeks**

**Recommended Timeline**: **14-18 business days** of actual development time, which translates to **4-6 weeks** calendar time accounting for meetings, code reviews, and context switching.

**Team Composition**:

- 1 Frontend Developer (primary): Phases 1-7
- 1 Backend Developer (support): 2-4 hours for verification/adjustments
- 1 QA Engineer (Phase 6): 8-16 hours for testing support
- 1 UX Designer (reviews): 4-6 hours for design validation

**Critical Path**: Phase 2 (US-001) → Phase 3 (US-002) → Phase 4 (US-003) → Phase 5 (US-004) → Phase 6 (Testing)

**Parallelization Opportunities**: Phase 1 (Foundation) can be split between multiple developers if available (e.g., one on shared components, one on API service).

---

## Success Metrics

### Functional Metrics

- [ ] All 4 user stories fully implemented (US-001 through US-004)
- [ ] All 12 business rules enforced (self-feedback prevention, duplicate detection, content sanitization, etc.)
- [ ] All acceptance criteria met (verified via checklist in description.md)
- [ ] Zero critical bugs in production (P0/P1 bugs blocking core functionality)
- [ ] Zero data integrity issues (feedback correctly linked to goals, requests, employees)

### Quality Metrics

- [ ] Frontend code coverage > 80% (Vitest + React Testing Library)
- [ ] Backend code coverage > 80% (already achieved, maintain with any changes)
- [ ] All unit tests passing (0 failures)
- [ ] All integration tests passing (0 failures)
- [ ] Zero security vulnerabilities (Snyk scan, npm audit pass)
- [ ] Accessibility score > 95 (Lighthouse audit, WCAG 2.1 AA compliance)
- [ ] Zero ESLint errors (linting compliance)
- [ ] Zero TypeScript errors (strict mode enabled, no `any` types)

### Performance Metrics

- [ ] My Feedback page load < 2s on 3G network (measured with Lighthouse)
- [ ] POST /api/feedback < 300ms at 95th percentile (measured with monitoring)
- [ ] GET /api/me/feedback < 200ms at 95th percentile (measured with monitoring)
- [ ] Search results display < 500ms after user stops typing (debounced search)
- [ ] Analytics dashboard render < 1.5s with 12 months data (measured with performance.now())
- [ ] Virtual scrolling maintains 60 FPS for lists >50 items (React DevTools Profiler)
- [ ] No performance regressions vs baseline (before feature implementation)
- [ ] Core Web Vitals: LCP < 2.5s, FID < 100ms, CLS < 0.1

### User Experience Metrics

- [ ] Task success rate > 95% (user can successfully submit feedback without errors)
- [ ] Feedback submission completion time < 2 minutes (measured in user testing)
- [ ] Filter application < 1 second (fast feedback for user actions)
- [ ] Offline submission works reliably (>95% success rate after reconnection)
- [ ] Draft recovery rate > 95% (users successfully recover auto-saved drafts)

### Business Metrics (Post-Launch)

- [ ] Feedback submission volume: >X submissions per week (to be defined)
- [ ] Feedback request response rate: >Y% of requests receive feedback (to be defined)
- [ ] User adoption: >Z% of employees submit at least one feedback per month (to be defined)
- [ ] User satisfaction: NPS score >X (to be measured via survey)

---

## Open Questions & Decisions Needed

### 1. **Backend Query Parameters Support**

- **Context**: Specification describes filtering, sorting, pagination query params for GET /api/me/feedback. Current backend implementation may not support all params.
- **Options**:
  - A. Add backend query param support (filtering, sorting, pagination server-side) - **Recommended**
  - B. Implement client-side filtering/sorting (fetch all data, filter in browser) - **MVP fallback**
- **Recommendation**: Option A (server-side filtering) for scalability and performance with large datasets
- **Decision**: **TO BE DECIDED** - Verify current backend implementation; if missing, prioritize backend query param support
- **Action**: Assign backend developer to verify and implement if needed (2-4 hours)

### 2. **EmployeeAutocomplete Component Availability**

- **Context**: Need reusable EmployeeAutocomplete component for recipient selection (unsolicited feedback)
- **Options**:
  - A. Reuse existing employee search component if available
  - B. Create new shared EmployeeAutocomplete component
- **Recommendation**: Search codebase first; if not found, create as shared component
- **Decision**: **DECIDED (2025-11-24)**: Create as shared component in Phase 1 if not found (budgeted 3-4 hours)

### 3. **Feature Toggle Strategy**

- **Context**: Gradual rollout capability for reducing risk
- **Options**:
  - A. Use environment variable (simple on/off toggle)
  - B. Implement feature flag system (LaunchDarkly, Azure App Configuration)
  - C. No toggle, full deployment
- **Recommendation**: Option A (environment variable) for MVP; consider Option B for future features
- **Decision**: **TO BE DECIDED** - Discuss with DevOps team

### 4. **Analytics Data Retention**

- **Context**: How long to retain feedback analytics data in IndexedDB cache
- **Options**:
  - A. 30 days (balance between freshness and storage)
  - B. 90 days (more historical data)
  - C. No limit (cache all time, sync on demand)
- **Recommendation**: Option A (30 days) for MVP, configurable for future
- **Decision**: **DECIDED (2025-11-24)**: 30 days retention for analytics data cache

### 5. **Export Format Specifications**

- **Context**: PDF and CSV export requirements (formatting, styling, branding)
- **Options**:
  - A. Basic PDF with plain text (simple, fast to implement)
  - B. Styled PDF with CPR branding (professional, more effort)
- **Recommendation**: Option A for MVP, Option B as enhancement
- **Decision**: **TO BE DECIDED** - Review with UX designer and product owner

### 6. **Translation Priority**

- **Context**: Which languages to translate first (English complete, others pending)
- **Options**:
  - A. English only for MVP
  - B. English + Spanish (large user base)
  - C. English + Spanish + French + German (full i18n)
- **Recommendation**: Option A (English) for MVP; translation templates prepared for future
- **Decision**: **TO BE DECIDED** - Confirm with product owner and stakeholder priorities

---

## References

- **Specification**: `specifications/0005-feedback-submission-collection/description.md` (1960 lines, comprehensive)
- **Tasks**: `specifications/0005-feedback-submission-collection/tasks.md` (to be completed with specific task breakdown)
- **Endpoints**: `specifications/0005-feedback-submission-collection/endpoints.md` (to be completed with API specs and TypeScript interfaces)
- **Data Model**: `specifications/0005-feedback-submission-collection/data-model.md` (backend already implemented, document for reference)
- **Progress Tracking**: `specifications/0005-feedback-submission-collection/progress.md` (Phase 2 complete, Phase 3 in progress)
- **Constitution**: `constitution.md` (CPR Constitutional Principles 1-11)
- **Architecture**: `documents/architecture.md` (System architecture patterns and standards)
- **Features List**: `features-list.md` (Feature F005 context and dependencies)
- **Related Features**:
  - F004 - Feedback Request Management (dependency, integration point)
  - F001 - Personal Goal Management (dependency, integration point)
  - F011 - Project Team Management (integration point)

**Backend Code References** (cpr-api):

- `src/CPR.Api/Controllers/FeedbackController.cs` - Feedback submission endpoint
- `src/CPR.Api/Controllers/MeFeedbackController.cs` - My feedback retrieval endpoint
- `src/CPR.Application/Contracts/FeedbackDtos.cs` - DTO definitions (SubmitFeedbackRequestDto, FeedbackDto, MyFeedbackDto)
- `src/CPR.Application/Services/Implementations/FeedbackService.cs` - Business logic
- `src/CPR.Infrastructure/Repositories/Implementations/FeedbackRepository.cs` - Data access
- `src/CPR.Domain/Entities/Feedback.cs` - Domain entity

---

## Change Log

| Date       | Author         | Changes                                                                   |
| ---------- | -------------- | ------------------------------------------------------------------------- |
| 2025-11-24 | Claude | Initial implementation plan created for Phase 3                           |
| 2025-11-24 | Claude | Completed constitutional compliance check for all 11 principles           |
| 2025-11-24 | Claude | Defined technical context, dependencies, and integration points           |
| 2025-11-24 | Claude | Created 7 implementation phases with detailed deliverables and file paths |
| 2025-11-24 | Claude | Added comprehensive risk assessment and mitigation strategies             |
| 2025-11-24 | Claude | Provided detailed effort estimation: 154-198 hours (14-18 days)           |
| 2025-11-24 | Claude | Documented performance considerations, security measures, success metrics |
