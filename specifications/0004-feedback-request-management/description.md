---
type: feature_specification
feature_number: 0004
feature_name: feedback-request-management
version: 2.0.0
created: 2025-11-13
last_updated: 2025-11-13
status: refined
phase: 2_refine
current_phase_status: completed
repositories:
  - cpr-meta
  - cpr-api
  - cpr-ui
related_documents:
  - ../../constitution.md
  - ../../architecture.md
  - ../../features-list.md
refinement_summary:
  questions_asked: 10
  major_changes: 7
  stakeholder: Vyacheslav Kozyrev
  refinement_date: 2025-11-13
---

# Feedback Request Management

> **Specification ID**: SPEC-0004  
> **Feature**: feedback-request-management  
> **Priority**: High  
> **Complexity**: Medium

## Executive Summary

Feedback Request Management enables employees to proactively request structured feedback from colleagues, managers, and stakeholders with clear context about projects, goals, and specific areas of interest. This feature facilitates continuous feedback culture by providing a formal mechanism to solicit input while reducing the friction of informal feedback requests. Requestors can specify project or goal context, include custom messages explaining what feedback they're seeking, and set optional due dates to manage timing expectations.

**Business Impact**: Empowers employees to drive their own development by seeking targeted feedback when needed, increases feedback frequency and quality through structured requests, and supports performance review preparation by gathering comprehensive feedback data throughout the review cycle.

---

## Core User Stories

### US-001: Create Feedback Request
**As a** registered employee  
**I want** to request feedback from specific colleagues with context about projects or goals  
**So that** I can gather targeted input to support my professional development and performance reviews

**Acceptance Criteria**:
- [ ] I can access feedback request creation via: "Request Feedback" button in main navigation (top-right), empty state button (if no requests), or from goal detail page ("Request Feedback" action in goal menu with goal pre-selected)
- [ ] I can create a feedback request with **one or more recipients** (multi-select employees):
  - **Employee Multi-Select Autocomplete** with advanced filtering:
    - **Search Interface**:
      - Search input with placeholder: "Search by name, email, department..."
      - Minimum 2 characters to trigger search
      - Debounced at 300ms to reduce API calls
      - Shows skeleton loaders for first 3 items while searching
    - **Filter Chips** (above search, collapsible on mobile):
      - Department dropdown (multi-select): Shows all departments, default "All"
      - Location dropdown (multi-select): Shows all office locations, default "All"
      - Role/Title filter: Dropdown with common roles (Engineer, Manager, Designer, etc.)
      - "Clear All Filters" link appears when any filter active
    - **Search Results Display** (three-line format per item):
      - Line 1: Display name (bold, 18px) + optional badge (Manager, Direct Report)
      - Line 2: Job title (gray, 14px)
      - Line 3: Department • Location (light gray, 12px)
      - Avatar/photo on left (40px circle)
      - Checkbox on right for multi-select
    - **Search Behavior**:
      - Searches by: first name, last name, display name, email, department, job title
      - Filters out: deleted/inactive employees, myself (cannot request feedback from self)
      - Returns top 10 matches, infinite scroll loads more
      - Sort order: Relevance (exact name match > starts-with > contains > department match)
      - Shows badge indicators: "Your Manager", "Direct Report", "Same Department"
    - **Multi-Select Behavior**:
      - Selected employees shown as chips below search input
      - Each chip shows: name + department + remove (X) button
      - Maximum 20 recipients per request (enforced with error message)
      - Chips are reorderable via drag-and-drop (optional, desktop only)
      - "Select All" checkbox appears if filtered results < 20 employees
      - Validation: Must select at least 1 recipient to enable "Send Request"
- [ ] I can optionally associate the request with a project (searchable dropdown):
  - Shows only my projects where I'm owner or team member
  - Displays project title and status badge (Active/Completed/On Hold)
  - Search filters by project title (minimum 2 characters)
  - Shows "No projects found" if no matches
- [ ] I can optionally associate the request with a goal (searchable dropdown):
  - Shows only my goals (not team/org goals unless I'm owner)
  - Displays goal title, status, and progress percentage
  - Search filters by goal title (minimum 2 characters)
  - Groups goals by status: Open, In Progress, Completed (Open first)
  - Shows "No goals found" if no matches
- [ ] I can include an optional message (up to 500 characters) explaining what feedback I'm seeking:
  - Multiline textarea with 3 rows initial height, auto-expands up to 8 rows
  - Character counter shows remaining characters: "450 characters remaining" (green when > 100, yellow when 50-100, red when < 50)
  - Counter position: bottom-right of textarea
  - Placeholder text: "What specific feedback would you like? (Optional)"
  - Helper text below field: "Consider mentioning specific projects, achievements, or areas you'd like feedback on"
- [ ] I can set an optional due date using Material-UI date picker:
  - Min date: Today (cannot select past dates)
  - Max date: No limit (but shows warning if > 90 days)
  - Quick select chips displayed above calendar: "+3 days", "+7 days", "+14 days", "+30 days"
  - Quick select automatically closes picker and sets date
  - Shows warning below picker if < 3 days selected: "⚠ Short turnaround - consider allowing more time for thoughtful feedback" (warning only, not blocking)
  - Shows info message if > 90 days: "ℹ Consider a shorter timeframe to ensure timely feedback"
  - Date format displays in user's locale (MM/DD/YYYY or DD/MM/YYYY)
- [ ] Form validates in real-time and on submit:
  - Employee: Required, validated on blur, error shown inline: "Please select an employee to request feedback from"
  - Project: Optional, validated on blur if selected, error if project deleted/invalid: "Selected project is no longer available"
  - Goal: Optional, validated on blur if selected, error if goal deleted/invalid: "Selected goal is no longer available"
  - Message: Optional, validated on change, error if exceeds 500 chars: "Message must be 500 characters or less (current: X)"
  - Due Date: Optional, validated on selection, error if past date: "Due date must be today or in the future"
- [ ] System prevents duplicate requests with intelligent detection:
  - **Duplicate Definition**: Same requestor + same recipient set (all selected employees) + same goal (if specified) + same project (if specified)
  - Check occurs on form submit (not during selection, to allow users to build recipient list)
  - **Partial Duplicate Handling**: If subset of selected employees already have active request:
    - Show warning dialog: "Duplicate Recipients Detected"
    - Message: "[N] of your selected recipients already have an active request for this [goal/project]:
      - [Employee Name 1]
      - [Employee Name 2]"
    - Options:
      - "Remove Duplicates & Continue" (removes duplicate recipients from selection, proceeds)
      - "View Existing Requests" (navigates to sent requests, filters by those employees)
      - "Cancel" (stays on form with full selection)
  - **Full Duplicate**: If ALL selected employees have active request:
    - Show error: "All selected recipients already have active requests for this [goal/project]. Please view your existing requests."
    - Only option: "View Existing Requests" or "Cancel"
- [ ] "Send Request" button behavior:
  - Enabled only when: employee selected AND all validations pass AND not submitting
  - Label: "Send Request" (with paper plane icon)
  - Disabled state shows: grayed out button with tooltip "Please select an employee"
  - During submission: Button disabled, label changes to "Sending..." with spinner icon
  - Submission timeout: 10 seconds, then show error toast
- [ ] Upon successful creation:
  - Form closes immediately (modal dismissed or navigate away if standalone page)
  - Success toast appears top-right with green checkmark icon:
    - **Single recipient**: "Feedback request sent to [Employee Name]"
    - **Multiple recipients**: "Feedback request sent to [N] employees"
  - Toast includes action button: "View Request" (navigates to sent request detail)
  - Toast auto-dismisses after 5 seconds
  - Created request appears at top of "Sent Requests" list with highlight animation (fade-in + brief yellow background flash)
  - If created from goal detail page, return to goal detail page with toast
  - Auto-save draft (if existed) is cleared from localStorage
- [ ] Recipients receive notifications immediately (async, doesn't block UI):
  - **In-app notification** (for each recipient):
    - Bell icon badge increments by 1
    - Notification appears in notification panel
    - Content: "[Requestor Name] has requested feedback from you [about Goal/Project Name]"
    - Clicking notification navigates to Todo Requests page
  - **Email notification** (sent if user has email notifications enabled):
    - Subject: "Feedback Requested: [Requestor Name]"
    - Body includes:
      - Requestor name and avatar
      - Request message (if provided)
      - Due date (if provided) with **"Add to Calendar"** link (generates .ics file)
      - Goal/project context (if associated)
      - "Respond Now" CTA button (deep link to todo request)
      - Footer: "You can respond at your convenience through the CPR platform"
    - Email sent within 5 minutes of request creation (queued, not blocking)
- [ ] API error handling with specific error messages displayed as toast (top-right, red, with error icon, auto-dismiss after 7 seconds):
  - 400 + "employee_not_found": "The selected employee could not be found. Please try another."
  - 400 + "duplicate_request": "You already have an active request for this employee. Please view your sent requests."
  - 400 + "invalid_goal": "The selected goal is no longer available. Please select another or remove the goal."
  - 400 + "invalid_project": "The selected project is no longer available. Please select another or remove the project."
  - 403 + "self_request": "You cannot request feedback from yourself."
  - 429 + "rate_limit": "You've created too many requests today. Please try again tomorrow."
  - 500 or network error: "Unable to send feedback request. Please check your connection and try again."
  - Timeout: "Request timed out. Please try again."
- [ ] **Auto-save Draft** (to support multi-session request preparation):
  - Form state auto-saves to browser localStorage every 30 seconds if form is dirty
  - Saved state includes: selected employees, project, goal, message, due date
  - Storage key: `feedback_request_draft_${employeeId}`
  - On form open, check for draft:
    - If draft exists and < 7 days old: Show info banner at top: "You have an unsaved draft from [relative time]. [Load Draft] [Discard Draft]"
    - If draft exists and ≥ 7 days old: Auto-discard, show no banner
  - "Load Draft" button: Populates form fields with draft data, hides banner
  - "Discard Draft" button: Clears localStorage, hides banner
  - Draft is cleared on successful submit or explicit discard
  - Draft persists across browser sessions (until submitted, discarded, or 7 days old)
  - **Offline behavior**: Draft saves even when offline, will be loaded on next online session
- [ ] "Cancel" button behavior:
  - Label: "Cancel" (secondary button, gray)
  - Position: Left of "Send Request" button in form footer
  - If form is pristine (no data entered) and no draft exists: Closes form immediately without confirmation
  - If form has data (dirty state): Shows confirmation dialog:
    - Title: "Discard request?"
    - Message: "Are you sure you want to discard this feedback request? Your changes will be saved as a draft."
    - Options: "Keep Editing" (primary, closes dialog), "Discard" (destructive red, closes form, draft remains in localStorage)
  - Pressing Escape key triggers Cancel button behavior

**Edge Cases**:
- [ ] Requesting from employee in different department: Allowed (cross-functional feedback encouraged)
- [ ] Requesting from manager: Allowed and encouraged (shows success message: "Feedback request sent to your manager, [Name]")
- [ ] Requesting from direct report: Allowed (upward feedback supported, shows message: "Upward feedback request sent to [Name]")
- [ ] Requesting from C-level executives: Allowed (no special restrictions)
- [ ] Message with only whitespace: Trimmed automatically, treated as NULL/empty (optional field, no error)
- [ ] Message with emoji or special characters: Allowed and preserved (UTF-8 support, only HTML tags stripped)
- [ ] Message exceeding 500 characters while typing: Character counter turns red, shows "X characters over limit", submit button disabled with tooltip "Message is too long"
- [ ] Selecting deleted/archived project: Form shows inline error below dropdown: "❌ This project is no longer available. Please select another or remove this association."
- [ ] Selecting deleted/completed goal: Form shows inline error below dropdown: "❌ This goal is no longer available. Please select another or remove this association."
- [ ] Employee search API timeout (>3 seconds): Show error state in dropdown: "⚠ Search unavailable. Please try again." with retry button
- [ ] Employee search returns 500+ results: Show only top 10, message at bottom: "Showing top 10 results. Refine your search for more specific matches."
- [ ] Creating request while offline: 
  - Form submission queued in local storage
  - Show info toast: "You're offline. Request will be sent automatically when connection is restored."
  - Request appears in sent list with "Pending Sync" badge
  - Background sync attempts retry every 30 seconds when online
  - If sync fails after 3 attempts, show persistent error: "Failed to send request. Tap to retry."
- [ ] Due date in past manually entered: Rejected immediately on blur, date picker reverts to today, error shown: "Due date must be today or in the future"
- [ ] Due date set to today: Allowed (today is valid), no warning shown
- [ ] Multiple rapid clicks on "Send Request": Button disabled after first click, subsequent clicks ignored, "Sending..." state shown
- [ ] Form open for extended period (>30 minutes): On submit, revalidate employee/goal/project existence, show error if stale: "Data has changed. Please refresh and try again."
- [ ] User navigates away with unsaved data: Browser shows standard "Leave site?" confirmation if form is dirty
- [ ] Two users request feedback from same person simultaneously: Both succeed (no conflict, separate requests created)
- [ ] Recipient has 50+ pending feedback requests: Still allowed, no throttling on recipient side (only requestor limited to 50/day)
- [ ] User tries to exceed 50 requests per day limit: Form submit fails, error toast: "Daily limit reached. You can create up to 50 feedback requests per day. Try again tomorrow."
- [ ] Clicking "View Existing Request" in duplicate dialog: Navigates to Sent Requests page with filter pre-applied for that specific employee and auto-scrolls to matching request

### US-002: View Sent Feedback Requests
**As a** registered employee  
**I want** to view all feedback requests I've sent to others with per-recipient status tracking  
**So that** I can track who I've requested feedback from and follow up on pending responses

**Acceptance Criteria**:
- [ ] I can access sent requests via main navigation "Feedback" → "Sent Requests" tab
- [ ] Page displays paginated list of my sent requests (20 per page) with skeleton loaders during initial load
- [ ] Each request card displays:
  - **Header**: Request date (relative: "2 days ago"), due date with urgency badge, goal/project name (if any)
  - **Recipients Section**: 
    - **Single recipient**: Shows one line: Avatar + Name + Status badge
    - **Multiple recipients** (2-5): Shows list with avatars + names + individual status badges
    - **Many recipients** (6+): Shows first 3 + "+ [N] more" expandable link
  - **Message Preview**: First 100 characters with "Show more" link (expands inline)
  - **Progress Summary** (multi-recipient only): "[X] of [Y] responded" with mini progress bar
  - **Action Buttons**: "Send Reminder", "View Responses", "Cancel Request" (context-dependent)
- [ ] **Status badges per recipient**:
  - "Pending" (gray): No response yet, not overdue
  - "Overdue" (red + warning icon): Past due date, no response
  - "Responded" (green + checkmark): Feedback submitted
  - "Cancelled" (gray strikethrough): Request was cancelled
- [ ] Request cards with ANY overdue recipient show bold due date in red with warning icon in card header
- [ ] I can filter by status: All/Pending/Responded/Overdue using dropdown filter
- [ ] I can sort by: Newest (created_at DESC), Oldest (created_at ASC), Due Date (due_date ASC)
- [ ] Clicking a request card expands it to show: full message, complete project/goal details, full recipient list, per-recipient action buttons
- [ ] **Expanded card shows** (per recipient):
  - Recipient name, avatar, department, job title
  - Status badge with timestamp: "Responded 2 days ago" or "Pending since 5 days"
  - **Action buttons** (context-dependent):
    - "View Feedback" (if responded) - navigates to `/feedback/{feedbackId}` detail page
    - "Send Reminder" (if pending AND >3 days since request/last reminder) - available per recipient
    - "Cancel for [Name]" (if pending) - removes individual recipient from request
  - Last reminder sent timestamp (if applicable): "Last reminded 1 day ago"
- [ ] **"Send Reminder" behavior** (per recipient):
  - Sends reminder notification to specific recipient only
  - Updates `feedback_request_recipients.last_reminder_at` for that recipient
  - Shows toast: "Reminder sent to [Recipient Name]"
  - Button disabled for that recipient for 48 hours (shows tooltip: "You can send another reminder in X hours")
  - **Bulk Reminder**: If multiple recipients pending, show "Remind All" button that sends to all eligible recipients (not reminded in last 48 hours)
- [ ] **"Cancel Request" behavior**:
  - **Single recipient**: Shows confirmation modal "Cancel feedback request to [Name]?"
    - Message: "This will permanently remove the request. [Name] will no longer see it in their todo list."
    - Options: "Yes, Cancel" (destructive red), "Keep Request" (primary gray)
    - On confirm: Soft-deletes entire request, shows toast "[Name]'s request cancelled"
  - **Multiple recipients** - two options:
    - "Cancel for [Name]" (individual): Sets `is_completed = TRUE` and `responded_at = NULL` for that recipient, shows as "Cancelled" status
    - "Cancel Entire Request" (in card menu): Cancels for ALL recipients, soft-deletes parent request
  - Cancelled requests: Recipients' notifications are silently cleared (no notification sent per Q5 answer)
  - **Partial cancellation**: If some recipients have responded and others are cancelled, request remains visible showing mixed statuses
- [ ] **"View Feedback" button**:
  - Navigates to `/feedback/{feedbackId}` - separate feedback detail page (per Q7 answer)
  - Opens in same tab by default, Ctrl+Click opens new tab
  - If multiple recipients have responded, shows "View All Responses ([N])" which opens list view of all feedback
- [ ] Page shows summary count: "Showing X of Y requests ([A] pending, [B] partially complete, [C] fully complete)"
- [ ] Empty state (no sent requests): "Start gathering feedback" with illustration + "Request Feedback" button

### US-002B: Manager View of Team Feedback Requests
**As a** manager  
**I want** to view feedback requests sent by and addressed to my direct reports  
**So that** I can support team development and identify coaching opportunities

**Acceptance Criteria**:
- [ ] Managers see additional tab in Feedback section: "Team Requests" (visible only to users with direct reports)
- [ ] Team Requests page shows two sub-tabs:
  - **"Sent by Team"**: Requests created by my direct reports
  - **"Received by Team"**: Requests addressed to my direct reports
- [ ] Display format identical to US-002 (Sent Requests) but with employee name prepended: "[Employee Name]: Request to [Recipients]"
- [ ] Manager has **READ-ONLY** access: Can view request details but CANNOT:
  - Send reminders on behalf of team members
  - Cancel requests
  - Edit request details
  - Create requests on behalf of team members
- [ ] Each request card shows: Team member name (bold), recipients, status, message preview
- [ ] Clicking card expands to show full details including per-recipient status
- [ ] Filter options: 
  - By team member (dropdown list of direct reports)
  - By status (All/Pending/Overdue/Responded)
  - By date range (Last 7 days/Last 30 days/Last 90 days/All time)
- [ ] Summary statistics shown at top:
  - "Team has [X] active requests ([Y] pending, [Z] overdue)"
  - "Team has received [A] requests ([B] pending, [C] completed)"
- [ ] Empty state: "Your team hasn't sent any feedback requests yet"
- [ ] Authorization: Only employees with `is_manager = TRUE` or employees with entries in `employees.manager_id` referencing them see this tab
- [ ] Performance: Manager view queries limited to direct reports only (not recursive/entire org hierarchy)

**Manager Use Cases**:
- Identify team members who aren't seeking feedback proactively
- See overdue requests that might need coaching/follow-up
- Understand patterns of cross-functional collaboration
- Support performance review preparation

**Edge Cases**:
- [ ] Manager promoted/demoted (direct reports changed): Team view updates immediately based on current `employees.manager_id` relationships
- [ ] Manager viewing request about themselves: Shows in both "My Requests" and "Team Requests" with indicator "(You)"
- [ ] Acting manager/temporary manager: Uses current manager_id relationships, no special historical tracking

**Edge Cases**:
- [ ] User with 500+ sent requests: Pagination performs efficiently, list renders within 500ms
- [ ] Filter change while scrolled down: Reset scroll to top, show shimmer during re-fetch
- [ ] Request to employee who has since been deleted: Show "[Employee Name] (no longer active)" with disabled reminder/view options
- [ ] Due date calculation uses user's timezone for "overdue" determination
- [ ] Sending reminder before 48-hour cooldown: Button disabled with tooltip "You can send another reminder in X hours"
- [ ] Network error loading requests: Show error state with retry button "Unable to load requests. Retry"
- [ ] Cancelling request that was just responded to: Show error toast "Cannot cancel - [Name] has already responded"

### US-003: View and Respond to Feedback Requests
**As a** registered employee  
**I want** to view feedback requests addressed to me and respond with structured feedback  
**So that** I can support my colleagues' development by providing thoughtful, timely feedback

**Acceptance Criteria**:
- [ ] I can access incoming requests via main navigation "Feedback" → "Todo Requests" tab with notification badge showing count
- [ ] Dashboard widget shows "Feedback Requests" card with count and "X overdue" warning if applicable
- [ ] Todo requests page displays paginated list of requests addressed to me (20 per page)
- [ ] Each request card displays: requestor name with avatar, request date, due date with urgency indicator, associated goal/project, requestor's message, "Respond" button
- [ ] Urgency indicators: "Due today" (orange badge), "Overdue" (red badge + bold), "Due soon" (yellow badge, within 3 days)
- [ ] Overdue requests appear at top of list by default (automatic sorting)
- [ ] I can filter by: All/Pending/Responded using dropdown
- [ ] I can sort by: Due Date (default), Received Date, Requestor Name
- [ ] Clicking "Respond" opens feedback submission form in modal or dedicated page
- [ ] Feedback form pre-fills: employee_id (requestor), goal_id and project_id if provided by request
- [ ] I must provide required fields: content (10-2000 characters), rating (1-5 scale)
- [ ] Content field is multiline textarea with character counter "X/2000 characters"
- [ ] Rating is displayed as 5-star selector with labels: 1=Needs Improvement, 3=Meets Expectations, 5=Exceeds Expectations
- [ ] Content field includes placeholder suggestions: "Consider describing specific examples, strengths observed, areas for growth..."
- [ ] I can preview my feedback before submitting using "Preview" button (shows formatted view)
- [ ] "Submit Feedback" button is enabled only when all required fields are valid
- [ ] Upon successful submission: Modal closes, request marked as "Responded" in list, toast shows "Feedback sent to [Name]"
- [ ] Submitted feedback is immediately visible to requestor in their received feedback list
- [ ] Request is removed from my todo list (moved to "Responded" filter)
- [ ] System tracks response timestamp for analytics and reporting
- [ ] I can save draft response (stores locally) and return later to complete
- [ ] Draft auto-saves every 30 seconds if content changed

**Empty State**:
- [ ] No pending requests: "You're all caught up! 🎉" message with illustration
- [ ] Sub-message: "When colleagues request your feedback, they'll appear here"
- [ ] Link: "Request feedback from others" redirects to request creation

**Edge Cases**:
- [ ] Responding after due date: Allowed but shows warning "This request was due on [Date]. Submit late feedback?"
- [ ] Request for deleted goal/project: Show context as "[Goal Name] (archived)" but still allow feedback submission
- [ ] Content with only whitespace: Rejected with error "Feedback content cannot be empty"
- [ ] Rating not selected: Form shows error "Please select a rating" on submit
- [ ] Network failure during submission: Show error toast, preserve draft, allow retry
- [ ] Multiple people respond to same request (if 360-degree): All responses saved separately, requestor sees all
- [ ] Very long feedback (2000 chars): Character counter turns red at 1900, prevents typing beyond 2000
- [ ] Requestor deleted their goal after request sent: Feedback form shows warning but allows submission (feedback stored with deleted goal reference)
- [ ] Submitting feedback while offline: Queue submission, show toast "Feedback saved offline. Will send when online"
- [ ] Draft exists when opening new response: Show notice "You have unsaved draft from [time]. Load draft or start fresh?"

### US-004: Manage Request Due Dates and Reminders
**As a** registered employee  
**I want** to set realistic due dates for feedback requests and send gentle reminders  
**So that** I can manage expectations while respecting colleagues' time and workload

**Acceptance Criteria**:
- [ ] When creating request, due date field shows suggested dates: "+3 days", "+7 days", "+14 days" as quick select buttons
- [ ] Custom date selection via date picker allows any future date (no maximum limit)
- [ ] System displays warning if due date < 3 days: "Short turnaround time. Consider allowing more time for thoughtful feedback"
- [ ] Warning is informational only, does not block request creation
- [ ] Recipient receives notification showing due date prominently: "Feedback requested by [Date]"
- [ ] Recipient's todo list displays requests sorted by due date (ascending) by default
- [ ] System automatically sends reminder notifications to recipient: 3 days before due date, 1 day before due date (only if request still pending)
- [ ] **Automatic reminder email content**:
  - Subject: "Reminder: Feedback request due [Date]"
  - Body: "Friendly reminder: [Requestor Name] requested feedback from you, due [Date]"
  - Includes original request message
  - **"Add to Calendar" button** generates .ics file with:
    - Event title: "Provide feedback for [Requestor Name]"
    - Date: Due date
    - Duration: 30 minutes (suggested time block)
    - Description: Request message + deep link to respond
    - Reminder: 1 day before
  - "Respond Now" CTA button (deep link to feedback form)
- [ ] I can manually send reminder from sent requests list using "Send Reminder" button (per-recipient cooldown: 48 hours between manual reminders to same person)
- [ ] Manual reminder button shows tooltip with next available send time if in cooldown: "You can send another reminder in X hours"
- [ ] Recipient can mark request as "In Progress" to signal they're working on it (removes from overdue appearance)
- [ ] "In Progress" status visible to requestor in sent requests list with label and timestamp "Started [time ago]"
- [ ] Requestor can extend due date from sent requests list: "Extend Deadline" button opens date picker
- [ ] Extending deadline sends notification to recipient: "[Name] extended feedback deadline to [New Date]"
- [ ] Extended deadline resets automatic reminder schedule (new reminders based on new date)
- [ ] No reminders sent for requests without due dates (open-ended requests)

**Edge Cases**:
- [ ] Due date on weekend: System still uses exact date, no business-day adjustment (user's choice)
- [ ] Due date on holiday: No automatic adjustment, user responsible for realistic dates
- [ ] Multiple reminders attempted in 48-hour window: Button disabled with helpful message
- [ ] Extending due date to earlier date than original: Allowed (user may have discussed with recipient)
- [ ] Extending due date after response submitted: Not allowed, button hidden for responded requests
- [ ] Automatic reminder fails to send (email service down): Retry 3 times, log failure for admin review
- [ ] Recipient has 20+ overdue requests: Special notification "You have X overdue feedback requests" with bulk actions
- [ ] Request with no due date: No urgency indicators, appears at bottom of todo list, no automatic reminders

---

## Business Rules

1. **Request Ownership & Multi-Recipient Model**: Each feedback request has one requestor (employee asking for feedback) and one or more recipients (employees providing feedback). Maximum 20 recipients per request. Requestor cannot request feedback from themselves. Recipients are tracked via `feedback_request_recipients` junction table.

2. **Duplicate Prevention**: System prevents duplicate active requests for same requestor-recipient set-goal-project combination. Duplicate = ALL selected recipients match an existing active request with same goal/project context. Partial duplicates allowed with warning (some recipients new, others duplicate).

3. **Due Date Constraints**: Due dates, when specified, must be today or future dates. Past dates are rejected. Due dates are optional - requests without due dates are open-ended. Due date applies to ALL recipients in a request (not per-recipient).

4. **Message Length**: Optional message field limited to 500 characters. Messages are trimmed and sanitized (HTML tags stripped) to prevent XSS attacks. Empty/whitespace-only messages are stored as NULL.

5. **Per-Recipient Status Lifecycle**: Each recipient in `feedback_request_recipients` tracks individual status:
   - `is_completed = FALSE, responded_at = NULL`: Pending
   - `is_completed = TRUE, responded_at = TIMESTAMP`: Responded (feedback submitted)
   - Parent request status = aggregation of all recipients (Pending/Partial/Complete)
   - Individual recipients can be cancelled without cancelling entire request

6. **Reminder Throttling**: Manual reminders throttled per recipient - minimum 48 hours between reminders to same person for same request. Automatic reminders sent at: 3 days before due date, 1 day before due date (only if due date exists and recipient still pending). Each recipient tracks `last_reminder_at` independently.

7. **Soft Deletion & Cancellation**:
   - **Full cancellation**: Sets `feedback_requests.is_deleted = TRUE, deleted_at = NOW()`. All recipients no longer see request.
   - **Partial cancellation**: Individual recipient can be removed (sets `is_completed = TRUE` with no `responded_at`). Request remains active for other recipients.
   - Requestors can view cancelled requests in history for 90 days.
   - No notification sent to recipients when request cancelled (silent removal per stakeholder decision).

8. **Context Association**: Requests can optionally be associated with one project and/or one goal. If associated, context must exist and be accessible at creation time. Feedback submission inherits these associations via `feedback.feedback_request_id` foreign key.

9. **Notification Requirements**: 
   - Creating request triggers notification to ALL recipients (in-app + email if enabled)
   - Email includes "Add to Calendar" .ics file generation for due date
   - Submitting feedback triggers notification to requestor
   - Reminders trigger notifications to specific recipient(s) only
   - Cancelling request does NOT trigger notification (silent)

10. **Access Control**: 
    - Employees can view their own sent requests and requests addressed to them
    - **Managers** can view feedback requests sent by and addressed to their direct reports (read-only access, determined by `employees.manager_id` relationship)
    - Administrators have full access for support and governance
    - Authorization enforced at API level, not database level

11. **Rate Limiting**: Maximum 50 feedback requests per requestor per day (across all recipients). System tracks by counting parent `feedback_requests` records created by user in last 24 hours. Prevents abuse and spam.

---

## Technical Requirements

### Performance Requirements
- **API Response Time**: GET requests < 200ms at 95th percentile, POST requests < 500ms at 95th percentile
- **List Page Load**: Initial render with skeleton loaders < 100ms, data display < 500ms for 20 items
- **Search Performance**: Employee search autocomplete responds < 300ms with debouncing (300ms delay)
- **Pagination**: Supports up to 10,000 requests per user with efficient cursor-based pagination
- **Concurrent Requests**: System handles 100 concurrent request creations without degradation

### Security Requirements
- **Authentication**: All endpoints require JWT authentication with valid employee context
- **Authorization**: Users can only create requests as themselves (requestor_id derived from JWT, not client input)
- **Data Validation**: Server-side validation for all inputs: employee existence, goal/project validity, message length, due date
- **XSS Prevention**: Message content sanitized using HTML purifier before storage, escaped on display
- **SQL Injection Prevention**: Parameterized queries for all database operations
- **Rate Limiting**: Max 50 feedback requests per user per day to prevent abuse

### Offline Mode Requirements
- **Request Creation**: Queue request creation locally when offline, sync when connection restored
- **View Sent Requests**: Cache last 50 sent requests for offline viewing (read-only)
- **View Todo Requests**: Cache last 20 todo requests for offline viewing (read-only)
- **Sync Strategy**: On reconnection, sync queued requests first, then fetch latest data
- **Conflict Resolution**: If request was cancelled server-side during offline period, notify user on sync

### Internationalization Requirements
- **UI Text**: All labels, buttons, messages, placeholders externalized to locale files
- **Date Formatting**: Due dates formatted according to user's locale (MM/DD/YYYY vs DD/MM/YYYY)
- **Relative Dates**: "2 days ago" localized using i18n library (e.g., "il y a 2 jours" in French)
- **Notification Content**: Email templates support localization based on recipient's language preference
- **Character Limits**: Message length (500 chars) applies to all languages, no byte limits

---

## API Design

### Endpoints

#### POST /api/feedback/request
**Purpose**: Create a new feedback request from authenticated user to one or more employees  
**Authentication**: Required (JWT Bearer token)  
**Request Body** (JSON):
```json
{
  "employee_ids": ["uuid", "uuid", ...] (required) - Array of 1-20 employee IDs to request feedback from",
  "project_id": "uuid (optional) - Associated project context",
  "goal_id": "uuid (optional) - Associated goal context",
  "message": "string (optional, max 500 chars) - Request message",
  "due_date": "ISO 8601 date string (optional) - When feedback is due"
}
```

**Response 201** (JSON):
```json
{
  "id": "uuid - Request identifier",
  "requestor_id": "uuid - Authenticated user's employee ID",
  "project_id": "uuid | null",
  "goal_id": "uuid | null",
  "message": "string | null",
  "due_date": "ISO 8601 date | null",
  "created_at": "ISO 8601 timestamp",
  "created_by": "uuid - User ID",
  "requestor": {
    "id": "uuid",
    "display_name": "string"
  },
  "recipients": [
    {
      "id": "uuid - feedback_request_recipients.id",
      "employee_id": "uuid",
      "employee": {
        "id": "uuid",
        "display_name": "string",
        "job_title": "string",
        "department": "string"
      },
      "is_completed": false,
      "responded_at": null,
      "last_reminder_at": null,
      "created_at": "ISO 8601 timestamp"
    }
  ],
  "project": {
    "id": "uuid",
    "title": "string"
  } | null,
  "goal": {
    "id": "uuid",
    "title": "string"
  } | null,
  "recipient_count": 3,
  "pending_count": 3,
  "responded_count": 0
}
```

**Error Responses**:
- **400**: Invalid input with specific errors:
  - `employee_ids_required`: "At least one recipient is required"
  - `employee_ids_max`: "Maximum 20 recipients allowed"
  - `employee_not_found`: "One or more employees not found: [ids]"
  - `self_request`: "Cannot request feedback from yourself"
  - `duplicate_request`: "Duplicate request detected for employees: [names]"
  - `invalid_goal`: "Goal not found or not accessible"
  - `invalid_project`: "Project not found or not accessible"
  - `message_too_long`: "Message exceeds 500 characters"
  - `invalid_due_date`: "Due date must be today or in the future"
- **401**: Unauthorized (invalid or missing JWT)
- **429**: Rate limit exceeded (>50 requests in 24 hours)
- **500**: Internal server error

**Validation Rules**:
- `employee_ids`: Required array, 1-20 elements, all must be valid non-deleted employees, cannot include requestor
- `project_id`: Optional, must be valid accessible project if provided
- `goal_id`: Optional, must be valid accessible goal if provided
- `message`: Optional, max 500 characters, HTML tags stripped, trimmed
- `due_date`: Optional, must be today or future date in ISO 8601 format

**Duplicate Detection Logic**:
- Check if requestor has existing active request with exact same recipient set + goal + project
- Partial duplicates (some recipients overlap) return warning in response but allow creation:
  ```json
  {
    "warning": "partial_duplicate",
    "duplicate_employees": ["uuid1", "uuid2"],
    "message": "2 recipients already have active requests"
  }
  ```

---

#### GET /api/me/feedback/request
**Purpose**: Get feedback requests sent by authenticated user (with multi-recipient support)  
**Authentication**: Required (JWT Bearer token)  
**Query Parameters**:
- `status` (optional): Filter by aggregated status - `all`, `pending`, `partial`, `complete`, `cancelled` (default: `all`)
  - `pending`: All recipients pending
  - `partial`: Some recipients responded, some pending
  - `complete`: All recipients responded
  - `cancelled`: Request cancelled
- `sort` (optional): Sort order - `newest`, `oldest`, `due_date` (default: `newest`)
- `page` (optional): Page number for pagination, 1-based (default: 1)
- `per_page` (optional): Items per page (default: 20, max: 100)

**Response 200** (JSON):
```json
{
  "data": [
    {
      "id": "uuid - feedback_requests.id",
      "requestor_id": "uuid",
      "project_id": "uuid | null",
      "goal_id": "uuid | null",
      "message": "string | null",
      "due_date": "ISO 8601 date | null",
      "created_at": "ISO 8601 timestamp",
      "requestor": {
        "id": "uuid",
        "display_name": "string"
      },
      "recipients": [
        {
          "id": "uuid - feedback_request_recipients.id",
          "employee_id": "uuid",
          "employee": {
            "id": "uuid",
            "display_name": "string",
            "job_title": "string",
            "department": "string"
          },
          "is_completed": false,
          "responded_at": "ISO 8601 timestamp | null",
          "last_reminder_at": "ISO 8601 timestamp | null",
          "feedback_id": "uuid | null - link to feedback if responded"
        }
      ],
      "project": {"id": "uuid", "title": "string"} | null,
      "goal": {"id": "uuid", "title": "string"} | null,
      "recipient_count": 5,
      "pending_count": 3,
      "responded_count": 2,
      "status": "pending | partial | complete | cancelled",
      "is_overdue": "boolean - true if any recipient overdue"
    }
  ],
  "pagination": {
    "current_page": 1,
    "per_page": 20,
    "total_items": 150,
    "total_pages": 8,
    "has_next": true,
    "has_previous": false
  },
  "summary": {
    "total": 150,
    "pending": 45,
    "partial": 30,
    "complete": 70,
    "cancelled": 5,
    "total_recipients": 850,
    "pending_recipients": 320,
    "responded_recipients": 530
  }
}
```

**Error Responses**:
- **401**: Unauthorized
- **400**: Invalid query parameters
- **500**: Internal server error

---

#### GET /api/me/feedback/request/todo
**Purpose**: Get feedback requests addressed to authenticated user (requests to respond to)  
**Authentication**: Required (JWT Bearer token)  
**Query Parameters**:
- `status` (optional): Filter by status - `pending`, `responded`, `all` (default: `pending`)
- `sort` (optional): Sort order - `due_date`, `received_date`, `requestor` (default: `due_date`)
- `page` (optional): Page number for pagination, 1-based (default: 1)
- `per_page` (optional): Items per page (default: 20, max: 100)

**Response 200** (JSON): Same structure as GET /api/me/feedback/request

**Error Responses**:
- **401**: Unauthorized
- **400**: Invalid query parameters
- **500**: Internal server error

---

#### PATCH /api/feedback/request/{id}
**Purpose**: Update feedback request (extend due date or cancel request)  
**Authentication**: Required (JWT Bearer token)  
**Authorization**: Only requestor can update their request  
**Request Body** (JSON):
```json
{
  "due_date": "ISO 8601 date string (optional) - New due date",
  "status": "cancelled (optional) - Set to cancel request"
}
```

**Response 200** (JSON): Updated FeedbackRequestDto

**Error Responses**:
- **401**: Unauthorized
- **403**: Forbidden (not the requestor)
- **404**: Request not found
- **400**: Invalid update (cannot modify responded request)
- **500**: Internal server error

---

#### POST /api/feedback/request/{id}/remind
**Purpose**: Send manual reminder to recipient about pending feedback request  
**Authentication**: Required (JWT Bearer token)  
**Authorization**: Only requestor can send reminder  
**Response 204**: No content (reminder sent successfully)

**Error Responses**:
- **401**: Unauthorized
- **403**: Forbidden (not the requestor)
- **404**: Request not found
- **400**: Cannot send reminder (already responded or too soon since last reminder)
- **429**: Rate limit exceeded (48-hour cooldown)
- **500**: Internal server error

**Rate Limiting**: Maximum 1 manual reminder per request per 48 hours

---

#### GET /api/team/feedback/request/sent
**Purpose**: Get feedback requests sent by manager's direct reports (Manager view)  
**Authentication**: Required (JWT Bearer token)  
**Authorization**: User must have direct reports (`employees.manager_id` references user's employee_id)  
**Query Parameters**: Same as GET /api/me/feedback/request plus:
- `employee_id` (optional): Filter by specific team member

**Response 200** (JSON): Same structure as GET /api/me/feedback/request with additional field:
```json
{
  "data": [
    {
      ...
      "team_member": {
        "id": "uuid",
        "display_name": "string",
        "job_title": "string"
      }
    }
  ]
}
```

**Error Responses**:
- **401**: Unauthorized
- **403**: Forbidden (user has no direct reports)
- **400**: Invalid query parameters

---

#### GET /api/team/feedback/request/received
**Purpose**: Get feedback requests addressed to manager's direct reports (Manager view)  
**Authentication**: Required (JWT Bearer token)  
**Authorization**: User must have direct reports  
**Query Parameters**: Same as GET /api/team/feedback/request/sent

**Response 200** (JSON): Same structure as sent requests

**Error Responses**: Same as sent requests

---

#### POST /api/feedback/request/{id}/recipient/{recipientId}/remind
**Purpose**: Send manual reminder to specific recipient about pending feedback request  
**Authentication**: Required (JWT Bearer token)  
**Authorization**: Only requestor can send reminder  
**Path Parameters**:
- `id`: feedback_requests.id (UUID)
- `recipientId`: feedback_request_recipients.id (UUID)

**Response 204**: No content (reminder sent successfully)

**Error Responses**:
- **401**: Unauthorized
- **403**: Forbidden (not the requestor)
- **404**: Request or recipient not found
- **400**: Cannot send reminder with specific reason:
  - `already_responded`: "This recipient has already responded"
  - `too_soon`: "Must wait 48 hours since last reminder"
  - `request_cancelled`: "This request has been cancelled"
- **429**: Rate limit exceeded
- **500**: Internal server error

**Rate Limiting**: Maximum 1 reminder per recipient per 48 hours (tracked via `last_reminder_at`)

---

#### DELETE /api/feedback/request/{id}/recipient/{recipientId}
**Purpose**: Cancel request for specific recipient (partial cancellation)  
**Authentication**: Required (JWT Bearer token)  
**Authorization**: Only requestor can cancel  
**Path Parameters**:
- `id`: feedback_requests.id (UUID)
- `recipientId`: feedback_request_recipients.id (UUID)

**Response 204**: No content (recipient removed successfully)

**Error Responses**:
- **401**: Unauthorized
- **403**: Forbidden (not the requestor)
- **404**: Request or recipient not found
- **400**: Cannot cancel with specific reason:
  - `already_responded`: "This recipient has already submitted feedback"
  - `last_recipient`: "Cannot remove last recipient - cancel entire request instead"
- **500**: Internal server error

**Behavior**: 
- Sets `is_completed = TRUE` with no `responded_at` timestamp (marks as cancelled)
- If this is the last active recipient, soft-deletes parent request
- No notification sent to recipient (silent removal)

---

## Data Model

### Database Schema

```sql
-- Feedback requests table (parent request with shared context)
CREATE TABLE feedback_requests (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    requestor_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    project_id UUID NULL REFERENCES projects(id) ON DELETE SET NULL,
    goal_id UUID NULL REFERENCES goals(id) ON DELETE SET NULL,
    message TEXT NULL CHECK (char_length(message) <= 500),
    due_date DATE NULL CHECK (due_date >= CURRENT_DATE OR due_date IS NULL),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    created_by UUID NULL REFERENCES users(id) ON DELETE SET NULL,
    updated_by UUID NULL REFERENCES users(id) ON DELETE SET NULL,
    deleted_at TIMESTAMP WITH TIME ZONE NULL,
    deleted_by UUID NULL REFERENCES users(id) ON DELETE SET NULL,
    is_deleted BOOLEAN NOT NULL DEFAULT FALSE,
    
    -- Constraints
    CONSTRAINT valid_due_date CHECK (due_date IS NULL OR due_date >= created_at::date)
);

-- Junction table for multiple recipients per request
CREATE TABLE feedback_request_recipients (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    feedback_request_id UUID NOT NULL REFERENCES feedback_requests(id) ON DELETE CASCADE,
    employee_id UUID NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    responded_at TIMESTAMP WITH TIME ZONE NULL,
    last_reminder_at TIMESTAMP WITH TIME ZONE NULL,
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    
    -- Constraints
    CONSTRAINT unique_request_recipient UNIQUE (feedback_request_id, employee_id),
    -- Prevent requestor from being recipient (checked at app level, but belt-and-suspenders here)
    CONSTRAINT check_recipient_valid CHECK (employee_id IS NOT NULL)
);

-- Indexes for feedback_requests
CREATE INDEX idx_feedback_requests_requestor ON feedback_requests(requestor_id) WHERE is_deleted = FALSE;
CREATE INDEX idx_feedback_requests_due_date ON feedback_requests(due_date) WHERE is_deleted = FALSE;
CREATE INDEX idx_feedback_requests_project ON feedback_requests(project_id) WHERE is_deleted = FALSE AND project_id IS NOT NULL;
CREATE INDEX idx_feedback_requests_goal ON feedback_requests(goal_id) WHERE is_deleted = FALSE AND goal_id IS NOT NULL;
CREATE INDEX idx_feedback_requests_created ON feedback_requests(created_at DESC) WHERE is_deleted = FALSE;

-- Indexes for feedback_request_recipients
CREATE INDEX idx_feedback_request_recipients_request ON feedback_request_recipients(feedback_request_id);
CREATE INDEX idx_feedback_request_recipients_employee ON feedback_request_recipients(employee_id);
CREATE INDEX idx_feedback_request_recipients_completed ON feedback_request_recipients(is_completed);
CREATE INDEX idx_feedback_request_recipients_pending ON feedback_request_recipients(employee_id, is_completed) WHERE is_completed = FALSE;

-- Trigger for updated_at on feedback_requests
CREATE TRIGGER set_feedback_requests_updated_at
    BEFORE UPDATE ON feedback_requests
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Trigger for updated_at on feedback_request_recipients
CREATE TRIGGER set_feedback_request_recipients_updated_at
    BEFORE UPDATE ON feedback_request_recipients
    FOR EACH ROW
    EXECUTE FUNCTION update_updated_at_column();

-- Add foreign key to feedback table to link responses back to requests
ALTER TABLE feedback 
ADD COLUMN feedback_request_id UUID NULL REFERENCES feedback_requests(id) ON DELETE SET NULL;

CREATE INDEX idx_feedback_request_link ON feedback(feedback_request_id) WHERE feedback_request_id IS NOT NULL;

-- NOTE: Duplicate prevention now handled at application level:
-- Same requestor + same employees (set) + same goal + same project
-- Cannot use DB unique constraint due to many-to-many recipient relationship
```

### Entity Relationships

```
feedback_requests (parent request)
├── requestor_id → employees.id (many-to-one) [who requested feedback]
├── project_id → projects.id (many-to-one, optional) [project context]
├── goal_id → goals.id (many-to-one, optional) [goal context]
├── created_by → users.id (many-to-one) [audit]
├── updated_by → users.id (many-to-one) [audit]
├── deleted_by → users.id (many-to-one) [audit]
└── recipients → feedback_request_recipients (one-to-many) [multiple recipients]

feedback_request_recipients (junction table)
├── feedback_request_id → feedback_requests.id (many-to-one) [parent request]
├── employee_id → employees.id (many-to-one) [recipient employee]
└── unique constraint on (feedback_request_id, employee_id)

feedback (links back to originating request)
└── feedback_request_id → feedback_requests.id (many-to-one, optional) [originating request]

Query patterns:
- Get all recipients for a request: JOIN feedback_request_recipients ON feedback_request_id
- Get all pending requests for employee: JOIN feedback_request_recipients WHERE employee_id = X AND is_completed = FALSE
- Check completion status: COUNT(*) vs COUNT(is_completed = TRUE) in recipients
```

---

## Type Safety

### C# DTOs (Backend - cpr-api)

**File**: `src/CPR.Application/Contracts/FeedbackDtos.cs`

```csharp
using System;
using System.ComponentModel.DataAnnotations;
using System.Text.Json.Serialization;

namespace CPR.Application.Contracts
{
    /// <summary>
    /// DTO for creating a new feedback request with multiple recipients
    /// </summary>
    public class CreateFeedbackRequestDto
    {
        /// <summary>Array of employee IDs to request feedback from (1-20 recipients)</summary>
        [JsonPropertyName("employee_ids")]
        [Required(ErrorMessage = "At least one recipient is required")]
        [MinLength(1, ErrorMessage = "At least one recipient is required")]
        [MaxLength(20, ErrorMessage = "Maximum 20 recipients allowed")]
        public List<Guid> EmployeeIds { get; set; } = new();

        /// <summary>Optional project context for the feedback request</summary>
        [JsonPropertyName("project_id")]
        public Guid? ProjectId { get; set; }

        /// <summary>Optional goal context for the feedback request</summary>
        [JsonPropertyName("goal_id")]
        public Guid? GoalId { get; set; }

        /// <summary>Optional message explaining the feedback request</summary>
        [JsonPropertyName("message")]
        [StringLength(500, ErrorMessage = "Message cannot exceed 500 characters")]
        public string? Message { get; set; }

        /// <summary>Optional due date for the feedback response</summary>
        [JsonPropertyName("due_date")]
        public DateTimeOffset? DueDate { get; set; }
    }

    /// <summary>
    /// DTO for individual recipient within a feedback request
    /// </summary>
    public class FeedbackRequestRecipientDto
    {
        /// <summary>Recipient record identifier</summary>
        [JsonPropertyName("id")]
        public Guid Id { get; set; }

        /// <summary>Employee ID of recipient</summary>
        [JsonPropertyName("employee_id")]
        public Guid EmployeeId { get; set; }

        /// <summary>Recipient employee details</summary>
        [JsonPropertyName("employee")]
        public EmployeeDetailDto? Employee { get; set; }

        /// <summary>Whether recipient has completed (responded or cancelled)</summary>
        [JsonPropertyName("is_completed")]
        public bool IsCompleted { get; set; }

        /// <summary>When recipient responded (null if pending)</summary>
        [JsonPropertyName("responded_at")]
        public DateTimeOffset? RespondedAt { get; set; }

        /// <summary>When last reminder was sent to this recipient</summary>
        [JsonPropertyName("last_reminder_at")]
        public DateTimeOffset? LastReminderAt { get; set; }

        /// <summary>Feedback ID if responded</summary>
        [JsonPropertyName("feedback_id")]
        public Guid? FeedbackId { get; set; }

        /// <summary>When this recipient was added to request</summary>
        [JsonPropertyName("created_at")]
        public DateTimeOffset CreatedAt { get; set; }
    }

    /// <summary>
    /// DTO for feedback request details with multiple recipients
    /// </summary>
    public class FeedbackRequestDto
    {
        /// <summary>Feedback request identifier</summary>
        [JsonPropertyName("id")]
        public Guid Id { get; set; }

        /// <summary>Employee ID who made the request</summary>
        [JsonPropertyName("requestor_id")]
        public Guid RequestorId { get; set; }

        /// <summary>Optional project context</summary>
        [JsonPropertyName("project_id")]
        public Guid? ProjectId { get; set; }

        /// <summary>Optional goal context</summary>
        [JsonPropertyName("goal_id")]
        public Guid? GoalId { get; set; }

        /// <summary>Optional request message</summary>
        [JsonPropertyName("message")]
        public string? Message { get; set; }

        /// <summary>Optional due date for response</summary>
        [JsonPropertyName("due_date")]
        public DateTimeOffset? DueDate { get; set; }

        /// <summary>When the request was created</summary>
        [JsonPropertyName("created_at")]
        public DateTimeOffset CreatedAt { get; set; }

        /// <summary>User ID who created the request</summary>
        [JsonPropertyName("created_by")]
        public Guid? CreatedBy { get; set; }

        /// <summary>Requestor employee details</summary>
        [JsonPropertyName("requestor")]
        public EmployeeSummaryDto? Requestor { get; set; }

        /// <summary>List of recipients for this request</summary>
        [JsonPropertyName("recipients")]
        public List<FeedbackRequestRecipientDto> Recipients { get; set; } = new();

        /// <summary>Total number of recipients</summary>
        [JsonPropertyName("recipient_count")]
        public int RecipientCount { get; set; }

        /// <summary>Number of pending recipients</summary>
        [JsonPropertyName("pending_count")]
        public int PendingCount { get; set; }

        /// <summary>Number of responded recipients</summary>
        [JsonPropertyName("responded_count")]
        public int RespondedCount { get; set; }

        /// <summary>Project details (if provided)</summary>
        [JsonPropertyName("project")]
        public ProjectSummaryDto? Project { get; set; }

        /// <summary>Goal details (if provided)</summary>
        [JsonPropertyName("goal")]
        public GoalSummaryDto? Goal { get; set; }

        /// <summary>Aggregated request status (computed): pending, partial, complete, cancelled</summary>
        [JsonPropertyName("status")]
        public string Status { get; set; } = null!;

        /// <summary>Whether ANY recipient is overdue (computed)</summary>
        [JsonPropertyName("is_overdue")]
        public bool IsOverdue { get; set; }
    }

    /// <summary>
    /// Extended employee details for recipient display
    /// </summary>
    public class EmployeeDetailDto
    {
        [JsonPropertyName("id")]
        public Guid Id { get; set; }

        [JsonPropertyName("display_name")]
        public string DisplayName { get; set; } = null!;

        [JsonPropertyName("job_title")]
        public string? JobTitle { get; set; }

        [JsonPropertyName("department")]
        public string? Department { get; set; }
    }

    /// <summary>
    /// DTO for updating feedback request
    /// </summary>
    public class UpdateFeedbackRequestDto
    {
        /// <summary>New due date (null to clear)</summary>
        [JsonPropertyName("due_date")]
        public DateTimeOffset? DueDate { get; set; }

        /// <summary>Status update (only 'cancelled' allowed)</summary>
        [JsonPropertyName("status")]
        [RegularExpression("^cancelled$", ErrorMessage = "Only 'cancelled' status is allowed")]
        public string? Status { get; set; }
    }

    /// <summary>
    /// DTO for feedback request list response with pagination
    /// </summary>
    public class FeedbackRequestListDto
    {
        [JsonPropertyName("data")]
        public List<FeedbackRequestDto> Data { get; set; } = new();

        [JsonPropertyName("pagination")]
        public PaginationDto Pagination { get; set; } = null!;

        [JsonPropertyName("summary")]
        public FeedbackRequestSummaryDto Summary { get; set; } = null!;
    }

    /// <summary>
    /// DTO for feedback request summary statistics (multi-recipient aware)
    /// </summary>
    public class FeedbackRequestSummaryDto
    {
        [JsonPropertyName("total")]
        public int Total { get; set; }

        [JsonPropertyName("pending")]
        public int Pending { get; set; }

        [JsonPropertyName("partial")]
        public int Partial { get; set; }

        [JsonPropertyName("complete")]
        public int Complete { get; set; }

        [JsonPropertyName("cancelled")]
        public int Cancelled { get; set; }

        [JsonPropertyName("total_recipients")]
        public int TotalRecipients { get; set; }

        [JsonPropertyName("pending_recipients")]
        public int PendingRecipients { get; set; }

        [JsonPropertyName("responded_recipients")]
        public int RespondedRecipients { get; set; }
    }

    /// <summary>
    /// DTO for pagination metadata
    /// </summary>
    public class PaginationDto
    {
        [JsonPropertyName("current_page")]
        public int CurrentPage { get; set; }

        [JsonPropertyName("per_page")]
        public int PerPage { get; set; }

        [JsonPropertyName("total_items")]
        public int TotalItems { get; set; }

        [JsonPropertyName("total_pages")]
        public int TotalPages { get; set; }

        [JsonPropertyName("has_next")]
        public bool HasNext { get; set; }

        [JsonPropertyName("has_previous")]
        public bool HasPrevious { get; set; }
    }
}
```

### TypeScript Interfaces (Frontend - cpr-ui)

**File**: `src/types/feedback.ts`

```typescript
/**
 * Request payload for creating feedback request
 */
export interface CreateFeedbackRequestDto {
  employee_id: string; // UUID
  project_id?: string | null; // UUID
  goal_id?: string | null; // UUID
  message?: string | null;
  due_date?: string | null; // ISO 8601 date string
}

/**
 * Feedback request details
 */
export interface FeedbackRequestDto {
  id: string; // UUID
  requestor_id: string; // UUID
  employee_id: string; // UUID
  project_id: string | null; // UUID
  goal_id: string | null; // UUID
  message: string | null;
  due_date: string | null; // ISO 8601 date string
  created_at: string; // ISO 8601 timestamp
  responded_at: string | null; // ISO 8601 timestamp
  last_reminder_at: string | null; // ISO 8601 timestamp
  created_by: string | null; // UUID
  requestor: EmployeeSummaryDto | null;
  employee: EmployeeSummaryDto | null;
  project: ProjectSummaryDto | null;
  goal: GoalSummaryDto | null;
  status: 'pending' | 'responded' | 'cancelled';
  is_overdue: boolean;
}

/**
 * Request payload for updating feedback request
 */
export interface UpdateFeedbackRequestDto {
  due_date?: string | null;
  status?: 'cancelled';
}

/**
 * Feedback request list response with pagination
 */
export interface FeedbackRequestListDto {
  data: FeedbackRequestDto[];
  pagination: PaginationDto;
  summary: FeedbackRequestSummaryDto;
}

/**
 * Summary statistics for feedback requests
 */
export interface FeedbackRequestSummaryDto {
  total: number;
  pending: number;
  responded: number;
  overdue: number;
}

/**
 * Pagination metadata
 */
export interface PaginationDto {
  current_page: number;
  per_page: number;
  total_items: number;
  total_pages: number;
  has_next: boolean;
  has_previous: boolean;
}

/**
 * Employee summary for request context
 */
export interface EmployeeSummaryDto {
  id: string; // UUID
  display_name: string;
}

/**
 * Project summary for request context
 */
export interface ProjectSummaryDto {
  id: string; // UUID
  title: string;
}

/**
 * Goal summary for request context
 */
export interface GoalSummaryDto {
  id: string; // UUID
  title: string;
}

/**
 * Query parameters for GET /api/me/feedback/request
 */
export interface GetSentRequestsParams {
  status?: 'pending' | 'responded' | 'cancelled' | 'all';
  sort?: 'newest' | 'oldest' | 'due_date';
  page?: number;
  per_page?: number;
}

/**
 * Query parameters for GET /api/me/feedback/request/todo
 */
export interface GetTodoRequestsParams {
  status?: 'pending' | 'responded' | 'all';
  sort?: 'due_date' | 'received_date' | 'requestor';
  page?: number;
  per_page?: number;
}
```

---

## Testing Strategy

### Unit Tests (Backend)

**Test File**: `tests/CPR.Application.Tests/Services/FeedbackServiceTests.cs`

**Test Cases**:
1. **CreateFeedbackRequestAsync**
   - ✅ Creates request with all valid required and optional fields
   - ✅ Rejects request when employee_id doesn't exist
   - ✅ Rejects request when requestor_id equals employee_id (self-request)
   - ✅ Rejects duplicate request (same requestor, employee, goal, project)
   - ✅ Allows new request after previous one responded
   - ✅ Rejects invalid project_id or goal_id
   - ✅ Trims and sanitizes message content
   - ✅ Rejects message exceeding 500 characters
   - ✅ Rejects due_date in the past
   - ✅ Accepts due_date as today
   - ✅ Creates request with null optional fields

2. **GetSentRequestsAsync**
   - ✅ Returns only requests created by specified requestor
   - ✅ Excludes soft-deleted requests
   - ✅ Filters by status correctly (pending, responded, all)
   - ✅ Sorts by newest, oldest, due_date correctly
   - ✅ Includes related entities (employee, project, goal)
   - ✅ Computes is_overdue correctly based on due_date and responded_at
   - ✅ Returns empty array when no requests exist

3. **GetTodoRequestsAsync**
   - ✅ Returns only requests addressed to specified employee
   - ✅ Excludes soft-deleted requests
   - ✅ Filters by status correctly
   - ✅ Sorts by due_date, received_date, requestor correctly
   - ✅ Places overdue requests first when sorting by due_date
   - ✅ Includes related entities
   - ✅ Returns empty array when no requests exist

4. **UpdateFeedbackRequestAsync**
   - ✅ Updates due_date successfully
   - ✅ Cancels request successfully (sets deleted_at)
   - ✅ Rejects update when user is not requestor
   - ✅ Rejects update when request already responded
   - ✅ Rejects due_date in past

5. **SendReminderAsync**
   - ✅ Sends reminder successfully and updates last_reminder_at
   - ✅ Rejects reminder within 48-hour cooldown period
   - ✅ Rejects reminder when request already responded
   - ✅ Rejects reminder when user is not requestor

### Integration Tests (Backend)

**Test File**: `tests/CPR.Api.Tests/Controllers/FeedbackControllerTests.cs`

**Test Cases**:
1. **POST /api/feedback/request**
   - ✅ Returns 201 with created request object
   - ✅ Returns 400 when employee_id missing
   - ✅ Returns 403 when requesting from self
   - ✅ Returns 400 when duplicate request exists
   - ✅ Returns 401 when not authenticated
   - ✅ Triggers notification to recipient

2. **GET /api/me/feedback/request**
   - ✅ Returns 200 with paginated list of sent requests
   - ✅ Respects status filter
   - ✅ Respects sort parameter
   - ✅ Returns 401 when not authenticated
   - ✅ Returns correct pagination metadata

3. **GET /api/me/feedback/request/todo**
   - ✅ Returns 200 with paginated list of todo requests
   - ✅ Respects status filter
   - ✅ Respects sort parameter
   - ✅ Returns 401 when not authenticated

4. **PATCH /api/feedback/request/{id}**
   - ✅ Returns 200 when extending due date
   - ✅ Returns 200 when cancelling request
   - ✅ Returns 403 when user is not requestor
   - ✅ Returns 404 when request doesn't exist
   - ✅ Returns 400 when trying to modify responded request

5. **POST /api/feedback/request/{id}/remind**
   - ✅ Returns 204 when reminder sent successfully
   - ✅ Returns 429 when reminder sent within 48-hour cooldown
   - ✅ Returns 403 when user is not requestor
   - ✅ Returns 400 when request already responded

### Unit Tests (Frontend)

**Test File**: `src/features/feedback/components/FeedbackRequestForm.test.tsx`

**Test Cases**:
1. **Form Rendering**
   - ✅ Renders all form fields correctly
   - ✅ Shows character counter for message field
   - ✅ Shows quick select buttons for due date (+3, +7, +14 days)
   - ✅ Disables submit button when required fields empty

2. **Form Validation**
   - ✅ Shows error when employee not selected
   - ✅ Shows error when message exceeds 500 characters
   - ✅ Shows warning when due date < 3 days
   - ✅ Prevents selecting past due date

3. **Form Submission**
   - ✅ Calls API with correct payload
   - ✅ Shows success toast on successful creation
   - ✅ Shows error toast on API failure
   - ✅ Disables submit during API call
   - ✅ Closes form after successful submission

4. **Duplicate Detection**
   - ✅ Shows warning modal when duplicate detected
   - ✅ Prevents submission when duplicate exists

### E2E Tests (Frontend)

**Test File**: `tests/e2e/feedback-requests.spec.ts`

**Test Cases**:
1. **Create Feedback Request Flow**
   - ✅ Navigate to request creation page
   - ✅ Select employee from autocomplete
   - ✅ Enter message
   - ✅ Select due date
   - ✅ Submit form
   - ✅ Verify toast message
   - ✅ Verify request appears in sent list

2. **View Sent Requests Flow**
   - ✅ Navigate to sent requests page
   - ✅ Verify requests displayed
   - ✅ Apply status filter
   - ✅ Verify filtered results
   - ✅ Change sort order
   - ✅ Verify sorted results

3. **Respond to Request Flow**
   - ✅ Navigate to todo requests page
   - ✅ Verify pending requests displayed
   - ✅ Click respond button
   - ✅ Fill feedback form
   - ✅ Submit feedback
   - ✅ Verify request marked as responded
   - ✅ Verify request removed from todo list

4. **Send Reminder Flow**
   - ✅ Navigate to sent requests
   - ✅ Expand pending request
   - ✅ Click send reminder
   - ✅ Verify toast message
   - ✅ Verify button disabled for 48 hours

### Performance Tests

**Test Scenarios**:
1. **Load Test - Create Requests**
   - 100 concurrent users creating requests
   - Response time < 500ms for 95th percentile
   - No errors under load

2. **Load Test - List Requests**
   - 500 concurrent users fetching sent requests
   - Response time < 200ms for 95th percentile
   - Efficient database query execution

3. **Stress Test - Large Result Sets**
   - User with 10,000+ requests
   - Pagination performs efficiently
   - UI remains responsive

---

## Success Metrics

1. **Adoption Rate**: 70% of employees create at least one feedback request within first 3 months of feature launch

2. **Response Rate**: 80% of feedback requests receive response within due date (or 14 days if no due date specified)

3. **Performance**: 95th percentile API response times meet targets (< 200ms GET, < 500ms POST)

4. **User Satisfaction**: Post-feature survey shows > 4.0/5.0 satisfaction rating for feedback request experience

5. **Feedback Frequency**: 30% increase in feedback submissions within 6 months compared to pre-feature baseline

---

## Constitutional Compliance Checklist

### ✅ Principle 1: Specification-First Development
- [x] Complete specification created before implementation begins
- [x] All requirements documented in cpr-meta repository
- [x] User stories, API contracts, and data models fully defined

### ✅ Principle 2: API Contract Consistency
- [x] C# DTOs defined with PascalCase properties and [JsonPropertyName] attributes
- [x] TypeScript interfaces defined with snake_case matching JSON contracts
- [x] Request and response shapes documented for all endpoints

### ✅ Principle 3: API Standards & Security
- [x] RESTful endpoints follow standard conventions (POST for create, GET for read, PATCH for update)
- [x] Proper HTTP status codes used (201 Created, 400 Bad Request, 401 Unauthorized, 403 Forbidden, 429 Rate Limited)
- [x] JWT authentication required for all endpoints
- [x] Rate limiting implemented (50 requests/day per user)

### ✅ Principle 4: Type Safety Everywhere
- [x] C# DTOs with validation attributes ([Required], [StringLength], [Range])
- [x] TypeScript interfaces with strict types and union types for status
- [x] Null safety handled explicitly in both languages

### ✅ Principle 5: Offline Mode
- [x] Request creation queued when offline, synced on reconnection
- [x] Sent and todo requests cached for offline viewing (read-only)
- [x] Sync strategy defined with conflict resolution
- [x] User notified when actions are queued for offline sync

### ✅ Principle 6: Internationalization
- [x] All UI text externalized to locale files
- [x] Date formatting respects user's locale
- [x] Relative dates localized (e.g., "2 days ago")
- [x] Email notification templates support localization

### ✅ Principle 7: Comprehensive Testing
- [x] Unit tests defined for service layer (backend)
- [x] Integration tests defined for API controllers
- [x] Unit tests defined for React components (frontend)
- [x] E2E tests defined for complete user workflows
- [x] Performance tests defined for load and stress scenarios

### ✅ Principle 8: Performance-First React Development
- [x] Performance targets set (list load < 500ms, initial render < 100ms)
- [x] Pagination implemented for large result sets
- [x] Skeleton loaders for perceived performance
- [x] Debouncing for search autocomplete (300ms)
- [x] Optimistic updates for immediate user feedback

### ✅ Principle 9: Strict Naming Conventions
- [x] JSON/API: snake_case (`employee_id`, `created_at`, `due_date`)
- [x] C# Properties: PascalCase with `[JsonPropertyName]` (`EmployeeId` → `"employee_id"`)
- [x] TypeScript: camelCase in code, snake_case in types matching API
- [x] Database: snake_case for tables and columns (`feedback_requests`, `requestor_id`)
- [x] URLs: kebab-case (`/api/feedback/request`, `/api/me/feedback/request/todo`)

### ✅ Principle 10: Security & Data Privacy
- [x] Authentication: JWT required for all endpoints
- [x] Authorization: Users can only create requests as themselves, view their own data
- [x] Input sanitization: XSS prevention for message content
- [x] SQL injection prevention: Parameterized queries
- [x] Rate limiting: Prevent abuse (50 requests/day, reminder cooldown)

### ✅ Principle 11: Database Design Standards
- [x] UUID primary keys used (`id UUID PRIMARY KEY`)
- [x] Foreign keys with proper ON DELETE cascades/set nulls
- [x] CHECK constraints for business rules (no_self_feedback_request, valid_due_date)
- [x] Indexes for query performance (requestor, employee, due_date, status)
- [x] Unique index for duplicate prevention
- [x] Audit fields (created_at, updated_at, created_by, updated_by)
- [x] Soft delete support (deleted_at, is_deleted)
- [x] Proper normalization and referential integrity

---

## Dependencies & Assumptions

### Dependencies
1. **Feature F001 - Personal Goal Management**: Feedback requests can be associated with goals
2. **Feature F011 - Project Team Management**: Feedback requests can be associated with projects
3. **Employee Directory**: Employee autocomplete search requires active employee list
4. **Notification System**: In-app and email notifications for request creation, reminders, and responses
5. **Authentication System**: JWT authentication with employee context

### Assumptions
1. **Email Service**: Assumes reliable email service (e.g., SendGrid) for notification delivery
2. **Employee Data**: Assumes employees table is populated with display_name for autocomplete
3. **Date Handling**: Assumes consistent timezone handling between client and server
4. **Browser Support**: Assumes modern browsers with ES6+ support for frontend
5. **Network**: Assumes users have internet connectivity for real-time operations (offline mode for caching only)
6. **User Behavior**: Assumes users will respect 48-hour reminder cooldown (enforced by API)
7. **Data Volume**: Assumes typical user has < 1000 feedback requests (performance tested up to 10,000)

---

## UI Specifications & Interaction Flows

### Screen Mockups

#### 1. Create Feedback Request Form

```
┌─────────────────────────────────────────────────────────────┐
│ Request Feedback                                       [X]  │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│ 📋 Auto-saved draft from 2 hours ago [Load] [Discard]      │
│                                                               │
│ Select Recipients * (0/20 selected)                          │
│ ┌───────────────────────────────────────────────────────┐  │
│ │ 🔍 Search by name, email, department...              │  │
│ └───────────────────────────────────────────────────────┘  │
│                                                               │
│ Filters: [All Departments ▼] [All Locations ▼] [All Roles ▼]│
│                                                               │
│ ┌─Selected Recipients (2)──────────────────────────────┐   │
│ │ 🧑 John Smith • Engineering [X]                       │   │
│ │ 👩 Sarah Johnson • Product [X]                         │   │
│ └───────────────────────────────────────────────────────┘   │
│                                                               │
│ Associated Project (Optional)                                │
│ [Select project... ▼]                                        │
│                                                               │
│ Associated Goal (Optional)                                   │
│ [Select goal... ▼]                                           │
│                                                               │
│ Message (Optional)                                           │
│ ┌───────────────────────────────────────────────────────┐  │
│ │ What specific feedback would you like?               │  │
│ │                                                        │  │
│ │                                                        │  │
│ └───────────────────────────────────────────────────────┘  │
│ 450 characters remaining                                     │
│ 💡 Consider mentioning specific projects, achievements...   │
│                                                               │
│ Due Date (Optional)                                          │
│ [Select date... 📅]  [+3 days] [+7 days] [+14 days]        │
│                                                               │
│ ⚠ Short turnaround - consider allowing more time            │
│                                                               │
│              [Cancel]  [Send Request ✈]                     │
└─────────────────────────────────────────────────────────────┘
```

#### 2. Sent Requests List (Multi-Recipient View)

```
┌─────────────────────────────────────────────────────────────┐
│ Feedback  [My Requests] [Sent Requests] [Team Requests]    │
├─────────────────────────────────────────────────────────────┤
│ Showing 15 of 45 requests (20 pending, 10 partial, 15 complete)│
│                                                               │
│ Filter: [All ▼]  Sort: [Newest First ▼]                     │
│                                                               │
│ ┌─Request to 3 recipients──────────────────────────────┐   │
│ │ 2 days ago • Due Nov 20 [⚠ 1 Overdue]               │   │
│ │ About: Q4 Performance Review (Goal)                   │   │
│ │                                                        │   │
│ │ Recipients (2/3 responded):                           │   │
│ │ • 🧑 John Smith [✓ Responded 1 day ago]              │   │
│ │ • 👩 Sarah Johnson [✓ Responded 2 hours ago]          │   │
│ │ • 👨 Mike Davis [⚠ Overdue - due yesterday]           │   │
│ │                                                        │   │
│ │ Message: "I'd appreciate feedback on..."              │   │
│ │ [Show more ▼]                                         │   │
│ │                                                        │   │
│ │ [View Responses (2)] [Remind Mike] [Cancel Request]  │   │
│ └───────────────────────────────────────────────────────┘   │
│                                                               │
│ ┌─Request to 5 recipients──────────────────────────────┐   │
│ │ 5 days ago • Due Nov 25                               │   │
│ │ About: Project Apollo Retrospective (Project)         │   │
│ │                                                        │   │
│ │ Recipients (5/5 pending):                             │   │
│ │ 🧑👩👨 + 2 more [All Pending]                          │   │
│ │                                                        │   │
│ │ [Expand] [Remind All] [Cancel Request]               │   │
│ └───────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

#### 3. Todo Requests List (Recipient View)

```
┌─────────────────────────────────────────────────────────────┐
│ Feedback Requests To Do                      [3 Overdue]    │
├─────────────────────────────────────────────────────────────┤
│ Filter: [Pending ▼]  Sort: [Due Date ▼]                     │
│                                                               │
│ ┌─[⚠ OVERDUE]─────────────────────────────────────────┐    │
│ │ John Smith requested feedback                        │    │
│ │ 5 days ago • Was due Nov 10 (3 days ago)           │    │
│ │ About: Q4 Performance Review (Goal)                  │    │
│ │                                                       │    │
│ │ "I'd appreciate your feedback on my communication    │    │
│ │ skills during the Q4 project presentations..."       │    │
│ │ [Show full message ▼]                                │    │
│ │                                                       │    │
│ │                      [Respond Now →]                 │    │
│ └──────────────────────────────────────────────────────┘    │
│                                                               │
│ ┌─[Due in 2 days]─────────────────────────────────────┐    │
│ │ Sarah Johnson requested feedback                     │    │
│ │ 3 days ago • Due Nov 15                             │    │
│ │ About: Project Apollo (Project)                      │    │
│ │                                                       │    │
│ │ "Looking for feedback on technical approach..."      │    │
│ │                                                       │    │
│ │                      [Respond Now →]                 │    │
│ └──────────────────────────────────────────────────────┘    │
│                                                               │
│ Empty state (when all caught up):                            │
│ ┌──────────────────────────────────────────────────────┐   │
│ │             🎉 You're all caught up!                  │   │
│ │                                                       │   │
│ │  When colleagues request your feedback,              │   │
│ │  they'll appear here.                                │   │
│ │                                                       │   │
│ │  [Request feedback from others →]                    │   │
│ └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

#### 4. Manager Team View

```
┌─────────────────────────────────────────────────────────────┐
│ Feedback  [My Requests] [Sent Requests] [Team Requests]    │
├─────────────────────────────────────────────────────────────┤
│ [Sent by Team] [Received by Team]                           │
│                                                               │
│ Team has 12 active requests (8 pending, 4 partial)          │
│ Team has received 18 requests (10 pending, 8 completed)     │
│                                                               │
│ Filter: [All Team Members ▼] [All Status ▼] [Last 30 days ▼]│
│                                                               │
│ ┌─Jane Doe: Request to 2 recipients──────────────────┐     │
│ │ 2 days ago • Due Nov 20                              │     │
│ │ About: User Research Project (Project)               │     │
│ │                                                       │     │
│ │ Recipients: John Smith (✓ Responded), Mike (Pending) │     │
│ │ Message: "Seeking feedback on research methods..."   │     │
│ │                                                       │     │
│ │ 🔒 Read-Only (Team Member's Request)                 │     │
│ │ [View Details]                                        │     │
│ └───────────────────────────────────────────────────────┘   │
│                                                               │
│ ℹ You can view your team's feedback requests to support     │
│   their development, but cannot send reminders or cancel.    │
└─────────────────────────────────────────────────────────────┘
```

### Interaction Flows

#### Flow 1: Create Multi-Recipient Request

```
User clicks "Request Feedback"
    ↓
Form opens with empty state
    ↓
[Optional] Load draft banner shown if draft exists (<7 days old)
    ↓
User searches for employees
    ├─ Type minimum 2 characters
    ├─ Debounce 300ms
    ├─ Apply filters (Department/Location/Role)
    └─ Show top 10 results with infinite scroll
    ↓
User selects multiple employees (up to 20)
    ├─ Each selection adds chip below search
    ├─ Counter updates: "5/20 selected"
    └─ Chips can be removed with [X]
    ↓
[Optional] Select project from dropdown
[Optional] Select goal from dropdown
    ↓
[Optional] Enter message (max 500 chars)
    ├─ Character counter updates in real-time
    └─ Auto-save draft every 30 seconds
    ↓
[Optional] Select due date
    ├─ Quick select chips (+3, +7, +14 days)
    ├─ Show warning if <3 days
    └─ Validate not in past
    ↓
User clicks "Send Request"
    ↓
Duplicate detection check
    ├─ IF full duplicate → Show error dialog, block send
    ├─ IF partial duplicate → Show warning dialog
    │   ├─ User selects "Remove Duplicates & Continue"
    │   └─ User selects "Cancel"
    └─ IF no duplicate → Continue
    ↓
API call: POST /api/feedback/request
    ├─ Button disabled, shows "Sending..."
    └─ 10 second timeout
    ↓
Success: Form closes
    ├─ Success toast: "Request sent to N employees"
    ├─ Navigate to Sent Requests
    ├─ New request highlighted at top
    ├─ Draft cleared from localStorage
    └─ Notifications sent to all recipients (async)
    ↓
Error: Form remains open
    ├─ Error toast with specific message
    ├─ Form data preserved
    └─ User can correct and retry
```

#### Flow 2: Respond to Feedback Request

```
Recipient receives notification
    ├─ In-app: Bell badge increments
    ├─ Email: With "Add to Calendar" and "Respond Now"
    └─ Recipient clicks notification or email link
    ↓
Navigate to Todo Requests page
    ↓
Request shown in list (sorted by due date)
    ├─ Overdue requests at top
    └─ Show urgency badges
    ↓
User clicks "Respond Now"
    ↓
Opens feedback submission form
    ├─ Pre-filled: employee_id (requestor)
    ├─ Pre-filled: goal_id and project_id (if request had them)
    ├─ Pre-filled: feedback_request_id (to link back)
    └─ Form includes: content (required), rating (required)
    ↓
User fills feedback form and submits
    ↓
API call: POST /api/feedback
    ├─ Sets feedback.feedback_request_id = request.id
    └─ Updates feedback_request_recipients.responded_at
    ↓
Success:
    ├─ Success toast: "Feedback sent to [Requestor Name]"
    ├─ Request marked as "Responded" with checkmark
    ├─ Request removed from Todo list
    ├─ Notification sent to requestor
    └─ Requestor sees "View Feedback" button in Sent Requests
```

#### Flow 3: Send Reminder (Single Recipient)

```
Requestor views Sent Requests list
    ↓
Clicks request card to expand
    ↓
Views per-recipient status
    ├─ Recipient shows "Pending" badge
    └─ "Send Reminder" button visible (if >3 days since request/last reminder)
    ↓
User clicks "Send Reminder" next to specific recipient
    ↓
Check cooldown (48 hours since last reminder)
    ├─ IF within cooldown → Show tooltip "Can remind in X hours"
    └─ IF eligible → Continue
    ↓
API call: POST /api/feedback/request/{id}/recipient/{recipientId}/remind
    ↓
Success:
    ├─ Success toast: "Reminder sent to [Recipient Name]"
    ├─ Button disabled for 48 hours
    ├─ Timestamp updated: "Last reminded just now"
    └─ Email sent to recipient with calendar .ics
    ↓
Error:
    ├─ Error toast with specific reason
    └─ Button remains available
```

#### Flow 4: Manager Views Team Requests

```
Manager navigates to Feedback section
    ↓
Sees additional "Team Requests" tab
    ├─ Badge shows count of team's pending requests
    └─ Only visible if user has direct reports
    ↓
Manager clicks "Team Requests"
    ↓
Page loads with two sub-tabs:
    ├─ "Sent by Team" (requests team members created)
    └─ "Received by Team" (requests addressed to team)
    ↓
Manager applies filters:
    ├─ Select specific team member from dropdown
    ├─ Filter by status
    └─ Filter by date range
    ↓
Request cards display:
    ├─ Team member name prepended
    ├─ Full request details visible
    ├─ "🔒 Read-Only" indicator
    └─ No action buttons (reminders/cancel disabled)
    ↓
Manager can:
    ├─ View request details (expand cards)
    ├─ See per-recipient status
    ├─ Identify coaching opportunities
    └─ Export/screenshot for documentation
    ↓
Manager CANNOT:
    ├─ Send reminders on behalf of team
    ├─ Cancel team members' requests
    ├─ Edit request details
    └─ Create requests on behalf of team
```

---

## Phase 2 Refinement Summary

**Stakeholder Decisions Incorporated** (2025-11-13):

### Major Changes:
1. **Multi-Recipient Support** ✅
   - Changed from single recipient to 1-20 recipients per request
   - Added `feedback_request_recipients` junction table
   - Per-recipient status tracking (`is_completed`, `responded_at`, `last_reminder_at`)
   - Partial completion support (some recipients responded, others pending)

2. **Manager Team View** ✅
   - New endpoints: GET /api/team/feedback/request/sent and /received
   - Read-only access for managers to view direct reports' requests
   - Filtered by `employees.manager_id` relationship
   - Separate tab in UI: "Team Requests"

3. **Enhanced Employee Search** ✅
   - Added filter chips: Department, Location, Role/Title
   - Multi-select with checkboxes
   - Badge indicators: "Your Manager", "Direct Report", "Same Department"
   - Maximum 20 recipients per request

4. **Auto-Save Drafts** ✅
   - Form state saved to localStorage every 30 seconds
   - Draft retained for 7 days
   - Load draft banner on form open
   - Draft cleared on successful submit

5. **Calendar Integration** ✅
   - Email reminders include "Add to Calendar" button
   - Generates .ics file with due date event
   - 30-minute time block suggested
   - Deep link to respond

6. **Feedback Linking** ✅
   - Added `feedback.feedback_request_id` foreign key
   - Links submitted feedback back to originating request
   - "View Feedback" navigates to /feedback/{id} detail page

7. **Silent Cancellation** ✅
   - No notification sent to recipients when request cancelled
   - Recipients' todo list updated silently
   - Business decision for professional discretion

### Deferred Features:
- AI-assisted request writing (future enhancement)
- Feedback request templates (future enhancement)

---

## Implementation Notes

### Backend Considerations
1. **Duplicate Detection Logic**: Unique index uses `COALESCE` to handle NULL goal_id and project_id in composite key
2. **Status Computation**: `status` field is computed at query time based on `responded_at` and `deleted_at`, not stored
3. **Overdue Calculation**: `is_overdue` computed as `due_date < CURRENT_DATE AND responded_at IS NULL`
4. **Reminder Cooldown**: Check `last_reminder_at` timestamp before allowing manual reminder (48-hour window)

### Frontend Considerations
1. **State Management**: Use React Query for API data caching and synchronization
2. **Form State**: Use React Hook Form for form validation and state management
3. **Date Picker**: Use Material-UI DatePicker with locale support
4. **Autocomplete**: Debounce employee search at 300ms to reduce API calls
5. **Optimistic Updates**: Update UI immediately for checkbox interactions, revert on API failure

### Future Enhancements (Out of Scope for V1)
1. Bulk feedback request creation (multiple employees at once)
2. Feedback request templates (save and reuse message templates)
3. Recurring feedback requests (automatic periodic requests)
4. Anonymous feedback requests (recipient identity hidden)
5. Feedback request approval workflow (manager approval before sending)
6. Advanced analytics dashboard (request response rates, average turnaround time)

---

## Phase 2 Completion Checklist

### Refinement Quality Validation

- [x] **User Stories**: All 4 user stories (US-001 to US-004) + US-002B (Manager view) have 10+ specific acceptance criteria
- [x] **Edge Cases**: 20+ edge cases identified and documented with specific behaviors
- [x] **Error Scenarios**: All validation and API errors have exact user-facing messages
- [x] **UI Behavior**: Complete UI specifications with mockups, interaction flows, and state transitions
- [x] **Authorization**: Explicit rules for all operations (user, manager, admin access)
- [x] **Offline Mode**: Defined for all user actions (draft save, queue requests, sync strategy)
- [x] **Performance**: Specific targets set (API < 200ms GET, < 500ms POST, list load < 500ms)
- [x] **Validation Rules**: Exact limits and formats for all fields (500 char message, 20 max recipients, etc.)
- [x] **Multi-Recipient**: Complete data model change with junction table, per-recipient tracking
- [x] **Manager View**: New read-only access for team oversight with authorization rules
- [x] **Calendar Integration**: Email reminders include .ics file generation with due date events
- [x] **Feedback Linking**: Foreign key relationship established (feedback.feedback_request_id)
- [x] **Draft Auto-Save**: localStorage persistence with 30-second interval, 7-day retention
- [x] **Advanced Search**: Department/Location/Role filters with multi-select and badges
- [x] **Notification System**: Complete notification specifications for all trigger events
- [x] **No Ambiguities**: Replaced all vague terms ("valid", "appropriate") with specifics

### Stakeholder Decisions Documented

- [x] 10 clarifying questions asked and answered (2025-11-13)
- [x] All major architectural decisions recorded in Phase 2 Refinement Summary
- [x] Multi-recipient model approved and fully specified
- [x] Manager read-only access approved with authorization constraints
- [x] Silent cancellation confirmed (no recipient notification)
- [x] Calendar integration (.ics file) specified
- [x] Draft auto-save strategy confirmed (localStorage, 30s interval)
- [x] Advanced employee search filters approved
- [x] AI assistance and templates deferred to future

### Constitutional Compliance (Re-validated)

- [x] **Principle 1**: Specification complete before implementation
- [x] **Principle 2**: C# DTOs and TypeScript interfaces updated with multi-recipient model
- [x] **Principle 3**: RESTful APIs with proper status codes (201, 204, 400, 403, 404, 429)
- [x] **Principle 4**: Strong typing with validation (MinLength, MaxLength on arrays)
- [x] **Principle 5**: Offline mode: draft save, request queuing, sync on reconnection
- [x] **Principle 6**: i18n: All UI text externalizable, locale-based date formatting, .ics localization
- [x] **Principle 7**: Comprehensive testing: 50+ test cases across unit/integration/E2E
- [x] **Principle 8**: Performance: < 500ms list load, debouncing, pagination, virtual scrolling
- [x] **Principle 9**: Naming: snake_case JSON (employee_ids, feedback_request_id), PascalCase C#
- [x] **Principle 10**: Security: JWT auth, rate limiting (50/day), XSS prevention (HTML stripping)
- [x] **Principle 11**: Database: Junction table, proper FKs, indexes, soft delete, audit fields

### Implementation Readiness

- [x] Database schema complete with migration-ready SQL
- [x] API contracts complete with request/response examples
- [x] C# DTOs complete with validation attributes
- [x] TypeScript interfaces complete with strict types
- [x] UI mockups provided for all screens
- [x] Interaction flows documented for all user journeys
- [x] Error messages catalog complete
- [x] Success metrics defined (5 KPIs)
- [x] Dependencies identified (F001 Goals, F011 Projects, notification system)
- [x] Testing strategy complete with 50+ test cases

---

**Specification Status**: ✅ **PHASE 2 COMPLETE** - Ready for Phase 3 (Implementation Planning)  
**Phase 2 Completed**: November 13, 2025  
**Refined By**: AI Assistant with Stakeholder (Vyacheslav Kozyrev)  
**Next Phase**: Phase 3 - Plan (Break down into implementation tasks)  
**Approval Status**: Awaiting formal approval from Product Owner, Tech Lead (Backend), Tech Lead (Frontend)
