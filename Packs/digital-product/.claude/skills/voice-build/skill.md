---
name: voice-build
description: Build the client's voice file from their existing writing or a spoken transcript. Creates content/voice-dna.md — the file Claude loads every chat to make drafts sound like the client instead of generic AI. Run once to create, then use /voice-check to sharpen over time.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /voice-build — Build the Voice File

Extracts the client's voice patterns from their own writing and saves them to `content/voice-dna.md`. Claude loads this file at the start of every chat and uses it for all writing.

**Important:** The voice file is for content — emails, newsletters, Substack, social posts. It is NOT for sales pages. Sales pages use copywriter voices (see the Sales Page section at the bottom).

---

## Step 1 — Check if the file already exists

Read `content/voice-dna.md`. If it exists and has content, tell the client:
> "Your voice file already exists at content/voice-dna.md. Use /voice-check to sharpen it from a draft that missed, or tell me you want to rebuild it from scratch."

Stop unless they say rebuild.

---

## Step 2 — Ask which path

Ask the client:
> "Do you have writing I can read — blog posts, emails, newsletter issues, anything you've published? Paste about 5,000 words and I'll pull your patterns out. Or if you don't have writing yet, record a 15-minute voice memo about your business and paste the transcript."

Wait for their response. Two paths:

---

## Path A — Client Has Writing (5,000+ words)

**Prompt to run on their sample:**

> Read this writing and pull out the voice patterns — sentence length and rhythm, words this person never uses, phrases only they use, topics they avoid, tone (warm/direct/dry/etc). Show me the patterns as a numbered list before writing anything. I need the client to confirm the list is right before saving.
>
> [their writing goes here]
>
> Show the patterns list. Wait for confirmation. Do not write the file yet.

After showing the list, ask:
> "Does this look right? Anything to correct, add, or remove before I save it?"

Make any corrections they give. Then write the file to `content/voice-dna.md` using this structure:

```markdown
# Voice DNA
*Built from [word count] words of [client name]'s writing — [date]*

## Core Characteristics
[sentence length, rhythm, tone — 3-5 bullet points]

## Banned Words
[words they never use — list each one]

## Approved Moves
[phrases or constructions only they use]

## Topics They Avoid
[subjects that never appear in their writing]

## Medium Notes
[any differences between how they write emails vs posts vs long form — if detectable from sample]
```

Confirm: "Voice file saved to content/voice-dna.md. Use /voice-check on any draft that doesn't sound right — it'll flag the miss and add the rule to this file so it doesn't happen again."

---

## Path B — Client Has a Transcript (No Writing Yet)

**Prompt to run on their transcript:**

> This is a transcript of someone talking about their business for about 15 minutes. It's unscripted — how they actually speak.
>
> Pull a first-draft voice profile from it: sentence length, words they lean on, words they'd never use, how they explain things, their tone. Mark anything you're uncertain about with [UNCONFIRMED] so they know to watch for it in future drafts.
>
> Show the profile as a list before writing anything. Wait for confirmation.
>
> [transcript goes here]

After showing the profile, ask:
> "Anything obviously wrong here? This is a first draft — it'll get sharper as you correct future drafts. Confirm and I'll save it."

Save to `content/voice-dna.md` using the same structure as Path A. Add a note at the top:

```markdown
# Voice DNA
*First draft — built from spoken transcript [date]. Sharpens as drafts are corrected.*
```

Confirm: "First-draft voice file saved. It won't be perfect yet — that's expected. Every time a draft misses, run /voice-check to add the rule."

---

## Step 3 — Wire it into CLAUDE.md

After saving the file, offer to wire it in:
> "Want me to add a line to your CLAUDE.md so this file loads automatically at the start of every chat? You'll never have to paste it manually."

If yes, run this — read CLAUDE.md first, add only the one line, show the diff before saving:

> Add a line to CLAUDE.md that tells Claude to read content/voice-dna.md at the start of every chat and use that voice for any writing. Read the existing CLAUDE.md first. Keep everything already in it. Only ADD the line — don't replace or delete anything. Show the diff before saving.

---

## One File Per Medium

If the client asks about multiple mediums (emails AND newsletters AND sales posts), tell them:
> "Build one file first — for whichever medium you write most. Once that's sharp, we'll build a second one for the next medium. One generic file for everything makes everything sound generic."

---

## Sales Pages — Exception

The voice file does NOT apply to sales pages.

If the client asks to write a sales page, tell them:
> "Sales pages use a different approach — your own voice actually converts worse there. Here's the method: write the first draft in Scott Adams style (plain, precise, nothing clever), then layer five expert copywriters on top."

**Clarity-first draft prompt:**
> Write the first draft of this sales page in the style of Scott Adams — precise, plain, gets straight to the point. No clever copywriting moves yet. Just make every line clear and easy to follow.
>
> [describe the product, who it's for, and the offer]

**Layer the copywriters prompt:**
> Take this clear draft and summon the 5 best copywriters in sales-page copy. Have each one rewrite it through their own lens — Eugene Schwartz on awareness and sophistication levels, Dan Kennedy on the strength of the offer and what the reader loses if they don't buy, and three more masters of this craft.
>
> Show all five versions side by side. Don't merge them. The client will read them and say which ones to implement.

---

## Watch Out For

- Don't let Claude invent banned words or approved moves the client didn't exhibit in the sample. If a "rule" feels made up, flag it before saving.
- Don't save without showing the pattern list first. The file is only as good as the sample — errors baked in now get repeated forever.
- Don't use this file for sales pages. Direct to the Scott Adams → copywriter method instead.
- One medium at a time. Don't try to capture email voice AND newsletter voice AND post voice from one sample.
