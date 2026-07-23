#!/usr/bin/env bash
# Competitor Intelligence Pack — installer
# Usage: bash install.sh [VAULT_ROOT]
# If VAULT_ROOT is not provided, uses the current directory.

set -e

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="${1:-$(pwd)}"

echo ""
echo "Competitor Intelligence Pack — Install"
echo "Pack:  $PACK_DIR"
echo "Vault: $VAULT_ROOT"
echo ""

added=0
skipped=0

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ]; then
    echo "  SKIP  $dest (already exists)"
    ((skipped++)) || true
  else
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
    echo "  ADD   $dest"
    ((added++)) || true
  fi
}

# --- Skill ---
echo "Skills:"
copy_if_missing "$PACK_DIR/.claude/skills/competitor" "$VAULT_ROOT/.claude/skills/competitor"

# --- Brain: Intelligence structure ---
echo ""
echo "Brain — Intelligence:"
copy_if_missing "$PACK_DIR/Brain/Intelligence/Competitors/INDEX.md" \
  "$VAULT_ROOT/Brain/Intelligence/Competitors/INDEX.md"
copy_if_missing "$PACK_DIR/Brain/Intelligence/Competitors/_template" \
  "$VAULT_ROOT/Brain/Intelligence/Competitors/_template"
copy_if_missing "$PACK_DIR/Brain/Intelligence/Weekly/_placeholder.md" \
  "$VAULT_ROOT/Brain/Intelligence/Weekly/_placeholder.md"

# --- System: Setup guides ---
echo ""
echo "System — Setup Guides:"
copy_if_missing "$PACK_DIR/System/Setup/fb-ad-library-setup.md" \
  "$VAULT_ROOT/System/Setup/fb-ad-library-setup.md"
copy_if_missing "$PACK_DIR/System/Setup/youtube-api-setup.md" \
  "$VAULT_ROOT/System/Setup/youtube-api-setup.md"

# --- ~/.secrets: add placeholders if not present ---
echo ""
echo "Secrets:"
SECRETS_FILE="$HOME/.secrets"
touch "$SECRETS_FILE"
chmod 600 "$SECRETS_FILE"

add_secret_if_missing() {
  local key="$1"
  local placeholder="$2"
  if grep -q "^$key" "$SECRETS_FILE" 2>/dev/null; then
    echo "  SKIP  $key (already in ~/.secrets)"
  else
    echo "$key=\"$placeholder\"" >> "$SECRETS_FILE"
    echo "  ADD   $key placeholder → ~/.secrets"
  fi
}

add_secret_if_missing "FB_AD_LIBRARY_TOKEN" "CONFIGURE_ME"
add_secret_if_missing "YOUTUBE_API_KEY" "CONFIGURE_ME"
add_secret_if_missing "APIFY_API_TOKEN" "CONFIGURE_ME"

# --- Scheduled_Flows.md: add row if not present ---
echo ""
echo "Scheduled Flows:"
FLOWS_FILE="$VAULT_ROOT/System/Scheduled_Flows.md"
if [ -f "$FLOWS_FILE" ]; then
  if grep -q "Competitor Intel" "$FLOWS_FILE" 2>/dev/null; then
    echo "  SKIP  Competitor Intel row already in Scheduled_Flows.md"
    ((skipped++)) || true
  else
    # Append row to the Active Flows table
    python3 -c "
import re, pathlib
p = pathlib.Path('$FLOWS_FILE')
content = p.read_text()
new_row = '| Competitor Intel | Bi-weekly Mon 6:30 AM | Runs /competitor for all active competitors, saves weekly digest to Intelligence/Weekly/ | — | ⬜ not yet scheduled |'
# Insert before the end of the table (first blank line after the table header)
content = content.replace(
    '| Daily Digest |',
    new_row + '\n| Daily Digest |'
)
p.write_text(content)
print('  ADD   Competitor Intel row → Scheduled_Flows.md')
" 2>/dev/null || echo "  NOTE  Could not auto-add row — add manually to System/Scheduled_Flows.md"
  fi
else
  echo "  SKIP  System/Scheduled_Flows.md not found — add competitor-intel row manually"
fi

# --- Summary ---
echo ""
echo "Done. $added added, $skipped skipped."
echo ""
echo "Next steps:"
echo ""
echo "  1. Configure API keys (free, required for full capability):"
echo "     FB Ad Library → $VAULT_ROOT/System/Setup/fb-ad-library-setup.md"
echo "     YouTube API   → $VAULT_ROOT/System/Setup/youtube-api-setup.md"
echo "     Apify         → get token at apify.com → add to ~/.secrets as APIFY_API_TOKEN"
echo ""
echo "  2. Add your first competitor to Intelligence/Competitors/INDEX.md"
echo "     Copy the config block template and fill in name, URL, tracked people"
echo "     Create their folder: mkdir -p Intelligence/Competitors/[Folder-Name]/People"
echo "     Copy templates: cp -r Intelligence/Competitors/_template/* Intelligence/Competitors/[Folder-Name]/"
echo ""
echo "  3. Run the initial profile build:"
echo "     /competitor --profile [Name]"
echo ""
echo "  4. Schedule bi-weekly scans via /schedule"
echo "     (or run /competitor manually each time)"
