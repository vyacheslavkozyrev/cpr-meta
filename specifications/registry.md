# Feature Registry

Compact reference used by the **Analyze** phase to detect conflicts across features.
One entry per feature. Updated at the end of each Specify phase.

---

## 0001 — Personal Goal Management

**Status**: Complete
**Summary**: Enables employees to create, track, and manage professional development goals using the SMART framework, with task decomposition, progress tracking, and visibility controls for both individual and manager oversight.
**Key entities**: `Goal`, `GoalTask`
**API endpoints**: POST /api/goals, GET /api/me/goals, GET /api/goals/{id}, PATCH /api/goals/{id}, DELETE /api/goals/{id}, POST /api/goals/{id}/tasks, PATCH /api/goals/{id}/tasks/{taskId}, DELETE /api/goals/{id}/tasks/{taskId}
**DB tables**: `goals`, `goal_tasks`

---

## 0004 — Feedback Request Management

**Status**: In Progress
**Summary**: Enables employees to proactively request structured feedback from colleagues and managers, with optional project/goal associations, a custom message, and an optional due date.
**Key entities**: `FeedbackRequest`
**API endpoints**: POST /api/feedback-requests, GET /api/me/feedback-requests
**DB tables**: `feedback_requests`

---

## 0005 — Feedback Submission & Collection

**Status**: In Progress
**Summary**: Enables employees to submit structured feedback to colleagues with 1–5 star ratings and comments tied to goals or projects, and to view received feedback with filtering, sorting, and analytics for performance review support.
**Key entities**: `Feedback`
**API endpoints**: POST /api/feedback, GET /api/me/feedback, GET /api/me/feedback/{id}, GET /api/me/feedback/analytics
**DB tables**: `feedback`

---

## 0008 — Skills Taxonomy & Career Framework

**Status**: In Progress
**Summary**: Enables all authenticated users to browse the company career framework (paths → tracks → positions) and view required skills per position via a radar/spider chart; gives Administrators full CRUD over career paths, tracks, positions, skill categories, skills, proficiency levels, and position skill requirements.
**Key entities**: `CareerPath`, `CareerTrack`, `Position`, `SkillCategory`, `Skill`, `SkillLevel`, `PositionToSkill`
**API endpoints**: GET /api/taxonomy/career-paths, GET /api/taxonomy/career-paths/{id}, GET /api/taxonomy/career-tracks, GET /api/taxonomy/career-tracks/{id}, GET /api/taxonomy/positions/{id}, GET /api/taxonomy/skill-categories, GET /api/taxonomy/skills, GET /api/taxonomy/skills/{id}, POST /api/taxonomy/career-paths, PATCH /api/taxonomy/career-paths/{id}, POST /api/taxonomy/career-tracks, PATCH /api/taxonomy/career-tracks/{id}, POST /api/taxonomy/positions, PATCH /api/taxonomy/positions/{id}, POST /api/taxonomy/skill-categories, PATCH /api/taxonomy/skill-categories/{id}, POST /api/taxonomy/skills, PATCH /api/taxonomy/skills/{id}, DELETE /api/taxonomy/skills/{id}, POST /api/taxonomy/skills/{id}/levels, PATCH /api/taxonomy/skills/{id}/levels/{level_id}, POST /api/taxonomy/positions/{id}/skills, PATCH /api/taxonomy/positions/{id}/skills/{position_skill_id}, DELETE /api/taxonomy/positions/{id}/skills/{position_skill_id}
**DB tables**: `career_paths`, `career_tracks`, `positions`, `skill_categories`, `skills`, `skill_levels`, `position_to_skill` (all existing — no new tables)

---

## 0006 — 360-Degree Feedback

**Status**: Complete
**Summary**: Enables Directors to create and manage 360-degree review cycles for employees in their department, with peer nominations by both the subject employee and their manager, reviewer feedback submission (1–5 rating + comments), and role-based results visibility (aggregated/anonymous for employees; full attributed detail for managers and directors).
**Key entities**: `ReviewCycle`, `ReviewNominee`, `ReviewResponse`
**API endpoints**: POST /api/review-cycles, GET /api/review-cycles, GET /api/review-cycles/{id}, PATCH /api/review-cycles/{id}/status, POST /api/review-cycles/{id}/nominees, DELETE /api/review-cycles/{id}/nominees/{nominee_id}, GET /api/review-cycles/{id}/nominees, POST /api/review-cycles/{id}/responses, GET /api/review-cycles/{id}/results, GET /api/me/review-requests
**DB tables**: `review_cycles`, `review_nominees`, `review_responses`
