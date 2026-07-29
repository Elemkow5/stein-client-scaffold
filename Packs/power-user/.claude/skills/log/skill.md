---
name: log
description: Session log health check — scans for files modified since the session started that aren't mentioned in the session log, writes any missing entries autonomously. Use anytime during a session to catch the log up, or as a lightweight alternative to /wrap.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash
---

# /log — Session Log Health Check

Checks whether the current session file is current. Scans for files modified since the session started that aren't mentioned in the session log. Writes any missing entries autonomously. Confirms when done.

Does not show a gap report. Does not ask for confirmation. Just fixes it and says "Session log is current."

---

## When to Use

- Any time during a session to catch the log up
- Before context compaction if you sense it's coming
- As a lightweight alternative to /wrap when you just want to confirm the log is current

Not a replacement for `/wrap`. `/wrap` is a full session close — commitment checks, Master.md sync, learning-loop review. `/log` is purely "is this session file current right now?"

---

## Instructions

### Step 1 — Find the Current Session File

```bash
find "Brain/Session_Logs" -name "*.md" | sort | tail -1
```

Read the file in full. Note:
- What's already logged
- The session start time (from the filename, if timestamped)

### Step 2 — Find Modified Files Since Session Start

```bash
find "Brain/Projects" "Brain/People" "Brain/Knowledge" "Brain/Decisions" \
     ".claude/skills" "Goals" "Dashboards" \
     -name "*.md" -o -name "*.html" -o -name "*.py" -o -name "*.json" \
     2>/dev/null | xargs ls -lt 2>/dev/null | head -40
```

**Focus on:**
- New or modified project files in `Brain/Projects/`
- New or updated People files in `Brain/People/`
- New entries in `Brain/Knowledge/` or `Brain/Decisions/`
- New skills in `.claude/skills/`
- New or updated Goals files

**Exclude:**
- The session file itself
- `Brain/Memory/` index files
- `Brain/Master.md` (too frequently touched to be meaningful on its own — but do check whether a Commitments-related change there is otherwise unlogged)
- `Brain/Commitments.md` (same — check for unlogged commitment activity, don't log every row edit)
- `Brain/Inbox.md`
- Temporary files

### Step 3 — Cross-Reference Against the Session Log

For each modified file, check: is it mentioned by name or by description in the session log?

A file counts as "logged" if its filename/path appears, or an entry clearly describes the work that produced it.

### Step 4 — Write Missing Entries

For each unlogged item, write a session log entry:

```
**[HH:MM]** Brief description of what happened and why it mattered. Include the file path if relevant. If it was a decision, include the reasoning.
```

Append to the session log. Quality bar: someone reading cold, with no access to the conversation, should understand what happened and why it mattered. Not "updated file" — the actual substance.

### Step 5 — Check for Unlogged Commitments

If `Brain/Commitments.md` has a row with a `Date Made` matching today, and the session log has no mention of a commitment being made, add an entry — this is a common gap since commitments are often made verbally mid-conversation and only captured via `/commitment` or `/wrap` afterward.

### Step 6 — Confirm

Output exactly one line:

```
Session log is current.
```

Nothing else.

---

## What NOT to Do

- Don't show the gap list before writing — just write
- Don't ask "should I log this?" — just log it
- Don't write thin entries ("worked on project") — write substance
- Don't log every minor file touch — use judgment
- Don't touch the session file structure — only append
- Don't run if there's no session file — say "No session file found. Create one first."

---

## Relationship to Other Skills

- `/wrap` — full session close: commitment checks, Master.md sync, learning-loop review. Run at session end.
- `/log` — session log health check only. Lighter, faster, can run anytime.
- `/checkin` (daily mode) — morning planning. Creates the day's session context.

The recommended pattern: `/log` throughout the session to keep things current, `/wrap` at the end.
