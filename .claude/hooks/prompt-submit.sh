#!/bin/bash
# UserPromptSubmit hook — session log staleness check.
# Fires before every response. Reminds to log if the last entry was > 30 min ago.

HOOK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="$(cd "$HOOK_DIR/../.." && pwd)"
SESSIONS_DIR="$VAULT_ROOT/Brain/Session_Logs"

NOW_EPOCH=$(date +%s)
SESSION_FILE=$(ls -t "$SESSIONS_DIR/"*.md 2>/dev/null | head -1)

if [[ -n "$SESSION_FILE" ]]; then
  LAST_EPOCH=$(stat -f %m "$SESSION_FILE" 2>/dev/null)

  if [[ -n "$LAST_EPOCH" ]]; then
    GAP=$((NOW_EPOCH - LAST_EPOCH))

    if [[ $GAP -gt 1800 ]]; then
      GAP_MIN=$((GAP / 60))
      echo "— $(basename "$SESSION_FILE") last updated ${GAP_MIN} min ago. Does the recent exchange need a Session Log entry?"
    fi
  fi
fi
