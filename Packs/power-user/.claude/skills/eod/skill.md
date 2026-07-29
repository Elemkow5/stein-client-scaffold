---
name: eod
description: End-of-day review — compares what was planned against what got done, captures why anything slipped, runs Layer 2 audit. Use at the end of any workday.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
---

# /eod — End of Day Review

Closes the day honestly. What got done, what didn't, why, and where unfinished items go.

---

## Instructions

### Step 1 — Read Today's Plan

Read `Brain/Daily/YYYY-MM-DD.md` (today's date) and the **Today** section of `Brain/Master.md`.

Present the task list clearly:
```
Today's plan had [N] tasks:
- [ ] Task 1
- [ ] Task 2
```

### Step 2 — Mark Completions

Ask: "Walk me through these — what got done?"

Mark each:
- `[x]` — done
- `[-]` — skipped / dropped
- `[ ]` — not done, carrying forward

### Step 3 — The Slip

For each undone item, ask one question: "What happened with [task]?"
One line per item. Not a debrief — just the honest reason.

### Step 4 — Move Unfinished Items

For each undone item, decide where it goes:
- **Tomorrow** → add to Master.md under tomorrow's date
- **Later this week** → add to the appropriate day
- **Backlog** → move to Backlog section
- **Drop** → remove entirely

Update `Brain/Master.md` accordingly.

### Step 4.5 — Reconcile Commitments

Read `Brain/Commitments.md` and check each open commitment:
- Done but still listed as open → move to Completed with actual date
- Past due → renegotiate now (new date) or move to Missed with one-line explanation
- Missing due date → get a date before closing

### Step 5 — Append EOD to Daily File

Append to today's `Brain/Daily/YYYY-MM-DD.md`:

```markdown
---

## EOD Review

**Completed:** [N]/[total]
- [x] Task that got done

**Slipped:**
- [ ] Task — [reason] → moved to [destination]

**One honest observation:**
[Pattern, win, or thing worth noting — one sentence]
```

### Step 6 — Clear Today in Master.md

- Remove all `[x]` done items from Today
- Remove all dropped `[-]` items
- Move remaining `[ ]` items to their destinations
- Leave Today empty for tomorrow

### Step 6.5 — Layer 2 Audit

Run the nightly Layer 2 extraction:

```bash
python3 Brain/System/Scripts/layer2-audit.py
```

Wait for output. Surface results in one line:
- Extracts found: "Layer 2 audit: [N] item(s) written — [filenames]. Full log at Brain/System/layer2-audit-log.md."
- Nothing found: "Layer 2 audit: nothing qualified today."

### Step 7 — Close

One sentence: how the day actually went. Honest, not cheerleading.
Then: "Tomorrow's tasks are in the board. See you in the morning."

---

## Notes

- Clean sweep → acknowledge it directly. "Clean sweep." Don't inflate it.
- Almost nothing done → name it plainly. "What got in the way today?"
- Keep the whole review under 5 minutes. It's a close, not a therapy session.
