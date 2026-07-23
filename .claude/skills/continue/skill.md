---
name: continue
description: Resumes a handoff from a previous session. Type /continue in a new session to pick up exactly where the last one left off. Type /continue [description] to resume a specific older handoff. Works with handoff files written by /handoff.
user-invocable: true
allowed-tools:
  - Read
  - Bash
---

# /continue — Resume a Handoff

Loads the pickup brief from a /handoff and resumes work in this fresh session.

---

## Instructions

### Step 1 — Find the handoff to load

**No argument (`/continue`):**
Read `Brain/Handoffs/handoff-current.md` to get the filename of the most recent handoff.
Load `Brain/Handoffs/[that filename]`.

**With description (`/continue [description]`):**
Search handoff files for the best match:
```bash
grep -rl "[description keywords]" Brain/Handoffs/ | grep -v handoff-current.md | sort -r | head -5
```
Read the top matches. Pick the one that best fits. If ambiguous, show the client the options (date + project + one-line summary) and ask which one.

**If no handoff files exist:**
```
No handoff found. Nothing to continue — start fresh or describe what you were working on.
```

### Step 2 — Load the handoff

Read the handoff file fully. Present it cleanly:

```
Resuming handoff from [date]
Project: [project]

What we were building:
[What We're Building section]

Stopped at:
[Where We Stopped section]

Next step:
[Immediate Next Step section]
```

Then: "Ready to continue. Should I start with [Immediate Next Step]?"

### Step 3 — Resume

If the client confirms: execute the next step immediately.

Load files from "Files Touched This Session" as needed — don't load all upfront, just what's relevant to the next step.

Check freshness:
- Handoff written today or yesterday: assume current, proceed
- Handoff older than 2 days: warn once — "This handoff is from [date] — things may have changed. Want me to check current state first?" — then proceed on their answer.

### Step 4 — Update session context

After loading the handoff, note the continuation in today's session file Context section:
```
- [HANDOFF] Continuing from [date] handoff — [project], picking up at [Immediate Next Step]
```

Do not mark the handoff resolved yet — that happens when /wrap runs.

---

## Notes
- The handoff file is source of truth for what was in progress; the session log is the full record
- If the work described was already completed (the client finished it and forgot), say so and ask what's actually next
- `/wrap` marks the handoff resolved when the project is properly closed out
