#!/usr/bin/env bash
# PM Copilot — Setup Implementation Loop State File
#
# Usage: bash setup-implement-loop.sh <spec-path> <session-id>
#
# Creates .claude/pm-implement-state.local.md from a spec file.
# Extracts all FR-xxx requirements and sets them as pending.

SPEC_PATH="$1"
SESSION_ID="$2"

if [ -z "$SPEC_PATH" ]; then
  echo "Error: spec path required"
  echo "Usage: bash setup-implement-loop.sh <spec-path> <session-id>"
  exit 1
fi

if [ ! -f "$SPEC_PATH" ]; then
  echo "Error: spec file not found at $SPEC_PATH"
  exit 1
fi

if [ -z "$SESSION_ID" ]; then
  SESSION_ID="session-$(date +%s)"
fi

# Create .claude directory if needed
mkdir -p .claude

# Extract spec name from file path
SPEC_NAME=$(basename "$SPEC_PATH" .md)

# Extract all FR-xxx requirements from the spec
# Looks for lines in the FR table: | FR-001 | description | priority | criteria |
FR_LINES=$(grep -oP 'FR-\d+\s*\|\s*[^|]+' "$SPEC_PATH" 2>/dev/null || grep -E 'FR-[0-9]+' "$SPEC_PATH" | head -50)

# Build the requirements checklist
REQUIREMENTS=""
while IFS= read -r line; do
  # Extract FR-xxx and its description
  FR_ID=$(echo "$line" | grep -oP 'FR-\d+' 2>/dev/null || echo "$line" | grep -oE 'FR-[0-9]+')
  if [ -n "$FR_ID" ]; then
    # Try to extract description (text after FR-xxx and pipe)
    DESC=$(echo "$line" | sed "s/.*$FR_ID[[:space:]]*|[[:space:]]*//" | sed 's/[[:space:]]*|.*//' | head -c 100)
    if [ -z "$DESC" ]; then
      DESC="(see spec)"
    fi
    REQUIREMENTS="$REQUIREMENTS
- [ ] $FR_ID: $DESC"
  fi
done <<< "$FR_LINES"

# Deduplicate requirements (same FR-xxx may appear multiple times)
REQUIREMENTS=$(echo "$REQUIREMENTS" | sort -t: -k1,1 -u)

# Count requirements
REQ_COUNT=$(echo "$REQUIREMENTS" | grep -c "FR-" || true)

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S")

# Write the state file
cat > ".claude/pm-implement-state.local.md" << EOF
# PM Implementation State

## Meta
- Spec: $SPEC_PATH
- Session: $SESSION_ID
- Started: $TIMESTAMP
- Total Requirements: $REQ_COUNT

## Project
- Backend: (to be detected)
- Frontend: (to be detected)
- ORM: (to be detected)
- State Management: (to be detected)

## Units

_Units will be populated after spec decomposition in Phase 1._

## Requirements Checklist
$REQUIREMENTS
EOF

echo "State file created: .claude/pm-implement-state.local.md"
echo "Requirements found: $REQ_COUNT"
