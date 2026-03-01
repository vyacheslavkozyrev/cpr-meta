# Schema Migrations — 360-Degree Feedback (0006)

## Migration: 0006_Create360DegreeFeedback

### New Tables

---

#### `review_cycles`

Represents a single 360 review cycle initiated by a Director for a subject employee.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | `uuid` | No | `gen_random_uuid()` | PK |
| `title` | `text` | No | — | Cycle name |
| `description` | `text` | Yes | `null` | Optional context |
| `subject_employee_id` | `uuid` | No | — | FK → `employees.id` — employee being reviewed |
| `department_id` | `uuid` | No | — | FK → `departments.id` — department context |
| `status` | `text` | No | `'draft'` | `draft` \| `open` \| `in_progress` \| `closed` |
| `opened_at` | `timestamptz` | Yes | `null` | Set when status → `open` |
| `started_at` | `timestamptz` | Yes | `null` | Set when status → `in_progress` |
| `closed_at` | `timestamptz` | Yes | `null` | Set when status → `closed` |
| `created_by` | `uuid` | No | — | Audit — Director who initiated |
| `created_at` | `timestamptz` | No | `CURRENT_TIMESTAMP` | Audit |
| `modified_by` | `uuid` | Yes | `null` | Audit |
| `modified_at` | `timestamptz` | Yes | `null` | Audit |
| `is_deleted` | `boolean` | No | `FALSE` | Audit — soft delete |
| `deleted_by` | `uuid` | Yes | `null` | Audit |
| `deleted_at` | `timestamptz` | Yes | `null` | Audit |

**Indexes**
- `IX_review_cycles_subject_employee_id` on `(subject_employee_id)`
- `IX_review_cycles_department_id` on `(department_id)`
- `IX_review_cycles_status` on `(status)`
- `IX_review_cycles_is_deleted` partial: `WHERE is_deleted = FALSE`

```sql
CREATE TABLE review_cycles (
    id                   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    title                TEXT        NOT NULL,
    description          TEXT        NULL,
    subject_employee_id  UUID        NOT NULL REFERENCES employees(id),
    department_id        UUID        NOT NULL REFERENCES departments(id),
    status               TEXT        NOT NULL DEFAULT 'draft',
    opened_at            TIMESTAMPTZ NULL,
    started_at           TIMESTAMPTZ NULL,
    closed_at            TIMESTAMPTZ NULL,
    -- audit columns
    created_by           UUID        NOT NULL,
    created_at           TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by          UUID        NULL,
    modified_at          TIMESTAMPTZ NULL,
    is_deleted           BOOLEAN     NOT NULL DEFAULT FALSE,
    deleted_by           UUID        NULL,
    deleted_at           TIMESTAMPTZ NULL
);

CREATE INDEX IX_review_cycles_subject_employee_id ON review_cycles (subject_employee_id);
CREATE INDEX IX_review_cycles_department_id ON review_cycles (department_id);
CREATE INDEX IX_review_cycles_status ON review_cycles (status);
CREATE INDEX IX_review_cycles_is_deleted ON review_cycles (is_deleted) WHERE is_deleted = FALSE;
```

---

#### `review_nominees`

Represents a reviewer nominated for a specific review cycle.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | `uuid` | No | `gen_random_uuid()` | PK |
| `cycle_id` | `uuid` | No | — | FK → `review_cycles.id` |
| `reviewer_employee_id` | `uuid` | No | — | FK → `employees.id` — the reviewer |
| `nominated_by` | `uuid` | No | — | FK → `employees.id` — who nominated them |
| `status` | `text` | No | `'pending'` | `pending` \| `invited` \| `submitted` |
| `created_by` | `uuid` | No | — | Audit |
| `created_at` | `timestamptz` | No | `CURRENT_TIMESTAMP` | Audit |
| `modified_by` | `uuid` | Yes | `null` | Audit |
| `modified_at` | `timestamptz` | Yes | `null` | Audit |
| `is_deleted` | `boolean` | No | `FALSE` | Audit — soft delete (used for removal) |
| `deleted_by` | `uuid` | Yes | `null` | Audit |
| `deleted_at` | `timestamptz` | Yes | `null` | Audit |

**Indexes**
- `IX_review_nominees_cycle_id` on `(cycle_id)`
- `IX_review_nominees_reviewer_employee_id` on `(reviewer_employee_id)`
- `UX_review_nominees_cycle_reviewer` unique on `(cycle_id, reviewer_employee_id)` `WHERE is_deleted = FALSE`
- `IX_review_nominees_is_deleted` partial: `WHERE is_deleted = FALSE`

```sql
CREATE TABLE review_nominees (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    cycle_id              UUID        NOT NULL REFERENCES review_cycles(id),
    reviewer_employee_id  UUID        NOT NULL REFERENCES employees(id),
    nominated_by          UUID        NOT NULL REFERENCES employees(id),
    status                TEXT        NOT NULL DEFAULT 'pending',
    -- audit columns
    created_by            UUID        NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by           UUID        NULL,
    modified_at           TIMESTAMPTZ NULL,
    is_deleted            BOOLEAN     NOT NULL DEFAULT FALSE,
    deleted_by            UUID        NULL,
    deleted_at            TIMESTAMPTZ NULL
);

CREATE INDEX IX_review_nominees_cycle_id ON review_nominees (cycle_id);
CREATE INDEX IX_review_nominees_reviewer_employee_id ON review_nominees (reviewer_employee_id);
CREATE UNIQUE INDEX UX_review_nominees_cycle_reviewer
    ON review_nominees (cycle_id, reviewer_employee_id)
    WHERE is_deleted = FALSE;
CREATE INDEX IX_review_nominees_is_deleted ON review_nominees (is_deleted) WHERE is_deleted = FALSE;
```

---

#### `review_responses`

Represents the feedback submission from a reviewer for a specific review cycle.

| Column | Type | Nullable | Default | Notes |
|--------|------|----------|---------|-------|
| `id` | `uuid` | No | `gen_random_uuid()` | PK |
| `cycle_id` | `uuid` | No | — | FK → `review_cycles.id` |
| `nominee_id` | `uuid` | No | — | FK → `review_nominees.id` |
| `reviewer_employee_id` | `uuid` | No | — | FK → `employees.id` — denormalised for query convenience |
| `overall_rating` | `smallint` | No | — | 1–5 inclusive |
| `comments` | `text` | No | — | 10–2000 characters |
| `created_by` | `uuid` | No | — | Audit |
| `created_at` | `timestamptz` | No | `CURRENT_TIMESTAMP` | Audit |
| `modified_by` | `uuid` | Yes | `null` | Audit |
| `modified_at` | `timestamptz` | Yes | `null` | Audit |
| `is_deleted` | `boolean` | No | `FALSE` | Audit — soft delete |
| `deleted_by` | `uuid` | Yes | `null` | Audit |
| `deleted_at` | `timestamptz` | Yes | `null` | Audit |

**Indexes**
- `IX_review_responses_cycle_id` on `(cycle_id)`
- `IX_review_responses_nominee_id` on `(nominee_id)`
- `UX_review_responses_nominee` unique on `(nominee_id)` `WHERE is_deleted = FALSE` — one response per nominee
- `IX_review_responses_is_deleted` partial: `WHERE is_deleted = FALSE`

**Constraints**
- `CHK_review_responses_overall_rating` — `overall_rating BETWEEN 1 AND 5`

```sql
CREATE TABLE review_responses (
    id                    UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    cycle_id              UUID        NOT NULL REFERENCES review_cycles(id),
    nominee_id            UUID        NOT NULL REFERENCES review_nominees(id),
    reviewer_employee_id  UUID        NOT NULL REFERENCES employees(id),
    overall_rating        SMALLINT    NOT NULL,
    comments              TEXT        NOT NULL,
    -- audit columns
    created_by            UUID        NOT NULL,
    created_at            TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,
    modified_by           UUID        NULL,
    modified_at           TIMESTAMPTZ NULL,
    is_deleted            BOOLEAN     NOT NULL DEFAULT FALSE,
    deleted_by            UUID        NULL,
    deleted_at            TIMESTAMPTZ NULL,
    CONSTRAINT CHK_review_responses_overall_rating CHECK (overall_rating BETWEEN 1 AND 5)
);

CREATE INDEX IX_review_responses_cycle_id ON review_responses (cycle_id);
CREATE INDEX IX_review_responses_nominee_id ON review_responses (nominee_id);
CREATE UNIQUE INDEX UX_review_responses_nominee
    ON review_responses (nominee_id)
    WHERE is_deleted = FALSE;
CREATE INDEX IX_review_responses_is_deleted ON review_responses (is_deleted) WHERE is_deleted = FALSE;
```

---

### Rollback

```sql
DROP TABLE IF EXISTS review_responses;
DROP TABLE IF EXISTS review_nominees;
DROP TABLE IF EXISTS review_cycles;
```
