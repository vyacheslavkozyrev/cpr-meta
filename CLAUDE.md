# cpr-meta — Framework & Specifications Context

Governance, SDD framework, and feature specifications for CPR.
See root `CLAUDE.md` for project-wide naming conventions, RBAC rules, and testing standards.

## Repository Structure

```
cpr-meta/
├── CLAUDE.md                    # This file — complete framework reference
├── .mcp.json                    # MCP server definitions (project-scoped)
├── .claude/
│   ├── skills/                  # Slash command entry points
│   │   ├── specify/SKILL.md
│   │   ├── analyze/SKILL.md
│   │   ├── plan/SKILL.md
│   │   ├── implement/SKILL.md
│   │   ├── review/SKILL.md
│   │   └── test/SKILL.md
│   ├── agents/                  # Subagents delegated to by phase prompts
│   │   ├── spec-reader.md
│   │   ├── codebase-scanner.md
│   │   ├── conflict-detector.md
│   │   ├── build-validator.md
│   │   └── test-runner.md
│   └── settings.json
├── documents/
│   ├── idea.md                  # Project concept and key design decisions
│   ├── architecture.md          # System design and patterns
│   ├── data.md                  # Database schema reference
│   ├── features.md              # Feature list and implementation status
│   └── personas.md              # User personas and role access levels
├── templates/                   # Spec document templates
│   ├── stories.md
│   ├── wireframes.md
│   ├── api.md
│   ├── schema.md
│   ├── plan.md
│   └── progress.md
└── specifications/
    ├── registry.md              # Compact feature registry (used by Analyze phase)
    └── [####]-[feature-name]/
        ├── stories.md
        ├── wireframes.md
        ├── api.md               # If feature adds/modifies API endpoints
        ├── schema.md            # If feature adds/modifies DB tables
        ├── plan.md
        └── progress.md
```

## Key Docs

- `documents/architecture.md` — system design and patterns
- `documents/data.md` — database schema reference
- `documents/features.md` — feature list and implementation status
- `documents/personas.md` — user personas and role access levels
- `specifications/registry.md` — feature registry

## MCP Servers

Project-level servers defined in `.mcp.json`:

| Server | Package | Used in |
|--------|---------|---------|
| `git-meta` | `mcp-server-git` → cpr-meta repo | Plan, Implement, Review |
| `git-api` | `mcp-server-git` → cpr-api repo | Plan, Implement, Review |
| `git-ui` | `mcp-server-git` → cpr-ui repo | Plan, Implement, Review |
| `postgres` | `@modelcontextprotocol/server-postgres` | Plan (schema discovery), Review |
| `sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` | Analyze (conflict detection), Review (scoring) |

User-level server (token stored in `~/.claude.json`, not committed):

| Server | Package | Used in |
|--------|---------|---------|
| `github` | `@modelcontextprotocol/server-github` | Test (PR creation after PASS) |

**Setup for new contributors**: `pip install mcp-server-git`, then:
`claude mcp add -s user -e GITHUB_PERSONAL_ACCESS_TOKEN=<token> -- npx -y @modelcontextprotocol/server-github`

---

## SDD Phases

| # | Phase | Command | Driver | Gate |
|---|-------|---------|--------|------|
| 1 | Specify | `/specify [####]` | Human + AI | Human approves all docs |
| 2 | Analyze | `/analyze [####]` | AI | No critical conflicts |
| 3 | Plan | `/plan [####]` | AI + Human | Human approves plan.md |
| 4 | Implement | `/implement [####]` | AI | Build passes |
| 5 | Review | `/review [####]` | AI | Score ≥ 80 |
| 6 | Test | `/test [####]` | AI | All ACs pass; coverage thresholds met; E2E passes |

## SDD Rules

- **Before implementing**: verify `progress.md` shows Analyze ✅ and Plan ✅.
- **Always read** `stories.md` acceptance criteria before writing any implementation code.
- **Always update** `progress.md` when completing each phase.
- **Implement in order**: work through `plan.md` tasks sequentially; check off each task immediately after completing it.
- **Never skip quality gates**: Analyze (no critical conflicts), Implement (build passes), Review (≥ 80), Test (all ACs covered and passing).
- **Registry**: always append to `specifications/registry.md` after Specify. Always read it at the start of Analyze.

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

## Spec Documents

| File | Required | Created in Phase |
|------|----------|-----------------|
| `stories.md` | Always | Specify |
| `wireframes.md` | Always | Specify |
| `api.md` | If API changes | Specify |
| `schema.md` | If DB changes | Specify |
| `plan.md` | Always | Plan |
| `progress.md` | Always | Specify |

Templates are in `templates/`. Spec folders: `specifications/[####]-[kebab-case-feature-name]/`.

- Feature number: 4-digit zero-padded integer, sequential.
- Folder name: `[####]-[kebab-case-feature-name]`.

## Feature Registry

`specifications/registry.md` — one compact entry per feature.

- Written at the end of Specify (after human confirms).
- Read at the start of Analyze to detect cross-feature conflicts.
- Updated when a feature status changes (e.g. In Progress → Complete).

## Skills

Skills live in `.claude/skills/` and are invoked as `/skill-name [####]` from `cpr-meta/`.

| Command | Phase |
|---------|-------|
| `/specify [####]` | Specify |
| `/analyze [####]` | Analyze |
| `/plan [####]` | Plan |
| `/implement [####]` | Implement |
| `/review [####]` | Review |
| `/test [####]` | Test |
| `/pipeline [####]` | All phases (Analyze → Test) in sequence |
