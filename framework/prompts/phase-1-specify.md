---
phase: 1_specify
purpose: Guide feature specification creation
applies_to: description.md
related_documents:
  - ../workflow.md
  - ../../constitution.md
  - ../../architecture.md
---

# Phase 1: Specify Feature - GitHub Copilot Prompt

## User Input

```text
$ARGUMENTS
```

You **MUST** consider user input before proceeding (if not empty).

## Context

You are helping to create a feature specification for the CPR (Career Progress Registry) project following the CPR Framework workflow. This is **Phase 1: Specify Feature**, where we define clear business requirements and technical foundations.

## Your Mission

Run `framework/tools/phase-1-specify.ps1` to initialize new feature.

Fill in the `description.md` template with comprehensive, well-structured content that:
1. Clearly defines the feature's business value and user needs
2. Provides complete technical specifications
3. Ensures constitutional compliance with all 11 CPR principles
4. Coordinates requirements across cpr-api (backend) and cpr-ui (frontend)

## CPR Constitutional Principles (MUST FOLLOW)

### Principle 1: Specification-First Development
- Complete this specification BEFORE any code is written
- Document all requirements clearly and comprehensively

### Principle 2: API Contract Consistency
- Define matching DTOs for C# backend and TypeScript frontend
- Ensure data contracts are synchronized across repositories

### Principle 3: API Standards & Security
- Use RESTful endpoints with proper HTTP methods
- Follow standard status codes and error handling

### Principle 4: Type Safety Everywhere
- Provide strongly-typed C# DTOs with validation attributes
- Provide TypeScript interfaces with strict types

### Principle 5: Offline Mode
- Specify offline capabilities for this feature
- Define offline data caching and sync strategies

### Principle 6: Internationalization
- Ensure all UI text is externalizable for translation
- Support locale-specific formatting (dates, numbers)

### Principle 7: Comprehensive Testing
- Define unit test, integration test, and performance test requirements
- Provide clear test scenarios

### Principle 8: Performance-First React Development
- Set measurable performance requirements (response times, load times)
- Define performance benchmarks

### Principle 9: Strict Naming Conventions
- **JSON/API**: snake_case (`user_id`, `created_at`)
- **C# Properties**: PascalCase with `[JsonPropertyName]` attributes
- **TypeScript**: camelCase in code, snake_case in API types
- **Database**: snake_case for tables, columns, indexes
- **URLs**: kebab-case (`/api/v1/user-profiles`)

### Principle 10: Security & Data Privacy
- Specify authentication and authorization requirements
- Define data encryption and privacy controls

### Principle 11: Database Design Standards
- Provide proper database schema with constraints
- Use UUIDs for primary keys, proper indexing, and normalization

## Specification Template Sections

### Executive Summary
- Write 2-3 clear sentences explaining WHAT this feature does and WHY it matters
- State the key business impact in one sentence

### Core User Stories
- Write user stories in the format: "As a [user type], I want [action], So that [benefit]"
- Provide 3-5 specific, testable acceptance criteria for each story
- Focus on user value, not implementation details

### Business Rules
- List 3-5 key business rules that govern this feature
- Be specific about constraints, validations, and requirements

### Technical Requirements
- **Performance**: Set measurable targets (e.g., "API response < 200ms at 95th percentile")
- **Security**: Define authentication, authorization, and data protection needs
- **Offline Mode**: Specify what works offline and how sync happens
- **Internationalization**: Identify what needs translation and locale support

### API Design
- Design RESTful endpoints following REST conventions
- Use proper HTTP methods: GET (read), POST (create), PUT (update), DELETE (delete)
- Follow naming: `/api/v1/resource-name` (kebab-case, plural for collections)
- Document each endpoint's purpose

### Data Model
- Write SQL schema with proper data types
- Include PRIMARY KEY, FOREIGN KEY, UNIQUE, and CHECK constraints
- Use snake_case for all table and column names
- Add created_at and updated_at timestamps

### Type Safety
- **C# DTOs**: Use PascalCase properties with `[JsonPropertyName("snake_case")]`
- Add validation attributes: `[Required]`, `[MinLength]`, `[MaxLength]`, `[Range]`
- **TypeScript**: Use snake_case to match API contracts
- Use strict types (e.g., `1 | 2 | 3 | 4 | 5` for limited ranges)

### Testing Strategy
- Define unit tests for business logic and validation
- Define integration tests for end-to-end workflows
- Define performance tests with load requirements

### Success Metrics
- Provide 3-5 measurable success criteria
- Use specific numbers (e.g., "95% users complete profile in < 5 minutes")

### Constitutional Compliance Checklist
- Review each of the 11 principles
- Check off principles that are fully addressed in the specification

### Dependencies & Assumptions
- List what this feature depends on (other features, systems, data)
- State key assumptions about the environment, users, or constraints

## Quality Checklist

Before finalizing, ensure:

- [ ] **Completeness**: All template sections are filled with meaningful content
- [ ] **Clarity**: Requirements are clear and unambiguous
- [ ] **Consistency**: Naming follows conventions (snake_case JSON, PascalCase C#, etc.)
- [ ] **Type Safety**: DTOs match between C# and TypeScript
- [ ] **Testability**: All requirements have testable acceptance criteria
- [ ] **Constitutional Compliance**: All 11 principles are addressed
- [ ] **Cross-Repository Coordination**: Both backend (cpr-api) and frontend (cpr-ui) requirements are specified

## Example: Good vs Bad

### ❌ Bad User Story
"As a user, I want to update my profile."

### ✅ Good User Story
**US-001: Profile Updates**
**As a** registered employee  
**I want** to update my skills and proficiency levels  
**So that** my career recommendations stay accurate

**Acceptance Criteria**:
- [ ] I can edit skills independently without affecting other profile sections
- [ ] Changes auto-save every 30 seconds while editing
- [ ] I receive visual confirmation when changes are saved successfully
- [ ] I can discard unsaved changes and revert to last saved state

### ❌ Bad API Endpoint
```
POST /UpdateUser
```

### ✅ Good API Endpoint
```
PUT /api/v1/user-profiles/{user-id}    # Update user profile
```

### ❌ Bad Type Definition
```csharp
public class User {
    public string Name { get; set; }
}
```

### ✅ Good Type Definition
```csharp
public class UserProfileDto
{
    [JsonPropertyName("user_id")]
    public Guid UserId { get; set; }
    
    [JsonPropertyName("first_name")]
    [Required, MinLength(2), MaxLength(100)]
    public string FirstName { get; set; }
    
    [JsonPropertyName("profile_completeness")]
    [Range(0, 100)]
    public int ProfileCompleteness { get; set; }
}
```

## Progress Tracking

As you complete sections of the specification, update `progress.md`:

1. Check off items in the **Phase 1: Specify** checklist
2. Update notes with important decisions or insights
3. Document any blockers that arise
4. Update the last_updated timestamp when making significant changes

Example progress update:
```yaml
last_updated: 2025-11-06
```

```markdown
### Phase 1: Specify
- [x] Executive summary completed
- [x] User stories defined with acceptance criteria
- [x] Business rules documented
- [ ] Technical requirements specified (in progress)
```

## Your Task

Now, fill in the `description.md` template following these guidelines. Create a comprehensive, high-quality specification that the development team can confidently implement.

**Remember**: 
- This is Phase 1 (Specify). Focus on WHAT and WHY, not HOW. Implementation details come in later phases.
- Update `progress.md` as you complete each section to track your progress.
