# CPR Feature Development Framework

> **Version**: 1.0  
> **Status**: Phases 1-6 Complete  
> **Last Updated**: 2025-11-10

---

## Overview

The CPR Feature Development Framework is a specification-driven development (SDD) system that guides feature implementation from initial concept through deployment. The framework combines automation tools, AI-assisted prompts, and structured templates to ensure quality, consistency, and constitutional compliance.

---

## Framework Structure

```
framework/
├── README.md                    # This file
├── workflow.md                  # Complete workflow documentation
├── prompts/                     # AI-assisted prompts for each phase
│   ├── phase-1-specify.md      # Feature specification creation
│   ├── phase-2-refine.md       # Specification refinement
│   ├── phase-3-plan.md         # Implementation planning
│   ├── phase-4-analyze.md      # Quality analysis
│   ├── phase-5-implement.md    # Code implementation
│   └── phase-6-review.md       # Code review
├── templates/                   # Document templates
│   ├── description.md          # Feature specification template
│   ├── implementation-plan.md  # Technical planning template
│   ├── tasks.md                # Task breakdown template
│   ├── endpoints.md            # API contract template
│   ├── data-model.md           # Database schema template
│   ├── research.md             # Technical decisions template
│   ├── progress.md             # Progress tracking template
│   ├── automation-review.json  # Automated review results template
│   └── review-report.md        # Code review report template
└── tools/                       # PowerShell automation scripts
    ├── phase-1-specify.ps1     # Initialize feature specification
    ├── phase-2-refine.ps1      # Prepare for refinement
    ├── phase-3-plan.ps1        # Setup planning artifacts
    ├── phase-4-analyze.ps1     # Automated quality analysis
    ├── phase-5-implement.ps1   # Prepare for implementation
    └── phase-6-review.ps1      # (To be created) Automated code review
```

---

## Development Phases

### Phase 1: Specify Feature
**Purpose**: Create initial feature specification  
**Tool**: `phase-1-specify.ps1`  
**Prompt**: `phase-1-specify.md`  
**Outputs**: `description.md`, `progress.md`, feature branches

### Phase 2: Refine Specification
**Purpose**: Clarify requirements through stakeholder questions  
**Tool**: `phase-2-refine.ps1`  
**Prompt**: `phase-2-refine.md`  
**Outputs**: Updated `description.md` with clarifications

### Phase 3: Plan Implementation
**Purpose**: Create detailed technical plan and task breakdown  
**Tool**: `phase-3-plan.ps1`  
**Prompt**: `phase-3-plan.md`  
**Outputs**: `implementation-plan.md`, `tasks.md`, `endpoints.md`, optional `data-model.md`, `research.md`

### Phase 4: Analyze Specification
**Purpose**: Quality analysis before implementation  
**Tool**: `phase-4-analyze.ps1`  
**Prompt**: `phase-4-analyze.md`  
**Outputs**: `analysis-report.md`, `automation-report.json`, quality score

### Phase 5: Implement
**Purpose**: Execute implementation following task breakdown  
**Tool**: `phase-5-implement.ps1`  
**Prompt**: `phase-5-implement.md`  
**Outputs**: Complete code in feature branches, updated `tasks.md`

### Phase 6: Code Review
**Purpose**: Comprehensive quality and compliance review  
**Tool**: `phase-6-review.ps1` (to be created)  
**Prompt**: `phase-6-review.md`  
**Outputs**: `automation-review.json`, `review-report.md`, approval decision

### Phase 7: Test
**Status**: To be defined

### Phase 8: Deploy
**Status**: To be defined

---

## Quick Start

### Creating a New Feature

1. **Phase 1 - Specify**:
   ```powershell
   cd cpr-meta
   .\framework\tools\phase-1-specify.ps1 -FeatureNumber "0001" -FeatureName "feature-name"
   ```
   
2. **Fill in specification** using GitHub Copilot:
   ```
   @workspace Use framework/prompts/phase-1-specify.md to create specification for feature 0001
   ```

3. **Phase 2 - Refine**:
   ```powershell
   .\framework\tools\phase-2-refine.ps1 -FeatureNumber "0001" -FeatureName "feature-name"
   ```
   
   Use Copilot with `phase-2-refine.md` to generate clarifying questions

4. **Phase 3 - Plan**:
   ```powershell
   .\framework\tools\phase-3-plan.ps1 -FeatureNumber "0001" -FeatureName "feature-name"
   ```
   
   Use Copilot with `phase-3-plan.md` to create implementation plan

5. **Phase 4 - Analyze**:
   ```powershell
   .\framework\tools\phase-4-analyze.ps1 -FeatureNumber "0001" -FeatureName "feature-name"
   ```
   
   Use Copilot with `phase-4-analyze.md` to generate analysis report

6. **Phase 5 - Implement**:
   ```powershell
   .\framework\tools\phase-5-implement.ps1 -FeatureNumber "0001" -FeatureName "feature-name"
   ```
   
   Use Copilot with `phase-5-implement.md` to implement code

7. **Phase 6 - Review**:
   ```powershell
   .\framework\tools\phase-6-review.ps1 -FeatureNumber "0001" -FeatureName "feature-name"
   ```
   
   Use Copilot with `phase-6-review.md` to conduct code review

---

## Templates Reference

### Required for All Features

| Template | Phase | Purpose |
|----------|-------|---------|
| `description.md` | 1-2 | Feature specification with user stories, requirements |
| `implementation-plan.md` | 3 | Technical design and implementation strategy |
| `tasks.md` | 3 | Detailed task breakdown with dependencies |
| `endpoints.md` | 3 | API contract specifications |
| `progress.md` | 1+ | Progress tracking across all phases |

### Optional (As Needed)

| Template | Phase | Purpose |
|----------|-------|---------|
| `data-model.md` | 3 | Database schema and entity definitions |
| `research.md` | 3 | Technical decisions and alternatives |

### Generated by Automation

| Template | Phase | Purpose |
|----------|-------|---------|
| `automation-report.json` | 4 | Automated quality analysis results |
| `analysis-report.md` | 4 | Comprehensive quality findings |
| `automation-review.json` | 6 | Automated code review results |
| `review-report.md` | 6 | Comprehensive code review findings |

---

## Prompts Reference

### Usage Pattern

All prompts follow a consistent pattern:

1. **Automation Tool First**: Run the PowerShell script for the phase
2. **AI Assistance Second**: Use GitHub Copilot with the prompt

Example:
```powershell
# Step 1: Run automation
.\framework\tools\phase-3-plan.ps1 -FeatureNumber "0001" -FeatureName "feature-name"

# Step 2: Use Copilot (in GitHub Copilot Chat)
@workspace Use framework/prompts/phase-3-plan.md to create implementation plan for feature 0001
```

### Prompt Features

Each prompt includes:
- **Context**: What phase, what's the purpose
- **Prerequisites**: What must be complete before this phase
- **Operating Constraints**: Rules and principles to follow
- **Workflow**: Step-by-step execution guide
- **Success Criteria**: How to know the phase is complete
- **Examples**: Sample outputs or code snippets

---

## Tools Reference

### PowerShell Scripts

All automation scripts are in `framework/tools/` and follow PowerShell best practices.

#### Common Parameters

- `-FeatureNumber`: 4-digit feature number (e.g., "0001")
- `-FeatureName`: Kebab-case feature name (e.g., "user-profile-management")
- `-SkipBranchCreation`: (Phase 5) Skip Git branch creation if already exists

#### What Tools Do

1. **Validate Prerequisites**: Check that previous phases are complete
2. **Create Artifacts**: Generate folders, files, branches as needed
3. **Run Analysis**: Execute automated checks (linting, tests, etc.)
4. **Generate Reports**: Create JSON/text summaries for AI review
5. **Update Progress**: Track phase completion

---

## Quality Standards

### Constitutional Compliance

All features must comply with the 11 CPR Constitutional Principles:

1. **Specification-Driven Development**: Code must be traceable to specifications
2. **API Contract Consistency**: DTOs must match between backend and frontend
3. **Framework Integration**: Use established patterns (ASP.NET Core, React Query)
4. **Type Safety**: Strong typing everywhere, no `any` or `dynamic`
5. **Offline-First Design**: React Query caching, IndexedDB persistence
6. **Internationalization**: i18n keys for all UI text, locale-aware formatting
7. **Comprehensive Testing**: Unit, integration, E2E tests (≥80% coverage)
8. **Performance Standards**: API <200ms, UI <1s, no N+1 queries
9. **Naming Conventions**: snake_case JSON, PascalCase C#, camelCase TS
10. **Security First**: Authentication, authorization, input validation
11. **Database Standards**: UUID PKs, timestamps, soft delete, proper indexes

### Quality Thresholds

**Phase 4 (Analysis)**:
- ≥90/100: Ready for implementation
- 70-89/100: Needs improvement
- <70/100: Not ready

**Phase 6 (Review)**:
- ≥85/100: Approved for testing
- 70-84/100: Conditional approval
- <70/100: Rejected

---

## Naming Conventions

### Feature Numbers
- Format: `####` (4 digits, zero-padded)
- Examples: `0001`, `0002`, `0042`, `0123`

### Feature Names
- Format: `kebab-case` (lowercase, hyphen-separated)
- Examples: `user-profile-management`, `goal-creation`, `performance-review`

### Specification Folders
- Format: `specifications/####-<feature-name>/`
- Examples: `specifications/0001-user-profile-management/`

### Git Branches
- Format: `feature/####-<feature-name>`
- Examples: `feature/0001-user-profile-management`

### Commit Messages
- Format: `<type>(####): <description>`
- Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`
- Examples: 
  - `feat(0001): Add user profile creation endpoint`
  - `test(0001): Add unit tests for profile service`

---

## File Organization

### Specification Folder Structure

```
specifications/####-<feature-name>/
├── description.md              # Phase 1-2: Feature specification
├── implementation-plan.md      # Phase 3: Technical plan
├── tasks.md                    # Phase 3: Task breakdown
├── endpoints.md                # Phase 3: API contracts
├── data-model.md               # Phase 3: Database schema (optional)
├── research.md                 # Phase 3: Technical decisions (optional)
├── progress.md                 # All phases: Progress tracking
├── automation-report.json      # Phase 4: Automated analysis results
├── analysis-report.md          # Phase 4: Quality analysis
├── automation-review.json      # Phase 6: Automated review results
└── review-report.md            # Phase 6: Code review report
```

---

## Best Practices

### Using the Framework

1. **Follow the Phases**: Don't skip phases; each builds on the previous
2. **Run Automation First**: Always run the PowerShell script before using AI prompts
3. **Complete Each Phase**: Ensure success criteria met before moving forward
4. **Track Progress**: Update `progress.md` after each phase
5. **Commit Regularly**: Use conventional commits throughout implementation
6. **Review Constitutional Compliance**: Check all 11 principles at each phase

### Working with AI

1. **Provide Context**: Always reference the phase prompt in your Copilot query
2. **Use @workspace**: Let Copilot see the full codebase context
3. **Be Specific**: Reference feature numbers and specific files
4. **Iterate**: If output isn't complete, ask Copilot to continue or refine
5. **Validate**: Don't blindly accept AI suggestions; review for quality

### Common Pitfalls

❌ **Don't**:
- Skip phases or automation tools
- Ignore constitutional principles
- Accept AI suggestions without review
- Modify specifications without updating all artifacts
- Commit without running tests and linting
- Merge without code review approval

✅ **Do**:
- Follow the workflow systematically
- Run automation before AI prompts
- Validate all outputs against success criteria
- Keep specifications and code in sync
- Test thoroughly before code review
- Fix all CRITICAL and HIGH issues before proceeding

---

## Troubleshooting

### Common Issues

**Issue**: Automation script fails with "Previous phase not complete"
- **Solution**: Complete the previous phase first; check `progress.md`

**Issue**: Git branch already exists error
- **Solution**: Use `-SkipBranchCreation` flag in Phase 5 tool

**Issue**: Quality score below threshold
- **Solution**: Review findings in analysis/review report, fix issues, re-run

**Issue**: Tests failing in Phase 6
- **Solution**: Fix failing tests before proceeding; tests must pass for approval

**Issue**: Constitutional principle violations
- **Solution**: Review `constitution.md`, update code to comply, re-review

---

## Contributing to the Framework

### Adding New Phases

When Phase 7+ are defined:

1. Create automation script: `framework/tools/phase-X-<name>.ps1`
2. Create AI prompt: `framework/prompts/phase-X-<name>.md`
3. Create templates if needed in `framework/templates/`
4. Update `workflow.md` with complete phase definition
5. Update this README with phase documentation
6. Test thoroughly before marking phase complete

### Improving Existing Phases

1. Update relevant files (tools, prompts, templates)
2. Update `workflow.md` documentation
3. Update this README if public interface changes
4. Test with existing features to ensure backward compatibility
5. Document breaking changes clearly

---

## Version History

### v1.0 - 2025-11-10
- ✅ Phase 1-6 prompts complete
- ✅ Phase 1-5 automation tools complete
- ✅ All templates created
- ⏳ Phase 6 automation tool pending
- ⏳ Phase 7-8 to be defined

---

## Resources

### Documentation
- [Workflow Guide](workflow.md) - Complete phase-by-phase workflow
- [Constitution](../constitution.md) - 11 CPR Constitutional Principles
- [Architecture](../architecture.md) - System architecture overview
- [Features List](../features-list.md) - All planned features

### Examples
- [Specification 0001](../specifications/0001-personal-goal-creation-management/) - Reference implementation

### External References
- [Conventional Commits](https://www.conventionalcommits.org/)
- [Semantic Versioning](https://semver.org/)
- [ASP.NET Core Best Practices](https://learn.microsoft.com/en-us/aspnet/core/)
- [React Best Practices](https://react.dev/learn)

---

**Questions or Issues?** Review the [workflow.md](workflow.md) for detailed guidance on each phase.
