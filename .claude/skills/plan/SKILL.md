---
description: Run the Plan phase — generate a file-level ordered implementation task list from the approved spec documents.
argument-hint: <feature-number>
---

You are executing the **Plan** phase of the SDD framework.

Feature number: **$ARGUMENTS**

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

**Read conventions and architecture** directly:
- `CLAUDE.md` — naming conventions, layer structure, build commands
- `documents/architecture.md` — architectural patterns
- `documents/data.md` — existing DB schema (avoid re-creating tables or columns that already exist)

> If you need concrete code examples for a specific entity (e.g. to verify an unusual pattern),
> you may optionally run the **`codebase-scanner`** agent with `layer: backend` or `layer: frontend`
> and a `focus` value. This is not required when conventions are clear from the documents above.

**If `schema.md` exists for this feature**, run both agents in parallel before generating the task list:

- **`db-inspector`** — pass the table names defined in `schema.md` as `tables`. Its output reveals the current live DB state (existing columns, FKs, indexes). Use this to avoid re-creating things that already exist and to confirm what the migration must add.
- **`migration-inspector`** — pass the primary entity name as `focus`. Its output shows any pending migrations already in the codebase and recent changes to the entity. Use this to avoid duplicating migration work.

If either agent reveals pending migrations or an already-existing schema that conflicts with `schema.md`, note this in the `## Rationale` section and adjust the `[Migration]` tasks accordingly.

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
