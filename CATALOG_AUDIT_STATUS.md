# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-13
Branch: `dev-large-update`

This is the durable registry for the Zakaz.ua catalog audit. GitHub is the source of truth; chat history is not the persistence layer.

## Workflow

`Zakaz.ua discovery → category/group gap check → brand/SKU selection → EAN + nutrition verification → pending review for uncertainty → dedup → runtime integration → final gap check`

Verification priority: official manufacturer source when available; Zakaz.ua is the discovery/current-retail source. Never infer missing nutrition values.

## Brand / workstream registry

| Brand / workstream | Status | Scope / categories | Last checkpoint | Notes |
|---|---|---|---|---|
| Рудь | CLOSED | ice cream; frozen vegetables/berries; dairy; butter; glazed curds; frozen semi-finished; dough/bakery; desserts | 2026-09-12 | Completed final audit; unresolved/incomplete records retained in pending/audit files rather than invented. |
| Danone | SKIPPED | predominantly yogurt/dairy variants already represented as product groups | 2026-09-13 | Partial discovery exists, but exhaustive audit stopped by project decision. Reopen only for a genuinely new product group or a concrete high-value gap. |
| Zakaz.ua category expansion | IN PROGRESS | category-first/gap-first discovery across Ukrainian retail | 2026-09-13 | New active workstream after stable APK #112. Prioritize underrepresented product groups and common products; avoid low-value duplication of near-identical SKUs. |
| Zakaz.ua — крупи та бобові | IN PROGRESS | dry cereals, rice variants, legumes and pseudocereals | 2026-09-13 | Existing runtime coverage checked before additions. Part 1 verified gaps committed in `assets/zakaz_grains_legumes_verified_part1.json`; ambiguous mash/quinoa SKU data isolated in `assets/zakaz_grains_legumes_pending_review.json`. Runtime merge deferred until the category gap pass is broader. |

## Current Zakaz.ua discovery priorities

### Крупи та бобові — active

Existing catalog already covers core dry buckwheat, millet, pearl barley, corn grits and couscous plus many cooked variants. Do not add ordinary branded duplicates solely for package/brand changes when nutrition is effectively generic.

Current high-value dry-product gaps include lentils, chickpeas, dry bulgur, dry semolina, wheat groats/Artek, spelt, mung beans and selected dry rice/pseudocereal variants. The first verified gap batch contains red lentils, green lentils, chickpeas, bulgur, semolina, spelt and Artek wheat groats. Mung bean nutrition conflicts across retail sources and quinoa currently has ambiguous multiple EAN representations, so both remain pending until clarified.

Next: complete the category-wide gap map (rice variants, barley/wheat types, beans/lentils, quinoa/mung and less-common grains), then integrate verified files through the canonical runtime merge with parse tests as a gate.

### Later category families

- pasta;
- breakfast cereals/flakes;
- instant foods;
- baking ingredients;
- ready/instant foods where recipe-specific carbohydrate values matter;
- meat products and delicatessen where added starch/sugar can make generic meat values inaccurate;
- ready meals and semi-finished products with manufacturer nutrition;
- other packaged categories discovered on Zakaz.ua that are not yet represented well in CarbCalc UA.

## Status definitions

- `NOT STARTED` — identified but not audited.
- `IN PROGRESS` — active audit; partial verified batches may exist.
- `PENDING` — main pass complete but unresolved data prevents closure.
- `SKIPPED` — intentionally not exhaustively audited because it adds little new group coverage; can be reopened for a concrete gap.
- `CLOSED` — current Zakaz.ua/official-source pass completed, duplicates reviewed, uncertainty isolated in pending/audit records.

## Persistence rule

After every significant verified batch:
1. Commit the data file to `dev-large-update`.
2. Update this registry with the category/brand checkpoint.
3. Update `PROJECT_STATUS.md` after major checkpoints.

If a chat reaches its limit, resume from `PROJECT_STATUS.md` plus this registry, not from memory alone.
