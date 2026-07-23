#!/usr/bin/env bash
# Digital Product Pack — installer
# Usage: bash install.sh [VAULT_ROOT]
# If VAULT_ROOT is not provided, uses the current directory.

set -e

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="${1:-$(pwd)}"

echo ""
echo "Digital Product Pack — Install"
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

# --- Skills ---
echo "Skills:"
for skill_dir in "$PACK_DIR/.claude/skills"/*/; do
  skill_name="$(basename "$skill_dir")"
  copy_if_missing "$skill_dir" "$VAULT_ROOT/.claude/skills/$skill_name"
done

# --- Brain: Funnels ---
echo ""
echo "Brain — Funnels:"
copy_if_missing "$PACK_DIR/Brain/Funnels/_template.md" "$VAULT_ROOT/Brain/Funnels/_template.md"
copy_if_missing "$PACK_DIR/Brain/Funnels/README.md"    "$VAULT_ROOT/Brain/Funnels/README.md"

# --- Brain: Validations ---
echo ""
echo "Brain — Validations:"
copy_if_missing "$PACK_DIR/Brain/Validations/README.md" "$VAULT_ROOT/Brain/Validations/README.md"

# --- Brain: content/voice-dna.md ---
echo ""
echo "Brain — Voice:"
copy_if_missing "$PACK_DIR/Brain/content/voice-dna.md" "$VAULT_ROOT/Brain/content/voice-dna.md"

# --- Summary ---
echo ""
echo "Done. $added added, $skipped skipped (already existed)."
echo ""
if [ "$added" -gt 0 ]; then
  echo "Next steps:"
  echo "  1. Run /voice-build to create the client's voice profile"
  echo "  2. Run /validate before building any new product"
  echo "  3. Run /funnel-map when ready to map a sales funnel"
  echo "     (Funnel Builder requires Stripe + email keys in ~/.secrets)"
fi
