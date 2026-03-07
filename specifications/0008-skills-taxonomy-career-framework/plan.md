# Implementation Plan — Skills Taxonomy & Career Framework (0008)

> **Note on existing entities**: The database tables for this feature already exist (created in migration `20250910193406_CreateDatabaseSchema`) and are seeded via `DatabaseSeeder.cs`. Domain entity classes likely already exist in the codebase (used by the seeder and the `employees.position_id` FK). Before implementing any `[Domain]` task below, check whether the entity file already exists and only add missing navigation properties rather than recreating the class from scratch.

---

## Task List

### Migration

> No new DB migration required — all tables (`career_paths`, `career_tracks`, `positions`, `skill_categories`, `skills`, `skill_levels`, `position_to_skill`) already exist in the deployed schema.

---

### Domain

- [x] T001 [Domain] Add/verify `CareerPath` entity with `Tracks` navigation collection — `cpr-api/src/CPR.Domain/Entities/CareerPath.cs`
- [x] T002 [Domain] Add/verify `CareerTrack` entity with `CareerPath` and `Positions` navigations — `cpr-api/src/CPR.Domain/Entities/CareerTrack.cs`
- [x] T003 [Domain] Add/verify `Position` entity with `CareerTrack` and `PositionSkills` navigations — `cpr-api/src/CPR.Domain/Entities/Position.cs`
- [x] T004 [Domain] Add/verify `SkillCategory` entity with `Skills` navigation collection — `cpr-api/src/CPR.Domain/Entities/SkillCategory.cs`
- [x] T005 [Domain] Add/verify `Skill` entity with `SkillCategory` and `Levels` navigations — `cpr-api/src/CPR.Domain/Entities/Skill.cs`
- [x] T006 [Domain] Add/verify `SkillLevel` entity with `Skill` navigation — `cpr-api/src/CPR.Domain/Entities/SkillLevel.cs`
- [x] T007 [Domain] Add/verify `PositionToSkill` entity with `Position`, `Skill`, and `SkillLevel` navigations — `cpr-api/src/CPR.Domain/Entities/PositionToSkill.cs`
- [x] T008 [Domain] Create `ITaxonomyRepository` interface (write operations: Add, Update, SoftDelete for all taxonomy entities) — `cpr-api/src/CPR.Domain/Repositories/ITaxonomyRepository.cs`
- [x] T009 [Domain] Create `ITaxonomyService` interface (all read + write operations matching api.md) — `cpr-api/src/CPR.Application/Services/ITaxonomyService.cs`

---

### Infrastructure

- [x] T010 [Infra] Update `CprDbContext` — add `DbSet<T>` declarations and `OnModelCreating` mappings for `CareerPath`, `CareerTrack`, `Position` (column names, FKs, navigation properties, soft-delete indexes) — `cpr-api/src/CPR.Infrastructure/Data/CprDbContext.cs`
- [x] T011 [Infra] Update `CprDbContext` — add `OnModelCreating` mappings for `SkillCategory`, `Skill`, `SkillLevel`, `PositionToSkill` (column names, unique index on `position_id + skill_id`, FKs, soft-delete filters) — `cpr-api/src/CPR.Infrastructure/Data/CprDbContext.cs`
- [x] T012 [Infra] Implement `TaxonomyRepository` — CRUD methods for all taxonomy entity writes using `CprDbContext`; set audit columns (`CreatedBy`, `CreatedAt`, `ModifiedBy`, `ModifiedAt`) on every operation — `cpr-api/src/CPR.Infrastructure/Data/Repositories/TaxonomyRepository.cs`
- [x] T013 [Infra] Implement `TaxonomyService` — all read queries (paginated lists, detail with includes, soft-delete filters) and all admin write operations; validate cross-entity references (e.g. active career path exists before creating track) — `cpr-api/src/CPR.Infrastructure/Services/TaxonomyService.cs`

---

### Application

- [x] T014 [App] Create `CareerPathDtos` — `CareerPathSummaryDto`, `CareerPathDetailDto` (with tracks), `CreateCareerPathDto`, `UpdateCareerPathDto`; decorate with `[JsonPropertyName]` — `cpr-api/src/CPR.Application/DTOs/Taxonomy/CareerPathDtos.cs`
- [x] T015 [App] Create `CareerTrackDtos` — `CareerTrackSummaryDto`, `CareerTrackDetailDto` (with positions), `CreateCareerTrackDto`, `UpdateCareerTrackDto` — `cpr-api/src/CPR.Application/DTOs/Taxonomy/CareerTrackDtos.cs`
- [x] T016 [App] Create `PositionDtos` — `PositionSummaryDto`, `PositionDetailDto` (with `skills` array), `CreatePositionDto`, `UpdatePositionDto` — `cpr-api/src/CPR.Application/DTOs/Taxonomy/PositionDtos.cs`
- [x] T017 [App] Create `SkillCategoryDtos` — `SkillCategoryDto`, `CreateSkillCategoryDto`, `UpdateSkillCategoryDto` — `cpr-api/src/CPR.Application/DTOs/Taxonomy/SkillDtos.cs` (co-located)
- [x] T018 [App] Create `SkillDtos` — `SkillSummaryDto`, `SkillDetailDto` (with `levels`), `SkillLevelSummaryDto`, `CreateSkillDto` (with optional `levels` array), `UpdateSkillDto`, `AddSkillLevelDto`, `UpdateSkillLevelDto` — `cpr-api/src/CPR.Application/DTOs/Taxonomy/SkillDtos.cs`
- [x] T019 [App] Create `PositionSkillDtos` — `PositionSkillRequirementDto`, `AddPositionSkillDto`, `UpdatePositionSkillDto` — `cpr-api/src/CPR.Application/DTOs/Taxonomy/PositionDtos.cs` (co-located)
- [x] T020 [App] Create `CareerPathDtoValidator` — FluentValidation for `CreateCareerPathDto` (title 1–200, unique) and `UpdateCareerPathDto` — `cpr-api/src/CPR.Application/Validators/Taxonomy/CareerPathDtoValidator.cs`
- [x] T021 [App] Create `CareerTrackDtoValidator` — FluentValidation for `CreateCareerTrackDto` (title 1–200, career_path_id required + active) and `UpdateCareerTrackDto` — `cpr-api/src/CPR.Application/Validators/Taxonomy/CareerTrackDtoValidator.cs`
- [x] T022 [App] Create `PositionDtoValidator` — FluentValidation for `CreatePositionDto` (title 1–200, description/expectations max 2000, career_track_id required + active) and `UpdatePositionDto` — `cpr-api/src/CPR.Application/Validators/Taxonomy/PositionDtoValidator.cs`
- [x] T023 [App] Create `SkillCategoryDtoValidator` — FluentValidation for `CreateSkillCategoryDto` (title 1–200, unique case-insensitive) and `UpdateSkillCategoryDto` — `cpr-api/src/CPR.Application/Validators/Taxonomy/SkillCategoryDtoValidator.cs`
- [x] T024 [App] Create `SkillDtoValidator` — FluentValidation for `CreateSkillDto` (title 1–200, category_id required + active, levels[].value unique 1–5, levels[].title 1–100), `UpdateSkillDto`, `AddSkillLevelDto`, `UpdateSkillLevelDto` — `cpr-api/src/CPR.Application/Validators/Taxonomy/SkillDtoValidator.cs`
- [x] T025 [App] Create `PositionSkillDtoValidator` — FluentValidation for `AddPositionSkillDto` (skill_id required + active, skill_level_id required + belongs to skill, weight > 0, rationale max 500) and `UpdatePositionSkillDto` — `cpr-api/src/CPR.Application/Validators/Taxonomy/PositionSkillDtoValidator.cs`

---

### API

- [x] T026 [API] Create `TaxonomyCareerPathsController` — `[Route("api/taxonomy/career-paths")]`; `GET` list (paginated, all authenticated); `GET {id}` (with tracks, all authenticated); `POST` create (Administrator); `PATCH {id}` update (Administrator) — `cpr-api/src/CPR.Api/Controllers/TaxonomyCareerPathsController.cs`
- [x] T027 [API] Create `TaxonomyCareerTracksController` — `[Route("api/taxonomy/career-tracks")]`; `GET` list with `career_path_id` filter (all authenticated); `GET {id}` (with positions, all authenticated); `POST` create (Administrator); `PATCH {id}` update (Administrator) — `cpr-api/src/CPR.Api/Controllers/TaxonomyCareerTracksController.cs`
- [x] T028 [API] Create `TaxonomyPositionsController` — `[Route("api/taxonomy/positions")]`; `GET {id}` (with active skills, all authenticated); `POST` create (Administrator); `PATCH {id}` update (Administrator); `POST {id}/skills` add skill requirement (Administrator); `PATCH {id}/skills/{positionSkillId}` update (Administrator); `DELETE {id}/skills/{positionSkillId}` soft-delete (Administrator) — `cpr-api/src/CPR.Api/Controllers/TaxonomyPositionsController.cs`
- [x] T029 [API] Create `TaxonomySkillCategoriesController` — `[Route("api/taxonomy/skill-categories")]`; `GET` list paginated (all authenticated); `POST` create (Administrator); `PATCH {id}` update (Administrator) — `cpr-api/src/CPR.Api/Controllers/TaxonomySkillCategoriesController.cs`
- [x] T030 [API] Create `TaxonomySkillsController` — `[Route("api/taxonomy/skills")]`; `GET` list with `category_id` filter (all authenticated); `GET {id}` with levels (all authenticated); `POST` create with optional levels (Administrator); `PATCH {id}` update (Administrator); `DELETE {id}` soft-delete (Administrator); `POST {id}/levels` add level (Administrator); `PATCH {id}/levels/{levelId}` update level (Administrator) — `cpr-api/src/CPR.Api/Controllers/TaxonomySkillsController.cs`
- [x] T031 [API] Register `ITaxonomyRepository → TaxonomyRepository` and `ITaxonomyService → TaxonomyService` in `InfrastructureRegistrar.AddInfrastructure()` — `cpr-api/src/CPR.Api/InfrastructureRegistrar.cs`

---

### UI — Types & Services

- [x] T032 [UI] Create TypeScript types file — `ICareerPathSummary`, `ICareerPathDetail`, `ICareerTrackSummary`, `ICareerTrackDetail`, `IPositionSummary`, `IPositionDetail`, `ISkillSummary`, `ISkillDetail`, `ISkillLevelSummary`, `IPositionSkillRequirement`, `ISkillCategory`; all admin request interfaces (`ICreateCareerPathDto`, etc.); snake_case field names throughout — `cpr-ui/src/types/taxonomy.types.ts`
- [x] T033 [UI] Create `taxonomyService.ts` — `TaxonomyApiService` class with methods for all 24 API endpoints using `apiClient`; export singleton `taxonomyApiService` — `cpr-ui/src/services/taxonomyService.ts`
- [x] T034 [UI] Create `taxonomyQueryService.ts` — React Query hooks: `useCareerPaths`, `useCareerPath`, `useCareerTracks`, `useCareerTrack`, `usePosition`, `useSkillCategories`, `useSkills`, `useSkill`; admin mutations: `useCreateCareerPath`, `useUpdateCareerPath`, `useCreateCareerTrack`, `useUpdateCareerTrack`, `useCreatePosition`, `useUpdatePosition`, `useCreateSkillCategory`, `useUpdateSkillCategory`, `useCreateSkill`, `useUpdateSkill`, `useDeleteSkill`, `useAddSkillLevel`, `useUpdateSkillLevel`, `useAddPositionSkill`, `useUpdatePositionSkill`, `useDeletePositionSkill` — `cpr-ui/src/services/taxonomyQueryService.ts`

---

### UI — MSW Mocks

- [x] T035 [UI] Create taxonomy mock data fixtures — mock career paths, tracks, positions, skill categories, skills (with levels), position-to-skill mappings; consistent UUIDs; seeded rich enough to render a radar chart — `cpr-ui/src/mocks/data/taxonomyMockData.ts`
- [x] T036 [UI] Create MSW handlers for taxonomy read endpoints — `GET */api/taxonomy/career-paths`, `GET */api/taxonomy/career-paths/:id`, `GET */api/taxonomy/career-tracks`, `GET */api/taxonomy/career-tracks/:id`, `GET */api/taxonomy/positions/:id`, `GET */api/taxonomy/skill-categories`, `GET */api/taxonomy/skills`, `GET */api/taxonomy/skills/:id` — `cpr-ui/src/mocks/handlers/taxonomyHandlers.ts`
- [x] T037 [UI] Add MSW handlers for taxonomy admin write endpoints to the same handler file — all `POST`, `PATCH`, `DELETE` endpoints for career paths, tracks, positions, skill categories, skills, skill levels, and position skills; include validation error responses for key cases (duplicate title, skill_already_assigned, skill_deleted) — `cpr-ui/src/mocks/handlers/taxonomyHandlers.ts`
- [x] T038 [UI] Register `taxonomyHandlers` in the MSW handler index — spread `...taxonomyHandlers` into `allHandlers` — `cpr-ui/src/mocks/handlers/index.ts`

---

### UI — Read Components

- [x] T039 [UI] Create `CareerPathCard` — MUI Card showing path title and description; clickable with arrow icon; skeleton variant for loading state — `cpr-ui/src/components/taxonomy/CareerPathCard.tsx`
- [x] T040 [UI] Create `CareerTrackCard` — MUI Card showing track title and description; clickable with arrow icon — `cpr-ui/src/components/taxonomy/CareerTrackCard.tsx`
- [x] T041 [UI] Create `PositionCard` — MUI Card showing position title, description (2-line truncated), and expectations excerpt; accordion expand for full expectations; clickable — `cpr-ui/src/components/taxonomy/PositionCard.tsx`
- [x] T042 [UI] Create `ProgressionLadder` — vertical stepper/timeline layout rendering `PositionCard` items ordered top-to-bottom (senior to junior); connector arrows between cards; empty state — `cpr-ui/src/components/taxonomy/ProgressionLadder.tsx`
- [x] T043 [UI] Create `SkillRadarChart` — radar/spider chart using Recharts `RadarChart`; axes = skills grouped by category (distinct colour per category); axis value = `skill_level_value` (1–5); solid line = mandatory, dashed = optional; legend; degrades to `BarChart` when fewer than 3 skills — `cpr-ui/src/components/taxonomy/SkillRadarChart.tsx`
- [x] T044 [UI] Create `SkillRequirementsTable` — MUI `Table` with columns: Category, Skill (clickable to open side panel), Required Level, Mandatory (chip), Weight, Rationale; client-side sortable by column header — `cpr-ui/src/components/taxonomy/SkillRequirementsTable.tsx`
- [x] T045 [UI] Create `SkillDetailPanel` — MUI `Drawer` (right side); shows skill title, category badge, description, proficiency levels list (value + title + description) sorted 1–5; highlights the required level passed as prop; close button — `cpr-ui/src/components/taxonomy/SkillDetailPanel.tsx`

---

### UI — Admin Components

- [x] T046 [UI] Create `TaxonomyAdminTabs` — MUI `Tabs` container with five tabs: Career Paths, Career Tracks, Positions, Skill Categories, Skills; lazy-loads each tab panel; only rendered for Administrator role — `cpr-ui/src/components/taxonomy/admin/TaxonomyAdminTabs.tsx`
- [x] T047 [UI] Create `CareerPathForm` — React Hook Form + Zod modal form for create/edit career path; fields: Title (required), Description; displays inline validation errors (title_duplicate, title_required) — `cpr-ui/src/components/taxonomy/admin/CareerPathForm.tsx`
- [x] T048 [UI] Create `CareerTrackForm` — React Hook Form + Zod modal for create/edit career track; fields: Title (required), Description, Career Path dropdown (required, lists active paths) — `cpr-ui/src/components/taxonomy/admin/CareerTrackForm.tsx`
- [x] T049 [UI] Create `PositionForm` — React Hook Form + Zod modal for create/edit position; fields: Title (required), Description, Expectations, Career Track dropdown (required, lists active tracks) — `cpr-ui/src/components/taxonomy/admin/PositionForm.tsx`
- [x] T050 [UI] Create `SkillCategoryForm` — React Hook Form + Zod modal for create/edit skill category; fields: Title (required), Description — `cpr-ui/src/components/taxonomy/admin/SkillCategoryForm.tsx`
- [x] T051 [UI] Create `SkillForm` — React Hook Form + Zod modal for create/edit skill; fields: Title (required), Description, Category dropdown (required); dynamic proficiency levels section (add/remove rows: value 1–5, title, description); inline per-level validation — `cpr-ui/src/components/taxonomy/admin/SkillForm.tsx`
- [x] T052 [UI] Create `SkillLevelsSubPanel` — side panel listing a skill's proficiency levels with inline edit rows (value badge, title, description, save/cancel); "+ Add Level" button adds new row; validates value uniqueness 1–5 — `cpr-ui/src/components/taxonomy/admin/SkillLevelsSubPanel.tsx`
- [x] T053 [UI] Create `PositionSkillsPanel` — side panel for managing a position's skill requirements; lists current requirements with inline edit (skill level, mandatory, weight, rationale) and soft-delete per row; "+ Add Skill Requirement" form row with Skill dropdown (active only) and dynamic Level dropdown; skill itself is immutable after creation — `cpr-ui/src/components/taxonomy/admin/PositionSkillsPanel.tsx`

---

### UI — Pages

- [x] T054 [UI] Create `CareerFrameworkPage` — route `/career-framework`; fetches `useCareerPaths`; renders grid of `CareerPathCard`; loading skeleton (3 cards), empty state, error state; shows "+ Add Career Path" button for Administrator role (opens `CareerPathForm` modal) — `cpr-ui/src/pages/taxonomy/CareerFrameworkPage.tsx`
- [x] T055 [UI] Create `CareerPathDetailPage` — route `/career-framework/:pathId`; breadcrumb; fetches `useCareerPath`; renders path title, description, and list of `CareerTrackCard`; loading/empty/error states; Administrator: Edit button + "+ Add Track" button — `cpr-ui/src/pages/taxonomy/CareerPathDetailPage.tsx`
- [x] T056 [UI] Create `CareerTrackDetailPage` — route `/career-framework/:pathId/tracks/:trackId`; breadcrumb; fetches `useCareerTrack`; renders track title, description, and `ProgressionLadder` of positions; loading/empty/error states; Administrator: "+ Add Position" button — `cpr-ui/src/pages/taxonomy/CareerTrackDetailPage.tsx`
- [x] T057 [UI] Create `PositionDetailPage` — route `/career-framework/:pathId/tracks/:trackId/positions/:positionId`; breadcrumb; fetches `usePosition`; renders position title, description, expectations; `SkillRadarChart` + `SkillRequirementsTable`; `SkillDetailPanel` drawer on skill click; loading/empty/error states; Administrator: Edit button + Manage Skills button (opens `PositionSkillsPanel`) — `cpr-ui/src/pages/taxonomy/PositionDetailPage.tsx`

---

### UI — i18n & Routes

- [x] T058 [UI] Add taxonomy i18n keys to English translation file — keys under `pages.careerFramework.*`, `pages.careerPath.*`, `pages.careerTrack.*`, `pages.position.*`, `components.taxonomy.*`, `admin.taxonomy.*`; include all button labels, headings, empty states, error messages, success toasts, confirmation dialog text — `cpr-ui/public/locales/en/translation.json`
- [x] T059 [UI] Register taxonomy routes in the router — nest `/career-framework`, `/career-framework/:pathId`, `/career-framework/:pathId/tracks/:trackId`, `/career-framework/:pathId/tracks/:trackId/positions/:positionId` under the authenticated `AppLayout` parent; add `/settings/career-framework` route for `TaxonomyAdminTabs` wrapped in `<RoleGuard allowedRoles={[UserRole.ADMINISTRATOR]}>` — `cpr-ui/src/routes/index.tsx`

---

### Tests

- [x] T060 [Test] Unit tests for `TaxonomyService` — test all read methods (empty results, soft-delete filtering, cross-entity joins); test all admin write methods (happy path, duplicate title rejection, deleted-entity reference rejection, skill_level_mismatch) — `cpr-api/tests/CPR.UnitTests/Services/TaxonomyServiceTests.cs`
- [x] T061 [Test] Unit tests for all taxonomy validators — `CareerPathDtoValidator`, `CareerTrackDtoValidator`, `PositionDtoValidator`, `SkillCategoryDtoValidator`, `SkillDtoValidator`, `PositionSkillDtoValidator`; test required fields, length constraints, uniqueness rules, range checks — `cpr-api/tests/CPR.UnitTests/Validators/TaxonomyValidatorTests.cs`
- [x] T062 [Test] Integration tests for taxonomy read endpoints — all `GET /api/taxonomy/*` endpoints; assert 200 shape, 401 without auth, correct soft-delete filtering, pagination envelope — `cpr-api/tests/CPR.IntegrationTests/Controllers/TaxonomyReadEndpointsTests.cs`
- [x] T063 [Test] Integration tests for taxonomy admin write endpoints — all `POST`, `PATCH`, `DELETE` endpoints; assert 201/200/204 on success, 403 for non-admin roles, 400 for validation errors (duplicate, deleted reference, level mismatch), 404 for missing resources — `cpr-api/tests/CPR.IntegrationTests/Controllers/TaxonomyAdminEndpointsTests.cs`
- [x] T064 [Test] Frontend tests for `CareerFrameworkPage` and `CareerPathDetailPage` — render with MSW mocks; assert card rendering, navigation on click, empty/error/loading states, admin button visibility based on role — `cpr-ui/src/__tests__/pages/taxonomy/CareerFrameworkPage.test.tsx`
- [x] T065 [Test] Frontend tests for `PositionDetailPage` — render with position including skills; assert radar chart renders, skill table columns, skill detail panel opens on click, admin buttons visible only for Administrator — `cpr-ui/src/__tests__/pages/taxonomy/PositionDetailPage.test.tsx`
- [x] T066 [Test] Frontend unit tests for `SkillRadarChart` — renders correct number of axes, mandatory vs optional styling, bar chart fallback for < 3 skills, empty state — `cpr-ui/src/__tests__/components/taxonomy/SkillRadarChart.test.tsx`

---

## Rationale

All DB tables exist in the current schema, so no migration tasks are needed; the plan opens with domain entity verification rather than migration to avoid redundant work. Domain entities must be complete before EF Core configurations reference their navigation properties (T001–T007 → T010–T011), and `CprDbContext` must be updated before the repository and service can compile (T010–T011 → T012–T013). DTOs are defined before validators to give validators concrete types to reference, and validators are registered before controllers so FluentValidation auto-validation fires on controller action parameters. On the frontend, types and the API service client must exist before the React Query hooks can import them (T032–T033 → T034), and mock data must be seeded before MSW handlers reference it (T035 → T036–T037). Reusable leaf components (`CareerPathCard`, `SkillRadarChart`, etc.) are built before the composing page components that consume them, ensuring all imports resolve at compile time. i18n keys and route registration are final UI tasks because they depend on knowing the exact page component exports and the string surface area of all completed components.
