# Competitor Intelligence — Index & Config
*Read by /competitor at runtime. Edit this file to add/remove competitors or toggle sources.*

---

## Active Competitors

| Competitor | Folder | URL | Status | Last scanned | What changed |
|---|---|---|---|---|---|
| [Company Name] | `Competitors/[Folder]/` | [URL] | active | — | Not yet scanned |

---

## Competitor Config

Each competitor block defines what to track. Copy and fill in for each competitor.

```yaml
# competitors:
#   - name: "Company Name"
#     folder: "Company-Name"          # matches folder name under Competitors/
#     url: "https://example.com"
#     youtube_channel_id: ""          # leave blank if not tracked
#     fb_ad_search_term: "Company Name"  # used for Ad Library search
#     tracked_people:
#       - name: "Full Name"
#         role: "CEO"
#         linkedin_url: "https://linkedin.com/in/handle"
#         x_handle: "@handle"
#         youtube_handle: ""          # leave blank if not active
#     sources:
#       website: true
#       fb_ads: true
#       youtube: true
#       blog: true
#       news: true
#       linkedin_apify: false         # set true once Apify key is configured
#       twitter_apify: false          # set true once Apify key is configured
#       jobs: true
#     scan_frequency: "biweekly"     # biweekly | weekly
#     status: "active"               # active | paused
```

---

## API Key Status

| Service | Key location | Status |
|---|---|---|
| Facebook Ad Library | `~/.secrets` → `FB_AD_LIBRARY_TOKEN` | ⬜ not configured |
| YouTube Data API | `~/.secrets` → `YOUTUBE_API_KEY` | ⬜ not configured |
| Apify | `~/.secrets` → `APIFY_API_TOKEN` | ⬜ not configured |

*Run `/competitor setup` to see setup guides for any unconfigured service.*

---

## Scan Log

| Date | Competitors scanned | Sources active | Notes |
|---|---|---|---|
| — | — | — | No scans yet |
