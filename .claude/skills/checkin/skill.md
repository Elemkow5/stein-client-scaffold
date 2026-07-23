---
name: checkin
description: Check-in session — daily, weekly, or quarterly. AI asks which at the start, then runs the right flow. Use at the start of a day, start of a week, or beginning of a new quarter.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /checkin — Daily, Weekly, or Quarterly Check-in

One entry point for all check-ins. AI asks which mode, then runs the right flow.

---

## Step 0 — Ask Which Mode

"Check-in — daily, weekly, or quarterly?"

Wait for answer. Accept: "daily" / "d", "weekly" / "w", "quarterly" / "q".

---

## Daily Mode

*Purpose: set clear priorities for today so the session has direction.*

### D1 — Read Context
Silently read:
- `Personality/Priorities.yaml` — active priorities
- `Brain/Master.md` — what's open, overdue, and flagged for this week
- Most recent session log in `Brain/Session_Logs/` — what was left open

### D2 — Calendar Check
If Google or Microsoft integration is configured in `System/integrations.yaml`, pull today's calendar events via MCP. List what's scheduled.

If not connected: skip silently.

### D3 — Surface What Matters Today
Present a clean brief:

```
Today — [DAY], [DATE]

Meetings: [list or "None"]

Carried over from yesterday:
- [items flagged as Today that weren't completed]

This week's open tasks:
- [top 3-5 from Brain/Master.md ## This Week]

Top priority today (from Priorities.yaml):
- [P0 priority current focus]
```

### D4 — Set Today's Focus
Ask: "What's the one thing that would make today a success?"

Add their answer as a `## Today` section in `Brain/Master.md` if one doesn't already exist, with today's date as the header.

### D5 — Inbox Check
Ask: "Anything new to capture before we start?" If yes, run /capture inline. If no, proceed.

---

## Weekly Mode

*Purpose: review last week, set direction for the next 7 days, check goal progress.*

### W1 — Read Context
Silently read:
- `Personality/Priorities.yaml`
- `Brain/Master.md`
- Last 5 session logs in `Brain/Session_Logs/`
- `Goals/` — all active goal files

### W2 — Last Week Review
Ask: "How was last week? What got done, what got skipped, and why?"

Listen. Reflect back what you hear about patterns — what's moving, what's stuck.

### W2b — Commitments Audit
Read `Brain/Commitments.md`. For each row with status `open`:
- If the due date has passed: ask "Did you deliver on [what] for [who]?" Mark `kept` or `missed` based on the answer.
- If the due date is this coming week: just surface it — no status change yet, just visibility.

Report a clean summary: kept vs. missed vs. still open, and update the row status in `Brain/Commitments.md` accordingly. If a pattern emerges (e.g. consistently missing commitments to one person, or commitments in general), name it — same honesty standard as goal and priority review.

### W3 — Goal Progress Check
For each active goal in `Goals/`, check whether any milestones had deadlines this week. Surface any that were due and ask for a status update. Update the goal file with their answer.

### W4 — Set This Week's Priorities
Ask: "What are your top 3 priorities for this week?"

Write them to `Brain/Master.md` under `## This Week`, clearing or archiving last week's items first:
```
## This Week — [DATE RANGE]
### Priority 1: [what they said]
### Priority 2:
### Priority 3:
```

### W5 — Block the Week
If calendar integration is active, ask: "Want to block time for your top priorities?" For each priority they say yes to, create a calendar event via MCP.

### W6 — Close
Summarize: top 3 for the week, any goal milestones due, one honest observation about momentum.

---

## Quarterly Mode

*Purpose: step back, assess progress against annual goals, reset priorities for the next 90 days.*

### Q1 — Read Context
Silently read:
- `Goals/Annual.md` and `Goals/Quarterly.md`
- `Personality/Priorities.yaml`
- `Goals/` — all goal files
- `Brain/Master.md`

### Q2 — Last Quarter Reflection
Ask three questions, one at a time:
1. "What did you actually accomplish this quarter — be honest and specific."
2. "What didn't happen that you expected to? What got in the way?"
3. "What surprised you — good or bad?"

Listen fully before moving on.

### Q3 — Goal Audit
For each active goal in `Goals/`: were milestones hit? Are deadlines still realistic? Ask the client to rate each goal: on track / at risk / stalled. Update goal files accordingly. Stalled goals get a decision: reset, pause, or drop.

### Q4 — Priorities Check
Read `Personality/Priorities.yaml` aloud. Ask: "Do these still reflect your actual priorities? Anything to add, drop, or reorder?" Update the file with any changes.

### Q5 — Set Next Quarter's Focus
Ask: "What are the 3 outcomes that would make next quarter a success?"

Write to `Goals/Quarterly.md`:
```markdown
# Q[N] [YEAR] — Quarterly Goals
**Quarter:** [dates]
**Set:** [today's date]

## Top 3 Outcomes
1. [Outcome 1]
2. [Outcome 2]
3. [Outcome 3]

## Key Milestones
[pull from active goal files]
```

### Q6 — Close
Summarize the quarter ahead: 3 outcomes, key milestones, one honest observation about what has to be different this quarter vs. last.
