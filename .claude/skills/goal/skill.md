---
name: goal
description: Conversational goal-setting session. AI walks the client through escape/arrival framing, beneficiary and stakes, confidence rating, SMART framing, milestones, and tasks — then creates a goal file and syncs deadlines to calendar and Master.md.
user-invocable: true
allowed-tools:
  - Read
  - Write
  - Edit
---

# /goal — Goal Setting

A fully conversational goal intake. AI leads with questions — client answers. The goal file is built from the dialogue.

One question at a time. Let them finish before moving on.

---

## The Question Sequence

### G1 — The Goal

"What's the goal?"

Keep it open. Don't constrain format. Let them describe it in their own words.

---

### G2 — The Deadline

"By when do you want to achieve this?"

Get a specific date. If they're vague ("sometime this year"), push: "What month? Give me a date you'd be proud to hit."

---

### G3 — Escape

"Describe where you are right now — before this is achieved. This is the escape: the starting point of the journey. What does your life or work look like today, without this goal done?"

This is about contrast. The more vivid, the better. Let them sit in it.

---

### G4 — Arrival

"Now describe arrival. When this goal is achieved, what does your life or work actually look like? Be specific — what's different? What can you do or feel that you can't right now?"

If their answer is vague, ask: "What's the most concrete thing that changes?"

---

### G5 — Beneficiaries

"Who else benefits if you achieve this? This goal doesn't have to be just about you — who else is affected by whether you succeed or fail?"

Could be a partner, a child, a team, clients, or a community. Let them name the people.

---

### G6 — The Beneficiary Conversation

"I want you to imagine two conversations.

First: you achieved the goal. You're sitting with [beneficiary they named]. What do they say to you? What do you tell them?

Second: you didn't achieve it. Same person, same conversation — but the goal wasn't reached. What does that conversation sound like?"

Give them space. This is the emotional core of the exercise. Don't rush past it.

After they respond, reflect back what you heard: "So what's really at stake is [what you heard]. Is that right?"

---

### G7 — Personal Stakes

"Beyond [beneficiary] — what's at stake for you personally? What do you gain if you achieve this? What do you lose if you don't?"

Both sides. Positive and negative. Let both land.

---

### G8 — Confidence Rating

"On a scale of 1 to 10 — how confident are you that you'll actually achieve this goal?"

Wait for their number.

If they say 8 or below: "What would need to be true to make that a 9?"

This surfaces hidden blockers. Listen carefully — their answer often reshapes the milestones.

---

### G9 — SMART Framing

Based on everything they've shared, draft the goal in SMART format and read it back:

> "Here's how I'd frame this goal:
> **[Goal name]** — [Specific, Measurable, Achievable, Relevant, Time-bound statement]
> Target date: [DATE]
>
> Does that capture it? Anything to adjust?"

Revise based on their feedback until they confirm it.

---

### G10 — Milestones

"Let's break this into milestones — the major checkpoints on the way from escape to arrival. What are the 3 to 5 key stages you need to pass through?"

If they're not sure where to start, offer: "Think about it in thirds. What needs to be true at the one-third mark? Two-thirds? Then arrival."

For each milestone:
- Get a name / description
- Get a target date
- Ask: "What do you need to accomplish this milestone? Resources, decisions, people?"

---

### G11 — Tasks

For each milestone, ask: "What are the first 2-3 concrete tasks to move this forward? Each one needs a deadline."

Write them as:
```
- [ ] [Task description] — due [DATE]
```

---

### G12 — Write the Goal File

Save to `Goals/[slug].md`:

```markdown
# [Goal Name]
**Created:** [DATE]
**Target:** [DEADLINE]
**Status:** active

## SMART Goal
[SMART statement from G9]

## Escape
[Their words from G3]

## Arrival
[Their words from G4]

## What's at Stake
**Beneficiary:** [Name(s) from G5]
**If achieved:** [From G6 — the success conversation]
**If not:** [From G6 — the failure conversation]
**Personal stakes:** [From G7]

## Confidence
[Rating from G8] / 10
**To reach a 9:** [Their answer, or "N/A"]

## Milestones
### [Milestone 1 Name] — due [DATE]
What's needed: [From G10]
- [ ] [Task] — due [DATE]
- [ ] [Task] — due [DATE]

### [Milestone 2 Name] — due [DATE]
What's needed: [From G10]
- [ ] [Task] — due [DATE]

[Continue for all milestones]
```

---

### G13 — Sync to Master.md

Add each milestone as a task in `Brain/Master.md` under `## Backlog` (or `## This Month` if the deadline is within 30 days):

```
- [ ] [Goal Name] — [Milestone 1] due [DATE]
```

---

### G14 — Calendar Sync

If calendar integration is active in `System/integrations.yaml`, ask: "Want me to add the milestone deadlines to your calendar?"

If yes: create a calendar event for each milestone via MCP — title: "[Goal]: [Milestone]", all-day event on the deadline date.

If not connected: "Calendar isn't connected yet — you can add these manually. Here are the dates:" [list milestones + dates]

---

### G15 — Close

Read back the goal name, deadline, number of milestones, and the one sentence from the beneficiary conversation that hit hardest.

"The goal file is saved. First task due: [earliest task] on [date]. You know what's at stake."
