# Feature 0010 — Progress

## Phase Status

| Phase | Status | Date | Notes |
|-------|--------|------|-------|
| Specify | ✅ Complete | 2026-03-10 | |
| Analyze | ✅ Complete | 2026-03-10 | PASS — all conflicts resolved via spec amendments |
| Plan | ✅ Complete | 2026-03-10 | 42 tasks across Migration→Domain→Infra→App→API→Config→UI→Test |
| Implement | ⏳ Pending | — | |
| Review | ⏳ Pending | — | |
| Test | ⏳ Pending | — | |

## Conflict Analysis

### Analyze — 2026-03-10

**Result**: PASS _(initially BLOCKED; all Criticals resolved 2026-03-10 via spec amendments to 0007, 0009, 0008)_

| Severity | Finding | Affected Feature | Resolution |
|----------|---------|-----------------|------------|
| Critical | `DROP COLUMN source` breaks 0007, which writes `source = 'self'` on every upsert and uses it in its partial unique index. 0009 reads `assessment_source` field derived from `source = 'manager'`. | 0007, 0009 | 0010 supersedes the `source` column. 0007 must remove all `source` references; 0009 must redefine "manager-approved" as `manager_assessment_value IS NOT NULL`. Both must be amended before 0010 enters Plan. |
| Critical | `DROP COLUMN is_target` makes 0007 US-003 (Set Target Skill Level) unimplementable. 0007 writes `is_target = TRUE` for target records across three endpoints. | 0007 | 0010 decision: target level is replaced by `manager_assessment_value`. 0007 US-003 and AC-010–AC-013 must be formally moved out of scope before 0010 enters Plan. |
| Critical | `PUT /api/me/skill-assessment/skills/{skillId}` has contradictory contracts: 0007 requires `skill_level_id` (UUID FK); 0010 removes it and requires `self_assessment_value` (numeric). Response shapes also conflict (`skill_level_id/title/value` present in 0007, absent in 0010). | 0007 | 0010 contract supersedes 0007. 0007 api.md must be amended to the 0010 shape before 0010 enters Plan. |
| Critical | `PUT` and `DELETE /api/me/skill-assessment/skills/{skillId}/target` are fully specified in 0007 (US-003). 0010 removes them entirely (404). | 0007 | 0010 wins. 0007 US-003 must be dropped from scope. Decision recorded here. |
| Critical | 0007 schema.md defines `UX_employee_to_skill_self ON (employee_id, skill_id, is_target) WHERE source = 'self'`. The 0010 migration drops `is_target` and `source` without first dropping this index — will cause migration failure in environments where 0007 has been applied. | 0007 | Add `DROP INDEX IF EXISTS UX_employee_to_skill_self;` to 0010 schema.md migration Up, before Steps 5 (DROP COLUMN source/is_target). ✅ Added to schema.md. |
| Critical | 0008 is **Complete** (live code). Its taxonomy endpoints accept and return `weight` on position-skill items. 0010 drops `weight` from `position_to_skill`. This is an intentional breaking change to a live feature. | 0008 | Intentional. 0010 explicitly supersedes 0008's weight-related contracts (AC-017, AC-041, AC-043 in 0008). 0008 progress.md must be amended to note superseded ACs. Taxonomy UI weight column must be included in 0010 plan.md. |
| Major | 0009 `GET /api/me/gap-analysis` returns `assessment_source: "manager"` derived from `source = 'manager'`. After 0010 this column is gone; derivation must change to `manager_assessment_value IS NOT NULL`. | 0009 | Amend 0009 api.md: `assessment_source` is `"manager"` when `manager_assessment_value IS NOT NULL`, otherwise `"default"`. Update 0009 US-002 AC-010. |
| Major | 0007 GET response shape includes `target` object and `assessed.skill_level_id/title/value` — both removed by 0010. 0007 ACs AC-007, AC-011–AC-013 reference dropped columns. | 0007 | Amend 0007 api.md GET response to match 0010 SkillItem shape. Reword AC-007; drop AC-011–AC-013 from scope. |
| Major | 0008 AC-017 specifies a "Weight" column in the position detail skills table (live UI). 0010 US-007 removes weight entirely. | 0008 | 0010 plan.md must include a task to remove the Weight column from the position detail page UI component. Amend 0008 progress.md. |
| Minor | 0007 progress.md has an open Major conflict about `UX_employee_to_skill_employee_skill_effective` coexisting with the 0007-added index. 0010 explicitly replaces it with `UX_employee_to_skill_employee_skill` — this resolves the open finding. | 0007 | Update 0007 progress.md conflict entry to mark resolved by 0010. |
| Minor | 0009 US-001 AC-006 radar chart label "Actual Level (manager-approved)" maps to `source = 'manager'`; after 0010 it must map to `manager_assessment_value IS NOT NULL`. Terminology concern only. | 0009 | Covered by the Major finding above. Ensure 0009 UI implementation maps "Actual Level" to `manager_assessment_value` when non-null. |
| Minor | 0007 evidence endpoint pre-condition check (self-assessment row must exist before evidence can be linked) was expressed as `source = 'self', is_target = FALSE`. After 0010 the check simplifies to: `employee_to_skill` row exists for (employee, skill). No contract change. | 0007 | Informational. Implementors must use row-existence check instead of column-value check. |

## Amendments

_None._
