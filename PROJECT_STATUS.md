# CarbCalc UA — Project Status

Updated: 2026-09-13
Branch: `dev-large-update`

## Current workstream

Audit and expansion of the product catalog using Zakaz.ua as the discovery source, with nutrition values and EANs verified against official manufacturer pages whenever available.

## TM Рудь — CLOSED

The current Zakaz.ua-driven audit of TM Рудь is closed. The pass covered frozen vegetables/berries, ice cream and frozen desserts, dairy/butter/glazed curds, bakery and current frozen-semi-finished retail gaps.

CLOSED means the current systematic Zakaz.ua audit is complete. Manufacturer-only historical/Horeca products are not implied to be complete. Products marked `тимчасово не виробляється` remain excluded. Incomplete/ambiguous records remain in pending-review files; missing nutrition values must never be invented.

### Verified Rud audit files

Frozen vegetables/berries:
- `assets/rud_verified_part1.json` … `assets/rud_verified_part7.json`
- pending: `assets/rud_pending_review.json`

Ice cream / desserts:
- `assets/rud_icecream_verified_part1.json` … `assets/rud_icecream_verified_part11.json`
- `assets/rud_final_verified_supplement.json`
- `assets/rud_final_retail_verified.json`
- pending: `assets/rud_icecream_pending_review.json`

Non-ice-cream / curds / retail:
- `assets/rud_non_icecream_verified_part1.json`
- `assets/rud_curds_verified_part2.json`
- `assets/rud_frozen_semis_verified_final.json`

Final retail-gap additions included DOCHI desserts, Fruit Bites blueberry, Kochubey's Oaks variants, frozen butter croissants, current dumplings/vareniki and other verified retail gaps.

Final batch commits:
- `7ca63221cd18e6057724e401bfa3826497802316` — final dessert/bakery retail gaps
- `af854cbe26a5419deb1946da01cc6bb0f3a5e053` — final frozen-semis batch

### Audit flags preserved

- IMPERIUM «Празький» 500 g: unusual manufacturer-published EAN prefix; preserve and recheck if needed.
- «СЕЛЯНСЬКЕ» family pack: official URL/card weight mismatch remains flagged.
- «ЕСКІМОС» ВАНІЛЬ — ПОЛУНИЦЯ — ШОКОЛАД: official sugars/carbohydrates inconsistency remains flagged.
- Manufacturer nutrition has priority over Zakaz.ua when EAN/recipe match.
- Croissants: manufacturer EAN `4823097809549` is canonical.
- Kochubey's Oaks provenance under Rud retail branding / АТ Полтавхолод must be preserved.

## 11–12 September catalog integration audit

The app consumes canonical fields in `assets/products.json` (`carbs`, `protein`, `fat`, `calories`, `barcode`). Rud audit files use source/audit fields such as `carbs_100g`, `protein_100g`, `fat_100g`, `kcal_100g`, `ean`, so they must not be appended directly.

A dedicated safe integration path was added:
- `scripts/merge_rud_catalog.py` — commit `7cc0cdde7f4387706eb30f0ba5a70a3ddbf64eec`
- `.github/workflows/rud-catalog-merge.yml` — commit `4957a9cf5c3f597f8bbb08659a45c6b24db58caa`
- retrigger/checkpoint commit `7c9db5da908ae4f97776a04985c093e58dd9a6c1`

The Rud merge converts audit fields to the app schema, excludes pending-review files, checks duplicate IDs/EANs, and skips products already present in the base.

The canonical `scripts/merge_verified_catalogs.py` now invokes the Rud merge automatically, so future catalog regeneration cannot silently omit verified Rud products:
- commit `0f423080b48b84157c1f06aa8ef86d9059ee206d`

At the moment this checkpoint was written, the last confirmed committed regeneration of `assets/products.json` was still `72b6fb239f3ef48eeb1c5cf35173a7661c6f802b`; the new GitHub Actions regeneration had been triggered but its bot commit had not yet appeared. Do not claim the persistent products.json merge completed until a newer products.json commit is visible.

## APK build checkpoint

`.github/workflows/android-apk.yml` was updated so `dev-large-update` builds signed APKs and the build explicitly runs `scripts/merge_rud_catalog.py` before creating the branded offline database.

Build-trigger commit:
- `757fcc087f66a77cae13cdc4b599ef2516ae8ca0`

Therefore APKs built from this updated workflow include the verified Rud merge even if the separate products.json bot commit is still pending. Confirm the Actions result/artifact before declaring the APK build successful.

## Catalog audit registry

General manufacturer progress is tracked in `CATALOG_AUDIT_STATUS.md`. TM Рудь is CLOSED; the next manufacturer audit is Danone after the integration/build checkpoint is confirmed.

## Deduplication rule

If the same recipe is sold in multiple package sizes with identical nutrition, keep one base product and attach package/EAN variants as SKUs where the app schema supports it. Do not create duplicate foods merely for package size.

## Next exact step

1. Confirm a new `assets/products.json` bot commit after `72b6fb239f3ef48eeb1c5cf35173a7661c6f802b` and inspect the Rud integration result.
2. Confirm the Android APK workflow triggered from the dev branch and obtain the successful APK artifact/build number.
3. Test representative Rud products by name and barcode in the APK.
4. Then continue the Zakaz.ua manufacturer audit with Danone.

## Working rules

- Discovery source: Zakaz.ua.
- Verification priority: official manufacturer page.
- Verify EAN where available.
- Never infer missing protein/fat/carbohydrate values.
- Keep uncertain items in pending review.
- Official `тимчасово не виробляється` products are excluded from the current verified catalog.
- GitHub branch for this audit: `dev-large-update`.

## Chat continuity rule

This file is the canonical handoff point for continuing the project in a new ChatGPT conversation. Update it after every significant catalog integration/build checkpoint and each major manufacturer/category block.
