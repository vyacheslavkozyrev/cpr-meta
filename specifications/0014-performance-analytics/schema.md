# Schema Migrations — Performance Analytics & Reporting (0014)

## Migration: 0014_AddEmployeeSkillHistory

### New Tables

#### `employee_skill_history`

Records a snapshot of an employee's skill assessment values every time they change.
Rows are append-only and must never be modified or deleted.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | `uuid` | No | `gen_random_uuid()` | PK |
| `employee_id` | `uuid` | No | — | FK → employees.id |
| `skill_id` | `uuid` | No | — | FK → skills.id |
| `self_assessment_value` | `numeric` | No | — | Captured from `employee_to_skill.self_assessment_value` at the time of change |
| `manager_assessment_value` | `numeric` | Yes | `null` | Captured from `employee_to_skill.manager_assessment_value`; null if not yet assessed by manager |
| `recorded_at` | `timestamptz` | No | `CURRENT_TIMESTAMP` | When the change occurred (set by application at write time) |
| `created_by` | `uuid` | No | — | Audit — actor who triggered the change |
| `created_at` | `timestamptz` | No | `CURRENT_TIMESTAMP` | Audit |
| `modified_by` | `uuid` | Yes | `null` | Audit |
| `modified_at` | `timestamptz` | Yes | `null` | Audit |
| `is_deleted` | `boolean` | No | `FALSE` | Audit — must remain FALSE; history rows are never deleted |
| `deleted_by` | `uuid` | Yes | `null` | Audit |
| `deleted_at` | `timestamptz` | Yes | `null` | Audit |

**Indexes**

- `IX_employee_skill_history_employee_id` on `(employee_id)`
- `IX_employee_skill_history_skill_id` on `(skill_id)`
- `IX_employee_skill_history_employee_skill_recorded_at` on `(employee_id, skill_id, recorded_at)`

```sql
CREATE TABLE employee_skill_history (
    id                       UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    employee_id              UUID        NOT NULL REFERENCES employees(id),
    skill_id                 UUID        NOT NULL REFERENCES skills(id),
    self_assessment_value    NUMERIC     NOT NULL,
    manager_assessment_value NUMERIC     NULL,
    recorded_at              TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    -- audit columns (required on every table)
    created_by  UUID        NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by UUID        NULL,
    modified_at TIMESTAMPTZ NULL,
    is_deleted  BOOLEAN     NOT NULL DEFAULT FALSE,
    deleted_by  UUID        NULL,
    deleted_at  TIMESTAMPTZ NULL
);

CREATE INDEX IX_employee_skill_history_employee_id
    ON employee_skill_history (employee_id);

CREATE INDEX IX_employee_skill_history_skill_id
    ON employee_skill_history (skill_id);

CREATE INDEX IX_employee_skill_history_employee_skill_recorded_at
    ON employee_skill_history (employee_id, skill_id, recorded_at);
```

---

### Rollback

```sql
DROP TABLE IF EXISTS employee_skill_history;
```
