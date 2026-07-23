#!/bin/bash

# Session Start Hook
# Fires on every UserPromptSubmit. Injects client context before the first response.
# Uses vault-relative paths — no hardcoded locations.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="$(cd "$HOOK_DIR/../.." && pwd)"

INBOX="$VAULT_ROOT/Brain/Inbox.md"
MASTER="$VAULT_ROOT/Brain/Master.md"
TODAY=$(date +"%Y-%m-%d")
DAY_OF_WEEK=$(date +"%A")

# Staging dir — per-vault, inside .claude/
STAGING_DIR="$VAULT_ROOT/.claude/staging"
mkdir -p "$STAGING_DIR"
> "$STAGING_DIR/surfaced_this_session.txt"

echo "=== SESSION START ==="
echo "Date: $TODAY ($DAY_OF_WEEK)"
echo ""

# Detect client name from Personality/ identity file
# /setup populates Personality/[Name].md with the real name as the first H1
IDENTITY_FILE=""
CLIENT_NAME="Client"
for f in "$VAULT_ROOT/Personality/"*.md; do
  basename_f=$(basename "$f")
  # Skip the standard non-identity files
  if [[ "$basename_f" == "Mistake_Patterns.md" || "$basename_f" == "Working_Preferences.md" ]]; then
    continue
  fi
  IDENTITY_FILE="$f"
  # Extract name from first # heading
  FIRST_H1=$(grep -m1 "^# " "$f" 2>/dev/null | sed 's/^# //')
  if [[ -n "$FIRST_H1" && "$FIRST_H1" != "[Name]"* ]]; then
    CLIENT_NAME="$FIRST_H1"
  fi
  break
done

echo "--- CORE CONTEXT ---"
if [[ -n "$IDENTITY_FILE" ]]; then
  echo "Per CLAUDE.md: Read Personality/$(basename "$IDENTITY_FILE"), Personality/Working_Preferences.md, and Personality/Mistake_Patterns.md now."
else
  echo "Per CLAUDE.md: Read Personality/[Name].md, Personality/Working_Preferences.md, and Personality/Mistake_Patterns.md now."
fi
echo ""

# Check Inbox.md for unprocessed items
if [[ -f "$INBOX" ]]; then
  INBOX_ITEMS=$(grep -c "^- \[ \]" "$INBOX" 2>/dev/null || echo "0")
  if [[ "$INBOX_ITEMS" -gt 0 ]]; then
    echo "--- INBOX ---"
    echo "⚠ $INBOX_ITEMS unprocessed item(s) in Brain/Inbox.md"
    grep "^- \[ \]" "$INBOX" | head -5
    if [[ "$INBOX_ITEMS" -gt 5 ]]; then
      echo "  ... and $((INBOX_ITEMS - 5)) more"
    fi
    echo ""
  fi
fi

# Day-of-week reminders
if [[ "$DAY_OF_WEEK" == "Monday" ]]; then
  echo "--- MONDAY ---"
  echo "📋 Start of the week. Consider running /daily to set priorities."
  echo ""
fi
if [[ "$DAY_OF_WEEK" == "Friday" ]]; then
  echo "--- FRIDAY ---"
  echo "📋 End of week. Consider running /wrap to close out open threads."
  echo ""
fi

# Build context injection index
NODE_BIN=$(which node 2>/dev/null || echo "node")
INDEX_SCRIPT="$VAULT_ROOT/.claude/hooks/build-context-index.js"
if [[ -f "$INDEX_SCRIPT" ]]; then
  "$NODE_BIN" "$INDEX_SCRIPT" 2>/dev/null || echo "[context-index] Build failed — skipping"
fi

echo "=== READY ==="
