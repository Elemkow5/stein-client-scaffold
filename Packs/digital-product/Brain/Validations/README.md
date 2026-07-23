# Brain/Validations/

Validation briefs — one file per idea tested.

Each file is created by `/validate` before any product is built. It captures the one-line promise, the test method, the "yes" threshold, and what a "no" means — all locked in before the test runs.

**Update the Result field after the test.** Don't delete failed validations — they're the most useful ones.

---

## File naming

`[idea-slug].md` — short, lowercase, hyphenated. Examples:
- `ai-email-course.md`
- `shopify-audit-template.md`
- `weekly-accountability-cohort.md`

## Status values

- `testing` — test is in progress
- `passed` — hit the threshold; build is authorized
- `failed` — didn't hit the threshold; see Result field for what to do next
- `paused` — test started, not finished; note why
