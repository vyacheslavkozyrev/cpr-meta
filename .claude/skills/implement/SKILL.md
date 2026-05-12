---
description: Run the Implement phase — execute plan.md tasks in order to produce working code that satisfies the spec, with build checkpoints after each layer.
argument-hint: <feature-number>
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

## Step 2 — Split and Execute Tasks in Parallel

### Split the task list

From the unchecked tasks in `plan.md`, create two batches:

- **Backend batch**: tasks tagged `[Migration]`, `[Domain]`, `[Infra]`, `[App]`, `[API]`, or `[Config]`
- **UI batch**: tasks tagged `[UI]`

### Spawn execution sub-agents

- **If both batches are non-empty**: spawn them as **two parallel sub-agents** (see prompts below).
- **If only one batch is non-empty**: spawn one sub-agent with the appropriate prompt.

Backend and UI tasks operate on separate git repos (`source/cpr-api` and `source/cpr-ui`) — there are no commit conflicts when running in parallel.

**Sub-agents must not modify `plan.md`**. After both return, the orchestrator (this agent) marks all completed task IDs as `[x]` in `plan.md`. If a sub-agent reports an unresolvable blocker, document it in `progress.md` and halt.

---

### Backend Sub-Agent Prompt

Pass the following as the sub-agent's full prompt, filling in `[####]` and the task list:

```
You are implementing backend tasks for feature [####].

Spec files (read as needed):
- specifications/[####]-*/stories.md — acceptance criteria
- specifications/[####]-*/api.md — endpoint contracts
- specifications/[####]-*/schema.md — DB schema
- documents/architecture.md — architectural patterns
- CLAUDE.md — naming conventions

Task list (execute in order — these are your only tasks):
[paste backend task list here, one per line with original T-numbers]

For each task:
1. List the target directory; read 1–2 sibling files to understand existing patterns.
2. Implement the task following CLAUDE.md conventions exactly.
3. Commit: bash .claude/skills/implement/scripts/commit-task.sh [####] "<description>"

EF Core migrations: write the class directly (Up + Down). Do not run dotnet ef migrations add.

Build checkpoints: after every 3–5 tasks, run build-validator with project: api and model: haiku.
Fix all build errors before continuing. Do not accumulate errors.

Unresolvable errors: stop immediately and return a description of the blocker.

When done, return: "Backend complete. Finished: T001, T002, ..." listing all task IDs completed.
```

---

### UI Sub-Agent Prompt

```
You are implementing UI tasks for feature [####].

Spec files (read as needed):
- specifications/[####]-*/stories.md — acceptance criteria
- specifications/[####]-*/api.md — endpoint contracts (UI must call these exactly)
- specifications/[####]-*/wireframes.md — screen layouts and flows
- documents/architecture.md — architectural patterns
- CLAUDE.md — naming conventions

Task list (execute in order — these are your only tasks):
[paste UI task list here, one per line with original T-numbers]

For each task:
1. List the target directory; read 1–2 sibling files to understand existing patterns.
2. Implement the task following CLAUDE.md conventions exactly.
3. Commit: bash .claude/skills/implement/scripts/commit-task.sh [####] "<description>"

Build checkpoints: after every 3–5 tasks, run build-validator with project: ui and model: haiku.
Fix all build errors before continuing. Do not accumulate errors.

Unresolvable errors: stop immediately and return a description of the blocker.

When done, return: "UI complete. Finished: T031, T032, ..." listing all task IDs completed.
```

---

### After both sub-agents return

1. Mark all completed task IDs as `[x]` in `plan.md`.
2. If any sub-agent reported an unresolvable error: document it in `progress.md` and halt.

### Quality rules (enforced within each sub-agent)

- Name everything exactly as specified in `api.md` and `schema.md`.
- Do not add fields, endpoints, or UI elements not in the spec.
- Do not create files not listed in `plan.md`. If a new file is needed, halt and report it.
- Each API endpoint must match `api.md` contract exactly (method, path, request, response).
- Each migration must match `schema.md` exactly (table names, columns, types, constraints).
- Auth/role checks must be present on every protected endpoint.

---

## Step 3 — Final Build and Review

After all tasks are complete, run the following in sequence:

1. **`build-validator`** with `project: both` and `model: haiku` — both must report PASS.
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
