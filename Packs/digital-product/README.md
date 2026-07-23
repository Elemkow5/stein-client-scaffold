# Digital Product Pack
[[Stein for Clients]]

An optional add-on to the base Stein scaffold for clients who are building and selling digital products with Claude.

---

## What This Pack Adds

Three modules that drop on top of the base install. Install all three or pick what the client needs.

| Module | Skills | What It Does |
|--------|--------|--------------|
| **Voice File** | `/voice-build`, `/voice-check` | Builds and sharpens the client's voice profile from their own writing |
| **Funnel Builder** | `/funnel-map`, `/funnel-edit`, `/funnel-recover` | Maps 7-piece funnels, safe-edit ritual, lost-cart recovery |
| **Validate** | `/validate` | Sell-before-you-build test — runs cheapest validation before any build |

---

## How to Install

Run from the client's vault root:

```bash
bash /path/to/_CLIENT_SCAFFOLD/Packs/digital-product/install.sh
```

Or manually copy:
- `.claude/skills/[skill-name]/` → client's `.claude/skills/`
- `Brain/content/` → client's `Brain/content/` (won't overwrite existing voice-dna.md)

---

## Dependencies

**Voice File module** — no dependencies beyond the base install.

**Funnel Builder module** — requires:
- Stripe API key in `~/.secrets` (for `/funnel-recover`)
- Email tool API key in `~/.secrets` (for `/funnel-recover`)
- Telegram bot token in `~/.secrets` (for alerts — set up during `/funnel-recover`)
- Skills degrade gracefully if keys are missing — they tell the client what to set up first.

**Validate module** — no dependencies beyond the base install.

---

## Who This Is For

Clients who are:
- Building digital products (web apps, mini tools, courses, workshops)
- Running sales funnels with Stripe
- Publishing content and want it to sound like them, not generic AI
- Wanting to validate ideas before building them

Not needed for clients using Stein purely as a personal OS (planning, comms, knowledge management).
