---
name: competitor
description: Competitor intelligence — monitors a competitor's full marketing stack (website, ads, social, content, people, jobs) and synthesizes findings into structured intelligence files. Run /competitor for all active competitors, /competitor [name] for one, /competitor --profile [name] for the initial deep-build on a new competitor.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - WebFetch
  - WebSearch
---

# /competitor — Competitor Intelligence

Monitors competitors' full marketing stack and maintains structured intelligence files. Two modes:
- **Weekly scan** — diffs against existing files, appends Change_Log, updates what changed
- **Initial profile build** (`--profile`) — deep first pass, writes all files from scratch

**Non-interactive.** Never stop to ask questions. If a source is unavailable or an API key is missing, log it and continue.

---

## Arguments

```
/competitor                    → weekly scan, all active competitors
/competitor [name]             → weekly scan, one competitor (partial name match)
/competitor --profile [name]   → initial deep profile build for a new competitor
/competitor setup              → print API setup guide paths and key status
```

Arguments are in `$ARGUMENTS`.

---

## Step 0 — Parse Arguments & Load Config

```bash
INTEL_DIR="Intelligence/Competitors"
INDEX="$INTEL_DIR/INDEX.md"
WEEKLY_DIR="Intelligence/Weekly"
TODAY=$(date +%Y-%m-%d)
```

Read `Intelligence/Competitors/INDEX.md`. Extract:
- List of active competitors (name, folder, url, tracked_people, sources config)
- API key status table

Check which API keys are available:
```bash
FB_TOKEN=$(grep 'FB_AD_LIBRARY_TOKEN' ~/.secrets 2>/dev/null | cut -d'=' -f2 | tr -d ' "')
YT_KEY=$(grep 'YOUTUBE_API_KEY' ~/.secrets 2>/dev/null | cut -d'=' -f2 | tr -d ' "')
APIFY_TOKEN=$(grep 'APIFY_API_TOKEN' ~/.secrets 2>/dev/null | cut -d'=' -f2 | tr -d ' "')
```

If `/competitor setup` was passed: print the paths to `System/Setup/fb-ad-library-setup.md` and `System/Setup/youtube-api-setup.md`, show the API key status table from INDEX.md, then stop.

Determine mode:
- `--profile [name]` → INITIAL_BUILD=true, TARGET=[name]
- `[name]` (no flag) → INITIAL_BUILD=false, TARGET=[name]
- no args → INITIAL_BUILD=false, TARGET=all

Filter competitor list to TARGET. If no match, report and stop.

---

## Step 1 — Load Existing Context (Weekly Scan Only)

For each competitor being scanned, read existing files to understand current state:
- `[folder]/Profile.md`
- `[folder]/Positioning.md`
- `[folder]/Ads.md`
- `[folder]/Jobs.md`
- `[folder]/Change_Log.md` (last entry only — for diff context)

This is the baseline. Every finding in subsequent steps is compared against it.

Skip this step for initial profile builds (no existing files to read).

---

## Step 2 — Website

WebFetch each of these pages (skip gracefully if 404):
- `[url]/` — homepage
- `[url]/services` or `/solutions` or `/what-we-do`
- `[url]/about` or `/team`
- `[url]/blog` or `/insights` or `/resources`
- `[url]/case-studies` or `/clients` or `/work`
- `[url]/pricing`

For each page, extract:
- **Homepage:** hero headline, sub-headline, primary CTA, stated ICP signals, big promise language
- **Services/Solutions:** offer names, descriptions, how they're packaged, any visible pricing
- **About:** key people mentioned, founding story, company positioning language
- **Blog:** post titles and dates (last 5) — content themes, what topics they're covering
- **Case studies:** client names/industries, outcomes claimed, social proof language
- **Pricing:** any visible pricing, packaging names, model (subscription/project/retainer)

**Diff check (weekly scan):** Note anything that wasn't in the existing Profile.md or Positioning.md. Flag as NEW.

---

## Step 3 — Facebook & Instagram Ads

Skip this step if `FB_TOKEN` is empty. Log: `[FB Ads] Skipped — FB_AD_LIBRARY_TOKEN not configured. See System/Setup/fb-ad-library-setup.md`

```bash
curl -s "https://graph.facebook.com/v19.0/ads_archive" \
  -d "search_terms=[FB_AD_SEARCH_TERM]" \
  -d "ad_reached_countries=['US']" \
  -d "ad_type=ALL" \
  -d "limit=25" \
  -d "fields=id,ad_creative_bodies,ad_creative_link_captions,ad_creative_link_descriptions,ad_creative_link_titles,ad_delivery_start_time,ad_delivery_stop_time,page_name,spend" \
  -d "access_token=$FB_TOKEN" \
  -o /tmp/fb_ads.json 2>/dev/null

python3 -c "
import json
data = json.load(open('/tmp/fb_ads.json'))
ads = data.get('data', [])
print(f'TOTAL ADS: {len(ads)}')
for ad in ads:
    print('---')
    print(f'ID: {ad.get(\"id\")}')
    print(f'START: {ad.get(\"ad_delivery_start_time\",\"unknown\")}')
    print(f'STOP: {ad.get(\"ad_delivery_stop_time\",\"still running\")}')
    bodies = ad.get('ad_creative_bodies', [])
    print(f'BODY: {bodies[0][:300] if bodies else \"no body\"}')
    titles = ad.get('ad_creative_link_titles', [])
    print(f'TITLE: {titles[0] if titles else \"no title\"}')
    captions = ad.get('ad_creative_link_captions', [])
    print(f'CAPTION: {captions[0] if captions else \"no caption\"}')
" 2>/dev/null
```

For each ad, extract:
- Opening hook (first sentence of body copy)
- Angle (what pain/desire it targets)
- CTA (link title or caption)
- Start date → calculate weeks running
- Stop date (still running vs. ended)

**Longevity rule:** Any ad running > 2 weeks = it's working. Flag these.
**Diff check:** Note any ads not in existing Ads.md (new) and any previously tracked ads now absent (stopped).

---

## Step 4 — YouTube

Skip this step if `YT_KEY` is empty. Log: `[YouTube] Skipped — YOUTUBE_API_KEY not configured. See System/Setup/youtube-api-setup.md`

Search for YouTube channels for **both the company and each tracked person by name** — do not rely only on pre-configured handles. People often have personal channels separate from the company channel, and handles may not be known in advance.

For each search target — the company name AND each tracked person's full name — run a channel search:

```bash
# Search for channel by name to get channel ID
curl -s "https://www.googleapis.com/youtube/v3/search?part=snippet&q=[CHANNEL_NAME]&type=channel&key=$YT_KEY" \
  -o /tmp/yt_channel.json 2>/dev/null

# Get recent videos from channel
CHANNEL_ID=$(python3 -c "import json; data=json.load(open('/tmp/yt_channel.json')); items=data.get('items',[]); print(items[0]['id']['channelId'] if items else '')" 2>/dev/null)

if [ -n "$CHANNEL_ID" ]; then
  curl -s "https://www.googleapis.com/youtube/v3/search?part=snippet&channelId=$CHANNEL_ID&order=date&maxResults=10&type=video&key=$YT_KEY" \
    -o /tmp/yt_videos.json 2>/dev/null

  python3 -c "
import json
data = json.load(open('/tmp/yt_videos.json'))
for item in data.get('items', []):
    s = item['snippet']
    print(f'TITLE: {s[\"title\"]}')
    print(f'DATE: {s[\"publishedAt\"][:10]}')
    print(f'DESC: {s[\"description\"][:200]}')
    print(f'VIDEO_ID: {item[\"id\"][\"videoId\"]}')
    print('---')
  " 2>/dev/null

  # Get top comments from most recent video
  VIDEO_ID=$(python3 -c "import json; data=json.load(open('/tmp/yt_videos.json')); items=data.get('items',[]); print(items[0]['id']['videoId'] if items else '')" 2>/dev/null)
  if [ -n "$VIDEO_ID" ]; then
    curl -s "https://www.googleapis.com/youtube/v3/commentThreads?part=snippet&videoId=$VIDEO_ID&order=relevance&maxResults=20&key=$YT_KEY" \
      -o /tmp/yt_comments.json 2>/dev/null
    python3 -c "
import json
data = json.load(open('/tmp/yt_comments.json'))
for item in data.get('items', []):
    c = item['snippet']['topLevelComment']['snippet']
    print(f'COMMENT: {c[\"textDisplay\"][:200]}')
    print(f'LIKES: {c[\"likeCount\"]}')
    print('---')
    " 2>/dev/null
  fi
fi
```

Extract:
- Video titles + dates (content themes, cadence)
- Description hooks (how they open each video)
- Top comments (what questions/pain points viewers express — ICP signal)
- View counts if visible (what content gets traction)

---

## Step 5 — Blog & News

**Blog:** WebFetch the blog/insights page. Extract the last 5-10 post titles and dates. Note themes and any new posts since last scan.

**News & events:**
```
WebSearch: "[company name]" announcement OR press OR news — last 30 days
WebSearch: "[person name 1]" OR "[person name 2]" podcast OR speaking OR conference 2026
```

Extract: announcements, partnerships, press mentions, conference appearances (ICP signal), podcast appearances.

---

## Step 6 — Apify: LinkedIn + X Posts

Skip this entire step if `APIFY_TOKEN` is empty. Log: `[LinkedIn/X] Skipped — APIFY_API_TOKEN not configured. LinkedIn and X post tracking requires Apify. See Intelligence/Competitors/INDEX.md for setup.`

For each tracked person:

**LinkedIn posts:**
```bash
curl -s -X POST "https://api.apify.com/v2/acts/apify~linkedin-profile-scraper/run-sync-get-dataset-items?token=$APIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"profileUrls\": [\"[LINKEDIN_URL]\"], \"maxPosts\": 10}" \
  -o /tmp/li_posts_[name].json 2>/dev/null

python3 -c "
import json
data = json.load(open('/tmp/li_posts_[name].json'))
posts = data if isinstance(data, list) else data.get('posts', [])
for p in posts[:10]:
    print(f'DATE: {p.get(\"date\",\"unknown\")}')
    print(f'TEXT: {str(p.get(\"text\",\"\"))[:400]}')
    likes = p.get('likes', p.get('likesCount', 0))
    comments = p.get('comments', p.get('commentsCount', 0))
    print(f'ENGAGEMENT: {likes} likes, {comments} comments')
    # Extract commenters for Engagers.md
    for c in p.get('topComments', []):
        print(f'COMMENTER: {c.get(\"author\",\"\")} | {c.get(\"authorUrl\",\"\")} | {c.get(\"authorTitle\",\"\")}')
    print('---')
" 2>/dev/null
```

**X/Twitter posts:**
```bash
curl -s -X POST "https://api.apify.com/v2/acts/apify~twitter-scraper/run-sync-get-dataset-items?token=$APIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"handles\": [\"[X_HANDLE]\"], \"maxItems\": 20, \"mode\": \"user\"}" \
  -o /tmp/x_posts_[name].json 2>/dev/null

python3 -c "
import json
data = json.load(open('/tmp/x_posts_[name].json'))
for t in data[:20]:
    print(f'DATE: {t.get(\"createdAt\",\"unknown\")}')
    print(f'TEXT: {t.get(\"fullText\",\"\")[:400]}')
    print(f'LIKES: {t.get(\"likeCount\",0)} | RT: {t.get(\"retweetCount\",0)} | REPLIES: {t.get(\"replyCount\",0)}')
    # Replies = engagers
    for r in t.get('replies', []):
        print(f'REPLIER: {r.get(\"author\",\"\")} | {r.get(\"authorUrl\",\"\")} | {r.get(\"authorTitle\",\"\")}')
    print('---')
" 2>/dev/null
```

**LinkedIn company page:**
```bash
curl -s -X POST "https://api.apify.com/v2/acts/apify~linkedin-company-scraper/run-sync-get-dataset-items?token=$APIFY_TOKEN" \
  -H "Content-Type: application/json" \
  -d "{\"companyUrls\": [\"[COMPANY_LINKEDIN_URL]\"], \"maxPosts\": 10}" \
  -o /tmp/li_company.json 2>/dev/null
```

For all posts collected, extract:
- Topics and themes being covered
- Hook patterns (opening lines)
- Engagement levels (what's resonating)
- Mentions of offers, CTAs, pain points
- Key quotes worth tracking

**Engager collection (automated):** From LinkedIn comments and X replies, extract:
- Commenter/replier name
- Profile URL
- Job title/headline (if available)
- Company (if available)
- Which post they engaged on
- Date

Deduplicate against existing Engagers.md (by profile URL). Append new entries only.

---

## Step 7 — Job Postings

```
WebSearch: [company name] jobs site:linkedin.com/jobs OR site:[company-url]/careers
```

Also WebFetch `[url]/careers` or `[url]/jobs` if it exists.

Extract: role titles, departments, seniority levels, date posted. For each new role, note the strategic signal (e.g. "First VP Sales hire = building a sales team", "Hiring ML engineers = product investment").

---

## Step 8 — Synthesize

This is the intelligence step — not a data dump. For each competitor:

**Read everything collected in Steps 2-7.** Then answer:

1. **What's their current offer and how is it packaged?**
2. **What's the big promise — the transformation they lead with?**
3. **Who do they position as the enemy?**
4. **What unique mechanism or proprietary frame do they claim?**
5. **Who is their actual target audience?** (inferred from post engagement, ad copy language, case study clients, event appearances — not just what the website says)
6. **What pain points are they consistently activating?**
7. **How does the funnel work?** TOF → MOF → BOF — what's the path from attention to close?
8. **What's working?** (longest-running ads, highest-engagement content)
9. **What changed this week?** (diff against prior state — weekly scan only)
10. **What does this tell us about their strategy?** (1-2 sentence read)

Hold all findings. Proceed to Step 9.

---

## Step 9 — Write / Update Files

### Initial Profile Build

Write all files from scratch using the templates. Replace every `[Not yet observed]` with real findings or leave it only if genuinely not observed (note the source gap in Open Questions).

- `Profile.md` — company facts, key people, stated ICP, notable clients
- `Positioning.md` — full marketing breakdown from synthesis
- `Ads.md` — all active ads found
- `Jobs.md` — all open roles found
- For each tracked person: `People/[First-Last].md` (copy from `_template/People/_template.md`)
- `Engagers.md` — engager pool from post data
- `Change_Log.md` — initial entry

### Weekly Scan

Update files in place — only change what actually changed:
- `Positioning.md` — update sections where findings differ from existing content
- `Ads.md` — add new ads, mark stopped ads as inactive
- `Jobs.md` — add new roles, note filled roles
- `People/[name].md` — add new Recent Highlights entries, update content profile if patterns changed
- `Engagers.md` — append new engagers (deduplicated by profile URL)

Append to `Change_Log.md`:
```markdown
## [TODAY] — Weekly Scan
*Sources active this run: [list active sources, note any skipped and why]*

### What Changed
- **[Category]** — [specific change]

### New This Week
- [new ad / post / job / case study / announcement]

### Signal
[1-2 sentence read: what do this week's changes indicate about their strategy?]
```

---

## Step 10 — Update INDEX.md

Update the competitor's row in the scan log table:
- Last scanned: TODAY
- What changed: 1-line summary

---

## Step 11 — Weekly Digest

Save `Intelligence/Weekly/[TODAY].md`:

```markdown
# Competitor Intelligence — [DATE]
*[N] competitor(s) scanned · Sources: [list]*

## Summary
[2-3 sentences: overall signal level this week and the single most notable finding across all competitors.]

## [Competitor Name]

### What Changed
[Bulleted list — specific changes found this scan]

### Most Notable
[The single most strategically significant finding — an offer change, a new angle being tested, a new hire signal, a major ad shift]

### Signal Read
[1-2 sentences: what does this week's pattern tell you about where they're headed?]

---
[Repeat block for each competitor scanned]

## Action Items
- [ ] [Anything worth acting on — e.g. "Their new CFO-targeting angle overlaps with our positioning — revisit our ICP language"]
```

---

## Step 12 — Chat Output (5 lines max)

```
Competitor scan complete — [DATE]

[Competitor name]: [1-line most notable finding]
[If multiple competitors, one line each]
Sources active: [list] · Skipped: [list with reason]

Saved: Intelligence/Weekly/[DATE].md · All competitor files updated
```

---

## What NOT to Do

- Don't dump raw data — synthesize. Every finding gets interpretation: what does it mean?
- Don't mark an API source as failed silently — always log what was skipped and why
- Don't rewrite sections of Positioning.md that haven't changed — only update what's new
- Don't include engagers from the company's own employees in Engagers.md — filter obvious internal accounts
- Don't invent findings — if something is not observed, say "Not yet observed" and note the source gap
- Don't stop to ask questions — run with what's available and note gaps in the digest
