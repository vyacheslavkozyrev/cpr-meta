# CPR Platform Architecture

CPR is a **modular monolith**: .NET 8 Web API backend + React 18 SPA frontend, deployed via Docker on Azure.

---

## Backend (CPR-API)

### Technology Stack

- **Runtime**: .NET 8 (targeting .NET 9)
- **Web Framework**: ASP.NET Core Web API
- **Data Access**: Entity Framework Core + Migrations
- **Database**: PostgreSQL (containerized)
- **Authentication**: Microsoft Entra External ID — OAuth2/OIDC + JWT
- **Deployment**: Docker; GitHub Container Registry (GHCR); GitHub Actions CI/CD

### Clean Architecture Layers

```
CPR.Api            — Controllers (thin, HTTP only), DTOs, Middleware (auth, CORS, logging, error handling)
    ↓
CPR.Application    — CQRS Command/Query handlers, business workflows, AI & integration service interfaces
    ↓
CPR.Domain         — Entities, Value Objects, Domain Events, Repository interfaces, Domain Services
    ↓
CPR.Infrastructure — EF Core DbContext + Repositories, AI services, external integrations, caching, notifications
```

### Key Patterns

- **CQRS** — separate Commands (writes) from Queries (reads); optimized query paths for reporting
- **Repository Pattern** — abstract data access behind interfaces; testable without a live database
- **Domain Events** — decouple side effects (notifications, audit trail) from core business logic
- **Dependency Injection** — interface-based design throughout; configuration-driven implementations

### Project Structure

```
cpr-api/src/
├── CPR.Api/            Controllers/, Middleware/, DTOs/, Program.cs
├── CPR.Application/    Commands/, Queries/, Handlers/, Services/, DTOs/
├── CPR.Domain/         Entities/, ValueObjects/, Events/, Repositories/, Services/
└── CPR.Infrastructure/ Data/(DbContext, Migrations, Repositories), AI/, Integrations/, Notifications/, Caching/

cpr-api/tests/
├── CPR.UnitTests/
├── CPR.IntegrationTests/
└── CPR.ArchitectureTests/
```

---

## Frontend (CPR-UI)

### Technology Stack

- **Framework**: React 18 + TypeScript 5 (strict mode)
- **Build**: Vite 5
- **UI**: Material UI (MUI) v6 — light/dark theme
- **State**: Zustand (UI/client state) + React Query (server/cache state)
- **Routing**: React Router v6 with RBAC route guards
- **Auth**: MSAL.js v3 for Microsoft Entra integration
- **Forms**: React Hook Form + Zod validation
- **Testing**: Vitest + React Testing Library + MSW

### Component Layers

```
Application Shell   — AppLayout, Header, Sidebar; Theme/Auth providers; Route Guards; Error Boundaries
    ↓
Page Components     — Route containers; data fetching coordination
    ↓
Feature Components  — GoalCard, FeedbackForm, SkillMatrix, etc.; business logic
    ↓
MUI Library         — Button, Card, TextField, DataGrid, Dialog, etc.
```

### State Management

- **React Query** — all server data: caching, background refetch, optimistic updates, error retry
- **Zustand** — UI-only state: theme, layout, sidebar open/closed, user preferences
- **MSAL context** — auth identity, token refresh, role/permission checks

### Project Structure

```
cpr-ui/src/
├── components/     Reusable feature components (GoalCard/, FeedbackForm/, SkillMatrix/, etc.)
├── pages/          Route targets (DashboardPage, GoalsPage, FeedbackPage, SkillsPage, etc.)
├── services/       API service layer (goals/, feedback/, skills/, auth/, ai/)
├── hooks/          React Query hooks by feature (useGoals, useFeedback, useSkills, etc.)
├── store/          Zustand stores (authStore, themeStore, layoutStore)
├── types/          TypeScript types (api.types, goal.types, feedback.types, etc.)
├── routes/         Route definitions, ProtectedRoute, RoleGuard
├── theme/          MUI theme (palette, typography, component overrides)
└── utils/          Date formatting, validation helpers, constants

cpr-ui/src/mocks/
├── handlers/       MSW request handlers by feature (goals, feedback, skills, auth, etc.)
└── data/           Mock data fixtures
```

### Development Modes

- **Mock** (`yarn start:mock`) — MSW intercepts all API calls; fully offline; role variants: `start:mock-manager`, `start:mock-admin`
- **Local** (`yarn start:local`) — connects to `http://localhost:5000/api`; real backend + auth

---

## AI Services

Four planned services (not yet implemented):

| Service | Responsibility |
|---------|---------------|
| Goal Recommendation Engine | Suggests SMART goals based on skills, role, career trajectory |
| Feedback Generation Assistant | Guides structured feedback; reduces bias |
| Sentiment Analysis Service | Scores and trends feedback quality across teams and time |
| Predictive Modeling Engine | Retention risk and performance trajectory predictions |

Integration patterns: **real-time** (interactive wizards), **batch** (periodic analysis), **event-driven** (triggered on goal/feedback changes).

---

## External Integrations

Planned connectors (not yet implemented):

| Connector | Data |
|-----------|------|
| HRIS | Employee sync, org structure, reporting relationships |
| Learning Platforms | Course recommendations, training completion, certifications |
| Productivity Tools | Project management, calendar, collaboration data |
| Notifications | Email, Slack/Teams, mobile push |

Integration patterns: synchronous REST (user-initiated), async message queues (bulk sync), webhooks (third-party events).

---

## Security

- **Authentication**: Microsoft Entra External ID; OAuth2/OIDC; SSO + MFA support
- **Authorization**: JWT validation on all endpoints; `[Authorize(Policy = "...")]` for RBAC
- **Encryption**: TLS 1.3 in transit; database-level encryption at rest; Azure Key Vault for secrets
- **Privacy**: GDPR compliance; data retention policies; right-to-be-forgotten
- **Audit**: structured access logs with `user_id`, `action`, `resource_type`, `resource_id`, `timestamp`

---

## Infrastructure

- **Local dev**: docker-compose — PostgreSQL (port 5432), API (port 5000), UI (port 3000)
- **CI/CD**: GitHub Actions — test → build Docker image → push to GHCR → deploy
- **Containers**: multi-stage Docker builds for API and UI
- **Registry**: `ghcr.io/vyacheslavkozyrev/cpr-api` and `cpr-ui`

---

## Performance & Observability

- **Caching**: Redis (distributed) + application-level cache; CDN for static assets
- **API**: response compression; pagination (default 20, max 100); async background processing
- **Database**: connection pooling; read replicas for analytics queries
- **Logging**: structured JSON; correlation IDs for request tracing; centralized log aggregation
- **Health checks**: `/health` endpoint; error tracking; custom business metrics

---

## Scalability

Current phase: **modular monolith** — single deployable unit with clear domain boundaries and a shared database. API is stateless (no server-side session), enabling horizontal scaling behind a load balancer when needed. Domain boundaries are designed for future service extraction.
