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
| Консерви | IN PROGRESS | Olives/black olives audit active. Current verified count remains 18; parts13–14 keep unresolved green/black olive identities pending. |

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

### Part12 — Delphi Kalamata olives
- `assets/canned_verified_part12_olives.json` — 3 verified Delphi / Intercomm Foods Kalamata identities; all exact barcodes absent from current `assets/products.json` before creation.
- Kalamata olives with stone in brine 350 g, barcode `05201306700396`: В 2.7 / Б 1.5 / Ж 25.2 / 249 ккал.
- Kalamata pitted marinated olives 60 g, barcode `05201306822074`: В 2.7 / Б 1.5 / Ж 25.2 / 249 ккал.
- Kalamata olives with stone marinated with extra virgin olive oil 250 g, barcode `05201306810316`: В 2.7 / Б 1.5 / Ж 25.2 / 249 ккал.
- part12 commit: `12423fa84b2ca978ad2d3b9d98c9fc1bc017c789`.

### Part13 — Delphi green olives conflict pass
- `assets/canned_pending_review_part13_olives.json` — pending-only; no new verified identities.
- Delphi green pitted olives in brine 350 g: Zakaz EAN cards `05201306700419` and `05201306821053` agree on В 1.0 / Б 0.8 / Ж 14.8 / 139 ккал, but another current retailer card exposes a materially different nutrition/ingredient generation. Keep pending until exact label generation is resolved.
- Delphi green olives stuffed with almonds 350 g, barcode `05201306821091`: multiple retailer cards agree on В 2.7 / Б 3.0 / Ж 19.8 / 209 ккал and recipe, but matching primary manufacturer/label nutrition for the exact EAN was not located.
- part13 commit: `2503d4056ccc8ccc6ea108ae80feeac339795998`.

### Part14 — black olives Iberica / Maestro de Oliva / Oscar
- `assets/canned_pending_review_part14_black_olives.json` — pending-only; no new verified identities.
- Iberica black pitted olives 420 g, barcode `08436024290592`: current Zakaz exact-EAN card gives В 0 / Б 0.5 / Ж 14 / 134 ккал; current Silpo Iberica black pitted olives independently matches the same profile. Exact primary manufacturer nutrition tied to this EAN was not resolved, so it stays pending.
- Maestro de Oliva black pitted olives 432 g, barcode `08436024299045`: multiple current Zakaz cards agree on В 0 / Б 0.5 / Ж 14 / 134 ккал and the same recipe, but manufacturer-label confirmation for the exact EAN is still missing.
- Oscar black pitted olives 300 g, barcode `08413552051475`: exact-EAN Zakaz cards agree on В 0 / Б 0.5 / Ж 13 / 129 ккал, but the Oscar range currently exposes multiple manufacturer/recipe generations with materially different nutrition across EANs; exact manufacturer-label confirmation required.
- checked candidate barcodes are absent from current runtime where exact lookup was performed; none is promoted to runtime.
- part14 commit: `f3f36770449ab6a2b90e7fdb92d819c69566af27`.

Current canned verified count: **18**. No canned-food runtime whitelist or merge has been created.

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

Current: **консерви → оливки/маслини**. Continue manufacturer/label resolution for black olives and audit stuffed/seasoned olives; then remaining canned subcategories, followed by **напої → заморожені напівфабрикати**.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
