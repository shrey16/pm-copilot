# PM Copilot — Claude Code Plugin

Autonomous product management copilot that owns the Plan → Build → Ship → Measure loop.

## Commands

| Command | Description |
|---------|-------------|
| `/pm-init [name]` | Interactive Q&A to create product context for your project |
| `/pm-feature [idea]` | Exhaustive 12-category feature drilling → implementation-ready spec |
| `/pm-implement [spec]` | Autonomous implementation REPL — generates NestJS + React code, tests, and verifies against spec |
| `/pm-cancel-implement` | Cancel an active implementation loop |
| `/pm-next` | Intelligent next-step advisor — reads all state and recommends what to do next |
| `/pm-status` | Product health dashboard with metrics, backlog, and recommendations |

## How It Works

### Product Context
Every project gets a `.claude/product-context.md` file (created by `/pm-init`) that stores vision, personas, KPIs, feature backlog, decision log, and test infrastructure details. This is the shared brain across all PM commands.

### Feature Drilling
`/pm-feature` launches a relentless questioning agent that systematically covers 12 categories:

1. User Flows
2. Edge Cases
3. Success Metrics
4. Acceptance Criteria
5. Error States
6. Dependencies (including test infrastructure)
7. Scope Boundaries
8. Data Requirements
9. Performance
10. Security & Privacy
11. Accessibility
12. Rollback Plan

The agent refuses to stop until every category is `[COMPLETE]`. It then hands off to the spec-writer agent to produce an implementation-ready spec with a Test Strategy section.

### Implementation REPL
`/pm-implement` takes a feature spec and autonomously implements it:

1. **Detection** — Checks if NestJS + React project exists. Scaffolds if needed.
2. **Decomposition** — Breaks the spec into implementation units, each completable in ~5 iterations.
3. **Implementation Loop** (per unit, max 5 iterations):
   - **Implement** → generate NestJS controllers/services + React components
   - **Unit Test** → write + run Jest/Vitest tests
   - **E2E Test** → write + run Playwright tests
   - **Verify** → check each requirement from the spec
   - If failures → fix and iterate
4. **Integration Verification** — Run full test suite across all units.
5. **Summary** — Report results and update product context.

A `Stop` hook powers the REPL loop — it blocks exit while requirements remain pending or tests are failing, re-feeding the prompt to continue work.

### Agents

- **feature-driller** — The relentless questioner. Uses "What happens when...", "Specifically...", and "Boundary" techniques to eliminate all ambiguity.
- **spec-writer** — Converts drilled requirements into a structured spec with FR/NFR/edge cases/data model/API contracts.
- **implementer** — Code generator for NestJS + React. Follows existing codebase patterns.
- **unit-tester** — Writes and runs unit tests (Jest/Vitest) for each implementation unit.
- **e2e-tester** — Writes and runs Playwright E2E tests for user flows.
- **spec-verifier** — Read-only auditor that produces a pass/fail checklist for every spec requirement.

### Hooks
- **UserPromptSubmit** — Detects PM-related terms and reminds you to run `/pm-init` if no product context exists.
- **Stop** — Powers the implementation REPL loop. Blocks exit while requirements or tests are pending.

### MCP Integrations
- **Playwright** — Browser automation for E2E testing via `@playwright/mcp`

## Installation

Load the plugin with the `--plugin-dir` flag:

```bash
claude --plugin-dir ~/.claude/plugins/pm-copilot
```

On Windows with spaces in path, use the full path:

```powershell
claude --plugin-dir "C:\Users\Your Name\.claude\plugins\pm-copilot"
```

Commands will be available as `/pm-copilot:pm-init`, `/pm-copilot:pm-next`, etc.

## Future Plans

- `/pm-analyze` — Analytics-to-planning bridge with PostHog MCP integration
- `/pm-sprint` — Sprint planning from backlog
- Additional MCP integrations (PostHog, Linear)
