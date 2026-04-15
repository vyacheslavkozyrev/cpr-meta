# Plan — Org Hierarchy & Employee Directory (0012)

## Task List

### Migration

- [ ] T001 [Migration] Create EF Core migration adding `phone`, `avatar_url`, `location_id` to `users` and `hire_date` to `employees` — `source/cpr-api/src/CPR.Infrastructure/Migrations/20260409000001_AddEmployeeDirectoryFields.cs`

### Domain

- [ ] T002 [Domain] Add `Phone`, `AvatarUrl`, `LocationId` properties and `Location` navigation to `User` entity — `source/cpr-api/src/CPR.Domain/Entities/User.cs`
- [ ] T003 [Domain] Add `HireDate` property to `Employee` entity — `source/cpr-api/src/CPR.Domain/Entities/Employee.cs`
- [ ] T004 [Domain] Add `IEmployeeDirectoryRepository` interface with `GetEmployeeProfileAsync`, `GetOrgChartContextAsync`, `GetFullOrgChartAsync` — `source/cpr-api/src/CPR.Domain/Repositories/IEmployeeDirectoryRepository.cs`

### Infrastructure

- [ ] T005 [Infra] Update `CprDbContext` with EF column mappings for `User.Phone`, `User.AvatarUrl`, `User.LocationId` (FK→locations, index `IX_users_location_id`) and `Employee.HireDate` — `source/cpr-api/src/CPR.Infrastructure/Data/CprDbContext.cs`
- [ ] T006 [Infra] Implement `EmployeeDirectoryRepository` — queries for employee profile (with manager + direct reports), centred org context (self / manager / manager's manager / peers), and recursive full org tree — `source/cpr-api/src/CPR.Infrastructure/Repositories/EmployeeDirectoryRepository.cs`

### Application

- [ ] T007 [App] Add `OrgChartDtos.cs` containing `OrgNodeDto`, `OrgChartContextDto`, and `EmployeeProfileDto` records — `source/cpr-api/src/CPR.Application/DTOs/OrgChart/OrgChartDtos.cs`
- [ ] T008 [App] Add `IEmployeeDirectoryService` interface with `GetEmployeeProfileAsync`, `GetOrgChartContextAsync`, `GetFullOrgChartAsync` — `source/cpr-api/src/CPR.Application/Services/IEmployeeDirectoryService.cs`

### Infrastructure (services)

- [ ] T009 [Infra] Implement `EmployeeDirectoryService` delegating to `IEmployeeDirectoryRepository` and projecting results to DTOs — `source/cpr-api/src/CPR.Infrastructure/Services/EmployeeDirectoryService.cs`

### API

- [ ] T010 [API] Add `GET /api/employees/{id}` action to `EmployeesController` returning `EmployeeProfileDto`; all authenticated users — `source/cpr-api/src/CPR.Api/Controllers/EmployeesController.cs`
- [ ] T011 [API] Create `OrgChartController` with `GET /api/org-chart` (full tree) and `GET /api/org-chart/{employee_id}` (centred view); all authenticated users — `source/cpr-api/src/CPR.Api/Controllers/OrgChartController.cs`

### Config

- [ ] T012 [Config] Register `IEmployeeDirectoryRepository` and `IEmployeeDirectoryService` in `InfrastructureRegistrar` — `source/cpr-api/src/CPR.Api/InfrastructureRegistrar.cs`

### UI — Types & Services

- [ ] T013 [UI] Add TypeScript DTO and model types: `TOrgNodeDto`, `TEmployeeProfileDto`, `TOrgChartContextDto`, `TEmployeeDirectoryItemDto` — `source/cpr-ui/src/types/employee.types.ts`
- [ ] T014 [UI] Add `employeeProfileService` with `getEmployeeProfile(id)` → `GET /api/employees/{id}` — `source/cpr-ui/src/services/employeeProfileService.ts`
- [ ] T015 [UI] Add `orgChartService` with `getOrgChartContext(employeeId)` and `getFullOrgChart()` — `source/cpr-ui/src/services/orgChartService.ts`

### UI — Hooks

- [ ] T016 [UI] Add React Query hooks: `useEmployeeProfile(id)`, `useOrgChartContext(employeeId)`, `useFullOrgChart()` — `source/cpr-ui/src/hooks/useOrgChart.ts`

### UI — MSW Mock Handlers

- [ ] T017 [UI] Add MSW handlers for `GET /api/employees/:id`, `GET /api/org-chart/:employeeId`, `GET /api/org-chart`, and `GET /api/employees` (paged directory — mocked for 0004 compatibility) — `source/cpr-ui/src/mocks/handlers/employeeDirectoryHandlers.ts`
- [ ] T018 [UI] Register `employeeDirectoryHandlers` in the handler index — `source/cpr-ui/src/mocks/handlers/index.ts`

### UI — Components

- [ ] T019 [UI] Create `OrgNodeCard` — avatar, display name, job title; clickable; expand/collapse toggle prop — `source/cpr-ui/src/components/employees/OrgNodeCard.tsx`
- [ ] T020 [UI] Create `EmployeeCard` for directory listing — avatar, name, title, department, city, country, roles chip list — `source/cpr-ui/src/components/employees/EmployeeCard.tsx`

### UI — Pages

- [ ] T021 [UI] Create `EmployeeDirectoryPage` at `/employees` — paginated grid of `EmployeeCard`; name search field (debounced); role filter dropdown; empty state — `source/cpr-ui/src/pages/employees/EmployeeDirectoryPage.tsx`
- [ ] T022 [UI] Create `EmployeeProfilePage` at `/employees/:id` — profile header, contact section, career info, manager card, direct reports list, "View in org chart" button — `source/cpr-ui/src/pages/employees/EmployeeProfilePage.tsx`
- [ ] T023 [UI] Create `OrgChartMyView` sub-component — highlighted self node, manager chain, peers row, expandable direct reports — `source/cpr-ui/src/pages/orgChart/components/OrgChartMyView.tsx`
- [ ] T024 [UI] Create `OrgChartFullTree` sub-component — recursive tree from root nodes; in-memory expand/collapse state; level-1 visible on load — `source/cpr-ui/src/pages/orgChart/components/OrgChartFullTree.tsx`
- [ ] T025 [UI] Create `OrgChartPage` at `/org-chart` — "My View" / "Full Org Chart" tabs toggling between sub-components; `?view=full` query param syncs tab — `source/cpr-ui/src/pages/orgChart/OrgChartPage.tsx`

### UI — i18n

- [ ] T026 [UI] Add `employees` and `orgChart` namespaces with all user-visible strings to English translation — `source/cpr-ui/public/locales/en/translation.json`
- [ ] T027 [UI] Mirror the same keys (English values as fallback) to `es` translation — `source/cpr-ui/public/locales/es/translation.json`
- [ ] T028 [UI] Mirror the same keys to `fr` translation — `source/cpr-ui/public/locales/fr/translation.json`
- [ ] T029 [UI] Mirror the same keys to `be` translation — `source/cpr-ui/public/locales/be/translation.json`

### UI — Routes

- [ ] T030 [UI] Add routes for `/employees`, `/employees/:id`, `/org-chart` to the route configuration — `source/cpr-ui/src/routes/index.tsx`

### Tests

- [ ] T031 [Test] Unit tests for `EmployeeDirectoryService` — profile fetch, org context, full tree; 404 on unknown id — `source/cpr-api/tests/CPR.UnitTests/Services/EmployeeDirectoryServiceTests.cs`
- [ ] T032 [Test] Integration tests for `GET /api/employees/{id}` — happy path, 404, 401 — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/EmployeeProfileControllerTests.cs`
- [ ] T033 [Test] Integration tests for `GET /api/org-chart/{employee_id}` and `GET /api/org-chart` — happy path, 401 — `source/cpr-api/tests/CPR.IntegrationTests/Controllers/OrgChartControllerTests.cs`
- [ ] T034 [Test] Unit tests for `EmployeeDirectoryPage` — renders list, name search filters, role filter, empty state, pagination — `source/cpr-ui/src/pages/employees/EmployeeDirectoryPage.test.tsx`
- [ ] T035 [Test] Unit tests for `EmployeeProfilePage` — renders profile fields, manager card link, direct reports, "View in org chart" nav — `source/cpr-ui/src/pages/employees/EmployeeProfilePage.test.tsx`
- [ ] T036 [Test] Unit tests for `OrgChartPage` — tab switching, my-view highlights self, full-tree expand/collapse, node click navigates — `source/cpr-ui/src/pages/orgChart/OrgChartPage.test.tsx`

---

## Rationale

**Migration first**: `T001` must execute before domain entity properties are mapped, because EF will validate column presence against the migration snapshot. Domain entities (`T002–T003`) are updated immediately after so downstream layers have the correct C# types to reference.

**Repository before service**: `IEmployeeDirectoryRepository` (`T004`) is defined in Domain so Application can reference it via interface without a concrete dependency; `T006` implements it in Infrastructure after DbContext (`T005`) is updated — this preserves Clean Architecture dependency direction.

**Single service, two controllers**: All data-access logic is centralised in `EmployeeDirectoryService` (`T008–T009`), with `EmployeesController` (`T010`) handling the `/employees/{id}` profile endpoint and a separate `OrgChartController` (`T011`) handling `/org-chart/*` — this keeps route namespaces clean and avoids bloating the existing `EmployeesController` which already owns search and gap-analysis.

**Directory page uses a mocked paged endpoint**: `GET /api/employees` (paginated directory listing) is owned by feature 0004 per the Analyze conflict resolution. `T017` mocks it in MSW so the `EmployeeDirectoryPage` (`T021`) can be built and tested against the agreed response shape without a backend implementation in this feature.

**i18n before routes**: Translation keys (`T026–T029`) are added before route registration (`T030`) so that pages never render with missing key warnings on first load; the four locale files are separate tasks to make the diff reviewable per locale.
