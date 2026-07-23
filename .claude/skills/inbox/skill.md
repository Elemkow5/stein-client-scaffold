---
name: inbox
description: Process Brain/Inbox.md one item at a time — decide where each thing goes. Lighter than /planning — just clears the queue. Use when the client wants to work the inbox without a full planning session.
user-invocable: true
allowed-tools:
  - Read
  - Edit
  - Write
---

# /inbox — Triage the Inbox

Work through `Brain/Inbox.md` one item at a time. For each item: decide where it goes.

---

## Instructions

### Step 1 — Load Inbox

Read `Brain/Inbox.md`. Collect all unchecked items (`- [ ]`).

If empty: "Inbox is empty." Done.

### Step 2 — Auto-Split Dictated Lists

If a single captured item contains multiple `-`-prefixed sub-items (e.g. a voice capture that came through as one blob), split into separate `- [ ]` entries before triage — one per sub-item, same timestamp. Replace in place, then triage each separately.

### Step 3 — Present Item + Options

Show the item text (strip `- [ ]` prefix and timestamp), then:

> **[1 of N]** "Call dentist to reschedule"
> 1. Today  2. This Week  3. This Month  4. Backlog  5. Someday  6. Ideas  7. Skip  8. Delete

If **This Week** is chosen, follow up:
> Which day? 1. Mon  2. Tue  3. Wed  4. Thu  5. Fri  6. Sat  7. Sun  8. Unassigned

### Step 4 — Act

| Response | Action |
|---|---|
| Today | Add to `### [today's day]` under `## This Week` in Brain/Master.md |
| This Week | Add to chosen day's section (or `### Unassigned`) in `## This Week` |
| This Month | Add under `## This Month` in Brain/Master.md |
| Backlog | Add under `## Backlog` in Brain/Master.md |
| Someday | Add under `## Someday` in Brain/Master.md |
| Ideas | Add to `## Ideas` in Brain/Master.md |
| Skip | Leave in Inbox, move to next item |
| Delete | Remove from Inbox, add nowhere |

Remove from `Brain/Inbox.md` after acting (unless Skipped).

Accept shorthand: t=Today, w=Week, m=Month, b=Backlog, s=Someday, i=Ideas, d=Delete.

### Step 5 — Next Item

Repeat until all items are processed or client types "done".

### Step 6 — Wrap Up

> "Done — [N] items processed. Today: [n], This Week: [n], Backlog: [n], Deleted: [n]. [N] skipped."
