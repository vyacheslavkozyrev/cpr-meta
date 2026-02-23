# Plan Phase

Generate a file-level, ordered implementation task list from the approved spec documents.

## Step 0 — Verify Gate

Read `specifications/[####]-*/progress.md`.
Confirm **Analyze** shows ✅ Complete.
If not, stop and notify the user: "Analyze is not yet complete. Run `/analyze [####]` first."

---

## Inputs
- Feature number `[####]`
- `stories.md`, `wireframes.md`, `api.md` (if exists), `schema.md` (if exists)
- `documents/architecture.md` — existing patterns and conventions
- `CLAUDE.md` — naming conventions, build structure

---

## Step 1 — Read All Context

**Load spec documents** — use the **`spec-reader`** agent, passing feature number `[####]`.
Use its output as the spec context throughout this phase.

**Scan codebase patterns** — run the **`codebase-scanner`** agent twice **in parallel**:
- Instance 1: `layer: backend`
- Instance 2: `layer: frontend`

Also read `documents/architecture.md` and `documents/data.md` directly for architectural context and the
existing database schema (avoid re-creating tables or columns that already exist).

---

## Step 2 — Generate plan.md

Create `specifications/[####]-*/plan.md`.

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
