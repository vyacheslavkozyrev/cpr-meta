# CPR Feature List

**Status legend**: ✅ Done · 🔄 Partial · ❌ Not started

---

## Goal Management

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F001 | Personal Goal Creation & Management | ✅ CRUD `/api/goals`, `/api/me/goals` | ❌ Placeholder | SDD spec: 0001 |
| F002 | Goal Task Management | ✅ `/api/goals/{id}/tasks` | ❌ | |
| F003 | Goal Progress Visualization | ❌ Basic only | ❌ Mock widgets | |

## Feedback System

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F004 | Feedback Request Management | ✅ incl. reminders, Hangfire, ICS | ✅ Substantial | Missing: manager team view. SDD spec: 0004 |
| F005 | Feedback Submission & Collection | ✅ `/api/feedback`, `/api/me/feedback` | ❌ Placeholder | SDD spec: 0005 |
| F006 | 360-Degree Feedback | 🔄 Multi-source supported | ❌ | |

## Skills & Development

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F007 | Skills Self-Assessment | ✅ `/api/me/skills` | ❌ Placeholder | |
| F008 | Skills Taxonomy & Career Framework | ✅ Full CRUD (paths, tracks, positions, skills) | ❌ | SDD spec: 0008 |
| F009 | Skills Gap Analysis & Development Planning | ❌ | ❌ | |

## Team Management

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F010 | Team Member Dashboard (Manager View) | ✅ `/api/team`, `/api/team/members/{id}`, `/api/team/goals` | ❌ Placeholder | |
| F011 | Project Team Management (Solution Owner) | ✅ Full project CRUD + team assignment | ❌ | |
| F012 | Org Hierarchy & Employee Directory | ✅ Data in DB | ❌ | |

## Analytics & Dashboards

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F013 | Personal Performance Dashboard | 🔄 Basic endpoints | 🔄 Mock widgets | Real data not wired |
| F014 | Performance Analytics & Reporting | ❌ | ❌ | |
| F015 | Manager Analytics Dashboard | ❌ | ❌ | |

## AI-Powered Features

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F016 | AI-Assisted Goal Setting | ❌ | ❌ | |
| F017 | AI-Assisted Feedback Generation | ❌ | ❌ | |
| F018 | Feedback Sentiment Analysis | ❌ | ❌ | |
| F019 | Predictive Analytics & Retention Risk | ❌ | ❌ | |

## Recognition & Rewards

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F020 | Achievement Badges | ❌ | ❌ | |
| F021 | Peer Recognition & Social Feedback | ❌ | ❌ | |

## User Account & Auth

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F022 | Authentication & Session Management | ✅ JWT + RBAC | 🔄 Entra integration in progress | |
| F023 | User Profile Management | ✅ `GET /api/me` | 🔄 Basic display only | |

## System Integration

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F024 | HRIS Integration & Employee Data Sync | ❌ | ❌ | |
| F025 | Learning Management System Integration | ❌ | ❌ | |

## Mobile & Accessibility

| # | Feature | API | UI | Notes |
|---|---------|-----|----|-------|
| F026 | Mobile-Responsive Interface | ✅ REST APIs mobile-ready | ✅ MUI responsive | |
| F027 | Accessibility & i18n | ✅ i18n data structures | 🔄 Framework in place, incomplete | |

---

## Summary

| Category | Total | API ✅ | UI ✅ | Fully Done |
|----------|-------|--------|--------|------------|
| Goal Management | 3 | 2 | 0 | 0 |
| Feedback System | 3 | 3 | 1 | 0 |
| Skills & Development | 3 | 2 | 0 | 0 |
| Team Management | 3 | 3 | 0 | 0 |
| Analytics & Dashboards | 3 | 1 | 0 | 0 |
| AI-Powered Features | 4 | 0 | 0 | 0 |
| Recognition & Rewards | 2 | 0 | 0 | 0 |
| User Account & Auth | 2 | 2 | 0 | 0 |
| System Integration | 2 | 0 | 0 | 0 |
| Mobile & Accessibility | 2 | 2 | 2 | 0 |
| **Total** | **27** | **15** | **3** | **0** |

**Key gap**: Strong API coverage (15/27 features) with minimal UI (3/27). Primary focus: build frontend for existing APIs.
