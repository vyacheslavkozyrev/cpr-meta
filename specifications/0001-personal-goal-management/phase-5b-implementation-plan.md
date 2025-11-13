# Phase 5B: Advanced Features Implementation Plan
**Feature 0001 - Personal Goal Management**  
**Created:** November 12, 2025  
**Status:** Ready to Start

---

## Overview

Phase 5B focuses on implementing advanced features that enhance the user experience beyond the core functionality completed in Phase 5A. This phase adds drag-and-drop task reordering, offline synchronization, advanced internationalization, auto-save functionality, and performance optimizations.

---

## Objectives

1. **Task Reordering**: Drag-and-drop task reordering with @dnd-kit
2. **Offline Sync**: IndexedDB caching with background synchronization
3. **Internationalization**: Language switcher and locale-specific formatting
4. **Auto-Save**: Debounced auto-save for goal forms (2-second delay)
5. **Performance**: Virtual scrolling, code splitting, bundle optimization
6. **User Preferences**: Persist filter/sort/view preferences

---

## Prerequisites

✅ Phase 5A Complete (Enhanced UI Components)
- All core UI components implemented
- Loading states and skeletons
- Form validation and error handling
- Responsive design tested

---

## Phase 5B Tasks

### Sub-Phase 5B.1: Drag-and-Drop Task Reordering
**Duration:** 4-6 hours  
**Priority:** P1 (High)

#### Backend Requirements
- ✅ `order_index` column already exists in `goal_tasks` table (from Phase 1)
- ⚠️ **NEW ENDPOINT NEEDED:** `PATCH /api/goals/{id}/tasks/reorder`
  - Body: `{ "task_order": [{ "task_id": "uuid", "order_index": 0 }, ...] }`
  - Response: `204 No Content` or `200 OK` with updated tasks

#### Frontend Tasks
1. **Install Dependencies**
   - `@dnd-kit/core@^6.0.0`
   - `@dnd-kit/sortable@^7.0.0`
   - `@dnd-kit/utilities@^3.2.0`

2. **Create Reorder Service**
   - File: `src/services/goalService.ts`
   - Add `reorderTasks(goalId: string, taskOrder: TaskOrderItem[]): Promise<void>`

3. **Enhance TaskList Component**
   - File: `src/components/goals/TaskList.tsx`
   - Wrap with `DndContext` from @dnd-kit/core
   - Use `SortableContext` for task items
   - Implement `onDragEnd` handler
   - Add drag handle icon to each task item
   - Add visual feedback during drag (opacity, shadow)

4. **Create Sortable Task Item**
   - File: `src/components/goals/SortableTaskItem.tsx`
   - Wrap TaskItem with `useSortable` hook
   - Add drag handle with grab cursor
   - Style active/dragging state

5. **Add Reorder Mutation**
   - File: `src/services/index.ts`
   - Create `useReorderTasks` hook
   - Optimistic update: reorder locally, sync on success
   - Rollback on error with toast notification

**Acceptance Criteria:**
- [ ] Tasks can be dragged and dropped to reorder
- [ ] Drag handle visible on hover
- [ ] Visual feedback during drag
- [ ] Optimistic update with rollback on error
- [ ] Keyboard accessible (Space to grab, arrows to move, Enter to drop)
- [ ] Works on touch devices (mobile)

---

### Sub-Phase 5B.2: Offline Synchronization
**Duration:** 8-10 hours  
**Priority:** P1 (High)

#### Architecture
```
┌─────────────────┐
│   React Query   │ ← Online: Direct API calls
│   (Cache Layer) │
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│ Offline Manager │ ← Detects connectivity
└────────┬────────┘
         │
         ↓
┌─────────────────┐
│   IndexedDB     │ ← Offline: Local storage + sync queue
│  (Local Store)  │
└─────────────────┘
```

#### Implementation Tasks

1. **Create Offline Storage Service**
   - File: `src/services/offlineStorageService.ts`
   - Use Dexie.js wrapper for IndexedDB
   - Tables: `goals`, `tasks`, `sync_queue`
   - Methods: `saveGoal`, `getGoals`, `deleteGoal`, `addToSyncQueue`

2. **Create Sync Queue Service**
   - File: `src/services/syncQueueService.ts`
   - Queue mutation operations when offline
   - Process queue when online
   - Retry logic: 3 attempts with exponential backoff
   - Conflict resolution: server wins, notify user

3. **Create Offline Hook**
   - File: `src/hooks/useOfflineSync.ts`
   - Monitor `navigator.onLine` events
   - Sync queue on reconnection
   - Expose `isOnline`, `syncStatus`, `pendingCount`

4. **Enhance API Service Layer**
   - File: `src/services/goalService.ts`
   - Check online status before API calls
   - Route to IndexedDB if offline
   - Add to sync queue for mutations

5. **Create Offline Store**
   - File: `src/stores/offlineStore.ts`
   - Zustand store for offline state
   - Track: `isOnline`, `syncQueue`, `lastSyncTime`

6. **Update Offline Indicator**
   - File: `src/components/common/OfflineIndicator.tsx`
   - Show sync status (syncing, pending, error)
   - Click to manually trigger sync
   - Show pending operations count

**Acceptance Criteria:**
- [ ] App works offline (read cached data, queue mutations)
- [ ] Offline indicator visible when disconnected
- [ ] Sync queue processes automatically on reconnect
- [ ] User notified of sync errors
- [ ] Pending operations count displayed
- [ ] Manual sync button functional

---

### Sub-Phase 5B.3: Advanced Internationalization
**Duration:** 6-8 hours  
**Priority:** P2 (Medium)

#### Implementation Tasks

1. **Create Language Switcher Component**
   - File: `src/components/common/LanguageSwitcher.tsx`
   - Dropdown in app header
   - Flags/icons for each language
   - Persist selection to localStorage

2. **Add Ukrainian Translations**
   - File: `public/locales/uk/translation.json`
   - Translate all goal-related keys
   - Include pluralization rules
   - Add date/time formats

3. **Enhance Date Formatting**
   - File: `src/hooks/useDateFormat.ts`
   - Use `Intl.DateTimeFormat` for locale-aware dates
   - Support multiple formats (short, long, relative)
   - Add timezone support

4. **Add Number Formatting**
   - File: `src/utils/formatters.ts`
   - Use `Intl.NumberFormat` for percentages
   - Locale-aware decimal separators
   - Currency formatting (if needed)

5. **RTL Support Preparation**
   - File: `src/theme.ts`
   - Add RTL direction detection
   - Update MUI theme with RTL config
   - Test with Arabic locale (optional)

**Acceptance Criteria:**
- [ ] Language switcher in header
- [ ] English and Ukrainian fully translated
- [ ] Dates format per locale (MM/DD/YYYY vs DD/MM/YYYY)
- [ ] Percentages use locale decimal separator
- [ ] Language preference persisted
- [ ] Page title updates with language change

---

### Sub-Phase 5B.4: Auto-Save Functionality
**Duration:** 3-4 hours  
**Priority:** P2 (Medium)

#### Implementation Tasks

1. **Create Auto-Save Hook**
   - File: `src/hooks/useAutoSave.ts`
   - Debounce value changes (2-second delay)
   - Track save status (idle, saving, saved, error)
   - Return save function and status

2. **Enhance Goal Form**
   - File: `src/pages/goals/GoalFormPage.tsx`
   - Use `useAutoSave` hook
   - Show "Saving..." indicator
   - Show "All changes saved" confirmation
   - Disable on validation errors

3. **Add Save Indicator Component**
   - File: `src/components/common/SaveIndicator.tsx`
   - Animated icon (spinner → checkmark)
   - Status text ("Saving..." / "Saved" / "Error")
   - Position: top-right or below form header

**Acceptance Criteria:**
- [ ] Form auto-saves 2 seconds after user stops typing
- [ ] Save indicator shows current status
- [ ] No save on validation errors
- [ ] Works with offline queue
- [ ] Manual save still available

---

### Sub-Phase 5B.5: Performance Optimizations
**Duration:** 6-8 hours  
**Priority:** P2 (Medium)

#### Implementation Tasks

1. **Virtual Scrolling for Large Lists**
   - File: `src/components/goals/GoalsList.tsx`
   - Use `react-window` or `@tanstack/react-virtual`
   - Render only visible items (~20)
   - Smooth scrolling with buffer

2. **Code Splitting & Lazy Loading**
   - File: `src/routes/index.tsx`
   - Lazy load goal pages: `React.lazy(() => import('./pages/goals/GoalsPage'))`
   - Add Suspense boundaries with skeletons
   - Preload on link hover

3. **Memoization & Performance Hooks**
   - Files: All goal components
   - Wrap expensive components with `React.memo`
   - Use `useMemo` for computed values (filtered/sorted lists)
   - Use `useCallback` for event handlers passed to children

4. **Bundle Analysis & Optimization**
   - Analyze with `npm run build -- --analyze`
   - Split vendor chunks (React, MUI, i18n)
   - Tree-shake unused dependencies
   - Target: < 500 KB main bundle

5. **Image Optimization**
   - Compress assets (TinyPNG, ImageOptim)
   - Use WebP format with fallbacks
   - Lazy load images below fold

**Acceptance Criteria:**
- [ ] Virtual scrolling renders 1000+ goals smoothly
- [ ] Code splitting reduces initial bundle by 30%+
- [ ] No unnecessary re-renders (React DevTools Profiler)
- [ ] Lighthouse Performance score > 90
- [ ] TTI < 2 seconds on 3G

---

### Sub-Phase 5B.6: User Preferences Persistence
**Duration:** 4-5 hours  
**Priority:** P2 (Medium)

#### Backend Requirements
- ⚠️ **NEW ENDPOINTS NEEDED:**
  - `GET /api/user-preferences` - Retrieve preferences
  - `PUT /api/user-preferences` - Save preferences
  - Schema: `{ "goals_view": "grid|table", "goals_sort": "...", "goals_filters": {...}, "language": "en|uk" }`

#### Frontend Tasks

1. **Create User Preferences Service**
   - File: `src/services/userPreferencesService.ts`
   - `getUserPreferences(): Promise<UserPreferences>`
   - `saveUserPreferences(prefs: UserPreferences): Promise<void>`

2. **Create Preferences Store**
   - File: `src/stores/preferencesStore.ts`
   - Zustand store for user preferences
   - Load on app init
   - Auto-save on changes (debounced)

3. **Integrate with Goals Page**
   - File: `src/pages/goals/GoalsPage.tsx`
   - Load saved view/sort/filter preferences
   - Save on user changes
   - Reset to defaults option

4. **Add Settings Page (Optional)**
   - File: `src/pages/settings/SettingsPage.tsx`
   - Centralized preferences management
   - Reset all preferences button
   - Export/import preferences (JSON)

**Acceptance Criteria:**
- [ ] View preference (grid/table) persisted
- [ ] Sort/filter preferences saved
- [ ] Language preference saved
- [ ] Preferences load on app init
- [ ] Reset to defaults functional

---

## Technical Stack

### New Dependencies
```json
{
  "@dnd-kit/core": "^6.0.0",
  "@dnd-kit/sortable": "^7.0.0",
  "@dnd-kit/utilities": "^3.2.0",
  "dexie": "^3.2.0",
  "dexie-react-hooks": "^1.1.0",
  "react-window": "^1.8.0" // or @tanstack/react-virtual
}
```

### Backend Endpoints to Implement
1. `PATCH /api/goals/{id}/tasks/reorder` - Batch task reorder
2. `GET /api/user-preferences` - Retrieve preferences
3. `PUT /api/user-preferences` - Save preferences

---

## Testing Strategy

### Unit Tests
- [ ] Auto-save hook with debounce
- [ ] Offline sync queue logic
- [ ] Drag-and-drop handlers
- [ ] Preferences store

### Integration Tests
- [ ] Offline mode: queue → sync → verify
- [ ] Task reorder: drag → API call → state update
- [ ] Language switch: change → translations update
- [ ] Auto-save: type → wait → verify save

### E2E Tests (Playwright)
- [ ] Offline workflow: go offline → create goal → go online → verify sync
- [ ] Task reorder: drag task → verify order persisted
- [ ] Language switch: change language → verify UI updates
- [ ] Auto-save: edit form → wait → verify indicator

---

## Success Criteria

**Phase 5B is complete when:**
- [ ] All 6 sub-phases implemented (drag-drop, offline, i18n, auto-save, performance, preferences)
- [ ] Unit test coverage > 80% for new code
- [ ] E2E tests pass for all workflows
- [ ] Lighthouse Performance score > 90
- [ ] Bundle size < 500 KB (main chunk)
- [ ] No console errors or warnings
- [ ] Accessibility audit passed (WCAG AA)
- [ ] Build successful with 0 TypeScript errors
- [ ] Manual testing completed on mobile/tablet/desktop

---

## Implementation Order (Recommended)

1. **Start with User Preferences** (easiest, foundational)
2. **Then Drag-and-Drop** (high visibility, user delight)
3. **Then Auto-Save** (quick win, improves UX)
4. **Then Internationalization** (moderate complexity)
5. **Then Offline Sync** (most complex, requires backend)
6. **Finally Performance** (optimization, measurement)

---

## Estimated Timeline

| Sub-Phase | Hours | Days (8h) |
|-----------|-------|-----------|
| 5B.1 Drag-Drop | 4-6 | 0.5-0.75 |
| 5B.2 Offline Sync | 8-10 | 1-1.25 |
| 5B.3 i18n | 6-8 | 0.75-1 |
| 5B.4 Auto-Save | 3-4 | 0.5 |
| 5B.5 Performance | 6-8 | 0.75-1 |
| 5B.6 Preferences | 4-5 | 0.5-0.6 |
| **TOTAL** | **31-41** | **4-5 days** |

---

## Blockers & Dependencies

### Backend Blockers
- ⚠️ `PATCH /api/goals/{id}/tasks/reorder` endpoint not implemented
- ⚠️ User preferences endpoints not implemented

### Workarounds
- **Task Reorder**: Can implement UI-only (order persists in component state, not backend)
- **Preferences**: Can use localStorage instead of backend API

### External Dependencies
- None - all npm packages are stable and well-maintained

---

## Next Steps After Phase 5B

1. **Phase 6: Code Review**
   - Comprehensive code review (backend + frontend)
   - Security audit
   - Performance review
   - Constitutional compliance check

2. **Phase 7: Testing**
   - Full test suite execution
   - Manual UAT
   - Accessibility audit
   - Cross-browser testing

3. **Phase 8: Deployment**
   - Staging deployment
   - Production deployment
   - Monitoring setup
   - Documentation finalization

---

**Status:** 📋 Ready to Start  
**Next Action:** Decide which sub-phase to implement first (recommend User Preferences as warm-up)
