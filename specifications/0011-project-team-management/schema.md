# Schema Migrations — Project Team Management (0011)

## Migration: 0011_AddProjectLifecycleAndAssignmentDates

No new tables are introduced. This migration adds lifecycle columns to `projects` and date-range columns to `project_teams`.

---

### Modified Tables

#### `projects` — Added columns

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `status` | `text` | No | `'draft'` | Enum: `draft`, `active`, `completed`, `archived` |
| `start_date` | `date` | Yes | `null` | Project start date |
| `end_date` | `date` | Yes | `null` | Project end date; must be >= `start_date` when both set |

```sql
ALTER TABLE projects
    ADD COLUMN status     TEXT  NOT NULL DEFAULT 'draft',
    ADD COLUMN start_date DATE  NULL,
    ADD COLUMN end_date   DATE  NULL;

-- Constrain status to valid values
ALTER TABLE projects
    ADD CONSTRAINT CK_projects_status
    CHECK (status IN ('draft', 'active', 'completed', 'archived'));

-- Enforce end_date >= start_date at DB level
ALTER TABLE projects
    ADD CONSTRAINT CK_projects_date_range
    CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date);

CREATE INDEX IX_projects_status ON projects(status) WHERE is_deleted = FALSE;
```

---

#### `project_teams` — Added columns

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `start_date` | `date` | Yes | `null` | Assignment start date |
| `end_date` | `date` | Yes | `null` | Assignment end date; must be >= `start_date` when both set |

```sql
ALTER TABLE project_teams
    ADD COLUMN start_date DATE NULL,
    ADD COLUMN end_date   DATE NULL;

ALTER TABLE project_teams
    ADD CONSTRAINT CK_project_teams_date_range
    CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date);
```

The existing unique index `UX_project_teams_role_employee` (on `project_role_id, employee_id`) must be **dropped** — it enforces one assignment per employee per role globally, but after this migration multiple non-overlapping assignments are permitted.

```sql
DROP INDEX IF EXISTS UX_project_teams_role_employee;
```

Overlap enforcement is implemented in application code (not at the DB layer), because date-range exclusion constraints require the `btree_gist` extension which may not be available in all environments.

---

### Rollback

```sql
-- Remove project_teams changes
ALTER TABLE project_teams
    DROP CONSTRAINT IF EXISTS CK_project_teams_date_range,
    DROP COLUMN IF EXISTS start_date,
    DROP COLUMN IF EXISTS end_date;

-- Restore original unique index
CREATE UNIQUE INDEX UX_project_teams_role_employee
    ON project_teams(project_role_id, employee_id);

-- Remove projects changes
DROP INDEX IF EXISTS IX_projects_status;

ALTER TABLE projects
    DROP CONSTRAINT IF EXISTS CK_projects_date_range,
    DROP CONSTRAINT IF EXISTS CK_projects_status,
    DROP COLUMN IF EXISTS status,
    DROP COLUMN IF EXISTS start_date,
    DROP COLUMN IF EXISTS end_date;
```
