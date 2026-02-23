# Implement Phase

Execute the tasks in plan.md in order to produce working code that satisfies the spec.

## Step 0 — Verify Gate

Read `specifications/[####]-*/progress.md`.
Confirm **Plan** shows ✅ Complete.
If not, stop and notify the user: "Plan is not yet complete. Run `/plan [####]` first."

---

## Inputs
- Feature number `[####]`
- `plan.md` — ordered task list
- `stories.md` — acceptance criteria (reference while implementing)
- `api.md`, `schema.md`, `wireframes.md` — spec reference
- `documents/architecture.md`, `CLAUDE.md` — conventions

---

## Step 1 — Read Context

Read `plan.md`. Note which tasks are already checked off (resume from first unchecked).
Read `stories.md` acceptance criteria — these define what "done" means.
Read `documents/architecture.md` for architectural patterns to follow.

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

After every 3–5 tasks or after completing a full layer, use the **`build-validator`** agent:
- Pass `project: api` after backend tasks
- Pass `project: ui` after frontend tasks
- Pass `project: both` for a full checkpoint

Continue only if the agent reports PASS. Fix all listed errors before proceeding.
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

After all tasks are complete, use the **`build-validator`** agent with `project: both`.

Both must report PASS. If either fails, fix the errors — do not mark Implement complete.

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
