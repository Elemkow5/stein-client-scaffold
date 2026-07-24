# Google Workspace Setup

Run this before the first /setup session with a Google client.
Takes ~5 minutes via Claude Desktop connectors.

---

## Platform Note

This guide uses Claude Desktop's built-in Connectors — a UI-based flow requiring no API keys, no terminal, and no Google Cloud Console. If you ever move off Claude to a different LLM or platform, use the Manual MCP Setup section at the bottom instead.

---

## What Gets Connected

| Service | What it enables |
|---|---|
| Google Calendar | /daily pulls today's meetings and attendees |
| Gmail | Emails from known contacts update People files; /daily surfaces overnight emails from today's attendees |
| Google Drive | File search, doc creation, content pipeline (if Module 1 installed) |

---

## Step 1 — Open Claude Desktop on Client's Machine

Open Claude Desktop (the Mac or Windows app — not the web). Make sure you're in the client's vault folder.

---

## Step 2 — Connect Google Services

1. Click the **+** button at the bottom of the chat input
2. Select **Connectors**
3. Find **Google Calendar** → click **Connect**
4. Standard "Sign in with Google" flow — client logs in with their Google account and grants access
5. Repeat for **Gmail** and **Google Drive**

No API keys. No terminal. No OAuth setup.

---

## Step 3 — Update integrations.yaml

The connectors are live but the vault's config file doesn't know that yet. Open `System/integrations.yaml` and update:

```yaml
platform: google

services:
  calendar:
    enabled: true
    provider: google_calendar
    connection: claude_desktop_connector
  email:
    enabled: true
    provider: gmail
    connection: claude_desktop_connector
  files:
    enabled: true
    provider: google_drive
    connection: claude_desktop_connector
```

---

## Step 4 — Verify

Ask Claude:

> "What's on my calendar today?"

Should return actual calendar events. If it does — Google is connected.

---

## What to Ask During /setup

When the interview reaches integrations:
- Do you use Google or Microsoft for email and calendar?
- Do you use Slack?

Connect whichever they use. Slack is in Connectors the same way — click +, find Slack, Connect.

---

## Manual MCP Setup (Non-Claude Platforms)

If you ever move to a platform that supports MCP but doesn't have a built-in connector UI, here's the manual path:

**1. Add to the platform's MCP config file:**
```json
{
  "mcpServers": {
    "google-calendar": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-google-calendar"],
      "env": {
        "GOOGLE_CLIENT_ID": "[from Google Cloud Console]",
        "GOOGLE_CLIENT_SECRET": "[from Google Cloud Console]",
        "GOOGLE_REFRESH_TOKEN": "[from auth flow]"
      }
    },
    "gmail": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gmail"],
      "env": {
        "GOOGLE_CLIENT_ID": "[same]",
        "GOOGLE_CLIENT_SECRET": "[same]",
        "GOOGLE_REFRESH_TOKEN": "[same]"
      }
    },
    "google-drive": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gdrive"],
      "env": {
        "GOOGLE_CLIENT_ID": "[same]",
        "GOOGLE_CLIENT_SECRET": "[same]",
        "GOOGLE_REFRESH_TOKEN": "[same]"
      }
    }
  }
}
```

**2. Get credentials:**
- console.cloud.google.com → new project → enable Calendar/Gmail/Drive APIs
- Credentials → OAuth 2.0 Client ID → Desktop App → download JSON
- Run `npx @modelcontextprotocol/server-google-calendar --auth` to get refresh token

**3. Update integrations.yaml** — change `connection: claude_desktop_connector` to `connection: manual_mcp`
