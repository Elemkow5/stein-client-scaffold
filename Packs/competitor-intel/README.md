# Competitor Intelligence Pack
[[Stein for Clients]]

An optional add-on to the base Stein scaffold. Monitors competitors' full marketing stack — website, ads, social posts, content, people, job postings — and synthesizes findings into structured intelligence files. Runs bi-weekly on a schedule. Feeds signals into the daily intel brief when something new is found.

---

## What This Pack Adds

| Component | What it does |
|---|---|
| `/competitor` skill | Runs the full intelligence pipeline — collect, synthesize, update files |
| `Intelligence/Competitors/` | Per-competitor files: Profile, Positioning, Change Log, Ads, Jobs, People |
| `Intelligence/Weekly/` | Weekly digest files — one per scan |
| API setup guides | Step-by-step for FB Ad Library + YouTube Data API (both free) |

---

## What It Monitors

| Source | Method | Cost |
|---|---|---|
| Competitor website (key pages) | WebFetch | Free |
| Facebook + Instagram Ads | FB Ad Library API (official) | Free |
| YouTube channel + comments | YouTube Data API v3 | Free |
| Blog / RSS | WebFetch | Free |
| News, press, event appearances | WebSearch | Free |
| LinkedIn posts (tracked people) | Apify | ~$0.25/person/run |
| X/Twitter posts (tracked people) | Apify | ~$0.25/person/run |
| LinkedIn company page | Apify | ~$0.25/run |
| Job postings | WebSearch + Apify | Free / minimal |

**Cost at full capability:** ~$1.50–2/week per competitor with 3 tracked people. Start with free sources only — the skill degrades gracefully when API keys are missing.

---

## Intelligence Files Per Competitor

```
Intelligence/Competitors/[Name]/
  Profile.md        — static facts: what they do, who they serve, team, clients
  Positioning.md    — full marketing breakdown: offer, promise, enemy, unique mechanism,
                      pain points, TOF/MOF/BOF funnel map, ad breakdown, target audience
  Change_Log.md     — dated entries of every change found, newest first
  Ads.md            — FB/IG Ad Library: active ads, hooks, angles, CTAs, longevity
  Jobs.md           — open roles → signals about investment and direction
  People/[Name].md  — per person: post themes, key quotes, recent highlights, content cadence
  Engagers.md       — people who engage with tracked posts (for /prospect-mine)
```

---

## How to Install

Run from the client's vault root:

```bash
bash /path/to/_CLIENT_SCAFFOLD/Packs/competitor-intel/install.sh
```

Or manually:
1. Copy `.claude/skills/competitor/` → client's `.claude/skills/`
2. Copy `Brain/Intelligence/` → client's `Brain/Intelligence/`
3. Copy `System/Setup/` → client's `System/Setup/`
4. Add API key placeholders to client's `~/.secrets`

---

## How to Add a Competitor

1. Open `Intelligence/Competitors/INDEX.md`
2. Add a row to the Active Competitors table
3. Fill in the config block (name, URL, tracked people, sources)
4. Create their folder and copy templates:
   ```bash
   mkdir -p Intelligence/Competitors/[Name]/People
   cp -r Intelligence/Competitors/_template/* Intelligence/Competitors/[Name]/
   ```
5. Run the initial profile build: `/competitor --profile [Name]`

---

## Slash Commands

| Command | What it does |
|---|---|
| `/competitor` | Weekly scan — all active competitors |
| `/competitor [name]` | Weekly scan — one competitor |
| `/competitor --profile [name]` | Initial deep profile build (first run on a new competitor) |
| `/competitor setup` | Show API setup guide paths + key status |

---

## Daily Brief Integration

When the weekly scan runs, it saves a digest to `Intelligence/Weekly/YYYY-MM-DD.md`. The `/intel` skill checks for recent competitor files at the start of each run — if anything was updated in the last 24 hours, a `## Competitor Signals` section appears in the daily brief. On all other days, the section is silently omitted.

---

## Scheduling

Add to the client's scheduled cloud agents (via `/schedule`):

- **Frequency:** Bi-weekly, Monday 6:30 AM (before the 7 AM daily brief)
- **Command:** `/competitor`
- **Notes:** Bi-weekly keeps Apify costs within the free tier for 1-2 competitors

---

## Dependencies

**Free sources (no setup required):** WebFetch, WebSearch — work immediately after install.

**FB Ad Library:** Free. Requires a Facebook Developer account + User Access Token.
→ `System/Setup/fb-ad-library-setup.md`

**YouTube Data API:** Free. Requires a Google Cloud API key.
→ `System/Setup/youtube-api-setup.md`

**Apify:** Required for LinkedIn + X post tracking. Free tier: $5/month compute credit.
→ [apify.com](https://apify.com) → get API token → add to `~/.secrets` as `APIFY_API_TOKEN`

---

## Engager Pool → /prospect-mine

`Engagers.md` per competitor is the data contract for the future `/prospect-mine` skill. The competitor skill collects who engages with tracked people's posts (commenters on LinkedIn, repliers on X). The prospect skill will qualify those people and surface the ones worth reaching out to. The two skills are intentionally separate — competitor intel runs on a schedule, prospect mining runs on demand.
