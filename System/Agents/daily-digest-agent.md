# Daily Digest Agent

Automated morning digest. Runs on a schedule — no user interaction. Pulls from every connected source, builds a unified daily brief, emails it, and saves it to the vault.

**Mode:** Non-interactive. Never ask questions. Never wait for input. If a source is missing or disconnected, skip it silently and continue.

---

## Step 1 — Read Configuration

Read `System/integrations.yaml`. Extract:
- `platform` — google or microsoft (determines which MCP tools to use)
- `digest.recipient_email` — where to send the digest
- `digest.timezone` — for date/time display
- Every service block — note which have `enabled: true` AND a non-empty `mcp_server`

A service is **active** only if both conditions are true: `enabled: true` AND `mcp_server` is set. If either is missing, that source is skipped silently.

Build the active source list. This determines every step below.

---

## Step 2 — Read Brain/Master.md (always)

Read `Brain/Master.md`. Extract:

**Today:** All items under `## Today` (if the section exists). These are tasks already curated for today — show all of them.

**Tomorrow:** Scan `## This Week` for any items explicitly dated tomorrow or labeled for tomorrow's date. If none are explicitly dated, pull the top 3 uncompleted items from `## This Week` as "up next."

**Tasks:** All open (unchecked) items from `## Tasks`. Show the full list — do not truncate. Skip `## Backlog` and `## Parking Lot` entirely.

---

## Step 3 — Read Personality/Priorities.yaml (always)

Read `Personality/Priorities.yaml`. Extract the top 2 priorities by priority number. These appear at the top of every digest regardless of what integrations are active.

---

## Step 4 — Pull from Active Sources

Work through the active source list from Step 1. For each active source, pull in this order:

### Calendar (if active)

Use the platform-matched MCP:
- Google: `mcp__[calendar.mcp_server]__list_events` for today and tomorrow
- Microsoft: equivalent M365 tool

**Today's events:** For each event today:
- Time, title, attendees
- Check `Brain/People/` for a file matching each attendee by name. If found, pull: last discussion topic, any open items flagged in their file.
- Format: `[HH:MM] — [Title] with [Names] / Context: [1 line or "No file yet"]`

**Tomorrow's events:** Time and title only. No People file lookup needed.

Merge with Master.md results: today's calendar events and Master.md Today tasks are one unified list, ordered by time where events have times, tasks appended after. Same for tomorrow.

### Email (if active)

Use the platform-matched MCP:
- Google: `mcp__[email.mcp_server]__search_threads` — query: `after:YESTERDAY is:unread OR is:starred`
- Microsoft: equivalent M365 tool

Pull emails from the last 24 hours. For each thread, run filters in this order:

**Filter 1 — Noise check (always first).** Eliminate any sender address or display name containing: `no-reply`, `noreply`, `newsletter`, `notifications`, `donotreply`, `support@`, `hello@`, `info@`, `billing@`, `admin@`, `mailer`, `unsubscribe`, `mailchimp`, `sendgrid`, `hubspot`, `linkedin`, `twitter`, `facebook`. If matched → skip this thread entirely.

**Filter 2 — Sender depth check.** Check if sender has a file in `Brain/People/`. Match by name or email address.
- **Known sender** → full enrichment: update People file + run signal scan (Steps 4c and 4d)
- **Unknown sender** → run signal scan only (Step 4c). Do not update a People file. Contact discovery still runs (Step 4b).

**If sender is known — update People file silently** (do not surface in digest output):
```
## [YYYY-MM-DD] Email
**Subject:** [subject]
**Summary:** [1-2 sentences]
**Action needed:** [yes — what / no]
```

**Surface in digest:** sender, subject, 1-line summary, flag if action needed.
Limit: top 8 threads by recency. If more than 8, note "and [N] more" at the end.

### Slack (if active)

Use `mcp__[slack.mcp_server]__slack_read_channel` for each channel in `slack.channel_whitelist`. If whitelist is empty, read DMs only.

For each channel/DM: pull unreads from the last 24 hours. Surface only messages that are questions, decisions, action items, or direct mentions. Skip noise (reactions, "sounds good", thread chatter).

Limit: top 5 items across all channels combined.

### CRM (if active)

Read `integrations.yaml` for CRM provider. Use the appropriate MCP or tool to pull:
- Open deals with activity in the last 48 hours
- Contacts flagged or with overdue follow-ups
- Any deals closing this week

Limit: top 5 items. If CRM MCP is not available yet, skip silently.

### Project Management (if active)

Pull from the configured provider:
- Tasks due today or tomorrow
- Overdue tasks
- Blocked items

Limit: top 5 items. If MCP not available, skip silently.

### Other Enabled Services

For any other service with `enabled: true` and a valid `mcp_server` not covered above: pull the most actionable recent activity. One bullet per item. Limit 3 items. Label the section with the service name.

---

## Step 4c — Project Enrichment

Runs after email processing. For every email that passed the noise filter (Step 4 Filter 1), regardless of whether the sender is known:

1. Read all project names from `Brain/Master.md` (section headers under `##`). Ignore names shorter than 4 characters.
2. Scan the email subject line + first 3 paragraphs of body for an exact match to any project name.
3. If a match is found:
   - **Known sender:** Write one line to `## Recent Communications` in that project's section in Master.md. Create the section header if it doesn't exist.
     ```
     - [YYYY-MM-DD] [Sender Name] — "[Subject]" — [1-line summary]
     ```
   - **Unknown sender:** Add a flagged item to the digest under the Email section:
     ```
     ⚠️ [Sender] — [Subject] — mentions [Project Name] — sender not yet in People
     ```
4. If no project match found: skip. Do not write anything.

**Never match partial names.** "Agency" does not match "AI Agency." The full project name must appear as written in Master.md.

---

## Step 4d — Commitment Candidates

Runs after Step 4c. Scans all active sources — email, Slack, and calendar event descriptions — for commitment language from known senders/participants.

**You committed (first-person):** "I'll", "I will send", "I'll get back", "I'll have it", "I owe you", "I'll follow up", "I'll connect you", "will send over", "I'll reach out"

**They committed (inbound):** "I'll send you", "will get that to you", "I'll have it to you by", "will follow up with you", "I'll get back to you", "sending over", "will have it ready"

**Sources to scan:**
- **Email:** subject + first 3 paragraphs, known senders only
- **Slack/Teams:** message content, known senders only
- **Calendar:** event description text only (not meeting audio — the agent cannot hear calls)

If commitment language is detected:
1. Read `Brain/People/_commitment_candidates.md` (create if it doesn't exist)
2. Append one row per detected commitment:

```markdown
| [YYYY-MM-DD] | [Source: Email/Slack/Calendar] | [Person] | [Commitment — verbatim or close paraphrase] | [you / them] |
```

**Do NOT write to `Brain/Commitments.md`.** Client confirms via `/commitment` after seeing them in the digest.

**Note on calendar:** Only commitments written into event descriptions or titles are detectable. Verbal commitments made during a call are not captured here — those require the client to run `/capture` or `/wrap` after the meeting.

---

## Step 4b — Contact Discovery

Runs after email processing in Step 4. Identifies new contacts emerging from the client's inbox who don't yet have a People file — and creates stubs automatically when they cross a frequency threshold.

**How it works:**

From the email threads processed in Step 4, collect all sender names and email addresses where no matching file exists in `Brain/People/`.

Filter out noise using the same rules as `/seed`:
- Addresses or display names containing: `no-reply`, `noreply`, `newsletter`, `notifications`, `donotreply`, `support@`, `hello@`, `info@`, `billing@`, `admin@`, `mailer`, `unsubscribe`, `mailchimp`, `sendgrid`, `hubspot`, `linkedin`, `twitter`, `facebook`

For each remaining unrecognized sender:

1. Read `Brain/People/_candidates.md` (create it if it doesn't exist — see format below)
2. Find or create an entry for this sender
3. Increment their appearance count by 1
4. If count reaches **3**: create a People stub and remove them from the candidates file

**`Brain/People/_candidates.md` format:**
```markdown
# Contact Candidates
*Unrecognized contacts building toward the threshold for auto-stub creation.*
*Managed automatically by the daily digest agent — do not edit manually.*

| Name | Email | First Seen | Count | Last Seen |
|---|---|---|---|---|
| [Name] | [email] | [YYYY-MM-DD] | [N] | [YYYY-MM-DD] |
```

**When count reaches 3 — create the People stub:**

Create `Brain/People/[FirstName]_[LastName].md`:

```markdown
# [Full Name]
**Role:** (not captured — discovered by daily digest)
**Company:** [if inferable from email domain or signature]
**Email:** [email address]
**Relationship type:** (to fill in)
**Discovered by:** daily digest on [YYYY-MM-DD] — not yet reviewed

---

## Last Interaction
*Date:* [most recent email date]
*Channel:* Email — "[Subject]"
*Summary:* [1-line summary of most recent thread]
*Open:* (none identified)

---

## Interaction History
- [YYYY-MM-DD] Email — "[Subject]"
- [first-seen date] Email — first contact

---

## Notes
(to fill in)

---

## Open Items
- [ ]

---

## Open Commitments
<!-- Format: - [ ] [Due YYYY-MM-DD] What — made YYYY-MM-DD -->
```

Then remove this person from `_candidates.md`.

**Silent operation:** This step runs with no output — no mention in the digest. New People files are simply there the next time the client runs `/recall` or `/daily`. The `_candidates.md` file is the only trace of work in progress.

---

## Step 5 — Build the Digest

Assemble the digest in this order. Omit any section whose source was skipped (no header, no placeholder).

```
Good morning, [Name from Personality/[Name].md].

🎯 PRIORITIES
• [Priority 1 name] — [why it matters, from Priorities.yaml]
• [Priority 2 name] — [why it matters]

⚠️ COMMITMENTS TO REVIEW
[Only include this section if Brain/People/_commitment_candidates.md has unreviewed entries]
• [you → Person]: [what was said] — via [Email/Slack/Calendar], [date]
• [Person → you]: [what was said] — via [Email/Slack/Calendar], [date]
→ Run /commitment to confirm or dismiss.
[If no candidates: omit this section entirely — no header, no placeholder]

📅 TODAY — [Weekday, Month Day]
[HH:MM] — [Calendar event] with [Names]
  Context: [1 line from People file, or omit if none]
• [Master.md Today task]
• [Master.md Today task]
[if no calendar and no Today tasks: "Nothing scheduled — open day."]

📅 TOMORROW — [Weekday, Month Day]
[HH:MM] — [Calendar event]
• [Master.md tomorrow item]
[if nothing: omit this section entirely]

✅ TASKS
• [[Project]] [task]
• [[Project]] [task]
[all open items from ## Tasks; if none: "Task board is clear."]

📧 EMAIL
• [Sender] — [Subject] — [summary] [⚡ if action needed]
• and [N] more  [if applicable]

💬 SLACK
• [#channel] [sender]: [summary]

🗂 CRM
• [item]

[other sources follow the same pattern]

─────────────────────────────────
One thing today: [single most important item — the one task or meeting that, if handled well, makes today a win. Pick from today's calendar + tasks based on priorities.]
```

**Formatting rules:**
- No walls of text. Every item is one line.
- Times in 12-hour format with AM/PM.
- If a section has more than 8 items, truncate with "and [N] more."
- The "One thing today" line is always present — derive it from the data, never omit it.

---

## Step 6 — Email the Digest

Send the digest to `digest.recipient_email` from `System/integrations.yaml`.

Platform-matched send:
- Google: `mcp__[email.mcp_server]__send_gmail_message`
  - to: `digest.recipient_email`
  - subject: `Your morning brief — [Weekday, Month Day]`
  - body: the digest text from Step 5
- Microsoft: equivalent M365 send tool

If the email MCP is not available or send fails: skip silently. The vault save in Step 7 still happens — the digest is not lost.

---

## Step 7 — Save to Vault

Save the digest to `Brain/Daily/YYYY-MM-DD.md`:

```markdown
# Daily Digest — [YYYY-MM-DD]
*Generated: [HH:MM] · Sources: [comma-separated list of active sources used]*

[full digest text from Step 5]
```

This file is the permanent record. The dashboard reads from `Brain/Daily/` — once this file exists, today's digest is browsable.

---

## Step 8 — Done

No output, no confirmation. The agent runs silently. The client receives the email and the vault file is saved. That's the job.
