# User Stories — Skills Self-Assessment (0007)

## Out of Scope

The following are explicitly **not** part of this feature:

- Manager-initiated assessments (a manager setting skill levels on behalf of another employee)
- Peer skill assessments (source = 'peer' entries are owned by other features)
- Assessment approval or sign-off workflow (no manager confirmation step in this feature)
- Notifications when an assessment is submitted or changed
- Historical timeline of skill level changes (only the latest assessment per skill is retained)
- Bulk export of skill assessment data
- Skill gap recommendations or learning resource suggestions
- Side-by-side comparison of multiple employees' assessments
- Assessing skills that are not required by the user's current position
- Assigning or changing a user's position from this screen

---

## Stories

### US-001: View Skill Self-Assessment Dashboard

**As an** authenticated user (any role)
**I want to** see all skills required by my current position alongside my assessed and target levels
**So that** I have a clear overview of where I stand against my role's expectations

#### Acceptance Criteria

- [ ] AC-001: The page header displays the user's current position title, career track, and career path.
- [ ] AC-002: All skills required by the current position (via `position_to_skill`) are listed and grouped by `skill_category`.
- [ ] AC-003: Each skill row displays: skill title, skill description, required proficiency level title for the current position, the user's current self-assessed level (or "Not assessed"), and the user's target level (or "No target set").
- [ ] AC-004: The page is accessible to all authenticated roles.

---

### US-002: Self-Assess Current Skill Level

**As an** authenticated user (any role)
**I want to** record my current proficiency level for each skill required by my position
**So that** I have an accurate self-portrait of my skills for career development planning

#### Acceptance Criteria

- [ ] AC-005: For each required skill, a level selector lists all `skill_levels` defined for that skill, ordered by `value` ascending (lowest to highest).
- [ ] AC-006: Selecting a level immediately auto-saves the choice — no separate submit button is required.
- [ ] AC-007: The saved record is written to `employee_to_skill` with `source = 'self'` and `is_target = FALSE`.
- [ ] AC-008: If an assessment record already exists for the skill (`source = 'self'`, `is_target = FALSE`), it is updated in place (upsert); no duplicate history record is created.
- [ ] AC-009: A notes text field (max 1,000 characters) is available alongside each skill rating; the note auto-saves on field blur.

---

### US-003: Set Target Skill Level

**As an** authenticated user (any role)
**I want to** set a target proficiency level for each skill
**So that** I can communicate my development ambitions to my manager

#### Acceptance Criteria

- [ ] AC-010: For each required skill, a separate target level selector lists all `skill_levels` for that skill, ordered by `value` ascending.
- [ ] AC-011: Selecting a target level immediately auto-saves it as `source = 'self'`, `is_target = TRUE` in `employee_to_skill`.
- [ ] AC-012: The target level value must be strictly greater than the current self-assessed level value; if not, a validation message "Target level must be higher than your current level" is shown and the save is rejected.
- [ ] AC-013: A "Clear target" action removes the target-level record (`is_target = TRUE`) for the skill.

---

### US-004: View Radar Chart

**As an** authenticated user (any role)
**I want to** see a radar/spider chart comparing my self-assessed levels against my current and next position requirements
**So that** I can visually understand my skill gaps and progression path

#### Acceptance Criteria

- [ ] AC-014: A radar/spider chart renders on the assessment page with three labeled datasets:
  - **Dataset 1** (blue, solid): required proficiency values for the current position.
  - **Dataset 2** (green, solid): user's current self-assessed proficiency values (0 if not assessed).
  - **Dataset 3** (grey, dashed): required proficiency values for the next position in the career track (determined by the next higher `sort_order` in the same `career_track_id`).
- [ ] AC-015: If the user has no next position in their track (they hold the highest `sort_order`), Dataset 3 is omitted and a note "You are at the highest position in your track" appears near the chart.
- [ ] AC-016: Each chart axis corresponds to one skill required by the current position; axis labels show the skill title.
- [ ] AC-017: The chart updates in real-time as the user changes their self-assessed level without a page reload.

---

### US-005: Link Received Feedback as Evidence

**As an** authenticated user (any role)
**I want to** attach feedback I have received as evidence supporting my skill self-assessment
**So that** my self-rating is backed by external observations

#### Acceptance Criteria

- [ ] AC-018: For each skill, a "Link feedback" action opens a modal listing feedback items the current user has received (`to_employee_id = current employee`), showing sender name, rating, and a content excerpt.
- [ ] AC-019: The user can select one or more feedback items and attach them as evidence; each link is stored in `employee_skill_evidence`.
- [ ] AC-020: Feedback items already linked to the current skill are visually marked as selected in the modal and cannot be linked twice.
- [ ] AC-021: Attached feedback items are displayed below the skill row showing sender display name, star rating, and a truncated content excerpt (max 200 characters).
- [ ] AC-022: A "Remove" action on an evidence item unlinks it from the skill assessment (deletes the `employee_skill_evidence` record).

---

### US-006: PeopleManager Views Direct Reports' Assessments

**As a** PeopleManager
**I want to** see my direct reports' skill self-assessments
**So that** I can identify skill gaps and coaching opportunities across my team

#### Acceptance Criteria

- [ ] AC-023: A PeopleManager can navigate to a team skill overview page listing all direct reports (employees where `manager_id = current employee id`) with a summary row per person: name, position, count of assessed skills, and count of skills meeting the required level.
- [ ] AC-024: Clicking a direct report opens their full assessment page in **read-only** mode (no level selectors, no save or clear actions, no "Link feedback" action).
- [ ] AC-025: The read-only view shows the radar chart, all assessed skill levels with notes, and all linked feedback evidence items.

---

### US-007: Director and Administrator View Any Employee's Assessment

**As a** Director or Administrator
**I want to** view any employee's skill self-assessment
**So that** I can support organisation-level talent and succession decisions

#### Acceptance Criteria

- [ ] AC-026: A Director or Administrator can access any employee's skill assessment page in read-only mode via that employee's profile.
- [ ] AC-027: The read-only view is identical in layout and content to the manager read-only view (AC-024–AC-025).
