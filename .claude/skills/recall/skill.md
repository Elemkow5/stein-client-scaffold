---
name: recall
description: Search across the entire vault — session logs, project files, knowledge, goals, decisions, people. Natural language input. No syntax required. Use when the client wants to find anything said, saved, decided, or worked on.
user-invocable: true
allowed-tools:
  - Bash
  - Read
---

# /recall — Vault Search

Searches everything: session logs, projects, knowledge, goals, decisions, people. Natural language — no tags, no dates, no syntax required.

---

## How to Invoke

| What you type | What happens |
|---|---|
| `/recall context injector` | Finds anything about "context injector" across the vault |
| `/recall when did we last talk about Project X` | Returns most recent match only |
| `/recall something about pricing we discussed` | Vague → semantic fallback via INDEX.md |
| `/recall` (no args) | Lists 10 most recently modified files |

---

## Instructions

### Step 1 — Parse Query and Detect Mode

Extract query from `$ARGUMENTS`.

**No arguments:** list 10 most recently modified `.md` files:
```bash
find Brain/ Goals/ -name "*.md" 2>/dev/null | xargs ls -t 2>/dev/null | head -10
```

**Recency mode** — detect if query contains:
- "when did we last", "most recent", "last time we", "most recently"
→ Set `RECENCY_ONLY=true` — return single most-recent match only.

**Vague query** — detect if:
- Query is ≤ 3 words AND contains no proper nouns
- Query starts with: "that thing", "something about", "I think we", "wasn't there", "do you remember"
- After stripping stopwords, fewer than 2 distinctive keywords remain
→ Flag for semantic fallback if grep returns 0 results.

---

### Step 2 — Check Topics hub first

Before running a broad search, check if the query matches a known topic hub:

```bash
ls Brain/Topics/ 2>/dev/null
```

If a matching hub exists, read it — the **Key Files** section is the curated starting point. Also run the backlink grep:
```bash
grep -ril "[[TOPIC_NAME]]" Brain/Session_Logs/ --include="*.md" 2>/dev/null
```
Present hub summary + matching session references together, then skip to Step 5.

---

### Step 3 — Keyword Search

```bash
bash System/Scripts/recall-search.sh "$QUERY"
```

Pass optional narrows if the client asked for them:
- Timeframe: `--days 7` (last week), `--days 30` (last month)
- Project: `--project "ProjectName"`
- Type: `--section "decisions made"` or `"tasks completed"` or `"session log"`
- Recency only: `--recency-only`

Parse the JSON output. Each result has: `date`, `file`, `section`, `excerpt`, `score`, `confidence`.

---

### Step 4 — Branch on Result Count

**0 results:**
1. Strip query to individual keywords and retry (broadened search)
2. If still 0 AND query was vague (or client says "try harder"): go to Step 4b (semantic fallback)
3. If still 0 after broadening: "Nothing found for '[query]'. Try different keywords, or describe it differently."

**1 result:** Load the file immediately. Navigate to matching section. Display ~25 lines of context. Skip the list — go straight to content.

**2–10 results:** Display ranked list (see Step 5 format). Ask: "Which to load? (number) — or narrow by: timeframe / project / type"

**10+ results:** Show count + top 3 as preview. Ask ONE narrowing question:
"Found [N] matches — narrow by: **timeframe** (this week / this month / date range), **project**, or **type** (decision / note / goal)?"
Wait for answer, re-run with filter, then proceed normally.

---

### Step 4b — Semantic Fallback (when keyword search fails)

Trigger: 0 results after broadening, OR vague query, OR client says "try harder" / "search by meaning".

```bash
INDEX="Brain/Session_Logs/INDEX.md"
```

1. Read `Brain/Session_Logs/INDEX.md`
2. Identify up to 3 session IDs most likely to contain what they're looking for
3. For each: read the session file, search within it for sections relevant to the query
4. Format results same as keyword results
5. If INDEX.md is empty or doesn't exist: "Session index not built yet — it populates automatically after each /wrap. Try a keyword variation in the meantime."

---

### Step 5 — Result Display Format

```
Found [N] match(es) for "[query]":

1. [date] — [section header]
   "[excerpt up to 150 chars]..."
   → [relative file path]

2. [date] — [section header]
   "[excerpt]..."
   → [relative file path]
```

After list: *"Load one? (1–N) — or narrow by timeframe / project / type"*

---

### Step 6 — Load a Result

When the client picks a result:
1. Read the full file
2. Find the matching section
3. Display from section header to next `##` (or 30 lines max)
4. Offer: "Want the full file, or is this enough?"

---

### Step 7 — Wikilink Crawl (optional)

If any result is a `Brain/Topics/` hub file or contains `[[wikilinks]]`:
"[Hub name] connects to more files — want me to follow those links?"
If yes: `grep -ril "[[HubName]]" Brain/ --include="*.md"` and surface as additional results.

---

## Search Scope

Searches: `Brain/` (all subdirs — Session_Logs, Projects, Knowledge, Decisions, People, Topics, Plans), `Goals/`, `Personality/`

Does NOT search: `Dashboards/`, `.claude/` (hooks, settings, skills)

Semantic fallback requires `Brain/Session_Logs/INDEX.md` — auto-built by /wrap after each session.
