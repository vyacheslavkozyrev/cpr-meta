# CPR Project — Claude Code Context

CPR (Continuous Performance Review) is a performance management platform with a .NET 9 backend and React 18 frontend.
Features are developed through the SDD (Spec-Driven Development) framework defined in `framework/`.

## Repository Structure

```
source/
├── cpr-meta/                  # Framework, specs, governance (you are here)
│   ├── CLAUDE.md              # This file
│   ├── documents/
│   ├── .claude/               # Claude Code skills
│   │   └── skills/            # Slash command entry points
│   ├── framework/             # SDD framework
│   │   ├── workflow.md        # Phase reference
│   │   ├── prompts/           # Phase prompts (specify, analyze, plan, implement, review, test)
│   │   └── templates/         # stories.md, wireframes.md, api.md, schema.md, plan.md, progress.md
│   └── specifications/
│       ├── registry.md        # Feature registry (used by Analyze phase)
│       └── [####]-<feature-name>/
├── cpr-api/                   # .NET 8 Web API (backend)
└── cpr-ui/                    # React 18 + TypeScript (frontend)
```

## SDD Framework

| Phase | Command | Key Output | Gate |
|-------|---------|------------|------|
| Specify | `/specify [####]` | stories.md, wireframes.md, api.md?, schema.md? | Human approval |
| Analyze | `/analyze [####]` | Conflict report → progress.md | No critical conflicts |
| Plan | `/plan [####]` | plan.md | Human approval |
| Implement | `/implement [####]` | Code + updated progress.md | Build passes |
| Review | `/review [####]` | Review report → progress.md | Score ≥ 80 |
| Test | `/test [####]` | Test results → progress.md | All ACs covered |

Phase prompts: `framework/prompts/`
Skills: `.claude/skills/` (invoked as `/specify [####]`, `/analyze [####]`, etc.)

## SDD Framework Rules

- **Before implementing**: verify `progress.md` shows Analyze ✅ and Plan ✅.
- **Always read** `stories.md` acceptance criteria before writing any implementation code.
- **Always update** `progress.md` when completing each phase.
- **Implement in order**: work through `plan.md` tasks sequentially; check off each task immediately after completing it.
- **Never skip quality gates**: Analyze (no critical conflicts), Implement (build passes), Review (≥ 80), Test (all ACs covered and passing).
- **Registry**: always append to `registry.md` after Specify. Always read `registry.md` at the start of Analyze.
- **Spec folder**: all spec documents for a feature live in `specifications/[####]-feature-name/`.

## Naming Conventions

| Context | Convention | Example |
|---------|-----------|---------|
| JSON / API fields | snake_case | `user_id`, `created_at` |
| C# properties | PascalCase + `[JsonPropertyName]` | `UserId` → `"user_id"` |
| TypeScript interfaces | `I` prefix + PascalCase | `IUserProfile`, `IGoal` |
| TypeScript type aliases | `T` prefix + PascalCase | `TApiResponse<T>`, `TUser` |
| TypeScript enums | `E` prefix + PascalCase | `EUserRole`, `EGoalStatus` |
| TypeScript (code) | camelCase; snake_case in API types | `userId` / `user_id` |
| Event handlers | `handle[Action]` / `on[Action]` | `handleSubmit`, `onDelete` |
| Database tables/columns | snake_case | `user_profiles`, `created_at` |
| URL paths | kebab-case | `/api/user-profiles` |
| Component files | PascalCase | `GoalCard.tsx`, `LoginForm.tsx` |
| Service/utility files | camelCase | `goalService.ts`, `userMapper.ts` |

## TypeScript Standards

- **Strict mode**: `strict: true`, `noImplicitAny: true`, `strictNullChecks: true` — no `any` type; use `unknown` with type guards.
- **API types**: snake_case field names matching the JSON wire format exactly.

## C# Standards

- **Nullable refs**: `<Nullable>enable</Nullable>` — treat nullable warnings as errors.
- **JSON serialization**: always annotate C# properties with `[JsonPropertyName("snake_case")]`.

## API Standards

- **Error format**: RFC 7807 ProblemDetails — `{ type, title, status, detail }`.
- **Dates**: ISO 8601 UTC with Z suffix — `"2025-11-05T10:30:00Z"`.
- **Query params**: snake_case — `?page=1&per_page=20&sort_by=created_at`.
- **Pagination**: default page size 20, max 100.
- **All inputs validated server-side** — never rely on client-side validation alone.

## Database Standards

- **Primary keys**: UUID only — never auto-increment.
- **Audit columns** (required on every table): `created_by`, `created_at`, `modified_by`, `modified_at`, `is_deleted`, `deleted_by`, `deleted_at`.
- **Soft delete only** — set `is_deleted = true`; never hard-delete user data.
- **Indexes**: on all foreign keys and filtered/sorted columns; partial indexes use `WHERE is_deleted = FALSE`.
- **Migrations**: Entity Framework with Up/Down methods; always run `dotnet ef database update`.

## React Standards

- **No inline handlers**: wrap all event handlers in `useCallback` with correct deps.
- **No inline styles**: create style objects with `useMemo` or a factory; never `sx={{ ... }}` inline.
- **Expensive computations**: wrap in `useMemo`.
- **Frequent re-renders**: wrap component in `React.memo`.

## Offline Mode (MSW)

- Every API endpoint must have a corresponding mock handler in `../cpr-ui/src/mocks/handlers/`.
- Mock responses must match `api.md` exactly (request/response shapes, status codes, errors).
- Use `yarn start:mock` for offline development; `yarn test` automatically uses MSW mocks.

## Internationalization

- No hardcoded UI text — all strings via `t('namespace.key')` translation keys.
- Supported locales: `en`, `es`, `fr`, `be`.
- Dates/numbers formatted with locale-aware APIs (`toLocaleDateString()`, `Intl.NumberFormat()`).
- API error messages return localization keys, not hardcoded text.

## Security & RBAC

- **Roles**: `Employee`, `PeopleManager`, `SolutionOwner`, `Director`, `Administrator`.
- Enforce via `[Authorize(Policy = "...")]` on all protected endpoints.
- Never log PII (emails, phone numbers) — redact or hash for correlation IDs.
- Audit trail: log all data access with `user_id`, `action`, `resource_type`, `resource_id`, `timestamp`.
- Secrets via Azure Key Vault only — never commit secrets or `.env` files.

## Testing Standards

- Minimum **80% code coverage**; authentication, validation, and business-rule paths require **100%**.
- Test pyramid: ~60% unit, ~30% integration, ~10% E2E.
- Frontend tests must pass without a running backend (use MSW mocks).

## Build Commands

**Backend (../cpr-api)**
```bash
dotnet build ../cpr-api
dotnet test ../cpr-api
dotnet ef database update --project ../cpr-api
```

**Frontend (../cpr-ui)** — package manager: yarn
```bash
yarn --cwd ../cpr-ui install

# Dev server modes
yarn --cwd ../cpr-ui start:local          # local API
yarn --cwd ../cpr-ui start:mock           # mock data, employee role
yarn --cwd ../cpr-ui start:mock-manager   # mock data, manager role
yarn --cwd ../cpr-ui start:mock-admin     # mock data, admin role

# Build
yarn --cwd ../cpr-ui build

# Test
yarn --cwd ../cpr-ui test                 # unit tests (vitest)
yarn --cwd ../cpr-ui test:coverage        # with coverage report
yarn --cwd ../cpr-ui test:e2e             # e2e tests (playwright)

# Lint / format
yarn --cwd ../cpr-ui lint
yarn --cwd ../cpr-ui format
```

## Key Docs

- `documents/architecture.md` — system design and patterns
- `documents/data.md` — database schema reference
- `documents/features.md` — feature list and implementation status
- `framework/workflow.md` — SDD phase reference
- `specifications/registry.md` — feature registry
