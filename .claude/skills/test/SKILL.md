---
description: Run the Test phase — write and run backend, frontend, and E2E tests covering every acceptance criterion; gate on full AC coverage and minimum 80% code coverage.
argument-hint: <feature-number>
---

You are executing the **Test** phase of the SDD framework.

Feature number: **$ARGUMENTS**

# Test Phase

Write and run tests that verify every acceptance criterion in stories.md.
Gate progression on full AC coverage, passing tests, and minimum code coverage.

## Step 0 — Verify Gate

Read `specifications/[####]-*/progress.md`.
Confirm **Review** shows ✅ Complete with score ≥ 80.
If not, stop and notify the user: "Review is not yet complete or did not pass. Run `/review [####]` first."

### Carry forward Review findings

Extract every item listed under **Blockers** and **Major** in the Review section of `progress.md`.
Build a **Review Findings List** — you will use this in Step 3 to add required tests for each finding.

Print the list before continuing:

```
Review Findings — required tests:
RF-001: [finding summary] → must verify [specific behaviour]
RF-002: [finding summary] → must verify [specific behaviour]
```

If a finding is purely a code-style or documentation issue with no observable runtime behaviour, mark it `(no test required)` and skip it. Auth, error-handling, and business-logic findings always require a test.

---

## Inputs
- Feature number `[####]`
- `stories.md` — acceptance criteria are the test requirements
- All implementation files from `plan.md`
- `api.md` — for integration test contract verification
- `wireframes.md` — for E2E user flow verification

---

## Step 1 — Map Acceptance Criteria to Tests

**Load spec documents** — if a `=== SPEC SUMMARY ===` block is already present in your context (injected by the pipeline orchestrator), use it as the AC source of truth and **skip the spec-reader call**. Otherwise, use the **`spec-reader`** agent, passing feature number `[####]`.
Use its AC list as the source of truth for the mapping below.

For each acceptance criterion, define at least one test and assign it a test ID.
Print the mapping before writing any code:

```
AC-001: [criterion text]
  → T-001: [test name] — describe("[AC-001] …") or [Fact(DisplayName = "AC-001: …")]

AC-002: [criterion text]
  → T-002: [test name] — describe("[AC-002] …") or [Fact(DisplayName = "AC-002: …")]
```

**AC identifier rule**: every test that covers an AC **must** include the AC identifier (`AC-NNN`) in its test name or description string. This is mandatory — `ac-coverage-checker` uses exact identifier matching, not name similarity.

Also map each Review Finding from Step 0:

```
RF-001: [finding summary]
  → T-0XX: [test name] — it("[RF-001] …")
```

---

## Step 2 — Verify MSW Handlers

Before writing any frontend tests, check that `cpr-ui/src/mocks/handlers/` contains a handler
for every API endpoint used by this feature.

For each missing handler: **stop and report a blocker** — do not write frontend tests for that
endpoint until the handler exists. Implement the missing handler directly in
`cpr-ui/src/mocks/handlers/`, then re-run `/test [####]`.

Verify each handler's response shape matches `api.md` exactly (field names, types, status codes).

---

## Step 3 — Write Tests in Parallel

Spawn two parallel test-writing sub-agents — one for backend (xUnit), one for frontend (Vitest). Each receives the relevant portion of the AC mapping from Step 1.

**How to split ACs between agents**:
- **Backend agent**: ACs about API behaviour, business logic, validation rules, auth enforcement.
- **Frontend agent**: ACs about UI rendering, user interactions, empty/error/loading states.
- An AC that touches both (e.g. a form submission that calls an API) gets tests in both agents.

---

### Backend Test Sub-Agent Prompt

```
Write xUnit tests for feature [####].

AC mapping (your targets — include ALL listed ACs):
[paste backend-relevant AC → test mappings from Step 1]

Review Findings requiring tests:
[paste RF items that involve API/business-logic from Step 0]

Spec files:
- specifications/[####]-*/stories.md
- specifications/[####]-*/api.md

Rules:
- Unit tests: services, domain logic, validators — mock repos with Moq.
- Integration tests: API endpoints via WebApplicationFactory.
  Verify request → response shape matches api.md (field names, types, status codes).
- Per-endpoint auth matrix for every endpoint in api.md:
    Unauthenticated → 401
    Each disallowed role → 403
    Each allowed role → 2xx / expected status
  Do not use a single generic auth test — every endpoint needs its own matrix.
- Every test name MUST include the AC identifier: [Fact(DisplayName = "AC-001: ...")]
- RF tests: directly exercise the failing behaviour and assert the correct outcome.
- File naming: [Entity]ServiceTests.cs, [Entity]ControllerTests.cs
- Location: follow existing pattern in cpr-api/tests/

Return: "Backend tests complete. Files created: [list of file paths]"
```

---

### Frontend Test Sub-Agent Prompt

```
Write Vitest + Testing Library tests for feature [####].

AC mapping (your targets — include ALL listed ACs):
[paste frontend-relevant AC → test mappings from Step 1]

Spec files:
- specifications/[####]-*/stories.md
- specifications/[####]-*/wireframes.md

Rules:
- Component tests: render components, simulate user interactions,
  assert output matches wireframes.md flows.
- Test empty states, error states, and loading states.
- Every describe/it string MUST include the AC identifier: describe("[AC-001] ...")
- File naming: [Component].test.tsx
- Location: follow existing pattern in cpr-ui/src/

Return: "Frontend tests complete. Files created: [list of file paths]"
```

---

After both sub-agents return, proceed to E2E.

### E2E (Playwright)

E2E tests are **required** whenever the feature includes any of the following:
- Role-gated pages or actions (different roles see different UI)
- Multi-step flows (e.g. request → approve/reject)
- Optimistic UI updates (state changes without page reload)
- Cross-role interactions (action by one role affects another role's view)

E2E may only be deferred when all MSW handlers for the feature are missing (a hard blocker).
Deferring E2E for convenience is not permitted.

E2E tests run against the MSW-backed mock environment (`yarn start:mock`).

- Cover the happy path for each user story end-to-end.
- Cover at least one error/edge-case path per story (e.g. validation failure, empty state).
- Use role-appropriate mock contexts (`start:mock`, `start:mock-manager`, `start:mock-admin`)
  to verify role-restricted flows behave correctly — each restricted flow must be tested from
  both an allowed role (expects success) and a disallowed role (expects redirect or blocked UI).

File naming: `[feature-name].spec.ts`
Location: follow existing pattern in `cpr-ui/e2e/`

---

## Step 4 — Run Tests

Use the **`test-runner`** agent with `model: haiku`. Run backend and frontend tests **in parallel**:
- Instance 1: `scope: backend`
- Instance 2: `scope: frontend`

Once both pass, run E2E separately:
- Instance 3: `scope: e2e`

Record the structured results returned by the agent.

**Coverage thresholds** (from `CLAUDE.md`):
- Overall: minimum 80%
- Authentication, validation, and business-rule paths: 100%

If coverage falls below threshold, identify the uncovered paths and add tests to cover them before proceeding.

---

## Step 5 — Verify AC Coverage

Use the **`ac-coverage-checker`** agent with `model: haiku`, passing the feature number.
Its output provides the authoritative AC → test mapping used to gate progression.

### Coverage rules

- **Explicit** coverage: the test name/description contains the exact AC identifier (e.g. `AC-009`). Always accepted.
- **Inferred** coverage: the agent matched by name similarity without finding the identifier. **Treat as Uncovered** — go back and add the AC identifier to the test name.
- **Uncovered**: no test found. Write a test before continuing.

Do not proceed to Step 6 until the agent returns `Result: PASS` with zero Inferred or Uncovered ACs.

Also verify that every Review Finding test from Step 3 is present and passing. If any RF test is missing or failing, resolve it before proceeding.

---

## Step 6 — Mark Covered ACs in stories.md

For each AC confirmed as covered by the `ac-coverage-checker` output, change its checkbox
in `stories.md` from `- [ ]` to `- [x]`. Leave uncovered or failing ACs as `- [ ]`.
This gives a visual completion record directly in the spec document.

---

## Step 7 — Update progress.md

Append to the **Test Results** section of `progress.md`:

```
### Test — [YYYY-MM-DD]

**AC Coverage**: [N]/[total] criteria covered (all explicit)
**Review Findings tested**: [N]/[total] findings covered
**Backend**: [pass]/[total] tests pass · coverage [N]%
**Frontend**: [pass]/[total] tests pass · coverage [N]%
**E2E**: [pass]/[total] tests pass  *(or: Deferred — reason)*
**Result**: PASS / BLOCKED

#### Failed Tests
- [TestName]: [failure reason]

#### Uncovered ACs
- AC-00N: [criterion] — [reason not covered]

#### Untested Review Findings
- RF-00N: [finding] — [reason not tested]

#### MSW Blockers
- [endpoint]: handler missing
```

Update the Test row in the Phase Status table: ✅ Complete (PASS) or ❌ Blocked.

Also update `specifications/registry.md`: change the feature's **Status** from `In Progress` to `Complete`.

---

## Gate

- **Any Inferred or Uncovered AC** → BLOCKED. "Inferred" is not passing.
- **Any untested Review Finding** (auth, error-handling, business-rule) → BLOCKED.
- **E2E skipped without a hard MSW blocker** → BLOCKED.
- **Any failing test, missing MSW handler, or coverage below threshold** → BLOCKED.
  List specifically which ACs are not covered, which RF tests are missing, which tests fail, and which handlers are missing.

- **All ACs explicitly covered, all RF tests pass, E2E passes, coverage meets thresholds** → PASS.
  Feature is complete.
