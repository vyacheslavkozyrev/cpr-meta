# Specify Phase

Transform a free-text feature description into structured specification documents.

## Inputs
- Feature number `[####]` — provided by the user
- Feature description — free text from the user

---

## Step 1 — Locate or Create Spec Folder

Check `specifications/registry.md` to confirm `[####]` is not already registered
under a different feature name. If it is, stop and notify the user:
"Feature [####] already exists in the registry as '[Name]'. Use a different number or run `/analyze [####]` if this is an amendment."

Then check if `specifications/[####]-*/` exists.

- If it exists: read its current contents and note what's already there.
- If it doesn't exist: ask the user for a short kebab-case feature name
  (e.g. `job-applications`), then create `specifications/[####]-[name]/`.

---

## Step 2 — Ask Clarifying Questions

Read `documents/personas.md` to understand the available roles and their access levels before identifying gaps.

Read the feature description. Identify gaps across these areas:
- **Roles**: who performs each action? (refer to documents/personas.md for role definitions)
- **Scope**: what is explicitly out of scope?
- **Data**: what fields/attributes are needed?
- **API**: does this need new endpoints or modify existing ones?
- **DB**: does this require new tables or changes to existing ones?
- **UI**: what screens or interactions are needed?
- **Edge cases**: what happens with invalid input, empty states, concurrent edits?
- **Dependencies**: does this interact with existing features?

Ask **at most 10 questions in a single batch**. Number them Q1–Q10.
Ask only questions whose answers will materially change the spec documents.
Do not ask about implementation details or technology choices.

If the feature description already covers all areas above with sufficient detail,
skip the questions and proceed directly to Step 3 — note to the user that no
clarification was needed.

Otherwise, wait for the user to answer before proceeding to Step 3.

---

## Step 3 — Generate Spec Documents

Use templates from `framework/templates/` as the base structure.
Replace all placeholder text with feature-specific content.
Follow naming conventions from `CLAUDE.md` exactly:
snake_case for all JSON fields and DB columns, kebab-case for URL paths,
PascalCase for C# entity names, `I` prefix for TypeScript interfaces.

### stories.md (always required)

- Populate the **Out of Scope** section first: list everything mentioned or implied
  by the description that is intentionally excluded or deferred.
- Extract all user stories implied by the description + answers.
- Each story: role, action, benefit, 2–5 acceptance criteria.
- Acceptance criteria must be specific, testable, and unambiguous.
- Story numbering: US-001, US-002, … sequential across the feature.
- AC numbering: global across the entire feature (never reset per story).
  Example: US-001 gets AC-001–AC-003; US-002 continues at AC-004–AC-006.

### wireframes.md (always required)

- Create Mermaid diagrams for each significant screen or interaction flow.
- Every screen and flow described in stories.md must have a corresponding wireframe section — verify coverage before finalising this document.
- Use `flowchart TD` for screen layouts and navigation.
- Use `sequenceDiagram` for multi-step interactions (e.g. form submit → API → response).
- Add notes for non-obvious interactions, empty states, and error states.

### api.md (if feature adds or modifies API endpoints)

- One section per endpoint.
- Include: HTTP method, path, auth requirement, role, request body,
  success response with status code, error response table.
- For every request body, include a **Validation Rules** table specifying
  which fields are required and their constraints (length, format, range, enum values).
- All JSON fields must use snake_case.
- Paths must use kebab-case: `/api/resource-name`.

### schema.md (if feature adds or modifies DB tables)

- List new tables with all columns, types, nullability, defaults, constraints, indexes.
- List modifications to existing tables (added/removed/changed columns).
- Include SQL for migration up and rollback.
- All table and column names must use snake_case.

---

## Step 4 — Initialize progress.md

If `progress.md` does not yet exist, create it using the template,
set Specify to ✅ Complete with today's date, and leave all other phases as ⏳ Pending.

If `progress.md` already exists (amendment scenario), do not overwrite it —
update only the Specify row date and add an entry to the Amendments section.

---

## Step 5 — Propose Registry Entry

Print (do not write yet) the proposed entry for `specifications/registry.md`:

```
## [####] — [Feature Name]
**Status**: In Progress
**Summary**: [1–2 sentences describing what this feature does and for whom]
**Key entities**: [comma-separated entity/model names]
**API endpoints**: [METHOD /api/path, ...] or "none"
**DB tables**: [table names] or "none"
```

Ask the user to confirm. On confirmation, append the entry to `specifications/registry.md`.
