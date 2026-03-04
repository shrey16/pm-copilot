---
name: spec-generation
description: This skill should be used when generating a feature specification, writing a PRD, creating a product spec, converting requirements into a spec document, or when the user says "write the spec", "generate spec", "create PRD", "product requirements document"
version: 0.1.0
---

# Spec Generation

## Overview

Spec generation converts drilled requirements (the output of feature drilling) into a structured, implementation-ready specification document. A good spec eliminates all ambiguity for engineers — they should be able to implement the feature without asking a single clarifying question.

## Quality Criteria

A spec is **implementation-ready** when it meets ALL of these criteria:

1. **Unambiguous**: Every requirement has exactly one interpretation
2. **Complete**: All 12 drilling categories are represented
3. **Testable**: Every requirement can be verified with a test
4. **Prioritized**: Requirements are clearly labeled as must-have (P0), should-have (P1), or nice-to-have (P2)
5. **Bounded**: Scope boundaries are explicit — what's in and what's out
6. **Measurable**: Success metrics have concrete targets and measurement plans
7. **Consistent**: No contradictions between sections

## Writing Style

- **Use active voice**: "The system sends a notification" not "A notification is sent"
- **Be specific**: "Response time < 200ms at p95" not "The system should be fast"
- **Use RFC 2119 keywords**: MUST, SHOULD, MAY for requirement levels
- **Include examples**: For complex logic, include concrete examples with actual values
- **Number everything**: Every requirement gets a unique ID (FR-001, NFR-001, etc.)

## Spec Structure

Follow the template in `templates/feature-spec-template.md`. Key sections:

1. **Overview** — One-paragraph summary, target persona, problem statement
2. **User Flows** — Step-by-step flows with decision points
3. **Functional Requirements** — Numbered, prioritized, testable
4. **Non-Functional Requirements** — Performance, security, accessibility
5. **Data Model** — Entities, fields, types, constraints, relationships
6. **API Contracts** — Endpoints, request/response shapes, error codes (if applicable)
7. **Edge Cases & Error Handling** — Exhaustive table of scenarios and responses
8. **Success Metrics** — Metrics with baselines, targets, measurement plans
9. **Dependencies** — Upstream/downstream with risk assessment
10. **Scope & Phasing** — What's in v1, what's deferred, rationale
11. **Rollback Plan** — Feature flags, monitoring, rollback steps
12. **Open Questions** — Anything genuinely unresolved (should be minimal after drilling)
13. **Decision Log** — All decisions made during drilling with rationale

## Common Mistakes to Avoid

- Writing vague requirements that can't be tested ("improve user experience")
- Missing error states ("what if the API returns 500?")
- Assuming happy path only — every flow needs its error counterpart
- Mixing requirements with implementation details ("use Redis for caching" — that's an implementation choice, not a requirement)
- Forgetting non-functional requirements (performance, security, accessibility)
- Not specifying default values and boundaries for every field

---

For the quality review checklist, see `references/spec-quality-criteria.md`.
For the spec template, see `templates/feature-spec-template.md`.
