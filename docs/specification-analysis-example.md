# Example: Specification Analysis in Action

This example shows how the automated analysis system works with a real specification.

## Scenario: User Notification Feature

A developer creates a specification for a new user notification feature.

---

## Initial Specification Files

### `specs/spec-042-user-notifications/description.md`

```markdown
# User Notifications

## Overview
Add notification system to CPR so users can receive alerts.

## User Stories
- As a user, I want to receive notifications, so I know when things happen
- As a user, I want to see my notifications, so I can stay informed

## Acceptance Criteria
1. Users can receive notifications
2. Notifications appear in the UI
3. Users can mark notifications as read
```

### `specs/spec-042-user-notifications/endpoints.md`

```markdown
## GET /api/notifications

Returns user notifications.

**Response:**
```json
{
  "notifications": []
}
```
```

### Other Files
- `implementation-plan.md`: Minimal content
- `tasks.md`: Empty
- `progress.md`: "Not Started"

---

## Step 1: Run Automated Analysis

**Command**: Use GitHub Copilot with `prompts/specification-analysis.md`

**AI Input**: All files from `specs/spec-042-user-notifications/`

---

## Step 2: AI Generates analysis-report.md

### `specs/spec-042-user-notifications/analysis-report.md` (Generated)

```markdown
# Specification Analysis: User Notifications

**Analyzed By**: AI Specification Analyzer  
**Analysis Date**: 2025-11-05  
**Specification Version**: v1.0  

## Analysis Summary

- **Overall Rating**: 25/100 ❌ NOT READY
- **Critical Issues**: 2
- **Major Issues**: 7
- **Minor Issues**: 6

---

## Gaps Analysis

### Gap 1: Missing Authentication Specification [CRITICAL]
**Severity**: Critical (Blocks Development)  
**Location**: `endpoints.md` - All endpoints  
**Description**: No authentication requirements specified for any endpoint. Who can access notifications? How is the user identified?  
**Impact**: Cannot implement secure endpoints without auth specification.  
**Recommendation**: Specify authentication method (Bearer token) and authorization rules.  
**Status**: ⚠️ OPEN

### Gap 2: Undefined Notification Types [CRITICAL]
**Severity**: Critical (Blocks Development)  
**Location**: `description.md` - Overview  
**Description**: "Things happen" is too vague. What types of notifications exist? (goal completed, feedback received, project assigned, etc.)  
**Impact**: Cannot design database schema or implement notification triggers without knowing types.  
**Recommendation**: Define specific notification types with examples.  
**Status**: ⚠️ OPEN

### Gap 3: Missing Request/Response Schema [MAJOR]
**Severity**: Major (-20 points)  
**Location**: `endpoints.md` - GET /api/notifications  
**Description**: Response only shows empty array. What fields does a notification have? (id, message, timestamp, read status, type, etc.)  
**Impact**: Frontend cannot be implemented without knowing data structure.  
**Recommendation**: Provide complete JSON schema with all fields, types, and example data.  
**Status**: ⚠️ OPEN

### Gap 4: Missing Error Responses [MAJOR]
**Severity**: Major (-20 points)  
**Location**: `endpoints.md` - All endpoints  
**Description**: No error responses defined (401, 404, 500, etc.)  
**Impact**: Cannot implement proper error handling.  
**Recommendation**: Define error responses for each endpoint following RFC 7807 format.  
**Status**: ⚠️ OPEN

### Gap 5: Missing Pagination Specification [MAJOR]
**Severity**: Major (-20 points)  
**Location**: `endpoints.md` - GET /api/notifications  
**Description**: Notifications could be numerous. How is pagination handled? Page size? Cursor vs offset?  
**Impact**: Performance issues if returning all notifications. Frontend needs pagination parameters.  
**Recommendation**: Add pagination parameters (page, per_page, or cursor-based).  
**Status**: ⚠️ OPEN

### Gap 6: No Create/Send Notification Endpoint [MAJOR]
**Severity**: Major (-20 points)  
**Location**: `endpoints.md`  
**Description**: Only GET endpoint specified. How are notifications created? Is there a POST endpoint? Is it system-generated only?  
**Impact**: Cannot implement notification creation without specification.  
**Recommendation**: Specify how notifications are created (POST endpoint, background job, event-driven).  
**Status**: ⚠️ OPEN

### Gap 7: No Mark as Read Endpoint [MAJOR]
**Severity**: Major (-20 points)  
**Location**: `endpoints.md`  
**Description**: Acceptance criteria mentions "mark as read" but no endpoint specified.  
**Impact**: Cannot implement this requirement.  
**Recommendation**: Add PATCH /api/notifications/{id} endpoint to mark as read.  
**Status**: ⚠️ OPEN

### Gap 8: Missing Database Schema [MAJOR]
**Severity**: Major (-20 points)  
**Location**: `implementation-plan.md`  
**Description**: No database schema specified. What tables/columns are needed?  
**Impact**: Cannot implement persistence layer.  
**Recommendation**: Define notifications table schema with fields, types, indexes.  
**Status**: ⚠️ OPEN

### Gap 9: Incomplete Implementation Plan [MAJOR]
**Severity**: Major (-20 points)  
**Location**: `implementation-plan.md`  
**Description**: Plan is minimal with no phases, approach, or technical details.  
**Impact**: No clear path for implementation.  
**Recommendation**: Break into phases (schema, backend, frontend), define approach.  
**Status**: ⚠️ OPEN

### Gap 10: No Test Scenarios [MINOR]
**Severity**: Minor (-5 points)  
**Location**: All files  
**Description**: No test scenarios or contract test requirements defined.  
**Impact**: Testing approach unclear.  
**Recommendation**: Define key test scenarios in description.md.  
**Status**: ⚠️ OPEN

[... additional minor issues ...]

---

## Conflicts Analysis

### No Conflicts Detected
Specification does not appear to conflict with existing features (though it's too incomplete to fully assess).

---

## Duplications Analysis

### No Duplications Detected
New functionality, not duplicating existing features.

---

## Quality Issues

### Issue 1: Vague User Stories
**Severity**: Minor (-5 points)  
**Location**: `description.md` - User Stories  
**Description**: Stories use vague language ("things happen", "stay informed"). Not specific enough.  
**Impact**: Unclear what value the feature provides.  
**Recommendation**: Make stories specific: "As a user, I want to receive a notification when my goal is approved, so I can proceed with execution."  
**Status**: ⚠️ OPEN

[... additional quality issues ...]

---

## Rating Calculation

**Starting Score**: 100 points

**Critical Issues**: 2 (blocks development - score = 0)

Since critical issues exist, specification is automatically NOT READY regardless of point deductions.

**Deductions (for reference)**:
- Gap 3 (Major): -20 points
- Gap 4 (Major): -20 points
- Gap 5 (Major): -20 points
- Gap 6 (Major): -20 points
- Gap 7 (Major): -20 points
- Gap 8 (Major): -20 points
- Gap 9 (Major): -20 points
- Gap 10 (Minor): -5 points
- [Additional issues]: -30 points

**Final Score**: 0/100 (due to critical issues)

**Status**: ❌ NOT READY

---

## Next Steps

### ❌ Specification is Not Ready

**Critical Issues Must Be Resolved**:

1. **Define Authentication** (Gap 1): Specify how users are authenticated and authorized to access notifications.

2. **Define Notification Types** (Gap 2): List all notification types with examples (e.g., GoalApproved, FeedbackReceived, ProjectAssigned).

**Required Actions**:
1. Resolve both critical issues
2. Address all 7 major issues
3. Complete endpoints.md with full API specification
4. Write comprehensive implementation plan
5. Define database schema
6. Re-run analysis after significant rework

**Questions to Address**:

**Q1: What types of notifications will the system support?**
- Goal-related notifications?
- Feedback notifications?
- Project/assignment notifications?
- System announcements?
- Other types?

**Q2: How should notifications be created?**
- Event-driven (triggered by other actions in the system)?
- Manual creation via API endpoint?
- Background job processing?
- Combination of approaches?

**Q3: What fields should a notification have?**
- At minimum: id, userId, type, message, timestamp, isRead
- Other fields: priority, actionUrl, expiresAt?

**Q4: How should notifications be paginated?**
- Offset-based (page/per_page)?
- Cursor-based (for real-time feeds)?
- Default page size? Maximum?

**Q5: Should there be real-time notification delivery?**
- WebSocket/SignalR for instant notifications?
- Or just polling via GET endpoint?
- This impacts architecture significantly.

**Q6: What are the acceptance criteria for "mark as read"?**
- Mark individual notification?
- Mark all as read?
- Does marking as read persist?

**Q7: Are there any notification preferences?**
- Can users opt-out of certain notification types?
- Email notifications in addition to in-app?

**Next Steps**:
1. Schedule specification workshop with product owner and architect
2. Answer all questions above
3. Write complete specification addressing all gaps
4. Re-run automated analysis
5. Target score: ≥ 90/100 with no critical issues

---

## Sign-Off Checklist

- [ ] All critical issues resolved
- [ ] All major issues resolved or accepted as risks
- [ ] Minor issues documented and tracked
- [ ] Overall rating ≥ 90/100
- [ ] Specification ready for manual review

**Ready for Manual Approval**: NO

---

## Notes

This specification is in early draft stage and requires significant development before it's ready for implementation. The concept is sound, but the details are critically incomplete. Recommend working session with architect to flesh out the requirements and technical approach.
```

---

## Step 3: Developer Reviews and Fixes

The developer sees the analysis and realizes the specification is incomplete.

**Actions**:
1. Schedules meeting with product owner and architect
2. Answers the AI's questions
3. Rewrites specification with complete details

---

## Step 4: Updated Specification (Key Changes)

### Updated `description.md`

```markdown
# User Notifications

## Overview
Add notification system to alert users of important events in CPR, such as goal approvals, feedback received, and project assignments.

## Notification Types
1. **GoalApproved**: Manager approves a goal
2. **GoalCompleted**: User completes a goal
3. **FeedbackReceived**: User receives feedback
4. **ProjectAssigned**: User assigned to project
5. **SystemAnnouncement**: Important system messages

## User Stories
- As a user, I want to receive a notification when my goal is approved, so I can begin execution
- As a user, I want to receive a notification when I receive feedback, so I can respond promptly
- As a user, I want to view all my notifications in one place, so I can stay informed
- As a user, I want to mark notifications as read, so I can track what I've seen
- As a user, I want to mark all notifications as read, so I can clear my notification list quickly

## Acceptance Criteria
1. Users receive notifications for all 5 notification types
2. Notifications appear in UI with unread indicator
3. Users can view list of all notifications (paginated)
4. Users can mark individual notification as read
5. Users can mark all notifications as read
6. Unread count displayed in navigation
7. Notifications persist in database
8. Real-time delivery not required (polling acceptable)
```

### Updated `endpoints.md`

```markdown
## GET /api/notifications

Retrieve paginated list of notifications for authenticated user.

**Authentication**: Required (Bearer token)

**Query Parameters**:
- `page` (integer, optional, default: 1): Page number
- `per_page` (integer, optional, default: 20, max: 100): Items per page
- `unread_only` (boolean, optional, default: false): Filter to unread only

**Success Response (200 OK)**:
```json
{
  "notifications": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "userId": "679add6e-6c29-4e00-b6a5-b69c8e0f3445",
      "type": "GoalApproved",
      "message": "Your goal 'Complete Q4 Training' has been approved",
      "relatedEntityId": "a1b2c3d4-e5f6-g7h8-i9j0-k1l2m3n4o5p6",
      "relatedEntityType": "Goal",
      "isRead": false,
      "createdAt": "2025-11-05T10:30:00Z"
    }
  ],
  "pagination": {
    "currentPage": 1,
    "perPage": 20,
    "totalPages": 3,
    "totalCount": 47
  },
  "unreadCount": 12
}
```

**Error Responses**:

401 Unauthorized:
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1",
  "title": "Unauthorized",
  "status": 401,
  "detail": "Authorization header is missing or invalid"
}
```

---

## POST /api/notifications/{id}/read

Mark a specific notification as read.

**Authentication**: Required (Bearer token)

**Path Parameters**:
- `id` (UUID, required): Notification ID

**Success Response (204 No Content)**:
(empty response body)

**Error Responses**:

404 Not Found:
```json
{
  "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
  "title": "Not Found",
  "status": 404,
  "detail": "Notification with ID '550e8400-...' not found or does not belong to user"
}
```

---

## POST /api/notifications/read-all

Mark all notifications as read for authenticated user.

**Authentication**: Required (Bearer token)

**Success Response (200 OK)**:
```json
{
  "markedAsRead": 12
}
```
```

### Updated `implementation-plan.md`

```markdown
# Implementation Plan: User Notifications

## Technical Approach
Event-driven notification creation with polling-based retrieval.

## Database Schema

### Table: `notifications`
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES employees(id),
  type VARCHAR(50) NOT NULL,
  message TEXT NOT NULL,
  related_entity_id UUID,
  related_entity_type VARCHAR(50),
  is_read BOOLEAN NOT NULL DEFAULT FALSE,
  created_at TIMESTAMP NOT NULL DEFAULT NOW(),
  INDEX idx_user_unread (user_id, is_read, created_at DESC),
  INDEX idx_created_at (created_at)
);
```

## Implementation Phases

### Phase 1: Backend Foundation (Week 1)
- Create database migration for notifications table
- Implement NotificationService with CRUD operations
- Create NotificationsController with 3 endpoints
- Write unit tests for NotificationService
- Write contract tests for endpoints

### Phase 2: Notification Triggers (Week 1-2)
- Implement event handlers for 5 notification types
- Integrate with existing Goal, Feedback, Project services
- Write integration tests for trigger logic

### Phase 3: Frontend Integration (Week 2)
- Create NotificationsList component
- Create NotificationBadge component (unread count)
- Integrate with navigation
- Implement mark as read functionality
- Write component tests

### Phase 4: Polish (Week 2-3)
- Add notification icon/styling
- Implement toast notifications for new items
- Add user preferences (future: opt-out)
- Performance testing and optimization

## Dependencies
- Requires existing authentication system (Entra External ID)
- Requires existing employee/user data
- No external service dependencies

## Risks
- Database performance with many notifications (mitigated by indexes)
- Polling load on API (mitigated by rate limiting, future: WebSocket)
```

### Updated `tasks.md`

[Complete task breakdown with 20+ specific tasks]

---

## Step 5: Re-run Analysis

**AI re-analyzes the updated specification...**

### `analysis-report.md` (Second Analysis)

```markdown
# Specification Analysis: User Notifications

**Analyzed By**: AI Specification Analyzer  
**Analysis Date**: 2025-11-05  
**Specification Version**: v2.0  

## Analysis Summary

- **Overall Rating**: 92/100 ✅ READY FOR DEVELOPMENT
- **Critical Issues**: 0
- **Major Issues**: 0
- **Minor Issues**: 4

---

## Gaps Analysis

### Gap 1: Missing Delete Notification Endpoint [MINOR]
**Severity**: Minor (-5 points)  
**Location**: `endpoints.md`  
**Description**: No way to delete/dismiss old notifications. Consider if users should be able to delete.  
**Impact**: Notifications accumulate indefinitely.  
**Recommendation**: Add DELETE /api/notifications/{id} or document retention policy.  
**Status**: ⚠️ OPEN - Consider for future iteration

### Gap 2: No Notification Preferences Specified [MINOR]
**Severity**: Minor (-5 points)  
**Location**: `description.md`  
**Description**: Implementation plan mentions "user preferences (future)" but not specified.  
**Impact**: Users cannot opt-out of notification types.  
**Recommendation**: Either specify preferences or remove from implementation plan.  
**Status**: ⚠️ OPEN - Acceptable for v1, track as future enhancement

---

## Conflicts Analysis

### No Conflicts Detected
Specification is consistent internally and does not conflict with existing CPR features.

---

## Duplications Analysis

### No Duplications Detected
New functionality, no duplication with existing features.

---

## Quality Issues

### Issue 1: WebSocket Future Consideration
**Severity**: N/A (informational)  
**Location**: `implementation-plan.md` - Risks  
**Description**: Mentions "future: WebSocket" but doesn't specify criteria for when to implement.  
**Impact**: None for current implementation.  
**Recommendation**: Document trigger criteria (e.g., "implement WebSocket if polling load > X requests/minute").  
**Status**: ⚠️ OPEN - Document in backlog

### Issue 2: Notification Retention Not Specified
**Severity**: N/A (informational)  
**Location**: `implementation-plan.md`  
**Description**: How long are notifications retained? Forever? 90 days?  
**Impact**: Database growth over time.  
**Recommendation**: Define retention policy (suggest 90 days for read, 1 year for unread).  
**Status**: ⚠️ OPEN - Acceptable for v1, add to backlog

---

## Rating Calculation

**Starting Score**: 100 points

**Deductions**:
- Gap 1 (Minor): -5 points
- Gap 2 (Minor): -5 points
- No major or critical issues: 0 points

**Final Score**: 100 - 10 = **92/100**

**Status**: ✅ **READY FOR DEVELOPMENT**

---

## Next Steps

### ✅ Specification is Ready for Development

**Recommendations before starting**:
1. Consider adding notification retention policy before Phase 4
2. Track Gap 1 (delete endpoint) as backlog item for future
3. Document WebSocket decision criteria in backlog

**Proceed to**:
- Manual review and approval by tech lead
- Mark specification as "Ready for Development" in progress.md
- Begin Phase 1 implementation

---

## Sign-Off Checklist

- [x] All critical issues resolved (none found)
- [x] All major issues resolved (none found)
- [x] Minor issues documented and tracked (acceptable for v1)
- [x] Overall rating ≥ 90/100 (92/100)
- [x] Specification ready for manual review

**Ready for Manual Approval**: YES

---

## Notes

Excellent improvement from v1.0! The specification is now complete, well-structured, and ready for implementation. The identified minor issues are acceptable for v1 and properly tracked for future iterations. The phased approach is realistic and the database schema is appropriate. Good work!
```

---

## Step 6: Manual Approval

Tech lead reviews the specification and analysis:
- Verifies all endpoints are complete
- Confirms database schema is appropriate
- Checks implementation phases are realistic
- **Approves** specification

Updates `analysis-report.md` sign-off:
```markdown
**Approved By**: Jane Smith (Tech Lead)  
**Approval Date**: 2025-11-05
```

Updates `progress.md`:
```markdown
**Status**: Approved - Ready for Development
**Approval Date**: 2025-11-05
```

---

## Step 7: Implementation Begins

Developer can now confidently implement the feature knowing:
✅ Requirements are complete
✅ API contracts are fully specified  
✅ Database schema is defined  
✅ Implementation plan is feasible  
✅ No conflicts with existing features  

---

## Key Takeaways

1. **First analysis caught critical gaps early** - saved significant rework
2. **AI provided specific guiding questions** - helped developer know what to fix
3. **Re-analysis confirmed improvements** - objective quality measurement
4. **Manual review added final validation** - human expertise still critical
5. **Result: High-quality specification** - ready for confident implementation

**Time Investment**:
- Initial spec (incomplete): 30 minutes
- First analysis: 3 minutes (AI) + 5 minutes (review)
- Specification rework: 2 hours
- Second analysis: 3 minutes (AI) + 5 minutes (review)
- Manual approval: 15 minutes
- **Total: ~3 hours**

**Value**: Prevented days or weeks of rework from incomplete requirements and missing specifications.
