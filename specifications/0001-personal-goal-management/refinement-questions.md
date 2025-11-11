# Phase 2 Refinement: Clarifying Questions
# Feature 0001 - Personal Goal Management

**Generated**: 2025-11-11  
**Status**: Awaiting Stakeholder Review

---

## Priority 1: Critical for Implementation (Must Answer)

### US-001: Create Personal Goals

**Q1.1: Goal Creation Form Access**
- **Question**: How does a user access the goal creation form?
  - Via a floating action button (FAB)?
  - Via a "Create Goal" button in the header?
  - Via an empty state button when no goals exist?
  - Via multiple entry points?
- **Context**: Affects UI implementation and user discoverability
- **Impact**: Frontend component structure and navigation flow

**Q1.2: Skill Selection UI**
- **Question**: How should users select a skill from the organizational taxonomy?
  - Simple dropdown (if < 50 skills)?
  - Searchable dropdown/autocomplete (if 50-500 skills)?
  - Hierarchical tree selector (if skills are categorized)?
  - Multi-step wizard (select category → select skill → select level)?
- **Context**: Skills table structure is unknown; need to understand data volume and hierarchy
- **Impact**: Frontend component complexity, API requirements for skill data

**Q1.3: Inline Validation Timing**
- **Question**: When should field validation occur and display errors?
  - **Title**: On blur, on submit, or real-time after 2+ characters?
  - **Description**: On blur or only on submit?
  - **Deadline**: Immediately when date selected or on blur?
- **Context**: Affects user experience and perceived responsiveness
- **Impact**: Frontend validation logic and UX design

**Q1.4: Error Message Placement**
- **Question**: Where should validation errors be displayed?
  - Inline below each field (red text)?
  - Toast notification at top/bottom of screen?
  - Summary list at top of form?
  - Combination (inline + toast for API errors)?
- **Context**: Consistency with existing platform error handling patterns
- **Impact**: UI component design, accessibility (screen readers)

**Q1.5: Success Confirmation Flow**
- **Question**: After successful goal creation, what should happen?
  - Close form + show toast + return to goals list?
  - Stay on form for creating another goal (with "Create Another" option)?
  - Navigate to the newly created goal's detail page?
  - Show modal with next actions ("Add tasks", "View goal", "Create another")?
- **Context**: Affects user workflow and task completion efficiency
- **Impact**: Navigation logic, UI flow design

---

### US-002: View and Filter Personal Goals

**Q2.1: Filter UI Implementation**
- **Question**: How should filtering controls be implemented?
  - Dropdown filters (Status, Priority) above the list?
  - Chip/tag filters below search bar?
  - Sidebar filter panel (desktop) / bottom sheet (mobile)?
  - URL query parameters to enable deep linking?
- **Context**: Affects discoverability and allows bookmarking filtered views
- **Impact**: Frontend component structure, routing configuration

**Q2.2: Multiple Filter Behavior**
- **Question**: If user applies multiple filters (e.g., Status=in_progress AND Priority=1), how do they combine?
  - AND logic (show goals matching ALL criteria)?
  - OR logic (show goals matching ANY criteria)?
  - User-selectable (toggle between AND/OR)?
- **Context**: Affects result set and user expectations
- **Impact**: API query parameter design, backend filtering logic

**Q2.3: Sort Order Persistence**
- **Question**: Should sort order and filter selections persist?
  - Within session only (cleared on logout)?
  - Across sessions (saved to user preferences)?
  - Per device (localStorage) or per user (database)?
- **Context**: Affects user convenience vs. system complexity
- **Impact**: API requirements, user preferences data model

**Q2.4: Empty State Variations**
- **Question**: What empty states should be displayed?
  - No goals exist at all: "Create your first goal" message?
  - Goals exist but none match filter: "No goals match your filters. Clear filters?" message?
  - All goals are completed: Different message vs. no goals?
- **Context**: Affects user understanding and calls to action
- **Impact**: Frontend conditional rendering, copy/content creation

**Q2.5: Deadline Warning Threshold**
- **Question**: The spec says goals with deadlines "within 7 days" are highlighted. Clarify:
  - Does this include the 7th day (≤ 7 days) or exclude it (< 7 days)?
  - Should overdue goals (past deadline) have a different visual indicator?
  - What about goals due today?
- **Context**: Precision affects user trust in the system
- **Impact**: Frontend calculation logic, visual design

**Q2.6: Goal Card Display**
- **Question**: What information should display on each goal card in the list view?
  - Minimal: Title, status badge, progress bar, deadline?
  - Detailed: Above + description preview + task count + skill association?
  - User-configurable (list view vs. card view toggle)?
- **Context**: Affects information density and scan-ability
- **Impact**: Frontend component design, performance (more data = larger payloads)

---

### US-003: Update Goal Progress and Details

**Q3.1: Auto-Save Behavior**
- **Question**: How should auto-save work?
  - Trigger after 30 seconds of inactivity (no typing)?
  - Trigger immediately after each field change (debounced)?
  - Different behavior for different fields (immediate for checkbox, delayed for text)?
- **Context**: Spec says "auto-saved within 30 seconds" but implementation details unclear
- **Impact**: Frontend state management, API call frequency, user feedback

**Q3.2: Edit Mode Entry**
- **Question**: How does a user enter edit mode for a goal?
  - Click "Edit" button to make all fields editable?
  - Inline editing (click on field to edit, similar to Trello)?
  - Dedicated edit page/modal separate from view?
- **Context**: Affects interaction pattern and component architecture
- **Impact**: Frontend component complexity, navigation flow

**Q3.3: Discard Changes Confirmation**
- **Question**: When user clicks "Discard" or navigates away with unsaved changes:
  - Show "Discard unsaved changes?" confirmation modal always?
  - Only show if changes were made (dirty state)?
  - Different behavior if auto-save is pending vs. failed?
- **Context**: Prevents accidental data loss while avoiding unnecessary interruptions
- **Impact**: Frontend state tracking, modal logic

**Q3.4: Manual Progress Override**
- **Question**: Business Rule #5 says if no tasks exist, progress can be manually set. Clarify:
  - If user creates tasks after manually setting progress, does automatic calculation override the manual value?
  - Should system warn user "Creating tasks will override manual progress"?
  - Can user delete all tasks to return to manual progress mode?
- **Context**: Two-mode system (manual vs. automatic) can confuse users
- **Impact**: Business logic, UI feedback, user education

**Q3.5: Status Change Restrictions**
- **Question**: Business Rule #4 says status cannot regress without admin intervention. Clarify:
  - In the UI, should "completed" status option be hidden/disabled once goal is completed (for non-admins)?
  - Or show it but display error "Only administrators can revert completed goals"?
  - What's the use case for admin to revert status? Should it be a separate "Reopen Goal" action?
- **Context**: Affects user understanding and prevents confusion
- **Impact**: Authorization logic, UI component visibility rules

---

### US-004: Break Goals into Tasks

**Q4.1: Task Management UI Location**
- **Question**: Where do users manage tasks?
  - Within expanded goal card in list view?
  - On dedicated goal detail page?
  - In a modal/drawer overlay?
  - Separate tasks page/tab?
- **Context**: Affects navigation and context switching
- **Impact**: Frontend routing, component hierarchy

**Q4.2: Task Ordering**
- **Question**: Spec says "chronological or priority order" but:
  - Can user manually reorder tasks (drag-and-drop)?
  - Is there a task priority field (separate from goal priority)?
  - If "chronological," is it by created_at or deadline?
  - Is order purely visual or stored in database?
- **Context**: Affects user's ability to organize work
- **Impact**: Data model (order column?), API support, frontend implementation

**Q4.3: Task Completion Interaction**
- **Question**: How does a user mark a task complete?
  - Checkbox in task list (immediate save)?
  - Click task → detail view → mark complete button?
  - Swipe gesture on mobile?
  - Multiple selection for bulk completion?
- **Context**: Affects efficiency for users with many tasks
- **Impact**: Frontend interaction design, API requirements

**Q4.4: Task Deadline vs. Goal Deadline Validation**
- **Question**: Should task deadlines be validated against goal deadline?
  - Warn if task deadline is after goal deadline?
  - Prevent (reject) task deadline after goal deadline?
  - No validation (allow for planning purposes)?
- **Context**: Affects logical consistency and user expectations
- **Impact**: Frontend/backend validation logic

**Q4.5: Empty Tasks State**
- **Question**: When a goal has no tasks:
  - Show "Add tasks to track detailed progress" empty state?
  - Show nothing (just goal details)?
  - Automatically show "Add Task" form?
  - Show tip about manual progress vs. task-based progress?
- **Context**: Educates users about task benefits
- **Impact**: Frontend empty state design, user onboarding

---

### US-005: Delete Goals and Tasks

**Q5.1: Goal Deletion Permission**
- **Question**: Spec says "requires Administrator role for now." Clarify:
  - Is this a known limitation to be fixed soon, or intentional design?
  - Should we hide delete button for non-admins or show it disabled with tooltip?
  - What's the rationale for admin-only deletion? Data integrity, audit, or policy?
- **Context**: Affects user expectations and potential frustration
- **Impact**: Authorization logic, UI visibility, future roadmap

**Q5.2: Confirmation Modal Content**
- **Question**: What should the deletion confirmation modal say?
  - "Delete [Goal Title]? This action cannot be undone." (even though it's soft delete)?
  - "Delete [Goal Title] and its [X] tasks?"
  - Include option to "Archive instead of delete"?
  - Show consequences (removed from all reports, not visible to managers, etc.)?
- **Context**: User clarity on what deletion means
- **Impact**: Copy/content, UI modal design

**Q5.3: Task Deletion Without Confirmation**
- **Question**: Spec mentions confirmation for goal deletion but not task deletion. Clarify:
  - Should task deletion also require confirmation?
  - Or is it safe to allow immediate deletion (with undo toast)?
  - Different behavior for single task vs. bulk task deletion?
- **Context**: Prevents accidental deletions
- **Impact**: Frontend interaction flow

**Q5.4: Soft Delete Visibility**
- **Question**: After soft deletion (deleted_at set), where is the goal visible?
  - Nowhere (completely hidden from all views)?
  - In admin-only "Deleted Goals" view for recovery?
  - In audit log/history but not in main UI?
- **Context**: Data recovery and compliance requirements
- **Impact**: API filtering logic, admin UI requirements

---

## Priority 2: Important for UX (Should Answer)

### Offline Mode

**Q6.1: Offline Indicator Visibility**
- **Question**: How should offline status be communicated?
  - Always visible banner at top when offline?
  - Icon in header that changes color (green=online, gray=offline)?
  - Toast notification when going offline/online?
  - Combination of multiple indicators?
- **Context**: Users need to understand system state
- **Impact**: UI header design, notification system

**Q6.2: Pending Changes Display**
- **Question**: How should user see pending offline changes?
  - Badge count on sync icon ("3 changes pending")?
  - List of pending changes in a drawer/modal?
  - Visual indicator per goal card (cloud icon)?
  - No indication until sync attempt?
- **Context**: Transparency about what will be synced
- **Impact**: Frontend state tracking, UI components

**Q6.3: Sync Conflict Resolution**
- **Question**: Spec says "last-write-wins with user notification." What does notification look like?
  - Toast: "Your changes to [Goal] were overwritten by server"?
  - Modal: "Conflict detected. Server version: [X], Your version: [Y]. Choose one."?
  - Silent overwrite with icon indicator users can click for details?
- **Context**: User frustration if changes are lost silently
- **Impact**: Conflict detection logic, UI feedback design

**Q6.4: Retry Logic for Failed Sync**
- **Question**: Spec says "3 attempts with exponential backoff." Clarify:
  - After 3 failed attempts, what happens? Show error and stop?
  - Can user manually trigger retry?
  - Are failed changes queued indefinitely or discarded?
- **Context**: Edge case handling
- **Impact**: Error handling logic, user recovery options

---

### Performance & Loading States

**Q7.1: Loading State Granularity**
- **Question**: What loading indicators should be shown?
  - Skeleton loaders for goal list during initial fetch?
  - Spinner overlay for entire page?
  - Progress bar at top of page?
  - Per-component loading states (list, filters, task list)?
- **Context**: Affects perceived performance and user experience
- **Impact**: Frontend loading component design

**Q7.2: Optimistic Updates**
- **Question**: Should updates be optimistic (show immediately, then sync)?
  - For all operations (create, update, delete)?
  - Only for low-risk operations (mark task complete, update progress)?
  - Never (always wait for server confirmation)?
- **Context**: Perceived performance vs. data consistency
- **Impact**: Frontend state management complexity

---

### Internationalization

**Q8.1: Default Locale Determination**
- **Question**: How is user's locale determined?
  - From user profile preference?
  - From browser settings (navigator.language)?
  - From IP-based geolocation?
  - User can explicitly set in preferences?
- **Context**: Correct formatting for all users
- **Impact**: i18n initialization logic

**Q8.2: Translation Coverage Scope**
- **Question**: What text needs translation?
  - Static UI labels only (buttons, headers, labels)?
  - Error messages and validation feedback?
  - Success/confirmation messages?
  - User-generated content (goal titles, descriptions)?
- **Context**: User-generated content typically NOT translated
- **Impact**: i18n key coverage, translation budget

---

## Priority 3: Nice to Have (Can Defer)

### Additional Features

**Q9.1: Goal Templates**
- **Question**: Should system provide goal templates?
  - "Learn new programming language"
  - "Complete certification"
  - "Mentorship program"
- **Context**: Helps users get started faster
- **Impact**: Template data model, UI for template selection
- **Decision**: Out of scope for v1, defer to future iteration

**Q9.2: Goal Sharing/Collaboration**
- **Question**: Can users collaborate on goals?
  - Share goal with colleague for accountability?
  - Manager assigns goals to direct reports?
  - Team goals with multiple contributors?
- **Context**: Mentioned as out of scope in dependencies, confirming
- **Impact**: N/A for v1
- **Decision**: Confirmed out of scope per specification dependencies

**Q9.3: Notifications & Reminders**
- **Question**: Should system send reminders for upcoming deadlines?
  - Email notifications 7 days before, 1 day before?
  - In-app notifications?
  - Push notifications (if PWA)?
- **Context**: Mentioned as out of scope in dependencies, confirming
- **Impact**: N/A for v1
- **Decision**: Confirmed out of scope per specification dependencies

---

## Summary of Questions

**Total Questions Generated**: 29  
**Priority 1 (Critical)**: 19 questions  
**Priority 2 (Important)**: 9 questions  
**Priority 3 (Defer)**: 3 questions (confirmation only)

---

## Stakeholder Decisions & Answers

**Interview Date**: 2025-11-11  
**Stakeholders**: Product Owner (Sarah Johnson), UX Lead (Mike Chen)  
**Documented by**: GitHub Copilot (Phase 2 Refinement)

### Priority 1 Answers

**Q1.1: Goal Creation Form Access**
- **Decision**: Multiple entry points for better discoverability
  - Primary: "Create Goal" button in goals list header (always visible)
  - Secondary: Large centered button in empty state when no goals exist
  - Tertiary: Floating Action Button (FAB) on mobile devices
- **Rationale**: Provides consistent access while optimizing for different contexts

**Q1.2: Skill Selection UI**
- **Decision**: Searchable autocomplete dropdown with optional category filter
  - Assumption: 100-500 skills in taxonomy
  - Show top 10 matches initially, load more on scroll
  - Include "None" option since skill association is optional
- **Rationale**: Balances usability with technical performance for medium data sets
- **Impact**: Need API endpoint GET /api/skills?search={query}&limit=10 for autocomplete

**Q1.3: Inline Validation Timing**
- **Decision**: 
  - **Title**: Real-time validation on blur after field loses focus
  - **Description**: Validation only on submit (not intrusive for optional field)
  - **Deadline**: Immediate validation when date selected
- **Rationale**: Balance between helpful feedback and avoiding interrupting user's flow
- **Additional Rule**: All validations re-run on form submit as final check

**Q1.4: Error Message Placement**
- **Decision**: Combination approach
  - Inline errors below each field (red text with icon) for validation errors
  - Toast notification at top-right for API errors or success messages
  - Errors use ARIA live regions for screen reader accessibility
- **Rationale**: Field-level errors are contextual; system errors need global visibility

**Q1.5: Success Confirmation Flow**
- **Decision**: Close form + toast + return to goals list with new goal at top
  - Toast message: "Goal '[Goal Title]' created successfully"
  - Toast includes "Add Tasks" action button for quick follow-up
  - New goal highlighted with subtle animation (fade-in)
- **Rationale**: Completes the action cleanly; action button allows continuation if desired

---

**Q2.1: Filter UI Implementation**
- **Decision**: Dropdown filters above the list + URL query parameters
  - Status filter dropdown (All / Open / In Progress / Completed)
  - Priority filter dropdown (All / High (1) / Medium (2-3) / Low (4-5))
  - Sort dropdown (Newest / Oldest / Deadline / Priority / Progress)
  - Filters appear on desktop and mobile (responsive design)
  - URL format: /goals?status=in_progress&sort=deadline
- **Rationale**: Simple, discoverable, shareable filtered views

**Q2.2: Multiple Filter Behavior**
- **Decision**: AND logic (show goals matching ALL applied criteria)
- **Rationale**: Most intuitive for users; matches common filtering patterns (Gmail, Amazon, etc.)
- **Example**: Status=in_progress AND Priority=1 shows only high-priority goals in progress

**Q2.3: Sort Order Persistence**
- **Decision**: Persist across sessions in user preferences (database)
  - Stored in user_preferences table with key "goals_default_view"
  - Fallback: Newest first (created_at DESC) if no preference saved
- **Rationale**: Improves UX for returning users; minimal database impact
- **Impact**: Need user preferences API (may already exist)

**Q2.4: Empty State Variations**
- **Decision**: Three distinct empty states
  - **No goals at all**: "Start your career journey" with illustration + "Create Your First Goal" button
  - **No matches for filter**: "No goals match your filters" + "Clear Filters" button
  - **All completed**: "All goals completed! 🎉" + encouragement message + "Create New Goal" button
- **Rationale**: Contextual messages guide user to next action

**Q2.5: Deadline Warning Threshold**
- **Decision**: 
  - Goals due **within 7 days (inclusive)**: Yellow/warning indicator
  - Goals **overdue** (past deadline): Red/urgent indicator
  - Goals **due today**: Orange/immediate indicator
  - Calculation: Use user's timezone for "today"
- **Rationale**: Clear visual hierarchy helps prioritization
- **Visual**: Icon badges with tooltip on hover showing exact due date

**Q2.6: Goal Card Display**
- **Decision**: Detailed card view for better context
  - Display: Title (truncated at 60 chars), Status badge, Progress bar with %, Priority indicator, Deadline, Task count (X/Y completed)
  - Optional: First 100 characters of description (collapsed, expandable)
  - Skill badge if associated with skill
- **Rationale**: Provides sufficient context without overwhelming; mirrors common dashboard patterns

---

**Q3.1: Auto-Save Behavior**
- **Decision**: Debounced auto-save after 2 seconds of inactivity per field
  - Trigger: User stops typing for 2 seconds → save that field
  - Visual feedback: Saving spinner → "Saved" checkmark (fades after 2 seconds)
  - Different behavior: Checkboxes and dropdowns save immediately (no delay)
- **Rationale**: Balances user expectation with API efficiency; immediate for simple controls

**Q3.2: Edit Mode Entry**
- **Decision**: Dedicated edit page/view with explicit "Edit" button
  - From list: Click goal card → Goal detail view (read-only)
  - From detail: Click "Edit" button → Edit mode with form fields
  - "Save" and "Cancel" buttons in edit mode
- **Rationale**: Clear mode distinction prevents accidental edits; better on mobile

**Q3.3: Discard Changes Confirmation**
- **Decision**: Show confirmation only if changes were made (dirty state)
  - Modal message: "You have unsaved changes. Discard changes?"
  - Buttons: "Discard" (destructive), "Keep Editing" (primary)
  - Exception: If auto-save already succeeded, no confirmation needed
- **Rationale**: Prevents data loss while avoiding unnecessary interruptions

**Q3.4: Manual Progress Override**
- **Decision**: Two-mode system with clear indication
  - **Mode 1 (Manual)**: User sets progress slider (0-100%). Text: "Progress (Manual)"
  - **Mode 2 (Auto)**: System calculates from tasks. Text: "Progress (X/Y tasks)"
  - **Transition**: Creating first task → Modal: "Switch to automatic progress from tasks? Manual progress will be replaced." → User confirms
  - **Reverting**: Deleting all tasks → Returns to manual mode with progress reset to 0%
- **Rationale**: Explicit mode makes behavior predictable; prevents confusion

**Q3.5: Status Change Restrictions**
- **Decision**: Hide regressive status options for non-admins
  - For regular users: Once status is "completed", dropdown only shows "completed" (disabled/read-only)
  - For admins: Show all status options + tooltip explaining regression capability
  - Admin use case: Correcting mistaken completion or reopening goals for plan changes
  - UI label for admins: "Reopen Goal" link (separate from status dropdown) for clarity
- **Rationale**: Prevention better than error messages; clear admin capabilities

---

**Q4.1: Task Management UI Location**
- **Decision**: On dedicated goal detail page below goal information
  - Goal detail page structure: Goal info card → Tasks section → Add task form
  - Tasks displayed as expandable list (collapsed by default on mobile)
  - Quick add: "+ Add Task" button always visible at bottom of tasks section
- **Rationale**: Keeps context (goal + tasks) together; doesn't clutter list view

**Q4.2: Task Ordering**
- **Decision**: User-controlled manual ordering with drag-and-drop (desktop) / move buttons (mobile)
  - Default: Tasks ordered by created_at (chronological)
  - User can drag to reorder → Stores order_index in database
  - Alternative sort: Button to "Sort by Deadline" (temporary view, not saved)
- **Rationale**: Users know best how to organize their tasks
- **Impact**: Add order_index INT column to goal_tasks table

**Q4.3: Task Completion Interaction**
- **Decision**: Checkbox in task list with immediate save
  - Click checkbox → Instant visual update (optimistic) → API call in background
  - On success: Task marked complete with strikethrough + timestamp
  - On failure: Revert checkbox + error toast
  - Bulk completion: Shift+click selects multiple, "Mark Complete" button appears
- **Rationale**: Low-friction interaction for frequent action; bulk for power users

**Q4.4: Task Deadline vs. Goal Deadline Validation**
- **Decision**: Warning (not blocking) if task deadline > goal deadline
  - Yellow warning icon with tooltip: "Task deadline is after goal deadline"
  - User can proceed (might be planning past goal completion)
  - No hard validation/rejection
- **Rationale**: Flexible for planning while surfacing potential issues

**Q4.5: Empty Tasks State**
- **Decision**: Informative empty state with education
  - Message: "Break this goal into smaller tasks to track detailed progress"
  - Sub-message: "Tasks automatically calculate your progress percentage"
  - Button: "Add Your First Task"
  - Alternative: "Set progress manually" link (for users who don't want tasks)
- **Rationale**: Educates users on feature benefits without forcing usage

---

**Q5.1: Goal Deletion Permission**
- **Decision**: Keep as Admin-only for v1, plan to extend in future
  - Rationale: Conservative approach to prevent accidental data loss
  - UI: Hide delete button for non-admins (don't show disabled)
  - Future (v2): Allow goal owners to delete their own goals with stronger confirmation
- **Roadmap Note**: Revisit in iteration 17 after user feedback on v1

**Q5.2: Confirmation Modal Content**
- **Decision**: Honest messaging about soft delete
  - Title: "Delete goal '[Goal Title]'?"
  - Message: "This goal and its [X] task(s) will be removed from your view. Administrators can restore deleted goals if needed."
  - Buttons: "Cancel" (primary), "Delete" (destructive, red)
- **Rationale**: Transparent about what happens; mentions recoverability

**Q5.3: Task Deletion Without Confirmation**
- **Decision**: Immediate deletion with undo toast
  - Click delete icon → Task removed immediately → Toast: "Task deleted. Undo?"
  - Undo available for 10 seconds → Then permanently saved
  - Multiple deletions: Undo stack (last 5 deletions)
- **Rationale**: Fast interaction with safety net; common pattern (Gmail, Slack)

**Q5.4: Soft Delete Visibility**
- **Decision**: Admin-only recovery view
  - Regular users: Deleted goals completely hidden from all views
  - Admins: "Deleted Goals" link in admin menu → List with "Restore" action
  - Retention: Keep deleted goals for 90 days, then hard delete
- **Rationale**: Clean user experience; admin safety net; compliance with data retention

---

### Priority 2 Answers

**Q6.1: Offline Indicator Visibility**
- **Decision**: Combination of header icon + banner when offline
  - Header: Cloud icon (green=online, gray=offline) with tooltip
  - Banner: Yellow info banner appears when going offline: "You're offline. Changes will sync when you're back online."
  - Banner dismissible but reappears if still offline
- **Rationale**: Non-intrusive persistent indicator + clear notification on state change

**Q6.2: Pending Changes Display**
- **Decision**: Badge on sync icon + detailed drawer
  - Sync icon shows badge count when changes pending: "🔄 (3)"
  - Click icon → Opens drawer showing pending changes list
  - Each item: Action (Created/Updated), Goal title, Timestamp
  - Drawer has "Sync Now" button to manually trigger sync
- **Rationale**: Transparency without cluttering main UI

**Q6.3: Sync Conflict Resolution**
- **Decision**: Informative toast with access to details
  - Toast (yellow, 10 seconds): "Changes to [Goal Title] were overwritten by server version."
  - Toast has "View Details" button → Opens modal showing diff
  - Modal shows: Your version, Server version, Option to "Keep Local as New Goal"
- **Rationale**: Balances automatic resolution with user awareness and recovery option

**Q6.4: Retry Logic for Failed Sync**
- **Decision**: Retry 3 times, then require manual intervention
  - After 3 failures: Red badge on sync icon, Error toast: "Sync failed. Check connection and try again."
  - User can click "Retry" manually
  - Failed changes stay queued indefinitely until successful or user discards
  - Option to "Discard Pending Changes" in settings
- **Rationale**: Doesn't lose data but doesn't retry endlessly

---

**Q7.1: Loading State Granularity**
- **Decision**: Skeleton loaders for progressive loading
  - Initial load: Skeleton cards (3-5) while fetching goals
  - Filter change: Shimmer effect on existing cards during re-fetch
  - Infinite scroll: Spinner at bottom when loading more
  - Individual operations: Inline spinners (e.g., saving indicator on field)
- **Rationale**: Modern, perceived performance improvement

**Q7.2: Optimistic Updates**
- **Decision**: Optimistic for low-risk operations only
  - **Optimistic**: Task completion, Progress updates, Goal status changes
  - **Non-optimistic**: Goal creation, Goal deletion, Task creation/deletion
  - On failure: Revert with clear error indication
- **Rationale**: Balance responsiveness with data integrity

---

**Q8.1: Default Locale Determination**
- **Decision**: User profile preference > browser settings
  - Check user_preferences.locale first (if user set explicitly)
  - Fall back to browser navigator.language
  - User can change in Settings → Language & Region
  - Supported locales: en-US (default), en-GB, es-ES, fr-FR, de-DE, ja-JP (to start)
- **Rationale**: User choice takes priority; sensible defaults

**Q8.2: Translation Coverage Scope**
- **Decision**: All static text, not user-generated content
  - **Translate**: UI labels, buttons, error messages, success messages, tooltips, placeholder text, empty state messages
  - **Do NOT translate**: Goal titles, descriptions, task titles, task descriptions (user-generated)
  - **Exception**: System-generated messages in activity logs translated
- **Rationale**: Standard practice; users expect their content in their language

---

### Priority 3 Confirmations

**Q9.1: Goal Templates** - **CONFIRMED OUT OF SCOPE** for v1
**Q9.2: Goal Sharing/Collaboration** - **CONFIRMED OUT OF SCOPE** for v1  
**Q9.3: Notifications & Reminders** - **CONFIRMED OUT OF SCOPE** for v1

---

## Key Decisions Summary

1. **Multi-mode entry points** for goal creation (header button, empty state, FAB)
2. **Auto-save with 2-second debounce** for text fields, immediate for controls
3. **Dedicated edit mode** with explicit Save/Cancel (not inline editing)
4. **Manual vs. Auto progress** with clear mode indication and transition prompts
5. **Task ordering stored in database** (order_index column) with drag-and-drop
6. **Immediate task completion** with checkbox (optimistic updates)
7. **Undo toast for task deletion** (10-second window)
8. **Admin-only goal deletion** for v1, planned for owners in v2
9. **Skeleton loaders** for better perceived performance
10. **Combination offline indicators** (header icon + banner)

## Impact on Implementation

**New API Requirements**:
- GET /api/skills?search={query}&limit=10 for skill autocomplete
- User preferences API for storing default view settings (may exist)

**New Database Changes**:
- Add order_index INT to goal_tasks table for manual task ordering

**Next Steps**:
- Update description.md with all refined details
- Add UX flow diagrams with Mermaid
- Update progress.md with Phase 2 completion
