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
| Консерви | IN PROGRESS | Olives and hummus skipped; limited jam and fruit-preserve passes completed. Current verified count 21. Next: close remaining high-value canned scope, then drinks. |

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

### Parts1–4 — vegetable/legume/mushroom preserves
- part1: 2 verified Veres products; conflicting peas/corn/beans variants pending.
- part2: 3 verified Veres recipe-dependent vegetable preserves.
- part3: 2 verified Veres pickled vegetable identities; 5 conflict groups pending.
- part4: 1 verified Veres sterilized champignon identity; marinated variants pending.
- verified commits: `8689c5ffdcb524399970c4fd726285aefe24c49f`, `6f105aefe2adb95d1f807047e2852215ae45c2da`, `d6d211579dd3c222f744a0eb738a7452c18cb999`, `c70314ce43b04902150eee3ec1f7a1953bfb9f2b`.

### Parts5–11 — fish preserves
- parts5–6: pending-only Fish Line, Calvo, Baltic Fish, Aquamarine and Ukrainian Star candidates where manufacturer confirmation is missing/conflicting/incomplete.
- part7: 2 verified Brivais Vilnis identities — Riga sprats in oil and sprat pâté.
- part8: 3 verified Brivais Vilnis tomato-sauce identities — sardines, mackerel and roasted Riga sprats.
- part9: cod liver and Riga sardines in oil remain pending because of label/manufacturer conflicts.
- part10: 1 verified Brivais Vilnis mackerel in oil identity, barcode `04750616001255`, В 0 / Б 16 / Ж 33 / 358 ккал.
- part11: 1 verified Brivais Vilnis smoked Baltic herring in oil identity, barcode `04750616001163`, В 0 / Б 16 / Ж 23 / 271 ккал.
- fish verified commits: `c034cdaba67262c6a20ae5049f9de125bafb6ce1`, `8c2d442c3fa8e86a0489b97ee9dc7ba3c9b73c77`, `6dd0d4d4adb42cea85fbbdd788582af9ee53846c`, `fb5207eb15417744da44483b1e5d2c8dfc640c84`.

### Parts12–14 — olives / black olives — SKIPPED
- part12 contains 3 verified Delphi Kalamata identities and remains available for later whitelist consideration.
- parts13–14 are pending-only because exact manufacturer/label resolution was poor for green/black olives.
- User decision 2026-09-16: stop further olive/black-olive audit and move on.
- No pending olive identity is promoted to runtime.

### Part15 — hummus limited pass — SKIPPED
- `assets/canned_pending_review_part15_hummus.json` contains 2 Yofi candidates; no new verified identities.
- Yofi Classic 250 g, barcode `04820146820111`: retailer/manufacturer recipe generations conflict materially.
- Yofi Truffle 250 g, barcode `04820146820586`: retailer values agree, but exact manufacturer nutrition tied to EAN was not resolved.
- Both exact barcodes were absent from current runtime before audit-file creation.
- User-approved rule: only a couple of products; poor verification means skip. Hummus is SKIPPED.
- part15 commit: `5a437ede5061ea1e81d9c34f0a6be155deecaf1a`.

### Part16 — jams limited pass
- `assets/canned_verified_part16_jams.json`: 1 verified identity — Veres strawberry jam, exact EAN `04823105400348`, official manufacturer В 62.0 / Б 0.3 / Ж 0 / 249 ккал; current exact-EAN Zakaz cards independently confirm the 385 g product and 62 g carbs. Barcode absent from current runtime before creation. Commit `0607d2013af06c846871a8c0b771313cfe27b40b`.
- `assets/canned_pending_review_part16_jams.json`: Veres apricot jam 370 g kept pending because current retailer and official manufacturer nutrition materially conflict. Commit `0497d68dd423a5761e370f30aaf4651821a8797b`.
- Per user rule, stop after this small sample and move on rather than expanding the jam audit.

### Part17 — fruit preserves limited pass
- `assets/canned_verified_part17_fruit.json`: 2 verified Iberica canned pineapple identities.
- Iberica pineapple rings in syrup 565 g, EAN `08436024298925`: В 15.4 / Б 0.3 / Ж 0.1 / 64 ккал. Exact EAN and nutrition agree across current Zakaz, Auchan Ukraine and independent product-passport evidence.
- Iberica pineapple pieces in syrup 565 g, EAN `08436024298918`: В 15.4 / Б 0.3 / Ж 0.1 / 64 ккал. Exact EAN, recipe and nutrition corroborated by current retail and Ukrainian product-passport evidence.
- Both exact EANs were absent from current `assets/products.json` before creation.
- part17 commit: `e5303cc7006182637cefb467b24435300fc6e19e`.
- Per user limited-pass rule, do not expand fruit preserves broadly; move on after this successful sample.

Current canned verified count: **21**. No canned-food runtime whitelist or merge has been created.

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

Current: **консерви — close remaining high-value scope without broad expansion**. Then **напої → заморожені напівфабрикати**. Before any canned runtime merge: revalidate verified identities, dedup, create explicit whitelist, then merge/test. Avoid low-value meat-only identities unless carbohydrate-relevant.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
