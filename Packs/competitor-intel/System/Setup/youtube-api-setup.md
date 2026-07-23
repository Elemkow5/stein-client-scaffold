# YouTube Data API — Setup Guide

The YouTube Data API v3 is free. It gives you 10,000 quota units per day — more than enough for bi-weekly competitor scans (a typical scan uses 20-50 units). No billing required for standard use.

**Time to set up: ~10 minutes**

---

## Step 1 — Go to Google Cloud Console

1. Go to [console.cloud.google.com](https://console.cloud.google.com)
2. Sign in with your Google account
3. If prompted, agree to the Terms of Service

---

## Step 2 — Create a Project

1. Click the project dropdown at the top (next to "Google Cloud")
2. Click **New Project**
3. Name it (e.g. "Stein Competitor Intel") → click **Create**
4. Make sure the new project is selected in the dropdown

---

## Step 3 — Enable YouTube Data API v3

1. In the left sidebar, go to **APIs & Services → Library**
2. Search for "YouTube Data API v3"
3. Click on it → click **Enable**

---

## Step 4 — Create an API Key

1. Go to **APIs & Services → Credentials**
2. Click **+ Create Credentials → API key**
3. Your new key is shown immediately — copy it (starts with `AIza...`)
4. Optional but recommended: click **Restrict key** → under "API restrictions" select "YouTube Data API v3" → Save

---

## Step 5 — Verify It Works

```bash
curl -s "https://www.googleapis.com/youtube/v3/search?part=snippet&q=test&type=video&maxResults=1&key=YOUR_API_KEY"
```

You should get back a JSON response with a `items` array. If you get a `403` error, wait 2-3 minutes — new keys sometimes take a moment to activate.

---

## Step 6 — Save to ~/.secrets

```bash
echo 'YOUTUBE_API_KEY="YOUR_API_KEY"' >> ~/.secrets
```

Verify:
```bash
grep 'YOUTUBE_API_KEY' ~/.secrets
```

---

## Step 7 — Update INDEX.md

Open `Intelligence/Competitors/INDEX.md` and update the API Key Status table:

```
| YouTube Data API | `~/.secrets` → `YOUTUBE_API_KEY` | ✅ configured |
```

---

## Quota Notes

Each API call costs quota units:
- Channel search: 100 units
- Video list from channel: 100 units
- Comment threads for a video: 1 unit per page

For one competitor with one YouTube channel, a full scan costs ~200-300 units. At 10,000/day, you can scan ~30-50 competitors per day before hitting the limit. For bi-weekly scans of a handful of competitors, you'll never come close.

If you ever need more quota, you can request an increase in the Google Cloud Console — but you won't need to for normal use.

---

## Troubleshooting

**`quotaExceeded` error**
→ You've hit the 10,000 unit daily limit. Rare for normal use. Resets at midnight Pacific time.

**`keyInvalid` error**
→ Key was just created — wait 2-3 minutes and retry.

**Channel not found for a competitor**
→ Try searching by the person's name or company name directly. The search endpoint handles fuzzy matching well.
