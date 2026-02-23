# SDD Framework — Workflow Reference

Spec-Driven Development: a free-text feature description flows through 6 phases to
produce working, tested code. Specs live in `specifications/[####]-feature-name/`.

---

## Phases

| # | Phase | Command | Driver | Gate |
|---|-------|---------|--------|------|
| 1 | Specify | `/specify [####]` | Human + AI | Human approves all docs |
| 2 | Analyze | `/analyze [####]` | AI | No critical conflicts |
| 3 | Plan | `/plan [####]` | AI + Human | Human approves plan.md |
| 4 | Implement | `/implement [####]` | AI | Build passes |
| 5 | Review | `/review [####]` | AI | Score ≥ 80 |
| 6 | Test | `/test [####]` | AI | All ACs pass; coverage thresholds met; E2E passes |

---

## Spec Documents

| File | Required | Created in Phase |
|------|----------|-----------------|
| `stories.md` | Always | Specify |
| `wireframes.md` | Always | Specify |
| `api.md` | If API changes | Specify |
| `schema.md` | If DB changes | Specify |
| `plan.md` | Always | Plan |
| `progress.md` | Always | Specify |

Templates: `framework/templates/`

---

## Quality Gates

| Phase | Condition to proceed |
|-------|---------------------|
| Specify | Human reviews and approves all generated docs |
| Analyze | Zero critical conflicts. Major conflicts need a resolution note. |
| Plan | Human reviews task list and approves ordering |
| Implement | `dotnet build cpr-api` and `yarn --cwd cpr-ui build` both exit 0 |
| Review | Score ≥ 80/100. All Blockers resolved before Test. |
| Test | Every AC covered by ≥ 1 passing test; coverage thresholds met; all E2E tests pass |

---

## Feature Registry

`specifications/registry.md` — one compact entry per feature.

- Written at the end of Specify (after human confirms).
- Read at the start of Analyze to detect cross-feature conflicts.
- Updated when a feature status changes (e.g. In Progress → Complete).

---

## Folder Convention

```
specifications/
├── registry.md
├── 0001-personal-goal-management/
│   ├── stories.md
│   ├── wireframes.md
│   ├── api.md
│   ├── schema.md
│   ├── plan.md
│   └── progress.md
└── [####]-[kebab-case-name]/
    └── ...
```

Feature number: 4-digit zero-padded integer, sequential.
Folder name: `[####]-[kebab-case-feature-name]`.

---

## Amending a Spec

### Before implementation starts (after Plan, before Implement)

1. Edit the relevant spec documents (`stories.md`, `api.md`, `schema.md`, `wireframes.md`).
2. Re-run `/analyze [####]` to check for new conflicts introduced by the change.
3. Update `plan.md` — add, remove, or reorder tasks as needed.
4. Add an amendment note with date to `progress.md` explaining what changed and why.

Do not skip the re-analyze step; a spec change can introduce conflicts that weren't present before.

### After implementation starts (during or after Implement)

1. Add new or changed stories to `stories.md`. Update `api.md` / `schema.md` / `wireframes.md` as needed.
2. Add delta tasks to `plan.md` for any new files or changes required.
3. Re-run `/implement [####]` — it will resume from the first unchecked task.
4. Re-run `/review [####]` and `/test [####]` to re-validate the full feature.
5. Add an amendment note with date to `progress.md` explaining what changed and why.

---

## Skills Reference

Skills live in `.claude/skills/` and are invoked as `/skill-name [####]`.
Each skill reads its detailed prompt from `framework/prompts/`.

| Skill file | Prompt file |
|------------|-------------|
| `.claude/skills/specify/SKILL.md` | `framework/prompts/specify.md` |
| `.claude/skills/analyze/SKILL.md` | `framework/prompts/analyze.md` |
| `.claude/skills/plan/SKILL.md` | `framework/prompts/plan.md` |
| `.claude/skills/implement/SKILL.md` | `framework/prompts/implement.md` |
| `.claude/skills/review/SKILL.md` | `framework/prompts/review.md` |
| `.claude/skills/test/SKILL.md` | `framework/prompts/test.md` |
