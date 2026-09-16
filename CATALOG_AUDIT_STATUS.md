# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-16
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
| Консерви | IN PROGRESS | Vegetable/legume/mushroom preserves part1–4 completed; fish preserves audit active. Current verified count is 15 after part11 added manufacturer-confirmed Brivais Vilnis smoked Baltic herring in oil. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`.
Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`.
Whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`.
Merge-script commit: `13211d27d99b78f35d589b553357ba6ffa373350`.
Generated runtime commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.
Merge workflow `Merge verified catalogs #110` completed successfully.

Integrated sauce whitelist contains 8 verified ketchup products from Heinz, Щедро and Чумак. Audit-only sauce files remain separate. Conflicting Torchin retailer values were not used to overwrite existing runtime products.

## Canned foods audit checkpoint

Audit started 2026-09-14 from Zakaz.ua top-level `Консерви` with category-first scope. Broad map includes vegetable preserves, fish preserves, olives, hummus, jams/preserves, meat preserves, fruit preserves, mushroom preserves, pâtés, and retailer-specific canned soups/garnishes.

Existing-runtime gap check confirmed that several Bonduelle canned legumes/vegetables are already present in `assets/products.json`; they must not be duplicated merely because Zakaz lists another package size. Candidate barcodes are checked against `assets/products.json` before audit-file creation.

### Part1 — legumes/vegetables
- `assets/canned_verified_part1.json` — 2 verified Veres products: beans in tomato sauce and canned chickpeas.
- `assets/canned_pending_review_part1.json` — green peas, standard sweet corn, premium tender corn, and beans with vegetables; conflicts/label generations keep them outside runtime.
- verified commit: `8689c5ffdcb524399970c4fd726285aefe24c49f`
- pending commit: `4e0463284c32f067ba462c1710f713a8f4385f6f`

### Part2 — recipe-dependent vegetable preserves
- `assets/canned_verified_part2.json` — 3 verified Veres products: zucchini caviar, zucchini caviar with pepper, eggplants in adjika.
- Different label/recipe generations are not merged merely by product name.
- commit: `6f105aefe2adb95d1f807047e2852215ae45c2da`

### Part3 — pickled vegetables
- `assets/canned_verified_part3.json` — 2 verified Veres products: pickled cucumbers 435 g and pickled tomatoes 760 g.
- `assets/canned_pending_review_part3.json` — Sauté, Zakarpatska vegetable appetizer, vegetable stew, Bulgarian lecho, pickled cherry tomatoes.
- verified commit: `d6d211579dd3c222f744a0eb738a7452c18cb999`
- pending commit: `f6bdaa210d4772eeeac77960c9a52e4f03d5235f`

### Part4 — mushroom preserves
- `assets/canned_verified_part4.json` — 1 verified Veres sterilized champignons identity, barcode `04823105400140`, В 5.3 / Б 2.2 / Ж 0.5 / 35 ккал.
- `assets/canned_pending_review_part4.json` — snack-marinated and delicatessen marinated champignon lines remain outside runtime because of missing matching primary nutrition confirmation / materially different recipes.
- verified commit: `c70314ce43b04902150eee3ec1f7a1953bfb9f2b`
- pending commit: `a446bdfe9fd009ceca407329635eac7904d92a6e`

### Part5 — fish preserves initial pass
- `assets/canned_pending_review_part5_fish.json` — pending-only fish candidates; no fish item promoted to verified because current retailer data is conflicting or lacks manufacturer-level confirmation.
- commit: `4b9a2249003df5c3783b5888eb3a1c8368bbae62`

### Part6 — fish preserves expansion
- `assets/canned_pending_review_part6_fish.json` created as pending-only.
- Baltic Fish sprats in oil: 160 g (`04751007739368`), 240 g (`04751007739375`) and 190 g (`04751007739382`) show the same recipe and identical Zakaz nutrition across current cards: В 0.1 / Б 21.0 / Ж 10.2 / 176 ккал. Per identity rule these package sizes are one recipe identity, but primary manufacturer/label nutrition is still required before verified/runtime status.
- Aquamarine sardine in tomato sauce `04650067810195`: current Zakaz card has complete В 4.0 / Б 18.0 / Ж 12.0 / 196 ккал and a carbohydrate-containing tomato sauce recipe, but no matching primary manufacturer nutrition source was located, so it stays pending.
- Ukrainian Star sardine in tomato sauce `04823071341676`: current card gives В 4.0 / Ж 12.0 / 196 ккал but protein is missing in the indexed data; incomplete P/F/C means mandatory pending.
- Fish Line tuna in own juice `04820235630591`: identity confirmed but complete primary-source nutrition not obtained; zero-carbohydrate inference is not enough for runtime inclusion.
- all checked part6 barcodes were absent from current `assets/products.json` in this pass.
- part6 commit: `3e95bc32190a8fdf7b8fc5b53d8e6b0416018320`

### Part7 — first verified fish identities
- `assets/canned_verified_part7_fish.json` — 2 Brivais Vilnis products promoted to verified after manufacturer + Zakaz cross-check and runtime barcode gap check.
- Riga sprats in oil 160 g, barcode `04750616001132`: official Brivais Vilnis and Zakaz agree exactly on recipe and nutrition — В 0.0 / Б 17.0 / Ж 32.0 / 356 ккал per 100 g.
- Sprat pâté, barcode `04750616002634`: Zakaz 160 g barcode identity matches the current Brivais Vilnis manufacturer recipe by full P/F/C and ingredients — В 5.7 / Б 8.9 / Ж 12.0 / 165 ккал per 100 g. Manufacturer page currently shows another package size; same recipe/package-size rule applies.
- both barcodes were absent from current `assets/products.json` in this pass.
- part7 commit: `c034cdaba67262c6a20ae5049f9de125bafb6ce1`

### Part8 — verified Brivais Vilnis tomato-sauce fish
- `assets/canned_verified_part8_fish.json` — 3 manufacturer-confirmed Brivais Vilnis identities absent from current runtime by checked barcode.
- Sardines in tomato sauce 240 g, barcode `04750616001439`: official Brivais Vilnis and Zakaz agree exactly — В 5.2 / Б 16.0 / Ж 3.2 / 111 ккал per 100 g.
- Mackerel in tomato sauce 240 g, barcode `04750616001446`: official Brivais Vilnis and Zakaz agree exactly — В 7.1 / Б 12.0 / Ж 16.0 / 217 ккал per 100 g.
- Roasted Riga sprats in tomato sauce 240 g: Zakaz barcodes `04750616002337` and `04750616002344` show the same weight, recipe and В 6.9 / Б 8.5 / Ж 9.6 / 148 ккал; official Brivais Vilnis matches the same recipe/nutrition. They are recorded as one recipe identity with an alternate barcode for dedup.
- all checked part8 barcodes were absent from current `assets/products.json` in this pass.
- part8 commit: `8c2d442c3fa8e86a0489b97ee9dc7ba3c9b73c77`

### Part9 — Brivais Vilnis oil fish / cod liver conflict pass
- `assets/canned_pending_review_part9_fish.json` — 2 pending identities; no promotion to verified.
- Cod liver 121 g, barcode `04750616003655`: absent from runtime. Current official Brivais Vilnis page gives В 0.38 / Б 8.5 / Ж 36 / 361 ккал, while current Zakaz barcode card gives В 0.4 / Б 8.5 / Ж 39 / 386 ккал. Material fat/calorie mismatch means label/production generation must be resolved.
- Riga sardines in oil 240 g, barcode `04750616008865`: absent from runtime. Zakaz gives В 0 / Б 15 / Ж 18 / 225 ккал, but current manufacturer catalog exposes multiple distinct sardine/herring-in-oil recipes and the exact barcode-linked primary nutrition was not resolved. Keep pending.
- part9 commit: `b31dc67dde01edeb48616fee410617fbece7e2f7`

### Part10 — Brivais Vilnis mackerel in oil
- `assets/canned_verified_part10_fish.json` — 1 verified identity.
- Mackerel in oil 240 g, barcode `04750616001255`: exact barcode/name absent from current `assets/products.json`. Current Ukrainian product passport identifies JSC Brivais Vilnis and gives В 0 / Б 16 / Ж 33 / 358 ккал; current Silpo card independently matches 0/16/33/358. Official Brivais Vilnis current mackerel range exposes the same nutrition profile for the corresponding mackerel/oil recipe family. Recorded as verified audit identity; no runtime merge yet.
- part10 commit: `6dd0d4d4adb42cea85fbbdd788582af9ee53846c`

### Part11 — Brivais Vilnis smoked Baltic herring in oil
- `assets/canned_verified_part11_fish.json` — 1 verified identity.
- Smoked Baltic herring in oil 240 g, barcode `04750616001163`: barcode absent from current `assets/products.json`. Official Brivais Vilnis current `Large sprats` product page identifies the recipe as smoked Baltic herring 68%, rapeseed oil 31%, salt 1% and gives В 0 / Б 16 / Ж 23 / 271 ккал per 100 g. Current Silpo card for Brivais Vilnis smoked herring 240 g matches the same nutrition exactly; independent barcode/product-passport sources tie EAN 4750616001163 to this 240 g identity.
- part11 commit: `fb5207eb15417744da44483b1e5d2c8dfc640c84`

Current canned verified count: **15** (parts1–4 + part7–8 + part10–11). No canned-food runtime whitelist or merge has been created.

## APK/runtime checkpoint

APK **#233** is the current USER-TESTED STABLE Android checkpoint.
- run ID `34860877221`
- head `7be9e02ab0f21caba4f247f4658eb1529edf72b3`
- artifact `CarbCalcUA-0.6.0-build-233`
- analyze/tests/release build/publish all succeeded
- user Android test 2026-09-14 confirmed product-selection navigation works correctly
- remaining UI follow-up: final `Додати до щоденника` button needs bottom safe-area/scroll clearance so it cannot be obscured by app or Android navigation.

APK **#224** is the previous USER-TESTED stable checkpoint. APK #226 was tested but its navigation fix was incomplete.

## Planned category sequence

Current: **консерви**. Fish audit is near closure; next subcategory is **оливки/маслини**, followed by **напої → заморожені напівфабрикати**.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
