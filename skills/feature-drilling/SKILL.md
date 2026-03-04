---
name: feature-drilling
description: This skill should be used when drilling into a feature idea, exploring feature requirements, asking exhaustive questions about a feature, identifying edge cases, or when the user says "drill into", "explore feature", "what about edge cases", "feature requirements", "flesh out this idea"
version: 0.1.0
---

# Feature Drilling Methodology

## Overview

Feature drilling is the systematic process of eliminating all ambiguity from a feature idea through relentless, structured questioning. The goal is to transform a vague idea ("add search") into a fully specified set of requirements that an engineer could implement without asking a single clarifying question.

## Core Principles

1. **Never accept vague answers.** If the user says "it should be fast", ask "What is the maximum acceptable latency in milliseconds for the 95th percentile?"
2. **Cover all 12 categories.** Every feature must be examined through every lens in the drilling checklist. No exceptions.
3. **Track completion explicitly.** Each category is `[NOT STARTED]`, `[PARTIAL]`, or `[COMPLETE]`. Do not move to spec generation until all are `[COMPLETE]`.
4. **Ask one question at a time.** Wait for the answer before asking the next. Group related sub-questions only when they're tightly coupled.
5. **Push back on scope creep.** If a question reveals a new feature, note it as a separate backlog item. Don't let it absorb into the current feature.

## Questioning Techniques

### "What happens when..." (Error Discovery)
Force the user to think through failure modes:
- "What happens when the user has no internet connection during this flow?"
- "What happens when two users try to do this simultaneously?"
- "What happens when the user cancels halfway through?"
- "What happens when the input data is malformed?"

### "Specifically..." (Precision Forcing)
Convert vague statements into concrete specs:
- User says "notifications" → "Specifically, which channels: email, push, in-app, SMS? All of them or a subset?"
- User says "admin can manage" → "Specifically, can admin create, read, update, and delete? Or only a subset of CRUD?"

### "Boundary" (Limits Discovery)
Find min/max/default for every quantifiable value:
- "What's the minimum and maximum length for this field?"
- "What's the default value if the user doesn't specify?"
- "Is there a rate limit? What happens when it's exceeded?"
- "What's the maximum number of items in this list?"

### "Who else..." (Stakeholder Discovery)
Identify all affected parties:
- "Who else is affected when this action happens?"
- "Does anyone need to be notified?"
- "Who can see this data? Who can't?"

## Completion Criteria

A category is `[COMPLETE]` when:
- Every question in the checklist for that category has a concrete, specific answer
- No answer contains words like "maybe", "probably", "usually", "sometime", "TBD"
- The answers are consistent with each other (no contradictions)
- Edge cases within that category have been identified and addressed

A feature is **fully drilled** when all 12 categories are `[COMPLETE]`.

## Progress Tracking

Display a progress table after every 3-4 questions:

```
## Drilling Progress
| # | Category | Status | Notes |
|---|----------|--------|-------|
| 1 | User Flows | [COMPLETE] | 3 flows mapped |
| 2 | Edge Cases | [PARTIAL] | Concurrent access TBD |
| 3 | Success Metrics | [NOT STARTED] | |
...
```

## Handling "I Don't Know" Answers

When the user says "I don't know" or "I haven't thought about that":
1. Offer 2-3 concrete options based on common patterns
2. Explain the trade-offs of each option
3. Ask the user to pick one, or suggest a reasonable default
4. If the user picks a default, mark it as a **decision** to log in the product context

## Handling Scope Creep

When a question reveals something that's really a separate feature:
1. Acknowledge it: "That sounds like a separate feature."
2. Suggest adding it to the backlog: "I'll note '{idea}' as a backlog item."
3. Ask: "For this feature, should we assume {simple default} for now?"
4. Continue drilling the original feature.

---

For the complete 12-category checklist, see `references/drilling-checklist.md`.
