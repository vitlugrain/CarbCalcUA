# CarbCalc UA — Project Status

Updated: 2026-09-21
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
- Заморожені напівфабрикати — parts 1–10 retained; discovery stopped by user.
- Молочні продукти — 6 compact verified audit parts.
- **М'ясо та м'ясні продукти — CLOSED AUDIT CHECKPOINT 2026-09-21; 4 parts, no runtime merge yet.**

### Current active audit plan before next APK
User-approved sequence: **Овочі → Фрукти/ягоди → Горіхи/насіння/сухофрукти → Картопля/страви з неї → Риба/морепродукти → runtime preparation → deferred bottom-safe-area UI fix → APK.**

## Meat products — CLOSED AUDIT CHECKPOINT 2026-09-21
Completed:
- `assets/meat_verified_part1_raw_generic.json` — raw chicken breast, pork, beef, turkey generic-first; commit `79c44ff9906e29d0e3d5133badb4b54023cab13c`.
- `assets/meat_verified_part2_sausages_ham.json` — representative cooked/dry-smoked sausage, sausages and ham; commit `a632d2f1c84b90615825792654cb6b67478f392f`.
- `assets/meat_verified_part3_sardelky_hunting_pate.json` — sardelky, hunting sausages, liver pâté; commit `4b037ecabab053b725be097c326ce7bbd360d73d`.
- `assets/meat_verified_part4_bacon_buzhenina_balyk.json` — bacon, buzhenina, pork balyk; commit `ed8cf3d6ef942463b3672b13d5873b041836f083`.

Policy outcome: plain raw meat generic-first at 0 g carbs; processed/marinated/breaded meat must not inherit 0 g automatically; processed meat uses representative generic or branded recipe-dependent profiles where carbohydrate differences matter. No runtime merge yet.

## Dairy products — CLOSED AUDIT CHECKPOINT 2026-09-18
Six compact verified parts retained; no runtime merge yet.

## Frozen convenience foods — CLOSED AUDIT CHECKPOINT 2026-09-18
Parts 1–10 retained. User stopped further frozen discovery. Known Makey syrnyky conflict remains pending. No runtime merge yet.

## Mandatory catalog policy
Hybrid generic + branded catalog. Simple/raw foods generic-first. Recipe/manufactured foods may be branded when nutrition materially differs. Same recipe across package sizes normally one identity. Before every SKU check branch-specific `assets/products.json`. Never invent nutrition/barcodes. Missing secondary nutrients may be null. Material carbohydrate conflicts or unclear recipe generations stay pending. Use A/B/C verification policy from `CATALOG_AUDIT_STATUS.md`.

## APK checkpoint
**APK #233 — USER-TESTED STABLE**
- run ID `34860877221`
- head `7be9e02ab0f21caba4f247f4658eb1529edf72b3`
- artifact `CarbCalcUA-0.6.0-build-233`
- artifact ID `10354139918`
- digest `sha256:2fe83151372a88c1adf596388665e047dc8868e7aaafdcc3a17aacaa29d39588`

Deferred UI fix: dynamic bottom padding/safe-area so `Додати до щоденника` always scrolls above app and Android navigation. Preserve APK #233 quantity auto-scroll behavior.

## Next integration plan
Finish the five user-approved categories before the next APK: vegetables, fruit/berries, nuts/seeds/dried fruit, potato/preparations, fish/seafood. Then fresh revalidation where required → branch-specific runtime duplicate check → dedup → explicit whitelist → merge only whitelist → validate/parse/tests → deferred bottom-safe-area UI fix → one meaningful APK.

## Working rule for continuation
At the start of every new chat, first read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md` from `dev-large-update`. Before updating/deleting an existing GitHub file, refetch its current blob SHA. Do not bulk-merge audit files just because filenames contain `verified`.


## Runtime integration checkpoint — 2026-09-21
- Stable tested Android checkpoint remains APK #233.
- Final catalog audit/revalidation is complete for the pre-APK integration scope.
- `assets/runtime_whitelist_preintegration_2026-09-21.json` is the explicit integration gate.
- `assets/products.json` now contains **1135 products** after controlled integration of approved audited blocks.
- Validation checkpoint: **0 duplicate IDs** and **0 duplicate barcodes across different product IDs**.
- Integrated in this cycle include canned foods, drinks, pasta, breakfast cereals, instant foods, produce gaps, nuts/seeds/dried fruit, baby food, strong meat candidates, revalidated dairy candidates, and verified frozen semifinished foods.
- Deferred/conflicting records remain outside runtime (including pending instant-food conflicts, weak meat generics, unresolved USDA/FDC-reference gaps, recipe-dependent ready meals, weak early sweets/snacks, and pending frozen syrnyky conflict).
- Next engineering step: implement the deferred bottom safe-area/scroll-padding fix for `Додати до щоденника`, preserving APK #233 quantity auto-scroll behavior; then run parse/analyze/tests and build the next APK.


## Android checkpoint — APK #295 USER VERIFIED — 2026-09-21
- GitHub Actions run: `35598700845`; artifact: `CarbCalcUA-0.6.0-build-295`; artifact ID: `10637504288`.
- Head commit: `e9b7bb2a0a3b156455a69678861e7a48c8b867a1`.
- SHA-256: `0bbf41395886ef624d47a29ae4d50705ec006effadd1951e4dcd1a0a714bdc67`.
- User installed #295 over the previous app: existing diary data was preserved.
- Product addition works.
- Bottom `Додати до щоденника` action is now displayed correctly and no longer hidden by app/system navigation.
- Initial user impression: the app feels slower / has noticeable lag. This is the primary next engineering investigation; do not change catalog data merely to mask performance.
- Runtime catalog checkpoint remains **1135 products**, with the completed controlled pre-APK integration and no known duplicate IDs/barcodes at the integration checkpoint.
- Treat APK #295 as the new tested Android functional checkpoint while performance investigation begins.


## Checkpoint 2026-09-21 — post-APK #302 semantic dedup / search

- Current user-tested Android baseline: APK #302; user reports it works well. Do not promote a new control APK yet; accumulate changes first.
- Runtime catalog after semantic duplicate cleanup: **1079 products**.
- Semantic dedup policy: simple product + same state/type => one canonical generic where safe; keep materially different state/subtype/recipe/flavor/lactose-free/fat-level/brand SKU; never average conflicting nutrition.
- Recent duplicate cleanup includes cranberry synonym consolidation (Журавлина/Клюква), exact Galychyna yogurt duplicates, Galychyna mango yogurt duplicate, and identical package/recipe variants where multiple EANs are retained in `barcodes` (Bonduelle GOLD corn, Rud MOCHI variants, Rud 100% ice cream variants, Rud ESKIMOS XL chocolate multipack).
- Barcode runtime verified in code: `BarcodeService.hasBarcode()` checks `product.allBarcodes`, and custom SQLite lookup checks stored `barcodes`; therefore all retained EANs are searchable/scannable.
- IMPORTANT unresolved package-size issue: merged products can have multiple EANs but only one `servingGrams` / `package_g`. Next task is to inspect post-scan quantity flow and ensure an alternate package EAN does not prefill the canonical package size incorrectly. Do not merge further different-size packages until this is resolved.
- Search fixes already committed: base query `картопля` normalization plus common Ukrainian base-food aliases and regression tests. Need later investigate screenshot anomaly where query `перець` showed unrelated raspberry item, and determine source of the 5.4-carb duplicate `Баклажан, сирий` seen in APK #302 (current products.json only has the 3.1 entry; possible old build-time/persisted custom DB source).
- Semantic scan currently finds no additional obvious safe duplicates. Similar nutrition alone is NOT sufficient to merge (different flavors, recipes, lactose-free variants, KFC/McDonald's portion SKUs, etc.). Rud 90g `100% морозиво` brick vs 100g `МОРОЗИВО РУДЬ` brick remains unmerged pending stronger identity evidence.
- After package-size/search investigation, rerun integrity: product count, duplicate IDs, and barcode collisions including both singular `barcode` and list `barcodes`.


## Quantity-unit normalization checkpoint — 2026-09-22

- Current user-tested Android baseline remains **APK #302**; no new control APK is promoted yet.
- Runtime catalog remains **1079 products**.
- Package size is metadata only and must not become a quantity/serving automatically. Product.fromJson no longer falls back from package_g to servingGrams (commit `3d0807fa3668fa232636091e4493a48724dc5c3c`).
- Non-restaurant weight products no longer expose `порція`; ordinary weight products use grams. Genuine McDonald's/KFC portions remain supported.
- Catalog unit policy: no `л`, `упаковка`, `банка/баночка`, `зубчик`, `стебло`, or `скибка` quantity units. These were normalized to grams or milliliters as appropriate (commit `904296c1959e69b6be17cccb6f156af24f6d41c2`).
- `шт` is retained only for **22 approved fixed-weight products**. All 22 also offer grams and have a valid gramsPerPiece; other former piece-based generic foods were normalized to grams (commit `9a45a733ce5d84b8ef4620f5b0e506406051eaab`).
- Removed **86 stale serving fields** from gram-only products (commit `829b6d142d7e3113bae5e6b5153f007aaa1a8ab1`). Remaining serving metadata is limited to 22 fixed-weight piece products plus 121 genuine McDonald's/KFC portion products.
- Drinks/liquids are intentionally **left as currently encoded**. Do not mass-add grams to ml products and do not assume 1 ml = 1 g; use grams+ml only where catalog metadata already supports it / a trustworthy conversion exists.
- Piece calculation path verified: pieces -> gramsPerPiece -> grams -> carbs/XO. Regression tests added in commit `7f536685fd0da5a534a3365313e772226eabe875`; CI #338 was still running when this checkpoint was written. CI #337 and earlier normalization runs are green.
- Post-cleanup integrity: **1079 products, 0 duplicate IDs, 0 cross-product barcode collisions, 0 non-McDonald's/KFC explicit portions, exactly 22 `шт` products and all 22 have gramsPerPiece**.
- Do not do further broad serving/unit deletion: the remaining serving fields have functional meaning under the current model.


## Technical catalog integrity checkpoint — 2026-09-22
- APK #302 remains the current user-tested Android baseline. Intermediate APK/CI #341 is green but is **not** a user-test checkpoint; continue accumulating changes before the next requested device test.
- CI #338 for fixed-weight piece conversion tests is green.
- CI #341 for DB schema v8 / targeted stale eggplant cleanup is green; commit `30d12cf372f1f65f179db8827fbe61bf797f7e9b`.
- Current bundled catalogs contain only the canonical raw `Баклажан, сирий` at 3.1 g carbs/100 g. The 5.4 duplicate observed on APK #302 is not in current bundled assets; DB v8 removes that known stale persisted copy on upgrade while excluding current user-created rows marked `source='Користувач'`.
- The earlier `пере...` screenshot is closed as expected partial-query behavior; there is no confirmed `перець` search defect and no search-algorithm change is required for it.
- Full structural audit of all **1079 products** passed: 1079 unique IDs, no cross-product barcode collisions, no invalid/missing carbohydrate values, no `шт` without a valid `gramsPerPiece`, no stale serving field on gram-only/non-piece/non-portion products, and no non-McDonald's/KFC explicit portions.
- Explicit quantity-unit counts at this checkpoint: `г` 643, `мл` 134, `порція` 147, `шт` 22. Drinks remain intentionally unchanged per user decision.
- Technical unit/serving cleanup is closed. Resume category-first catalog breadth/quality work; do not build/request a new user-test APK after every small change.
