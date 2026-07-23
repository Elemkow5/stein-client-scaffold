---
name: commitment
description: Capture a promise made to another person — what, to whom, by when. Use right after a call or meeting where the client said they'd deliver something. Writes to the Commitments ledger, Master.md, and the person's file so it surfaces automatically before you next see them.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /commitment — Capture a Promise

Logs a commitment made to another person in the moment — right after the call or meeting where it was made, not at end of session. Same write logic `/wrap` Step 6 calls when the client makes a commitment there instead.

---

## Instructions

### Step 1 — What was committed

Ask: "What did you commit to?" Get the specific deliverable or outcome, in the client's own words. Push for specifics if vague — "I'll get back to them" isn't capturable; "send the revised proposal" is.

### Step 2 — Who it's owed to

Ask: "Who is this owed to?"

Match the name against `Brain/People/`. If a file exists, use it. If no file exists, offer to create one now using `Brain/People/_template.md` — same behavior `/daily` already uses when it meets a new meeting attendee. Fill in what's known (name, and role/company if mentioned); leave the rest blank.

### Step 3 — Due date

Ask: "By when?" Accept relative dates ("Friday", "end of month") or absolute ones. Normalize to `YYYY-MM-DD` before writing anywhere.

### Step 4 — Write to the ledger

Open `Brain/Commitments.md` (create from template if it doesn't exist yet — see `Brain/Commitments.md` structure below). Add one row:

```
| [today's date] | [Person Name] | [What] | [Due date] | open |
```

### Step 5 — Write to Master.md

Add to `Brain/Master.md` under the appropriate time bucket (This Week if due within 7 days, otherwise Backlog):

```
- [ ] [COMMITMENT: PersonName, YYYY-MM-DD] What
```

### Step 6 — Write to the person's file

Open `Brain/People/[PersonName].md`. If a `## Open Commitments` section doesn't exist, add it (place it after `## Open Items`). Append:

```
- [ ] [Due YYYY-MM-DD] What — made [today's date]
```

This is what lets `/daily` surface it automatically the next time this person is on the calendar.

### Step 7 — Confirm

One line: "Logged — you owe [Person] [what] by [date]. It'll surface when they're on your calendar or the date arrives."

---

## Notes

- This skill only ever creates rows with status `open`. Status changes to `kept` / `missed` / `renegotiated` happen during the weekly review, never here — keeps the ledger's audit trail trustworthy.
- If `/wrap` Step 6 is answered with a commitment, it calls this same Step 4–7 write sequence rather than duplicating it.
- Not for personal task deadlines — those go through normal `/capture` or `/wrap` next-steps. This is specifically for promises made *to someone else*.
