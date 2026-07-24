---
name: import-setup
description: Reads a pasted pre-interview transcript and builds the full Personality layer — identity file, priorities, working preferences, People files, Goals, Master.md seed, integrations.yaml, and Topic hubs. Replaces the live /setup interview when the client did the pre-interview before the Zoom.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# /import-setup — Build System from Pre-Interview Transcript

Builds the full Personality layer from the client's pre-interview transcript. Run this on the Zoom after deploying the scaffold and connecting integrations — before /lets-go.

**Input:** Pasted pre-interview transcript  
**Output:** All Personality files, Goals, People files, Master.md seeded, integrations.yaml written, Topic hubs created  
**Time:** 5–10 minutes (no live interview needed)

---

## Step 0 — Get the Transcript

Say:

> "Paste the full interview transcript now — the email Scott sent you. Include everything from the opening through the final structured summary."

Wait for the paste. Do not proceed until transcript is in context.

Once pasted, say: "Got it. Extracting everything now — give me a moment."

---

## Step 1 — Extract from Transcript

Read the full transcript carefully. The pre-interview ends with a structured summary — use it as the primary extraction source, then check the conversation itself for any detail, nuance, or specific language the summary might compress.

Extract every field below. If something is genuinely absent from the transcript, mark it `(not captured)` — never infer or invent.

**Identity**
- Full name
- Role / what they do
- How long they've been doing it
- What a great day looks like for them (their words)
- Archetype: Owner/Founder / Senior Executive / Professional/Practitioner / Investor/Dealmaker
- System name they chose (what they're calling their AI OS)

**Active Projects** (each with one-sentence description and current status)

**Priorities** (each with why it matters — their words)

**Key People** (for each: name, role/company, how they connect to the client's work)

**Tech Stack** — go field by field:
- Device: Mac or PC, iPhone or Android
- Core platform: Google or Microsoft
- Video calls
- Team communication / messaging
- Project/task management
- CRM
- Sales tools
- Email marketing
- Social platforms + scheduling tool
- Design tools
- Website platform + analytics
- Accounting + payments
- Scheduling tool
- Automation tools
- AI tools currently used
- Anything else mentioned

**Goals**
- Annual goal (what would make this year a great year)
- Quarterly goal (what would make this quarter a success)

**Workflow signals** (for each, capture their exact words or close paraphrase):
- Biggest time sinks
- What they track manually that should be automatic
- What falls through the cracks most often
- How they manage key relationships
- How they stay current on their market
- What they write/produce most often
- Archetype-specific answers (WD8 questions)
- Dream automation (WD9)

**Working preferences**
- How direct they want the system to be
- What the system should never do
- Anything else about how they work

**Open commitments** (if mentioned — each with: what, to whom, by when)

---

## Step 2 — Ask Three Quick Questions

Before writing files, ask these in one message:

> "Three quick things before I build the files:
>
> 1. **Daily digest time** — what time do you want [Name]'s morning brief delivered? (e.g. 7:30 AM)
> 2. **Timezone** — what timezone? (e.g. America/New_York)
> 3. **Knowledge sources** — did [Name] share any website URLs, LinkedIn, or documents during the interview? Any URLs or files to pull in now?
>
> (If you don't have this yet, I'll note it as a follow-up and we can add it later.)"

Wait for answers. Record:
- `DIGEST_TIME` — e.g. "7:30 AM"
- `TIMEZONE` — e.g. "America/New_York"
- `KNOWLEDGE_SOURCES` — list of URLs or "none for now"
- `SYSTEM_NAME` — from the interview (already extracted in Step 1)
- `CLIENT_FIRST` / `CLIENT_LAST` — from the interview

Then say: "Building everything now."

---

## Step 3 — Write Personality/[Name].md

Create `Personality/[CLIENT_FIRST]_[CLIENT_LAST].md`:

```markdown
# [Full Name]
[Role] — [Industry/Business Type]
*Archetype: [Owner/Founder | Senior Executive | Professional/Practitioner | Investor/Dealmaker]*

## Who I Am
[2–3 sentences from their role, tenure, and what a great day looks like — their words where possible]

## My Projects
[Active projects as a dash list — wikilink each project name to its hub: `- [[ProjectName]] — one-sentence status`]

## My Priorities
[Priority names as a bullet list with why each matters]

## Key People
[Key contacts as a dash list — wikilink each person to their hub: `- [[First Last]] — role, how they connect`]

## How to Work With Me
[From working preferences — directness level, what not to do, other notes]

## What I'm Trying to Build
[Annual and quarterly goals — their words]

## Workflow Signals
[Brief notes on: biggest time sinks, what falls through the cracks, dream automation — their words]
```

---

## Step 4 — Write Personality/Priorities.yaml

Create `Personality/Priorities.yaml`:

```yaml
priorities:
  - name: [Priority 1 name]
    why: "[Why it matters — their words]"
    priority: 1

  - name: [Priority 2 name]
    why: "[Why it matters — their words]"
    priority: 2

  # Add more as captured
```

---

## Step 5 — Write Personality/Working_Preferences.md

Create `Personality/Working_Preferences.md`:

```markdown
# Working Preferences

## Communication Style
[Directness level from the interview]

## What Not to Do
[Their answer on what the system should never do]

## Other Preferences
[Anything else they mentioned about how they work]
```

---

## Step 6 — Write Personality/Mistake_Patterns.md

Create `Personality/Mistake_Patterns.md`:

```markdown
# Mistake Patterns

*Corrections and guidance captured over time — updated whenever [Name] says "don't do that" or adjusts an approach.*

(none yet — populated as the system learns)
```

---

## Step 7 — Write Goals/Annual.md and Goals/Quarterly.md

Create `Goals/Annual.md`:

```markdown
# Annual Goals — [Year]

[Their answer to "what would make this year a great year" — their words, not a paraphrase]
```

Create `Goals/Quarterly.md`:

```markdown
# Quarterly Goals — Q[N] [Year]

[Their answer to "what would make this quarter a success" — their words]
```

---

## Step 8 — Create People Files

For each person named in the interview, create `Brain/People/[FirstName]_[LastName].md`. Add a wikilink to their Topic hub at the top so Obsidian backlinks connect the People file to the hub:

```markdown
# [Full Name]
[[First Last]]

**Role:** [Role or relationship type]
**Company:** [Company or context]
**Relationship type:** [client / partner / vendor / colleague / advisor / contact]
**How decisions get made:** (to fill in)

---

## Last Interaction
*Date:* (not yet)
*What was discussed:* (to fill in)
*What's open:* (to fill in)

---

## Notes
[One sentence from the interview on why they matter and how they connect]

---

## Open Items
- [ ] 

---

## Open Commitments
<!-- Format: - [ ] [Due YYYY-MM-DD] What — made YYYY-MM-DD -->
```

Create a file for every person mentioned. If 12 people were listed, create 12 files. Do not skip anyone.

---

## Step 8b — Seed Brain/Commitments.md

If any open commitments were captured in the transcript:

Open `Brain/Commitments.md`. If it doesn't have the table header yet, add it:

```markdown
# Commitments

Running ledger of all commitments made to other people.

| Date Made | To | What | Due | Status |
|---|---|---|---|---|
```

For each commitment, add one row:

| Date Made | To | What | Due | Status |
|---|---|---|---|---|
| [today's date] | [person name] | [what was committed] | [due date or "unknown"] | open |

Also add a matching entry to each person's People file under `## Open Commitments`:
```
- [ ] [Due YYYY-MM-DD] [What] — made [today's date]
```

And add a `## Commitments` section to `Brain/Master.md` with one line per commitment:
```
- [ ] [COMMITMENT: PersonName, YYYY-MM-DD] What
```

If no commitments were mentioned, skip this step.

---

## Step 9 — Seed Brain/Master.md

Open `Brain/Master.md`. Add a project section for each active project. Use `[[wikilinks]]` on every project name so they link to the Topic hubs created in Step 12:

```markdown
## [[ProjectName]]
*[One-sentence description from the interview]*

### This Week
- [ ] (to be set by client on first /daily)

### Tasks
- [ ] (to be set by client on first /daily)

### Backlog

```

Do this for every project mentioned. Keep the master board clean — don't add tasks you don't have data for.

---

## Step 10 — Write System/integrations.yaml

Create `System/integrations.yaml` from the tech stack extracted in Step 1.

```yaml
# ── Device & OS ──────────────────────────────────────────
device:
  computer: [mac | pc | both]
  phone: [iphone | android]

# ── Core platform ────────────────────────────────────────
platform: [google | microsoft]

email:
  provider: [gmail | outlook | other]
  enabled: true
  connection: claude_desktop_connector

calendar:
  provider: [google | outlook | other]
  enabled: true
  connection: claude_desktop_connector

drive:
  provider: [google_drive | onedrive | dropbox | other]
  enabled: true
  connection: claude_desktop_connector

# ── Communication ─────────────────────────────────────────
video:
  provider: [zoom | google_meet | teams | webex | other]
  enabled: false

messaging:
  provider: [slack | teams | discord | none]
  enabled: [true if Slack was connected via Connectors, else false]

# ── Project management ────────────────────────────────────
project_management:
  provider: [notion | asana | monday | clickup | trello | linear | spreadsheet | none]
  enabled: false

# ── CRM & sales ───────────────────────────────────────────
crm:
  provider: [hubspot | salesforce | pipedrive | gohighlevel | none]
  enabled: false

sales_tools:
  - [apollo | instantly | linkedin_sales_nav | none]

# ── Marketing ─────────────────────────────────────────────
email_marketing:
  provider: [mailchimp | kit | beehiiv | substack | none]
  enabled: false

# ── Social media ──────────────────────────────────────────
social:
  platforms:
    - [linkedin | twitter_x | instagram | facebook | tiktok | youtube]
  scheduler: [buffer | hootsuite | later | native | none]

# ── Finance ───────────────────────────────────────────────
accounting:
  provider: [quickbooks | xero | freshbooks | spreadsheets | none]

payments:
  provider: [stripe | paypal | square | invoicing | none]

# ── Scheduling ────────────────────────────────────────────
scheduling:
  provider: [calendly | acuity | email | none]

# ── Automation ────────────────────────────────────────────
automation:
  tools:
    - [zapier | make | n8n | none]

# ── AI tools ──────────────────────────────────────────────
ai_tools:
  - claude
  # add others mentioned

# ── Inbox folder ──────────────────────────────────────────
inbox_folder:
  name: "AI Inbox"
  drive: [google_drive | onedrive | icloud | dropbox]
  local_path: ""  # to set on next call

# ── Daily digest ──────────────────────────────────────────
digest:
  time: "[DIGEST_TIME]"
  timezone: "[TIMEZONE]"
  recipient_email: ""  # ask on first /daily if not provided
```

Fill in every field from the transcript. Use `none` where they don't use that tool. Leave `enabled: false` for anything that exists but isn't connected via Connectors yet.

---

## Step 11 — Create Brain/Business.md

Even without URL scraping, create a placeholder business context file from what the interview captured:

```markdown
# [Client Name]'s Business
*[SYSTEM_NAME]'s foundational knowledge about the business.*

## What We Do
[From the interview — their description of their work in their own language]

## Who We Serve
[From the interview — who their clients/customers are]

## Services & Offerings
[From the interview — what they deliver or sell]

## How We're Different
(to fill in — add website and LinkedIn URLs on next call)

## Results & Proof Points
(to fill in)

## Voice & Language
(to fill in — will be enriched from website/docs)

## Key People
[Named team members or partners mentioned in the interview]

## Online Presence
(to fill in — ask client for website URL and LinkedIn on next call)

## Additional Context
[Market context, competitive notes, or anything else mentioned in the interview]

---
## Sources
*Built from pre-interview transcript — [today's date]*
- Pre-interview transcript — ✅ read
[List any knowledge_sources URLs provided in Step 2 — status: pending scrape]
```

If any knowledge source URLs were provided in Step 2, note them here as `pending scrape` and add a task to Master.md:
```
- [ ] Ingest knowledge sources for [Name] — URLs: [list]
```

---

## Step 12 — Create Topic Hubs

For each active project, create `Brain/Topics/[ProjectName].md`:

```markdown
---
type: topic
created: [today's date]
---

# [Project Name]

[One-paragraph description from the interview — what it is, where it stands, why it matters]

## Key Files
- [[Brain/Master.md]] — project tasks

## Related
[Other projects or people this connects to]
```

For each key person (from People files), create `Brain/Topics/[PersonName].md`:

```markdown
---
type: topic
created: [today's date]
---

# [Person Name]

[Role, company, relationship type, why they matter to the client's work]

## Key Files
- [[Brain/People/[FirstName]_[LastName]]] — contact file

## Related
[Projects or other people they connect to]
```

Add every hub created to `Brain/Topics/INDEX.md` under the right category (Projects or People).

---

## Step 13 — Rebuild the Context Index

```bash
node .claude/hooks/build-context-index.js
```

This wires the new project and people names into the context injection system.

If the script errors, note it in Master.md under Backlog:
```
- [ ] Rebuild context index — node .claude/hooks/build-context-index.js returned error
```
Do not let this block the session.

---

## Step 14 — Confirm Dashboard

Check if the dashboard server is running:
```bash
curl -s http://localhost:7272 > /dev/null && echo "running" || echo "not running"
```

If not running:
```bash
bash System/Scripts/start-dashboard-server.sh
```

Open `http://localhost:7272` and confirm the client's name appears.

---

## Step 15 — Review with Client

Show the client what was built. Walk through each file quickly:

1. `Personality/[Name].md` — "This is how the system thinks about you. Does this feel right?"
2. `Brain/Master.md` — "These are your active projects. Is anything missing?"
3. `Brain/People/` — "I created a contact file for each person you named — [number] total."

Fix anything that's wrong or off. Their words should be in the files — not summaries of their words. If something doesn't sound like them, ask what they'd say instead and update it.

Say: "This is your system's memory of who you are. Every session starts by reading this — which means every response already knows your context."

---

## Step 16 — Flag Gaps for Follow-up

Before moving to /lets-go, surface any gaps clearly:

> "A few things to complete later:
>
> [List any of these that apply:]
> - Knowledge sources not yet ingested (website, LinkedIn, docs) — add to next call
> - Inbox folder path not set — confirm local path before drive monitoring activates
> - Digest email not set — confirm where to send the daily brief
> - [Any other enabled: false tools they actually use] — connect via Connectors when ready"

Add each gap as a task in `Brain/Master.md` under `## Backlog`.

---

## Step 17 — Hand Off to /lets-go

Say:

> "Files are built. Ready to run /lets-go — that's what fires everything up for the first time and shows you what your morning brief looks like."

Await confirmation, then they type `/lets-go` to continue.

---

## Notes

- Never invent content — only write what the transcript captured
- If a field is absent from the transcript, write `(not captured)` — not a guess
- The pre-interview summary at the end of the transcript is the primary source; the conversation body has nuance the summary may miss — read both
- Keep file writing moving — the client is watching on Zoom. Build all files, then review together
- /import-setup replaces the live /setup interview entirely — do not run /setup after this
