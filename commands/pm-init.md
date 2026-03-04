---
description: Initialize product context for the current project via interactive Q&A
allowed-tools: Read, Write, Edit, Glob, Grep, Bash
argument-hint: [product-name]
---

# Product Context Initialization

Create `.claude/product-context.md` through interactive questioning.

## Important Rules

- **Always use `AskUserQuestion`** — never ask questions as plain text. Provide 2-4 MCQ options.
- **Always recommend one option.** First option = recommended with "(Recommended)" label. Description explains WHY.
- **Ask ONE question at a time.** Wait for the answer.
- **Never assume answers.** Follow up on vague responses.
- **Use $ARGUMENTS as product name** if provided.
- **Check for existing context.** If `.claude/product-context.md` exists, ask: update or start fresh?
- **Do NOT use EnterPlanMode, ExitPlanMode, or Skill tool.**

---

## Phase 1: Explore Project (silently, no output)

Read `README.md`, `package.json`, `pyproject.toml`, configs, test setups. Note directory name. Gather context for smart defaults.

---

## Phase 2: Questions via AskUserQuestion

Ask one at a time. Infer smart defaults from Phase 1.

| # | Header | Question | Notes |
|---|--------|----------|-------|
| 1 | Product | Product name & one-liner | Skip if $ARGUMENTS provided. Infer from directory/package.json. |
| 2 | Vision | Long-term vision (1-2 years) | Suggest plausible visions from README/description. |
| 3 | Personas | Primary user personas (name, goal, pain point) | Suggest 2-3 profiles based on product type. |
| 4 | KPIs | 3-5 key metrics | Suggest relevant KPIs. Mark values as TBD if unknown. |
| 5 | Backlog | Top 3-5 planned features | Suggest from TODOs/issues if found in codebase. |
| 6 | Constraints | Technical constraints | Infer from dependencies, configs, README. |
| 7 | Stage | Product stage | Options: Pre-launch, Beta, Growth, Mature. |
| 8 | Testing | Test infrastructure | Infer from test configs. Mark TBD if none found. |

---

## Phase 3: Write Product Context

1. Create `.claude/` directory if needed.
2. Write `.claude/product-context.md` using this template:

```markdown
# Product Context: {product-name}

> {one-liner description}

## Vision

{vision statement}

## Stage

{current stage}

## Personas

### {Persona 1 Name} — {Role}
- **Goal**: {goal}
- **Pain Point**: {pain point}

{repeat for each persona}

## KPIs

| Metric | Current | Target | Status |
|--------|---------|--------|--------|
| {metric} | {current} | {target} | {on-track/at-risk/behind} |

## Feature Backlog

| # | Feature | Priority | Impact | Effort | Confidence | Status |
|---|---------|----------|--------|--------|------------|--------|
| 1 | {feature} | {P0-P3} | {H/M/L} | {H/M/L} | {H/M/L} | proposed |

## Technical Constraints

{constraints list}

## Test Infrastructure

{details or "TBD"}

## Decision Log

| Date | Decision | Rationale | Decided By |
|------|----------|-----------|------------|
| {today} | Initialized product context | Baseline for PM copilot | {user} |

## Analytics Snapshots

_No snapshots yet. Use `/pm-analyze` to populate._

## Current Sprint

_No sprint active. Use `/pm-sprint` to plan._
```

3. Confirm: "Product context created." Suggest `/pm-copilot:pm-next` or `/pm-copilot:pm-feature [idea]`.

---

**Begin now.** Phase 1 (explore), then Phase 2 (questions).
