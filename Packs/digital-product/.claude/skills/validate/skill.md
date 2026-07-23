---
name: validate
description: Sell-before-you-build test. Conversational intake — distills the idea to a one-line promise, picks the cheapest validation method, sets a "yes" threshold before starting, and defines what a "no" looks like. Saves a validation brief to Brain/Validations/. Run this before building any new product or funnel.
user-invocable: true
allowed-tools:
  - Read
  - Write
---

# /validate — Sell Before You Build

Before any page gets built, any funnel gets mapped, any offer gets written — run this. The goal is to find out if someone will pay for it before spending time building it. The cheapest validation that proves demand is always the right first move.

---

## Step 1 — Name the idea

Ask:
> "What's the idea? Tell me in plain terms — what is it, who's it for, what does it do for them."

Let them answer without interrupting. Don't suggest anything yet.

---

## Step 2 — Distill to a one-line promise

After they describe it, run this prompt internally:

> Take what they described and reduce it to one line in this format: [Product name] helps [specific person] [do specific thing] so they can [get specific result]. No jargon. No hedging. If I can't write this line clearly, the idea isn't clear yet.

Show the one-line promise to the client:
> "Here's what I heard: [one-line promise]. Is that right? Fix anything that's off before we go further."

Don't proceed until they confirm the line is right.

---

## Step 3 — Pick the cheapest validation method

Based on the idea, propose the single cheapest test that would prove real demand. Use this decision tree:

**If the product is information/education (course, guide, template, community):**
→ Presell: DM 10 people who fit the exact buyer profile, show them the one-line promise, ask if they'd pay $[price] for it right now. If 2+ say yes and give payment info, build it.

**If the product is a service or done-for-you:**
→ Offer it to one person at a discount in exchange for a case study. No sales page needed — just a conversation and a PayPal link.

**If the product is software or a tool:**
→ Manual first: do the thing by hand for one paying customer before writing any code. Charge for the result, not the tech. If they pay and come back, then build.

**If there's an existing audience (email list, social following):**
→ Send a single email or post. Describe the problem the product solves. Ask who's dealing with it right now. Count replies — not likes, replies. If 5%+ reply, the pain is real.

Show the client one recommended method — not a menu:
> "The cheapest test for this idea is [method]. Here's exactly what to do: [specific steps]. This takes [realistic time estimate] and costs nothing to run. Does this work, or is there a constraint I'm missing?"

---

## Step 4 — Set the "yes" threshold before starting

Before they run any test, get a specific number locked in:

> "Before you start: what result would make this a clear yes? Be specific — not 'good response' or 'people seem interested.' Give me a number. How many people paying, how many replies, how many sign-ups — whatever fits the test."

Push back if the number is vague. The threshold has to be set before the test runs, not after — otherwise confirmation bias decides.

Write it down in the validation brief (Step 6).

---

## Step 5 — Define what a "no" looks like

Ask:
> "If the test doesn't hit that threshold — what does that mean? Is the idea dead, is the price wrong, is the audience wrong, or is the offer unclear? Tell me what you'll do with a no before you run the test."

This is the hardest question. Help them think it through if they're stuck:
- If nobody responds at all → the problem probably isn't painful enough or the promise isn't clear
- If people like it but won't pay → the price is wrong or it's a nice-to-have, not a need
- If the wrong people respond → the targeting is off, not the idea
- If 1-2 people pay but not 3+ → real signal, not enough. Lower scope, test cheaper.

---

## Step 6 — Save the validation brief

Save to `Brain/Validations/[idea-slug].md`:

```markdown
# Validation — [Idea Name]
*Created [date] — status: testing / passed / failed*

## One-Line Promise
[The one-line promise they confirmed in Step 2]

## What We're Testing
[The validation method chosen in Step 3]

## Exact Steps
[The specific steps to run the test]

## "Yes" Threshold
[The specific number set in Step 4 — e.g. "3 people pay $97", "5 replies asking for it"]

## What a "No" Means
[What they'll do or conclude if the threshold isn't hit — from Step 5]

## Result
[Fill in after the test runs]
```

Confirm: "Validation brief saved to Brain/Validations/[idea-slug].md. Run the test, then come back and update the Result field. Don't build anything until the test is done."

---

## Watch Out For

- Don't let them skip the threshold. "I'll know it when I see it" is not a threshold. A number is a threshold.
- Don't suggest a complicated test when a simple one works. One DM conversation that ends with payment is better than a landing page with a waitlist.
- Don't validate with attention. Likes, shares, compliments, and "I'd definitely buy that" are not validation. Money changing hands — or a firm commitment to pay — is validation.
- Don't validate with the wrong people. Family, friends, and fans who already love everything are not the market. The test only counts if the people saying yes are the actual buyer.
- If they already ran a "test" without a threshold, it doesn't count. Start over with Step 4.
