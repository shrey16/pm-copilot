---
description: Initialize product context for the current project via interactive Q&A
allowed-tools: Read, Write, Edit, Glob, Grep, Bash, Agent
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
- **Check for existing context.** If `.claude/product-context.md` exists, offer three options: Update (keep existing, add new detections), Re-sync (rescan features only, skip Q&A), or Start fresh (discard and rebuild). Store the choice to control later phases.
- **Do NOT use EnterPlanMode, ExitPlanMode, or Skill tool.**

---

## Phase 0: Existing Context Check

Use the Read tool to check whether `.claude/product-context.md` exists.

**If the file EXISTS:**

Use `AskUserQuestion` with the following question and options:

> "A product context file already exists for this project. How would you like to proceed?"

| Option | Label | Description |
|--------|-------|-------------|
| 1 (Recommended) | Update | Keep existing context. Scan codebase for newly detected features and add them. Run Q&A only for fields that are missing or outdated. |
| 2 | Re-sync | Rescan features only. Skip the full Q&A entirely. Present detected features for confirmation, then write updated backlog. |
| 3 | Start fresh | Discard the existing product-context.md and rebuild from scratch. Runs full scan + full Q&A. |

Store the user's choice as **SYNC_MODE** (`update`, `re-sync`, or `start-fresh`). This value controls skipping behaviour in Phase 3 (Q&A) and Phase 4 (write).

Flow by choice:
- **Update** (`update`): Proceed to Phase 1 (scan). In Phase 3, skip Q&A fields that already have answers in the existing file. In Phase 4, merge new data into the existing file.
- **Re-sync** (`re-sync`): Proceed to Phase 1 (scan). Skip Phase 3 Q&A entirely. In Phase 4, update only the Feature Backlog section and the Decision Log; all other sections remain unchanged.
- **Start fresh** (`start-fresh`): Proceed normally — full Phase 1 scan, full Phase 1.5 confirmation, full Phase 2 explore, full Phase 3 Q&A, full Phase 4 write. Overwrite the existing file.

**If the file does NOT exist:**

Set SYNC_MODE to `new`. Proceed normally — full Phase 1 scan, full Phase 1.5 confirmation, full Phase 2 explore, full Phase 3 Q&A, full Phase 4 write.

---

## Phase 1: Auto-Scan Codebase

Output the message: "Scanning codebase for existing features..."

Then use the `Agent` tool with `subagent_type: "Explore"` to scan the codebase for existing features. Pass the following complete instructions to the subagent:

---

**Subagent instructions (copy verbatim into the Agent prompt):**

> You are a codebase feature scanner. Your job is to detect existing features in this project by searching for known file patterns. Work silently — do not explain what you are doing. At the end, return a structured list of detected features.
>
> **Security rules — NEVER read or report contents of:**
> - `.env`, `.env.*`, `.env.local`, `.env.production`, `.env.staging`
> - `credentials.*`, `secrets.*`, `*.key`, `*.pem`, `*.p12`, `*.pfx`, `*.cer`
> - Any file whose name contains "secret", "password", or "token"
> - Files listed in `.gitignore` (read `.gitignore` first if it exists and skip those paths)
>
> **Cross-platform path rules:** Use forward slashes in all glob patterns. Do not use backslashes.
>
> **Scan the following pattern categories using the Glob tool:**
>
> 1. **Plugin / Skill definitions**
>    - `commands/*.md`
>    - `skills/**/*.md`
>    - `**/SKILL.md`
>    - `.claude/commands/*.md`
>    - `.claude/skills/**/*.md`
>
> 2. **API route handlers**
>    - `**/routes/**/*.ts`
>    - `**/routes/**/*.js`
>    - `**/controllers/**/*.ts`
>    - `**/controllers/**/*.js`
>    - `**/*.controller.ts`
>    - `**/*.controller.js`
>    - `**/api/**/*.ts`
>    - `**/api/**/*.js`
>
> 3. **React / UI components**
>    - `**/components/**/*.tsx`
>    - `**/components/**/*.jsx`
>    - `**/components/**/*.ts`
>    - `**/pages/**/*.tsx`
>    - `**/pages/**/*.jsx`
>    - `**/views/**/*.tsx`
>    - `**/views/**/*.jsx`
>
> 4. **CLI commands**
>    - `**/commands/**/*.ts`
>    - `**/commands/**/*.js`
>    - `**/commands/**/*.md`
>    - `**/cli/**/*.ts`
>    - `**/cli/**/*.js`
>    - `bin/**`
>
> 5. **Config file entries**
>    - `package.json` — read and extract the `scripts` keys as feature signals
>    - `nest-cli.json`
>    - `vite.config.*`
>    - `webpack.config.*`
>    - `tsconfig*.json`
>    - `.claude/settings.json` — if present, extract any listed commands/skills
>
> 6. **Test files (feature signals)**
>    - `**/*.test.ts`
>    - `**/*.test.tsx`
>    - `**/*.test.js`
>    - `**/*.spec.ts`
>    - `**/*.spec.tsx`
>    - `**/*.spec.js`
>    - `**/__tests__/**/*.ts`
>    - `**/__tests__/**/*.js`
>
> **For each match found:**
> - Derive a human-readable feature name from the file or directory name (e.g., `pm-init.md` → "pm-init", `user.controller.ts` → "User API", `LoginPage.tsx` → "Login Page").
> - Assign category: one of `skill`, `api-route`, `ui-component`, `cli-command`, `config-entry`, `test-coverage`.
> - Assign status: `shipped` (file exists in codebase).
> - Assign confidence: `high` if the file is clearly a feature (e.g., a named skill, a route controller, a page component). Assign `low` if the file is ambiguous (e.g., could be a feature or a utility, a generic helper that might represent a feature, or a file whose purpose is unclear from its name alone).
> - Do NOT skip ambiguous files — include them with `confidence: "low"` so the user can decide during confirmation.
> - Skip files that are clearly infrastructure-only (e.g., `utils.ts`, `helpers.js`, `index.ts` that only re-exports, `types.ts`, `constants.ts`).
> - Skip `node_modules/**`, `dist/**`, `build/**`, `.git/**`, `coverage/**`, `.next/**`, `out/**`.
>
> **If the total number of matched files exceeds 200**, stop scanning, report the count, and include this message in your output: `SCOPE_TOO_LARGE: Found {count} files. User must narrow scope.`
>
> **If any Glob or Read call errors** (permission denied, path not found), skip that pattern silently and continue with remaining patterns.
>
> **Output format — return ONLY this JSON structure, nothing else:**
> ```json
> {
>   "detected_features": [
>     { "name": "Feature Name", "category": "skill|api-route|ui-component|cli-command|config-entry|test-coverage", "status": "shipped", "confidence": "high|low", "source_file": "relative/path/to/file.ext" }
>   ],
>   "scope_too_large": false,
>   "total_files_scanned": 12,
>   "scan_errors": []
> }
> ```

---

**After the subagent returns:**

1. Parse the JSON output from the subagent.

2. **If `scope_too_large` is true:**
   Use `AskUserQuestion` to ask:
   > "The codebase has too many files to scan automatically (over 200 matches). Please select a directory to narrow the scan scope:"

   Offer options derived from top-level directories visible in the project (use Glob `*` to list them). Include an option "Scan everything anyway (may be slow)" and "Skip scan, go to Q&A". Re-run the subagent scan on the chosen subdirectory if needed, or set ZERO_DETECTION = true and proceed to Phase 2 if the user skips.

3. **If `detected_features` is empty OR the list has 0 entries:**
   Set **ZERO_DETECTION = true**. Output the message: "No existing features detected — proceeding to questions." Do NOT show a confirmation step — proceed directly to Phase 2.

4. **If features were detected:**
   Set **ZERO_DETECTION = false**. Store the parsed array as **DETECTED_FEATURES**. Proceed to Phase 1.5 (Feature Confirmation).

   Deduplicate: if two entries resolve to the same feature name (case-insensitive), keep one — prefer the entry with the more specific category (e.g., prefer `skill` over `test-coverage`).

5. **Do not print the raw JSON or intermediate output to the user.** This entire phase is silent except for the scope-too-large error path.

---

## Phase 1.5: Feature Confirmation + Verification

**Skip this phase entirely if ZERO_DETECTION = true** — the zero-detection message was already shown in Phase 1, and there are no features to confirm.

---

### Step A: Present Detected Features for Confirmation

Use `AskUserQuestion` to show the list of DETECTED_FEATURES and ask the user to confirm or edit. Format the question text as a numbered list grouped by category.

Example question text:

> "The following features were detected in your codebase:
>
> 1. pm-init (skill)
> 2. pm-feature (skill)
> 3. User API (api-route)
> 4. Login Page (ui-component)
> 5. DataHelper (cli-command) [low confidence]
>
> How would you like to proceed?"

Populate the numbered list dynamically from DETECTED_FEATURES (name + category for each entry). For entries with `confidence: "low"`, append `[low confidence]` to the line so the user can pay extra attention to those. Show all entries.

Options:

| Option | Label | Description |
|--------|-------|-------------|
| 1 (Recommended) | Confirm all as shipped | Accept the full detected list. All entries will be written to the backlog with status "shipped". |
| 2 | Remove some items | Specify which detected items to remove before confirming. |
| 3 | Add more manually | Accept all detected items and also add additional features by typing them in. |

**If the user selects "Remove some items":**

Use a follow-up `AskUserQuestion` with checkboxes or a numbered list asking which items to exclude:

> "Which detected features would you like to remove from the list? Enter the numbers separated by commas (e.g., 2, 4)."

Provide options listing each detected feature by number and name, plus "None — keep all". Remove the indicated entries from DETECTED_FEATURES before proceeding.

**If the user selects "Add more manually":**

Use a follow-up `AskUserQuestion`:

> "Enter additional feature names, one per line. Format: 'Feature Name (category)' where category is one of: skill, api-route, ui-component, cli-command, config-entry. Example: 'Dark Mode (ui-component)'"

Parse the user's typed input and append each new entry to the feature list with status "proposed" (since these were not detected in the codebase, their existence is unconfirmed).

---

### Step B: Backlog Status Verification (FR-005)

**Only run this step if SYNC_MODE is `update` or `re-sync`** (i.e., an existing `product-context.md` was found in Phase 0).

1. Read the existing `product-context.md` Feature Backlog table.

2. For each row in the existing backlog, extract the feature name and current status.

3. Compare against DETECTED_FEATURES using fuzzy name matching (case-insensitive, strip punctuation and extra whitespace for comparison):

   - **Mismatch type A**: Feature is in the backlog with status "proposed" BUT it was detected in the codebase → flag as: "Code exists — mark as shipped?"
   - **Mismatch type B**: Feature is in the backlog with status "shipped" BUT it was NOT found in DETECTED_FEATURES → flag as: "Code not found — still shipped?"

4. **If no mismatches are found**, proceed silently to Step C.

5. **If mismatches are found**, use `AskUserQuestion` to present them:

   Example question text:

   > "The following backlog entries may have incorrect statuses based on the codebase scan:
   >
   > 1. 'pm-sync' — listed as 'proposed' but code was detected → suggest: shipped
   > 2. 'pm-dashboard' — listed as 'shipped' but no code found → suggest: proposed
   >
   > How would you like to handle these?"

   Options:

   | Option | Label | Description |
   |--------|-------|-------------|
   | 1 (Recommended) | Accept all suggested status changes | Apply all suggested corrections automatically. |
   | 2 | Review each mismatch individually | Step through each mismatch one at a time with a separate AskUserQuestion per item. |
   | 3 | Keep existing statuses | Ignore mismatches. Write the backlog with existing statuses unchanged. |

   **If "Review each mismatch individually" is selected**, loop through each mismatch and ask:

   > "Backlog entry '{name}' is listed as '{current_status}', but {mismatch_reason}. What should the status be?"
   > Options: "shipped" / "proposed" / "remove from backlog"

   Apply the user's choice per item.

---

### Step C: Build CONFIRMED_FEATURES

After Steps A and B are complete, assemble the final confirmed list as **CONFIRMED_FEATURES**.

CONFIRMED_FEATURES is the authoritative list for all downstream phases (Phase 2, Phase 3, Phase 4). DETECTED_FEATURES should no longer be referenced after this point.

Each entry in CONFIRMED_FEATURES stores only:
- `name` — the feature name (string)
- `status` — either `"shipped"` or `"proposed"`

Nothing else. Priority, impact, effort, and confidence are filled in during Phase 3 (Q&A).

**Merge rules for CONFIRMED_FEATURES:**

- All user-confirmed detected features → status: `shipped`
- Manually added features (from "Add more manually") → status: `proposed`
- Existing backlog entries with corrected statuses (from Step B) → use resolved status
- Existing backlog entries not flagged as mismatches → carry forward their existing status unchanged
- Deduplicate by name (case-insensitive). Keep one entry per feature, preferring the corrected/confirmed version over the original.

---

## Phase 2: Explore Project (silently, no output)

Read `README.md`, `package.json`, `pyproject.toml`, configs, test setups. Note directory name. Gather additional context for smart defaults (tech stack, dependencies, description, scripts). This supplements the scan from Phase 1 — do not re-scan files already processed.

---

## Phase 3: Questions via AskUserQuestion

Ask one at a time. Infer smart defaults from Phase 2 (project exploration) and CONFIRMED_FEATURES (from Phase 1.5 confirmation).

**Skip this phase entirely if SYNC_MODE = `re-sync`.**

For SYNC_MODE = `update`, skip any question whose answer is already present and non-empty in the existing product-context.md.

**When CONFIRMED_FEATURES is empty (ZERO_DETECTION = true), ask ALL questions in their original form. Adaptation only applies when CONFIRMED_FEATURES is non-empty.**

| # | Header | Question | Adaptation (when CONFIRMED_FEATURES is non-empty) |
|---|--------|----------|--------------------------------------------------|
| 1 | Product | Product name & one-liner | Skip if $ARGUMENTS provided. Use package.json `name`/`description` as recommended option if available. |
| 2 | Vision | Long-term vision (1-2 years) | If 5+ shipped features, bias toward "scaling"/"expanding" rather than "building from scratch". |
| 3 | Personas | Primary user personas (name, goal, pain point) | If ui-component entries exist, suggest end-user personas. If only api-route/cli-command, suggest developer personas. |
| 4 | KPIs | 3-5 key metrics | Bias toward usage-based KPIs (DAU, feature adoption). Mark values as TBD if unknown. |
| 5 | Backlog | Top 3-5 planned features | Ask "What are the NEXT features?" not "what are your planned features?" — backlog is pre-filled with confirmed entries. |
| 6 | Constraints | Technical constraints | Infer and pre-fill backend/frontend from api-route/ui-component entries + Phase 2 exploration. Skip if fully determined. |
| 7 | Stage | Product stage | Options: Pre-launch, Beta, Growth, Mature. Recommend "Beta"/"Growth" if shipped features exist. "Growth"/"Mature" if 10+. |
| 8 | Testing | Test infrastructure | Infer test framework from Phase 2 configs. Pre-fill and skip if fully determined. Mark TBD if none found. |

---

## Phase 4: Write Product Context

Write behaviour depends on SYNC_MODE:

- **`new` or `start-fresh`**: Write the full file using the template below. Overwrite any existing file.
- **`update`**: Read the existing file first. Merge new Q&A answers and CONFIRMED_FEATURES backlog entries into the existing sections. Append a new row to the Decision Log. Do not overwrite sections that already have content unless the user explicitly changed them.
- **`re-sync`**: Read the existing file first. Replace only the Feature Backlog table with the updated list (CONFIRMED_FEATURES + existing entries with corrected statuses from Phase 1.5). Append a new row to the Decision Log. All other sections remain unchanged.

1. Create `.claude/` directory if needed.
2. Write `.claude/product-context.md` using this template (for `new` and `start-fresh`):

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

**Backlog ordering rule** (for `new` and `start-fresh` modes): In the Feature Backlog table, list CONFIRMED_FEATURES entries with status "shipped" FIRST (sorted alphabetically by name), followed by proposed features from Q5 answers (sorted alphabetically by name).

3. Confirm: "Product context created." Add: "To undo, run: `git checkout .claude/product-context.md`". Suggest `/pm-copilot:pm-next` or `/pm-copilot:pm-feature [idea]`.

---

**Begin now.** Phase 0 (existing context check), then Phase 1 (auto-scan codebase), then Phase 1.5 (feature confirmation + verification, skipped if zero detection), then Phase 2 (explore project), then Phase 3 (questions if applicable), then Phase 4 (write product context).
