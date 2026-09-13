# CarbCalc UA — Project Status

Updated: 2026-09-13
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

Active workstream: **Zakaz.ua — Крупи та бобові**, now at the **FINAL GAP CHECK / FINAL DEDUP** stage. GitHub is the source of truth.

### Governing catalog rule

Do not collect brands. Brand, package size or EAN alone is not a reason for a new runtime food. Compare food type + preparation/state + P/F/C per 100 g. If an existing generic/base food is equivalent or practically equivalent, skip the branded candidate. Small label/rounding/raw-material differences do not justify duplication. New runtime records are only for genuine food/state gaps or nutritionally/culinarily meaningful subtypes.

## APK checkpoint

**APK #112 remains VERIFIED / STABLE on the user's Android device.** Workflow run `34754770248`, head `c1d3169450b4d1a9c63e72798ef6582ad5f8ba39`, artifact `CarbCalcUA-0.6.0-build-112`. Add Food, Diary add flow, search and performance were device-verified. The tested performance optimization is still applied at build time by `scripts/apply_runtime_catalog_performance_fix.py`; later it can be folded into `lib/main.dart` without behavior changes.

## Catalog workstreams

- Рудь — CLOSED and runtime integrated.
- Danone — SKIPPED unless a genuinely new product group is discovered.
- Zakaz.ua / Крупи та бобові — FINAL GAP CHECK; no runtime merge yet.

## Крупи та бобові audit

Prepared generic candidate batches cover the useful gaps discovered across lentils, chickpeas, bulgur, semolina, spelt, wheat groats, selected rice types, barley/yachna, bean subtypes, split peas, dried broad beans, oat groats and adzuki. All batches remain audit inputs until final dedup against `assets/products.json`.

Conflicting/uncertain products remain pending rather than receiving invented values: mung beans, white-bean conflicting labels, quinoa variants, red/black rice, Poltava №3 and conflicting wheat/yachna profiles.

### Brown-rice correction

The previously created `assets/zakaz_grains_legumes_verified_part3.json` candidate was a duplicate. Runtime already contains `ua_bonduelle_brown_rice_dry` (`Рис коричневий, сухий`, alias `бурий рис сухий`). Part3 has therefore been converted to `duplicate_not_for_runtime` and must never be included by the canonical merge. Correction commit: `16057941d6aa4ef70092b04848ffe6cf72bcee72`.

This correction illustrates the mandatory rule: representative branded/Zakaz data may verify a generic food, but must not create a second runtime record when that generic food already exists.

## Runtime integration state

The Zakaz grains/legumes audit files are **NOT yet wired into `scripts/merge_verified_catalogs.py`**. Do not claim these products are in the app yet.

Before integration:
1. compare every candidate in all `zakaz_grains_legumes_verified_part*.json` files against current `assets/products.json`;
2. exclude duplicate/held/pending records, including brown-rice part3 and any yachna/wheat candidate whose subtype is not defensible;
3. add only surviving generic gaps to the canonical merge;
4. run the full runtime catalog parse validation/test gate;
5. build one Android APK checkpoint and have the user test search/Add Food/performance;
6. only after a successful device test mark Крупи та бобові CLOSED.

## Next category

After grains/legumes integration is device-verified, move to **Макаронні вироби**. Use the same category-first, gap-first, cross-brand generic nutritional dedup method instead of SKU-by-SKU importing.

## Working rules

- Zakaz.ua is the discovery/current-retail source; official manufacturer data is preferred for verification.
- Never invent missing P/F/C.
- Uncertain/incomplete/conflicting records stay pending and out of runtime.
- Active branch is `dev-large-update`; do not audit on `main`.
- Preserve app behavior, signing/update continuity and local-data upgrade path.
- `CATALOG_AUDIT_STATUS.md` plus this file are the canonical chat handoff.
