---
description: Run the Analyze phase — detect conflicts between a new feature spec and all existing features, then gate progression based on conflict severity.
argument-hint: <feature-number>
allowed-tools: Read, Write, Edit, Agent
---

You are executing the **Analyze** phase of the SDD framework.

Feature number: **$ARGUMENTS**

# Analyze Phase

Detect conflicts between the new feature spec and all existing features,
then gate progression based on conflict severity.

## Step 0 — Verify Gate

Read `cpr-meta/specifications/[####]-*/progress.md`.
Confirm **Specify** shows ✅ Complete.
If not, stop and notify the user: "Specify is not yet complete. Run `/specify [####]` first."

---

## Inputs
- Feature number `[####]`

---

## Steps 1–3 — Detect Conflicts

Delegate to the **`conflict-detector`** agent, passing feature number `[####]`.

The agent reads the registry, the new feature's specs, and all related feature specs,
then returns a structured conflict report. Use that report as input to Steps 4–5 below.

---

## Step 4 — Classify Findings

- **Critical** — Blocker. Must be resolved before Plan phase.
  Examples: exact duplicate API path, table name collision, directly contradictory business rule.

- **Major** — Needs a resolution note but can proceed with a documented decision.
  Examples: similar entity with different structure, partial overlap in user stories.

- **Minor** — Informational. Note for awareness, no action required.
  Examples: related feature that should be cross-linked, shared concept with different naming.

---

## Step 5 — Update progress.md

Append to the **Conflict Analysis** section of `progress.md`:

```
### Analyze — [YYYY-MM-DD]

**Result**: PASS / BLOCKED

| Severity | Finding | Affected Feature | Resolution |
|----------|---------|-----------------|------------|
| Critical | [description] | [####] | [required action] |
| Major    | [description] | [####] | [decision/note] |
| Minor    | [description] | [####] | — |
```

If no conflicts found, write: `No conflicts detected. Result: PASS.`

Update the Analyze row in the Phase Status table: ✅ Complete (PASS) or ❌ Blocked.

---

## Gate

- **BLOCKED**: one or more Critical conflicts exist.
  Do not proceed to Plan. Notify the user with specific resolution steps.

- **PASS**: zero Critical conflicts (Major/Minor are noted but not blocking).
  Inform the user they may proceed to `/plan [####]`.
