# User Stories — Skills Taxonomy & Career Framework (0008)

## Out of Scope

The following are explicitly **not** part of this feature:

- Employee self-assessment against skills (separate feature)
- Skill gap analysis and reporting for managers, directors, and solution owners (separate feature)
- Display of an employee's current position within the career framework (handled by the self-assessment / gap analysis feature)
- Team-level or org-level skill gap reporting (separate feature)
- Deletion of career paths, career tracks, positions, or skill categories via the UI (soft-delete is only exposed for skills and position-to-skill mappings in this feature)
- Bulk import or export of taxonomy data
- Versioned history / change audit of taxonomy edits (standard audit columns in DB are sufficient)

---

## Stories

### US-001: Browse Career Paths

**As an** authenticated user (any role)
**I want to** view the list of all active career paths
**So that** I can understand the company's career framework at a high level

#### Acceptance Criteria

- [ ] AC-001: The career paths page lists all career paths where `is_deleted = false`, showing title and description for each.
- [ ] AC-002: Career paths are sorted alphabetically by title.
- [ ] AC-003: An empty state message is displayed when no active career paths exist.
- [ ] AC-004: Each career path entry is clickable and navigates to the career path detail view.

---

### US-002: View Career Path Detail with Tracks

**As an** authenticated user (any role)
**I want to** view a career path and its associated career tracks
**So that** I can explore which specific tracks are available within a path

#### Acceptance Criteria

- [ ] AC-005: The career path detail displays the path title, description, and a list of all active career tracks belonging to it (`is_deleted = false`).
- [ ] AC-006: Each career track is shown with its title and description.
- [ ] AC-007: Each track is clickable and navigates to the career track detail view.
- [ ] AC-008: An empty state is displayed if the career path has no active tracks.

---

### US-003: View Career Track with Position Progression Ladder

**As an** authenticated user (any role)
**I want to** view a career track's positions displayed as a progression ladder
**So that** I can understand the seniority levels and advancement opportunities within that track

#### Acceptance Criteria

- [ ] AC-009: The career track detail displays the track title, description, and all active positions (`is_deleted = false`) belonging to that track.
- [ ] AC-010: Positions are displayed in a visual vertical progression ladder (bottom = most junior, top = most senior), ordered by `sort_order` ascending (lower value = more junior); positions with equal `sort_order` are sorted alphabetically by title as a tiebreaker.
- [ ] AC-011: Each position card shows title, description, and expectations (truncated to 3 lines with expand option if long).
- [ ] AC-012: Clicking a position card navigates to the position detail view.

---

### US-004: View Position Detail with Skill Spider Web Diagram

**As an** authenticated user (any role)
**I want to** view a position's required skills in a spider web (radar) diagram
**So that** I can understand which skills and proficiency levels are needed for that position

#### Acceptance Criteria

- [ ] AC-013: The position detail displays the position title, description, expectations, and its parent career track name (with a breadcrumb back to the track).
- [ ] AC-014: A radar/spider chart is rendered showing all active required skills for the position; each axis represents one skill, with the axis value representing the required skill level value (1–5).
- [ ] AC-015: Skills are grouped by skill category in the chart; each category uses a distinct colour.
- [ ] AC-016: Mandatory skills are visually distinguished from optional skills in the chart (e.g. solid vs. dashed axis or a legend marker).
- [ ] AC-017: A sortable table below the chart lists all active required skills with columns: Category, Skill, Required Level (title + value), Mandatory, Weight, Rationale.
- [ ] AC-018: Skills whose `is_deleted = true` are excluded from both the chart and the table.

---

### US-005: View Skill Detail

**As an** authenticated user (any role)
**I want to** view a skill's description and its proficiency levels
**So that** I can understand what each level of that skill entails

#### Acceptance Criteria

- [ ] AC-019: The skill detail panel/page shows the skill title, description, and its parent skill category.
- [ ] AC-020: Proficiency levels are listed in ascending order by value (1–5), each showing the level title and description.

---

### US-006: Manage Career Paths

**As an** Administrator
**I want to** create and edit career paths
**So that** I can maintain the top-level career framework taxonomy

#### Acceptance Criteria

- [ ] AC-021: Administrator can create a career path with a required title (1–200 characters) and optional description (max 1000 characters).
- [ ] AC-022: Administrator can edit the title and description of an existing career path.
- [ ] AC-023: A duplicate title (case-insensitive) is rejected with a validation error (`errors.validation.title_duplicate`).
- [ ] AC-024: Changes are saved immediately and reflected in the read-only view for all users.

---

### US-007: Manage Career Tracks

**As an** Administrator
**I want to** create and edit career tracks within career paths
**So that** I can define the specific tracks available in each career path

#### Acceptance Criteria

- [ ] AC-025: Administrator can create a career track with a required title (1–200 characters), optional description (max 1000 characters), and a required association to an existing active career path.
- [ ] AC-026: Administrator can edit the title, description, and parent career path of an existing career track.
- [ ] AC-027: Selecting a deleted or non-existent career path is rejected with a validation error.
- [ ] AC-028: Changes are saved immediately and reflected in the read-only view for all users.

---

### US-008: Manage Positions

**As an** Administrator
**I want to** create and edit positions within career tracks
**So that** I can define the job positions and their expectations

#### Acceptance Criteria

- [ ] AC-029: Administrator can create a position with a required title (1–200 characters), optional description (max 2000 characters), optional expectations (max 2000 characters), optional `sort_order` (non-negative integer, default 0), and a required association to an existing active career track.
- [ ] AC-030: Administrator can edit the title, description, expectations, `sort_order`, and parent career track of an existing position.
- [ ] AC-031: Changes are saved immediately and reflected in the progression ladder and position detail views.

---

### US-009: Manage Skill Categories

**As an** Administrator
**I want to** create and edit skill categories
**So that** I can organise skills into meaningful groups for the spider web diagram

#### Acceptance Criteria

- [ ] AC-032: Administrator can create a skill category with a required title (1–200 characters) and optional description (max 1000 characters).
- [ ] AC-033: Administrator can edit the title and description of an existing skill category.
- [ ] AC-034: A duplicate category title (case-insensitive) is rejected with a validation error (`errors.validation.title_duplicate`).

---

### US-010: Manage Skills and Proficiency Levels

**As an** Administrator
**I want to** create, edit, and soft-delete skills along with their proficiency levels
**So that** I can maintain the skill library used across the career taxonomy

#### Acceptance Criteria

- [ ] AC-035: Administrator can create a skill with a required title (1–200 characters), optional description (max 1000 characters), and a required skill category.
- [ ] AC-036: Administrator can add proficiency levels to a skill, each requiring a unique value (integer 1–5), a required title (1–100 characters), and optional description (max 500 characters); no duplicate values per skill.
- [ ] AC-037: Administrator can edit a skill's title, description, and category.
- [ ] AC-038: Administrator can edit a proficiency level's title, description, and value (value must remain unique within the skill).
- [ ] AC-039: Administrator can soft-delete a skill; the skill is marked `is_deleted = true` in the DB and is immediately excluded from all read-only views (career path browsing, position skill requirements), but existing employee records that reference the skill are unaffected in the DB.
- [ ] AC-040: Administrator cannot soft-delete an individual proficiency level while its parent skill is active; proficiency levels are managed only via the parent skill.

---

### US-011: Manage Position Skill Requirements

**As an** Administrator
**I want to** add, edit, and remove skill requirements for a position
**So that** I can define which skills and proficiency levels are needed for each position

#### Acceptance Criteria

- [ ] AC-041: Administrator can add a skill requirement to a position specifying: skill (required, must be active), required skill level (required, must belong to the selected skill), mandatory flag (required, default `false`), weight (optional, positive decimal), and rationale (optional, max 500 characters).
- [ ] AC-042: Only one skill requirement per skill per position is permitted; adding a duplicate is rejected with a validation error (`errors.validation.skill_already_assigned`).
- [ ] AC-043: Administrator can edit the required skill level, mandatory flag, weight, and rationale of an existing position-to-skill entry.
- [ ] AC-044: Administrator can soft-delete a position-to-skill entry; the skill requirement no longer appears in the position detail view.
- [ ] AC-045: Attempting to add a soft-deleted skill as a position requirement is rejected with a validation error (`errors.validation.skill_deleted`).
