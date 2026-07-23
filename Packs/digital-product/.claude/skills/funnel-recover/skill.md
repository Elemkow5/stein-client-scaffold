---
name: funnel-recover
description: Wire up lost-cart recovery for any funnel. When a card declines at checkout, Stripe pings the server, the payment listener catches it, and a recovery email goes out within 6 minutes. Run once per funnel after the checkout is live.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
---

# /funnel-recover — Lost-Cart Recovery Setup

One in ten checkout attempts ends in a declined card. Most funnels lose every one of those buyers. This wires up a 6-minute recovery email that wins back the ones who actually wanted the product — the card just glitched.

Three pieces: Stripe pings the server on failure → payment listener catches it → email tool sends the recovery email. All owned, no monthly tool sitting in between.

---

## Step 1 — Pre-flight check

Before building anything, check:

1. Read `~/.secrets` — confirm Stripe API key and email tool API key exist. If either is missing, stop and tell the client:
   > "I need your Stripe API key and your email tool API key in ~/.secrets before I can wire this up. I'll tell you exactly what to add and where to get each one — I'll never ask you to paste a key into this chat."
   Then walk them through getting each key and storing it in `~/.secrets`.

2. Ask: "What's your website address (domain), and which product is this recovery for?"

3. Ask: "Do you already have a payment-listener file on your server — the file that handles Stripe webhook events?" If yes, ask for the file path. If no, note that it needs to be created as part of this setup.

4. Check if Telegram is configured in `~/.secrets` (bot token). If yes, it can be used for a test confirmation buzz. If no, skip the Telegram step — not required for recovery to work.

---

## Step 2 — Configure Stripe webhook (failed payments only)

Run this:

> Wire up lost-cart recovery for my [product name] funnel.
>
> My Stripe and email-tool keys are already in ~/.secrets — read them from there. NEVER ask me to paste a key into this chat.
>
> Step 1: Tell me exactly what to set in Stripe so it pings my server ONLY on a failed payment — specifically the `payment_intent.payment_failed` event. Tell me which other events to leave OFF so I don't trigger the five-emails-per-cart mistake (where every Stripe ping fires a separate email enrolment).
>
> Walk me through the exact clicks in Stripe to add the webhook endpoint — which menu, which field, which event to select.

Wait for the client to confirm they've set up the Stripe webhook before continuing.

---

## Step 3 — Update the payment listener

Run this after the webhook is confirmed:

> Now show me the change to my payment-listener file at [file path].
>
> The change should:
> 1. Catch the `payment_intent.payment_failed` event specifically (not all events)
> 2. Extract the buyer's email and what they were trying to buy
> 3. Call my email tool to trigger the recovery email sequence
> 4. Include a deduplication check — if this buyer already got a recovery email for this cart in the last 24 hours, skip it
>
> Save a copy of the current file first. Show me the exact lines you're adding before touching the file. Wait for me to say "apply it" before saving.

Apply using the safe-edit ritual (save copy → show diff → confirm → log the change).

---

## Step 4 — Draft the recovery email

Run this:

> Draft the recovery email for this funnel. Read content/voice-dna.md for the client's voice.
>
> The email:
> - Subject line: plain, not urgent, not "did you forget" — something like "Your order didn't go through" or "Quick note about your [product name] order"
> - Opening: say what happened in one plain sentence. The card didn't go through — that's all.
> - Middle: give them a new payment link and an Apple Pay / Google Pay option if available
> - Close: one line inviting a reply if something went wrong or they have a question. Not a sales push.
> - Tone: take-it-or-leave-it. They wanted the product. Just give them a practical way to complete it.
>
> Match the client's voice from voice-dna.md. If voice-dna.md doesn't exist, write it plainly — no urgency, no pressure, no "last chance."
>
> Show me the draft before wiring it into the email tool.

Show the draft to the client. Iterate on tone or wording if anything feels off. Once approved, wire it into the email tool as a triggered automation: "when this webhook fires → send this email now."

---

## Step 5 — Test with a declining card

Run this:

> Give me the Stripe test card numbers that always decline — I need to run a test purchase to confirm the recovery email fires within 6 minutes.
>
> Also tell me:
> 1. Which logs to check to confirm the webhook fired
> 2. What timestamp to expect on the recovery email (should be within 6 minutes of the declined charge)
> 3. How to confirm the email actually arrived vs. just being triggered

Walk the client through a test purchase using a declining test card. Confirm:
- Stripe webhook fired (check Stripe webhook log)
- Payment listener caught it (check server log)
- Recovery email landed within 6 minutes (check email tool sent log)

If any step fails, diagnose from the logs before retrying.

---

## Watch Out For

- **Failed payment only.** Stripe fires many events per purchase — `payment_intent.created`, `payment_intent.succeeded`, `charge.succeeded`, etc. Wire ONLY `payment_intent.payment_failed`. Subscribing to all events is how one buyer gets five emails.
- **One recovery email per cart.** Build the dedup check. If the card fails twice, one email. Not two.
- **No follow-up drip.** One recovery email, then silence. If they don't act on it, that's their answer. No "just checking in" 48 hours later.
- **Not sales-y.** "Last chance!" reads like a chase. They already decided to buy. Just give them the practical fix.
- **Never paste keys in the chat.** All keys go in `~/.secrets`. The client hands them directly to the secrets file — they never appear in a Claude message.
- **Test before calling it done.** An untested recovery flow is not a recovery flow. Make a real declined-card test purchase and watch the email land.
