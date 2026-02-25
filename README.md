# cpr-meta

Documentation, specifications, and SDD framework for the CPR project.

---

## Reference Documents

| File | Purpose |
|------|---------|
| `documents/idea.md` | Project concept and key design decisions |
| `documents/architecture.md` | System architecture, patterns, and technology stack |
| `documents/data.md` | Database schema reference |
| `documents/features.md` | Feature list and implementation status |
| `documents/personas.md` | User personas and role access levels |

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

Skills, agents, and settings live at the **repo root** (`source/`), shared across all three repos:

```
source/
├── CLAUDE.md                    # Claude Code context (standards, rules, build commands)
├── .mcp.json                    # MCP server definitions (project-scoped)
└── .claude/
    ├── skills/                  # Slash command entry points (invoke the prompts below)
    │   ├── specify/SKILL.md
    │   ├── analyze/SKILL.md
    │   ├── plan/SKILL.md
    │   ├── implement/SKILL.md
    │   ├── review/SKILL.md
    │   └── test/SKILL.md
    ├── agents/                  # Subagents delegated to by phase prompts
    │   ├── spec-reader.md       # Load and summarize spec docs (haiku)
    │   ├── codebase-scanner.md  # Scan backend/frontend patterns — optional (haiku)
    │   ├── conflict-detector.md # Detect cross-feature conflicts (sonnet)
    │   ├── build-validator.md   # Run builds, return pass/fail (haiku)
    │   └── test-runner.md       # Run tests, return structured results (haiku)
    └── settings.json            # Auto-approves all project MCP servers

cpr-meta/
└── framework/
    ├── workflow.md              # Phase reference
    ├── prompts/                 # Detailed phase instructions (read by skills)
    │   ├── specify.md
    │   ├── analyze.md
    │   ├── plan.md
    │   ├── implement.md
    │   ├── review.md
    │   └── test.md
    └── templates/               # Spec document templates
        ├── stories.md
        ├── wireframes.md
        ├── api.md
        ├── schema.md
        ├── plan.md
        └── progress.md
```

### MCP Servers

Project-level servers defined in `source/.mcp.json` (shared with team):

| Server | Package | Used in |
|--------|---------|---------|
| `git-meta` | `mcp-server-git` → cpr-meta repo | Plan, Implement, Review |
| `git-api` | `mcp-server-git` → cpr-api repo | Plan, Implement, Review |
| `git-ui` | `mcp-server-git` → cpr-ui repo | Plan, Implement, Review |
| `postgres` | `@modelcontextprotocol/server-postgres` | Plan (schema discovery), Review |
| `sequential-thinking` | `@modelcontextprotocol/server-sequential-thinking` | Analyze (conflict detection), Review (scoring) |

User-level server configured via `claude mcp add -s user` (token stored in `~/.claude.json`, not committed):

| Server | Package | Used in |
|--------|---------|---------|
| `github` | `@modelcontextprotocol/server-github` | Test (PR creation after PASS) |

**Setup for new contributors**: `mcp-server-git` requires Python — install with `pip install mcp-server-git`. Then add your GitHub token: `claude mcp add -s user -e GITHUB_PERSONAL_ACCESS_TOKEN=<token> -- npx -y @modelcontextprotocol/server-github`.

### Skills

Invoked as slash commands from Claude Code (run from `source/`):

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
├── registry.md                              # Compact feature registry (used by Analyze phase)
├── 0001-personal-goal-management/           # Complete
├── 0004-feedback-request-management/        # In Progress
├── 0005-feedback-submission-collection/     # In Progress
└── 0008-skills-taxonomy-career-framework/   # Plan ✅ — ready for /implement 0008
```

Each spec folder contains: `stories.md`, `wireframes.md`, `api.md` (if applicable), `schema.md` (if applicable), `plan.md`, `progress.md`.

---

## Related

- `../cpr-api/` — .NET 9 Web API backend
- `../cpr-ui/` — React 18 + TypeScript frontend
- `../CLAUDE.md` — Claude Code context (standards, rules, build commands)
