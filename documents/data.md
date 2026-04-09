# CPR Database Schema

**Database**: PostgreSQL 15+ | **ORM**: EF Core (.NET 8) | **Migration**: `20250910193406_CreateDatabaseSchema`

---

## Conventions

- **PKs**: `id UUID PRIMARY KEY` on every table
- **FKs**: `{referenced_table}_id` (e.g., `user_id`, `manager_id`)
- **Indexes**: `IX_{table}_{column}`, unique: `UX_{table}_{column}`
- **Timestamps**: `TIMESTAMPTZ`; dates only: `DATE`

### Audit Columns (on every table via `AuditableEntity`)

```sql
created_by   UUID         NOT NULL
created_at   TIMESTAMPTZ  NOT NULL  DEFAULT CURRENT_TIMESTAMP
modified_by  UUID         NULL
modified_at  TIMESTAMPTZ  NULL
is_deleted   BOOLEAN      NOT NULL  DEFAULT FALSE
deleted_by   UUID         NULL
deleted_at   TIMESTAMPTZ  NULL
```

All queries filter `WHERE is_deleted = FALSE`. Never hard-delete — set `is_deleted = TRUE`.

---

## Core Tables

### users
```sql
CREATE TABLE users (
    id                 UUID         PRIMARY KEY,
    user_name          TEXT         NOT NULL,
    entra_external_id  TEXT         NULL,   -- Microsoft Entra External ID
    display_name       TEXT         NULL,
    -- Audit columns
);

CREATE UNIQUE INDEX UX_users_user_name ON users(user_name);
CREATE UNIQUE INDEX IX_users_entra_external_id ON users(entra_external_id) WHERE entra_external_id IS NOT NULL;
```

### roles
System roles: Employee, Manager, Solution Owner, Director, Administrator.
```sql
CREATE TABLE roles (
    id           UUID  PRIMARY KEY,
    title        TEXT  NOT NULL,
    description  TEXT  NULL,
    -- Audit columns
);
```

### user_to_role
```sql
CREATE TABLE user_to_role (
    id       UUID  PRIMARY KEY,
    user_id  UUID  NOT NULL REFERENCES users(id),
    role_id  UUID  NOT NULL REFERENCES roles(id),
    -- Audit columns
);

CREATE INDEX IX_user_to_role_user_id ON user_to_role(user_id);
CREATE INDEX IX_user_to_role_role_id ON user_to_role(role_id);
CREATE UNIQUE INDEX UX_user_to_role_user_role ON user_to_role(user_id, role_id);
```

### departments
```sql
CREATE TABLE departments (
    id                    UUID  PRIMARY KEY,
    name                  TEXT  NOT NULL,
    code                  TEXT  NULL,   -- e.g., "ENG", "HR"
    description           TEXT  NULL,
    parent_department_id  UUID  REFERENCES departments(id),
    manager_id            UUID  NULL,   -- circular ref to employees
    -- Audit columns
);
```

### locations
```sql
CREATE TABLE locations (
    id             UUID  PRIMARY KEY,
    name           TEXT  NOT NULL,
    address        TEXT  NULL,
    city           TEXT  NULL,
    region         TEXT  NULL,
    country        TEXT  NULL,
    postal_code    TEXT  NULL,
    timezone       TEXT  NULL,
    contact_phone  TEXT  NULL,
    -- Audit columns
);
```

---

## Career Framework

### career_paths
High-level paths: Engineering, Product, Design, etc.
```sql
CREATE TABLE career_paths (
    id           UUID  PRIMARY KEY,
    title        TEXT  NOT NULL,
    description  TEXT  NULL,
    -- Audit columns
);
```

### career_tracks
Specific tracks within a path: Backend Engineering, Frontend Engineering, etc.
```sql
CREATE TABLE career_tracks (
    id              UUID  PRIMARY KEY,
    title           TEXT  NOT NULL,
    description     TEXT  NULL,
    career_path_id  UUID  NOT NULL REFERENCES career_paths(id),
    -- Audit columns
);
```

### positions
Job positions within a track: Senior Software Engineer, etc.
```sql
CREATE TABLE positions (
    id               UUID  PRIMARY KEY,
    title            TEXT  NOT NULL,
    description      TEXT  NULL,
    expectations     TEXT  NULL,
    career_track_id  UUID  NOT NULL REFERENCES career_tracks(id),
    -- Audit columns
);
```

### employees
Links users to org structure.
```sql
CREATE TABLE employees (
    id             UUID  PRIMARY KEY,
    user_id        UUID  NOT NULL REFERENCES users(id),
    manager_id     UUID  REFERENCES employees(id),    -- self-referential
    position_id    UUID  REFERENCES positions(id),
    department_id  UUID  REFERENCES departments(id),
    -- Audit columns
);

CREATE INDEX IX_employees_user_id ON employees(user_id);
CREATE INDEX IX_employees_manager_id ON employees(manager_id);
CREATE INDEX IX_employees_position_id ON employees(position_id);
CREATE INDEX IX_employees_department_id ON employees(department_id);
```

---

## Skills & Assessment

### skill_categories
```sql
CREATE TABLE skill_categories (
    id           UUID  PRIMARY KEY,
    title        TEXT  NOT NULL,
    description  TEXT  NULL,
    -- Audit columns
);
```

### skills
```sql
CREATE TABLE skills (
    id           UUID  PRIMARY KEY,
    title        TEXT  NOT NULL,
    description  TEXT  NULL,
    category_id  UUID  NOT NULL REFERENCES skill_categories(id),
    -- Audit columns
);
```

### skill_levels
Proficiency levels per skill (e.g., Beginner=1 … Expert=5).
```sql
CREATE TABLE skill_levels (
    id           UUID     PRIMARY KEY,
    skill_id     UUID     NOT NULL REFERENCES skills(id),
    title        TEXT     NOT NULL,
    description  TEXT     NULL,
    value        INTEGER  NOT NULL,   -- 1–5
    -- Audit columns
);
```

### position_to_skill
Required skills and proficiency levels for a position.
```sql
CREATE TABLE position_to_skill (
    id              UUID     PRIMARY KEY,
    position_id     UUID     NOT NULL REFERENCES positions(id),
    skill_id        UUID     NOT NULL REFERENCES skills(id),
    skill_level_id  UUID     NOT NULL REFERENCES skill_levels(id),
    is_mandatory    BOOLEAN  DEFAULT FALSE,
    rationale       TEXT     NULL,
    -- Audit columns
    -- Note: weight column removed in feature 0010
);

CREATE INDEX IX_position_to_skill_position_id ON position_to_skill(position_id);
CREATE INDEX IX_position_to_skill_skill_id ON position_to_skill(skill_id);
CREATE INDEX IX_position_to_skill_skill_level_id ON position_to_skill(skill_level_id);
CREATE UNIQUE INDEX UX_position_to_skill_position_skill ON position_to_skill(position_id, skill_id);
```

### employee_to_skill
Employee skill assessments. Updated in feature 0010: `persist_value` renamed to `self_assessment_value` (NOT NULL),
`manager_assessment_value` added, `source` and `is_target` columns dropped.
```sql
CREATE TABLE employee_to_skill (
    id                       UUID        PRIMARY KEY,
    employee_id              UUID        NOT NULL REFERENCES employees(id),
    skill_id                 UUID        NOT NULL REFERENCES skills(id),
    skill_level_id           UUID        REFERENCES skill_levels(id),
    self_assessment_value    NUMERIC     NOT NULL DEFAULT 0,   -- employee's numeric self-rating
    manager_assessment_value NUMERIC     NULL,                 -- manager's numeric rating (nullable)
    effective_date           TIMESTAMPTZ NULL,
    notes                    TEXT        NULL,
    -- Audit columns
);

CREATE INDEX IX_employee_to_skill_employee_id ON employee_to_skill(employee_id);
CREATE INDEX IX_employee_to_skill_skill_id ON employee_to_skill(skill_id);
CREATE UNIQUE INDEX UX_employee_to_skill_employee_skill ON employee_to_skill(employee_id, skill_id) WHERE is_deleted = FALSE;
```

### employee_skill_evidence
Links a feedback item as supporting evidence for an employee's skill assessment.
```sql
CREATE TABLE employee_skill_evidence (
    id                  UUID PRIMARY KEY,
    employee_to_skill_id UUID NOT NULL REFERENCES employee_to_skill(id),
    feedback_id         UUID NOT NULL REFERENCES feedback(id),
    -- Audit columns
);

CREATE INDEX IX_employee_skill_evidence_employee_to_skill_id ON employee_skill_evidence(employee_to_skill_id);
CREATE INDEX IX_employee_skill_evidence_feedback_id ON employee_skill_evidence(feedback_id);
CREATE UNIQUE INDEX UX_employee_skill_evidence_skill_feedback ON employee_skill_evidence(employee_to_skill_id, feedback_id) WHERE is_deleted = FALSE;
```

---

## Goals & Performance

### goals
```sql
CREATE TABLE goals (
    id                     UUID          PRIMARY KEY,
    employee_id            UUID          NOT NULL REFERENCES employees(id),
    title                  TEXT          NOT NULL,
    description            TEXT          NULL,
    status                 TEXT          DEFAULT 'open',   -- open | in_progress | completed
    related_skill_id       UUID          REFERENCES skills(id),
    related_skill_level_id UUID          REFERENCES skill_levels(id),
    deadline               DATE          NULL,
    is_completed           BOOLEAN       DEFAULT FALSE,
    completed_at           TIMESTAMPTZ   NULL,
    progress_percent       NUMERIC(5,2)  DEFAULT 0.00,    -- 0.00–100.00
    priority               SMALLINT      NULL,
    visibility             TEXT          NULL,             -- private | team | organization
    -- Audit columns
);

CREATE INDEX IX_goals_employee_id ON goals(employee_id);
```

### goal_tasks
```sql
CREATE TABLE goal_tasks (
    id           UUID        PRIMARY KEY,
    goal_id      UUID        NOT NULL REFERENCES goals(id),
    title        TEXT        NOT NULL,
    description  TEXT        NULL,
    deadline     TIMESTAMPTZ NULL,
    is_completed BOOLEAN     DEFAULT FALSE,
    completed_at TIMESTAMPTZ NULL,
    -- Audit columns
);
```

---

## Feedback

### feedback_requests
```sql
CREATE TABLE feedback_requests (
    id            UUID        PRIMARY KEY,
    requestor_id  UUID        NOT NULL REFERENCES employees(id),  -- who requested
    employee_id   UUID        NOT NULL REFERENCES employees(id),  -- who should respond
    project_id    UUID        REFERENCES projects(id),
    goal_id       UUID        REFERENCES goals(id),
    message       TEXT        NULL,
    due_date      TIMESTAMPTZ NULL,
    -- Audit columns
);
```

### feedback
```sql
CREATE TABLE feedback (
    id               UUID     PRIMARY KEY,
    goal_id          UUID     NOT NULL REFERENCES goals(id),
    project_id       UUID     REFERENCES projects(id),
    from_employee_id UUID     NOT NULL REFERENCES employees(id),
    to_employee_id   UUID     NOT NULL REFERENCES employees(id),
    content          TEXT     NOT NULL,
    rating           INTEGER  NULL,
    -- Audit columns
);
```

---

## Projects

### projects
```sql
CREATE TABLE projects (
    id           UUID  PRIMARY KEY,
    code         TEXT  NOT NULL UNIQUE,   -- e.g., "PRJ-001"
    title        TEXT  NOT NULL,
    description  TEXT  NULL,
    owner_id     UUID  REFERENCES employees(id),
    sponsor_id   UUID  REFERENCES employees(id),
    -- Audit columns
);

CREATE INDEX IX_projects_owner_id ON projects(owner_id);
CREATE INDEX IX_projects_sponsor_id ON projects(sponsor_id);
CREATE UNIQUE INDEX UX_projects_code ON projects(code);
```

### project_roles
Project-specific roles (Tech Lead, Product Manager, etc.).
```sql
CREATE TABLE project_roles (
    id           UUID  PRIMARY KEY,
    project_id   UUID  NOT NULL REFERENCES projects(id),
    title        TEXT  NOT NULL,
    description  TEXT  NULL,
    -- Audit columns
);
```

### project_teams
Employee assignments to project roles.
```sql
CREATE TABLE project_teams (
    id               UUID  PRIMARY KEY,
    project_role_id  UUID  NOT NULL REFERENCES project_roles(id),
    employee_id      UUID  NOT NULL REFERENCES employees(id),
    -- Audit columns
);

CREATE INDEX IX_project_teams_project_role_id ON project_teams(project_role_id);
CREATE INDEX IX_project_teams_employee_id ON project_teams(employee_id);
CREATE UNIQUE INDEX UX_project_teams_role_employee ON project_teams(project_role_id, employee_id);
```

---

## Audit Logging

### audit_logs
```sql
CREATE TABLE audit_logs (
    id           UUID  PRIMARY KEY,
    actor_id     UUID  NULL,   -- user performing the action
    action       TEXT  NOT NULL,
    target_type  TEXT  NULL,   -- entity type affected
    target_id    UUID  NULL,   -- entity ID affected
    detail       TEXT  NULL,
    -- Audit columns
);
```

---

## Seed Data

Development and test environments are seeded via `DatabaseSeeder.cs` with sample users, roles, departments, career paths/tracks/positions, skills, projects, and org hierarchy.
