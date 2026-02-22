# CPR — Continuous Performance Review Platform

CPR replaces traditional annual performance reviews with a continuous, data-driven cycle: employees set SMART goals, collect ongoing peer/manager feedback, track skill development, and build a documented record of achievements — all surfaced into automated review summaries that reduce administrative burden for managers.

---

## Core Concept

- **Continuous feedback** over sporadic annual reviews
- **Goal tracking** linked to skills, career paths, and org objectives
- **AI assistance** for goal setting, feedback generation, and sentiment analysis
- **Performance summaries** auto-generated from accumulated goals, feedback, and skill data
- **Recognition** via achievement badges and peer appreciation

---

## Key Design Decisions

These decisions affect authorization logic, data access, and UX — reference when implementing related features.

### Organizational Visibility
- Managers see their **direct reports and their direct reports' profiles** (two levels deep)
- Solution Owners / Project Managers see **all members of their project teams** regardless of reporting structure
- Directors see **org-wide** data

### Employee Data Lifecycle
- When an employee changes manager, the **new manager inherits full profile access** (continuity of performance history)
- When an employee leaves, their profile is **archived** (soft-deleted, not destroyed) with secure reactivation if they return

### Performance Evaluation
- Managers have **discretionary control** over weighting qualitative feedback vs. quantitative goal achievement — no fixed formula
- Evaluation approach can vary by role while staying consistent within a team

### Accessibility & i18n
- Target: **WCAG 2.1 AA** compliance
- Supported locales: `en`, `es`, `fr`, `be`
