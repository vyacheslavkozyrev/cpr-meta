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
- New feature's spec docs: `stories.md`, `api.md` (if exists), `schema.md` (if exists)
- `cpr-meta/specifications/registry.md`

---

## Step 1 — Read Context

1. Read `cpr-meta/specifications/registry.md` — compact overview of all features.
2. Read the new feature's `stories.md`, `api.md`, `schema.md` from its spec folder.

---

## Step 2 — Flag Potentially Conflicting Features

Exclude feature `[####]` itself from the comparison — only analyze other features.
From the remaining registry entries, identify features that share any of the following with the new feature:
- Same or similar entity/model names
- Overlapping API path prefixes
- Same DB tables
- Same business domain or user role actions

For each flagged feature, read its full spec files (stories.md, api.md, schema.md).
Skip features with **Status: Not Started** — their spec files do not exist yet and
cannot be compared; note them as informational in the findings.

---

## Step 3 — Analyze for Conflicts

Check each flagged feature against the new spec:

| Category | What to look for |
|----------|-----------------|
| **Naming** | Same entity or table name with different meaning or structure |
| **Data model** | Duplicate columns, conflicting FK references, overlapping table responsibilities |
| **API** | Duplicate paths, same endpoint with different request/response contract |
| **Business logic** | Contradictory rules, duplicate user stories, overlapping acceptance criteria |
| **Scope** | New feature duplicates functionality already implemented |

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
