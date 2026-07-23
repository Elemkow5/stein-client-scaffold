---
name: voice-check
description: Check a draft against the client's voice file and fix what doesn't sound like them. Also adds the correction as a rule to content/voice-dna.md so the same miss doesn't happen again. Run whenever a draft feels off.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /voice-check — Check and Sharpen the Voice

Two jobs in one: fix the draft that missed, then bake the correction into `content/voice-dna.md` so it doesn't happen again.

---

## Step 1 — Read the voice file

Read `content/voice-dna.md`. If it doesn't exist, stop and say:
> "No voice file found. Run /voice-build first to create content/voice-dna.md from your writing."

---

## Step 2 — Determine what to check

Two ways this gets invoked:

**A — Client flags a specific draft:**
They'll say something like "this doesn't sound like me" or paste a draft. Take whatever they gave.

**B — Check the last thing written:**
If no draft is provided, check the most recent output from this session.

---

## Step 3 — Check against the voice file

Run this pass on the draft:

> Read content/voice-dna.md. Then read this draft. Find every place it doesn't match the voice profile — a banned word used, an approved move missing, wrong sentence length, wrong tone, a topic that should be avoided.
>
> List the misses specifically: quote the offending line, name which rule it breaks, suggest the fix.
>
> [draft here]

Show the miss list to the client before rewriting anything.

---

## Step 4 — Rewrite

After showing the misses, rewrite the draft with all flags corrected. Present the new version.

Ask: "Does this sound right now? Or is there still something off?"

If they flag more: repeat the check on their specific note, fix, show again.

---

## Step 5 — Add the rule to the voice file

After they approve the rewrite, ask:
> "Want me to add a rule to your voice file so this miss doesn't happen again?"

If yes (default — suggest yes):

Ask them to describe what was wrong in their own words, or use what you already identified. Then:

1. Read `content/voice-dna.md`
2. Add the new rule to the appropriate section (Banned Words, Approved Moves, Core Characteristics, or Topics to Avoid)
3. Show the exact line being added before saving:
   > "Adding this line to your voice file: [the rule]. Save it?"
4. Save only after they confirm

---

## Step 6 — Tag winners

If the client mentions a draft performed well (good open rate, lots of replies, sales), offer:
> "Want to tag this as a winner in your voice file? We can label it 'emails that get replies' or similar — so the file captures not just your patterns but what actually works."

If yes, append to `content/voice-dna.md`:

```markdown
## Winners
### [Medium] — [what made it work]
> [paste the winning line or section]
```

---

## Watch Out For

- Don't let Claude decide the rule without the client's input. They know their voice — surface the miss, let them confirm the fix.
- Don't rewrite the whole draft when only one line is off. Fix what's broken, leave the rest.
- Don't skip adding the rule to the file. If the correction stays only in this chat, Claude repeats the miss next week.
- Don't judge by AI compliments. "That sounds great" from Claude means nothing. What matters is open rates, replies, sales — judge by results.
