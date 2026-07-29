#!/bin/bash
# install-skeleton.sh — put the blank vault forms into place.
#
# The repo tracks blank templates in _skeleton/. The live vault (Brain/,
# Personality/, Goals/) is gitignored so client data never enters the shared
# repo. This script bridges the two: it copies _skeleton/ into the vault root.
#
# NON-DESTRUCTIVE. A file that already exists is never touched. Safe to run
# any number of times — on deploy, after a pull, or as a repair.
#
# Usage: bash System/Scripts/install-skeleton.sh [VAULT_ROOT]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
VAULT_ROOT="${1:-$REPO_ROOT}"

# The skeleton always comes from where THIS SCRIPT lives, never from the target.
# Deriving it from VAULT_ROOT breaks the moment you install into a fresh folder,
# which is exactly what a first deploy does.
SKELETON="$REPO_ROOT/_skeleton"
[ -d "$SKELETON" ] || SKELETON="$VAULT_ROOT/_skeleton"

QUIET="${SKELETON_QUIET:-}"
say() { [ -n "$QUIET" ] || echo "$1"; }

if [ ! -d "$SKELETON" ]; then
  echo "install-skeleton: no _skeleton/ found at $SKELETON — nothing to install." >&2
  exit 1
fi

added=0
kept=0

# Walk every file in _skeleton/ and mirror it into the vault root.
while IFS= read -r src; do
  rel="${src#"$SKELETON"/}"
  dest="$VAULT_ROOT/$rel"

  if [ -e "$dest" ]; then
    kept=$((kept + 1))
    continue
  fi

  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  say "  + $rel"
  added=$((added + 1))
done < <(find "$SKELETON" -type f ! -name '.DS_Store')

# layer2-audit.py must be executable to run under launchd.
AUDIT="$VAULT_ROOT/Brain/System/Scripts/layer2-audit.py"
[ -f "$AUDIT" ] && chmod +x "$AUDIT"

if [ "$added" -gt 0 ]; then
  say "Skeleton installed — $added file(s) created, $kept left as-is."
else
  say "Skeleton already in place — $kept file(s) untouched."
fi
