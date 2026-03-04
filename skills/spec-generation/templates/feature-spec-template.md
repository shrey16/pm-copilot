# Feature Spec: {Feature Name}

> **Status**: Draft | In Review | Approved
> **Author**: {author}
> **Date**: {date}
> **Product**: {product name}
> **Target Persona**: {primary persona}

---

## 1. Overview

### Problem Statement
{What problem does this feature solve? Why now?}

### Solution Summary
{One-paragraph description of the solution}

### Success Criteria
{How do we know this feature is successful? Link to metrics in Section 8.}

---

## 2. User Flows

### 2.1 Primary Flow (Happy Path)
1. {Step 1}
2. {Step 2}
3. ...

### 2.2 Alternative Flows
{Describe branching paths, e.g., first-time user vs. returning user}

### 2.3 Entry & Exit Points
- **Entry**: {How does the user access this feature?}
- **Exit**: {Where does the user go after completion?}

---

## 3. Functional Requirements

| ID | Requirement | Priority | Acceptance Criteria |
|----|------------|----------|-------------------|
| FR-001 | {requirement} | P0 | {testable criterion} |
| FR-002 | {requirement} | P0 | {testable criterion} |
| FR-003 | {requirement} | P1 | {testable criterion} |

---

## 4. Non-Functional Requirements

| ID | Category | Requirement | Target |
|----|----------|------------|--------|
| NFR-001 | Performance | {requirement} | {specific target} |
| NFR-002 | Security | {requirement} | {specific target} |
| NFR-003 | Accessibility | {requirement} | {specific target} |

---

## 5. Data Model

### 5.1 New Entities

#### {EntityName}
| Field | Type | Constraints | Default | Description |
|-------|------|------------|---------|-------------|
| id | UUID | PK, NOT NULL | auto-generated | Unique identifier |
| {field} | {type} | {constraints} | {default} | {description} |

### 5.2 Relationships
{Describe relationships between entities: 1:1, 1:N, M:N}

### 5.3 Data Lifecycle
- **Creation**: {when/how is data created}
- **Updates**: {what can be updated, by whom}
- **Archival**: {when is data archived}
- **Deletion**: {hard delete vs. soft delete, retention policy}

---

## 6. API Contracts

### 6.1 {Endpoint Name}
- **Method**: {GET/POST/PUT/DELETE}
- **Path**: {/api/v1/...}
- **Auth**: {required/optional, role}

**Request**:
```json
{
  "field": "type — description"
}
```

**Response (200)**:
```json
{
  "field": "type — description"
}
```

**Error Responses**:
| Status | Code | Message | When |
|--------|------|---------|------|
| 400 | INVALID_INPUT | {message} | {condition} |
| 404 | NOT_FOUND | {message} | {condition} |

---

## 7. Edge Cases & Error Handling

| Scenario | Expected Behavior | User Message | Recovery |
|----------|-------------------|-------------|----------|
| {scenario} | {behavior} | {message shown to user} | {how to recover} |
| Empty state | {behavior} | {message} | {recovery} |
| Rate limit exceeded | {behavior} | {message} | {recovery} |
| Network failure | {behavior} | {message} | {recovery} |

---

## 8. Success Metrics

| Metric | Baseline | Target | Timeframe | Measurement |
|--------|----------|--------|-----------|-------------|
| {metric} | {current value} | {target value} | {by when} | {how measured} |

### Rollback Threshold
{At what metric values do we roll back?}

---

## 9. Dependencies

| Dependency | Type | Risk | Mitigation |
|-----------|------|------|------------|
| {system/team/API} | {upstream/downstream} | {H/M/L} | {mitigation plan} |

---

## 10. Scope & Phasing

### In Scope (v1)
- {feature/capability}

### Out of Scope (deferred)
- {feature/capability} — Rationale: {why deferred}

### Future Phases
- **Phase 2**: {what comes next}

---

## 11. Rollback Plan

- **Feature Flag**: {flag name and configuration}
- **Rollout Plan**: {canary → % rollout → GA}
- **Monitoring**: {what dashboards/alerts to watch}
- **Rollback Steps**: {step-by-step rollback procedure}
- **Data Rollback**: {can data changes be reversed? how?}

---

## 12. Open Questions

| # | Question | Owner | Due Date | Resolution |
|---|----------|-------|----------|------------|
| 1 | {question} | {who decides} | {when} | {answer once resolved} |

---

## 13. Decision Log

| Date | Decision | Rationale | Decided By |
|------|----------|-----------|------------|
| {date} | {decision} | {why} | {who} |

---

## 14. Test Strategy

### Unit Test Approach
- **Backend**: {NestJS service/controller tests — what to mock, key assertions}
- **Frontend**: {React component/hook tests — what to render, key interactions to test}

### E2E Flows to Test
| # | Flow | Steps | Expected Outcome |
|---|------|-------|-----------------|
| 1 | Primary happy path | {Step 1 → Step 2 → ...} | {expected result} |
| 2 | {alternative flow} | {steps} | {expected result} |
| 3 | {edge case flow} | {steps} | {expected result} |

### Test Data Requirements
- **Entities to seed**: {what test data is needed before tests run}
- **Seeding method**: {API calls, database fixtures, factory scripts}
- **Cleanup strategy**: {transaction rollback, API cleanup endpoint, manual deletion}

### QA Account Needs
- **Roles needed**: {admin, user, viewer, etc.}
- **Account creation**: {how QA accounts are created for this feature}
- **Authentication**: {how tests authenticate — tokens, cookies, mock auth}
