---
name: stein-doctor
description: System health check — tells you the honest state of your setup. What's working, what's stale, what needs attention. Run weekly or when something feels off.
user-invocable: true
allowed-tools:
  - Read
  - Bash
---

# /stein-doctor — System Health Check

A plain-truth audit of your system. No sugarcoating. Run this to know whether things are actually working or quietly falling apart.

---

## Step 1 — Session Log Health

Check how recently the session log was updated:
```bash
ls -t "Brain/Session_Logs/" | head -3
```

Read the most recent session file. Check its last entry.

- ✅ Last entry within 48 hours
- ⚠️ 2–7 days since last entry
- 🔴 More than 7 days since last entry

---

## Step 2 — Inbox Status

Read `Brain/Inbox.md`. Count open items. Find the oldest one.

- ✅ 0–3 items, oldest < 7 days
- ⚠️ 4–9 items or oldest 7–30 days
- 🔴 10+ items or oldest > 30 days

---

## Step 3 — Commitments Audit

Read `Brain/Commitments.md`. List all open `- [ ]` items where the due date has passed today.

- ✅ No overdue commitments
- ⚠️ 1–3 overdue
- 🔴 4+ overdue, or any item > 30 days past due

---

## Step 4 — Stale Projects

Read `Brain/Master.md`. For each active project section, find the most recent completed task or dated entry. Flag any project with no activity in 12+ days as **stale**.

```bash
grep -n "\[x\]" "Brain/Master.md" | tail -20
```

Format stale items as:
```
⚠️ STALE: [Project] — last activity [date] ([X] days ago)
```

---

## Step 5 — People File Gaps

```bash
grep -rL "Last contact:" "Brain/People/" 2>/dev/null | grep "\.md$" | grep -v "_template"
```

List any People files missing a `Last contact:` field — these are incomplete.

Also scan for People files where Last contact is > 60 days ago — flag these as potentially cold relationships.

---

## Step 6 — Integration Health

Read `System/integrations.yaml`. For each enabled integration, check whether it's been used recently (any reference in the last 7 days of session logs). Flag any integration that's configured but shows no evidence of activity.

---

## Step 7 — Output the Report

```
🩺 STEIN DOCTOR — [Date]

SESSION LOG     [✅/⚠️/🔴]  [finding]
INBOX           [✅/⚠️/🔴]  [finding]
COMMITMENTS     [✅/⚠️/🔴]  [finding]
STALE PROJECTS  [✅/⚠️/🔴]  [findings or "all active"]
PEOPLE FILES    [✅/⚠️/🔴]  [findings or "all current"]
INTEGRATIONS    [✅/⚠️/🔴]  [findings or "all active"]

OVERALL: [one honest sentence]

ACTION ITEMS:
- [specific thing to address, if any]
```

---

## Notes

- Run weekly — best on Sunday or Monday, alongside /checkin.
- Red flags are information, not failure. The system exists to serve you.
- A stale project isn't a broken system — it's a signal to either act or formally park it.
