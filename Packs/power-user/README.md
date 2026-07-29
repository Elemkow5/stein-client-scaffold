# Power User Pack
[[Stein for Clients]]

An optional add-on to the base Stein scaffold for clients who have outgrown the base ten commands.

The base layer is deliberately small — ten commands a client can learn in one session. This pack holds the ones that only make sense once the system is genuinely part of how they work: longer sessions, deeper session hygiene, and self-diagnosis.

**Do not install this at onboarding.** Install it when a client asks for it, or when the weekly health report shows they're using the system heavily enough to need it.

---

## What This Pack Adds

| Command | What it does | Who it's for |
|---|---|---|
| `/handoff` | Packages the live session state into a pickup brief for a fresh window | Anyone running long working sessions that outgrow one context window |
| `/continue` | Resumes from a `/handoff` save point | Pairs with `/handoff` — install both or neither |
| `/eod` | End-of-day review — planned vs. done, why anything slipped, runs the Layer 2 audit | Clients who want a closing ritual separate from `/wrap` |
| `/log` | Session-log health check — finds files changed but never logged, writes the missing entries | Clients who care about the completeness of their own record |
| `/kb-audit` | Weekly knowledge-graph check — orphan notes, missing hubs, hubs with no Key Files | Clients with a large vault and a real wikilink graph |
| `/stein-doctor` | Honest state of the setup — what's working, what's stale, what needs attention | Clients who self-serve rather than calling you |

---

## Why These Aren't in the Base Layer

Each one solves a problem a new client doesn't have yet.

`/handoff` and `/continue` matter when a session gets long enough to lose context — that's a heavy-usage problem. `/eod` is a third closing ritual on top of `/wrap` and `/checkin`; offering three ways to end a day to someone still learning their first is how a system stops getting used. `/log` and `/kb-audit` are the system auditing itself — real value, invisible to someone in week one. `/stein-doctor` is a repair tool, and a new client should be calling you when something breaks, not diagnosing it alone.

The base ten tell one story: capture → process → remember → meet → close. Every command here is a second story, and the second story is what makes a system feel like homework.

---

## Prerequisites

- Base scaffold installed and `/setup` completed
- Nothing else — these are all local, no integrations required

---

## How to Install

From the vault root:

```bash
bash Packs/power-user/install.sh .
```

Copies all six skills into `.claude/skills/` and creates `Brain/Handoffs/`. Non-destructive and re-runnable — anything already present is skipped.

Install selectively by copying only what you want:

```bash
cp -r Packs/power-user/.claude/skills/handoff .claude/skills/
cp -r Packs/power-user/.claude/skills/continue .claude/skills/
```

If you install `/handoff`, install `/continue` too — they're a pair and each references the other.

---

## After Installing

Add the new commands to the client's `System/Docs/your-commands.md` so they know the commands exist. The base doc intentionally covers the base ten only.
