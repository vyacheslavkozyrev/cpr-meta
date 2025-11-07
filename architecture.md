# CPR Platform Architecture

**Continuous Performance Review Platform - Technical Architecture Specification**

This document defines the comprehensive architecture for the CPR platform, including backend API, frontend user interface, AI services, system integrations, and infrastructure components.

---

## Architecture Overview

The CPR platform is designed as a modern, full-stack solution with clear separation of concerns, modular architecture, and scalable design principles. The system follows Clean Architecture patterns with domain-driven design, ensuring maintainability, testability, and extensibility.

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                    CPR Platform Ecosystem                        │
├─────────────────────────────────────────────────────────────────┤
│  Frontend (React SPA)          │  Backend Services               │
│  ┌─────────────────────────┐   │  ┌─────────────────────────┐   │
│  │   CPR-UI Application    │   │  │    CPR-API Service      │   │
│  │  • React + TypeScript   │◄──┤  │  • ASP.NET Core Web API │   │
│  │  • Material UI (MUI)    │   │  │  • Clean Architecture   │   │
│  │  • MSAL Authentication  │   │  │  • EF Core + PostgreSQL │   │
│  │  • React Query Caching  │   │  │  • Microsoft Entra ID   │   │
│  └─────────────────────────┘   │  └─────────────────────────┘   │
├─────────────────────────────────┼─────────────────────────────────┤
│  AI Services Layer              │  External Integrations         │
│  ┌─────────────────────────┐   │  ┌─────────────────────────┐   │
│  │  AI Assistant Services  │   │  │   System Integrations   │   │
│  │  • Goal Recommendation  │   │  │  • HRIS Systems         │   │
│  │  • Feedback Generation  │   │  │  • Learning Platforms   │   │
│  │  • Sentiment Analysis   │   │  │  • Productivity Tools   │   │
│  │  • Predictive Modeling  │   │  │  • Email/Notifications  │   │
│  └─────────────────────────┘   │  └─────────────────────────┘   │
├─────────────────────────────────────────────────────────────────┤
│  Infrastructure & DevOps                                        │
│  • Docker Containers  • GitHub Actions CI/CD  • GHCR Registry  │
│  • PostgreSQL Database  • Secret Management  • Monitoring      │
└─────────────────────────────────────────────────────────────────┘
```

---

## Backend Architecture (CPR-API)

### Core Technology Stack

- **Runtime**: .NET 9 (fallback to .NET 8)
- **Web Framework**: ASP.NET Core Web API
- **Data Access**: Entity Framework Core + Migrations
- **Database**: PostgreSQL (containerized)
- **Authentication**: Microsoft Entra External ID (OAuth2/OIDC) + JWT
- **Container Registry**: GitHub Container Registry (GHCR)
- **CI/CD**: GitHub Actions
- **Deployment**: Docker containers, docker-compose for local development

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    CPR.API (Presentation)                   │
│  • Controllers (thin, HTTP concerns only)                  │
│  • DTOs & Request/Response models                          │
│  • Middleware (auth, cors, logging, error handling)       │
│  • API documentation (OpenAPI/Swagger)                     │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│              CPR.Application (Use Cases)                   │
│  • Command/Query handlers (CQRS pattern)                  │
│  • Business workflows & orchestration                     │
│  • AI service interfaces & coordination                   │
│  • Integration service interfaces                         │
│  • Application DTOs & mapping                             │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                CPR.Domain (Business Logic)                 │
│  • Entities (Employee, Goal, Feedback, Skill, Badge)      │
│  • Value objects & domain rules                           │
│  • Domain events & business invariants                    │
│  • Repository interfaces (ports)                          │
│  • Domain services for complex business logic             │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│            CPR.Infrastructure (External Concerns)          │
│  • EF Core DbContext & configurations                     │
│  • Repository implementations                              │
│  • External service integrations (HRIS, Learning)         │
│  • AI service implementations                              │
│  • Email/notification services                            │
│  • Caching, logging, monitoring                           │
└─────────────────────────────────────────────────────────────┘
```

### Project Structure

```
cpr-api/
├── src/
│   ├── CPR.Api/                      # Presentation Layer
│   │   ├── Controllers/
│   │   │   ├── AuthController.cs
│   │   │   ├── GoalsController.cs
│   │   │   ├── FeedbackController.cs
│   │   │   ├── SkillsController.cs
│   │   │   ├── BadgesController.cs
│   │   │   ├── TeamsController.cs
│   │   │   └── AnalyticsController.cs
│   │   ├── Middleware/
│   │   │   ├── AuthenticationMiddleware.cs
│   │   │   ├── CorrelationIdMiddleware.cs
│   │   │   ├── ExceptionHandlingMiddleware.cs
│   │   │   └── RateLimitingMiddleware.cs
│   │   ├── DTOs/
│   │   └── Program.cs
│   │
│   ├── CPR.Application/              # Use Cases Layer
│   │   ├── Commands/
│   │   │   ├── Goals/
│   │   │   ├── Feedback/
│   │   │   ├── Skills/
│   │   │   └── Recognition/
│   │   ├── Queries/
│   │   │   ├── Analytics/
│   │   │   ├── Reporting/
│   │   │   └── Teams/
│   │   ├── Services/
│   │   │   ├── IAIAssistantService.cs
│   │   │   ├── IGoalRecommendationService.cs
│   │   │   ├── IFeedbackAnalysisService.cs
│   │   │   ├── IPredictiveModelingService.cs
│   │   │   └── IIntegrationService.cs
│   │   ├── Handlers/
│   │   └── DTOs/
│   │
│   ├── CPR.Domain/                   # Domain Layer
│   │   ├── Entities/
│   │   │   ├── Employee.cs
│   │   │   ├── Goal.cs
│   │   │   ├── Feedback.cs
│   │   │   ├── Skill.cs
│   │   │   ├── Badge.cs
│   │   │   ├── Team.cs
│   │   │   └── PerformanceReview.cs
│   │   ├── ValueObjects/
│   │   │   ├── SkillLevel.cs
│   │   │   ├── FeedbackRating.cs
│   │   │   └── GoalStatus.cs
│   │   ├── Events/
│   │   ├── Repositories/
│   │   └── Services/
│   │
│   └── CPR.Infrastructure/           # Infrastructure Layer
│       ├── Data/
│       │   ├── CPRDbContext.cs
│       │   ├── Configurations/
│       │   ├── Migrations/
│       │   └── Repositories/
│       ├── AI/
│       │   ├── OpenAIService.cs
│       │   ├── GoalRecommendationEngine.cs
│       │   ├── SentimentAnalysisService.cs
│       │   └── PredictiveModelService.cs
│       ├── Integrations/
│       │   ├── HRISConnector.cs
│       │   ├── LearningPlatformConnector.cs
│       │   └── ProductivityToolsConnector.cs
│       ├── Notifications/
│       └── Caching/
│
├── tests/
│   ├── CPR.UnitTests/
│   ├── CPR.IntegrationTests/
│   ├── CPR.ContractTests/
│   └── CPR.ArchitectureTests/
│
├── infra/
│   ├── docker-compose.yml
│   ├── docker-compose.override.yml
│   └── postgres/
│
└── ci/
    ├── build.yml
    ├── test.yml
    └── deploy.yml
```

### Frontend Project Structure

```
cpr-ui/
├── .vscode/                  # VS Code settings & extensions
├── documents/                # Project documentation (existing)
├── public/                   # Static assets
│   ├── favicon.ico
│   ├── manifest.json
│   └── locales/              # i18n files (future)
├── src/
│   ├── components/           # Reusable UI components
│   │   ├── layout/           # Layout components
│   │   │   ├── AppLayout/
│   │   │   ├── Header/
│   │   │   ├── Sidebar/
│   │   │   ├── Footer/
│   │   │   └── NavigationMenu/
│   │   ├── goals/            # Goal-specific components
│   │   │   ├── GoalCard/
│   │   │   ├── GoalList/
│   │   │   ├── GoalForm/
│   │   │   ├── GoalProgress/
│   │   │   └── AIGoalWizard/
│   │   ├── feedback/         # Feedback components
│   │   │   ├── FeedbackCard/
│   │   │   ├── FeedbackForm/
│   │   │   ├── FeedbackList/
│   │   │   └── AIFeedbackAssistant/
│   │   ├── skills/           # Skills components
│   │   │   ├── SkillAssessment/
│   │   │   ├── SkillMatrix/
│   │   │   ├── SkillTree/
│   │   │   └── SkillProgress/
│   │   ├── team/             # Team components
│   │   │   ├── TeamMemberCard/
│   │   │   ├── TeamDashboard/
│   │   │   ├── OrgChart/
│   │   │   └── TeamAnalytics/
│   │   ├── recognition/      # Badge & recognition components
│   │   │   ├── BadgeDisplay/
│   │   │   ├── BadgeList/
│   │   │   ├── AchievementCard/
│   │   │   └── RecognitionFeed/
│   │   ├── dashboard/        # Dashboard widgets
│   │   │   ├── GoalSummary/
│   │   │   ├── FeedbackSummary/
│   │   │   ├── SkillProgress/
│   │   │   ├── ActivityFeed/
│   │   │   └── AIInsights/
│   │   └── forms/            # Reusable form components
│   │       ├── FormInput/
│   │       ├── FormSelect/
│   │       ├── FormDatePicker/
│   │       └── FormAutocomplete/
│   ├── pages/                # Page components (route targets)
│   │   ├── auth/
│   │   │   ├── LoginPage.tsx
│   │   │   └── CallbackPage.tsx
│   │   ├── dashboard/
│   │   │   └── DashboardPage.tsx
│   │   ├── goals/
│   │   │   ├── GoalsPage.tsx
│   │   │   ├── GoalDetailPage.tsx
│   │   │   └── GoalCreatePage.tsx
│   │   ├── feedback/
│   │   │   ├── FeedbackPage.tsx
│   │   │   ├── FeedbackRequestPage.tsx
│   │   │   └── FeedbackHistoryPage.tsx
│   │   ├── skills/
│   │   │   ├── SkillsPage.tsx
│   │   │   └── SkillAssessmentPage.tsx
│   │   ├── team/
│   │   │   ├── TeamPage.tsx
│   │   │   └── TeamMemberPage.tsx
│   │   ├── profile/
│   │   │   └── ProfilePage.tsx
│   │   ├── recognition/
│   │   │   ├── BadgesPage.tsx
│   │   │   └── AchievementsPage.tsx
│   │   ├── admin/
│   │   │   ├── TaxonomyPage.tsx
│   │   │   ├── UsersPage.tsx
│   │   │   └── AnalyticsPage.tsx
│   │   └── NotFoundPage.tsx
│   ├── services/             # API services & business logic
│   │   ├── api/
│   │   │   ├── client.ts     # Base API client (fetch wrapper)
│   │   │   ├── generated/    # OpenAPI generated code
│   │   │   └── interceptors.ts
│   │   ├── auth/
│   │   │   ├── msalConfig.ts
│   │   │   ├── authService.ts
│   │   │   └── tokenService.ts
│   │   ├── goals/
│   │   │   └── goalsService.ts
│   │   ├── feedback/
│   │   │   └── feedbackService.ts
│   │   ├── skills/
│   │   │   └── skillsService.ts
│   │   ├── recognition/
│   │   │   └── badgesService.ts
│   │   ├── ai/
│   │   │   ├── aiAssistantService.ts
│   │   │   └── recommendationService.ts
│   │   └── team/
│   │       └── teamService.ts
│   ├── hooks/                # Custom React hooks
│   │   ├── useAuth.ts
│   │   ├── useCurrentUser.ts
│   │   ├── useTheme.ts
│   │   ├── usePermissions.ts
│   │   ├── useGoals.ts       # React Query hooks
│   │   ├── useFeedback.ts
│   │   ├── useSkills.ts
│   │   ├── useTeam.ts
│   │   ├── useBadges.ts
│   │   ├── useAI.ts
│   │   └── useDebounce.ts
│   ├── store/                # Zustand stores
│   │   ├── authStore.ts      # Current user, auth state
│   │   ├── themeStore.ts     # Light/dark mode
│   │   └── layoutStore.ts    # Sidebar open/closed, etc.
│   ├── types/                # TypeScript type definitions
│   │   ├── api.types.ts      # API response types
│   │   ├── user.types.ts
│   │   ├── goal.types.ts
│   │   ├── feedback.types.ts
│   │   ├── skill.types.ts
│   │   ├── badge.types.ts
│   │   ├── ai.types.ts
│   │   └── team.types.ts
│   ├── utils/                # Utility functions
│   │   ├── date.ts           # Date formatting
│   │   ├── validation.ts     # Custom validators
│   │   ├── formatting.ts     # Text/number formatting
│   │   ├── constants.ts      # App constants
│   │   └── helpers.ts
│   ├── routes/               # Route configuration
│   │   ├── index.tsx         # Route definitions
│   │   ├── ProtectedRoute.tsx
│   │   └── RoleGuard.tsx
│   ├── config/               # App configuration
│   │   ├── env.ts            # Environment variables
│   │   └── queryClient.ts    # React Query config
│   ├── theme/                # MUI theme configuration
│   │   ├── index.ts
│   │   ├── palette.ts
│   │   ├── typography.ts
│   │   └── components.ts     # Component overrides
│   ├── assets/               # Images, fonts, etc.
│   ├── App.tsx               # Root component
│   ├── main.tsx              # Entry point
│   └── vite-env.d.ts         # Vite type definitions
├── mocks/                    # MSW - Mock Service Worker
│   ├── browser.ts            # Browser MSW setup
│   ├── server.ts             # Node MSW setup (tests)
│   ├── handlers/             # Request handlers by feature
│   │   ├── index.ts          # Combined handlers
│   │   ├── auth.handlers.ts
│   │   ├── goals.handlers.ts
│   │   ├── feedback.handlers.ts
│   │   ├── skills.handlers.ts
│   │   ├── badges.handlers.ts
│   │   ├── ai.handlers.ts
│   │   ├── team.handlers.ts
│   │   └── admin.handlers.ts
│   ├── data/                 # Mock data fixtures
│   │   ├── users.ts
│   │   ├── goals.ts
│   │   ├── feedback.ts
│   │   ├── skills.ts
│   │   ├── badges.ts
│   │   ├── ai-recommendations.ts
│   │   └── taxonomy.ts
│   └── utils/                # Mock utilities
│       ├── response.ts       # Response helpers
│       ├── pagination.ts     # Pagination helpers
│       └── delay.ts          # Realistic delays
├── tests/
│   ├── setup.ts              # Test setup & global mocks
│   └── utils/                # Test utilities
│       └── renderWithProviders.tsx
├── .env.development          # Dev environment variables
├── .env.production           # Prod environment variables
├── .env.localapi             # Local API mode environment variables
├── .env.mock                 # Mock mode environment variables
├── .eslintrc.json            # ESLint config
├── .prettierrc               # Prettier config
├── tsconfig.json             # TypeScript config
├── tsconfig.node.json        # TypeScript config for Vite
├── vite.config.ts            # Vite configuration
├── vitest.config.ts          # Vitest test configuration
├── package.json
├── yarn.lock
└── README.md
```

### Key Architectural Patterns

1. **CQRS (Command Query Responsibility Segregation)**
   - Separate read and write operations
   - Optimized queries for reporting and analytics
   - Clear separation of concerns

2. **Repository Pattern**
   - Abstract data access layer
   - Testable without database dependencies
   - Support for multiple data sources

3. **Domain Events**
   - Decouple business logic from side effects
   - Enable audit trails and notifications
   - Support for eventual consistency

4. **Dependency Injection**
   - Interface-based design
   - Testable and maintainable code
   - Configuration-driven implementations

---

## Frontend Architecture (CPR-UI)

### Core Technology Stack

- **Framework**: React 18.3+ with TypeScript 5.x (strict mode)
- **Build Tool**: Vite 5.x for fast development and builds
- **UI Library**: Material UI (MUI) v6 with light/dark themes
- **State Management**: Zustand (UI state) + React Query (server state)
- **Routing**: React Router v6 with RBAC route guards
- **Authentication**: MSAL.js v3 for Microsoft Entra integration
- **Forms**: React Hook Form + Zod validation
- **Testing**: Vitest + React Testing Library + MSW mocking

### Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Application Shell                       │
│  • AppLayout, Header, Sidebar, Footer                      │
│  • Theme Provider, Auth Provider                           │
│  • Route Guards, Error Boundaries                          │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                   Page Components                          │
│  • Dashboard, Goals, Feedback, Skills, Team, Profile      │
│  • Route-specific containers                               │
│  • Data fetching & state management                       │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│                Feature Components                          │
│  • GoalCard, FeedbackForm, SkillMatrix                    │
│  • BadgeDisplay, TeamDashboard, AIAssistant               │
│  • Business logic & feature-specific state                │
└─────────────────────────┬───────────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────────┐
│            Material UI (MUI) Component Library            │
│  • Built-in components: Button, Card, Dialog, DataGrid    │
│  • Form components: TextField, Select, DatePicker         │
│  • Layout components: Box, Stack, Grid, Container         │
│  • Navigation: AppBar, Drawer, Tabs, Breadcrumbs         │
└─────────────────────────────────────────────────────────────┘
```

### State Management Strategy

1. **Server State (React Query)**
   - API data caching and synchronization
   - Optimistic updates for better UX
   - Background refetching and invalidation
   - Error handling and retry logic

2. **Client State (Zustand)**
   - User preferences and UI state
   - Theme settings and layout state
   - Form state for complex workflows
   - Navigation and routing state

3. **Authentication Context**
   - User identity and permissions
   - Token management and refresh
   - Role-based access control

### Development Modes

1. **Mock Mode** (`yarn start:mock`)
   - MSW intercepts all API calls
   - Fully offline development capability
   - Consistent mock data for UI testing
   - Perfect for frontend-focused development

2. **Local Mode** (`yarn start:local`)
   - Connect to `http://localhost:5000/api`
   - Real backend integration testing
   - Local authentication tokens
   - Full-stack development workflow

3. **Production Mode** (`yarn build && yarn preview`)
   - Production build testing
   - Performance optimization validation
   - Production authentication flow

---

## AI Services Architecture

### AI Assistant Components

```
┌─────────────────────────────────────────────────────────────┐
│                   AI Services Layer                         │
├─────────────────────────────────────────────────────────────┤
│  Goal Recommendation Engine                                 │
│  • Analyzes current skills and career trajectories         │
│  • Suggests SMART goals based on role and level            │
│  • Considers organizational needs and opportunities         │
├─────────────────────────────────────────────────────────────┤
│  Feedback Generation Assistant                              │
│  • Guides users through structured feedback questions      │
│  • Generates coherent, constructive feedback               │
│  • Ensures quality and reduces bias in submissions         │
├─────────────────────────────────────────────────────────────┤
│  Sentiment Analysis Service                                 │
│  • Real-time analysis of feedback sentiment                │
│  • Quality scoring and bias detection                      │
│  • Trend analysis across teams and time periods            │
├─────────────────────────────────────────────────────────────┤
│  Predictive Modeling Engine                                 │
│  • Retention risk assessment                               │
│  • Performance trajectory predictions                      │
│  • Development recommendation algorithms                    │
└─────────────────────────────────────────────────────────────┘
```

### AI Integration Patterns

1. **Real-time Assistance**
   - Interactive goal setting wizard
   - Live feedback guidance
   - Immediate quality scoring

2. **Batch Processing**
   - Periodic sentiment analysis
   - Bulk performance predictions
   - Organizational trend analysis

3. **Event-driven Processing**
   - Trigger analysis on feedback submission
   - Update predictions on goal changes
   - Real-time bias detection alerts

### AI Service Interfaces

```csharp
public interface IAIAssistantService
{
    Task<GoalRecommendation[]> GenerateGoalRecommendationsAsync(
        Guid employeeId, 
        SkillAssessment currentSkills);
    
    Task<FeedbackSuggestion> GenerateFeedbackAsync(
        FeedbackContext context, 
        string[] responses);
    
    Task<SentimentAnalysis> AnalyzeFeedbackSentimentAsync(
        string feedbackText);
    
    Task<RetentionRisk> PredictRetentionRiskAsync(
        Guid employeeId, 
        TimeSpan period);
}
```

---

## System Integration Architecture

### External Service Connectors

```
┌─────────────────────────────────────────────────────────────┐
│                External Integrations                        │
├─────────────────────────────────────────────────────────────┤
│  HRIS Integration                                           │
│  • Employee data synchronization                           │
│  • Organizational structure updates                        │
│  • Role and reporting relationship management              │
├─────────────────────────────────────────────────────────────┤
│  Learning Platform Integration                              │
│  • Skill development course recommendations                │
│  • Training completion tracking                            │
│  • Certification and credential management                 │
├─────────────────────────────────────────────────────────────┤
│  Productivity Tools Integration                             │
│  • Project management system connections                   │
│  • Collaboration platform data import                      │
│  • Calendar and meeting integration                        │
├─────────────────────────────────────────────────────────────┤
│  Notification Services                                      │
│  • Email notification delivery                             │
│  • Slack/Teams integration                                 │
│  • Mobile push notifications                               │
└─────────────────────────────────────────────────────────────┘
```

### Integration Patterns

1. **Synchronous REST APIs**
   - Real-time data exchange
   - Immediate validation and responses
   - Direct user-initiated operations

2. **Asynchronous Message Queues**
   - Bulk data synchronization
   - Event-driven notifications
   - Resilient background processing

3. **Webhook Subscriptions**
   - Real-time event notifications
   - Third-party system updates
   - Automated workflow triggers

### Data Synchronization Strategy

```csharp
public interface IIntegrationService
{
    Task SyncEmployeeDataAsync(string hrSystemId);
    Task UpdateOrganizationStructureAsync();
    Task SyncLearningProgressAsync(Guid employeeId);
    Task SendNotificationAsync(NotificationRequest request);
    Task<Course[]> GetRecommendedCoursesAsync(SkillGap[] gaps);
}
```

---

## Security Architecture

### Authentication & Authorization

1. **Microsoft Entra External ID Integration**
   - OAuth2/OIDC standard compliance
   - Single Sign-On (SSO) capability
   - Multi-factor authentication support
   - Enterprise directory integration

2. **Role-Based Access Control (RBAC)**
   - Fine-grained permissions system
   - Hierarchical role inheritance
   - Context-aware access decisions
   - Audit trail for access changes

3. **API Security**
   - JWT token validation
   - Rate limiting and throttling
   - Input validation and sanitization
   - CORS configuration

### Data Protection

1. **Encryption**
   - Data at rest: Database-level encryption
   - Data in transit: TLS 1.3 for all communications
   - Key management: Azure Key Vault integration

2. **Privacy Controls**
   - GDPR compliance features
   - Data retention policies
   - User consent management
   - Right to be forgotten implementation

3. **Audit & Compliance**
   - Comprehensive audit logging
   - Change tracking for sensitive data
   - Compliance reporting capabilities
   - Data access monitoring

---

## Infrastructure & DevOps

### Containerization Strategy

```dockerfile
# Multi-stage build for CPR-API
FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["CPR.Api/CPR.Api.csproj", "CPR.Api/"]
COPY ["CPR.Application/CPR.Application.csproj", "CPR.Application/"]
COPY ["CPR.Domain/CPR.Domain.csproj", "CPR.Domain/"]
COPY ["CPR.Infrastructure/CPR.Infrastructure.csproj", "CPR.Infrastructure/"]
RUN dotnet restore "CPR.Api/CPR.Api.csproj"
COPY . .
WORKDIR "/src/CPR.Api"
RUN dotnet build "CPR.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "CPR.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CPR.Api.dll"]
```

### CI/CD Pipeline

```yaml
# GitHub Actions workflow
name: CPR Platform CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    
    steps:
      - uses: actions/checkout@v4
      - name: Setup .NET
        uses: actions/setup-dotnet@v3
        with:
          dotnet-version: '9.0.x'
      
      - name: Run Backend Tests
        run: |
          dotnet restore
          dotnet test --configuration Release --logger trx --results-directory TestResults/
      
      - name: Build Docker Image
        run: docker build -t ghcr.io/vyacheslavkozyrev/cpr-api:${{ github.sha }} .
      
      - name: Push to Registry
        if: github.ref == 'refs/heads/main'
        run: |
          echo ${{ secrets.GITHUB_TOKEN }} | docker login ghcr.io -u ${{ github.actor }} --password-stdin
          docker push ghcr.io/vyacheslavkozyrev/cpr-api:${{ github.sha }}

  frontend-tests:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'yarn'
      
      - name: Install Dependencies
        run: yarn install --frozen-lockfile
      
      - name: Run Tests
        run: yarn test:ci
      
      - name: Build Production
        run: yarn build
      
      - name: Build Docker Image
        run: docker build -t ghcr.io/vyacheslavkozyrev/cpr-ui:${{ github.sha }} .
```

### Local Development Environment

```yaml
# docker-compose.yml for local development
version: '3.8'

services:
  postgres:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: cpr_dev
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./infra/postgres/init.sql:/docker-entrypoint-initdb.d/init.sql

  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "5000:80"
    environment:
      - ConnectionStrings__DefaultConnection=Host=postgres;Database=cpr_dev;Username=postgres;Password=postgres
      - ASPNETCORE_ENVIRONMENT=Development
    depends_on:
      - postgres
    volumes:
      - ./logs:/app/logs

  ui:
    build:
      context: ./cpr-ui
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    environment:
      - VITE_API_BASE_URL=http://localhost:5000/api
    volumes:
      - ./cpr-ui:/app
      - /app/node_modules

volumes:
  postgres_data:
```

---

## Performance & Monitoring

### Performance Optimization

1. **Database Optimization**
   - Proper indexing strategy
   - Query optimization and monitoring
   - Connection pooling
   - Read replicas for analytics

2. **Caching Strategy**
   - Redis for distributed caching
   - Application-level caching
   - CDN for static assets
   - Browser caching headers

3. **API Performance**
   - Response compression
   - Pagination for large datasets
   - Asynchronous processing
   - Rate limiting and throttling

### Monitoring & Observability

1. **Application Monitoring**
   - Health check endpoints
   - Performance metrics collection
   - Error tracking and alerting
   - Custom business metrics

2. **Logging Strategy**
   - Structured logging (JSON format)
   - Correlation IDs for request tracing
   - Centralized log aggregation
   - Log retention policies

3. **Metrics & Dashboards**
   - Application performance metrics
   - Business intelligence dashboards
   - User engagement analytics
   - System health monitoring

---

## Scalability Considerations

### Horizontal Scaling

1. **Stateless Design**
   - No server-side session state
   - Database-backed authentication
   - Distributed caching
   - Load balancer friendly

2. **Database Scaling**
   - Read replicas for queries
   - Partitioning strategies
   - Connection pooling
   - Query optimization

3. **Microservices Evolution**
   - Modular monolith foundation
   - Domain boundary identification
   - Event-driven architecture readiness
   - Service extraction patterns

### Future Architecture Evolution

1. **Phase 1: Modular Monolith** (Current)
   - Single deployable unit
   - Clear domain boundaries
   - Shared database
   - Simple deployment

2. **Phase 2: Service Decomposition**
   - Extract AI services
   - Separate analytics service
   - Independent deployments
   - Event-driven communication

3. **Phase 3: Distributed Architecture**
   - Full microservices architecture
   - Service mesh implementation
   - Distributed data management
   - Advanced monitoring and tracing

This architecture provides a solid foundation for the CPR platform while maintaining flexibility for future growth and evolution. The design emphasizes clean separation of concerns, testability, maintainability, and scalability to support the platform's long-term success.