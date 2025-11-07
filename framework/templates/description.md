---
type: feature_specification
feature_number: {{FEATURE_NUMBER}}
feature_name: {{FEATURE_NAME}}
version: 1.0.0
created: {{CREATED_DATE}}
status: draft
phase: 1_specify
repositories:
  - cpr-meta
  - cpr-api
  - cpr-ui
related_documents:
  - ../../constitution.md
  - ../../architecture.md
---

# [Feature Title]

> **Specification ID**: SPEC-{{FEATURE_NUMBER}}  
> **Feature**: {{FEATURE_NAME}}  
> **Priority**: [High/Medium/Low]  
> **Complexity**: [High/Medium/Low]

## Executive Summary

[2-3 sentences describing the feature and its business value]

**Business Impact**: [Key business benefit]

---

## Core User Stories

### US-001: [Story Title]
**As a** [user type]  
**I want** [action]  
**So that** [benefit]

**Acceptance Criteria**:
- [ ] [Specific testable criterion]
- [ ] [Specific testable criterion]
- [ ] [Specific testable criterion]

### US-002: [Story Title]
**As a** [user type]  
**I want** [action]  
**So that** [benefit]

**Acceptance Criteria**:
- [ ] [Specific testable criterion]
- [ ] [Specific testable criterion]

---

## Business Rules

1. **[Rule Name]**: [Description]
2. **[Rule Name]**: [Description]
3. **[Rule Name]**: [Description]

---

## Technical Requirements

### Performance
- [Performance requirement with measurable metric]
- Example: API response time < 200ms (95th percentile)

### Security
- [Security requirement]
- Example: All endpoints require authentication

### Offline Mode (Constitutional Principle 5)
- [Offline capability requirement]
- Example: Feature works offline with cached data

### Internationalization (Constitutional Principle 6)
- [I18n requirement]
- Example: All UI text externalized for translation

---

## API Design (Constitutional Principles 2, 3, 9)

### Endpoints
```
GET    /api/v1/[resource-name]           # [Description]
POST   /api/v1/[resource-name]           # [Description]
PUT    /api/v1/[resource-name]/{id}      # [Description]
DELETE /api/v1/[resource-name]/{id}      # [Description]
```

---

## Data Model (Constitutional Principle 11)

### [EntityName]
```sql
[table_name] (
  id UUID PRIMARY KEY,
  [field_name] VARCHAR(100) NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

---

## Type Safety (Constitutional Principles 2, 4, 9)

### C# DTOs (cpr-api)
```csharp
public class [Entity]Dto
{
    [JsonPropertyName("field_name")]
    [Required]
    public string FieldName { get; set; }
}
```

### TypeScript (cpr-ui)
```typescript
export interface [Entity] {
  field_name: string;
}
```

---

## Testing Strategy (Constitutional Principle 7)

### Unit Tests
- [Test category]

### Integration Tests
- [Test scenario]

### Performance Tests
- [Performance test requirement]

---

## Success Metrics

- **[Metric Name]**: [Target value]
- **[Metric Name]**: [Target value]
- **[Metric Name]**: [Target value]

---

## Constitutional Compliance ✅

- [ ] **Principle 1**: Specification-First Development
- [ ] **Principle 2**: API Contract Consistency
- [ ] **Principle 3**: RESTful API Standards
- [ ] **Principle 4**: Type Safety (C# + TypeScript)
- [ ] **Principle 5**: Offline Mode Support
- [ ] **Principle 6**: Internationalization
- [ ] **Principle 7**: Comprehensive Testing
- [ ] **Principle 8**: Performance Requirements
- [ ] **Principle 9**: Naming Conventions (snake_case JSON)
- [ ] **Principle 10**: Security & Privacy
- [ ] **Principle 11**: Database Design Standards

---

## Dependencies & Assumptions

**Dependencies:**
- [Required system/feature]

**Assumptions:**
- [Key assumption]

---

**Next Phase**: Phase 2 (Refine) - Detailed requirements analysis

**GitHub Copilot Instructions**: Please fill in this specification template following CPR constitutional principles and framework standards.
