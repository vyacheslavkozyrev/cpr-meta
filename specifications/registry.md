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

**Status**: Not Started
**Summary**: (Specification not yet created)
**Key entities**: —
**API endpoints**: —
**DB tables**: —
