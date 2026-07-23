---
name: plan
description: Write a structured execution plan before any non-trivial work. Produces a plan file with approach, steps, and acceptance criteria. Use before any task that spans multiple sessions or has real complexity.
user-invocable: true
allowed-tools:
  - Read
  - Write
---

# /plan — Execution Planning

Produces a structured plan before work begins. The plan is the operating contract — work proceeds from it, not from memory or conversation.

---

## When to Use

- Before any task that spans more than one session
- Before anything with multiple steps, files, or moving parts
- Any time losing context mid-task would be costly

Skip for quick one-off changes. Use for anything real.

---

## Instructions

### Step 1 — Read Context Silently

Before writing anything, read:
1. `Personality/Priorities.yaml` — active priorities
2. `Brain/Master.md` — what's already in flight
3. The relevant project file in `Brain/Projects/` if applicable

### Step 2 — Discuss First

Share your initial read: what the objective is, the approach you're leaning toward, any scope questions or tradeoffs. Ask the client to react. Let them redirect before anything is written.

**Exception:** If the client says "just go" — skip to Step 4.

### Step 3 — One Clarifying Question (if needed)

If anything is still unresolved after the discussion, ask one focused question. One only.

### Step 4 — Write the Plan

Save to `Brain/Plans/YYYY-MM-DD-[slug]-plan.md`:

```markdown
# Plan: [Task Name]
**Date:** [DATE]
**Status:** active
**Project:** [Project name]

## What We're Doing
[One paragraph — what the finished state looks like.]

## Approach
[The method. Why this over alternatives. Name the files, tools, or patterns involved.]

## Steps
- [ ] [Step 1 — specific enough to execute without asking]
- [ ] [Step 2]
- [ ] [Step 3]

## Acceptance Criteria
- [ ] [How we know it's done]
- [ ] [Edge cases to verify]

## Files / Resources
- [File or resource — what it is and why it's relevant]

## Out of Scope
[What this plan explicitly does NOT cover]
```

### Step 5 — Present the Summary

Give the client a 3-line summary:
- What we're building
- The approach in one sentence
- How many steps, rough time estimate

Then: "Plan saved. Say go when ready."

### Step 6 — Execute

Work through steps in order. Check off each as completed by updating the plan file. Surface blockers specifically — don't improvise around them.

When done, update status to `complete`.

---

## Plan Status Values
- `active` — in progress
- `complete` — done, criteria met
- `paused` — waiting on something
- `abandoned` — decided not to do it (note why)
