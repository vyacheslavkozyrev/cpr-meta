# Review Phase

Review all code produced during Implement against the spec, architecture, and conventions.
Produce a scored report and gate progression at ≥ 80/100.

## Step 0 — Verify Gate

Read `specifications/[####]-*/progress.md`.
Confirm **Implement** shows ✅ Complete.
If not, stop and notify the user: "Implement is not yet complete. Run `/implement [####]` first."

---

## Inputs
- Feature number `[####]`
- All files listed in `plan.md` (every `[x]` task's target file)
- `stories.md`, `api.md`, `schema.md`, `wireframes.md`
- `documents/architecture.md`, `CLAUDE.md`

---

## Step 1 — Read All Context

**Load spec documents** — use the **`spec-reader`** agent, passing feature number `[####]`.
Its output provides the comparison baseline (stories/ACs, API contracts, schema, wireframe flows).

Read every file targeted by a completed task in `plan.md` directly.
Also read any files modified as a side effect (e.g. DI registration files, route configs).

---

## Step 2 — Score Against Review Categories

| Category | Points | What to check |
|----------|--------|--------------|
| **Spec compliance** | 30 | Does code implement all stories.md ACs? Do endpoints match api.md exactly? Does schema match schema.md? |
| **Architecture** | 25 | Correct layer separation, repository pattern, service pattern, no logic leaking across layers |
| **Naming conventions** | 15 | snake_case for DB/JSON, PascalCase for C#, camelCase for TS, kebab-case for URL paths; no hardcoded UI strings (all text via `t()` i18n keys) |
| **Security** | 15 | Auth/role checks on protected endpoints, no injection risks, no secrets in code |
| **Code quality** | 15 | No dead code, no over-engineering, no TODO/FIXME left, no unnecessary abstractions |

Score each category out of its maximum using this scale:
- **Full**: all criteria in that category are fully met → full points
- **Partial**: some criteria met → prorate using the rules below
- **Zero**: category entirely unaddressed or critically broken

**Proration rules:**
- **Spec compliance (30)**: `(ACs implemented / total ACs) × 30`. Also deduct proportionally for endpoint contract mismatches and schema deviations.
- **Architecture (25)**: count the number of layer violations (logic leaking across layers, bypassed repository, service called from wrong layer). Each violation deducts 5 points; minimum 0.
- **Naming conventions (15)**: count naming errors (wrong case, missing `[JsonPropertyName]`, hardcoded UI string). Each error deducts 2 points; minimum 0.
- **Security (15)**: `(endpoints_with_correct_auth / total_protected_endpoints) × 15`. Any SQL injection or secret-in-code finding scores 0 for this category regardless.
- **Code quality (15)**: deduct 3 points per TODO/FIXME left in code, dead code block, or unnecessary abstraction; minimum 0.

Sum for total out of 100.

---

## Step 3 — List Findings by Severity

For each issue found:

- **Blocker** — must fix before Test phase (spec mismatch, missing auth, broken contract)
- **Major** — should fix but does not block (architecture violation, naming error)
- **Minor** — optional improvement (style, readability)

Format each finding as: `` `path/to/File.cs:42` — [description] — [suggested fix] ``
Use the file's path relative to the repo root (e.g. `cpr-api/src/.../GoalService.cs:42`
or `cpr-ui/src/components/GoalCard/GoalCard.tsx:17`).

---

## Step 4 — Update progress.md

Write the following to the **Review** section of `progress.md`
(replace any previous review content if this is a re-run):

```
### Review — [YYYY-MM-DD]

**Score**: [N]/100
**Result**: PASS (≥80) / BLOCKED (<80)

#### Blockers
- `file:line` — description

#### Major
- `file:line` — description

#### Minor
- `file:line` — description
```

Update the Review row in the Phase Status table: ✅ Complete (PASS) or ❌ Blocked.

---

## Gate

- **Score < 80 or any Blockers** → BLOCKED.
  List all Blockers clearly. User must fix them and re-run `/review [####]`.

- **Score ≥ 80 and no Blockers** → PASS.
  Inform the user they may proceed to `/test [####]`.
  Note any Major/Minor findings for optional cleanup.

---

## Re-runs

On each re-run, rescore **all categories from scratch**. The prior score is informational only.
