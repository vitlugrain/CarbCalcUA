# CarbCalc UA — Project Status

Updated: 2026-09-17
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

GitHub is the source of truth. APK **#233** remains the current USER-TESTED STABLE Android checkpoint. Product selection/navigation works on the user's Android device. Remaining non-blocking UI issue: final `Додати до щоденника` can be partially hidden behind app/Android bottom navigation; fix bottom safe-area/scroll padding in the next meaningful catalog APK, not as a standalone build.

### Runtime integrated
1. Крупи та бобові.
2. Хліб та випічка.
3. Соуси — 8 explicitly whitelisted verified ketchups; existing Torchin block preserved.

### Closed audit checkpoints awaiting runtime whitelist/revalidation
- Макаронні вироби.
- Пластівці та сухі сніданки.
- Продукти швидкого приготування.
- Солодощі — some earlier parts need revalidation.
- Снеки — weak earlier parts need revalidation.
- Консерви — baseline 21 verified + A/B/C audit candidates.
- Напої — 27 confirmed audit identities.

### Current active audit
**Заморожені напівфабрикати.** Category-first, breadth-first. Do not exhaustively add every brand/SKU. Prefer popular representative products and materially different recipes/fillings.

Completed frozen audit blocks as of 2026-09-17:
- Levada pelmeni: `assets/frozen_semifinished_verified_part1_levada.json`, commit `b698fbb132d6035eeadfe6d8c8923660eb458517`.
- Levada varenyky: `assets/frozen_semifinished_verified_part2_levada_varenyky.json`, commit `578848d6cc0167ec1c238e2d0275e7734fddd335`.
- Hercules representative pelmeni: `assets/frozen_semifinished_verified_part3_hercules.json`, commit `10ad61210f185fe08d464c3b48288a8be83ad83e`.
- Three Bears representative pelmeni: `assets/frozen_semifinished_verified_part4_three_bears.json`, commit `4b2324f1d5d6deb6da6dd8c4635631d113e53747`.
- Three Bears cherry + sweet-cottage-cheese varenyky: `assets/frozen_semifinished_verified_part5_three_bears_varenyky.json`, commit `75c982fc893d641185c5f2b8e4ae3c9a404f0b2b`.
- Levada pancakes: `assets/frozen_semifinished_verified_part6_levada_pancakes.json`, commit `555e8d833528eec6b9ad4e433ac0c32b9f3686f7`.

Pelmeni and varenyky blocks are intentionally stopped to avoid brand/SKU bloat. Pancake/nalysnyky coverage is now representative: sweet cottage cheese, chicken, and unfilled sweet pancakes. Next: **сирники → нагетси/панірована курка → заморожена піца/тісто → other useful frozen prepared foods → revalidate existing Bonduelle frozen candidates**.

## Mandatory catalog policy

Hybrid generic + branded catalog. Simple/raw foods generic-first. Recipe/manufactured foods may be branded when nutrition materially differs. Same recipe across package sizes normally one identity. Before every SKU check branch-specific `assets/products.json`. Never invent nutrition/barcodes. Missing secondary nutrients may be null. Material carbohydrate conflicts or unclear recipe generations stay pending. Use A/B/C verification policy from `CATALOG_AUDIT_STATUS.md`.

## Instant foods rule

Dry-product nutrition stays on dry basis. Added water changes weight, not total carbs. Never invent yield/absorption coefficients. See `assets/INSTANT_FOODS_RULES.md`.

## APK checkpoint

**APK #233 — USER-TESTED STABLE**
- run ID `34860877221`
- head `7be9e02ab0f21caba4f247f4658eb1529edf72b3`
- artifact `CarbCalcUA-0.6.0-build-233`
- artifact ID `10354139918`
- digest `sha256:2fe83151372a88c1adf596388665e047dc8868e7aaafdcc3a17aacaa29d39588`
- analyze/tests/release build/publish succeeded.

Deferred UI fix for next meaningful APK: dynamic bottom padding/safe-area so `Додати до щоденника` always scrolls above app and Android navigation. Preserve the working APK #233 quantity auto-scroll behavior.

## Next integration plan

Finish a meaningful breadth-first frozen-food audit batch. Then: revalidate weak candidates → branch-specific runtime duplicate check → dedup → explicit whitelist → merge only whitelist → validate/parse/tests → apply deferred bottom-safe-area UI fix → one meaningful APK for Android testing.

## Working rule for continuation

At the start of every new chat, first read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md` from `dev-large-update`. Before updating/deleting an existing GitHub file, refetch its current blob SHA. Do not bulk-merge audit files just because filenames contain `verified`.
