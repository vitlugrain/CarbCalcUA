# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-18
Branch: `dev-large-update`

GitHub is the source of truth. Workflow: `discovery → existing-catalog gap check → A/B/C nutrition verification → pending only for material conflicts → dedup → explicit runtime whitelist → merge → parse/test → APK`.

## Mandatory catalog identity rule

CarbCalc UA uses a hybrid generic + branded model. Simple/raw foods are generic-first and deduplicated across brands. Manufactured/recipe-dependent foods may coexist when nutrition materially differs or recipe/subtype is distinct. Same recipe with different package sizes should be one nutrition identity where practical, with multiple EANs attachable to that identity. Before every new SKU, check `assets/products.json`. Never invent nutrition values.

For crowded manufactured categories, do not exhaustively add every brand/flavour. Prefer a compact set of popular/relevant representatives with materially different carbohydrate profiles, then move to the next product type to improve catalog breadth.

## A/B/C verification policy — adopted 2026-09-16

- **Level A — manufacturer/label verified.** Exact/current product identity plus manufacturer or readable label data for carbohydrates. Missing secondary nutrients may be `null`; never invent zero.
- **Level B — retailer verified.** Exact EAN plus nutrition from a reliable Ukrainian retailer; second-source corroboration preferred where practical.
- **Level C — recipe identity verified.** Current identity is established and nutrition belongs to the same recipe in another/equivalent current package size.
- **Pending** is reserved for material carb conflicts, unclear recipe generations, uncertain EAN mapping or obviously inconsistent data.
- Audit useful batches rather than exhaustively perfecting one brand.

## Workstream registry

| Workstream | Status | Checkpoint |
|---|---|---|
| Рудь | CLOSED | Runtime integrated and device-tested. |
| Danone | SKIPPED | Reopen only for a useful missing group. |
| Крупи та бобові | CLOSED CHECKPOINT | Runtime integrated. |
| Хліб та випічка | CLOSED CHECKPOINT | Runtime integrated. |
| Макаронні вироби | CLOSED AUDIT CHECKPOINT | Runtime whitelist validation still required. |
| Пластівці та сухі сніданки | CLOSED AUDIT CHECKPOINT | Runtime whitelist validation still required. |
| Продукти швидкого приготування | CLOSED AUDIT CHECKPOINT | Dry-basis rule mandatory; runtime whitelist required. |
| Солодощі | CLOSED AUDIT CHECKPOINT | Some earlier parts require revalidation. |
| Снеки | CLOSED AUDIT CHECKPOINT | Revalidate weak earlier parts before runtime. |
| Соуси | CLOSED + RUNTIME CHECKPOINT | 8 explicitly whitelisted ketchups integrated. |
| Консерви | CLOSED AUDIT CHECKPOINT | Baseline 21 verified + A/B/C candidates; runtime whitelist required. |
| Напої | CLOSED AUDIT CHECKPOINT | 27 confirmed audit identities; runtime whitelist required. |
| Заморожені напівфабрикати | CLOSED AUDIT CHECKPOINT | Parts 1–10 retained; user stopped further frozen discovery. No runtime merge yet. |
| Молочні продукти | CLOSED AUDIT CHECKPOINT | 6 compact verified parts; generic-first + representative branded recipe-dependent products. No runtime merge yet. |\n| Наступна загальна категорія | ACTIVE | Start category-first audit after dairy checkpoint. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`. Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`. Whitelist commit `4fdadb009977e6cdf87592dad0f5e93161e44ccf`; merge-script `13211d27d99b78f35d589b553357ba6ffa373350`; generated runtime `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.

## Canned foods audit checkpoint — CLOSED

Baseline canned audit verified count: **21**. A/B/C pending sweep produced additional audit candidates. They are not runtime-ready until fresh revalidation, branch-specific duplicate checks, dedup and explicit whitelist.

## Drinks audit checkpoint — CLOSED

Confirmed drinks audit count: **27**. Zhivchyk was explicitly skipped. Coca-Cola/Pepsi already have runtime representation and must not be blindly re-added. Galicia tomato and old Sandora orange recipe/EAN conflicts remain excluded. No drinks runtime whitelist/merge yet.

## Frozen convenience foods — CLOSED AUDIT CHECKPOINT 2026-09-18

The user explicitly stopped further frozen discovery after the pizza block. Keep the completed work, but do not continue into frozen dough/bases, additional frozen prepared foods, or Bonduelle frozen repair unless the category is explicitly reopened.

Verified audit files:
- `assets/frozen_semifinished_verified_part1_levada.json` — Levada pelmeni; commit `b698fbb132d6035eeadfe6d8c8923660eb458517`.
- `assets/frozen_semifinished_verified_part2_levada_varenyky.json` — Levada varenyky; commit `578848d6cc0167ec1c238e2d0275e7734fddd335`.
- `assets/frozen_semifinished_verified_part3_hercules.json` — Hercules pelmeni; commit `10ad61210f185fe08d464c3b48288a8be83ad83e`.
- `assets/frozen_semifinished_verified_part4_three_bears.json` — Three Bears pelmeni; commit `4b2324f1d5d6deb6da6dd8c4635631d113e53747`.
- `assets/frozen_semifinished_verified_part5_three_bears_varenyky.json` — Three Bears varenyky; commit `75c982fc893d641185c5f2b8e4ae3c9a404f0b2b`.
- `assets/frozen_semifinished_verified_part6_levada_pancakes.json` — pancakes; commit `555e8d833528eec6b9ad4e433ac0c32b9f3686f7`.
- `assets/frozen_semifinished_verified_part7_syrnyky.json` — 3 representative frozen syrnyky identities; commit `9d802c9c075ee86641dd4dc0a3120cc989b1f564`.
- `assets/frozen_semifinished_verified_part8_nuggets.json` — 3 representative frozen nugget profiles; commit `ad55dcdd87f5a6d83b3b97e628bd9ee9c2a72488`.
- `assets/frozen_semifinished_verified_part9_breaded_chicken.json` — 3 frozen chicken-strip profiles; commit `5bfd71e65c9a8511813ff2933ebb5c714d08ac64`.
- `assets/frozen_semifinished_verified_part10_pizza.json` — 4 representative ready frozen pizzas; commit `36253c6cc67aac77eca59f3c6b5c36cb9b00a380`.

Pending:
- `assets/frozen_semifinished_pending_syrnyky.json` — Makey Premium classic syrnyky, exact-EAN material carbohydrate conflict. Keep pending; do not average or promote without resolving recipe/label generation.

Close decisions:
- pelmeni/varenyky/pancakes/syrnyky/nuggets/breaded chicken/pizza are sufficiently represented for this audit pass;
- frozen dough, pizza bases and preparations: **SKIP**;
- all further frozen foods: **SKIP**;
- Bonduelle frozen candidate revalidation: **SKIP FOR NOW**;
- no frozen runtime whitelist/merge yet.

## Dairy products — CLOSED AUDIT CHECKPOINT 2026-09-18

Six compact audit parts completed:
- `assets/dairy_verified_part1_basic.json` — generic milk 2.5%, kefir 2.5%, ryazhanka 4%; commit `aaaa09ddda9a92511f364b1ba23b96d0da1900a8`.
- `assets/dairy_verified_part2_yogurts.json` — plain yogurt generic + representative branded sweet/fruit/grain profiles; commit `d5b3be6e3e4556f229fea60e5399e5d588be8d90`.
- `assets/dairy_verified_part3_cottage_sourcream_cream.json` — cottage cheese, sour cream and cream generic-first; commit `d7976bae84cd6fe2a16992e458569cdccf66f51a`.
- `assets/dairy_verified_part4_sweet_desserts.json` — representative glazed curd/dessert profiles; commit `d6be611137f04a998f16d83cd9879259fa319448`.
- `assets/dairy_verified_part5_cheese.json` — compact hard cheese/mozzarella/feta/processed-cheese coverage; commit `db435b3614327d11ad3adf9791010dfc81b0f42d`.
- `assets/dairy_verified_part6_butter_condensed_drinks.json` — butter, sweetened condensed milk, chocolate milk drink; commit `60762bf6ccf5179915dfed7607fa160b05be13dd`.

Close decisions:
- simple/plain dairy remains generic-first;
- recipe-dependent sweet/fruit dairy may be branded when carbohydrate differences are meaningful;
- do not exhaustively add every flavour/brand;
- no dairy runtime whitelist/merge yet;
- continue to the next general catalog category and accumulate a meaningful cross-category batch before APK.

## APK/runtime checkpoint

APK **#233** remains USER-TESTED STABLE. Run ID `34860877221`, head `7be9e02ab0f21caba4f247f4658eb1529edf72b3`, artifact `CarbCalcUA-0.6.0-build-233`. Core product-selection navigation works on device.

Deferred non-blocking UI fix: ensure final `Додати до щоденника` button has sufficient bottom safe-area/scroll clearance above app and Android navigation. Do **not** build a standalone APK for this; bundle it with the next meaningful catalog APK.

## Planned continuation

Frozen and dairy breadth audits are closed. Move to the **next general catalog category** using the standard category-first/hybrid generic+branded policy. Continue accumulating a meaningful catalog batch before runtime integration. Before any runtime merge: fresh revalidation where required → branch-specific runtime check → dedup → explicit whitelist → merge → full validation → APK. Bundle the deferred bottom-safe-area fix with that meaningful APK.

## Persistence rule

At the start of every new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → runtime gap check → dedup → explicit whitelist → merge → full validation → APK.


## FINAL PRE-APK INTEGRATION CHECKPOINT — 2026-09-21
Status: **CATALOG AUDIT COMPLETE FOR THIS APK / RUNTIME INTEGRATED**

- Explicit whitelist: `assets/runtime_whitelist_preintegration_2026-09-21.json`.
- Runtime catalog: `assets/products.json` = **1135 products**.
- Post-integration integrity check: **0 duplicate IDs; 0 cross-product duplicate barcodes**.
- Approved audit blocks have been integrated using actual audit IDs; whitelist IDs were normalized after merge.
- Pending/material-conflict records were not promoted.
- No new broad catalog-expansion cycle is required before the next APK.
- Remaining pre-APK work is engineering: bottom safe-area UI fix, validation/tests, release APK build.


## APK #295 validation — 2026-09-21
- Integrated catalog reached Android device successfully in APK #295.
- User confirmed product addition works and existing diary survives in-place upgrade.
- Catalog integration remains closed for this checkpoint; next work is performance profiling/optimization, not another broad catalog audit.
- Runtime checkpoint: **1135 products**, whitelist normalized, pending/conflicting audit records remain excluded.


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
