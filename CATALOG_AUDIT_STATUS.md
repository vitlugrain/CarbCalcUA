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
| Консерви | CLOSED AUDIT CHECKPOINT | Category-first audit closed at 21 verified identities. Olives/hummus skipped after low verification yield; jams/fruit limited-pass by user decision. Runtime whitelist still required before merge. |
| Напої | IN PROGRESS | Next category. Start category-first with carbohydrate-relevant drinks; check existing runtime before each branded SKU. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`.
Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`.
Whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`.
Merge-script commit: `13211d27d99b78f35d589b553357ba6ffa373350`.
Generated runtime commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.
Merge workflow `Merge verified catalogs #110` completed successfully.

Integrated sauce whitelist contains 8 verified ketchup products from Heinz, Щедро and Чумак. Audit-only sauce files remain separate. Conflicting Torchin retailer values were not used to overwrite existing runtime products.

## Canned foods audit checkpoint — CLOSED

Audit ran 2026-09-14 through 2026-09-16 from Zakaz.ua top-level `Консерви` using category-first hybrid generic+branded policy. Candidate barcodes were checked against `assets/products.json` before audit-file creation. No canned-food runtime whitelist or merge has yet been created.

### Parts1–4 — vegetable/legume/mushroom preserves
- part1: 2 verified Veres products; conflicting peas/corn/beans variants pending.
- part2: 3 verified Veres recipe-dependent vegetable preserves.
- part3: 2 verified Veres pickled vegetable identities; 5 conflict groups pending.
- part4: 1 verified Veres sterilized champignon identity; marinated variants pending.

### Parts5–11 — fish preserves
- parts5–6 pending-only Fish Line, Calvo, Baltic Fish, Aquamarine and Ukrainian Star candidates where manufacturer confirmation is missing/conflicting/incomplete.
- part7: 2 verified Brivais Vilnis identities — Riga sprats in oil and sprat pâté.
- part8: 3 verified Brivais Vilnis tomato-sauce identities — sardines, mackerel and roasted Riga sprats.
- part9 remains pending due conflicts.
- part10: 1 verified Brivais Vilnis mackerel in oil.
- part11: 1 verified Brivais Vilnis smoked Baltic herring in oil.

### Parts12–14 — olives / black olives — SKIPPED
- part12 contains 3 verified Delphi Kalamata identities.
- parts13–14 pending-only.
- User decision 2026-09-16: stop further olive audit; no pending olive identity promoted.

### Part15 — hummus — SKIPPED
- 2 Yofi candidates remain pending because of recipe-generation conflict / missing exact manufacturer nutrition.
- User-approved limited-pass rule triggered skip.

### Part16 — jams limited pass
- 1 verified Veres strawberry jam identity, exact EAN `04823105400348`, В 62.0 / Б 0.3 / Ж 0 / 249 ккал.
- Veres apricot jam remains pending due material retailer/manufacturer conflict.

### Part17 — fruit preserves limited pass
- 2 verified Iberica canned pineapple identities: rings EAN `08436024298925` and pieces EAN `08436024298918`, both В 15.4 / Б 0.3 / Ж 0.1 / 64 ккал.
- User decision: do not broadly expand fruit preserves.

Final canned audit verified count: **21**.

Before any canned runtime integration: revalidate the verified files → check current runtime again → deduplicate identities/package variants → create an explicit canned runtime whitelist → merge only whitelist → parse/test → combine with deferred bottom-safe-area UI fix in the next meaningful APK.

## Drinks audit checkpoint — STARTED

Start after canned audit closure on 2026-09-16. Prioritize carbohydrate-relevant packaged drinks where exact nutrition matters: regular carbonated soft drinks, juices/nectars/juice drinks, kvass, sweetened iced tea, energy drinks and other sugar-containing beverages. Zero/sugar-free drinks can be represented selectively where barcode scanning is useful, but should not crowd the catalog. Plain water is low priority. Apply exact EAN + manufacturer/label + retailer corroboration where possible and check `assets/products.json` before every addition.

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

Current: **напої**. Then **заморожені напівфабрикати**. Canned foods are closed at audit checkpoint and await later explicit runtime-whitelist validation, not further broad discovery.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
