---
name: next-step
description: This skill should be used when deciding what to do next, prioritizing work, determining the next action, or when the user says "what should I do next", "what's the priority", "next step", "what now"
version: 0.1.0
---

# Next-Step Decision Tree Methodology

## Core Principles

1. **One recommendation.** User gets ONE action, not a list.
2. **Short-circuit.** Walk priority tree top-to-bottom, stop at first match.
3. **Higher priority wins.** P0 > P1 > P2 > P3 > P4.
4. **Tie-break**: higher-priority features first (P0 > P1), then closer to completion (spec-complete > proposed).

## Signal Sources

| Source | File | What to extract |
|--------|------|-----------------|
| Product Context | `.claude/product-context.md` | Backlog (priority, status, confidence), KPIs (status), test infra (TBD?), decision log (staleness), sprint |
| Feature Specs | `.claude/specs/*.md` | Open questions, drilling progress |
| Implementation | `.claude/pm-implement-state.local.md` | Current unit, iteration, stuck status, test results |

## Priority Levels

- **P0 Blockers**: No product context, stuck implementation, TBD test infra with spec-complete features
- **P1 In-Progress**: Active implementation running, specs with open questions
- **P2 Pipeline**: Features ready to implement or drill (P0 features first, then P1)
- **P3 Health**: At-risk KPIs, no sprint, low confidence features, stale decisions
- **P4 All Clear**: Everything healthy — suggest exploring new ideas

The `/pm-copilot:pm-next` command implements this methodology. See `commands/pm-next.md` for the full 14-check decision tree.
