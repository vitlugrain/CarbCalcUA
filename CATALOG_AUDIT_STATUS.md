# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-14
Branch: `dev-large-update`

GitHub is the source of truth. Workflow: `Zakaz.ua discovery → existing-catalog gap check → nutrition verification → pending review → dedup → explicit runtime whitelist → merge → parse/test → APK`.

## Mandatory catalog identity rule

CarbCalc UA uses a hybrid generic + branded model. Simple/raw foods are generic-first and deduplicated across brands. Manufactured/recipe-dependent foods may coexist when verified nutrition materially differs or recipe/subtype is distinct. Same recipe with different package sizes should be one identity where practical. Before every new SKU, check `assets/products.json`. Never invent missing P/F/C; conflicting or incomplete data stays outside runtime.

## Workstream registry

| Workstream | Status | Checkpoint |
|---|---|---|
| Рудь | CLOSED | Runtime integrated and device-tested. |
| Danone | SKIPPED | Reopen only for a useful missing group. |
| Крупи та бобові | CLOSED CHECKPOINT | Runtime integrated; unresolved conflicts excluded. |
| Хліб та випічка | CLOSED CHECKPOINT | Runtime integrated. |
| Макаронні вироби | CLOSED AUDIT CHECKPOINT | Runtime whitelist validation still required. |
| Пластівці та сухі сніданки | CLOSED AUDIT CHECKPOINT | Runtime whitelist validation still required. |
| Продукти швидкого приготування | CLOSED AUDIT CHECKPOINT | Dry-basis rule mandatory; runtime whitelist validation still required. |
| Солодощі | CLOSED AUDIT CHECKPOINT | Some earlier parts require revalidation before runtime. |
| Снеки | CLOSED AUDIT CHECKPOINT | Revalidate part5/part12 and verify part9/10/11 before runtime. |
| Соуси | CLOSED + RUNTIME CHECKPOINT | 8 explicitly whitelisted verified ketchup products integrated. Existing Torchin runtime block preserved and not duplicated. |
| Консерви | IN PROGRESS | Vegetable/legume preserves audit active; part1 = 2 verified + 4 pending; part2 = 3 verified; part3 = 2 verified + 5 pending conflict/label-generation groups. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`.
Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`.
Whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`.
Merge-script commit: `13211d27d99b78f35d589b553357ba6ffa373350`.
Generated runtime commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.
Merge workflow `Merge verified catalogs #110` completed successfully.

Integrated sauce whitelist contains 8 verified ketchup products from Heinz, Щедро and Чумак. Audit-only sauce files remain separate. Conflicting Torchin retailer values were not used to overwrite existing runtime products.

## Canned foods audit checkpoint

Audit started 2026-09-14 from Zakaz.ua top-level `Консерви` with category-first scope. Current broad category map includes vegetable preserves, fish preserves, olives, hummus, jams/preserves, meat preserves, fruit preserves, mushroom preserves, pâtés, and retailer-specific canned soups/garnishes. Audit order begins with vegetable/legume preserves because they are carbohydrate-relevant and overlap existing Bonduelle runtime data.

Existing-runtime gap check confirmed that several Bonduelle canned legumes/vegetables are already present in `assets/products.json`; they must not be duplicated merely because Zakaz lists another package size. Candidate barcodes are checked against `assets/products.json` before audit-file creation.

Part1 files:
- `assets/canned_verified_part1.json` — 2 verified Veres products: beans in tomato sauce and canned chickpeas. Both have matching official Veres and Zakaz P/F/C and were absent from runtime by checked barcode.
- `assets/canned_pending_review_part1.json` — green peas, standard sweet corn, premium tender corn, and beans with vegetables. These remain outside runtime because official Veres and current/historical Zakaz nutrition values conflict or indicate label/recipe generations.

Part1 commits:
- verified: `8689c5ffdcb524399970c4fd726285aefe24c49f`
- pending: `4e0463284c32f067ba462c1710f713a8f4385f6f`

Part2:
- `assets/canned_verified_part2.json` — 3 verified Veres recipe-dependent vegetable preserves absent from runtime by checked barcode: zucchini caviar, zucchini caviar with pepper, and eggplants in adjika.
- Official Veres and Zakaz nutrition agree for all three selected identities.
- Important identity note: Veres has evidence of label/recipe generations for zucchini caviar (including a newer 310 g variant with different P/F/calories despite same 7 g carbs). Part2 therefore pins the verified 440 g barcode identities and does not infer equivalence across changed recipes merely from product name.
- part2 commit: `6f105aefe2adb95d1f807047e2852215ae45c2da`.

Part3:
- `assets/canned_verified_part3.json` — 2 verified Veres preserves absent from runtime by checked barcode: classic pickled cucumbers 435 g and pickled tomatoes 760 g. Official Veres and current Zakaz values match for both: В 4.0, Б 0.3, Ж 0.0, 17 ккал / 100 г.
- `assets/canned_pending_review_part3.json` — Sauté, Zakarpatska vegetable appetizer, vegetable stew, Bulgarian lecho, and pickled cherry tomatoes remain outside runtime because of official-vs-retailer nutrition conflicts, multiple barcode/label generations, or insufficient manufacturer-level confirmation.
- verified commit: `d6d211579dd3c222f744a0eb738a7452c18cb999`.
- pending commit: `f6bdaa210d4772eeeac77960c9a52e4f03d5235f`.

No canned-food runtime whitelist or merge has been created yet.

## APK/runtime checkpoint

APK **#233** is the current USER-TESTED STABLE Android checkpoint.
- run ID `34860877221`
- head `7be9e02ab0f21caba4f247f4658eb1529edf72b3`
- artifact `CarbCalcUA-0.6.0-build-233`
- analyze/tests/release build/publish all succeeded
- user Android test on 2026-09-14 confirmed product-selection navigation works correctly
- remaining UI follow-up: final `Додати до щоденника` button needs bottom safe-area/scroll clearance so it cannot be obscured by app or Android navigation.

APK **#224** is the previous USER-TESTED stable checkpoint. APK #226 was tested but its navigation fix was incomplete.

## Planned category sequence

Current: **консерви**. Then: **напої → заморожені напівфабрикати**.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
