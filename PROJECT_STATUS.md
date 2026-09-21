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
