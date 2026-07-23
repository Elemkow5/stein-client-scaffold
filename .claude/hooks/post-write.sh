#!/bin/bash
# PostToolUse:Write hook — wikilink check.
# After any file write, warns if a vault .md has no [[wikilinks]].

INPUT=$(cat)
FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

# Only check .md files
if [[ -z "$FILE" || "$FILE" != *.md ]]; then
  exit 0
fi

# Skip template files — they're intentionally sparse
if [[ "$(basename "$FILE")" == _template* ]]; then
  exit 0
fi

# Skip published content paths (post bodies, drafts) — wikilinks in post copy
# will appear as raw text when published. Only link in vault files.
if [[ "$FILE" == */Content/Drafts/* || "$FILE" == */Content/Ready/* ]]; then
  exit 0
fi

if ! grep -q '\[\[' "$FILE" 2>/dev/null; then
  BASENAME=$(basename "$FILE")
  echo "{\"hookSpecificOutput\": {\"hookEventName\": \"PostToolUse\", \"additionalContext\": \"WIKILINK CHECK: No [[wikilinks]] found in $BASENAME — add [[Topic]] links if this file references named projects, people, or frameworks.\"}}"
fi
