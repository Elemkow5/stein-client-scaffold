---
name: comms-triage
description: Pull unread/flagged messages from all connected channels and return a single unified prioritized queue. Run this before touching any inbox.
user-invocable: true
---

# /comms-triage — Unified Communications Triage

Reads all connected channels (email, Slack, Teams, LinkedIn DMs) and returns one prioritized list sorted by urgency. Run this every morning before opening any inbox.

---

## Instructions

### Step 1 — Check what's connected

Read `System/integrations.yaml`. Look for the `comms_hub.channels` block. Note which channels have `enabled: true`. Skip any channel with `enabled: false` — silently, no error.

If ALL channels are disabled or `comms_hub` block is missing:
> "No channels are connected yet. Update System/integrations.yaml to enable email, Slack, Teams, or LinkedIn."
Stop.

### Step 2 — Apply filter (if specified)

If the client passed a filter when invoking (e.g. `/comms-triage last 24 hours` or `/comms-triage flagged` or `/comms-triage from [name]`), note it. Apply it to every channel pull in Step 3.

Default if no filter: all unread messages.

### Step 3 — Pull messages from each connected channel

For each enabled channel, pull messages and read sender, subject/thread name, and body. For each sender, check `Brain/People/` for a matching person page — if found, note relationship context.

**Email (Google):** Use Gmail MCP. Pull unread messages from inbox. Apply filter if set.

**Email (Microsoft):** Use M365 Connector. Pull unread Outlook messages. Apply filter if set.

**Slack:** Use Slack MCP. Pull unread DMs. If `channel_whitelist` in integrations.yaml is non-empty, also pull unread messages from those channels. Default: DMs only.

**Teams:** Use M365 Connector. Pull unread Teams chat messages.

**LinkedIn:** Read `Brain/Comms/LinkedIn_Queue.md`. Each line is one message in format `[YYYY-MM-DD HH:MM] **[Sender]:** [message]`. Pull all unread entries (those not yet triaged this session).

### Step 3b — Update People Files from Email

For every email message pulled in Step 3, silently and automatically:

1. **If the sender has a People file** (`Brain/People/[Name].md`): append a dated interaction entry:
   ```
   ## [YYYY-MM-DD] Email
   **Subject:** [subject line]
   **Summary:** [1-2 sentences — what they said, what they asked, what they mentioned]
   **Action needed:** [yes/no — and what, if yes]
   ```

2. **If no People file exists:** create `Brain/People/[Name].md` using the standard template:
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
   Fill in what can be inferred from the email. Leave blanks where unknown.

Do this for every email sender — known or new. No announcement to the client. This happens silently before triage output is shown.

Non-email channels (Slack, Teams, LinkedIn): do not create or update People files. Email only.

### Step 4 — Categorize and flag every message

For each message, assign:

**Category (pick one):**
- `[Reply needed]` — requires a response from the client
- `[Action item]` — something to do, no reply needed
- `[FYI]` — informational, no action required
- `[Waiting on them]` — client is waiting for something from this person
- `[Ignore]` — spam, newsletter, automated notification

**Urgency (pick one):**
- `[Today]` — needs to happen today
- `[This week]` — can wait but shouldn't go past the week
- `[No deadline]` — no time pressure

Tag each message with its source channel: `[Email]`, `[Slack]`, `[Teams]`, `[LinkedIn]`.

Use People page context to inform urgency — a message from a hot prospect or key client gets `[Today]` by default unless clearly FYI.

### Step 5 — Return the unified triage list

Sort by urgency: `[Today]` first, then `[This week]`, then `[No deadline]`. Within each group, put `[Reply needed]` and `[Action item]` before `[FYI]` and `[Waiting on them]`. `[Ignore]` items go at the very bottom, collapsed.

Format each entry:
```
[Channel] [Category] [Urgency]
From: [Sender name] ([relationship if People page exists])
Subject/Thread: [subject or first line]
Summary: [one sentence — what they want or what this is]
```

End the list with a count summary:
```
── [N] total · [N] need replies today · [N] action items · [N] FYI · [N] ignored ──
```

Then ask:
> "Which thread do you want to reply to? Say the sender name or number, or type /comms-reply."

---

## Notes

- Never error on a missing channel — skip silently and continue with what's connected
- If a channel MCP returns an auth error, surface it once at the top: "Gmail needs re-authorization — skipping for now" then continue
- People page context is additive — if no page exists for a sender, categorize from message content alone
- LinkedIn Queue: mark entries as processed after triage by appending `[triaged YYYY-MM-DD]` to each line, so they don't appear again next run
