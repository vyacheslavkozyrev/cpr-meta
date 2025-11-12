# GitHub Copilot Instructions for CPR Project

## Project Context
You are working on the CPR (Career Progress Registry) project - a specification-driven development platform with three repositories:
- **cpr-meta**: Documentation, specifications, governance, and framework
- **cpr-api**: .NET 8 Web API backend with PostgreSQL
- **cpr-ui**: React 18 + TypeScript frontend

## Core Principles (ALWAYS FOLLOW)
1. **Specification-First**: No code without documentation in cpr-meta
2. **Constitution Compliance**: All suggestions must align with constitution.md principles
3. **Type Safety**: Enforce strong typing in both C# and TypeScript
4. **API Consistency**: DTOs must match between backend and frontend
5. **Framework Integration**: Use CPR framework tools for validation

## Naming Conventions
- **JSON/API**: snake_case (`user_id`, `created_at`)
- **C# Properties**: PascalCase with `[JsonPropertyName]` (`UserId` → `"user_id"`)
- **TypeScript**: camelCase (`userId`, `createdAt`)
- **Database**: snake_case tables, columns, indexes
- **URLs**: kebab-case (`/api/v1/user-profiles`)

## Code Generation Rules

### When suggesting API changes:
1. Check existing DTOs in cpr-api/src/CPR.Application/DTOs/
2. Ensure JSON naming follows snake_case
3. Add proper validation attributes
4. Include corresponding TypeScript types for cpr-ui

### When suggesting UI changes:
1. Reference existing components in cpr-ui/src/components/
2. Use established patterns (React Query, Zustand, etc.)
3. Ensure type safety with proper TypeScript interfaces
4. Follow responsive design patterns

### When creating specifications:
1. Use templates from framework/templates/
2. Include structured metadata (YAML front matter)
3. Reference constitutional principles
4. Run framework validation tools

## Framework Commands
Suggest these CPR framework commands when appropriate:
- `cpr-analyze <path>` - Analyze specifications
- `cpr-validate-metadata` - Validate document metadata
- `cpr-new-spec <name> -Type <feature|api|ui>` - Create new specification
- `cpr-constitution` - Show constitutional principles

## Build & Test Commands (ALWAYS USE)

### Frontend (cpr-ui)
- **Build**: `yarn build` (NEVER use `npx tsc --noEmit` alone)
- **Test**: `yarn test`, `yarn test:coverage`, `yarn test:ui`
- **Dev**: `yarn dev`, `yarn start:mock`, `yarn start:local`
- **Lint**: `yarn lint`, `yarn lint:fix`

### Backend (cpr-api)
- **Build**: `dotnet build`, `dotnet build --configuration Release`
- **Test**: `dotnet test`, `dotnet test /p:CollectCoverage=true`
- **Run**: `dotnet run --project src/CPR.Api`

**Why**: Package.json scripts include TypeScript strict checking (`tsc -b`), configuration, and validations that direct commands bypass.

## Quality Gates
Before suggesting implementation:
1. Verify specification exists in cpr-meta
2. Check constitution compliance
3. Validate naming conventions
4. Ensure type safety
5. Confirm API contract alignment
6. **Run `yarn build` to verify TypeScript compilation**

## Common Responses
When asked about implementation without specification:
"I need to create a specification first. Let me generate one using the CPR framework templates and validate it against constitutional principles."

When suggesting code that might violate principles:
"This approach may conflict with CPR Constitutional Principle X. Let me suggest an alternative that maintains compliance."