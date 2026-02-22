# cpr-meta

Documentation, specifications, and SDD framework for the CPR project.

---

## Reference Documents

| File | Purpose |
|------|---------|
| `idea.md` | Project concept and key design decisions |
| `architecture.md` | System architecture, patterns, and technology stack |
| `data.md` | Database schema reference |
| `features.md` | Feature list and implementation status |
| `personas.md` | User personas and role access levels |

---

## SDD Framework

Features are developed through the **Spec-Driven Development (SDD)** framework in `framework/`.

### Phases

| Phase | Command | Output | Gate |
|-------|---------|--------|------|
| Specify | `/specify [####]` | stories.md, wireframes.md, api.md?, schema.md? | Human approval |
| Analyze | `/analyze [####]` | Conflict report → progress.md | No critical conflicts |
| Plan | `/plan [####]` | plan.md | Human approval |
| Implement | `/implement [####]` | Code + progress.md | Build passes |
| Review | `/review [####]` | Review report → progress.md | Score ≥ 80 |
| Test | `/test [####]` | Test results → progress.md | All ACs pass; coverage thresholds met; E2E passes |

### Framework Structure

```
framework/
├── workflow.md          # Phase reference
├── prompts/             # Detailed phase instructions (read by skills)
│   ├── specify.md
│   ├── analyze.md
│   ├── plan.md
│   ├── implement.md
│   ├── review.md
│   └── test.md
└── templates/           # Spec document templates
    ├── stories.md
    ├── wireframes.md
    ├── api.md
    ├── schema.md
    ├── plan.md
    └── progress.md
```

### Skills

Invoked as slash commands from Claude Code (defined in `.claude/skills/`):

```
/specify 0008    # Run Specify phase for feature 0008
/analyze 0008    # Run Analyze phase
/plan 0008       # Run Plan phase
/implement 0008  # Run Implement phase
/review 0008     # Run Review phase
/test 0008       # Run Test phase
```

---

## Specifications

```
specifications/
├── registry.md              # Compact feature registry (used by Analyze phase)
├── 0001-personal-goals/     # Spec folder per feature
├── 0004-feedback-requests/
├── 0005-feedback-submission/
└── 0008-skills-taxonomy/
```

Each spec folder contains: `stories.md`, `wireframes.md`, `api.md` (if applicable), `schema.md` (if applicable), `plan.md`, `progress.md`.

---

## Related

- `cpr-api/` — .NET 8 Web API backend
- `cpr-ui/` — React 18 + TypeScript frontend
- `CLAUDE.md` — Claude Code context (standards, rules, build commands)
