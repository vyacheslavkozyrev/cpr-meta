# CPR Database Schema & Data Specification

**Last Updated**: November 6, 2025  
**Database**: PostgreSQL 15+  
**Schema Version**: CreateDatabaseSchema Migration (20250910193406)  
**Entity Framework**: .NET 9 with EF Core

---

## Overview

This document provides comprehensive documentation of the CPR (Continuous Performance Review) platform database schema, including all entity tables, relationships, indexes, and seed data. The database follows Clean Architecture principles with comprehensive audit trails and soft delete patterns.

---

## Schema Conventions

### Naming Conventions
- **Tables**: snake_case (e.g., `career_paths`, `employee_to_skill`)
- **Columns**: snake_case (e.g., `user_name`, `created_at`)
- **Primary Keys**: `id` (UUID)
- **Foreign Keys**: `{table}_id` (e.g., `user_id`, `manager_id`)
- **Indexes**: `IX_{table}_{column}` or `UX_{table}_{column}` (unique)

### Audit Columns
All entities inherit from `AuditableEntity` with standard audit columns:
```sql
created_by      UUID            -- User who created the record
created_at      TIMESTAMPTZ     DEFAULT CURRENT_TIMESTAMP
modified_by     UUID            -- User who last modified the record  
modified_at     TIMESTAMPTZ     -- Last modification timestamp
is_deleted      BOOLEAN         DEFAULT FALSE
deleted_by      UUID            -- User who soft-deleted the record
deleted_at      TIMESTAMPTZ     -- Soft deletion timestamp
```

### Data Types
- **Identifiers**: `UUID` (Primary and Foreign Keys)
- **Timestamps**: `TIMESTAMPTZ` (with timezone support)
- **Dates**: `DATE` (date only, no time)
- **Text**: `TEXT` (variable length strings)
- **Numbers**: `NUMERIC` for decimals, `INTEGER` for whole numbers
- **Flags**: `BOOLEAN` for true/false values

---

## Core Entity Tables

### users
**Description**: System users with authentication and profile information
```sql
CREATE TABLE users (
    id                  UUID            PRIMARY KEY,
    user_name          TEXT            NOT NULL,
    entra_external_id  TEXT            NULL,        -- Microsoft Entra External ID
    display_name       TEXT            NULL,
    -- Audit columns
    created_by         UUID            NULL,
    created_at         TIMESTAMPTZ     DEFAULT CURRENT_TIMESTAMP,
    modified_by        UUID            NULL,
    modified_at        TIMESTAMPTZ     NULL,
    is_deleted         BOOLEAN         DEFAULT FALSE,
    deleted_by         UUID            NULL,
    deleted_at         TIMESTAMPTZ     NULL
);

-- Indexes
CREATE UNIQUE INDEX UX_users_user_name ON users(user_name);
CREATE UNIQUE INDEX IX_users_entra_external_id ON users(entra_external_id) WHERE entra_external_id IS NOT NULL;
```

### roles
**Description**: System roles for authorization (Employee, Manager, Solution Owner, Director, Administrator)
```sql
CREATE TABLE roles (
    id              UUID            PRIMARY KEY,
    title           TEXT            NOT NULL,
    description     TEXT            NULL,
    -- Audit columns included
);
```

### user_to_role
**Description**: Many-to-many relationship between users and roles
```sql
CREATE TABLE user_to_role (
    id              UUID            PRIMARY KEY,
    user_id         UUID            NOT NULL REFERENCES users(id),
    role_id         UUID            NOT NULL REFERENCES roles(id),
    -- Audit columns included
);

-- Indexes
CREATE INDEX IX_user_to_role_user_id ON user_to_role(user_id);
CREATE INDEX IX_user_to_role_role_id ON user_to_role(role_id);
CREATE UNIQUE INDEX UX_user_to_role_user_role ON user_to_role(user_id, role_id);
```

### departments
**Description**: Organizational departments and hierarchy
```sql
CREATE TABLE departments (
    id                      UUID            PRIMARY KEY,
    name                    TEXT            NOT NULL,
    code                    TEXT            NULL,           -- Department code (e.g., "ENG", "HR")
    description             TEXT            NULL,
    parent_department_id    UUID            REFERENCES departments(id),
    manager_id              UUID            NULL,           -- Department manager (circular ref to employees)
    -- Audit columns included
);
```

### locations
**Description**: Physical office locations and remote work settings
```sql
CREATE TABLE locations (
    id              UUID            PRIMARY KEY,
    name            TEXT            NOT NULL,
    address         TEXT            NULL,
    city            TEXT            NULL,
    region          TEXT            NULL,
    country         TEXT            NULL,
    postal_code     TEXT            NULL,
    timezone        TEXT            NULL,
    contact_phone   TEXT            NULL,
    -- Audit columns included
);
```

---

## Career Framework Tables

### career_paths
**Description**: High-level career paths (e.g., "Engineering", "Product", "Design")
```sql
CREATE TABLE career_paths (
    id              UUID            PRIMARY KEY,
    title           TEXT            NOT NULL,
    description     TEXT            NULL,
    -- Audit columns included
);
```

### career_tracks
**Description**: Specific tracks within career paths (e.g., "Backend Engineering", "Frontend Engineering")
```sql
CREATE TABLE career_tracks (
    id                  UUID            PRIMARY KEY,
    title               TEXT            NOT NULL,
    description         TEXT            NULL,
    career_path_id      UUID            NOT NULL REFERENCES career_paths(id),
    -- Audit columns included
);
```

### positions
**Description**: Specific job positions within career tracks (e.g., "Senior Software Engineer")
```sql
CREATE TABLE positions (
    id                  UUID            PRIMARY KEY,
    title               TEXT            NOT NULL,
    description         TEXT            NULL,
    expectations        TEXT            NULL,           -- Role expectations and responsibilities
    career_track_id     UUID            NOT NULL REFERENCES career_tracks(id),
    -- Audit columns included
);
```

### employees
**Description**: Employee records linking users to organizational structure
```sql
CREATE TABLE employees (
    id              UUID            PRIMARY KEY,
    user_id         UUID            NOT NULL REFERENCES users(id),
    manager_id      UUID            REFERENCES employees(id),    -- Self-referential for reporting structure
    position_id     UUID            REFERENCES positions(id),
    department_id   UUID            REFERENCES departments(id),
    -- Audit columns included
);

-- Indexes
CREATE INDEX IX_employees_user_id ON employees(user_id);
CREATE INDEX IX_employees_manager_id ON employees(manager_id);
CREATE INDEX IX_employees_position_id ON employees(position_id);
CREATE INDEX IX_employees_department_id ON employees(department_id);
```

---

## Skills & Assessment Tables

### skill_categories
**Description**: Skill categorization (e.g., "Technical Skills", "Leadership", "Communication")
```sql
CREATE TABLE skill_categories (
    id              UUID            PRIMARY KEY,
    title           TEXT            NOT NULL,
    description     TEXT            NULL,
    -- Audit columns included
);
```

### skills
**Description**: Individual skills within categories
```sql
CREATE TABLE skills (
    id              UUID            PRIMARY KEY,
    title           TEXT            NOT NULL,
    description     TEXT            NULL,
    category_id     UUID            NOT NULL REFERENCES skill_categories(id),
    -- Audit columns included
);
```

### skill_levels
**Description**: Proficiency levels for skills (e.g., "Beginner", "Intermediate", "Advanced", "Expert")
```sql
CREATE TABLE skill_levels (
    id              UUID            PRIMARY KEY,
    skill_id        UUID            NOT NULL REFERENCES skills(id),
    title           TEXT            NOT NULL,
    description     TEXT            NULL,
    value           INTEGER         NOT NULL,           -- Numeric level (1-5)
    -- Audit columns included
);
```

### position_to_skill
**Description**: Required skills and proficiency levels for positions
```sql
CREATE TABLE position_to_skill (
    id              UUID            PRIMARY KEY,
    position_id     UUID            NOT NULL REFERENCES positions(id),
    skill_id        UUID            NOT NULL REFERENCES skills(id),
    skill_level_id  UUID            NOT NULL REFERENCES skill_levels(id),
    weight          NUMERIC         NULL,               -- Importance weight for this skill
    is_mandatory    BOOLEAN         DEFAULT FALSE,      -- Whether skill is required vs preferred
    rationale       TEXT            NULL,               -- Why this skill is needed for the position
    -- Audit columns included
);

-- Indexes
CREATE INDEX IX_position_to_skill_position_id ON position_to_skill(position_id);
CREATE INDEX IX_position_to_skill_skill_id ON position_to_skill(skill_id);
CREATE INDEX IX_position_to_skill_skill_level_id ON position_to_skill(skill_level_id);
CREATE UNIQUE INDEX UX_position_to_skill_position_skill ON position_to_skill(position_id, skill_id);
```

### employee_to_skill
**Description**: Employee skill assessments and proficiency tracking
```sql
CREATE TABLE employee_to_skill (
    id              UUID            PRIMARY KEY,
    employee_id     UUID            NOT NULL REFERENCES employees(id),
    skill_id        UUID            NOT NULL REFERENCES skills(id),
    skill_level_id  UUID            REFERENCES skill_levels(id),
    persist_value   NUMERIC         NULL,               -- Alternative numeric assessment value
    source          TEXT            NULL,               -- Assessment source (self, manager, peer)
    effective_date  TIMESTAMPTZ     NULL,               -- When assessment became effective
    is_target       BOOLEAN         DEFAULT FALSE,      -- Whether this is a target vs current assessment
    -- Audit columns included
);

-- Indexes
CREATE INDEX IX_employee_to_skill_employee_id ON employee_to_skill(employee_id);
CREATE INDEX IX_employee_to_skill_skill_id ON employee_to_skill(skill_id);
CREATE INDEX IX_employee_to_skill_skill_level_id ON employee_to_skill(skill_level_id);
CREATE UNIQUE INDEX UX_employee_to_skill_employee_skill_effective ON employee_to_skill(employee_id, skill_id, effective_date);
```

---

## Goals & Performance Tables

### goals
**Description**: Individual and professional development goals
```sql
CREATE TABLE goals (
    id                      UUID            PRIMARY KEY,
    employee_id             UUID            NOT NULL REFERENCES employees(id),
    title                   TEXT            NOT NULL,
    description             TEXT            NULL,
    status                  TEXT            DEFAULT 'open',     -- open, in_progress, completed
    related_skill_id        UUID            REFERENCES skills(id),
    related_skill_level_id  UUID            REFERENCES skill_levels(id),
    deadline                DATE            NULL,
    is_completed            BOOLEAN         DEFAULT FALSE,
    completed_at            TIMESTAMPTZ     NULL,
    progress_percent        NUMERIC(5,2)    DEFAULT 0.00,       -- 0.00 to 100.00
    priority                SMALLINT        NULL,               -- Priority level
    visibility              TEXT            NULL,               -- private, team, organization
    -- Audit columns included
);

-- Indexes
CREATE INDEX IX_goals_employee_id ON goals(employee_id);
```

### goal_tasks
**Description**: Task breakdown for complex goals
```sql
CREATE TABLE goal_tasks (
    id              UUID            PRIMARY KEY,
    goal_id         UUID            NOT NULL REFERENCES goals(id),
    title           TEXT            NOT NULL,
    description     TEXT            NULL,
    deadline        TIMESTAMPTZ     NULL,
    is_completed    BOOLEAN         DEFAULT FALSE,
    completed_at    TIMESTAMPTZ     NULL,
    -- Audit columns included
);
```

---

## Feedback Tables

### feedback_requests
**Description**: Requests for feedback from colleagues and stakeholders
```sql
CREATE TABLE feedback_requests (
    id              UUID            PRIMARY KEY,
    requestor_id    UUID            NOT NULL REFERENCES employees(id),    -- Who requested feedback
    employee_id     UUID            NOT NULL REFERENCES employees(id),    -- Who should provide feedback
    project_id      UUID            REFERENCES projects(id),
    goal_id         UUID            REFERENCES goals(id),
    message         TEXT            NULL,                                 -- Context or specific request
    due_date        TIMESTAMPTZ     NULL,
    -- Audit columns included
);
```

### feedback
**Description**: Submitted feedback between employees
```sql
CREATE TABLE feedback (
    id                  UUID            PRIMARY KEY,
    goal_id             UUID            NOT NULL REFERENCES goals(id),
    project_id          UUID            REFERENCES projects(id),
    from_employee_id    UUID            NOT NULL REFERENCES employees(id),
    to_employee_id      UUID            NOT NULL REFERENCES employees(id),
    content             TEXT            NOT NULL,
    rating              INTEGER         NULL,                           -- Optional numeric rating
    -- Audit columns included
);
```

---

## Project Management Tables

### projects
**Description**: Projects and initiatives for cross-functional collaboration
```sql
CREATE TABLE projects (
    id              UUID            PRIMARY KEY,
    code            TEXT            NOT NULL UNIQUE,                    -- Project code (e.g., "PRJ-001")
    title           TEXT            NOT NULL,
    description     TEXT            NULL,
    owner_id        UUID            REFERENCES employees(id),           -- Project owner/lead
    sponsor_id      UUID            REFERENCES employees(id),           -- Executive sponsor
    -- Audit columns included
);

-- Indexes
CREATE INDEX IX_projects_owner_id ON projects(owner_id);
CREATE INDEX IX_projects_sponsor_id ON projects(sponsor_id);
CREATE UNIQUE INDEX UX_projects_code ON projects(code);
```

### project_roles
**Description**: Project-specific roles (e.g., "Tech Lead", "Product Manager" for a project)
```sql
CREATE TABLE project_roles (
    id              UUID            PRIMARY KEY,
    project_id      UUID            NOT NULL REFERENCES projects(id),
    title           TEXT            NOT NULL,
    description     TEXT            NULL,
    -- Audit columns included
);
```

### project_teams
**Description**: Employee assignments to project roles
```sql
CREATE TABLE project_teams (
    id                  UUID            PRIMARY KEY,
    project_role_id     UUID            NOT NULL REFERENCES project_roles(id),
    employee_id         UUID            NOT NULL REFERENCES employees(id),
    -- Audit columns included
);

-- Indexes
CREATE INDEX IX_project_teams_project_role_id ON project_teams(project_role_id);
CREATE INDEX IX_project_teams_employee_id ON project_teams(employee_id);
CREATE UNIQUE INDEX UX_project_teams_role_employee ON project_teams(project_role_id, employee_id);
```

---

## Audit & Logging Tables

### audit_logs
**Description**: System audit trail for all significant actions
```sql
CREATE TABLE audit_logs (
    id              UUID            PRIMARY KEY,
    actor_id        UUID            NULL,                               -- User performing the action
    action          TEXT            NOT NULL,                           -- Action performed
    target_type     TEXT            NULL,                               -- Type of entity affected
    target_id       UUID            NULL,                               -- ID of entity affected
    detail          TEXT            NULL,                               -- Additional action details
    -- Audit columns included
);
```

---

## Database Features

### Soft Delete Pattern
All entities support soft deletion:
- Records are marked as deleted (`is_deleted = TRUE`) instead of physical deletion
- Includes `deleted_by` and `deleted_at` for audit trail
- Application queries filter out deleted records by default

### Audit Trail
Complete audit trail for all entities:
- Creation tracking (`created_by`, `created_at`)
- Modification tracking (`modified_by`, `modified_at`) 
- Deletion tracking (`deleted_by`, `deleted_at`)
- Supports forensic analysis and compliance reporting

### Referential Integrity
- Foreign key constraints ensure data consistency
- Cascade deletion rules for hierarchical relationships
- Unique constraints prevent duplicate data
- Indexes optimize query performance

### PostgreSQL Features
- **UUID Primary Keys**: Globally unique identifiers
- **Timestamp with Timezone**: Proper timezone handling
- **Numeric Precision**: Accurate decimal calculations for progress percentages
- **JSON Support**: Ready for future schema-less data storage
- **Full-Text Search**: Available for content search capabilities

---

## Performance Considerations

### Indexing Strategy
- Primary key indexes (automatic)
- Foreign key indexes for join performance  
- Unique constraints for data integrity
- Composite indexes for common query patterns
- Filtered indexes for soft delete patterns

### Query Optimization
- Soft delete filtering in all queries (`WHERE is_deleted = FALSE`)
- Efficient joins through proper foreign key relationships
- Pagination support for large result sets
- Materialized views potential for complex analytics

### Scalability Features
- UUID-based sharding support
- Read replica compatibility
- Connection pooling ready
- Horizontal scaling preparation through proper normalization

---

## Migration History

### Version: 20250910193406_CreateDatabaseSchema
- **Status**: Applied
- **Description**: Initial database schema creation with all core entities
- **Features**: Complete audit trails, soft delete patterns, referential integrity
- **Seed Data**: Comprehensive test data for all entities

### Future Migrations
- Additional indexes for performance optimization
- New entities for advanced features (badges, notifications, integrations)
- Schema refinements based on usage patterns
- Data retention and archival policies

This database schema provides a robust foundation for the CPR platform with comprehensive audit trails, proper relationships, and scalable design patterns suitable for enterprise deployment.

**Note**: Comprehensive seed data is automatically provided through the `DatabaseSeeder.cs` service, which creates sample users, roles, departments, career framework, skills, projects, and organizational hierarchies in Development and Test environments.