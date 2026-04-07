# Feature 0010 — Schema Changes

## Modified Tables

### employee_to_skill

**Changes:**
- Rename column `persist_value` → `self_assessment_value`; change nullability to `NOT NULL` with a temporary default of `0` for migration.
- Add column `manager_assessment_value NUMERIC NULL`.
- Drop column `source`.
- Drop column `is_target`.
- Replace unique index `UX_employee_to_skill_employee_skill_effective` (on `employee_id, skill_id, effective_date`) with `UX_employee_to_skill_employee_skill` (on `employee_id, skill_id`) — because removing `is_target` means only one assessment row per employee+skill is valid.

**Table after migration:**
```sql
CREATE TABLE employee_to_skill (
    id                       UUID        PRIMARY KEY,
    employee_id              UUID        NOT NULL REFERENCES employees(id),
    skill_id                 UUID        NOT NULL REFERENCES skills(id),
    skill_level_id           UUID        REFERENCES skill_levels(id),
    self_assessment_value    NUMERIC     NOT NULL DEFAULT 0,
    manager_assessment_value NUMERIC     NULL,
    effective_date           TIMESTAMPTZ NULL,
    notes                    TEXT        NULL,
    -- Audit columns
);

CREATE INDEX IX_employee_to_skill_employee_id       ON employee_to_skill(employee_id);
CREATE INDEX IX_employee_to_skill_skill_id          ON employee_to_skill(skill_id);
CREATE INDEX IX_employee_to_skill_skill_level_id    ON employee_to_skill(skill_level_id);
CREATE UNIQUE INDEX UX_employee_to_skill_employee_skill
    ON employee_to_skill(employee_id, skill_id)
    WHERE is_deleted = FALSE;
```

---

### position_to_skill

**Changes:**
- Drop column `weight`.

**Table after migration:**
```sql
CREATE TABLE position_to_skill (
    id              UUID     PRIMARY KEY,
    position_id     UUID     NOT NULL REFERENCES positions(id),
    skill_id        UUID     NOT NULL REFERENCES skills(id),
    skill_level_id  UUID     NOT NULL REFERENCES skill_levels(id),
    is_mandatory    BOOLEAN  DEFAULT FALSE,
    rationale       TEXT     NULL,
    -- Audit columns
);

CREATE INDEX IX_position_to_skill_position_id    ON position_to_skill(position_id);
CREATE INDEX IX_position_to_skill_skill_id       ON position_to_skill(skill_id);
CREATE INDEX IX_position_to_skill_skill_level_id ON position_to_skill(skill_level_id);
CREATE UNIQUE INDEX UX_position_to_skill_position_skill
    ON position_to_skill(position_id, skill_id);
```

---

## Migration SQL

### Up

```sql
-- Step 1: Remove target-assessment rows (is_target = TRUE) — no longer needed
DELETE FROM employee_to_skill WHERE is_target = TRUE;

-- Step 2: Provide a default for rows where persist_value is NULL before making NOT NULL
UPDATE employee_to_skill SET persist_value = 0 WHERE persist_value IS NULL;

-- Step 3: Rename persist_value → self_assessment_value and enforce NOT NULL
ALTER TABLE employee_to_skill
    RENAME COLUMN persist_value TO self_assessment_value;

ALTER TABLE employee_to_skill
    ALTER COLUMN self_assessment_value SET NOT NULL,
    ALTER COLUMN self_assessment_value SET DEFAULT 0;

-- Step 4: Add manager_assessment_value
ALTER TABLE employee_to_skill
    ADD COLUMN manager_assessment_value NUMERIC NULL;

-- Step 5: Drop the 0007 partial index that references source and is_target
-- (must be dropped before the columns are removed)
DROP INDEX IF EXISTS UX_employee_to_skill_self;

-- Step 5b: Drop deprecated columns
ALTER TABLE employee_to_skill
    DROP COLUMN source,
    DROP COLUMN is_target;

-- Step 6: Replace the compound unique index with a simpler per-employee-skill index
DROP INDEX IF EXISTS UX_employee_to_skill_employee_skill_effective;

CREATE UNIQUE INDEX UX_employee_to_skill_employee_skill
    ON employee_to_skill(employee_id, skill_id)
    WHERE is_deleted = FALSE;

-- Step 7: Drop weight from position_to_skill
ALTER TABLE position_to_skill DROP COLUMN weight;
```

### Down (Rollback)

```sql
-- Restore weight on position_to_skill
ALTER TABLE position_to_skill ADD COLUMN weight NUMERIC NULL;

-- Restore columns on employee_to_skill
ALTER TABLE employee_to_skill
    ADD COLUMN is_target BOOLEAN NOT NULL DEFAULT FALSE,
    ADD COLUMN source    TEXT    NULL;

-- Drop the new simple unique index
DROP INDEX IF EXISTS UX_employee_to_skill_employee_skill;

-- Restore the original compound unique index
CREATE UNIQUE INDEX UX_employee_to_skill_employee_skill_effective
    ON employee_to_skill(employee_id, skill_id, effective_date);

-- Drop manager_assessment_value
ALTER TABLE employee_to_skill DROP COLUMN manager_assessment_value;

-- Rename self_assessment_value back to persist_value and make nullable
ALTER TABLE employee_to_skill
    RENAME COLUMN self_assessment_value TO persist_value;

ALTER TABLE employee_to_skill
    ALTER COLUMN persist_value DROP NOT NULL,
    ALTER COLUMN persist_value DROP DEFAULT;
```

---

## Existing Table — employee_skill_evidence (no changes, documentation only)

This table already exists in the DB (migration `20260301000001_AddSkillAssessmentSchema`) but is missing from `data.md`. It must be added there as part of this feature.

```sql
CREATE TABLE employee_skill_evidence (
    id                   UUID  PRIMARY KEY,
    employee_to_skill_id UUID  NOT NULL REFERENCES employee_to_skill(id),
    feedback_id          UUID  NOT NULL REFERENCES feedback(id),
    -- Audit columns
);

CREATE INDEX IX_employee_skill_evidence_employee_to_skill_id
    ON employee_skill_evidence(employee_to_skill_id);

CREATE UNIQUE INDEX UX_employee_skill_evidence_assessment_feedback
    ON employee_skill_evidence(employee_to_skill_id, feedback_id);
```

**Purpose:** Links a skill assessment row to one or more feedback items as supporting evidence. One row per (assessment, feedback) pair. Soft-deleted via `is_deleted` like all other tables.

---

## data.md Updates Required

Update `employee_to_skill` block:
- Remove `persist_value`, `source`, `is_target` entries.
- Add `self_assessment_value NUMERIC NOT NULL DEFAULT 0` and `manager_assessment_value NUMERIC NULL`.
- Update unique index to `UX_employee_to_skill_employee_skill ON employee_to_skill(employee_id, skill_id) WHERE is_deleted = FALSE`.

Update `position_to_skill` block:
- Remove `weight NUMERIC NULL` line.

Add new `employee_skill_evidence` block (see definition above) under the Skills & Assessment section.
