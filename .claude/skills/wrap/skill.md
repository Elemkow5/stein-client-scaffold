---
name: wrap
description: End-of-session close — logs what was done, captures next steps into Brain/Master.md, checks commitments. Run when finishing work on a project or ending the day.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /wrap — Session Close

Logs what happened, syncs next steps to the task board, checks commitments. Run at the end of any meaningful work session.

---

## Instructions

### Step 1 — Identify the Project

Ask: "Which project are we wrapping?" If obvious from context, confirm rather than asking.

### Step 2 — What Got Done

Ask: "What did you actually accomplish in this session? Be specific."

If vague, push for specifics — this log matters.

### Step 3 — Where Things Stand

Ask: "Where does the project stand right now?" One honest paragraph.

### Step 4 — Next Steps

Ask: "What are the specific next steps for next time?"

Write as actionable items. Bad: "Continue working on it." Good: "Draft the three-email sequence and send to client for review by Friday."

### Step 5 — Any Blockers?

Ask: "Anything blocking you?" If yes, add to `Brain/Master.md` Backlog with a [BLOCKED] tag.

### Step 6 — Commitment Prompt

Ask once: "Did you commit to anything with someone else this session — something you told them you'd deliver?"

If yes, run the same capture as `/commitment`:
1. "What did you commit to?"
2. "Who is this owed to?" — match against `Brain/People/`, offer to create a file if none exists
3. "By when?" — normalize to `YYYY-MM-DD`

Then write to all three places `/commitment` writes to:
- `Brain/Commitments.md` — new row, status `open`
- `Brain/Master.md` — tagged `[COMMITMENT: PersonName, YYYY-MM-DD]` in the appropriate time bucket
- `Brain/People/[PersonName].md` — appended under `## Open Commitments`

Also note it in the session log entry (Step 7 below). If no, skip silently — don't push.

### Step 7 — Write the Session Log

Find the current session file in `Brain/Session_Logs/` (most recently modified). Append:

```markdown
## [Project] — [DATE]

**What got done:**
[Summary from Step 2]

**Current state:**
[From Step 3]

**Next steps:**
- [ ] [Task 1]
- [ ] [Task 2]

**Commitments:**
[Any made, or "None"]

**Blockers:**
[Any, or "None"]
```

### Step 8 — Sync to Master.md

Add next steps to `Brain/Master.md` under `## Backlog` tagged with project name:
```
- [ ] [ProjectName] Draft three-email sequence
```

### Step 9 — Learning Check

Silently review: did the client correct you, redirect you, or express a preference this session? If yes, append to `Personality/Mistake_Patterns.md` or `Personality/Working_Preferences.md`. No announcement.

### Step 9b — Write Session Index Entry

Write the index entry that enables /recall semantic fallback. Run silently — no announcement unless it fails.

```bash
bash System/Scripts/write-session-index.sh --force
```

The `--force` flag overwrites any partial entry for this session. If the script fails (claude not in PATH, session too short), skip and continue.

### Step 10 — Close

Brief summary: what was accomplished, what's next, one honest note on momentum.
