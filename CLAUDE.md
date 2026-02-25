# cpr-meta — Framework & Specifications Context

Governance, SDD framework, and feature specifications. See root `CLAUDE.md` for SDD rules.

## Structure

```
cpr-meta/
├── documents/
│   ├── architecture.md    # System design and patterns
│   ├── data.md            # Database schema reference
│   └── features.md        # Feature list and implementation status
├── framework/
│   ├── workflow.md        # SDD phase reference
│   ├── prompts/           # Phase prompts (specify, analyze, plan, implement, review, test)
│   └── templates/         # stories.md, wireframes.md, api.md, schema.md, plan.md, progress.md
└── specifications/
    ├── registry.md        # Feature registry (read at Analyze, append after Specify)
    └── [####]-<feature-name>/
        ├── stories.md
        ├── wireframes.md
        ├── api.md
        ├── schema.md
        ├── plan.md
        └── progress.md
```

## Key Docs

- `documents/architecture.md` — system design and patterns
- `documents/data.md` — database schema reference
- `documents/features.md` — feature list and implementation status
- `framework/workflow.md` — SDD phase reference
- `specifications/registry.md` — feature registry

## Spec Folder Convention

All spec documents for a feature live in `specifications/[####]-feature-name/`.
Phase prompts are in `framework/prompts/` and are invoked via `.claude/skills/`.
