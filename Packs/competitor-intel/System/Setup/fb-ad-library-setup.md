# Facebook Ad Library API — Setup Guide

The Ad Library API is free and official. It gives you access to all active ads running on Facebook and Instagram for any advertiser. No spend required on your end.

**Time to set up: ~10 minutes**

---

## Step 1 — Create a Facebook Developer Account

1. Go to [developers.facebook.com](https://developers.facebook.com)
2. Click **Get Started** (top right)
3. Log in with your Facebook account (personal account is fine)
4. Complete the developer registration — select "Build connected experiences" when asked

---

## Step 2 — Create an App

1. From the developer dashboard, click **Create App**
2. Choose **Other** as the use case → click Next
3. Choose **Business** as the app type → click Next
4. Give it a name (e.g. "Stein Competitor Intel") and your email
5. Click **Create App**

---

## Step 3 — Get a User Access Token

The Ad Library API uses a User Access Token (not an app token).

1. In your app dashboard, go to **Tools → Graph API Explorer**
2. In the top-right dropdown, select your app
3. Click **Generate Access Token** → log in with Facebook when prompted → grant permissions
4. Copy the token shown — it looks like `EAABs...` (long string)

**Important:** The default token expires in ~1-2 hours. For automated use, you need a long-lived token:

```bash
# Exchange short-lived token for long-lived (60-day) token
curl -s "https://graph.facebook.com/v19.0/oauth/access_token" \
  -d "grant_type=fb_exchange_token" \
  -d "client_id=YOUR_APP_ID" \
  -d "client_secret=YOUR_APP_SECRET" \
  -d "fb_exchange_token=YOUR_SHORT_TOKEN"
```

Your App ID and App Secret are in your app dashboard under **Settings → Basic**.

The response gives you a long-lived token. Use this one.

---

## Step 4 — Verify Ad Library Access

Test that your token can access the Ad Library:

```bash
curl -s "https://graph.facebook.com/v19.0/ads_archive?search_terms=apple&ad_reached_countries=['US']&ad_type=ALL&limit=3&access_token=YOUR_TOKEN"
```

You should get back a JSON response with `data` containing ads. If you get an error about permissions, make sure your Facebook account is in good standing (no restrictions).

---

## Step 5 — Save to ~/.secrets

```bash
echo 'FB_AD_LIBRARY_TOKEN="YOUR_LONG_LIVED_TOKEN"' >> ~/.secrets
```

Verify it's there:
```bash
grep 'FB_AD_LIBRARY_TOKEN' ~/.secrets
```

---

## Step 6 — Update INDEX.md

Open `Intelligence/Competitors/INDEX.md` and update the API Key Status table:

```
| Facebook Ad Library | `~/.secrets` → `FB_AD_LIBRARY_TOKEN` | ✅ configured |
```

---

## Token Refresh

Long-lived tokens last ~60 days and auto-refresh if used regularly. If the token expires (you'll get a `190` error from the API), repeat Steps 3-5 to get a new one.

A future improvement is automating the refresh — for now, refresh manually when needed.

---

## Troubleshooting

**Error: `(#200) The user hasn't authorized the application`**
→ Re-generate the token in Graph API Explorer and make sure you're selecting the right app.

**Error: `(#190) Invalid OAuth access token`**
→ Token has expired. Re-generate and re-save to `~/.secrets`.

**No ads returned for a competitor**
→ They may not be running Facebook/Instagram ads, or they're running under a different page name. Try their exact Facebook page name as the `search_terms` value.
