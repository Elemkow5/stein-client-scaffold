---
name: lets-go
description: One-time system initializer — runs at the end of Session 1 after /setup completes. Fires up every connected source for the first time, runs the daily digest live in the room, and schedules the automated morning digest. The moment the system goes from installed to running.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Bash
  - mcp__scheduled-tasks__create_scheduled_task
  - mcp__scheduled-tasks__list_scheduled_tasks
  - mcp__*__list_events
  - mcp__*__search_threads
  - mcp__*__get_thread
  - mcp__*__send_gmail_message
  - mcp__*__slack_read_channel
  - mcp__*__slack_read_thread
---

# /Let's-Go — Start Your Engines

Runs exactly once, at the end of Session 1, after `/setup` is complete. Fires everything up for the first time. The client leaves having seen their actual data flow through their actual system — and with the scheduled digest already running.

**Mode:** Run this with Andrew in the room. It's a demo moment, not a background task.

---

## Step 1 — Confirm /setup Is Complete

Before doing anything, verify setup is done. Check that these files exist:

```
Personality/[Name].md
Personality/Priorities.yaml
Personality/Working_Preferences.md
System/integrations.yaml
Brain/Master.md
```

If any are missing, say:
> "Setup looks incomplete — [missing file] wasn't created. Run `/setup` first, then come back to `/Let's-Go`."

Stop here if setup is incomplete.

---

## Step 2 — Read Configuration

Read `System/integrations.yaml`. Extract:
- `platform` — google or microsoft
- `digest.time` — scheduled delivery time
- `digest.timezone` — client's timezone
- `digest.recipient_email` — where the digest gets sent
- Every service block — note which are active (`enabled: true` AND `mcp_server` set)

Build the active source list. Announce it:

> "Here's what's connected and ready to go:"
> 
> ✅ [service name] — [provider]  
> ✅ [service name] — [provider]  
> ⚠️ [service name] — not connected yet (will be skipped)  

Give the client a clear picture of what will and won't appear before running anything.

---

## Step 3 — Run the Daily Digest Live

Say:
> "Let's pull everything in right now so you can see what your morning brief looks like."

Read and execute `System/Agents/daily-digest-agent.md` — run every step exactly as the scheduled agent would, using today's live data. This is not a simulation.

As it runs, narrate briefly:
- "Pulling your calendar..."
- "Checking emails from the last 24 hours..."
- "Reading your task board..."

When done, show the completed digest output in full. Let them read it.

Then say:
> "This is what you'll get every morning at [digest.time]. It'll be in your inbox and saved here in Brain/Daily/."

---

## Step 4 — Schedule the Daily Digest

Create the scheduled agent that will run this automatically every morning.

```
mcp__scheduled-tasks__create_scheduled_task with:
  - name: "Daily Digest — [Client Name]"
  - schedule: cron expression matching digest.time and digest.timezone
    (e.g. "0 7 * * *" for 7:00 AM — convert digest.time to UTC using digest.timezone)
  - prompt: "Read System/Agents/daily-digest-agent.md and follow the instructions exactly."
  - working_directory: [vault root path]
```

Confirm it was created:
```
mcp__scheduled-tasks__list_scheduled_tasks
```

Say:
> "Scheduled. Your digest will run automatically every morning at [digest.time] [timezone]. You don't have to do anything — it just runs."

If scheduling fails (MCP unavailable, permissions issue, etc.): note it as a follow-up in `Brain/Master.md` — `- [ ] Schedule daily digest agent — /Let's-Go Step 4 failed, retry manually`. Do not let a scheduler failure block the rest of the session.

Update `System/Scheduled_Flows.md` — set Daily Digest status to ✅ running, fill in Last Run as today's date.

---

## Step 4b — Schedule the Weekly Health Report

Create the scheduled agent that emails Andrew every Monday morning.

```
mcp__scheduled-tasks__create_scheduled_task with:
  - name: "Weekly Health Report — [Client Name]"
  - schedule: "0 7 * * 1"  (every Monday at 7:00 AM UTC — adjust for timezone if needed)
  - prompt: "Read System/Agents/weekly-health-report.md and follow the instructions exactly."
  - working_directory: [vault root path]
```

Update `System/Scheduled_Flows.md` — set Weekly Health Report status to ✅ running.

If scheduling fails: add to `Brain/Master.md` under `## Backlog`:
```
- [ ] Schedule weekly health report — /Let's-Go Step 4b failed, retry manually
```

---

## Step 5 — Flag Unconnected Sources

For every service in integrations.yaml with `enabled: false` or an empty `mcp_server`, surface it as a short list:

> "A few things aren't connected yet — we can do these on our next call or you can follow the guides in System/Setup/:"
>
> • [Service] — connect via System/Setup/[guide].md  
> • [Service] — connect via System/Setup/[guide].md  

Add each unconnected service as a task in `Brain/Master.md` under `## Backlog`:
```
- [ ] Connect [Service] — see System/Setup/[guide].md
```

---

## Step 6 — Save to Brain/Daily/

The digest from Step 3 should already be saved (the agent does this in its Step 7). Confirm the file exists:

```
Brain/Daily/[today's date].md
```

If it doesn't exist (agent skipped the save), write it now from the digest output produced in Step 3.

---

## Step 7 — Close

Say:

> "Your system is live and running.
>
> Every morning at [time]: your digest arrives in your inbox. Calendar, tasks, emails, priorities — everything in one place, ready before your first meeting.
>
> From now on, open Claude Code in this folder whenever you want to work with the system. Run `/daily` for your morning planning session. Run `/wrap` when you finish a project. Use `/capture` to log anything on the fly.
>
> The system gets smarter every session. Every email updates your contacts automatically. Every correction becomes a permanent rule. It compounds."

Run `/wrap` to close out Session 1.
