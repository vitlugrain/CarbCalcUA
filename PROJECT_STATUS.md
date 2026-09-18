# CarbCalc UA — Project Status

Updated: 2026-09-18
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
- Заморожені напівфабрикати — breadth-first audit intentionally stopped after part10; no further frozen discovery now.
- **Молочні продукти — breadth-first audit CLOSED 2026-09-18; 6 verified audit parts, no runtime merge yet.**

### Current active audit
**Наступна загальна категорія каталогу.** Dairy breadth audit is closed. Continue category-first using the same hybrid generic + branded policy and branch-specific runtime checks before every candidate.

## Dairy products — CLOSED AUDIT CHECKPOINT 2026-09-18

Completed compact breadth-first dairy audit:
- part1 basic dairy — milk 2.5%, kefir 2.5%, ryazhanka 4% generic-first; `assets/dairy_verified_part1_basic.json`, commit `aaaa09ddda9a92511f364b1ba23b96d0da1900a8`.
- part2 yogurts — plain generic + representative materially different branded fruit/grain yogurts; `assets/dairy_verified_part2_yogurts.json`, commit `d5b3be6e3e4556f229fea60e5399e5d588be8d90`.
- part3 cottage cheese/sour cream/cream — generic-first; `assets/dairy_verified_part3_cottage_sourcream_cream.json`, commit `d7976bae84cd6fe2a16992e458569cdccf66f51a`.
- part4 sweet dairy desserts — representative glazed curds + high-protein pudding; `assets/dairy_verified_part4_sweet_desserts.json`, commit `d6be611137f04a998f16d83cd9879259fa319448`.
- part5 cheeses — compact generic hard cheese/mozzarella/feta/processed cheese set; `assets/dairy_verified_part5_cheese.json`, commit `db435b3614327d11ad3adf9791010dfc81b0f42d`.
- part6 butter/condensed milk/drinks — `assets/dairy_verified_part6_butter_condensed_drinks.json`, commit `60762bf6ccf5179915dfed7607fa160b05be13dd`.

Dairy policy outcome:
- ordinary milk/fermented dairy/cottage cheese/sour cream/cream/plain cheese: generic-first;
- sweet/fruit/recipe-dependent dairy: branded only where carbohydrate profile is materially useful;
- avoid flavour/SKU proliferation;
- no dairy runtime whitelist/merge yet.

## Frozen convenience foods — CLOSED AUDIT CHECKPOINT 2026-09-18

Frozen discovery is intentionally stopped. Do not continue with frozen dough/bases, other frozen prepared foods, or Bonduelle frozen candidates unless the user explicitly reopens this category.

Completed verified audit files:
- part1 Levada pelmeni — `assets/frozen_semifinished_verified_part1_levada.json`, commit `b698fbb132d6035eeadfe6d8c8923660eb458517`.
- part2 Levada varenyky — `assets/frozen_semifinished_verified_part2_levada_varenyky.json`, commit `578848d6cc0167ec1c238e2d0275e7734fddd335`.
- part3 Hercules pelmeni — `assets/frozen_semifinished_verified_part3_hercules.json`, commit `10ad61210f185fe08d464c3b48288a8be83ad83e`.
- part4 Three Bears pelmeni — `assets/frozen_semifinished_verified_part4_three_bears.json`, commit `4b2324f1d5d6deb6da6dd8c4635631d113e53747`.
- part5 Three Bears varenyky — `assets/frozen_semifinished_verified_part5_three_bears_varenyky.json`, commit `75c982fc893d641185c5f2b8e4ae3c9a404f0b2b`.
- part6 Levada pancakes — `assets/frozen_semifinished_verified_part6_levada_pancakes.json`, commit `555e8d833528eec6b9ad4e433ac0c32b9f3686f7`.
- part7 syrnyky — `assets/frozen_semifinished_verified_part7_syrnyky.json`, commit `9d802c9c075ee86641dd4dc0a3120cc989b1f564`.
- part8 nuggets — `assets/frozen_semifinished_verified_part8_nuggets.json`, commit `ad55dcdd87f5a6d83b3b97e628bd9ee9c2a72488`.
- part9 breaded chicken — `assets/frozen_semifinished_verified_part9_breaded_chicken.json`, commit `5bfd71e65c9a8511813ff2933ebb5c714d08ac64`.
- part10 frozen pizza — `assets/frozen_semifinished_verified_part10_pizza.json`, commit `36253c6cc67aac77eca59f3c6b5c36cb9b00a380`.

Known pending frozen conflict remains isolated in `assets/frozen_semifinished_pending_syrnyky.json` (Makey Premium classic syrnyky exact-EAN carb conflict). Do not silently promote it.

User decisions at close:
- frozen dough and pizza bases/preparations: SKIP;
- other frozen foods: SKIP;
- Bonduelle frozen candidate repair/revalidation: SKIP for now;
- retain all completed audit work; no deletion.

No frozen audit files have been runtime-merged yet.

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

Do not build a dairy-only APK. Continue the next general catalog category and accumulate a meaningful cross-category batch. Later: revalidate weak candidates → branch-specific runtime duplicate check → dedup → explicit whitelist → merge only whitelist → validate/parse/tests → apply deferred bottom-safe-area UI fix → one meaningful APK for Android testing.

## Working rule for continuation

At the start of every new chat, first read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md` from `dev-large-update`. Before updating/deleting an existing GitHub file, refetch its current blob SHA. Do not bulk-merge audit files just because filenames contain `verified`.
