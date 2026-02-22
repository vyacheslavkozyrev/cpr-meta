# Implement Phase

Execute the tasks in plan.md in order to produce working code that satisfies the spec.

## Step 0 — Verify Gate

Read `cpr-meta/specifications/[####]-*/progress.md`.
Confirm **Plan** shows ✅ Complete.
If not, stop and notify the user: "Plan is not yet complete. Run `/plan [####]` first."

---

## Inputs
- Feature number `[####]`
- `plan.md` — ordered task list
- `stories.md` — acceptance criteria (reference while implementing)
- `api.md`, `schema.md`, `wireframes.md` — spec reference
- `cpr-meta/architecture.md`, `CLAUDE.md` — conventions

---

## Step 1 — Read Context

Read `plan.md`. Note which tasks are already checked off (resume from first unchecked).
Read `stories.md` acceptance criteria — these define what "done" means.
Read `cpr-meta/architecture.md` for architectural patterns to follow.

---

## Step 2 — Execute Tasks

For each unchecked task in plan.md, in order:

1. List the target file's parent directory and read 1–2 sibling files to understand
   the existing patterns, imports, and naming conventions used nearby.
2. Implement the task. Follow all conventions from `CLAUDE.md` exactly.
3. Mark the task as `[x]` in `plan.md` immediately after completing it.

**EF Core migrations**: For `[Migration]` tasks, write the migration class directly
(Up and Down methods) matching `schema.md` exactly. Do not run `dotnet ef migrations add` —
write the file by hand and place it in the Migrations folder.

**Unresolvable errors**: If a build error cannot be fixed (e.g., missing dependency,
environment issue), stop immediately. Document the blocker in the Implementation Notes
section of `progress.md` and notify the user before proceeding.

### Build checkpoints

Run the appropriate build after every 3–5 tasks or after completing a full layer:

```bash
# After backend tasks
dotnet build cpr-api

# After frontend tasks
yarn --cwd cpr-ui build
```

Fix all build errors before continuing to the next task.
Do not accumulate build errors across tasks.

### Quality while implementing

- Name everything exactly as specified in `api.md` and `schema.md`.
- Do not add fields, endpoints, or UI elements not in the spec.
- Do not create files not listed in `plan.md`. If you need a new file, add it to plan.md first.
- Each API endpoint must match `api.md` contract exactly (method, path, request, response).
- Each migration must match `schema.md` exactly (table names, columns, types, constraints).
- Auth/role checks must be present on every protected endpoint.

---

## Step 3 — Final Build Verification

After all tasks are complete, run both builds:

```bash
dotnet build cpr-api
yarn --cwd cpr-ui build
```

Both must exit with code 0. If either fails, fix the errors — do not mark Implement complete.

---

## Step 4 — Update progress.md

Mark Implement as ✅ Complete with today's date.
Append to the **Implementation Notes** section of `progress.md`:

```
### Implement — [YYYY-MM-DD]

**Tasks added during implementation**: [list any T-numbers added to plan.md, or "none"]
**Notes**: [anything notable — deviations from plan, deferred items, workarounds]
```

Inform the user they may proceed to `/review [####]`.
