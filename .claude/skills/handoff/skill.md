---
name: handoff
description: Mid-session context transfer — packages the current session's live state into a pickup brief for a fresh Claude window. Use when the session is getting long and you want to continue in a new window without losing where you are. Distinct from /wrap (project close-out) and session log (archive).
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash
---

# /handoff — Mid-Session Context Transfer

Writes a pickup brief so a fresh Claude instance can resume exactly where this one left off. Run when switching windows mid-work, not when done for the day (that's /wrap).

---

## Instructions

### Step 1 — Bring the session log current

Run `/log` before doing anything else. This ensures the handoff reflects everything that actually happened this session.

Once `/log` confirms the log is current, continue.

### Step 2 — Assess the session

Read the current session file:
```bash
find Brain/Session_Logs -name "*.md" | grep -v INDEX | sort | tail -1
```
Read it. Also scan the last 10–15 turns of conversation for what's active right now.

### Step 3 — Determine project and task

From session context, identify:
- **Project**: which project we're in the middle of
- **Task**: what specific thing we're building or doing
- **Stopping point**: the most recent thing completed, or last file touched
- **Next step**: the single most immediate next action

If any are unclear, ask the client — one direct question.

### Step 4 — Write the handoff file

Generate a timestamp:
```bash
date '+%Y-%m-%d-%Hh%M'
```

Write to `Brain/Handoffs/[TIMESTAMP]-handoff.md`:

```markdown
# Handoff — YYYY-MM-DD HH:MM
**Project:** [project name]
**Status:** active
**Session:** [Brain/Session_Logs/YYYY-MM-DD-HHhMM.md]

## What We're Building
[1-2 sentences. Specific enough that a new Claude reading only this can understand the task without full session context. Name the file, skill, or system being built.]

## Where We Stopped
[The last concrete thing completed — file written, decision made. Include the file path if relevant.]

## Immediate Next Step
[Single next action. Specific. Ideally names the file to read or write next.]

## Files Touched This Session
[Bullet list of key files created or modified — paths from vault root]

## Open Questions
[Anything unresolved or a decision still pending — or "None"]

## Context Notes
[Anything unusual — errors encountered, partial implementations, workarounds — or "None"]
```

### Step 5 — Update the current pointer

Write the handoff filename to `Brain/Handoffs/handoff-current.md`:
```
[TIMESTAMP]-handoff.md
```

This is what `/continue` reads by default.

### Step 6 — Confirm

Print:
```
Handoff written: [timestamp]
Project: [project]
Stopped at: [one-line summary]
Next step: [one-line immediate next step]

Start a new Claude session and type: /continue
```

---

## Notes
- Handoff files accumulate in `Brain/Handoffs/` — they're small, no cleanup needed
- `/continue [description]` in the new session will search by keyword if multiple handoffs exist
- `/wrap` marks the handoff resolved when the project is closed out
- If the client does a handoff but never opens a new session, the file just sits there — no harm done
