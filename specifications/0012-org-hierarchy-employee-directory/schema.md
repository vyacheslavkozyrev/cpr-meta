# Schema Migrations — Org Hierarchy & Employee Directory (0012)

## Migration: 0012_AddEmployeeDirectoryFields

No new tables. This feature adds contact and location columns to `users` and a hire date column to `employees`.

---

### Modified Tables

#### `users` — Added columns

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `phone` | `text` | Yes | `null` | Contact phone number |
| `avatar_url` | `text` | Yes | `null` | URL to profile avatar image |
| `location_id` | `uuid` | Yes | `null` | FK → `locations.id` |

```sql
ALTER TABLE users ADD COLUMN phone       TEXT NULL;
ALTER TABLE users ADD COLUMN avatar_url  TEXT NULL;
ALTER TABLE users ADD COLUMN location_id UUID NULL REFERENCES locations(id);

CREATE INDEX IX_users_location_id ON users (location_id);
```

---

#### `employees` — Added columns

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `hire_date` | `date` | Yes | `null` | Date the employee joined the company |

```sql
ALTER TABLE employees ADD COLUMN hire_date DATE NULL;
```

---

### Rollback

```sql
ALTER TABLE users DROP COLUMN IF EXISTS phone;
ALTER TABLE users DROP COLUMN IF EXISTS avatar_url;
DROP INDEX IF EXISTS IX_users_location_id;
ALTER TABLE users DROP COLUMN IF EXISTS location_id;

ALTER TABLE employees DROP COLUMN IF EXISTS hire_date;
```
