# Schema Migrations — Team Member Dashboard (0010a)

## Migration: 0010a_TeamMemberDashboard

---

### Modified Tables

#### `goals` — Added column

Adds a nullable foreign key to record which manager suggested a goal. Combined with the new `suggested` status value, this enables the suggested-goal workflow.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `suggested_by_id` | `uuid` | Yes | `null` | FK → `users.id`; populated when `status = 'suggested'` |

```sql
ALTER TABLE goals
    ADD COLUMN suggested_by_id UUID NULL REFERENCES users(id);

CREATE INDEX IX_goals_suggested_by_id ON goals (suggested_by_id)
    WHERE suggested_by_id IS NOT NULL;
```

#### `goals` — Extended status CHECK constraint

Adds `'suggested'` to the existing CHECK constraint on the `status` column (VARCHAR-based, as established in F001). The existing constraint is dropped and recreated with the expanded value set.

```sql
ALTER TABLE goals DROP CONSTRAINT IF EXISTS chk_goals_status;
ALTER TABLE goals ADD CONSTRAINT chk_goals_status
    CHECK (status IN ('not_started', 'in_progress', 'completed', 'on_hold', 'cancelled', 'suggested'));
```

> **Note**: `'achieved'` is not used — the canonical completion status is `'completed'`, aligned with F001's existing constraint and trigger.

---

### New Tables

#### `goal_deletion_requests`

Tracks employee-initiated deletion requests awaiting manager approval. One active (pending) request per goal at any time is enforced by the partial unique index.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | `uuid` | No | `gen_random_uuid()` | PK |
| `goal_id` | `uuid` | No | — | FK → `goals.id` |
| `requested_by_id` | `uuid` | No | — | FK → `users.id` — employee who requested deletion |
| `status` | `varchar(20)` | No | `'pending'` | `'pending'`, `'approved'`, `'rejected'` |
| `created_by` | `uuid` | No | — | Audit |
| `created_at` | `timestamptz` | No | `CURRENT_TIMESTAMP` | Audit |
| `modified_by` | `uuid` | Yes | `null` | Audit |
| `modified_at` | `timestamptz` | Yes | `null` | Audit |
| `is_deleted` | `boolean` | No | `FALSE` | Audit — soft delete flag |
| `deleted_by` | `uuid` | Yes | `null` | Audit |
| `deleted_at` | `timestamptz` | Yes | `null` | Audit |

**Indexes**
- `IX_goal_deletion_requests_goal_id` on `(goal_id)`
- `UQ_goal_deletion_requests_pending` unique partial on `(goal_id) WHERE status = 'pending' AND is_deleted = FALSE` — enforces one active request per goal

```sql
CREATE TABLE goal_deletion_requests (
    id               UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
    goal_id          UUID         NOT NULL REFERENCES goals(id),
    requested_by_id  UUID         NOT NULL REFERENCES users(id),
    status           VARCHAR(20)  NOT NULL DEFAULT 'pending'
                                  CHECK (status IN ('pending', 'approved', 'rejected')),
    -- audit columns
    created_by       UUID         NOT NULL,
    created_at       TIMESTAMPTZ  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by      UUID         NULL,
    modified_at      TIMESTAMPTZ  NULL,
    is_deleted       BOOLEAN      NOT NULL DEFAULT FALSE,
    deleted_by       UUID         NULL,
    deleted_at       TIMESTAMPTZ  NULL
);

CREATE INDEX IX_goal_deletion_requests_goal_id
    ON goal_deletion_requests (goal_id);

CREATE UNIQUE INDEX UQ_goal_deletion_requests_pending
    ON goal_deletion_requests (goal_id)
    WHERE status = 'pending' AND is_deleted = FALSE;
```

---

### Rollback

```sql
-- Remove new table
DROP TABLE IF EXISTS goal_deletion_requests;

-- Remove added column (safe only if no rows have suggested_by_id set)
ALTER TABLE goals DROP COLUMN IF EXISTS suggested_by_id;

-- Restore original CHECK constraint (safe only if no rows have status = 'suggested')
ALTER TABLE goals DROP CONSTRAINT IF EXISTS chk_goals_status;
ALTER TABLE goals ADD CONSTRAINT chk_goals_status
    CHECK (status IN ('not_started', 'in_progress', 'completed', 'on_hold', 'cancelled'));
```
