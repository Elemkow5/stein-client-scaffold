# Your Morning Brief — How It Works

Every morning, before you open your laptop, your system has already run. It pulled your calendar, scanned your email, checked your priorities, and assembled a brief — then emailed it to you.

This document explains what it does, what it does well, and where it falls short. Read this before you start relying on it.

---

## What It Does

Each morning the system:

1. Reads your top priorities (from your Personality files) — these always lead the brief
2. Pulls today's and tomorrow's calendar events, with context on who you're meeting
3. Scans your last 24 hours of email for anything unread or flagged
4. Pulls open tasks from your task board
5. Checks Slack, your CRM, and any other connected tools (if you've connected them)
6. Assembles it all into one brief and emails it to you
7. Saves a copy to your vault at `Brain/Daily/YYYY-MM-DD.md`

It also runs silently in the background:
- Updates your People files with new interaction entries
- Tracks new contacts who email you (builds toward creating a file for them)
- Flags potential project mentions and commitment language for review

---

## What It Does Well

**It shows up every day.** You don't have to do anything. The brief is in your inbox before you start.

**It remembers context you'd forget.** When you have a meeting with someone, it pulls what you last discussed with them and any open items — without you having to dig through notes.

**It finds people you haven't set up yet.** Contacts who email you repeatedly will automatically get a file created in your system after they appear 3 times. You didn't have to remember to add them.

**It's connected to your real data.** This isn't a to-do app — it's pulling your actual calendar, your actual email, your actual priorities. The brief reflects reality.

**It saves everything.** Every brief is stored permanently in `Brain/Daily/`. If you missed a morning or want to look back, it's there.

---

## What It Cannot Do

Be honest with yourself about these. The system is useful precisely because you understand its limits.

**It only knows what's connected.** If you didn't connect your calendar, there are no calendar events. If Slack isn't connected, there's no Slack. The brief is only as complete as what you've set up. Check `System/integrations.yaml` to see what's active.

**It can't read attachments.** PDFs, Word docs, spreadsheets attached to emails — the system doesn't read them. It only sees the subject line and the first few paragraphs of an email body.

**It caps at 8 emails.** The digest shows the 8 most recent unread or starred threads. If you have a high-volume inbox, important emails may be below the cutoff and not appear in the brief. They still get processed for People file updates and project enrichment — they just won't show in the summary.

**People matching is approximate.** If someone emails you from a different address than what's in their file (work vs. personal, a company alias), the system may not connect the two. It matches by name and email address — if neither matches, it treats them as a new contact.

**Project detection requires exact names.** If a project in your system is called "Retail Expansion" and an email says "re: the retail deal," the system won't connect them. It looks for the exact project name as it appears in your task board. Short names (under 4 characters) are skipped to avoid false matches.

**It doesn't understand tone or nuance.** An email that's technically "actionable" (it contains a question) might not actually require your attention today. The system flags signals — judgment is still yours.

---

## Known Miscues

These are things the system will sometimes get wrong. Not bugs — just the nature of automated processing.

**False People file entries.** If a company you have a People file for sends you a bulk email (a product update, a notification), the system may log it as an interaction with that person. The entry won't cause harm, but it's noise. You can delete any entry that doesn't belong.

**Missed project mentions.** If someone refers to a project by a nickname, abbreviation, or a slight variation of the name, the system may miss the connection. "Agency" when the project is "AI Agency," for example. These just don't get logged — nothing is written incorrectly.

**Commitment candidates aren't perfect.** When the system detects commitment language in email or Slack ("I'll send you..." / "I'll have it to you by..."), it surfaces them in the brief under "Commitments to Review" — they do NOT go into your commitments list until you confirm via `/commitment`. But it may flag things that aren't real commitments, and it may miss commitments worded indirectly. The candidate list is a starting point, not a finished record.

**Commitments made on calls are invisible to the system.** The agent can only detect commitment language in written channels (email, Slack, calendar descriptions). If you verbally committed to something on a call, it won't appear here. Workaround: run `/capture` or `/wrap` after the meeting and log it manually.

**Unknown sender gaps.** If someone important emails you for the first time, they don't have a People file yet. Their email will still appear in the brief, and if they mentioned a known project, that gets flagged. But no People file gets updated for them until they've appeared 3 times or you create their file manually.

**Timezone edge cases.** If the digest runs close to midnight, "today's" events may reflect the wrong date. Check `System/integrations.yaml` for your configured timezone if the dates look off.

---

## When Something Feels Wrong

**The brief didn't arrive.** Check `Brain/Daily/[today's date].md` — the brief is always saved to the vault even if the email failed. If the file doesn't exist, the agent may not have run. Check with your system operator.

**An email I needed wasn't in the brief.** It may have been beyond the 8-thread cutoff, or the sender wasn't connected. Check `Brain/People/_candidates.md` to see if they're being tracked as a new contact.

**Something wrong is in a People file.** Edit it directly. Your edits won't be overwritten — the system only appends new entries, it doesn't replace existing content.

**A commitment got flagged that isn't real.** Open `Brain/People/_commitment_candidates.md` and delete the row. It hasn't been written anywhere else yet.

**The project section has noise.** The `## Recent Communications` section in your task board is auto-populated and may occasionally include low-signal entries. Delete any that don't belong — the section is informational, not a permanent record.

---

## The Bottom Line

The morning brief is a strong starting signal, not a complete picture. It will catch most of what matters. It will miss some things. It will occasionally include something that didn't need to be there.

Use it to orient your morning, not as the only thing you trust. If something feels important, go look at the source.

---

*Questions about your setup? Run `/checkin` in Claude Code for the interactive version, or ask your system operator.*
