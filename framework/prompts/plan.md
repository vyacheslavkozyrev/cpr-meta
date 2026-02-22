# Plan Phase

Generate a file-level, ordered implementation task list from the approved spec documents.

## Step 0 — Verify Gate

Read `cpr-meta/specifications/[####]-*/progress.md`.
Confirm **Analyze** shows ✅ Complete.
If not, stop and notify the user: "Analyze is not yet complete. Run `/analyze [####]` first."

---

## Inputs
- Feature number `[####]`
- `stories.md`, `wireframes.md`, `api.md` (if exists), `schema.md` (if exists)
- `cpr-meta/architecture.md` — existing patterns and conventions
- `CLAUDE.md` — naming conventions, build structure

---

## Step 1 — Read All Context

Read all spec documents for this feature.
Read `cpr-meta/architecture.md` to understand existing patterns:
repository layer, service layer, controller conventions, frontend structure.
Read `cpr-meta/data.md` to understand the existing database schema — avoid re-creating
tables or columns that already exist, and ensure FK references target correct tables.

Also scan the relevant parts of the codebase to understand current patterns:
- `cpr-api/src/CPR.Api/Controllers/` — existing controller structure and base classes
- `cpr-api/src/CPR.Application/Services/` — existing service patterns
- `cpr-api/src/CPR.Domain/Repositories/` — existing repository interfaces
- `cpr-ui/src/pages/` — existing page structure
- `cpr-ui/src/hooks/` — existing React Query hook patterns
- `cpr-ui/src/mocks/handlers/` — existing MSW handler style

---

## Step 2 — Generate plan.md

Create `cpr-meta/specifications/[####]-*/plan.md`.

### Task format

```
- [ ] T001 [Layer] Short imperative description — `relative/path/to/TargetFile.cs`
```

Rules:
- Each task targets exactly one file. Split multi-file work into separate tasks.
- Description is imperative: "Create", "Add", "Implement", "Register", "Update".
- File path is relative to the repo root.
- Layer tag is one of: `[Migration]` `[Domain]` `[Infra]` `[App]` `[API]` `[UI]` `[Test]` `[Config]`

### Ordering rules

Apply this sequence strictly:
1. `[Migration]` — DB migrations first (schema must exist before entities reference it)
2. `[Domain]` — entities, value objects, domain interfaces
3. `[Infra]` — repositories, EF configurations, DI registrations
4. `[App]` — DTOs, services, validators, mappings
5. `[API]` — controllers, route registration, middleware
6. `[Config]` — app configuration, environment settings, constants, feature flags
7. `[UI]` — types, API clients, hooks, MSW mock handlers, components, pages, i18n translation keys, route registration (in that order)
8. `[Test]` — test files last

Within each layer, order by dependency (things that other things depend on come first).

---

## Step 3 — Add Rationale

After the task list, add a `## Rationale` section (3–5 sentences) explaining
the key ordering decisions and any non-obvious dependencies between tasks.

---

## Step 4 — Update progress.md

Mark Plan as ✅ Complete with today's date.
Inform the user to review `plan.md` and confirm before running `/implement [####]`.
