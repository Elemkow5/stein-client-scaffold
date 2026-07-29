#!/usr/bin/env bash
# Communications Hub Pack (Module 15) — installer
# Usage: bash install.sh [VAULT_ROOT]
# If VAULT_ROOT is not provided, uses the current directory.

set -e

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="${1:-$(pwd)}"

echo ""
echo "Communications Hub Pack — Install"
echo "Pack:  $PACK_DIR"
echo "Vault: $VAULT_ROOT"
echo ""

added=0
skipped=0

copy_if_missing() {
  local src="$1"
  local dest="$2"
  if [ -e "$dest" ]; then
    echo "  SKIP  ${dest#$VAULT_ROOT/} (already exists)"
    skipped=$((skipped+1))
  else
    mkdir -p "$(dirname "$dest")"
    cp -r "$src" "$dest"
    echo "  ADD   ${dest#$VAULT_ROOT/}"
    added=$((added+1))
  fi
}

# --- Skills ---
echo "Skills:"
for s in comms-triage comms-reply; do
  copy_if_missing "$PACK_DIR/.claude/skills/$s" "$VAULT_ROOT/.claude/skills/$s"
done

# --- Brain: Comms folder ---
echo ""
echo "Brain — Comms:"
if [ -d "$VAULT_ROOT/Brain/Comms" ]; then
  echo "  SKIP  Brain/Comms (already exists)"
  skipped=$((skipped+1))
else
  mkdir -p "$VAULT_ROOT/Brain/Comms"
  echo "  ADD   Brain/Comms/"
  added=$((added+1))
fi

# --- integrations.yaml: enable comms_hub ---
echo ""
echo "Config:"
CFG="$VAULT_ROOT/System/integrations.yaml"
if [ ! -f "$CFG" ]; then
  echo "  SKIP  System/integrations.yaml not found — run /setup first, then re-run this installer"
else
  python3 - "$CFG" <<'PY' || echo "  NOTE  Could not auto-enable comms_hub — set comms_hub.enabled: true manually"
import re, sys, pathlib
p = pathlib.Path(sys.argv[1])
txt = p.read_text()

# Flip only the `enabled:` line that belongs to the comms_hub block — the one
# at two-space indent immediately following `comms_hub:`. Channel-level
# `enabled:` keys sit deeper and are left alone: which channels are on is the
# operator's call, not the installer's.
m = re.search(r'^comms_hub:\s*$', txt, re.M)
if not m:
    print("  NOTE  no comms_hub block found — add it manually")
    sys.exit(0)

start = m.end()
block_end = re.search(r'^\S', txt[start:], re.M)
end = start + (block_end.start() if block_end else len(txt) - start)
block = txt[start:end]

new_block, n = re.subn(r'^(  enabled:)\s*false\s*$', r'\1 true', block, count=1, flags=re.M)
if n:
    p.write_text(txt[:start] + new_block + txt[end:])
    print("  EDIT  comms_hub.enabled: false -> true")
else:
    print("  SKIP  comms_hub already enabled")
PY
fi

# --- Summary ---
echo ""
echo "Done. $added added, $skipped skipped."
echo ""
echo "Next steps:"
echo ""
echo "  1. Turn on the channels the client actually uses, in System/integrations.yaml:"
echo "       comms_hub.channels.email.enabled: true      (minimum — required)"
echo "       comms_hub.channels.slack.enabled: true      (+ set mcp_server and channel_whitelist)"
echo "       comms_hub.channels.teams.enabled: true      (M365 platform only)"
echo "       comms_hub.channels.linkedin.enabled: true   (needs Apify + Make.com — see Deployment_Guide.md)"
echo ""
echo "  2. Run /comms-triage once with the client so they see the unified queue."
echo ""
echo "  3. Add /comms-triage and /comms-reply to System/Docs/your-commands.md"
echo "     so they show up in the client's command reference."
