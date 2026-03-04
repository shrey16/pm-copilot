#!/usr/bin/env bash
# PM Copilot — Implementation REPL Stop Hook
# Adapted from ralph-loop pattern.
#
# This hook runs on the Stop event. It reads the implementation state file
# and decides whether to block the stop (continue the loop) or allow it.
#
# Exit behavior:
#   - Exit 0 with no output → allow stop
#   - Output JSON with decision:"block" → block stop and re-feed prompt

STATE_FILE=".claude/pm-implement-state.local.md"

# If no state file exists, allow stop — no active loop
if [ ! -f "$STATE_FILE" ]; then
  exit 0
fi

# Read the state file
STATE=$(cat "$STATE_FILE")

# Extract current unit info
CURRENT_UNIT=$(echo "$STATE" | grep -A 5 "Status: in-progress" | head -1 | sed 's/### Unit [0-9]*: //')
ITERATION=$(echo "$STATE" | grep -A 5 "Status: in-progress" | grep "Iteration:" | head -1 | sed 's/.*Iteration: //' | sed 's|/5||')
MAX_ITERATIONS=5

# Count pending requirements (unchecked boxes)
PENDING_REQS=$(echo "$STATE" | grep -c "^\- \[ \]" || true)
TOTAL_REQS=$(echo "$STATE" | grep -c "^\- \[" || true)

# Count completed units
COMPLETED_UNITS=$(echo "$STATE" | grep -c "Status: complete" || true)
TOTAL_UNITS=$(echo "$STATE" | grep -c "^### Unit" || true)

# Count failed tests
FAILED_UNIT_TESTS=$(echo "$STATE" | grep -A 5 "Status: in-progress" | grep -c "Unit Tests: fail" || true)
FAILED_E2E_TESTS=$(echo "$STATE" | grep -A 5 "Status: in-progress" | grep -c "E2E Tests: fail" || true)
TOTAL_FAILING=$((FAILED_UNIT_TESTS + FAILED_E2E_TESTS))

# If max iterations reached for current unit, allow stop but report
if [ -n "$ITERATION" ] && [ "$ITERATION" -ge "$MAX_ITERATIONS" ] 2>/dev/null; then
  # Check if there are more pending units after the current one
  PENDING_UNITS=$(echo "$STATE" | grep -c "Status: pending" || true)
  if [ "$PENDING_UNITS" -eq 0 ] && [ "$PENDING_REQS" -eq 0 ]; then
    # All done (or all maxed out) — allow stop
    exit 0
  fi
  # More units to process — continue
  REASON="Continue implementing. Current unit '$CURRENT_UNIT' reached max iterations ($MAX_ITERATIONS). Moving to next unit. $COMPLETED_UNITS/$TOTAL_UNITS units completed. $PENDING_REQS requirements still pending."
  echo "{\"decision\": \"block\", \"reason\": \"$REASON\"}"
  exit 0
fi

# If all requirements are satisfied and all tests pass, allow stop
if [ "$PENDING_REQS" -eq 0 ] && [ "$TOTAL_FAILING" -eq 0 ] && [ "$TOTAL_REQS" -gt 0 ]; then
  exit 0
fi

# Otherwise, block stop and continue the loop
REASON="Continue implementing. Unit: '$CURRENT_UNIT'. Iteration ${ITERATION:-0}/$MAX_ITERATIONS."

if [ "$PENDING_REQS" -gt 0 ]; then
  REASON="$REASON $PENDING_REQS/$TOTAL_REQS requirements pending."
fi

if [ "$TOTAL_FAILING" -gt 0 ]; then
  REASON="$REASON $TOTAL_FAILING test suites failing."
fi

REASON="$REASON Fix the failures and re-run tests."

echo "{\"decision\": \"block\", \"reason\": \"$REASON\"}"
exit 0
