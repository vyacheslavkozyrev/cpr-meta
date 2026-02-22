# Test Phase

Write and run tests that verify every acceptance criterion in stories.md.
Gate progression on full AC coverage, passing tests, and minimum code coverage.

## Step 0 — Verify Gate

Read `cpr-meta/specifications/[####]-*/progress.md`.
Confirm **Review** shows ✅ Complete with score ≥ 80.
If not, stop and notify the user: "Review is not yet complete or did not pass. Run `/review [####]` first."

---

## Inputs
- Feature number `[####]`
- `stories.md` — acceptance criteria are the test requirements
- All implementation files from `plan.md`
- `api.md` — for integration test contract verification
- `wireframes.md` — for E2E user flow verification

---

## Step 1 — Map Acceptance Criteria to Tests

For each acceptance criterion in stories.md, define at least one test.
Print the mapping before writing any code:

```
AC-001: [criterion text]
  → T-001: [test name and what it verifies]

AC-002: [criterion text]
  → T-002: [test name and what it verifies]
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

## Step 3 — Write Tests

### Backend (xUnit)

- **Unit tests**: services, domain logic, validators.
  Mock repository dependencies with an in-memory substitute or Moq.
- **Integration tests**: API endpoints using `WebApplicationFactory`.
  Verify request → response matches `api.md` contracts.
  Test auth (401 when unauthenticated, 403 when wrong role).

File naming: `[Entity]ServiceTests.cs`, `[Entity]ControllerTests.cs`
Location: follow existing pattern in `cpr-api/tests/`

### Frontend (Vitest + Testing Library)

- **Component tests**: render components, simulate user interactions,
  assert expected output matches wireframes.md flows.
- Test empty states, error states, and loading states where applicable.

File naming: `[Component].test.tsx`
Location: follow existing pattern in `cpr-ui/src/`

### E2E (Playwright)

Write E2E tests for every significant user flow described in `wireframes.md`.
E2E tests run against the MSW-backed mock environment (`yarn start:mock`).

- Cover the happy path for each user story end-to-end.
- Cover at least one error/edge-case path per story (e.g. validation failure, empty state).
- Use role-appropriate mock contexts (`start:mock`, `start:mock-manager`, `start:mock-admin`)
  to verify role-restricted flows behave correctly.

File naming: `[feature-name].spec.ts`
Location: follow existing pattern in `cpr-ui/e2e/`

---

## Step 4 — Run Tests

```bash
# Backend
dotnet test cpr-api --collect:"XPlat Code Coverage"

# Frontend unit + component
yarn --cwd cpr-ui test:coverage

# E2E
yarn --cwd cpr-ui test:e2e
```

Record the result of each test run (pass/fail, coverage %). Note any failures with the error message.

**Coverage thresholds** (from `CLAUDE.md`):
- Overall: minimum 80%
- Authentication, validation, and business-rule paths: 100%

If coverage falls below threshold, identify the uncovered paths and add tests to cover them before proceeding.

---

## Step 5 — Mark Covered ACs in stories.md

For each AC that is fully covered by passing tests, change its checkbox in `stories.md`
from `- [ ]` to `- [x]`. Leave uncovered or failing ACs as `- [ ]`.
This gives a visual completion record directly in the spec document.

---

## Step 6 — Update progress.md

Append to the **Test Results** section of `progress.md`:

```
### Test — [YYYY-MM-DD]

**AC Coverage**: [N]/[total] criteria covered
**Backend**: [pass]/[total] tests pass · coverage [N]%
**Frontend**: [pass]/[total] tests pass · coverage [N]%
**E2E**: [pass]/[total] tests pass
**Result**: PASS / BLOCKED

#### Failed Tests
- [TestName]: [failure reason]

#### Uncovered ACs
- AC-00N: [criterion] — [reason not covered]

#### MSW Blockers
- [endpoint]: handler missing
```

Update the Test row in the Phase Status table: ✅ Complete (PASS) or ❌ Blocked.

Also update `registry.md`: change the feature's **Status** from `In Progress` to `Complete`.

---

## Gate

- **Any uncovered AC, failing test, missing MSW handler, or coverage below threshold** → BLOCKED.
  List specifically which ACs are not covered, which tests fail, and which handlers are missing.

- **All ACs covered, all tests pass, coverage meets thresholds** → PASS.
  Feature is complete.
