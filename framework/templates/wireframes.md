# Wireframes — [Feature Name] ([####])

> **Coverage requirement**: every screen or interaction flow mentioned in `stories.md`
> must have a corresponding section below. Check stories.md before finalising this document.

## [Screen / Component Name]

```mermaid
flowchart TD
    A[Screen Title] --> B[Element]
    B --> C{Decision}
    C -->|Yes| D[Action]
    C -->|No| E[Alternative]
```

**Notes**
- [Interaction detail or design decision]
- [Edge case behavior]

---

## [Another Screen or Flow]

```mermaid
sequenceDiagram
    actor User
    participant UI
    participant API
    User->>UI: [action]
    UI->>API: [request]
    API-->>UI: [response]
    UI-->>User: [result]
```

**Notes**
- [Note]

---

## [Screen Name] — States

Document non-happy-path states for every screen that has them.

```mermaid
flowchart TD
    A[Load Screen] --> B{Data available?}
    B -->|Loading| C[Skeleton / Spinner]
    B -->|Empty| D[Empty state message + CTA]
    B -->|Error| E[Error message + Retry button]
    B -->|Success| F[Populated content]
```

**Notes**
- Empty state: [what message and call-to-action to show]
- Error state: [what error message and recovery action to show]
- Loading state: [skeleton layout or spinner placement]
