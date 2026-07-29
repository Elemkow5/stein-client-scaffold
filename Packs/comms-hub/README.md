# Communications Hub Pack
[[Stein for Clients]]

Module 15. An optional add-on to the base Stein scaffold for clients who live in their inbox.

Gives the client one place to triage and respond across every channel they use — email, Slack, Teams, and LinkedIn DMs. Instead of context-switching between four inboxes, they run one command and get a single prioritized queue. For anything that needs a reply, the system drafts it in their voice, matched to the tone of the channel. They review, edit, and send manually. **Nothing is ever sent automatically.**

---

## What This Pack Adds

| Component | What it does |
|---|---|
| `/comms-triage` | Pulls unread/flagged messages from every connected channel into one prioritized queue |
| `/comms-reply` | Drafts a reply in the client's voice — reads Personality files for tone, People files for relationship context, project files for background |

---

## Why It's Not in the Base Layer

The base scaffold ships `comms_hub.enabled: false` in `System/integrations.yaml`. Without a configured channel, both commands are inert — they'd appear in the client's command list and do nothing. Shipping them at base meant every client saw two commands that didn't work.

This is Module 15, scoped as an add-on since 2026-07-10. It now installs like one.

---

## Prerequisites

- Base scaffold installed and `/setup` completed
- At least one channel connected — **email is the minimum**
- Slack: Slack MCP connected, `services.slack.mcp_server` set
- Teams: covered by the M365 connector when `platform: microsoft`
- LinkedIn DMs: requires an Apify account + a Make.com scenario running on the client's machine (see `Deployment_Guide.md` → Module: Communications Hub)

---

## How to Install

From the vault root:

```bash
bash Packs/comms-hub/install.sh .
```

The installer copies both skills into `.claude/skills/`, creates `Brain/Comms/`, and enables `comms_hub` in `System/integrations.yaml`. It is non-destructive and re-runnable — anything that already exists is skipped.

After installing, set which channels are on:

```yaml
comms_hub:
  enabled: true
  channels:
    email:
      enabled: true
    slack:
      enabled: true
      channel_whitelist: ["general", "deals"]
```

Then run `/comms-triage` once with the client so they see the queue.

---

## Full Execution Guide

`Projects/AI_Agency/Stein_for_Clients/Execution_Guides/Module-15-Communications-Hub.md` — pre-reqs, MCP setup, first-run test, client training, troubleshooting.
