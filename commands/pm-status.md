---
description: Display product health dashboard from product context
allowed-tools: Read, Glob, Grep
argument-hint:
---

# Product Status Dashboard

You are a product management copilot generating a product health dashboard.

## Steps

### 1. Read Product Context

Read `.claude/product-context.md` in the current project. If the file does not exist, tell the user:

> "No product context found. Run `/pm-copilot:pm-init` first to set up your product context."

Then stop.

### 2. Gather Additional State

Use `Glob` to also check:
- `.claude/specs/*.md` — count how many specs exist and their status
- `.claude/pm-implement-state.local.md` — check if an implementation loop is active

### 3. Generate Dashboard

Format the product context into a clean, scannable dashboard. Use this exact structure:

---

**{Product Name}** — {one-liner}
**Stage**: {stage} | **Last Updated**: {file modification date or decision log date}

---

#### KPI Health

Display each KPI with a status indicator:
- On Track — current is within 10% of target or exceeding
- At Risk — current is 10-30% below target
- Behind — current is >30% below target
- Unknown — no current value

| Metric | Current | Target | Status |
|--------|---------|--------|--------|

#### Backlog Summary

Show the backlog grouped by priority:
- **P0 (Critical)**: list features with status
- **P1 (High)**: list features with status
- **P2 (Medium)**: list features with status
- **P3 (Low)**: list features with status

Include total count: "**{N} features** in backlog ({X} implemented, {Y} spec-complete, {Z} proposed)"

#### Specs on Disk

List specs found in `.claude/specs/` and whether they match backlog entries.

#### Active Implementation

If `.claude/pm-implement-state.local.md` exists, show current progress (unit, iteration, test status). Otherwise: "_No active implementation loop._"

#### Recent Decisions

Show the last 5 entries from the decision log, most recent first.

#### Active Sprint

Show current sprint contents if any. Otherwise: "_No active sprint._"

### 4. Recommendations

Based on the dashboard data, provide 2-3 actionable recommendations. Examples:
- "KPI {X} is behind target. Consider running `/pm-copilot:pm-feature` to explore improvements."
- "Backlog has {N} P0 items but no active sprint. Consider running `/pm-copilot:pm-sprint`."
- "{N} features have low confidence. Run `/pm-copilot:pm-feature [name]` to drill into requirements."
- "Run `/pm-copilot:pm-next` for a prioritized recommendation on what to do next."

---

**Begin now.** Read the product context and generate the dashboard.
