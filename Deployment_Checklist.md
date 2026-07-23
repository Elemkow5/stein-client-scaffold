# Deployment Checklist
*Run through this before and during every client setup session.*
*Pre-session steps: 30–60 min alone. Session itself: 60–90 min with client.*

---

## Pre-Session (Andrew does this alone, before the client call)

### 1. Run the setup script
On the client's machine (or via screen share):

```bash
bash System/Scripts/setup.sh
```

This script handles everything automatically:
- Asks for client name and vault location (iCloud vs Google Drive)
- Copies the scaffold to the right place
- Checks Node.js and Obsidian are installed
- Starts the dashboard at localhost:7272
- Installs LaunchAgent plists so dashboard and inbox watcher auto-start on login

If running on a client machine you can't easily script on, do the steps manually:
1. Copy `_CLIENT_SCAFFOLD/` to the right location, rename it
2. Confirm Node.js is installed (`node --version`)
3. Confirm Obsidian is installed
4. `node Dashboards/server.js &` to start the dashboard

### 2. Connect integrations in Claude Cowork (browser — do this first)

Go to **cowork.claude.ai** → Integrations. This is where OAuth happens — connecting here makes the MCP servers available to Claude Code automatically (same Anthropic account).

**Google path (most clients):** Connect Google Calendar, Gmail, and Google Drive.

**Microsoft path:** Connect Microsoft 365. ⚠️ Less tested — allow extra time.

Connect everything you can before the session. Anything not connected yet gets flagged in `System/integrations.yaml` as a follow-up — don't let a missing connector eat session time.

### 3. Confirm MCPs are live in Claude Code

After connecting in Cowork, verify they're visible in Claude Code:

```bash
claude mcp list
```

Calendar, email, and drive should appear. Quick test: "what's on my calendar today?" If that works, the integration is live.

### 3. Confirm everything works before the client joins
- [ ] Dashboard loads at `http://localhost:7272`
- [ ] Claude Code is open in the vault folder
- [ ] MCPs are connected — test: "what's on my calendar today?"
- [ ] Obsidian shows vault files
- [ ] You have 60–90 minutes blocked

---

## Session 1 — With the Client

### Step A — Run /setup
The live interview. Takes 30–45 minutes. Claude asks questions conversationally and writes:
- `Personality/[Name].md`
- `Personality/Priorities.yaml`
- `Brain/Master.md`
- `Brain/People/*.md` (key contacts)
- `Brain/Goals/*.md` (3-year, annual, quarterly placeholders)
- `System/integrations.yaml` (platform, tools, digest time, inbox folder)

You don't need to facilitate — Claude drives it. Your job is to be present, build rapport, and answer any "why" questions the client has.

### Step B — Connect remaining MCPs (if not already done)
Use `System/integrations.yaml` as the checklist. Set `enabled: true` and `mcp_server:` for each connected service.

### Step C — Run /Let's-Go
The ceremonial moment. Pulls all connected sources live for the first time. Sends the first digest in the room. Schedules the morning digest. The client leaves Session 1 having seen their actual data flow through their actual system.

---

## After Session 1 — Verify

- [ ] Dashboard shows client's name in sidebar
- [ ] `Brain/Master.md` has project sections
- [ ] `Brain/People/` has person files
- [ ] `Personality/[Name].md` is written
- [ ] `System/integrations.yaml` has correct platform, services, inbox_folder, and digest time
- [ ] Daily digest is scheduled (check `System/Scheduled_Flows.md` — status should be ✅)
- [ ] Inbox watcher is running (auto-started by launchd — drop a test file in the AI Inbox folder and confirm it appears in `Brain/Inbox.md` within a few seconds)
- [ ] Dashboard loads and shows real data

---

## Weekly (Andrew only — automated)

The weekly health report emails you every Monday at 7:00 AM from the client's system.

It covers: sessions this week, last session date, open/completed tasks, inbox backlog, vault growth, and automation status. It flags anything worth raising and suggests a call agenda.

You never prep for a client call blind — the health report is your agenda.

---

## Client Success Cadence

| Period | Touchpoint | Goal |
|---|---|---|
| Days 1–11 | Email sequence (automated) | Build the 5 core habits |
| End of Week 1 | Call — 20 min | Fix friction, lock habits |
| Weeks 2–4 | Weekly call — 35 min | Teach one new capability per call |
| Month 1 wrap | Call — 45 min | Review + deepen relationship layer |
| Month 2+ | Every 1–2 weeks — 30 min | Module expansion, health report agenda |

Every call: read health report before joining → address flags → teach one thing → check for new tools to connect.

Full call agendas and email sequence copy: `Projects/AI_Agency/Stein_for_Clients/Client_Success_Playbook.md`

This is curriculum, not support. The client gets smarter every week.

---

## Handoff Message to Client

Send after Session 1:

> "Your system is live at localhost:7272. It will open automatically every time you log in. To start each day: open Claude Code in your [Name] folder, type `/planning`, and you're off. Your daily briefing will land in your email each morning at [time]. Let me know if anything feels off this week."

---

## Troubleshooting

**Dashboard not loading after restart:** LaunchAgent should handle this automatically. If it doesn't, open Terminal and run:
```bash
node ~/[ClientName]_AI/Dashboards/server.js &
```

**Inbox watcher not capturing files:** Check that `inbox_folder.local_path` in `System/integrations.yaml` has the correct full path. Restart the watcher:
```bash
node ~/[ClientName]_AI/System/Scripts/inbox-watcher.js &
```

**MCP connection issues:** See `System/Setup/google-setup.md` or `System/Setup/microsoft-setup.md`.

**Logs:** Dashboard and inbox watcher logs live at `System/Logs/`.
