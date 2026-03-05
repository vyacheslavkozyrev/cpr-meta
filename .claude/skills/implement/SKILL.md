---
description: Run the Implement phase — execute plan.md tasks in order to produce working code that satisfies the spec, with build checkpoints after each layer.
argument-hint: <feature-number>
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
---

You are executing the **Implement** phase of the SDD framework.

Feature number: **$ARGUMENTS**

# Implement Phase

Execute the tasks in plan.md in order to produce working code that satisfies the spec.

## Step 0 — Verify Gate

Read `specifications/[####]-*/progress.md`.
Confirm **Plan** shows ✅ Complete.
If not, stop and notify the user: "Plan is not yet complete. Run `/plan [####]` first."

---

## Step 0.5 — Create Feature Branches

Run the branch creation script to ensure `feature/[####]-*` branches exist in both `cpr-api` and `cpr-ui`:

```bash
bash .claude/skills/implement/scripts/create-feature-branch.sh [####] <short-feature-name>
```

Derive `<short-feature-name>` from the specification folder name (the part after `[####]-`).

- If the branch already exists in a repo, the script checks it out instead of failing.
- Both repos must end up on the feature branch before continuing.

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

After every 3–5 tasks or after completing a full layer:

**1. Build** — use the **`build-validator`** agent:

- Pass `project: api` after backend tasks
- Pass `project: ui` after frontend tasks
- Pass `project: both` for a full checkpoint

If the build FAILs, fix all listed errors before continuing. Do not accumulate build errors across tasks.

**2. Code review** — once the build reports PASS, use the **`code-reviewer`** agent:

- Pass `base: develop` and `head: HEAD`
- Pass `scope: api`, `scope: ui`, or `scope: both` to match what was just built

The agent uses the following commands to produce the diff it reviews:

```bash
# Backend changes
git -C cpr-api diff develop..HEAD

# Frontend changes
git -C cpr-ui diff develop..HEAD
```

The agent will diff all changes introduced by this branch against `develop` and apply the full CPR review checklist.

**Blockers must be fixed before continuing to the next task batch.**
Warnings should be fixed within the current batch where practical; if not, note them in `progress.md` Implementation Notes — they will be caught again in the Review phase.
Do not proceed to the next task batch until the code-reviewer reports no Blockers.

### Quality while implementing

- Name everything exactly as specified in `api.md` and `schema.md`.
- Do not add fields, endpoints, or UI elements not in the spec.
- Do not create files not listed in `plan.md`. If you need a new file, add it to plan.md first.
- Each API endpoint must match `api.md` contract exactly (method, path, request, response).
- Each migration must match `schema.md` exactly (table names, columns, types, constraints).
- Auth/role checks must be present on every protected endpoint.

---

## Step 3 — Final Build and Review

After all tasks are complete, run the following in sequence:

1. **`build-validator`** with `project: both` — both must report PASS.
2. **`code-reviewer`** with `base: develop`, `head: HEAD`, `scope: both` — must report no Blockers.

```bash
git -C cpr-api diff develop..HEAD
git -C cpr-ui diff develop..HEAD
```

Fix any remaining build errors or Blocker findings before marking Implement complete. Warnings at this stage are noted in `progress.md` for the Review phase.

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
