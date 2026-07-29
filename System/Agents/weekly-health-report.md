# Weekly Health Report Agent
*Scheduled: Every Monday at 7:00 AM. Emails Andrew. Saves report to System/Health_Reports/.*
*Non-interactive — runs silently to completion.*

---

You are generating the weekly health report for this client's AI system. This report goes to Andrew Wohlberg (awohlberg@gmail.com) — NOT the client. It is his agenda for the weekly client call. Be specific, scannable, and flag anything worth raising.

---

## Step 1 — Gather session data

Read all files in `Brain/Session_Logs/` from the past 7 days.

For each session file found:
- Note the date and duration (from filename and ## Next Steps position)
- Note what projects were worked on (from session log tags like [ProjectName])
- Count the total number of session log entries (lines starting with `**[`)

Report:
- Sessions this week: N
- Last session: YYYY-MM-DD
- Projects touched: [list]
- Total log entries written: N

If zero sessions this week, flag: ⚠️ NO SESSIONS THIS WEEK

---

## Step 2 — Read Master.md

Read `Brain/Master.md`.

Count:
- Open tasks: lines matching `^- \[ \]`
- Completed tasks: lines matching `^- \[x\]`
- Sections present (## headings)

Flag if:
- Open task count > 20: backlog may be overwhelming
- No tasks completed since last report (compare with prior week's health report if it exists in System/Health_Reports/)

---

## Step 3 — Read Inbox

Read `Brain/Inbox.md`.

Count total items (lines starting with `- `).

Find the oldest item: look for date stamps in format `[YYYY-MM-DD]` in item text. If no dates, note that inbox items are undated.

Flag if:
- Inbox count > 10: ⚠️ Inbox backlog — raise with client
- Any item older than 14 days: ⚠️ Stale item in inbox

---

## Step 4 — Scan vault activity

Count new files created this week across:
- `Brain/People/` — new people files
- `Brain/Projects/` — new project files or subfolders
- `Goals/` — new or updated goals
- `Brain/Topics/` — new hub pages

Report counts. Flag if People count grew (signals active relationship tracking) or if no new files created anywhere (signals low engagement).

---

## Step 5 — Read Scheduled Flows

Read `System/Scheduled_Flows.md`.

For each flow listed:
- Note name, schedule, and status (✅ running / ⚠️ warning / ❌ failed / ⬜ not yet scheduled)

Flag any flow that is ❌ failed or ⬜ not yet scheduled.

Note when the daily digest last ran (most recent file in `Brain/Daily/`). If no file from yesterday or today, flag: ⚠️ Daily digest may not be running

---

## Step 6 — Compose the report

Build the report in this format:

```
WEEKLY HEALTH REPORT
[Client Name] · Week of [Monday date]
Generated: [today's date]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 ACTIVITY
Sessions this week: N
Last session: YYYY-MM-DD
Projects worked on: [list]

📋 TASKS
Open: N  |  Completed this week: N

📥 INBOX
Items waiting: N [oldest: YYYY-MM-DD or "undated"]

🗂 VAULT GROWTH
New people files: N
New projects: N
New goals: N
New topic hubs: N

⚙️ AUTOMATION STATUS
[list each flow with its status icon]
Daily digest last ran: YYYY-MM-DD

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚩 FLAGS FOR YOUR CALL
[bullet list of any ⚠️ items — what to raise, and what to ask]

If no flags: "Nothing urgent. Use the call to teach one new skill."

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

SUGGESTED CALL AGENDA
- [ ] Review flags above
- [ ] Ask: what's working, what's feeling clunky?
- [ ] Teach: [suggest one skill or workflow based on activity patterns]
- [ ] Check: any new tools or integrations to connect?
```

---

## Step 7 — Save the report

Save to `System/Health_Reports/YYYY-MM-DD.md` (today's date).

---

## Step 8 — Email Andrew

Email the report to awohlberg@gmail.com using the platform-matched email MCP from `System/integrations.yaml`.

Subject: `[ClientName] Weekly Report · [Date]`
Body: the full report from Step 6.

---

## Step 9 — Update Scheduled_Flows.md

Update the Last Run column for "Weekly Health Report" in `System/Scheduled_Flows.md` to today's date.

---

## Step 10 — Silent completion

No output. No summary. Done.
