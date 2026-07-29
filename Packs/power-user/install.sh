#!/usr/bin/env bash
# Power User Pack — installer
# Usage: bash install.sh [VAULT_ROOT] [skill ...]
#
#   bash install.sh .                     install all six
#   bash install.sh . handoff continue    install only those two
#
# If VAULT_ROOT is not provided, uses the current directory.

set -e

PACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VAULT_ROOT="${1:-$(pwd)}"
shift || true

ALL_SKILLS="handoff continue eod log kb-audit stein-doctor"
SKILLS="${*:-$ALL_SKILLS}"

echo ""
echo "Power User Pack — Install"
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
for s in $SKILLS; do
  if [ ! -d "$PACK_DIR/.claude/skills/$s" ]; then
    echo "  ERR   '$s' is not in this pack (available: $ALL_SKILLS)"
    continue
  fi
  copy_if_missing "$PACK_DIR/.claude/skills/$s" "$VAULT_ROOT/.claude/skills/$s"
done

# /handoff and /continue reference each other — one without the other is a
# dead end. Warn rather than silently installing half a feature.
case " $SKILLS " in
  *" handoff "*) case " $SKILLS " in *" continue "*) ;; *)
    echo "  WARN  /handoff installed without /continue — nothing can resume its save points" ;; esac ;;
esac
case " $SKILLS " in
  *" continue "*) case " $SKILLS " in *" handoff "*) ;; *)
    echo "  WARN  /continue installed without /handoff — there will be nothing to resume from" ;; esac ;;
esac

# --- Brain: Handoffs folder (only if /handoff went in) ---
case " $SKILLS " in
  *" handoff "*)
    echo ""
    echo "Brain — Handoffs:"
    if [ -d "$VAULT_ROOT/Brain/Handoffs" ]; then
      echo "  SKIP  Brain/Handoffs (already exists)"
      skipped=$((skipped+1))
    else
      mkdir -p "$VAULT_ROOT/Brain/Handoffs"
      echo "  ADD   Brain/Handoffs/"
      added=$((added+1))
    fi
    ;;
esac

# --- Summary ---
echo ""
echo "Done. $added added, $skipped skipped."
echo ""
echo "Next steps:"
echo ""
echo "  1. Add the installed commands to System/Docs/your-commands.md —"
echo "     the base doc covers the base ten only, so these are invisible until you do."
echo ""
echo "  2. Walk the client through whichever ones they asked for. Do not"
echo "     introduce all six at once — that is why they are not in the base layer."
