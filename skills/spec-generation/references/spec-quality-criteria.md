# Spec Quality Review Checklist

Use this checklist to review a spec before marking it as "Approved". Every item must be checked.

---

## Completeness

- [ ] All 13 sections of the spec template are present and filled
- [ ] Every functional requirement has an ID, priority, and acceptance criteria
- [ ] Every non-functional requirement has a measurable target
- [ ] All user flows cover both happy path and error paths
- [ ] Data model includes all entities, fields, types, constraints, and defaults
- [ ] Edge cases table has at least 5 scenarios (empty state, overflow, concurrent, network failure, cancel)
- [ ] Success metrics have baselines, targets, timeframes, and measurement methods
- [ ] Dependencies are listed with risk levels and mitigations
- [ ] Scope boundaries are explicit (in scope AND out of scope)
- [ ] Rollback plan includes feature flag, monitoring, and rollback steps

## Clarity

- [ ] No requirement uses vague language ("fast", "user-friendly", "scalable", "easy")
- [ ] Every requirement has exactly one interpretation (unambiguous)
- [ ] RFC 2119 keywords (MUST, SHOULD, MAY) are used consistently
- [ ] Examples are provided for complex logic
- [ ] Acronyms are defined on first use

## Testability

- [ ] Every functional requirement can be verified with a specific test
- [ ] Acceptance criteria use Given/When/Then or equivalent testable format
- [ ] Performance targets include specific numbers (latency, throughput, volume)
- [ ] Error messages are specified as exact copy, not just "show an error"

## Consistency

- [ ] No contradictions between sections (e.g., data model vs. API contracts)
- [ ] Requirement IDs are sequential and unique (no duplicates)
- [ ] Terminology is consistent throughout (same term for same concept)
- [ ] Priority levels are consistent (P0/P1/P2 used uniformly)

## Feasibility

- [ ] No requirements that assume specific implementation details
- [ ] Dependencies are available or have mitigation plans
- [ ] Performance targets are realistic for the expected scale
- [ ] Security requirements align with the product's compliance needs

## Decision Documentation

- [ ] All decisions from drilling are captured in the Decision Log
- [ ] Deferred items are listed in "Out of Scope" with rationale
- [ ] Open questions (if any) have owners and due dates

---

## Scoring

Count checked items and divide by total:
- **90-100%**: Ready for engineering
- **70-89%**: Needs minor revisions
- **50-69%**: Needs significant rework
- **Below 50%**: Incomplete — return to drilling

A spec MUST score 90%+ before being marked as "Approved".
