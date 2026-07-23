---
name: funnel-edit
description: Safe-edit ritual for touching any live page that takes money. Four mandatory steps in order — save a copy, see the diff, log the change, check the page after. Run this every time a live funnel page is edited. Never skip a step.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# /funnel-edit — Safe Edit Ritual

Four steps. Run them in order every time a live page that takes money is changed. This is what separates "I'm scared to touch my live site" from "I shipped three edits before lunch."

**Step 1 → Save a copy**
**Step 2 → See the change before it goes live**
**Step 3 → Log it**
**Step 4 → Check the page after**

Never skip a step. Never combine steps. The ritual is only valuable if it's a ritual.

---

## How to Invoke

Tell the client to run `/funnel-edit` any time they want to change something on a live page. Then ask:

> "What are we changing, and on which page?"

Get: the page URL or path, and what they want changed (copy edit, new button, layout change, new bump, etc).

Then run the four steps below in sequence, waiting for client confirmation between each.

---

## Step 1 — Save a Copy First

Run this before touching anything:

> Before you change anything on [page URL or file path], save a copy of the current live version.
>
> 1. Pull the current live files for that page into a local backup folder named with today's date and time — format: `backups/YYYY-MM-DD-HHmm-[page-name]/`
> 2. Confirm the backup exists and tell me the exact path.
> 3. Show me the one-line undo command — the exact thing I'd run to put the old version back if this change goes wrong.
>
> Don't edit anything yet. Just save the copy. Then wait for my next instruction.

**Wait for the client to confirm the backup exists before continuing.**

If the backup fails or the path can't be confirmed — stop. Do not proceed until this step is solid. A change without a backup has no undo.

---

## Step 2 — Show the Diff Before It Goes Live

Run this after the backup is confirmed:

> Show me exactly what this change would do before it goes live. Do NOT push it yet.
>
> For each file that would change:
> 1. The file path
> 2. The old line and the new line, side by side
> 3. One sentence on why it's changing
>
> If the change includes anything I didn't ask for — extra files, deleted lines, things I didn't mention — STOP and flag it before going further. I'd rather see one surprise now than find it broken at midnight.
>
> Wait for me to say "push it" before anything goes live.

**Show the diff. Wait for the client to say "push it" explicitly.** Do not go live on "looks good" or "ok" — require the explicit "push it" confirmation.

If the diff shows changes to files the client didn't mention: surface them clearly. "You asked to change the headline, but this diff also touches the checkout handler. Is that expected?" Stop if they're not sure.

---

## Step 3 — Log the Change

Run this immediately after pushing live:

> Add a line to the change log at `system/production-deploy-log.md` for the change we just pushed live.
>
> One entry, this format:
> - Date and time (client's local timezone)
> - The file or files touched
> - One sentence on WHAT changed
> - One sentence on WHY it was asked for
> - The one-line undo command from Step 1
>
> Add it to the end of the file. Don't rewrite the file. Show me the new line before you save it.

If `system/production-deploy-log.md` doesn't exist, create it first with a header:
```markdown
# Production Deploy Log
*One entry per live change. Newest at bottom.*
```

**Show the log entry before saving. Confirm, then save.**

---

## Step 4 — Check the Page After

Run this after the log is saved:

> Check the live page we just changed: [page URL]
>
> 1. Open the page in a real browser.
> 2. Take a full-page screenshot and save it to the backups folder with today's date and time.
> 3. Confirm the exact thing I changed actually shows up — quote the new copy back to me, or confirm the new button is there.
> 4. Check the page for errors — pixel firing, no broken scripts, no missing images.
> 5. Click the main buy button and tell me where it goes — Stripe checkout or the thank-you page.
>
> Give me a clear PASS or FAIL on each of the five. If anything fails, do NOT undo it on your own — show me what failed and ask before putting the old version back.

**If any check fails:** surface it specifically. Don't undo silently. Ask the client: "The [specific check] failed. Do you want me to roll back using the undo command from Step 1, or investigate first?"

---

## Big Changes — Use a Duplicate Instead

If the client wants to change a layout, redesign a section, swap out a whole bump or upsell, or do anything that affects the structure of the page (not just copy or a single element):

Tell them:
> "That's a big change — better to duplicate the funnel, test on the copy, then swap. That way the live funnel keeps taking money while we work. Want me to set that up?"

**Duplicate flow:**
1. Copy the whole funnel to a separate address (test URL)
2. Set the copy's Stripe to test mode so no real money moves
3. Change anything on the copy — break it completely if needed, the live funnel is untouched
4. Test end to end: bump, upsell, delivery email, login, failed card recovery
5. Swap the live address to point at the new version when it's better than what's live
6. Keep the old version as the backup for a few days

> I want to make a big change to my [product name] funnel without touching the live one. Set up a copy I can test on.
>
> 1. Duplicate the whole funnel — every page and every server file — to [test address]. Leave the live funnel completely untouched.
> 2. Put the copy's Stripe into TEST mode. Tell me how you confirmed it's in test mode.
> 3. Give me the test card numbers for a successful purchase and a declined one.
> 4. List everything I should test on the copy before trusting it: bump, upsell, down-sell, delivery email, login area.
>
> Don't swap anything live yet. When I've tested the copy and I'm happy, I'll ask you to switch the live address over — and keep the old version as backup so I can switch back in one move.

---

## Watch Out For

- Never skip the backup step because "it's a small change." Small changes break live pages too.
- Never go live without the explicit "push it" from the client. "Looks good" is not push it.
- Never let the deploy log fall behind. Every change that goes live gets an entry. No exceptions.
- Never undo silently when a check fails. Surface it, ask first.
- Never run the big-change flow on the live funnel directly. Duplicate → test → swap.
- Never run Claude and another AI (Codex, etc.) on the same funnel at the same time. They overwrite each other's work silently.
