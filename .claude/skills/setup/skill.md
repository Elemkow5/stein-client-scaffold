# /setup — Client Onboarding

Interviews the client live and builds their fully personalized system from scratch. Runs without anyone else in the room.

**Time:** 45–75 minutes  
**Input:** Nothing — Claude interviews the client directly  
**Output:** A fully personalized system — identity files, projects, people, goals, task board, integrations

---

## Instructions

### Step 0 — Opening

Before asking anything, say:

> "Welcome. I'm going to set up your personal AI system right now. This takes about 45–60 minutes — I'll ask you questions across your work, your projects, the people you work with, and how you like to work. As you answer, I'll build the files that make this system know you. By the time we're done, you'll have a live system that starts every session with full context on your business.
>
> There are no wrong answers — the more specific you are, the better the system works. Ready to start?"

Wait for confirmation, then ask:

> "Before we start — every system has a name. Andrew calls his Stein. Dave Killeen calls his Haydex. What do you want to call yours? This is your chief of staff — give them a name."

Take whatever they say. Single word or short name is ideal. Save it as `SYSTEM_NAME` — you'll use it throughout setup and wire it into every file that greets the client. If they can't decide, default to their last name + "OS" (e.g. "Collins OS") and note they can change it later.

Then begin the interview.

---

### Step 1 — Interview: Professional track

Work through these questions conversationally. Don't read them as a list — ask one, let them answer, follow up if something is vague, then move to the next. Keep the pace moving.

**Critical rule: one question at a time, always. Never stack multiple questions in a single message. Ask. Listen. Follow up if something is worth digging into. Then move on.**

**Identity**
- What's your name and what do you do?
- How long have you been doing it?
- What does a great day look like for you — what gets done, how do you feel at the end of it?

*After they answer the first question, silently identify their archetype — it shapes the Workflow Discovery section later:*
- *Owner/Founder — owns the business, responsible for revenue and strategy*
- *Senior Executive — responsible for a function inside a larger org (finance, ops, sales, etc.)*
- *Professional/Practitioner — client-facing, deliverable-driven (lawyer, advisor, consultant, doctor)*
- *Investor/Dealmaker — deal flow, portfolio, capital relationships*

**Projects**
- What are the 3–5 things you're actively working on right now? (These become their projects in the system)
- For each: one sentence on what it is and where it stands

**Priorities**
- If you had to name the 2–4 things that matter most to you right now — not tasks, but bigger themes or goals — what would they be?
- For each: why does it matter right now?

**Key people**
- Who are the 10–15 people most important to your work? (Clients, partners, collaborators, key contacts)
- For each: name, role/company, and how they connect to your work

**Tech stack — full audit**

Work through each category below. For each one, name the common options so they can confirm or add their own — don't make them recall from scratch. The goal is a complete picture of every tool they touch, even occasionally. Ask one category at a time.

**Device & OS**
- Mac or PC? (or both?)
- iPhone or Android?

**Core platform — email, calendar, files**
- Google Workspace (Gmail, Google Calendar, Google Drive) or Microsoft 365 (Outlook, Teams, OneDrive)? Or something else?

**Video & meetings**
- Which do you use for calls? (Zoom, Google Meet, Microsoft Teams, Webex, Around, other?)
- Do you record or send async video? (Loom, Loom, Vidyard, other?)

**Team communication**
- Slack, Microsoft Teams, Discord, or something else? Any group chats (WhatsApp groups, iMessage threads) that are actually work communication?

**Project & task management**
- How do you track work and projects? (Notion, Asana, Monday.com, ClickUp, Trello, Basecamp, Linear, Todoist, Apple Reminders, a spreadsheet, or just email?)

**CRM & sales**
- Do you use a CRM? (HubSpot, Salesforce, Pipedrive, GoHighLevel, Zoho, Close, or none?)
- Any sales or outreach tools? (Apollo, Instantly, Lemlist, Seamless, LinkedIn Sales Nav?)

**Marketing & email**
- Email marketing platform? (Mailchimp, ActiveCampaign, ConvertKit/Kit, Klaviyo, Constant Contact, Beehiiv, Substack, or none?)
- Any other marketing tools? (SEMrush, Ahrefs, Google Search Console, etc.)

**Social media**
- Which platforms are you active on? (LinkedIn, Twitter/X, Instagram, Facebook, TikTok, YouTube?)
- Do you use a scheduling or management tool? (Buffer, Hootsuite, Later, Publer, Postiz, or post natively?)

**Design & creative**
- Canva? Figma? Adobe (Photoshop, Illustrator, Premiere)? Anything else for design or creative work?

**Website & content**
- What's your website on? (WordPress, Webflow, Squarespace, Wix, Shopify, or something custom?)
- Any analytics? (Google Analytics, Plausible, other?)

**Finance & accounting**
- QuickBooks, Xero, FreshBooks, Wave, or spreadsheets?
- How do you process payments? (Stripe, PayPal, Square, bank ACH, invoicing only?)

**Scheduling**
- Do you use a scheduling tool? (Calendly, Acuity, TidyCal, or do people just email you?)

**Automation**
- Any automation tools? (Zapier, Make.com, n8n, or nothing yet?)

**AI tools**
- Which AI tools do you actually use regularly? (ChatGPT, Claude, Gemini, Perplexity, Midjourney, other?)

**Anything else**
- Any other tools that are important to how you work day to day that we haven't covered?

**Inbox folder**
- I'm going to set up an Inbox folder in your [drive from above — Google Drive / OneDrive / iCloud / Dropbox]. Anything you drop there — a PDF, a photo, a screenshot, a voice note, a document — gets pulled into your system automatically. What do you want to call it? (Default: "AI Inbox")
- Where does your [drive] folder live on your computer? (e.g. ~/Google Drive/My Drive — or they can drag the folder into the terminal to get the path)

**Knowledge sources — what the system should know**

> "The more [SYSTEM_NAME] knows about your business upfront, the more useful it is from day one. I want to feed it everything relevant — websites, documents, anything that describes who you are and what you do. Let's go through what exists."

Work through each category. Don't rush — this is one of the highest-value parts of setup.

**URLs to scrape:**
- Main website — get the homepage URL, then ask: "Are there specific pages that describe your services, pricing, or who you work with? Give me those URLs too."
- LinkedIn profile — personal and/or company page
- Bio or about page (speaker page, Calendly bio, directory listing, podcast guest page)
- Any other URL where someone could read about what you do

Collect every URL. You'll fetch them all in Step 3a.

**Documents to ingest:**
Go through each category — name it, let them confirm yes/no/share:
- *Pitch deck or company overview* — "anything you'd send a prospect to explain what you do?"
- *Services or pricing doc* — formal or informal, doesn't matter
- *One-pager or capability statement*
- *Bio or speaker intro*
- *SOPs or process docs* — how you do what you do
- *Proposals or scope of work templates* — especially ones you're proud of
- *Case studies or client results*
- *A "how I work" doc* — even informal notes about your process
- *Any research or reference material* you want the system to be informed by (market research, competitor notes, industry context)
- *A personal vision doc or goals doc* — if they've written one

For each document they have: ask them to share it one of these ways:
1. Drop it in the AI Inbox folder (gets auto-ingested)
2. Share a Google Drive link (if Drive MCP is connected)
3. Paste the text directly into chat

**The framing that helps:** 
> "Think about it this way — anything you'd give a new chief of staff on their first day so they could hit the ground running, give to [SYSTEM_NAME] right now."

Note everything collected. Process it all in Step 3a before writing any files.

**Open commitments — seed The Enforcer**

> "One more thing before we move on. Think about commitments you've made to specific people that are still open — things you've told someone you'd deliver, send, or follow up on. These could be from recent calls, emails, or conversations. What's outstanding?"

For each one they mention, collect three things:
- **What** — the specific deliverable or action (their words)
- **Who** — which person from their key contacts list (or a new name)
- **By when** — a specific date, or ask "when did you say you'd have it done?"

If they draw a blank, prompt: "Think about your last few calls or meetings. Did you tell anyone you'd send something, follow up, or get back to them?"

Collect all of them. You'll write them to `Brain/Commitments.md` in Step 6b.

**Daily digest time**
- Last one: what time do you want your daily brief delivered each morning? (One email, every day — when should it land?)

**Goals**
- What do you want to have done by the end of this year that would make you feel like it was a great year?
- What about by end of this quarter?

**Workflow Discovery**

*This section serves two purposes: it seeds the personality files AND generates the data for the module recommendation report (run `/intake-assess` after the session). Ask one question at a time. Offer menus where indicated — if they're stuck on an open question, prompt with examples. Probe when you hear a high-value signal; skip branches that clearly don't apply.*

---

**WD1 — Typical week**

> "Walk me through a typical week — what actually happens day to day? For example: how do you start Monday morning, what kinds of meetings or calls fill your week, what are you producing or delivering, and how does Friday usually end?"

---

**WD2 — Time sinks** *(menu)*

> "What takes the most time that you wish didn't? Pick everything that applies:
> 1. Writing — emails, proposals, updates, reports
> 2. Meeting prep — pulling context before calls
> 3. Tracking things down — information you know you have somewhere
> 4. Following up after conversations
> 5. Managing my inbox
> 6. Administrative tasks — scheduling, filing, data entry
> 7. Something else"

→ Follow up on whatever they pick: *"Tell me more about [X] — what does that actually look like for you?"*

---

**WD3 — Manual tracking** *(menu)*

> "What do you track manually today that you feel should just happen automatically? Pick everything that applies:
> 1. Contact notes and relationship history
> 2. Tasks and to-dos
> 3. Commitments I've made to people
> 4. Deals or projects in progress
> 5. Market activity — prices, news, what's moving
> 6. Deadlines and due dates
> 7. I don't really have a system — things live in my head
> 8. Something else"

→ Follow up: *"Which of those is the most painful right now?"*

---

**WD4 — What falls through the cracks** *(menu)*

> "What falls through the cracks most often?
> 1. Following up after meetings or calls
> 2. Getting back to someone I said I would
> 3. Tasks that got buried under other things
> 4. Relationships that go quiet
> 5. Information I meant to track but didn't
> 6. Deadlines I almost missed
> 7. Something else"

→ Follow up: *"How often does that happen — and what's the cost when it does?"*

---

**WD5 — Relationships** *(open, then menu)*

> "Who are the most important people in your world right now — clients, partners, contacts, whoever matters most to your work?"

→ After they answer: *"How do you manage those relationships today?*
> *1. I keep notes somewhere — email, a doc, my phone*
> *2. I rely on memory*
> *3. I use a CRM or contact tool*
> *4. Honestly I don't have a real system*
> *5. Something else"*

→ If they don't have a system or rely on memory: *"Does it ever cost you — walking into a call underprepared, or losing track of where things stand with someone?"*

---

**WD6 — Market intelligence** *(menu)*

> "How do you stay current on your market or industry?
> 1. I read newsletters or publications regularly
> 2. My network surfaces things for me
> 3. I research when I need to
> 4. I have tools that track things
> 5. I don't stay as current as I'd like
> 6. Something else"

→ If 5: *"What do you miss most often — what kinds of things do you find out about too late?"*

---

**WD7 — Output and writing** *(menu)*

> "What do you write or produce most often?
> 1. Emails and messages
> 2. Proposals or quotes
> 3. Reports or updates to stakeholders
> 4. Outreach — prospecting, introductions
> 5. Content — posts, articles, newsletters
> 6. Deal memos or analysis
> 7. I don't produce much written output
> 8. Something else"

→ Follow up: *"How long does that typically take, and where does it slow you down?"*

---

**WD8 — Archetype branch** *(3–4 questions based on archetype identified in Identity)*

*Owner/Founder:*
- *"How does new business come to you today?"* (menu: referrals / inbound / outreach / events / content / inconsistent / other) → if inconsistent: *"What does that cost you?"*
- *"Do you have a team or contractors? How do you manage them?"*
- *"Do you have a public presence — content, social, newsletters, speaking?"* (menu: yes active / want to but inconsistent / not really / just starting) → if yes or inconsistent: *"What's the biggest friction — ideas, writing, or getting it out consistently?"*

*Senior Executive:*
- *"How many deals, projects, or initiatives are you managing at once — and how do you keep track of where each one stands?"*
- *"Who are the key external parties you're managing relationships with?"* (menu: lenders / investors / counterparties / advisors / board / other) → *"Before a major meeting with any of them, how do you prepare today?"*
- *"How do you manage up — keeping leadership informed and aligned?"* (menu: formal reporting / ad hoc / lots of informal calls / it's a gap / other)

*Professional/Practitioner:*
- *"How many active clients or cases are you managing right now — and what does your communication with them look like week to week?"*
- *"How do new clients come to you?"* (menu: referrals / reputation / outreach / marketing / inconsistent / other)
- *"What's the most time-consuming part of client work — outside the actual work itself?"* (menu: onboarding / communication and updates / writing deliverables / billing and admin / scheduling / other)

*Investor/Dealmaker:*
- *"Walk me through your deal flow — how many deals are you looking at at any given time, and how do you track them through stages?"*
- *"How do you source deals today?"* (menu: network / active outreach / inbound / events / not systematic / other)
- *"What does your investor or LP communication look like?"* (menu: regular formal updates / ad hoc / heavier than I'd like / no LPs to manage / other) → if heavier than I'd like: *"What's the most time-consuming part?"*

---

**WD9 — The dream** *(open)*

> "Last one — if you had a perfect assistant with no limitations, what's the first thing you'd hand off?"

---

**Failure modes** *(keep brief — most is already covered above)*
- Is there anything you want the system to actively watch for and call out that we haven't touched on?

**How to work with you**
- How direct do you want the system to be — should it push back on you, or mostly execute?
- Is there anything the system should never do — topics to avoid, things that would annoy you?

---

### Step 2 — Optional: Personal track

After the professional track is complete, say:

> "That's the professional layer — the system already knows everything it needs to work with you on your business. There's an optional personal layer too. Sharing context about your personal life — family, health, finances, long-term goals — makes the system more useful over time and opens up additional modules. It's completely optional and you can skip anything. Want to continue?"

If yes — ask conversationally:
- Family situation (partner, kids, dependents)?
- Health priorities or anything the system should be aware of?
- Financial picture at a high level — what are you building toward?
- Long-term personal goals beyond work?
- Interests or things that matter to you outside of work?

If no — note `(personal track skipped — client preference)` in their identity file. Move to Step 3.

---

### Step 3a — Ingest knowledge sources → Build Brain/Business.md

This step runs before any other files are written. Process every source collected during the interview, then synthesize everything into one permanent context file.

`Brain/Business.md` is the system's foundational knowledge about the client's business. Every skill that drafts an email, writes a plan, or pulls context draws from it. The richer this file, the more useful the system is from day one.

---

**Processing by asset type:**

**URLs (website, LinkedIn, bio pages, etc.)**
Use WebFetch on every URL collected. For each page, extract:
- What they do and who they serve
- Services, products, and pricing (explicit — don't infer)
- How they describe themselves (exact language matters — voice carries over into email drafts)
- Named team members, partners, or key people
- Any results, case studies, or social proof mentioned

Fetch all URLs before writing anything. Synthesize across them — don't dump page text.

**Documents dropped in AI Inbox (PDFs, Word docs, text files)**
Read each file. Extract the same categories. PDFs and docs often have more detail than the website — pricing, process, positioning language. Prioritize explicit content from documents over inferred content from websites.

**Google Drive links (if Drive MCP is connected)**
Use the Drive MCP to read the file directly. Same extraction as above.

**Pasted text**
Already in context — extract and include.

**If a source can't be accessed** (broken URL, file format unreadable): note it at the bottom of Brain/Business.md under `## Sources` with status "could not read" — don't silently skip it.

---

**Write the file:**

```markdown
# [Client Name]'s Business
*[SYSTEM_NAME]'s foundational knowledge about the business.*

## What We Do
[Clear description in their own language — use their words where possible, not paraphrases]

## Who We Serve
[Target client/customer — who, what situation they're in, what problem they're trying to solve]

## Services & Offerings
[Each service or product on its own line. Format: **Name** — description. Include pricing if captured.]

## How We're Different
[Positioning, differentiators, what they emphasize about themselves vs. alternatives]

## Results & Proof Points
[Client outcomes, case studies, testimonials, or any results mentioned across sources]

## Voice & Language
[Words and phrases they use to describe what they do — useful for email drafts, proposals, and content. Note any language they avoid or use deliberately.]

## Key People
[Named team members, partners, collaborators — name, role, brief note]

## Online Presence
[One line per URL — what it is and the URL]

## Additional Context
[Market research, competitive notes, industry context, vision docs, or anything else fed in that doesn't fit above]

---
## Sources
*Ingested during /setup on [YYYY-MM-DD]*
- [source 1 — type and name/URL — ✅ read / ⚠️ could not read]
- [source 2]
```

**Do not invent content.** Only write what came from the sources. If a section has nothing, write `(none captured)` — never guess or fill in with assumptions.

After writing the file, say: "I've built [SYSTEM_NAME]'s business context file from [N] sources. Want to review it before we continue, or keep moving?"

---

### Step 3 — Write the identity file

Create `Personality/[FirstName].md` using their name from the interview.

```markdown
# [Full Name]
[Role] — [Industry/Business Type]

## Who I Am
[2-3 sentences from their role, tenure, and what a great day looks like]

## My Projects
[Active projects as a dash list — one per line]

## My Priorities
[Priority names as a bullet list]

## How to Work With Me
[From the "how to work with you" questions — directness level, what not to do]

## What I'm Trying to Build
[From the "what the system should do" and goals questions]

## My Common Failure Modes
[From the failure modes question]

## Personal Context
[Only if personal track completed. Plain prose — family, health, finances (high level), personal goals, interests. If skipped: "(personal track skipped — client preference)"]
```

**Do not invent content.** Only write what they said. If something is blank, write `(to fill in)` — never guess.

---

### Step 4 — Write the priorities file

Create `Personality/Priorities.yaml`:

```yaml
priorities:
  - name: [Priority 1 name]
    why: "[Why it matters — their words]"
    priority: 1

  - name: [Priority 2 name]
    why: "[Why it matters]"
    priority: 2

  # Add more as needed
```

---

### Step 5 — Write working preferences

Create `Personality/Working_Preferences.md`:

```markdown
# Working Preferences

## Communication Style
[Directness level + any notes from the interview]

## What Not to Do
[Their answer on what the system should never do]

## Other Preferences
[Anything else they mentioned]
```

---

### Step 6 — Create People files

For each person named in the interview, create `Brain/People/[FirstName]_[LastName].md`:

```markdown
# [Full Name]
**Role:** [Role / relationship]
**Company:** [Company or context]
**Why they matter:** [One sentence from the interview]

## Open Items
(none yet)

## Notes
(none yet)
```

If they named 12 people, create 12 files. Do not skip anyone.

---

### Step 6b — Seed Brain/Commitments.md

If any open commitments were collected during the interview, write them now.

Create (or open) `Brain/Commitments.md`. The file should have this structure if it doesn't exist yet:

```markdown
# Commitments

Running ledger of all commitments made to other people.

| Date Made | To | What | Due | Status |
|---|---|---|---|---|
```

For each commitment collected, add one row:

| Date Made | To | What | Due | Status |
|---|---|---|---|---|
| [today's date] | [person name] | [what was committed] | [due date or "unknown"] | open |

Then write a matching entry to each person's People file under `## Open Commitments`:
```
- [ ] [Due YYYY-MM-DD] [What] — made [today's date]
```

If the due date is unknown, use `(no date set)` and note it in the What column.

Also add a `## Commitments` section to `Brain/Master.md` if one doesn't exist:
```markdown
## Commitments
<!-- Open commitments to other people — sourced from Brain/Commitments.md -->
```

And add one tagged line per commitment under it:
```
- [ ] [COMMITMENT: PersonName, YYYY-MM-DD] What
```

If no commitments were mentioned during the interview, skip this step entirely — don't create an empty Commitments.md.

---

### Step 7 — Seed Master.md

Open `Brain/Master.md`. For each active project from the interview, add:

```markdown
## [Project Name]
*[One-sentence description from the interview]*

### This Week
[Ask: "What's the most important thing to move forward on [Project] this week?"]

### Tasks
[Ask: "What are the 2-3 things you know need to happen next on [Project]?"]

### Backlog
(empty for now)
```

Ask the "this week" and "tasks" questions live for each project. Fill in as they answer.

---

### Step 8 — Write goals files

Create `Goals/Annual.md`:

```markdown
# Annual Goals — [Year]

[3-5 goals derived from their priorities, active projects, and what they said they want to build this year]
```

Create `Goals/Quarterly.md`:

```markdown
# Quarterly Goals — Q[N] [Year]

[What they said would make this quarter a success — their words, not a paraphrase]
```

---

### Step 9 — Configure integrations

Write `System/integrations.yaml` from everything captured in the tech stack interview. Fill in every field — use `none` where they said they don't use something, leave `enabled: false` for anything that exists but isn't connected yet.

```yaml
# ── Device & OS ──────────────────────────────────────────
device:
  computer: mac           # mac | pc | both
  phone: iphone           # iphone | android

# ── Core platform ────────────────────────────────────────
platform: google          # google | microsoft

email:
  provider: gmail         # gmail | outlook | other
  enabled: true

calendar:
  provider: google        # google | outlook | other
  enabled: true

drive:
  provider: google_drive  # google_drive | onedrive | dropbox | other
  enabled: true

# ── Communication ─────────────────────────────────────────
video:
  provider: zoom          # zoom | google_meet | teams | webex | other
  enabled: false
  async_video: none       # loom | vidyard | none

messaging:
  provider: slack         # slack | teams | discord | none
  enabled: false
  informal_channels:      # whatsapp groups, imessage threads used for work
    - none

# ── Project management ────────────────────────────────────
project_management:
  provider: notion        # notion | asana | monday | clickup | trello | linear | todoist | spreadsheet | none
  enabled: false

# ── CRM & sales ───────────────────────────────────────────
crm:
  provider: hubspot       # hubspot | salesforce | pipedrive | gohighlevel | zoho | close | none
  enabled: false

sales_tools:              # apollo | instantly | lemlist | linkedin_sales_nav | none
  - none

# ── Marketing ─────────────────────────────────────────────
email_marketing:
  provider: none          # mailchimp | activecampaign | kit | klaviyo | beehiiv | substack | none
  enabled: false

seo_tools:                # semrush | ahrefs | google_search_console | none
  - none

# ── Social media ──────────────────────────────────────────
social:
  platforms:              # linkedin | twitter_x | instagram | facebook | tiktok | youtube
    - linkedin
  scheduler: none         # buffer | hootsuite | later | publer | postiz | native | none

# ── Design & creative ─────────────────────────────────────
design:
  tools:                  # canva | figma | adobe_photoshop | adobe_illustrator | adobe_premiere | none
    - none

# ── Website & analytics ───────────────────────────────────
website:
  platform: none          # wordpress | webflow | squarespace | wix | shopify | custom | none
  analytics: none         # google_analytics | plausible | none

# ── Finance ───────────────────────────────────────────────
accounting:
  provider: none          # quickbooks | xero | freshbooks | wave | spreadsheets | none

payments:
  provider: none          # stripe | paypal | square | ach | invoicing | none

# ── Scheduling ────────────────────────────────────────────
scheduling:
  provider: none          # calendly | acuity | tidycal | email | none

# ── Automation ────────────────────────────────────────────
automation:
  tools:                  # zapier | make | n8n | none
    - none

# ── AI tools ──────────────────────────────────────────────
ai_tools:                 # chatgpt | claude | gemini | perplexity | midjourney | other
  - claude

# ── Other tools ───────────────────────────────────────────
other_tools:              # anything else from the interview
  - none

# ── Inbox folder ──────────────────────────────────────────
# Anything dropped here gets pulled into Brain/Inbox.md automatically.
inbox_folder:
  name: "AI Inbox"        # folder name — from interview, default "AI Inbox"
  drive: google_drive     # google_drive | onedrive | icloud | dropbox
  local_path: ""          # full local path — e.g. /Users/name/Google Drive/My Drive/AI Inbox

# ── Daily digest ──────────────────────────────────────────
digest:
  time: "7:30 AM"
  timezone: ""            # e.g. America/New_York — ask if not obvious
  recipient_email: ""     # their email address — where the digest gets sent
```

For every tool with `enabled: false` that they actually use, add a follow-up to Master.md: `- [ ] Connect [tool] to [Client]'s system`.

Confirm platform OAuth is working:
```bash
claude mcp list
```
Calendar, email, and drive should appear as connected for their platform. If any are missing, add to Master.md follow-up — do not debug during the setup session.

---

### Step 10 — Create starter topic hubs

For each active project, create `Brain/Topics/[ProjectName].md` using `Brain/Topics/_template.md`:
- Description from the interview
- Key Files pointing to any project files already created
- Related links to relevant People hubs

For each key person, create `Brain/Topics/[PersonName].md`:
- Description: role, company, relationship type, why they matter
- Key Files: link to their `Brain/People/` file
- Related: other people or projects they connect to

Add every hub to `Brain/Topics/INDEX.md` under the right category.

---

### Step 11 — Rebuild the context index

```bash
node .claude/hooks/build-context-index.js
```

This wires the new project and people names into the context injection system so they surface automatically in future sessions.

---

### Step 12 — Confirm the dashboard

Check if the dashboard server is running:
```bash
curl -s http://localhost:7272 > /dev/null && echo "running" || echo "not running"
```

If not running, start it:
```bash
bash System/Scripts/start-dashboard-server.sh
```

Open `http://localhost:7272`. Confirm their name appears in the sidebar (it reads from `Personality/[Name].md`) and that Master.md tasks are visible.

---

### Step 13 — Run /planning

Run `/planning` to close out the setup session. This gives the client their first real experience of the system working — calendar pulled, priorities set, today's one thing identified.

By the end they should have:
- A clear picture of today's priorities
- Real tasks in their Master.md
- Their first session log written

---

### Step 14 — Close

Say:

> "Your system is live.
>
> From now on: open Claude Code in this folder every morning and run `/planning`. That's the only habit that matters to start. Everything else — `/capture`, `/wrap`, `/recall` — you'll pick up naturally as you use it.
>
> The system gets smarter every session. Every email updates your contacts automatically. Every correction becomes a permanent rule. The longer it runs, the more it knows — and the more useful it gets."

Run `/wrap` to log the setup session.

---

## Notes

- After the session ends, Andrew runs `/intake-assess [client name]` on the full interview transcript to generate the module recommendation report — this is separate from /setup and runs in Andrew's Stein vault, not the client's system
- Never invent content — only write what the client actually said
- If a section was skipped or vague, write `(to fill in)` rather than guessing
- Keep the interview moving — if they get chatty, redirect: "Let's keep moving, we can go deeper on that once the system is built"
- The system can always be updated later — better to launch at 80% than delay for perfection
- If something breaks technically during setup, note it in Master.md and move on — don't let a config issue eat the session
