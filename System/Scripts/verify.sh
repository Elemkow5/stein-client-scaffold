#!/bin/bash
# verify.sh — does a fresh clone of this repo actually work?
#
# WHY THIS EXISTS
# On 2026-07-27 a commit removed Brain/, Personality/ and Goals/ from the repo
# to keep client data out of it. Correct goal — but those folders held the BLANK
# TEMPLATES, not data. For two days every fresh clone was undeployable: 57 paths
# referenced by skills, hooks, agents and docs pointed at nothing. Nobody found
# out, because nothing checked.
#
# This script is what checks. Run it before every push, to either repo.
#
# Usage: bash System/Scripts/verify.sh
# Exit 0 = safe to push. Exit 1 = something is broken; do not push.

set -uo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'
BOLD='\033[1m'; RESET='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

FAILED=0
WARNED=0
fail() { echo -e "  ${RED}✗${RESET} $1"; FAILED=$((FAILED+1)); }
warn() { echo -e "  ${YELLOW}⚠${RESET} $1"; WARNED=$((WARNED+1)); }
pass() { echo -e "  ${GREEN}✓${RESET} $1"; }
head_() { echo -e "\n${BOLD}$1${RESET}"; }

echo -e "\n${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo -e "${BOLD}  Scaffold Verification${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
echo "  $ROOT"

# ── 1. The skeleton is tracked ───────────────────────────────────────────────
head_ "1. Vault skeleton is in the repo"

if [ ! -d "$ROOT/_skeleton" ]; then
  fail "_skeleton/ is missing — a fresh clone would have no vault at all"
else
  SKEL_COUNT=$(find "$ROOT/_skeleton" -type f ! -name '.DS_Store' | wc -l | tr -d ' ')
  if [ "$SKEL_COUNT" -lt 25 ]; then
    fail "_skeleton/ has only $SKEL_COUNT files — expected ~32. Templates may have been deleted."
  else
    pass "_skeleton/ has $SKEL_COUNT template files"
  fi

  for must in \
    "Brain/Master.md" "Brain/Inbox.md" "Brain/Commitments.md" \
    "Brain/Topics/_template.md" "Brain/Topics/INDEX.md" "Brain/People/_template.md" \
    "Brain/Session_Logs/INDEX.md" "Brain/System/Scripts/layer2-audit.py" \
    "Personality/Working_Preferences.md" "Personality/Mistake_Patterns.md" \
    "Personality/Priorities.yaml" "Goals/Annual.md" "System/integrations.yaml"
  do
    [ -f "$ROOT/_skeleton/$must" ] || fail "_skeleton/$must missing"
  done

  # Every tracked skeleton file must be visible to git, or a clone won't get it.
  if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
    UNTRACKED=$(git -C "$ROOT" ls-files --others --ignored --exclude-standard -- _skeleton | head -5)
    if [ -n "$UNTRACKED" ]; then
      fail "_skeleton/ files are being gitignored — a clone won't receive them:"
      echo "$UNTRACKED" | sed 's/^/      /'
    else
      pass "_skeleton/ is not caught by .gitignore"
    fi
  fi
fi

# ── 2. The live vault is NOT tracked ─────────────────────────────────────────
head_ "2. Client data stays out of the repo"

if git -C "$ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  LEAKED=$(git -C "$ROOT" ls-files -- Brain Personality Goals System/integrations.yaml 2>/dev/null | head -5)
  if [ -n "$LEAKED" ]; then
    fail "live vault files are tracked — client data could be committed:"
    echo "$LEAKED" | sed 's/^/      /'
  else
    pass "Brain/, Personality/, Goals/ are untracked"
  fi
fi

# ── 3. Every referenced path resolves ────────────────────────────────────────
head_ "3. Referenced paths resolve"

# Paths created at runtime by the client's own use — legitimately absent.
RUNTIME_OK='^(Brain/(Session_Logs/[0-9]|Daily/|Business\.md|seed-report\.md|Handoffs/|Plans/[0-9]|Intelligence/|Funnels/|Validations/|content/|Comms/[A-Z]|People/_(candidates|commitment_candidates)\.md|System/layer2-audit-log)|System/(Logs|\.setup_progress|Health_Reports/[0-9]|layer2-audit-log)|Dashboards/data)'

TMPREF=$(mktemp)
grep -rhoE '\b(Brain|Personality|Goals|System|Dashboards)/[A-Za-z0-9_./-]+' \
  "$ROOT/.claude/skills" "$ROOT/.claude/CLAUDE.md" "$ROOT/.claude/hooks" \
  "$ROOT/System" "$ROOT/Dashboards/server.js" \
  "$ROOT/README.md" "$ROOT/Deployment_Checklist.md" 2>/dev/null \
  | sed 's/[.,)`:*]*$//' | sort -u > "$TMPREF"

MISSING=0
while read -r ref; do
  [ -z "$ref" ] && continue
  case "$ref" in *'['*|*']'*|*'YYYY'*|*'filename'*|*'foo'*) continue ;; esac
  echo "$ref" | grep -qE "$RUNTIME_OK" && continue
  # Satisfied by either the live vault or the tracked template.
  [ -e "$ROOT/$ref" ] && continue
  [ -e "$ROOT/_skeleton/$ref" ] && continue
  fail "referenced but missing: $ref"
  MISSING=$((MISSING+1))
done < "$TMPREF"
rm -f "$TMPREF"
[ "$MISSING" -eq 0 ] && pass "every referenced path exists or is runtime-created"

# ── 4. Scripts referenced actually exist ─────────────────────────────────────
head_ "4. Scripts and hooks exist"

for s in install-skeleton.sh setup.sh start-dashboard-server.sh inbox-watcher.js \
         recall-search.sh write-session-index.sh verify.sh; do
  [ -f "$ROOT/System/Scripts/$s" ] || fail "System/Scripts/$s missing"
done

if [ -f "$ROOT/.claude/settings.json" ]; then
  python3 - "$ROOT" <<'PY' || FAILED=$((FAILED+1))
import json, os, sys, re
root = sys.argv[1]
cfg = json.load(open(os.path.join(root, ".claude/settings.json")))
bad = []
for ev, groups in cfg.get("hooks", {}).items():
    for g in groups:
        for h in g.get("hooks", []):
            cmd = h.get("command", "")
            m = re.search(r'(\.claude/hooks/[\w.-]+)', cmd)
            if m and not os.path.exists(os.path.join(root, m.group(1))):
                bad.append(f"{ev}: {m.group(1)}")
if bad:
    print("  \033[0;31m✗\033[0m settings.json points at missing hooks:")
    for b in bad: print("      " + b)
    sys.exit(1)
print("  \033[0;32m✓\033[0m every hook in settings.json exists")
PY
else
  fail ".claude/settings.json missing — is the submodule initialised?"
fi

# ── 5. session-start is on the right event ───────────────────────────────────
head_ "5. Hook events are correct"

if [ -f "$ROOT/.claude/settings.json" ]; then
  if python3 -c "
import json,sys
c=json.load(open('$ROOT/.claude/settings.json'))
ups=[h['command'] for g in c['hooks'].get('UserPromptSubmit',[]) for h in g['hooks']]
sys.exit(0 if any('session-start' in x for x in ups) else 1)" 2>/dev/null; then
    fail "session-start.sh is on UserPromptSubmit — it must be SessionStart, or it re-runs on every message"
  else
    pass "session-start.sh is not on UserPromptSubmit"
  fi
fi

# ── 6. Shell + Python + YAML + JS all parse ──────────────────────────────────
head_ "6. Everything parses"

SYNTAX_BAD=0
while IFS= read -r f; do
  bash -n "$f" 2>/dev/null || { fail "bash syntax error: ${f#$ROOT/}"; SYNTAX_BAD=1; }
done < <(find "$ROOT" -name '*.sh' -not -path '*/.git/*' 2>/dev/null)

while IFS= read -r f; do
  python3 -m py_compile "$f" 2>/dev/null || { fail "python syntax error: ${f#$ROOT/}"; SYNTAX_BAD=1; }
done < <(find "$ROOT" -name '*.py' -not -path '*/.git/*' 2>/dev/null)

if command -v node >/dev/null 2>&1; then
  while IFS= read -r f; do
    node --check "$f" 2>/dev/null || { fail "js syntax error: ${f#$ROOT/}"; SYNTAX_BAD=1; }
  done < <(find "$ROOT" -name '*.js' -o -name '*.cjs' | grep -v '/.git/' 2>/dev/null)
fi

if python3 -c "import yaml" 2>/dev/null; then
  for y in "$ROOT/_skeleton/System/integrations.yaml"; do
    [ -f "$y" ] || continue
    python3 -c "
import yaml,sys
d=yaml.safe_load(open('$y'))
need={'platform','services','comms_hub','inbox_folder','digest','stack'}
missing=need-set(d)
sys.exit(1 if missing else 0)" 2>/dev/null \
      || { fail "integrations.yaml is missing required top-level keys — /setup and 11 consumers disagree"; SYNTAX_BAD=1; }
  done
else
  warn "PyYAML not installed — skipped integrations.yaml schema check (pip3 install pyyaml)"
fi

[ "$SYNTAX_BAD" -eq 0 ] && pass "shell, python, js and yaml all parse"

# ── 7. Skills are well-formed ────────────────────────────────────────────────
head_ "7. Skills are well-formed"

SKILL_BAD=0
for d in "$ROOT/.claude/skills"/*/; do
  [ -d "$d" ] || continue
  n=$(basename "$d")
  f=""
  [ -f "$d/skill.md" ] && f="$d/skill.md"
  [ -f "$d/SKILL.md" ] && f="$d/SKILL.md"
  if [ -z "$f" ]; then fail "skill '$n' has no skill.md"; SKILL_BAD=1; continue; fi
  [ "$(head -1 "$f")" = "---" ] || { fail "skill '$n' has no frontmatter"; SKILL_BAD=1; }
  grep -q '^description:' "$f" || { fail "skill '$n' has no description"; SKILL_BAD=1; }
done

# Literal MCP server names can never match a real (UUID) server id.
LITERAL=$(grep -rhoE 'mcp__(google_calendar|google_drive|gmail|microsoft_365|slack)__[a-z_]+' \
          "$ROOT/.claude/skills" 2>/dev/null | sort -u)
if [ -n "$LITERAL" ]; then
  fail "skills reference literal MCP server names (real ids are UUIDs — use mcp__*__):"
  echo "$LITERAL" | sed 's/^/      /'
  SKILL_BAD=1
fi
[ "$SKILL_BAD" -eq 0 ] && pass "all skills have frontmatter and portable tool names"

# ── 7b. No references to retired skills ──────────────────────────────────────
head_ "7b. No references to retired commands"

# /checkin replaced /daily, /weekly and /quarterly. A doc or skill still telling
# the client to run a command that no longer exists is the exact drift that made
# the original mess: one layer changed, the rest kept pointing at the old thing.
python3 - "$ROOT" <<'PY' || FAILED=$((FAILED+1))
import os, re, sys
root = sys.argv[1]
retired = ["daily", "weekly", "quarterly", "planning"]
live = {d for d in os.listdir(os.path.join(root, ".claude/skills"))
        if os.path.isdir(os.path.join(root, ".claude/skills", d))}
targets = []
for rel in [".claude/skills", ".claude/CLAUDE.md", "System/Docs", "System/Setup",
            "System/Agents", "README.md", "Deployment_Checklist.md"]:
    p = os.path.join(root, rel)
    if os.path.isfile(p): targets.append(p)
    for dp, _, fns in os.walk(p):
        targets += [os.path.join(dp, f) for f in fns if f.endswith(".md")]

bad = []
for cmd in retired:
    if cmd in live:            # still a real skill — not retired
        continue
    # A slash COMMAND: /cmd not preceded by a path or word char, not followed by
    # one. Excludes Agents/weekly-health-report.md and Brain/Daily/.
    pat = re.compile(r'(?<![\w/-])/' + cmd + r'(?![\w/-])')
    for f in set(targets):
        try: txt = open(f, encoding="utf-8").read()
        except Exception: continue
        for i, line in enumerate(txt.split("\n"), 1):
            if pat.search(line):
                bad.append((cmd, os.path.relpath(f, root), i, line.strip()[:100]))

if bad:
    print("  \033[0;31m✗\033[0m references to retired commands (/checkin replaced these):")
    for cmd, f, i, line in bad[:10]:
        print(f"      /{cmd} — {f}:{i}")
        print(f"        {line}")
    sys.exit(1)
print("  \033[0;32m✓\033[0m no references to retired commands")
PY

# ── 8. A fresh deploy produces a working vault ───────────────────────────────
head_ "8. Dry-run deploy into a temp folder"

TMPV=$(mktemp -d)
if bash "$ROOT/System/Scripts/install-skeleton.sh" "$TMPV" >/dev/null 2>&1; then
  DRY_BAD=0
  for must in Brain/Master.md Brain/Inbox.md Personality/Working_Preferences.md \
              Goals/Annual.md System/integrations.yaml Brain/System/Scripts/layer2-audit.py; do
    [ -f "$TMPV/$must" ] || { fail "dry run did not produce $must"; DRY_BAD=1; }
  done
  [ -x "$TMPV/Brain/System/Scripts/layer2-audit.py" ] || warn "layer2-audit.py is not executable after install"
  [ "$DRY_BAD" -eq 0 ] && pass "a fresh deploy produces a populated vault"
else
  fail "install-skeleton.sh failed to run"
fi
rm -rf "$TMPV"

# ── Verdict ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
if [ "$FAILED" -gt 0 ]; then
  echo -e "${RED}${BOLD}  $FAILED problem(s) found — DO NOT PUSH${RESET}"
  [ "$WARNED" -gt 0 ] && echo -e "  ${YELLOW}$WARNED warning(s)${RESET}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
  exit 1
fi
echo -e "${GREEN}${BOLD}  All checks passed — safe to push.${RESET}"
[ "$WARNED" -gt 0 ] && echo -e "  ${YELLOW}$WARNED warning(s) — worth a look, not blocking${RESET}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}\n"
exit 0
