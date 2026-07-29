# Stein for Clients — Deployment Guide

This is the empty vessel. Copy it to a new client's machine, run `/setup`, and their system is live.

---

## What's Here

```
_CLIENT_SCAFFOLD/
├── Brain/              — Everything stored and remembered
│   ├── Session_Logs/   — One file per session, permanent record
│   ├── Memory/         — Distilled facts that persist forever
│   ├── Inbox.md        — Raw captures, processed during /inbox
│   ├── Master.md       — Live task board
│   ├── People/         — One page per key contact
│   ├── Projects/       — One folder per active project
│   ├── Decisions/      — Every significant decision, captured
│   └── Knowledge/      — Ingested documents, PDFs, notes
├── Personality/        — What makes the system theirs
│   ├── [Name].md       — Master identity file (written during /setup)
│   ├── Priorities.yaml — Strategic priorities
│   ├── Mistake_Patterns.md
│   └── Working_Preferences.md
├── Goals/              — Annual → Quarterly → Weekly hierarchy
├── Dashboards/         — The front door (localhost:7272)
├── System/             — Scripts and config
│   └── Scripts/        — Utility scripts
├── .claude/
│   ├── skills/         — All slash commands
│   └── hooks/          — All automation scripts
├── CLAUDE.md           — System prompt (reads Personality/[Name].md)
└── hooks.yaml          — Canonical connective tissue spec
```

---

## Deployment Steps (Andrew runs these before session 1)

1. Copy this folder into the client's iCloud vault folder (or Google Drive for Desktop folder)
2. Install Claude Code on their machine
3. Install Obsidian — point to the vault folder
4. Configure MCPs in Claude Code:
   - Google: Calendar MCP + Gmail MCP + Drive MCP
   - Microsoft: M365 Connector (covers Outlook, Teams, Calendar, OneDrive)
5. Run `System/Scripts/start-dashboard-server.sh` — confirm localhost:7272 loads
6. Open Claude Code → run `/setup` — begin onboarding interview with client

---

## Onboarding (Session 1)

Run `/setup` with the client. Have them complete `Onboarding_Questionnaire.md` beforehand if possible.

`/setup` will:
- Interview the client (or read their completed questionnaire)
- Write all Personality files
- Create People pages for their key contacts
- Seed Master.md with their active projects
- Configure integrations for their platform
- Run `/checkin` as the closing moment — their first morning brief

---

## Daily Client Workflow

1. Open browser → `localhost:7272` — master dashboard
2. Click Daily Brief — see today's meetings, priorities, tasks
3. Open Claude Code and run `/checkin` — the one habit. Everything else (`/capture`, `/recall`, `/wrap`) comes naturally.
4. Everything Claude Code writes shows up in the dashboards automatically
