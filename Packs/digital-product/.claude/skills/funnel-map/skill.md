---
name: funnel-map
description: Map a 7-piece funnel for any product before building anything. Reads the product file and voice profile from the vault, proposes each piece, and saves a funnel map the client pushes back on before a single page is built. Run this before /funnel-edit or any build work.
user-invocable: true
allowed-tools:
  - Read
  - Write
---

# /funnel-map — Map the Funnel

Plan the seven pieces of a funnel for one product. Nothing gets built until the map is approved. The map is what you push back on — change the bump, swap the upsell, rethink the down-sell — before any code is written.

**The seven pieces:**
1. Sales page — headline angle, proof block, buy button copy
2. Order bump — a companion product at checkout (one checkbox, no second page)
3. One-click upsell — one screen, one button, card already on file
4. Down-sell — lighter/cheaper cut of the upsell for those who passed
5. Email + delivery — how the buyer hits the list and what unlocks
6. Lost-cart recovery — the 6-minute email when a card declines
7. Client login + access area — what the buyer sees when they log in

---

## Step 1 — Ask which product

Ask:
> "Which product are we mapping? Give me the name — I'll read its file from your vault."

Then read `Brain/Products/[product-name].md`. If the folder doesn't exist or the file isn't there, ask the client to describe the product: what it is, who buys it, price point, what they get.

Also read `content/voice-dna.md` if it exists — needed for piece 6 (recovery email voice).

---

## Step 2 — Map all seven pieces

Run this against what you know about the product:

> Read [product file] and content/voice-dna.md. Map a seven-piece funnel for this product — one short line per piece:
>
> 1. Sales page — the headline angle, the one proof element that matters most for this buyer, the buy button copy
> 2. Order bump — propose 3 small companion products or add-ons, then recommend one. The bump solves the buyer's NEXT problem after the main one. It's a checkbox at checkout — not a second page.
> 3. One-click upsell — propose 3 candidates at a higher price point, recommend one. One screen, one sentence, one button. They already paid — this is the highest-converting screen in the funnel.
> 4. Down-sell — a lighter, cheaper version of the upsell for people who passed. What's the minimum version of the upsell that still delivers real value?
> 5. Email + delivery — how does the buyer hit the list (what tag or sequence), and what unlocks for them (download link, login credentials, access email)?
> 6. Lost-cart recovery — draft the subject line and first two sentences of the 6-minute recovery email. Voice: not "did you forget", not urgent. Take-it-or-leave-it tone. What happened, here's another way to pay, reply if anything's wrong.
> 7. Client login + access area — what does the buyer see when they log in? What's the first thing they should do or access?
>
> Don't write any pages yet. One short line per piece. Map only.

Show the client the full map.

---

## Step 3 — Push back loop

After showing the map, say:
> "Read through this. Tell me what's wrong — wrong bump, wrong upsell angle, price off, tone off. We don't build anything until the map is right."

Iterate on any piece they flag. When they say it's right, move to Step 4.

---

## Step 4 — Save the funnel map

Save the approved map to `Brain/Funnels/[product-name].md` using this structure:

```markdown
# Funnel Map — [Product Name]
*Approved [date] — ready to build*

## 1 · Sales Page
[headline angle / proof / buy button copy]

## 2 · Order Bump
[what it is / price / why it fits]

## 3 · One-Click Upsell
[what it is / price / one-sentence pitch]

## 4 · Down-sell
[what it is / price / what it strips out]

## 5 · Email + Delivery
[list tag or sequence / what unlocks / delivery mechanism]

## 6 · Lost-Cart Recovery
Subject: [subject line]
[first two sentences of the email]

## 7 · Client Login + Access Area
[what they see / first action]

## Build Order
1. Sales page + checkout (first — prove the sale before building everything else)
2. Order bump
3. One-click upsell
4. Down-sell
5. Email + delivery
6. Lost-cart recovery
7. Login + access area
```

Confirm: "Funnel map saved to Brain/Funnels/[product-name].md. Build in order — sales page and checkout first. Add the rest after the first real buyer."

---

## Step 5 — Offer to start the build

Ask:
> "Ready to start building? I can walk you through the full funnel end to end — hosting, domain, Stripe, checkout — one step at a time. Or we can start with just the sales page and checkout. Which?"

**If end-to-end:** Use this prompt to kick off the build:

> I want to build and launch the funnel for [product name] end to end — sales page, checkout, one-click upsell, delivery email — on my own hosting.
>
> Walk me through the whole thing one step at a time. Tell me exactly what to set up (hosting, domain, Stripe, email tool), what to give you and where to get it, and store every key in my ~/.secrets file, never in this chat.
>
> Start with step one and wait for me.

**If sales page + checkout only:** Use this prompt:

> Build a checkout page for my [product name] sales page, using my Stripe. Make it look like part of my site.
>
> Turn on local payment methods, Apple Pay, Google Pay, and Link.
>
> Tell me exactly what you need from Stripe and where to get it — and store the key in my ~/.secrets, never in this chat.

---

## Watch Out For

- Don't build anything before the map is approved. The map is cheap to change. Pages are not.
- Don't pick a bump that competes with the main product. A bump is a companion — it solves the buyer's NEXT problem, not an alternative to the thing they just bought.
- Don't treat the upsell like a second sales page. One screen. One sentence. One button.
- Build in order: sales page + checkout first, then add pieces. Never try to build all seven at once on the first funnel.
- Never put API keys or Stripe keys in the chat. Always `~/.secrets`.
