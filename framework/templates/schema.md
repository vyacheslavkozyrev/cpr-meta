# Schema Migrations — [Feature Name] ([####])

## Migration: [####]_[MigrationName]

### New Tables

#### `table_name`

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | `uuid` | No | `gen_random_uuid()` | PK |
| `user_id` | `uuid` | No | — | FK → users.id |
| `name` | `text` | No | — | |
| `created_by` | `uuid` | No | — | Audit — actor who created the row |
| `created_at` | `timestamptz` | No | `CURRENT_TIMESTAMP` | Audit |
| `modified_by` | `uuid` | Yes | `null` | Audit — actor who last modified |
| `modified_at` | `timestamptz` | Yes | `null` | Audit |
| `is_deleted` | `boolean` | No | `FALSE` | Audit — soft delete flag |
| `deleted_by` | `uuid` | Yes | `null` | Audit |
| `deleted_at` | `timestamptz` | Yes | `null` | Audit |

**Indexes**
- `IX_table_name_user_id` on `(user_id)`
- `IX_table_name_is_deleted` partial: `WHERE is_deleted = FALSE`

```sql
CREATE TABLE table_name (
    id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id     UUID        NOT NULL REFERENCES users(id),
    name        TEXT        NOT NULL,
    -- audit columns (required on every table)
    created_by  UUID        NOT NULL,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by UUID        NULL,
    modified_at TIMESTAMPTZ NULL,
    is_deleted  BOOLEAN     NOT NULL DEFAULT FALSE,
    deleted_by  UUID        NULL,
    deleted_at  TIMESTAMPTZ NULL
);

CREATE INDEX IX_table_name_user_id ON table_name (user_id);
CREATE INDEX IX_table_name_is_deleted ON table_name (is_deleted) WHERE is_deleted = FALSE;
```

---

### Modified Tables

#### `existing_table` — Added columns

| Column | Type | Nullable | Default |
|--------|------|----------|---------|
| `new_column` | `text` | Yes | `null` |

```sql
ALTER TABLE existing_table ADD COLUMN new_column TEXT;
```

---

### Rollback

```sql
DROP TABLE IF EXISTS table_name;
ALTER TABLE existing_table DROP COLUMN IF EXISTS new_column;
```
