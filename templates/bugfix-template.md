# Bugfix: [Bug Title]

> **Type**: Bug Fix  
> **ID**: [bugfix-###]-[short-description]  
> **Severity**: [Critical | High | Medium | Low]  
> **Priority**: [P0 | P1 | P2 | P3]  
> **Created**: YYYY-MM-DD  
> **Reporter**: [Your Name]  
> **Status**: [Open | In Progress | Fixed | Verified | Closed]

## Bug Description

[Clear, concise description of the bug - what is happening that shouldn't be happening]

## Impact

### User Impact
- **Affected Users**: [All users | Specific role | Specific percentage]
- **User Experience**: [How this affects the user experience]
- **Business Impact**: [Impact on business operations or metrics]

### System Impact
- **Affected Components**: [List affected systems/components]
- **Performance Impact**: [If applicable]
- **Data Integrity**: [If applicable]
- **Security Impact**: [If applicable]

### Severity Justification
[Explain why this bug has the assigned severity level]

**Severity Definitions**:
- **Critical**: System down, data loss, security breach
- **High**: Major functionality broken, significant user impact
- **Medium**: Feature partially broken, workaround exists
- **Low**: Minor issue, cosmetic problem, edge case

## Steps to Reproduce

1. [Detailed step 1]
2. [Detailed step 2]
3. [Detailed step 3]
4. [What happens]

**Environment**:
- **Browser/Platform**: [Browser version or platform]
- **OS**: [Operating system]
- **Version**: [Application version]
- **Environment**: [Development | Staging | Production]

## Expected Behavior

[Describe what should happen instead]

## Actual Behavior

[Describe what actually happens]

## Visual Evidence

### Screenshots
[Add screenshots if applicable]

### Logs
```
[Paste relevant error logs, stack traces, or console output]
```

### Network Requests (if applicable)
```json
// Request
{
  "field": "value"
}

// Response
{
  "error": "message"
}
```

## Root Cause Analysis

### Investigation Steps
1. [Step taken to investigate]
2. [Step taken to investigate]
3. [Step taken to investigate]

### Root Cause
[Detailed explanation of what is causing the bug]

**Location**: `path/to/file.ext:line_number`

**Code Snippet** (problematic code):
```typescript
// Current problematic code
function buggyFunction() {
  // Problem is here
  return incorrectValue;
}
```

### Why This Happened
[Explanation of how this bug was introduced]
- **Introduced in**: [Commit hash or PR number]
- **Reason**: [Why the bug wasn't caught earlier]

## Proposed Solution

### Approach
[Describe the approach to fix the bug]

**Fixed Code**:
```typescript
// Corrected code
function fixedFunction() {
  // Fixed implementation
  return correctValue;
}
```

### Alternative Solutions Considered

#### Solution 1: [Name]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Decision**: [Why chosen or rejected]

#### Solution 2: [Name]
- **Pros**: [Advantages]
- **Cons**: [Disadvantages]
- **Decision**: [Why chosen or rejected]

### Why This Solution
[Explain why the proposed solution is the best approach]

## Implementation Plan

### Files to Change

#### Backend Changes
- `path/to/file1.cs`
  - Change: [Description of change]
  - Lines: [Line numbers]
  
- `path/to/file2.cs`
  - Change: [Description of change]
  - Lines: [Line numbers]

#### Frontend Changes
- `path/to/file1.tsx`
  - Change: [Description of change]
  - Lines: [Line numbers]

#### Database Changes
- **Migration**: [If applicable]
- **Data Fix**: [If applicable]

### Testing Required

#### Unit Tests
- [ ] Test [scenario 1]
- [ ] Test [scenario 2]
- [ ] Test [edge case]

#### Integration Tests
- [ ] Test [integration scenario]

#### Manual Testing
- [ ] Verify [test case 1]
- [ ] Verify [test case 2]
- [ ] Verify [original bug is fixed]

#### Regression Testing
- [ ] Test [related feature 1] still works
- [ ] Test [related feature 2] still works

## Risk Assessment

### Risks of Fixing
- **Risk 1**: [Description and mitigation]
- **Risk 2**: [Description and mitigation]

### Risks of Not Fixing
- **Risk 1**: [Description and impact]
- **Risk 2**: [Description and impact]

### Breaking Changes
[Will this fix introduce any breaking changes? If yes, describe]

### Backward Compatibility
[How is backward compatibility maintained?]

## Verification Steps

### Test Cases

#### Test Case 1: [Title]
**Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**: [What should happen]

#### Test Case 2: [Title]
**Steps**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**: [What should happen]

### Regression Test Cases
[List features that need regression testing]

1. [ ] Feature 1: [Test description]
2. [ ] Feature 2: [Test description]

## Rollback Plan

[If the fix causes issues, how to rollback]

1. **Step 1**: [Rollback action]
2. **Step 2**: [Rollback action]
3. **Verification**: [How to verify rollback succeeded]

## Related Issues

### Related Bugs
- [BUG-###]: [Title and how it relates]
- [BUG-###]: [Title and how it relates]

### Related Features
- [SPEC-###]: [Feature that this bug affects]

### Blocked By
- [BUG-###]: [Bug that must be fixed first]

### Blocks
- [BUG-###]: [Bug that this blocks]
- [SPEC-###]: [Feature that this blocks]

## Timeline

| Date | Event | Notes |
|------|-------|-------|
| YYYY-MM-DD | Bug reported | [Initial report details] |
| YYYY-MM-DD | Investigation started | [Who started investigating] |
| YYYY-MM-DD | Root cause identified | [Summary of findings] |
| YYYY-MM-DD | Fix implemented | [Implementation details] |
| YYYY-MM-DD | Testing completed | [Testing results] |
| YYYY-MM-DD | Deployed to staging | [Deployment details] |
| YYYY-MM-DD | Deployed to production | [Deployment details] |
| YYYY-MM-DD | Verified in production | [Verification results] |
| YYYY-MM-DD | Closed | [Final notes] |

## Deployment

### Deployment Checklist
- [ ] Code changes committed
- [ ] Tests passing
- [ ] Code reviewed and approved
- [ ] Deployed to development
- [ ] Tested in development
- [ ] Deployed to staging
- [ ] Tested in staging
- [ ] Stakeholders notified
- [ ] Deployed to production
- [ ] Verified in production
- [ ] Documentation updated

### Deployment Notes
[Any special considerations for deployment]

### Post-Deployment Monitoring
[What to monitor after deployment]
- [ ] Monitor [metric 1] for [duration]
- [ ] Monitor [metric 2] for [duration]
- [ ] Check error logs for [pattern]

## Prevention

### How to Prevent Similar Bugs

1. **Process Improvement**: [What process changes would prevent this]
2. **Code Quality**: [What code quality measures would prevent this]
3. **Testing**: [What testing would catch this earlier]
4. **Monitoring**: [What monitoring would detect this sooner]

### Technical Debt
[Does this bug reveal technical debt that should be addressed?]

- [ ] [Technical debt item 1]
- [ ] [Technical debt item 2]

### Lessons Learned
[Key takeaways from this bug]

1. [Lesson 1]
2. [Lesson 2]
3. [Lesson 3]

## Communication

### Stakeholders to Notify
- [ ] [Stakeholder 1] - [Why they need to know]
- [ ] [Stakeholder 2] - [Why they need to know]
- [ ] [Stakeholder 3] - [Why they need to know]

### Communication Plan
**When to Notify**: [When stakeholders should be notified]  
**Message**: [Key points to communicate]

### User Communication (if applicable)
**Subject**: [Email/notification subject]  
**Message**: [User-facing message about the fix]

## Additional Notes

[Any additional context, discussions, or considerations]

## References

- **Original Report**: [Link to bug report]
- **Related Documentation**: [Links to related docs]
- **Stack Overflow**: [Links to helpful resources]
- **Pull Request**: [Link to PR when created]
- **Commit**: [Commit hash when fixed]

---

**Status**: [Current status]  
**Last Updated**: YYYY-MM-DD  
**Updated By**: [Name]
