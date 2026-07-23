# System/Agents/

Prompt files for scheduled cloud agents. Each file is a self-contained set of instructions that a Claude Code scheduled agent runs on a cron.

The scheduled task points here. Edit the file to change what the agent does — no need to touch the scheduler.

## Agents

| File | What it does | Schedule |
|---|---|---|
| `daily-digest-agent.md` | Morning digest — calendar, tasks, email, Slack → email + Brain/Daily/ | Daily at client's chosen time |
