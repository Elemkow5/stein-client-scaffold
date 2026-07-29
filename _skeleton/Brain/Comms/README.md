# Comms
Staging files for external channel queues used by the Communications Hub module.

Currently used by LinkedIn DMs only — written by Make.com scenario, read by `/comms-triage`.

**Files:**
- `LinkedIn_Queue.md` — LinkedIn DM staging queue (auto-populated by Make.com)

**Format (LinkedIn_Queue.md):**
`- [YYYY-MM-DD HH:MM] **[Sender Name]:** [message text] [triaged YYYY-MM-DD]`

The `[triaged YYYY-MM-DD]` tag is appended by `/comms-triage` after processing. Entries without this tag are treated as unread.
