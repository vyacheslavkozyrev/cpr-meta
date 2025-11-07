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
├── architecture.md              # System architecture decisions
├── data.md                      # Data models and database design
├── features-list.md             # Current feature scope
├── personas.md                  # User personas
├── project-idea.md              # Original project concept
├── framework/                   # CPR custom development framework
│   ├── README.md                # Framework documentation
│   ├── tools/                   # Analysis and validation scripts
│   │   ├── analyze-spec.ps1     # Specification analysis tool
│   │   └── check-prerequisites.ps1
│   ├── templates/               # Specification templates
│   │   ├── spec-description-template.md
│   │   ├── spec-implementation-plan-template.md
│   │   ├── spec-tasks-template.md
│   │   ├── spec-endpoints-template.md
│   │   ├── spec-progress-template.md
│   │   ├── spec-analysis-report-template.md
│   │   └── bugfix-template.md
│   └── workflows/               # Development process definitions
│       └── specification-analysis-process.md
├── specifications/              # Feature specifications by lifecycle
│   ├── README.md                # Specification management guide
│   ├── active/                  # Currently implemented features
│   ├── proposed/                # Features planned for future
│   └── archived/                # Completed/deprecated features
├── analysis/                    # Framework analysis output
│   ├── README.md                # Analysis output documentation
│   ├── compliance-reports/      # Constitution compliance reports
│   └── gap-analysis/           # Specification coverage analysis
└── prompts/                     # AI prompt templates
    └── specification-analysis.md
```

## Document Structure & Metadata

All CPR documents use structured YAML front matter for enhanced AI integration and framework automation:

```yaml
---
type: governance                    # Document category
document_class: constitution       # Specific type
version: 1.1.0                    # Semantic version
status: active                     # Current status
scope: [cpr-meta, cpr-api, cpr-ui] # Applicable repositories
enforcement: mandatory             # Compliance level
ai_instructions: |                 # AI guidance
  Always validate against principles
related_documents: [architecture.md] # Links
---
```

**Benefits:**
- **AI Context**: Copilot understands document purpose and usage
- **Framework Integration**: Tools automatically discover and validate documents  
- **Cross-Repository Linking**: Clear dependencies between documents
- **Change Management**: Structured versioning and approval workflows

See [framework/workflows/metadata-guide.md](framework/workflows/metadata-guide.md) for complete documentation.

## Core Principles

The CPR project follows these foundational principles (see [constitution.md](constitution.md)):

1. **Specification-First Development**: All features begin with a specification
2. **API Contract Consistency**: DTOs and contracts must match across repos
3. **Type Safety Everywhere**: Strong typing prevents runtime errors
4. **Comprehensive Testing**: 80% minimum coverage with contract tests

## Quick Start

### Creating a New Feature Specification

1. **Create specification files**:
   ```powershell
   # Start in proposed/ directory
   cd specifications/proposed
   
   # Copy templates
   Copy-Item "../../framework/templates/spec-description-template.md" "./feat-feature-name.md"
   ```

2. **Use framework templates**:
   - `spec-description-template.md` - Feature overview, user stories, acceptance criteria
   - `spec-implementation-plan-template.md` - Technical approach, phases
   - `spec-tasks-template.md` - Task breakdown
   - `spec-endpoints-template.md` - API contracts (if applicable)

3. **Run automated analysis**:
   ```powershell
   # Validate against constitution
   & "../../framework/tools/analyze-spec.ps1" -FeaturePath .
   ```

4. **Fix issues if needed**:
   - Address all CRITICAL and HIGH issues
   - Re-run analysis until compliant

5. **Move through lifecycle**:
   - **Proposed** → **Active** (when approved for development)
   - **Active** → **Archived** (when implementation complete)

6. **Begin implementation**:
   - Reference spec in PRs to cpr-api or cpr-ui
   - Use framework tools to maintain alignment

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

## Framework Integration

The CPR Framework (`framework/`) provides:
- **Specification-First Development**: Automated validation and templates
- **Constitutional Compliance**: Automatic checking against project principles  
- **Quality Assurance**: Analysis tools that ensure specification completeness
- **Cross-Repository Alignment**: Tools to keep API, UI, and docs synchronized

### Templates

The `framework/templates/` folder provides ready-to-use templates:

### Specification Templates
- **spec-description-template.md** - Feature description (user stories, requirements, business rules)
- **spec-implementation-plan-template.md** - Technical plan (architecture, API contracts, phases)
- **spec-tasks-template.md** - Task breakdown with dependencies and estimates
- **spec-endpoints-template.md** - API documentation (requests, responses, errors)
- **spec-progress-template.md** - Progress tracking (timeline, blockers, metrics)
- **spec-analysis-report-template.md** - Analysis report template (used by AI system)

### Bug Fix Template
- **bugfix-template.md** - Bug documentation (root cause, solution, prevention)

## Framework Workflow

```
1. Create Specification (specifications/proposed/)
   │ - Use framework/templates/
   │ - Follow constitutional principles
   ↓
2. Framework Analysis
   │ - Run framework/tools/analyze-spec.ps1
   │ - Generate compliance report in analysis/
   │ - Fix CRITICAL/HIGH issues
   ↓
3. Review & Approve
   │ - Tech lead approval
   │ - Move to specifications/active/
   ↓
4. Implementation (in cpr-api/cpr-ui)
   │ - Maintain spec alignment
   │ - Update progress regularly
   ↓
5. Testing & Validation
   │ - Run framework gap analysis
   │ - Ensure cross-repository consistency
   ↓
6. Completion
   │ - Move to specifications/archived/
   │ - Generate final compliance report
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
