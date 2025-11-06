# CPR Meta Repository

**Single source of truth for specifications, documentation, and shared context across CPR project.**

## Overview

This repository contains:
- **Specifications** for features and bug fixes
- **Constitution** defining core principles and standards
- **Documentation** for processes and guidelines
- **Prompts** for AI-assisted development
- **Templates** for consistent documentation

## Repository Structure

```
cpr-meta/
├── constitution.md              # Core principles and standards
├── specs/                       # Feature specifications
│   ├── [spec-001]-feature-name/
│   │   ├── description.md       # Feature overview & acceptance criteria
│   │   ├── implementation-plan.md   # Technical approach & phases
│   │   ├── tasks.md             # Task breakdown
│   │   ├── endpoints.md         # API contracts (JSON format)
│   │   ├── analysis-report.md   # Quality analysis (≥90/100 to proceed)
│   │   └── progress.md          # Current status
│   └── ...
├── bugfixes/                    # Bug fix specifications
│   ├── [bug-001]-short-description/
│   │   ├── description.md
│   │   ├── endpoints.md
│   │   └── progress.md
│   └── ...
├── docs/                        # Process documentation
│   ├── specification-analysis-guide.md
│   └── specification-analysis-example.md
├── prompts/                     # AI prompt templates
│   └── specification-analysis.md
└── templates/                   # Document templates
    ├── spec-description-template.md
    ├── spec-implementation-plan-template.md
    ├── spec-tasks-template.md
    ├── spec-endpoints-template.md
    ├── spec-progress-template.md
    ├── spec-analysis-report-template.md
    └── bugfix-template.md
```

## Core Principles

The CPR project follows these foundational principles (see [constitution.md](constitution.md)):

1. **Specification-First Development**: All features begin with a specification
2. **API Contract Consistency**: DTOs and contracts must match across repos
3. **Type Safety Everywhere**: Strong typing prevents runtime errors
4. **Comprehensive Testing**: 80% minimum coverage with contract tests

## Quick Start

### Creating a New Feature Specification

1. **Create spec folder**:
   ```bash
   mkdir -p specs/[spec-001]-feature-name
   ```

2. **Create required files**:
   - `description.md` - Feature overview, user stories, acceptance criteria
   - `implementation-plan.md` - Technical approach, phases
   - `tasks.md` - Task breakdown
   - `endpoints.md` - API contracts (if applicable)
   - `progress.md` - Status tracking

3. **Run automated analysis**:
   - Use GitHub Copilot with `prompts/specification-analysis.md`
   - AI generates `analysis-report.md` with quality score
   - Must score ≥ 90/100 to proceed

4. **Fix issues if needed**:
   - Address all critical and major issues
   - Re-run analysis until ≥ 90/100

5. **Get approval**:
   - Tech lead reviews specification
   - Signs off in `analysis-report.md`
   - Marks as "Ready for Development" in `progress.md`

6. **Begin implementation**:
   - Reference spec in PRs to cpr-api or cpr-ui
   - Update `progress.md` as work progresses

### Standards at a Glance

| Aspect | Standard | Example |
|--------|----------|---------|
| **JSON Fields** | snake_case | `user_id`, `created_at` |
| **URL Paths** | kebab-case | `/api/v1/user-profiles` |
| **Query Params** | snake_case | `?page=1&per_page=20` |
| **C# Code** | PascalCase + `[JsonPropertyName]` | `UserId` → `"user_id"` |
| **TypeScript** | camelCase | `userId`, `createdAt` |
| **Dates** | ISO 8601 UTC | `2025-11-05T10:30:00Z` |
| **HTTP** | RESTful | GET, POST, PATCH, DELETE |

## Documentation

- **[Constitution](constitution.md)** - Complete principles and standards
- **[Specification Analysis Guide](docs/specification-analysis-guide.md)** - How to analyze specifications
- **[Specification Analysis Example](docs/specification-analysis-example.md)** - Real example walkthrough

## Templates

The `templates/` folder provides ready-to-use templates:

### Specification Templates
- **spec-description-template.md** - Feature description (user stories, requirements, business rules)
- **spec-implementation-plan-template.md** - Technical plan (architecture, API contracts, phases)
- **spec-tasks-template.md** - Task breakdown with dependencies and estimates
- **spec-endpoints-template.md** - API documentation (requests, responses, errors)
- **spec-progress-template.md** - Progress tracking (timeline, blockers, metrics)
- **spec-analysis-report-template.md** - Analysis report template (used by AI system)

### Bug Fix Template
- **bugfix-template.md** - Bug documentation (root cause, solution, prevention)

## Workflow Overview

```
1. Create Specification (use templates/)
   ↓
2. Analyze Specification (AI + Human Review)
   │ - Must score ≥ 90/100
   │ - Fix issues and re-analyze if needed
   ↓
3. Review & Approve
   │ - Tech lead approval
   ↓
4. Implementation (in cpr-api/cpr-ui)
   ↓
5. Testing
   ↓
6. Deployment
```

## Contributing

All changes to this repository should follow the principles defined in [constitution.md](constitution.md).

### Adding a Specification

1. Follow the folder structure: `specs/[spec-###]-short-description/`
2. Include all required files
3. Run automated analysis
4. Get approval before marking as ready for development

### Updating the Constitution

1. Create issue with label `constitution-amendment`
2. Discuss with team
3. Create PR with changes
4. Require approval from 2+ tech leads
5. Update version and last updated date
6. Communicate changes to all team members

## Related Repositories

- **[cpr-api](../cpr-api)** - Backend API (.NET 8, C#, PostgreSQL)
- **[cpr-ui](../cpr-ui)** - Frontend UI (React, TypeScript, Vite)

## Questions?

- Create issue in this repository for process questions
- Reference [constitution.md](constitution.md) for standards
- Use [specification-analysis-guide.md](docs/specification-analysis-guide.md) for analysis help

---

**Remember**: Specifications save time. A well-specified feature prevents days or weeks of rework.
