# Feature Drilling Checklist — 12 Categories

Use this checklist to systematically question every aspect of a feature. Each category has key questions that must be answered concretely before marking it `[COMPLETE]`.

---

## 1. User Flows

- What is the primary happy-path flow, step by step?
- Are there alternative flows (e.g., first-time vs. returning user)?
- What is the entry point? How does the user discover/access this feature?
- What is the exit point? Where does the user go after completing the flow?
- Are there any branching decisions in the flow? What determines each branch?

**Complete when**: Every flow is documented as a numbered step-by-step sequence with clear entry/exit points.

---

## 2. Edge Cases

- What happens with empty/zero state? (no data, first use, empty list)
- What happens with maximum/overflow state? (too many items, very long text, large files)
- What happens with concurrent usage? (multiple users or tabs)
- What happens when the user cancels midway through?
- What happens when the user navigates away and comes back?
- What happens on slow/intermittent network?

**Complete when**: Every "what happens when..." has a concrete, documented answer.

---

## 3. Success Metrics

- What is the primary metric that indicates this feature is successful?
- What are 2-3 secondary/supporting metrics?
- What is the target value for each metric and by when?
- How will each metric be measured? (instrumentation plan)
- What is the baseline value before the feature launches?
- At what metric value would you consider rolling back the feature?

**Complete when**: Each metric has a name, measurement method, baseline, target, and rollback threshold.

---

## 4. Acceptance Criteria

- What are the "must have" criteria for the MVP?
- What are "nice to have" criteria that could be deferred?
- Are there specific test scenarios that must pass?
- What does "done" look like from the user's perspective?
- What does "done" look like from the engineering perspective?

**Complete when**: Acceptance criteria are written as testable statements (Given/When/Then or equivalent).

---

## 5. Error States

- What are all the ways this feature can fail?
- For each failure mode: what does the user see?
- For each failure mode: is there a retry mechanism?
- For each failure mode: is the error recoverable or terminal?
- What error messages are shown? (exact copy, not just "show an error")
- Are errors logged/alerted? Who gets notified?

**Complete when**: Every failure mode has a user-facing message, recovery path, and logging strategy.

---

## 6. Dependencies

- What existing features/systems does this depend on?
- Are there external APIs or services required?
- Are there other teams/people who need to be involved?
- Are there features that depend on THIS feature?
- What is the risk if a dependency is unavailable?
- Are there data migrations required?

### Test Infrastructure Sub-Questions
- How should test accounts be set up for this feature? (existing QA accounts, new accounts needed, roles required)
- What test data needs to be seeded before tests can run? (fixtures, factory data, imported datasets)
- Are there external service dependencies that need mocking or sandboxing for tests?
- Are there E2E prerequisites? (authenticated sessions, browser state, pre-existing data)

**Complete when**: All upstream and downstream dependencies are identified with risk mitigation. Test infrastructure needs are documented.

---

## 7. Scope Boundaries

- What is explicitly OUT of scope for this version?
- What is the simplest possible version that delivers value?
- Are there future phases planned? What goes in each?
- What related features should NOT be changed?
- What are the non-negotiable constraints?

**Complete when**: In-scope and out-of-scope are clearly delineated with rationale.

---

## 8. Data Requirements

- What new data entities/fields are needed?
- What are the data types, constraints, and validation rules for each field?
- What is the data lifecycle? (creation, update, archival, deletion)
- Are there data relationships to model? (1:1, 1:N, M:N)
- What data needs to be displayed? In what format?
- Is there data that needs to be imported/exported?

**Complete when**: Data model is specified with types, constraints, relationships, and lifecycle.

---

## 9. Performance

- What are the latency requirements? (page load, API response, processing)
- What are the throughput requirements? (requests/sec, concurrent users)
- What is the expected data volume? (rows, file sizes, storage)
- Are there specific performance SLAs?
- What happens when performance degrades? (graceful degradation plan)
- Are there caching requirements?

**Complete when**: Latency, throughput, and volume targets are quantified with degradation strategy.

---

## 10. Security & Privacy

- What data is sensitive or PII?
- Who can access this feature? (authentication/authorization)
- Are there role-based permissions? What can each role do?
- Is there data that must be encrypted at rest or in transit?
- Are there compliance requirements? (GDPR, HIPAA, SOC2, etc.)
- Is there an audit trail requirement?
- Can this feature be abused? How to prevent it?

**Complete when**: Access control, data classification, compliance, and abuse prevention are documented.

---

## 11. Accessibility

- Does the feature work with keyboard-only navigation?
- Does the feature work with screen readers?
- Are there color contrast requirements?
- Are there ARIA labels needed?
- Does the feature work on mobile/different screen sizes?
- Are there internationalization (i18n) requirements?

**Complete when**: WCAG 2.1 AA compliance plan is documented for all new UI.

---

## 12. Rollback Plan

- Can this feature be feature-flagged?
- What is the rollback procedure if something goes wrong?
- Is the rollback instant or does it require a deployment?
- Are there data changes that can't be rolled back? How to handle them?
- What monitoring/alerts should be in place post-launch?
- What is the rollout plan? (% rollout, canary, staged, big-bang)

**Complete when**: Feature flag strategy, rollback steps, and monitoring plan are documented.
