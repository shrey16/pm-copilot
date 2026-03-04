---
description: Cancel an active implementation loop
allowed-tools: Read, Write, Bash
argument-hint:
---

# Cancel Implementation Loop

You are canceling an active PM Copilot implementation loop.

## Actions

1. **Check for active loop**: Read `.claude/pm-implement-state.local.md`. If it doesn't exist, inform the user: "No active implementation loop found. Nothing to cancel."

2. **If state file exists**:
   - Read the state file and extract current progress
   - Display a summary of what was in progress:
     ```
     ## Canceling Implementation Loop

     **Spec**: {spec name}
     **Current Unit**: {unit name} (iteration {N}/5)
     **Progress**: {X}/{Y} units completed

     ### Completed Units
     - {unit 1}: Complete
     - {unit 2}: Complete

     ### Incomplete Units
     - {unit 3}: In Progress (iteration 2/5)
     - {unit 4}: Pending
     ```
   - Use `AskUserQuestion` to confirm cancellation:
     - Header: "Confirm"
     - Question: "Are you sure you want to cancel the implementation loop? Generated code will be kept."
     - Options: "Yes, cancel the loop" / "No, keep it running"
   - If confirmed, delete the state file: `.claude/pm-implement-state.local.md`
   - Confirm: "Implementation loop canceled. The state file has been removed. Any code generated so far remains in place."

3. **Suggest next steps**:
   - "Run `/pm-copilot:pm-implement {spec-name}` to restart from the beginning"
   - "Run `/pm-copilot:pm-next` to see what to do next"
   - "Run `/pm-copilot:pm-status` to see the current product dashboard"

## Important

- **Do not delete generated code or test files.** Only delete the state file. The user may want to keep partial work.
- **Do not modify the product context.** The feature status should remain as it was.
