# Your System — What Lives Where

Your AI OS is a set of files and folders that Claude reads and writes throughout your day. Understanding what lives where helps you find things, fix things, and trust what the system is doing.

---

## The Big Picture

Everything lives in your vault — the folder Claude Code opens from. It's a normal folder on your computer. You can open any file in Obsidian and read or edit it directly. Claude won't overwrite your edits.

---

## Brain/

The working layer. Everything active, in-progress, or recently touched lives here.

| File / Folder | What it is |
|---|---|
| `Brain/Master.md` | Your task board. Projects, open tasks, this week's focus, backlog. The main thing `/checkin` reads and updates. |
| `Brain/People/` | One file per person you interact with. Auto-updated by the morning digest. Run `/brief [name]` to pull context before a meeting. |
| `Brain/People/_candidates.md` | Contacts building toward the threshold for auto-file creation. Managed automatically — you don't need to touch it. |
| `Brain/People/_commitment_candidates.md` | Commitment language flagged from email — pending your review in the next `/checkin`. |
| `Brain/Commitments.md` | Open commitments you've confirmed — things you owe people and things people owe you. |
| `Brain/Inbox.md` | Raw captures from `/capture`. Processed by `/inbox`. |
| `Brain/Business.md` | Context about your work — ingested from Drive documents during setup. |
| `Brain/Daily/` | One file per day. Every morning brief saved here permanently. Browse at `localhost:7272`. |
| `Brain/seed-report.md` | Created during initial setup — lists everything the system discovered that you didn't mention in the interview. Review this once. |

---

## Personality/

Who you are and how you work. Claude reads these to give you relevant context, write in your voice, and prioritize correctly.

| File | What it is |
|---|---|
| `Personality/[Your Name].md` | Your identity file — role, background, expertise, how you think. |
| `Personality/Priorities.yaml` | Your top strategic priorities. These lead every morning brief. Update when your focus shifts. |
| `Personality/Working_Preferences.md` | How you prefer to work — communication style, decision-making, what you want Claude to do more or less of. |

*These files were created from your setup interview. They're yours to edit — the more accurate they are, the better everything else works.*

---

## Session history

| File / Folder | What it is |
|---|---|
| `Brain/Session_Logs/` | One file per session. Permanent searchable record of every conversation, decision, and insight. `/recall` searches here. |

---

## System/

Infrastructure. You rarely need to touch this, but it's good to know it's here.

| File / Folder | What it is |
|---|---|
| `System/integrations.yaml` | What's connected (email, calendar, Slack, etc.). If something stops working, check here first. |
| `System/Agents/` | The automated agents — the morning digest, the weekly health report. How they run, what they do. |
| `System/Docs/` | These user-facing guides. |
| `System/Setup/` | Setup instructions for each integration (Google, Microsoft, etc.). |

---

## Dashboard — localhost:7272

A local website that runs on your machine. Open any browser and go to `localhost:7272` when your computer is on.

Shows:
- **Overview** — your task board at a glance
- **People** — all your People files, browsable
- **Sessions** — your full session history, searchable
- **Daily** — every morning brief, archived

The dashboard is read-only — it's a view into your vault, not a way to edit it. Make changes in Claude Code or directly in the files.

---

## What Claude Writes, What It Doesn't

**Claude writes to:**
- `Brain/Master.md` — tasks, project updates, recent communications
- `Brain/People/[name].md` — interaction entries (silently, from the digest)
- `Brain/People/_candidates.md` — contact discovery tracking
- `Brain/People/_commitment_candidates.md` — commitment flags
- `Brain/Inbox.md` — captures from `/capture`
- `Brain/Daily/` — morning brief archives
- `Brain/Session_Logs/` — session logs
- `Personality/` files — during setup and when you run `/update`

**Claude never overwrites:**
- Your manual edits to any file
- Existing content in `Personality/` files (appends only)
- Your `Brain/Commitments.md` without your confirmation

---

## If You Can't Find Something

1. **Run `/recall [what you're looking for]`** — searches everything
2. **Check `Brain/Daily/[date].md`** — if it happened on a specific day, the brief from that morning has it
3. **Check `Brain/Session_Logs/`** — if it came up in a conversation, it's in a session log
4. **Open the Dashboard** at localhost:7272 — Sessions tab has full-text search

---

*Your vault is a normal folder. If you want to read a file, open it. If you want to edit something directly, edit it. Claude treats your edits as authoritative.*
