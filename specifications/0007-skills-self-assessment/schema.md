# Schema — Skills Self-Assessment (0007)

No new tables are introduced. This feature modifies two existing tables and adds one new table.

---

## Modified Tables

### positions — add `sort_order`

`sort_order` establishes the relative ordering of positions within a career track, enabling the "next position" chart dataset.

**Migration up**

```sql
ALTER TABLE positions
    ADD COLUMN sort_order INTEGER NOT NULL DEFAULT 0;

CREATE INDEX IX_positions_career_track_sort_order
    ON positions(career_track_id, sort_order);
```

**Rollback**

```sql
DROP INDEX IX_positions_career_track_sort_order;
ALTER TABLE positions DROP COLUMN sort_order;
```

---

### employee_to_skill — add `notes` + partial unique index

`notes` stores the free-text evidence/explanation added during self-assessment.

The partial unique index enforces that each employee has at most one current self-assessment and one target self-assessment per skill (preventing duplicate rows when auto-saving).

**Migration up**

```sql
ALTER TABLE employee_to_skill
    ADD COLUMN notes TEXT NULL;

-- Enforce one self-assessment record per (employee, skill, is_target)
CREATE UNIQUE INDEX UX_employee_to_skill_self
    ON employee_to_skill(employee_id, skill_id, is_target)
    WHERE source = 'self';
```

**Rollback**

```sql
DROP INDEX UX_employee_to_skill_self;
ALTER TABLE employee_to_skill DROP COLUMN notes;
```

---

## New Tables

### employee_skill_evidence

Links a self-assessment record to one or more received feedback items used as supporting evidence.

```sql
CREATE TABLE employee_skill_evidence (
    id                    UUID  PRIMARY KEY,
    employee_to_skill_id  UUID  NOT NULL REFERENCES employee_to_skill(id),
    feedback_id           UUID  NOT NULL REFERENCES feedback(id),
    -- Audit columns (created_by, created_at, modified_by, modified_at, is_deleted, deleted_by, deleted_at)
);

CREATE INDEX IX_employee_skill_evidence_assessment_id
    ON employee_skill_evidence(employee_to_skill_id);

CREATE UNIQUE INDEX UX_employee_skill_evidence_assessment_feedback
    ON employee_skill_evidence(employee_to_skill_id, feedback_id);
```

**Rollback**

```sql
DROP TABLE employee_skill_evidence;
```

---

## Column Reference

### positions (additions)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `sort_order` | INTEGER | NOT NULL | 0 | Ascending order within a career track; next position = lowest `sort_order` greater than current |

### employee_to_skill (additions)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `notes` | TEXT | NULL | — | Free-text evidence/notes from the employee (max enforced at API layer) |

### employee_skill_evidence (new table)

| Column | Type | Nullable | Default | Description |
|--------|------|----------|---------|-------------|
| `id` | UUID | NOT NULL | — | Primary key |
| `employee_to_skill_id` | UUID | NOT NULL | — | FK → `employee_to_skill.id` |
| `feedback_id` | UUID | NOT NULL | — | FK → `feedback.id` |
| + audit columns | | | | Standard `AuditableEntity` fields |

### Indexes

| Name | Table | Columns | Type |
|------|-------|---------|------|
| `IX_positions_career_track_sort_order` | `positions` | `(career_track_id, sort_order)` | B-tree |
| `UX_employee_to_skill_self` | `employee_to_skill` | `(employee_id, skill_id, is_target) WHERE source = 'self'` | Partial unique |
| `IX_employee_skill_evidence_assessment_id` | `employee_skill_evidence` | `(employee_to_skill_id)` | B-tree |
| `UX_employee_skill_evidence_assessment_feedback` | `employee_skill_evidence` | `(employee_to_skill_id, feedback_id)` | Unique |
