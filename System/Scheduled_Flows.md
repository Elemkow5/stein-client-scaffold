# Scheduled Flows

Registry of every automated workflow running in this system. Updated by `/Let's-Go` when agents are created, and manually when anything changes.

The weekly health report reads this file to surface what's running, what's stalled, and what needs attention.

---

## Active Flows

| Name | Schedule | What it does | Last run | Status |
|---|---|---|---|---|
| Competitor Intel | Bi-weekly Mon @ 6:30 AM | Runs /competitor for all active competitors → updates Intelligence/Competitors/ files + saves weekly digest to Intelligence/Weekly/ | — | ⬜ not yet scheduled |
| Daily Digest | Daily @ [time from integrations.yaml] | Pulls calendar, email, tasks → emails digest + saves Brain/Daily/ | — | ⬜ not yet scheduled |
| Weekly Health Report | Every Monday @ 7:00 AM | Vault activity summary → emails Andrew with flags and call agenda; saves System/Health_Reports/ | — | ⬜ not yet scheduled |

---

## How to Add a Flow

When a new scheduled agent is created via `/Let's-Go` or manually:
1. Add a row to the Active Flows table above
2. Fill in: name, schedule (human-readable), what it does, and set status to ✅ running
3. The health report will pick it up automatically on the next Monday run

## Status Key

| Symbol | Meaning |
|---|---|
| ✅ | Running — last run was successful |
| ⚠️ | Warning — last run had issues or is overdue |
| ❌ | Failed — needs attention |
| ⬜ | Not yet scheduled |
| ⏸ | Paused |
