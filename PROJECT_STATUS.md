# CarbCalc UA — Project Status

Updated: 2026-09-13
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current workstream

Systematic expansion of the product catalog using Zakaz.ua as discovery source and official manufacturer data as the preferred nutrition/EAN verification source. GitHub is the source of truth; chat history is not the persistence layer.

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

Important final Rud commits:
- `7ca63221cd18e6057724e401bfa3826497802316` — final dessert/bakery retail gaps
- `af854cbe26a5419deb1946da01cc6bb0f3a5e053` — final frozen-semis batch

Preserved audit flags include unusual/ambiguous manufacturer EAN or nutrition/weight cases; do not silently normalize them without re-verification.

## Runtime catalog integration — COMPLETED FOR APK BUILD

The app consumes `assets/products.json` with runtime fields such as `carbs`, `protein`, `fat`, `calories`, `barcode`. Rud audit files use several source schemas, so direct concatenation is unsafe.

Integration path:
- `scripts/merge_rud_catalog.py`
- `.github/workflows/rud-catalog-merge.yml`
- `scripts/merge_verified_catalogs.py` invokes the Rud merge automatically.
- `.github/workflows/android-apk.yml` builds `dev-large-update` and runs the verified catalog merges before APK creation.

Key integration/build fixes made on 2026-09-13:
- `7cc0cdde7f4387706eb30f0ba5a70a3ddbf64eec` — safe Rud runtime merge script.
- `4957a9cf5c3f597f8bbb08659a45c6b24db58caa` — Rud catalog merge workflow.
- `757fcc087f66a77cae13cdc4b599ef2516ae8ca0` — dev APK build with Rud integration.
- `0f423080b48b84157c1f06aa8ef86d9059ee206d` — Rud integration made part of canonical verified merge.
- `a13c79c08eaf5aa1caac7852f73f6771cf624d16` — stale GI enrichment targets no longer abort canonical merge; 21 stale IDs are skipped with warning.
- `0d42d448a3909bd3048cd88ad8eac4aec5dde39a` — Rud loader accepts alternate verified field names (`name_uk`, `barcode`, etc.).
- `74a36f0e2c55eb7ca48e2416267db4559427f513` — Rud loader accepts wrapped verified files (`products`/`items`/`records`).
- `644a9f1963baeb62b193e44106a138c2719653f7` — batch Rud deduplication/normalization, including nested `nutrition_100g`; equivalent duplicate IDs/EANs are collapsed in one pass instead of failing one-by-one.

### APK checkpoint

Android APK workflow **#105 is GREEN / SUCCESS**.
- Workflow run ID: `34748087483`
- Head commit: `644a9f1963baeb62b193e44106a138c2719653f7`
- This is the first confirmed successful APK build after the Sep 11–13 Rud integration/fix cycle.

Previous red runs in this cycle were diagnostic and fixed progressively: stale GI targets, alternate Rud field names, wrapped JSON catalog files, and conflicting/duplicate Rud EAN representations.

Note: the separate `Merge Rud verified catalog` workflow triggered at the same head may have its own persistence/commit behavior and is not equivalent to APK success. APK #105 itself is confirmed green and proves the build-time merge path succeeds.

## Catalog audit registry

`CATALOG_AUDIT_STATUS.md` is the durable brand-level registry.
- `Рудь` — CLOSED.
- `Danone` — IN PROGRESS and is the next active manufacturer.

Danone scope discovered under the Zakaz.ua Danone filter includes yogurt, Greek-style yogurt, milk drinks/cocktails, ayran/fermented drinks, desserts and child-oriented dairy sub-brands. Preserve consumer sub-brand identity (including Danonino, Ростишка, Actimel, Даніссімо) while retaining manufacturer relationship; do not flatten every consumer-facing brand name to Danone. At the selection checkpoint Zakaz.ua Kyiv exposed 26 products.

## Exact next actions for a new chat

1. Treat APK #105 as the successful build checkpoint. If needed, fetch its artifact and install/test it on Android.
2. Test several representative TM Рудь products by both name and barcode, especially final-batch items such as DOCHI, croissants, Pelmeni 100%, Eskimos dumplings and pizza base.
3. If runtime testing is satisfactory, do not reopen TM Рудь unless a concrete defect/gap is found.
4. Resume **Danone** from `CATALOG_AUDIT_STATUS.md`: Zakaz.ua discovery → category/SKU inventory → official nutrition/EAN verification → verified batch files → pending isolation → dedup → final gap check.
5. Commit each significant Danone batch to `dev-large-update`, update `CATALOG_AUDIT_STATUS.md`, then update this file after major checkpoints.
6. After Danone is CLOSED, select the next Zakaz.ua manufacturer and repeat the same brand-first process.

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

## Chat continuity rule

This file plus `CATALOG_AUDIT_STATUS.md` is the canonical handoff point for the next ChatGPT conversation. On a new chat, ask ChatGPT to read both files from branch `dev-large-update` and continue from the `Exact next actions` section. Do not rely on reconstructing the project from chat memory alone.
