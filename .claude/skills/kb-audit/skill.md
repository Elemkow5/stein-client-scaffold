---
name: kb-audit
description: Weekly knowledge graph health check — finds orphan notes, missing topic hubs, and hubs without Key Files sections. Keeps the wikilink graph useful over time.
user-invocable: true
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
---

# /kb-audit — Knowledge Graph Health Check

Audits the vault's wikilink graph and surfaces three categories of gaps. Run weekly or on demand.

---

## Instructions

### Step 1 — Orphan notes

Find files in `Brain/` with zero outbound wikilinks:

```bash
for f in Brain/Projects/*/*.md Brain/Knowledge/*.md; do
  count=$(grep -c "\[\[" "$f" 2>/dev/null || echo 0)
  if [ "$count" -eq 0 ]; then echo "ORPHAN: $f"; fi
done
```

---

### Step 2 — Names mentioned without a hub

Pull existing hub names from `Brain/Topics/INDEX.md`:

```bash
grep -o '\[\[[^\]]*\]\]' Brain/Topics/INDEX.md | tr -d '[]'
```

Scan session logs for wikilinked names appearing 3+ times without a hub:

```bash
grep -roh '\[\[[^\]]*\]\]' Brain/Session_Logs/*.md | tr -d '[]' | sort | uniq -c | sort -rn | head -20
```

Anything appearing 3+ times with no matching file in `Brain/Topics/` is a hub candidate.

---

### Step 3 — Hubs missing Key Files section

```bash
for f in Brain/Topics/*.md; do
  if ! grep -q "## Key Files" "$f" 2>/dev/null; then
    echo "NO KEY FILES: $f"
  fi
done
```

---

### Step 4 — Report

```
## KB Audit — [DATE]

### Orphan Notes ([N])
- ...

### Hub Candidates ([N])
- "Name" — N mentions, no hub yet
- ...

### Hubs Missing Key Files ([N])
- Brain/Topics/foo.md
- ...

### All Clear
✓ [any category with 0 findings]
```

---

### Step 5 — Offer to fix

After the report, ask which category to address first. Do not auto-fix without confirmation.
