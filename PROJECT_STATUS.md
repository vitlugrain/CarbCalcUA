# CarbCalc UA — Project Status

Updated: 2026-09-13
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current workstream

Systematic expansion of the product catalog using Zakaz.ua as discovery source and official manufacturer data as the preferred nutrition/EAN verification source. GitHub is the source of truth; chat history is not the persistence layer.

Active category: **Крупи та бобові**. Work is category-first and gap-first: compare current CarbCalc UA coverage before adding retail SKUs, avoid low-value branded duplicates, and isolate conflicting records before runtime integration.

## APK / runtime checkpoint — #112 VERIFIED STABLE

Android APK workflow **#112 is GREEN / SUCCESS and verified on the user's Android device**.
- Workflow run ID: `34754770248`
- Head commit: `c1d3169450b4d1a9c63e72798ef6582ad5f8ba39`
- Artifact: `CarbCalcUA-0.6.0-build-112`
- Installed successfully over the previous build without removing local app data.
- User verified: Add Food opens without hanging; adding works both from the Add menu and from Diary; search works for old and newly added products; performance is normal.

### #105 regression and fix

APK #105 was green in CI but hung on the Add Food screen with a white screen and spinner. Investigation found two issues:
1. verified catalog records can use audit nutrition fields such as `carbs_100g`, `protein_100g`, `fat_100g`, `kcal_100g`, while the older runtime parser expected `carbs`, `protein`, `fat`, `calories`; this could make a single newly merged record abort catalog loading;
2. the large catalog was repeatedly loaded/parsing from `FutureBuilder` during rebuilds, causing increasing slowdown as the database grew.

Fixes completed before #112:
- runtime Product parser accepts the verified/audit nutrition field variants safely;
- full runtime catalog parsing is covered by CI tests;
- base product catalog is cached for the app session;
- the three asset catalogs are loaded in parallel;
- Add Food keeps one product-loading Future instead of restarting full loading on each rebuild;
- Add Food now displays a concrete load error and retry action instead of an endless spinner.

The performance optimization used by APK #112 is currently applied by `scripts/apply_runtime_catalog_performance_fix.py` in the Android APK workflow. It has been device-verified. A later cleanup should fold the same tested code directly into `lib/main.dart` and then remove the build-time patch step; do not change behavior during that cleanup.

## TM Рудь — CLOSED

The current Zakaz.ua-driven TM Рудь audit is complete. Covered frozen vegetables/berries, ice cream/frozen desserts, dairy/butter/glazed curds, bakery/desserts and current frozen semi-finished retail gaps. Products officially marked `тимчасово не виробляється` are excluded. Incomplete/ambiguous records remain in pending-review files; missing nutrition values must never be invented.

Verified source files include:
- `assets/rud_verified_part1.json` … `rud_verified_part7.json`
- `assets/rud_icecream_verified_part1.json` … `rud_icecream_verified_part11.json`
- `assets/rud_non_icecream_verified_part1.json`
- `assets/rud_curds_verified_part2.json`
- `assets/rud_final_verified_supplement.json`
- `assets/rud_final_retail_verified.json`
- `assets/rud_frozen_semis_verified_final.json`

Pending files are intentionally excluded from runtime integration.

## Runtime catalog integration

The app consumes `assets/products.json` with runtime fields such as `carbs`, `protein`, `fat`, `calories`, `barcode`. Audit files can use several source schemas, so direct concatenation is unsafe.

Integration path includes:
- `scripts/merge_verified_catalogs.py`
- `scripts/merge_rud_catalog.py`
- `scripts/build_ua_branded_db.py`
- `.github/workflows/android-apk.yml`
- runtime catalog validation tests before APK creation.

Important integration/build commits from 2026-09-13 include:
- `7cc0cdde7f4387706eb30f0ba5a70a3ddbf64eec` — safe Rud runtime merge script.
- `0f423080b48b84157c1f06aa8ef86d9059ee206d` — Rud integration in canonical verified merge.
- `644a9f1963baeb62b193e44106a138c2719653f7` — batch Rud deduplication/normalization.
- `642092f74a87968ceb2274e789e1d12a9ca799d8` — safer runtime numeric parsing diagnostics.
- `25c8e6b6b9079f702a87eef32688ef3d5e7f7b98` — runtime support for verified catalog nutrition schemas and full-catalog parsing protection.
- `9e975e2374ff5572e72f26e30c91ba4f31388fb6` — runtime catalog performance patch script.
- `c1d3169450b4d1a9c63e72798ef6582ad5f8ba39` — APK workflow applies the device-verified catalog cache/performance fix; APK #112.

## Catalog audit direction

- `Рудь` — CLOSED.
- `Danone` — STOPPED / SKIPPED for now. The current Danone discovery was predominantly dairy variants belonging to product groups already represented in the database. Do not spend time exhaustively auditing Danone unless a genuinely new product group or a concrete missing high-value SKU is identified.
- `Zakaz.ua — Крупи та бобові` — IN PROGRESS and is the active category.

### Крупи та бобові checkpoint

Existing runtime comparison confirms that common generic dry buckwheat, millet, pearl barley, corn grits and couscous are already represented, alongside many cooked cereal variants. These should not be duplicated merely because Zakaz.ua lists another brand or package size.

First verified gap batch:
- file: `assets/zakaz_grains_legumes_verified_part1.json`
- commit: `67fef156035931916e608e1eeb7e4feb03c9b8f5`
- 7 verified retail gaps: red lentils, green lentils, dry chickpeas, dry bulgur, dry semolina, spelt and Artek wheat groats.

Pending review:
- file: `assets/zakaz_grains_legumes_pending_review.json`
- commit: `25c83bdb9f6ba9a971ed01affc321753feb029aa`
- mung beans: conflicting nutrition values across current retail sources for the same EAN/SKU;
- quinoa mix: identical consumer-facing 200 g product/nutrition appears under multiple EANs and needs package-variant confirmation.

The verified Zakaz grains file is **not yet wired into the canonical runtime merge**. Finish a broader category gap pass first, then integrate the category batch once through the canonical merge and runtime parse test rather than rebuilding after each small discovery batch.

## Zakaz.ua expansion strategy

Use Zakaz.ua for current retail discovery. Work category-first and gap-first rather than blindly importing every SKU.

For each candidate product/group:
1. check whether the product/group is already represented in the runtime/audit catalog;
2. prefer new product groups and high-value/common Ukrainian retail items;
3. capture exact consumer-facing name/brand and EAN/barcode where available;
4. verify nutrition from the official manufacturer when available; otherwise retain a clearly identified current retail source;
5. never invent missing protein/fat/carbohydrate values;
6. isolate incomplete, conflicting or uncertain records in pending review;
7. deduplicate same recipe/nutrition across package sizes where the schema permits;
8. commit significant verified batches to `dev-large-update` and keep audit/status files current.

## Exact next actions

1. Treat **APK #112 as the current stable Android checkpoint**. Do not use #105 as a runtime baseline.
2. Continue the **Крупи та бобові** gap map: dry rice variants (basmati, jasmine, parboiled, round/sushi where nutritionally useful), wheat/barley variants, lentils/beans, quinoa/mung and less-common grains.
3. Do not duplicate already-covered generic staples merely for another brand/package.
4. Verify new gaps in manageable files; conflicting records remain pending.
5. After the category pass is broad enough, add the verified Zakaz grains files to the canonical runtime merge, run the full runtime catalog parse test, build one APK checkpoint and device-test search/performance.
6. Then move to the next Zakaz.ua category, expected to be pasta.
7. Later, after catalog work is at a convenient checkpoint, fold the already-tested runtime performance patch directly into `lib/main.dart` and remove the build-time patch step without changing behavior.

## Working rules

- Discovery source: Zakaz.ua.
- Verification priority: official manufacturer source when available.
- Verify EAN/barcode where available.
- Never invent missing protein/fat/carbohydrate values.
- Uncertain/incomplete records go to pending review, not the verified runtime catalog.
- Same recipe + same nutrition across package sizes should be one base food with SKU/package variants where schema permits, not duplicate foods.
- Active audit branch: `dev-large-update`.
- Do not perform catalog-audit work on `main`.
- Preserve existing app behavior and signing/update continuity while expanding catalog data.
- GitHub is the durable source of truth for audit state.

## Chat continuity rule

This file plus `CATALOG_AUDIT_STATUS.md` is the canonical handoff point for the next ChatGPT conversation. On a new chat, read both files from branch `dev-large-update` and continue from the `Exact next actions` section.
