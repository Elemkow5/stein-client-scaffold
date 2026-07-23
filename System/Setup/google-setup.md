# Google Workspace Setup

Run this before the first /setup session with a Google client.
Takes ~15 minutes. Client needs a Google account — Workspace or personal Gmail both work.

---

## What Gets Connected

| Service | MCP Server | What it enables |
|---|---|---|
| Google Calendar | Google Calendar MCP | /planning pulls today's events; /goal creates milestone calendar events |
| Gmail | Gmail MCP | /planning daily mode surfaces flagged emails; /inbox can process email captures |
| Google Drive | Google Drive MCP | File search, doc creation, /gdoc uploads (if using content pipeline module) |

---

## Step 1 — Install Claude Code on Client Machine

1. Download from claude.ai/download
2. Install and sign in with the client's Anthropic account (or create one)
3. Confirm Claude Code opens in terminal: `claude --version`

---

## Step 2 — Install Google MCPs

In Claude Code, open settings and add these MCP servers. The easiest path is the Claude Code MCP marketplace (if available) or manual config.

**Manual config** — add to `~/.claude/claude_desktop_config.json` (or equivalent):

```json
{
  "mcpServers": {
    "google-calendar": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-google-calendar"],
      "env": {
        "GOOGLE_CLIENT_ID": "[from Step 3]",
        "GOOGLE_CLIENT_SECRET": "[from Step 3]",
        "GOOGLE_REFRESH_TOKEN": "[from Step 3]"
      }
    },
    "gmail": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gmail"],
      "env": {
        "GOOGLE_CLIENT_ID": "[from Step 3]",
        "GOOGLE_CLIENT_SECRET": "[from Step 3]",
        "GOOGLE_REFRESH_TOKEN": "[from Step 3]"
      }
    },
    "google-drive": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-gdrive"],
      "env": {
        "GOOGLE_CLIENT_ID": "[from Step 3]",
        "GOOGLE_CLIENT_SECRET": "[from Step 3]",
        "GOOGLE_REFRESH_TOKEN": "[from Step 3]"
      }
    }
  }
}
```

---

## Step 3 — Get Google OAuth Credentials

1. Go to console.cloud.google.com
2. Create a new project (or use an existing one)
3. Enable these APIs: Google Calendar API, Gmail API, Google Drive API
4. Go to Credentials → Create OAuth 2.0 Client ID → Desktop App
5. Download the credentials JSON
6. Run the auth flow to get a refresh token:
   ```bash
   npx @modelcontextprotocol/server-google-calendar --auth
   ```
   (Follow the browser prompt — same token works for all three MCPs)
7. Copy the `client_id`, `client_secret`, and `refresh_token` into the config above

---

## Step 4 — Update integrations.yaml

After connecting, fill in the `mcp_server` fields in `System/integrations.yaml`:

```yaml
platform: google

services:
  calendar:
    enabled: true
    provider: google_calendar
    mcp_server: google-calendar   # the key name from claude_desktop_config.json
  email:
    enabled: true
    provider: gmail
    mcp_server: gmail
  files:
    enabled: true
    provider: google_drive
    mcp_server: google-drive
```

---

## Step 5 — Verify

Open Claude Code in the client's vault and run:

```
/planning
> daily
```

The daily brief should pull today's calendar events. If it does — Google is connected. If it fails, check that the MCP server names in `claude_desktop_config.json` match what's in `integrations.yaml`.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| "MCP server not found" | Server name in integrations.yaml doesn't match config key |
| "Authentication failed" | Refresh token expired — rerun `--auth` flow |
| Calendar shows no events | Check that the correct Google account is authorized |
| Drive won't list files | Confirm Google Drive API is enabled in Google Cloud Console |
