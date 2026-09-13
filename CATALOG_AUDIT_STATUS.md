# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-13
Branch: `dev-large-update`

This is the durable registry for the Zakaz.ua catalog audit. GitHub is the source of truth; chat history is not the persistence layer.

## Workflow

`Zakaz.ua discovery → brand → brand categories → SKU/EAN + nutrition verification → pending review for uncertainty → dedup by recipe/package SKU → final gap check → CLOSED`

Verification priority: official manufacturer source when available; Zakaz.ua is the discovery/current-retail source. Never infer missing nutrition values.

## Brand registry

| Brand | Status | Scope / categories | Last checkpoint | Notes |
|---|---|---|---|---|
| Рудь | CLOSED | ice cream; frozen vegetables/berries; dairy; butter; glazed curds; frozen semi-finished; dough/bakery; desserts | 2026-09-12 | Completed final audit; unresolved/incomplete records retained in pending/audit files rather than invented. |
| Danone | IN PROGRESS | yogurt; Greek-style yogurt; milk drinks/cocktails; ayran/fermented drinks; desserts; child-oriented dairy sub-brands listed under Zakaz Danone filter | 2026-09-13 | Selected as next brand. Zakaz.ua Kyiv brand page currently exposes 26 items; audit begins with current yogurt range. |

## Status definitions

- `NOT STARTED` — brand identified but not audited.
- `IN PROGRESS` — active audit; partial verified batches may exist.
- `PENDING` — main pass complete but unresolved data prevents closure.
- `CLOSED` — current Zakaz.ua/official-source pass completed, duplicates reviewed, uncertainty isolated in pending/audit records.

## Persistence rule

After every significant verified batch:
1. Commit the data file to `dev-large-update`.
2. Update this registry with the brand/category checkpoint.
3. Update `PROJECT_STATUS.md` with the exact next action and relevant commit/file names.

If a chat reaches its limit, resume from `PROJECT_STATUS.md` plus this registry, not from memory alone.
