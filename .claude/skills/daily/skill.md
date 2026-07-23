---
name: daily
description: Morning brief — pulls today's calendar, surfaces meetings and who they're with, top priorities, overdue items, and the one thing that matters most. Run this to start the day with clarity. The flagship daily ritual.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - mcp__google_calendar__list_events
  - mcp__google_calendar__list_calendars
  - mcp__microsoft_365__list_events
---

# /daily — Morning Brief

Pulls today's calendar, surfaces what's open, processes anything new, and produces a single clear plan for the day. Run this first thing every morning.

---

## Step 1 — Read the Board

Read `Brain/Master.md`. Note:
- What's in Today (carry-forward from yesterday or set during last /wrap)
- What's in This Week for today's date
- Any overdue items from previous days

Read `Brain/Inbox.md`. Count unprocessed items — flag if there are more than 5.

---

## Step 2 — Pull the Calendar

Pull today's events from the connected calendar (Google or Microsoft — whichever is configured in `System/integrations.yaml`).

For each event today, surface:
- Time and title
- Who's attending (names)
- Check `Brain/People/` for a file matching each attendee — if found, pull: last discussion topic, any open items, what they care about
- Also check that file's `## Open Commitments` section — surface anything owed to this person that's due today or overdue
- If no People file exists for an attendee: note their name and suggest creating one after the meeting

Format:

```
📅 [Time] — [Meeting Title]
   With: [Names]
   Context: [1-2 lines from People file, or "No file yet — consider creating one after this meeting"]
   Open items: [Any open action items from prior interactions]
   ⏰ You owe them: [Any Open Commitments due today/overdue, or omit this line if none]
```

If no calendar is connected, skip this step and note: "Calendar not connected — run the setup guide in System/Setup/ to connect."

---

## Step 2b — Read Recent Emails + Update People Files

Check `System/integrations.yaml` for email platform (Google or Microsoft). If email is not connected, skip this step silently.

Pull emails from the last 48 hours. For each email:

1. Check if the sender has a file in `Brain/People/`. Match by name or email address.
2. **If a People file exists:** append a dated interaction entry to the bottom of their file:
   ```
   ## [YYYY-MM-DD] Email
   **Subject:** [subject line]
   **Summary:** [1-2 sentences — what they said, what they asked, what they mentioned]
   **Action needed:** [yes/no — and what, if yes]
   ```
   Do this silently — no announcement to the client.

3. **If no People file exists AND the sender appears more than once in recent history OR is attending a meeting today:** create `Brain/People/[Name].md` using the template:
   ```markdown
   # [Full Name]

   **Role:**
   **Company:**
   **Relationship type:**
   **How decisions get made:**

   ---

   ## Last Interaction
   *Date:* [today]
   *What was discussed:* [from email]
   *What's open:* [any action items or questions]

   ---

   ## Notes

   ---

   ## Open Items
   - [ ]
   ```
   Fill in what can be inferred from the email. Leave blanks where unknown. No announcement.

4. **For today's meeting attendees specifically:** after updating all People files, flag any attendee who had email activity in the last 48 hours. Surface this in Step 2's meeting block:
   ```
   📧 Recent email: [subject] — [one-line summary]
   ```
   This appears directly under the meeting context so the client sees it before walking in.

---

## Step 3 — Read the Priorities

Read `Personality/Priorities.yaml`. Surface the top 1-2 active priorities — the things that should be getting the most time and attention right now.

Check: does Today's task list reflect those priorities? If the calendar is full of noise and the priorities have no tasks, flag it.

---

## Step 3b — Competitor Signals (if active)

Check if `Brain/Intelligence/Competitors/` exists. If not, skip this step silently.

If it exists, check `Brain/Intelligence/Weekly/` for any file modified in the last 24 hours:

```bash
find "Brain/Intelligence/Weekly" -name "*.md" -newer "Brain/Intelligence/Weekly/_placeholder.md" \
  -not -name "_placeholder.md" 2>/dev/null | sort -r | head -1
```

If a recent weekly digest file is found, read it and extract:
- The Summary section (2-3 sentences)
- Any Action Items

Surface in the daily plan as:

```
🔍 COMPETITOR SIGNALS — [digest date]
[Summary from digest]
Action: [action item if any, or omit]
Full report: Brain/Intelligence/Weekly/[date].md
```

If no weekly digest was updated in the last 24 hours: skip this section entirely — no header, no placeholder.

---

## Step 4 — Build Today's Task List

Consolidate:
- Items already in Today in Master.md
- This Week items for today's date
- Any urgent inbox items

Rules:
- No more than 5-6 tasks. Be honest about what's actually doable.
- Active P0 priorities get a slot.
- Overdue items from prior days go in Today automatically.

---

## Step 5 — Save the Daily Plan

Save to `Brain/Daily/YYYY-MM-DD.md`:

```markdown
# Daily Plan — [DATE]

## The One Thing
[Filled in Step 6]

## Calendar
[Today's meetings with context — from Step 2]

## Today's Tasks
- [ ] Task
- [ ] Task
...

## Carry-Forward
[Anything overdue or rolling from yesterday]
```

---

## Step 6 — The One Thing

Ask:
> "What's the single most important thing today — the one that, if done, makes the day a win regardless of everything else?"

Write it at the top of the daily file under **The One Thing**.

If they're unsure, prompt with: "Look at your Priorities. What would move the needle most on your P0 priority?"

---

## Step 7 — Update Master.md

- Confirm Today section reflects the final task list
- Move any new THIS WEEK items to the correct day
- Move new backlog items to the Backlog section
- Clear processed inbox items from Brain/Inbox.md

---

## Step 8 — Pattern Check

Scan the task list and calendar. One observation only if something stands out — a priority that's missing, a meeting-heavy day with no deep work, an overdue item that keeps rolling. One line. No lecture.

---

## Step 9 — Close

End with the daily plan summary and: "You're set. Go do the thing."

---

## Notes

- If run in the afternoon: skip morning framing, plan the rest of the day.
- If calendar shows no events: confirm the MCP is connected before concluding the day is clear.
- The daily file is a snapshot — it doesn't change after this point. Live tracking happens in Master.md.
- People files are in `Brain/People/[Name].md` — check by first name or full name.
