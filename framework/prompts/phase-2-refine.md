---
phase: 2_refine
purpose: Clarify user stories and refine specification through stakeholder questions
applies_to: description.md
related_documents:
  - ../workflow.md
  - phase-1-specify.md
  - ../../constitution.md
---

# Phase 2: Refine Specification - GitHub Copilot Prompt

## User Input

```text
$ARGUMENTS
```

You **MUST** consider user input before proceeding (if not empty).

## Context

You are helping to refine a feature specification for the CPR (Career Progress Registry) project. This is **Phase 2: Refine**, where we walk through user stories, identify ambiguities, ask clarifying questions, and update the specification with additional details.

Phase 1 (Specify) created the initial specification. Now we need to ensure every detail is clear, complete, and implementable.

---

## IMPORTANT: Run Phase 2 Tool First

**Before using this prompt**, you SHOULD run the Phase 2 PowerShell tool to validate prerequisites:

```powershell
# From the cpr-meta repository root, run:
.\framework\tools\phase-2-refine.ps1 -FeatureNumber "0001" -FeatureName "user-profile-management"
```

**What the tool does**:
1. Verifies specification folder exists from Phase 1
2. Checks that `description.md` exists and is not empty
3. Validates that description.md is filled in (not just template placeholders)
4. Updates `progress.md` with Phase 2 tracking

**After running the tool**, you're ready to analyze and refine the specification using this prompt.

---

## Your Mission

1. **Analyze the specification** (`description.md`) thoroughly
2. **Generate clarifying questions** for each user story and technical requirement
3. **Facilitate stakeholder discussion** by asking targeted questions
4. **Update the specification** with clarifications and new details
5. **Generate UX Mockups** in `description.md`
6. **Validate completeness** before moving to implementation planning

## Analysis Framework

### For Each User Story, Ask:

#### 1. **Happy Path Clarity**
- Is the normal flow completely clear?
- Are all steps explicitly defined?
- Are success messages and confirmations specified?

#### 2. **Edge Cases**
- What happens if user navigates away mid-action?
- What if network fails during operation?
- What if data changes while user is editing?
- What if user has no data yet (empty state)?
- What if user has maximum data (performance at scale)?

#### 3. **Error Scenarios**
- What validation errors can occur?
- How should each error be displayed to user?
- Can user recover from errors inline or must restart?
- What happens if API returns unexpected error?

#### 4. **User Interactions**
- Which fields are required vs optional?
- What are the default values?
- Are there field dependencies (field B enabled only if field A is X)?
- What keyboard shortcuts should work?
- What happens on double-click, right-click?

#### 5. **Data Validation**
- What are exact character limits?
- What special characters are allowed/forbidden?
- Are there format requirements (email, phone, URL)?
- Are there business logic validations (e.g., end date > start date)?
- When does validation occur (on blur, on submit, on change)?

#### 6. **Performance & UX**
- How long should operations take?
- Should there be loading states?
- Should there be progress indicators?
- Should operations be optimistic (show immediately, sync later)?
- What happens if operation takes longer than expected?

#### 7. **Security & Authorization**
- Who can perform this action?
- Are there additional permission checks?
- Should audit logging capture this action?
- Are there rate limits?
- Can this action be performed in offline mode?

#### 8. **Integration Points**
- Does this depend on other features?
- Does this trigger notifications or events?
- Does this update derived data elsewhere?
- Are there webhooks or external systems involved?

## Question Format Template

For each ambiguity or missing detail, formulate questions like:

```markdown
### User Story: US-XXX - [Story Title]

**Clarifying Questions:**

1. **[Category]**: [Specific question]?
   - Context: [Why this matters]
   - Options: [Possible approaches if applicable]
   - Impact: [What this affects]

2. **[Category]**: [Specific question]?
   ...
```

## Example: Good vs Bad Questions

### ❌ Bad Questions (Too Vague)
- "How should errors be handled?"
- "What about edge cases?"
- "Is this secure?"

### ✅ Good Questions (Specific & Actionable)
- "When title validation fails (< 5 characters), should we show an inline error below the field or a toast notification at top of screen?"
- "If user creates a goal while offline and another user (manager) modifies the same goal on server, which version should win when sync occurs? Server wins, local becomes draft, or prompt user to resolve conflict?"
- "Should managers be able to delete goals for their direct reports, or only archive them? Currently DELETE endpoint is Admin-only."

## Phase 2 Process

### Step 1: Initial Analysis
Read the entire `description.md` and create a list of questions organized by:
- User Stories (US-001, US-002, etc.)
- Business Rules
- Technical Requirements
- API Design
- Data Model

### Step 2: Present Questions
Present questions to stakeholder/product owner in organized format:
- Group related questions together
- Prioritize by impact (blocking issues first)
- Provide context for each question
- Suggest options when helpful
- Limit number of questions by 10
- Reiterate Step 2 if you still have questions

### Step 3: Document Answers
Capture stakeholder responses clearly:
- Record exact decisions made
- Note rationale when provided
- Flag any deferred decisions
- Identify new requirements that surface

### Step 4: Update Specification
Incorporate answers into `description.md`:
- Add edge cases to acceptance criteria
- Expand business rules with clarifications
- Update API design if endpoints/fields change
- Add validation rules with specific limits
- Include error handling specifications
- Document UI behavior in detail

### Step 5: Validate Updates
Ensure updated specification:
- Has no contradictions
- Follows constitutional principles
- Is internally consistent
- Provides enough detail for developers
- Includes all edge cases

## Constitutional Principles to Verify

During refinement, ensure alignment with:

- **Principle 2 (API Contracts)**: Are request/response shapes complete with all fields?
- **Principle 4 (Type Safety)**: Are all data types specified exactly?
- **Principle 5 (Offline Mode)**: Is offline behavior defined for all operations?
- **Principle 6 (I18n)**: Are all user-facing strings identified for translation?
- **Principle 9 (Naming)**: Do field names follow conventions consistently?
- **Principle 10 (Security)**: Are authorization rules explicit for all operations?

## Red Flags to Address

Watch for these specification gaps:

- 🚩 Vague acceptance criteria: "User can update fields" (Which fields? All? Some?)
- 🚩 Missing error handling: No mention of what happens when API call fails
- 🚩 Unclear authorization: "Managers can view goals" (All goals? Just direct reports?)
- 🚩 Ambiguous validation: "Title must be valid" (What makes it valid?)
- 🚩 Undefined UI state: No mention of loading, empty, or error states
- 🚩 Missing edge cases: No mention of max limits, concurrent edits, or offline scenarios
- 🚩 Incomplete API spec: Request body documented but not response body
- 🚩 Inconsistent terminology: "Goal status" vs "Goal state" vs "Goal progress status"

## Output Format

After analysis and stakeholder discussion, update `description.md` with:

1. **Enhanced User Stories**
   - More specific acceptance criteria
   - Edge cases explicitly listed
   - Error scenarios covered

2. **Expanded Business Rules**
   - Clarified edge cases
   - Explicit constraint values
   - Conflict resolution rules

3. **Detailed Technical Requirements**
   - Specific timeout values
   - Exact validation rules
   - Clear error messages

4. **Refined API Design**
   - Complete request/response examples
   - All error codes documented
   - Query parameter behaviors specified

5. **Updated UI Specifications** (new section if needed)
   - Screen mockups or wireframe references
   - Interaction flows
   - State transitions
   - Error message text

## Example Refinement

### Before Refinement:
```markdown
### US-001: Create Goals
**As an** employee  
**I want** to create goals  
**So that** I can track my development

**Acceptance Criteria**:
- [ ] I can create a goal with title and description
```

### After Refinement:
```markdown
### US-001: Create Goals
**As an** employee  
**I want** to create personal development goals with structured details  
**So that** I can track progress toward specific career objectives

**Acceptance Criteria**:
- [ ] I can open goal creation form via "Create Goal" button on goals list page
- [ ] Form includes fields: title (required), description (optional), category (required dropdown), target date (required date picker)
- [ ] Title validation: 5-200 characters, no special characters except hyphen and apostrophe
- [ ] Description validation: 10-2000 characters when provided, accepts all UTF-8 characters
- [ ] Target date validation: Must be between today and 5 years from today (1,825 days)
- [ ] Category dropdown options: Technical, Leadership, Process, Business, Personal
- [ ] Form shows inline validation errors below each field (red text, icon)
- [ ] "Save" button disabled until all required fields valid
- [ ] On successful save: Close form, show success toast "Goal created successfully", add goal to top of list
- [ ] On API error: Show error toast with message from API, keep form open with data preserved
- [ ] "Cancel" button: Prompt "Discard changes?" if form has any data, otherwise close immediately
- [ ] Form works offline: Save to local queue, show "Will sync when online" message
```

## Success Criteria

Phase 2 is complete when:

- [ ] Every user story has 5-10 specific acceptance criteria
- [ ] All edge cases are identified and documented
- [ ] Error scenarios have defined user-facing messages
- [ ] All validation rules have exact limits and formats
- [ ] UI behavior is described in detail (what user sees, when they see it)
- [ ] Authorization rules are explicit for each operation
- [ ] Offline behavior is defined for all user actions
- [ ] No ambiguous terms remain (replace "valid", "appropriate", "reasonable" with specifics)
- [ ] Stakeholders confirm: "Yes, if developers build exactly this, it's correct"

---

## Progress Tracking

### Update progress.md When Complete

After completing Phase 2 refinement, update the `progress.md` file:

1. **Update Phase Status Overview Table**:
   ```markdown
   | 2. Refine | 🟢 Completed | 2025-11-06 | 2025-11-06 | 2 hours | Specification refined with stakeholder input |
   ```

2. **Update Phase 2 Section Status**:
   ```markdown
   **Status**: 🟢 Completed  
   **Started**: 2025-11-06  
   **Completed**: 2025-11-06
   ```

3. **Check Off Phase 2 Checklist Items**:
   ```markdown
   - [x] User stories reviewed for ambiguities
   - [x] Clarifying questions generated
   - [x] Stakeholder interview conducted
   - [x] Questions answered and documented
   - [x] Specification updated with clarifications
   - [x] Edge cases added to acceptance criteria
   - [x] Validation rules specified in detail
   - [x] UI behavior documented
   - [x] Error scenarios defined
   - [x] No outstanding ambiguities remain
   - [x] Stakeholder approval obtained
   - [x] Specification approved for Phase 3
   ```

4. **Update Phase 2 Deliverables**:
   ```markdown
   - [x] Updated `description.md` with refinements
   - [x] Clarifying questions document (if needed)
   ```

5. **Add Phase 2 Notes**:
   Document key decisions, clarifications, and any important context:
   ```markdown
   ### Notes
   - Clarified 15 edge cases across 5 user stories
   - Stakeholder confirmed offline sync behavior: server wins, local becomes draft
   - Added specific error messages for all validation failures
   - Defined exact field character limits and formats
   - Manager delete permission remains Admin-only (stakeholder decision)
   ```

6. **Update Overall Progress**:
   ```markdown
   **Completion**: 25% (2/8 phases complete)
   
   ```
   [🟩🟩⬜⬜⬜⬜⬜⬜] 25%
   ```
   ```

7. **Update Frontmatter**:
   ```yaml
   last_updated: 2025-11-06
   current_phase: 2_refine
   overall_status: completed_phase_2
   ```

8. **Update Feature Progress Header**:
   ```markdown
   > **Current Phase**: Phase 2 (Refine) - COMPLETE ✅  
   > **Overall Status**: Ready for Phase 3 (Plan)
   ```

### Example Complete Phase 2 Update

```markdown
## Phase 2: Refine

**Status**: 🟢 Completed  
**Started**: 2025-11-06  
**Completed**: 2025-11-06

### Checklist
- [x] User stories reviewed for ambiguities
- [x] Clarifying questions generated (23 questions)
- [x] Stakeholder interview conducted (Product Owner: Sarah Johnson)
- [x] Questions answered and documented
- [x] Specification updated with clarifications
- [x] Edge cases added to acceptance criteria (15 edge cases added)
- [x] Validation rules specified in detail (all fields have exact limits)
- [x] UI behavior documented (loading states, error displays, confirmations)
- [x] Error scenarios defined (12 error scenarios with user-facing messages)
- [x] No outstanding ambiguities remain
- [x] Stakeholder approval obtained
- [x] Specification approved for Phase 3

### Deliverables
- [x] Updated `description.md` with refinements (expanded from 29.7 KB to 35.2 KB)
- [x] Clarifying questions documented in notes

### Notes
- Generated 23 clarifying questions across all user stories
- Key decisions made:
  - Offline sync conflict resolution: Server always wins, local changes saved as draft
  - Manager goal deletion: Remains Admin-only (not extended to managers)
  - Validation timing: Real-time on blur for required fields, on submit for optional
  - Error display: Inline below field + toast for API errors
  - Auto-save: Triggered after 2 seconds of inactivity
- Added 15 specific edge cases to acceptance criteria
- Defined 12 error scenarios with exact user-facing messages
- All field validations now have exact character limits and format specifications
- Stakeholder (Sarah Johnson, Product Owner) approved specification 2025-11-06

### Blockers
_None - Phase 2 complete_
```

---

## Your Task

Now, analyze the `description.md` specification, generate clarifying questions, and guide the refinement process. Focus on transforming a good specification into a great, unambiguous, implementable specification.

**Remember**: 
- The goal is not to write the code, but to make the specification so clear that developers can implement it confidently without guessing.
- Update `progress.md` when Phase 2 is complete to track your progress and document key decisions.
