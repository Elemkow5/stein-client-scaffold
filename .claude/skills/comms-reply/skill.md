---
name: comms-reply
description: Draft a reply to any message from the triage list in the client's voice, tone-matched to the channel. Client reviews and sends manually — nothing is ever sent automatically.
user-invocable: true
---

# /comms-reply — Draft a Reply

Drafts a reply to any message in the client's voice. Tone is matched to the channel — email, Slack, Teams, and LinkedIn each get a different register. Client reviews, edits if needed, and sends manually. Nothing is ever sent automatically.

---

## Instructions

### Step 1 — Identify the thread

If the client named a thread after `/comms-triage` (e.g. "reply to the one from Marcus" or "reply to #3"):
- Match it to the triage list from this session
- Pull the channel and sender

If the client invoked `/comms-reply` without context, ask:
> "Which thread? You can name the sender, paste the message, or give me the number from the triage list."

### Step 2 — Pull the full thread

Pull the full thread history via the appropriate channel MCP or source:
- **Email (Google):** Gmail MCP — full thread including prior replies
- **Email (Microsoft):** M365 Connector — full Outlook thread
- **Slack:** Slack MCP — full DM or channel thread
- **Teams:** M365 Connector — full Teams chat thread
- **LinkedIn:** `Brain/Comms/LinkedIn_Queue.md` — the full entry for this sender

Read enough of the thread to understand context, tone of the relationship, and what's being asked.

### Step 3 — Load context

Read in order:
1. `Brain/People/[Sender Name].md` — if a People page exists, read it. Note: relationship type, last interaction, open items, anything sensitive.
2. `Personality/[Name].md` — client's identity, how they present themselves, their voice
3. `Personality/Working_Preferences.md` — communication style, tone rules, length preferences. Look for a `## Communications` or `## Email` section if it exists.
4. Any project files the context injector surfaced — if the thread mentions an active project, those files may already be in context.

### Step 4 — Draft the reply

Write the draft. Apply channel-specific tone:

**Email:**
- Full sentences, proper grammar
- Length matched to the ask: short acknowledgment for FYI, full response for a question or proposal
- Signature if the client uses one (check Working_Preferences.md)
- No unnecessary preamble ("Hope this finds you well" — avoid unless it matches their style)

**Slack:**
- Conversational, direct, concise
- Sentence fragments are fine
- Emoji acceptable if that matches the client's Slack style (check Working_Preferences.md)
- 1-3 sentences for most replies; longer only if genuinely needed

**Teams:**
- Professional but not stiff
- Slightly more formal than Slack, less formal than email
- No emoji unless clearly part of the team culture

**LinkedIn:**
- Professional-warm
- Relationship-aware — reference shared context if a People page exists
- Never salesy or pitchy unless the client explicitly asks for it
- 2-4 sentences is usually right

### Step 5 — Present the draft

Output:

```
Draft — [Channel] reply to [Sender]
─────────────────────────────────
[The draft, ready to copy]
─────────────────────────────────
Angle: [One sentence on why this tone/approach — e.g. "Kept it brief since this is a quick status check from a long-term client."]
```

Then offer:
> "Ready to send, or want a different angle?"

If the client says the draft is off (tone, length, angle):
- Ask what's wrong in one question if it's not clear
- Redraft immediately with the correction applied
- If the correction reveals a missing preference (e.g. "I never open with thanks"), update `Personality/Working_Preferences.md` under `## Communications` silently, then confirm: "Got it — updated your preferences so this doesn't happen again."

### Step 6 — After approval

When the client says it's ready:
> "Copy that into [Gmail / Outlook / Slack / Teams / LinkedIn] and send when you're ready. Nothing goes out from here."

Do not attempt to send via MCP. Read-only access only.

Optionally offer:
> "Want me to log this interaction to [Sender]'s People page?"

If yes — append a brief note to `Brain/People/[Sender].md` under the interaction log: date, topic, outcome ("Replied re: Q3 proposal — moved to next step").

---

## Notes

- Never send. The workflow always ends at draft-in-Claude.
- If no People page exists for the sender and the thread seems significant, offer to create one after the reply is approved — not before, so it doesn't interrupt the drafting flow.
- If Working_Preferences.md has no Communications section yet, draft from the general voice in Personality/[Name].md and ask at the end: "Want me to save any preferences from this reply for next time?"
- If the thread is ambiguous (multiple possible interpretations of what they want), call it out before drafting: "This could be a simple yes/no or they might want a full breakdown — which way do you want to go?"
