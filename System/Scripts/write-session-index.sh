#!/bin/bash
# write-session-index.sh — Appends a summary entry to Brain/Session_Logs/INDEX.md
# Called by /wrap. Idempotent: skips if entry already exists for this session.
# Usage: write-session-index.sh [session-file-path] [--force]
#   --force: overwrite existing entry (used by /wrap to replace a partial entry)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INDEX="$VAULT/Brain/Session_Logs/INDEX.md"
LOCK="/tmp/write-session-index.lock"
FORCE=false

# Resolve claude binary
CLAUDE_BIN=$(which claude 2>/dev/null || echo "")
if [ -z "$CLAUDE_BIN" ]; then
  NVM_NODE=$(ls -dt "$HOME/.nvm/versions/node"/*/bin/claude 2>/dev/null | head -1)
  [ -n "$NVM_NODE" ] && CLAUDE_BIN="$NVM_NODE"
fi
if [ -z "$CLAUDE_BIN" ]; then
  echo "[session-index] claude binary not found — skipping" >&2
  exit 1
fi

SESSION_FILE="$1"
shift
[ "$1" = "--force" ] && FORCE=true

# Find session file if not passed
if [ -z "$SESSION_FILE" ] || [ ! -f "$SESSION_FILE" ]; then
  SESSION_FILE=$(ls -t "$VAULT/Brain/Session_Logs/"*.md 2>/dev/null | grep -v "INDEX.md" | head -1)
fi

if [ -z "$SESSION_FILE" ] || [ ! -f "$SESSION_FILE" ]; then
  echo "[session-index] No session file found — skipping" >&2
  exit 0
fi

SESSION_STEM=$(basename "$SESSION_FILE" .md)

# Skip if entry already exists (unless --force)
if grep -q "^## $SESSION_STEM$" "$INDEX" 2>/dev/null; then
  if [ "$FORCE" = false ]; then
    echo "[session-index] Entry already exists for $SESSION_STEM — skipping (use --force to overwrite)"
    exit 0
  fi
fi

# Lock to prevent concurrent writes
if [ -f "$LOCK" ]; then
  echo "[session-index] Lock file exists — another write in progress, skipping" >&2
  exit 0
fi
touch "$LOCK"
trap "rm -f '$LOCK'" EXIT

SESSION_CONTENT=$(cat "$SESSION_FILE")
WORD_COUNT=$(echo "$SESSION_CONTENT" | wc -w | tr -d ' ')

if [ "$WORD_COUNT" -lt 100 ]; then
  echo "[session-index] Session too short ($WORD_COUNT words) — skipping"
  exit 0
fi

echo "[session-index] Generating summary for $SESSION_STEM..."

# Generate summary via headless Claude — run from /tmp to avoid loading vault CLAUDE.md
SUMMARY=$(cd /tmp && echo "$SESSION_CONTENT" | "$CLAUDE_BIN" -p \
  "Write a search index entry for this session log. Output EXACTLY this format with no preamble:
Topics: [5-8 comma-separated keywords]
[2-3 dense sentences: what was discussed, decided, or built. Name projects and tools specifically.]

Example:
Topics: client onboarding, CRM setup, email pipeline, integrations, goals
Completed /setup for a new client. Connected Google Calendar and Gmail MCPs. Seeded Master.md with four active projects and created People files for eleven key contacts." 2>/dev/null)

if [ -z "$SUMMARY" ]; then
  echo "[session-index] Claude summarization failed — skipping" >&2
  exit 1
fi

# Delete existing entry if --force
if [ "$FORCE" = true ]; then
  python3 - "$INDEX" "$SESSION_STEM" <<'PYEOF'
import sys, re
from pathlib import Path
index_path = Path(sys.argv[1])
stem = sys.argv[2]
content = index_path.read_text()
pattern = rf'\n## {re.escape(stem)}\n.*?(?=\n## |\Z)'
content = re.sub(pattern, '', content, flags=re.DOTALL)
index_path.write_text(content)
PYEOF
fi

# Append entry
{
  echo ""
  echo "## $SESSION_STEM"
  echo "$SUMMARY"
} >> "$INDEX"

echo "[session-index] Entry written for $SESSION_STEM"
