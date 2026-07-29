# Microsoft 365 Setup

Run this before the first /setup session with a Microsoft client.
Requires a Microsoft 365 account (Business Basic or higher recommended).

> ⚠️ **Note:** The Microsoft path has not yet been tested with a real client.
> Verify each step works before running with a client in the room.
> Update this doc with any corrections found during the first real deployment.

---

## What Gets Connected

| Service | Via | What it enables |
|---|---|---|
| Outlook Calendar | Microsoft 365 MCP Connector | /checkin pulls today's events; /goal creates milestone events |
| Outlook Email | Microsoft 365 MCP Connector | /checkin daily mode surfaces flagged emails |
| OneDrive / SharePoint | Microsoft 365 MCP Connector | File search and document access |

All three services run through a single Microsoft 365 MCP Connector — one auth flow covers everything.

---

## Step 1 — Install Claude Code on Client Machine

1. Download from claude.ai/download
2. Install and sign in with the client's Anthropic account
3. Confirm: `claude --version`

---

## Step 2 — Install the Microsoft 365 MCP Connector

Check the Claude Code MCP marketplace for the current Microsoft 365 connector.

**If available via marketplace:** install directly from the MCP settings panel.

**Manual config** — add to `~/.claude/claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "microsoft-m365": {
      "command": "npx",
      "args": ["-y", "@microsoft/mcp-server-m365"],
      "env": {
        "AZURE_CLIENT_ID": "[from Step 3]",
        "AZURE_TENANT_ID": "[from Step 3]",
        "AZURE_CLIENT_SECRET": "[from Step 3]"
      }
    }
  }
}
```

> Note: The exact package name may vary. Search `@microsoft mcp` on npm for the current official package.

---

## Step 3 — Register an Azure App

1. Go to portal.azure.com → Azure Active Directory → App Registrations → New Registration
2. Name: "Client AI System" (or client's preferred name)
3. Supported account types: "Accounts in this organizational directory only"
4. Redirect URI: leave blank for now
5. Register

6. After registration, go to **API Permissions** → Add a permission → Microsoft Graph:
   - `Calendars.ReadWrite`
   - `Mail.ReadWrite`
   - `Files.ReadWrite`
   - `User.Read`
7. Grant admin consent

8. Go to **Certificates & Secrets** → New client secret → copy the value immediately (shown once)

9. From the app Overview page, copy:
   - Application (client) ID → `AZURE_CLIENT_ID`
   - Directory (tenant) ID → `AZURE_TENANT_ID`
   - Client secret value → `AZURE_CLIENT_SECRET`

---

## Step 4 — Update integrations.yaml

```yaml
platform: microsoft

services:
  calendar:
    enabled: true
    provider: microsoft_m365
    mcp_server: microsoft-m365
  email:
    enabled: true
    provider: microsoft_m365
    mcp_server: microsoft-m365
  files:
    enabled: true
    provider: microsoft_m365
    mcp_server: microsoft-m365
```

---

## Step 5 — Verify

Open Claude Code in the client's vault and run:

```
/checkin
> daily
```

The daily brief should pull today's Outlook calendar events. If it does — Microsoft is connected.

---

## Troubleshooting

| Symptom | Fix |
|---|---|
| "MCP server not found" | Package not installed or wrong name — check npm |
| "Unauthorized" | Admin consent not granted — revisit Step 3 API Permissions |
| Calendar empty | Confirm `Calendars.ReadWrite` permission is granted and consented |
| Tenant error | AZURE_TENANT_ID is wrong — re-copy from Azure portal |

---

## Known Gaps (as of first build)

- Microsoft MCP package name and exact tool names TBD — verify on first real client
- SharePoint vs OneDrive routing may require additional config for some orgs
- Large orgs with conditional access policies may need IT involvement for app registration
