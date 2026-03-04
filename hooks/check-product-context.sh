#!/usr/bin/env bash
# PM Copilot: Check if product context exists when PM-related terms are used
# This hook fires on UserPromptSubmit and reads the user's prompt from stdin (JSON)

set -euo pipefail

# Read the hook input from stdin
INPUT=$(cat)

# Extract the user's prompt text from the JSON input
PROMPT=$(echo "$INPUT" | python -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(data.get('prompt', ''))
except:
    print('')
" 2>/dev/null || echo "")

# Check if the prompt contains PM-related terms (case-insensitive)
PM_TERMS="feature spec|product spec|PRD|product requirements|feature request|backlog|user story|acceptance criteria|feature drill|product context|KPI|success metric"

if echo "$PROMPT" | grep -qiE "$PM_TERMS"; then
    # Check if product context exists
    if [ ! -f ".claude/product-context.md" ]; then
        echo '{"message": "💡 PM Copilot: No product context found for this project. Run /pm-init to set up your product context for better results."}'
    fi
fi

# Exit successfully (don't block the prompt)
exit 0
