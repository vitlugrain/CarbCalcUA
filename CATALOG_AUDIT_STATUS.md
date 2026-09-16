# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-16
Branch: `dev-large-update`

GitHub is the source of truth. Workflow: `discovery → existing-catalog gap check → A/B/C nutrition verification → pending only for material conflicts → dedup → explicit runtime whitelist → merge → parse/test → APK`.

## Mandatory catalog identity rule

CarbCalc UA uses a hybrid generic + branded model. Simple/raw foods are generic-first and deduplicated across brands. Manufactured/recipe-dependent foods may coexist when nutrition materially differs or recipe/subtype is distinct. Same recipe with different package sizes should be one nutrition identity where practical, with multiple EANs attachable to that identity. Before every new SKU, check `assets/products.json`. Never invent nutrition values.

## A/B/C verification policy — adopted 2026-09-16

Goal: safely grow a useful carbohydrate-counting catalog without requiring unnecessary proof for secondary nutrients.

- **Level A — manufacturer/label verified.** Exact EAN/product identity plus official manufacturer or readable label data for carbohydrates. Carbohydrates are the critical CarbCalc UA field. Missing protein/fat does not block the product; unknown values must be stored as `null`, never invented as zero.
- **Level B — retailer verified.** Exact EAN plus nutrition from one reliable Ukrainian retailer; prefer corroboration from a second independent source when practical. Manufacturer page is not mandatory when exact-EAN retailer evidence is coherent.
- **Level C — recipe identity verified.** Current product identity/EAN is established and nutrition belongs to the same recipe in another package size or equivalent current package. Package-size-only differences do not create separate nutrition identities.
- **Pending review is reserved for material uncertainty:** conflicting carbohydrate values from credible sources, unclear recipe generation/change, uncertain EAN-to-product identity, or obviously inconsistent data.
- Do not block a product merely because protein/fat are unavailable. Do not convert missing protein/fat to 0 unless a source explicitly establishes 0.
- Audit in useful batches of roughly 10–20 common products rather than trying to exhaustively perfect one brand before adding anything.
- Existing pending files are not automatically promoted. Promote only those that qualify under A/B/C after revalidation.

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
| Консерви | CLOSED AUDIT CHECKPOINT | Baseline 21 verified identities; pending sweep under A/B/C produced additional candidates. Runtime whitelist still required before merge. |
| Напої | CLOSED AUDIT CHECKPOINT | 27 confirmed audit identities after part11 revalidation. Runtime dedup/explicit whitelist still required. |
| Заморожені напівфабрикати | NEXT | Start category-first audit under A/B/C after drinks checkpoint. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`.
Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`.
Whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`.
Merge-script commit: `13211d27d99b78f35d589b553357ba6ffa373350`.
Generated runtime commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.
Merge workflow `Merge verified catalogs #110` completed successfully.

## Canned foods audit checkpoint — CLOSED

Audit ran 2026-09-14 through 2026-09-16. Baseline canned audit verified count: **21**. A subsequent A/B/C pending sweep promoted additional retailer/recipe-verified candidates; these remain audit candidates until final runtime duplicate/whitelist validation. No canned-food runtime whitelist or merge has yet been created.

Before canned runtime integration: revalidate candidate files → check current runtime → deduplicate identities/package variants → create explicit whitelist → merge only whitelist → parse/test → combine with deferred bottom-safe-area UI fix in next meaningful APK.

## Drinks audit checkpoint — CLOSED AUDIT CHECKPOINT

Audit ran 2026-09-16. Scope prioritized carbohydrate-relevant packaged drinks: regular carbonated soft drinks, juices/nectars/juice drinks and other sugar-containing beverages. Zhivchyk was explicitly skipped by user. Coca-Cola and Pepsi families are known to have runtime representation and must not be blindly re-added.

Verified audit files:
- `assets/drinks_verified_part1.json`: Sprite + Schweppes Indian Tonic.
- `assets/drinks_verified_part2_schweppes.json`: Schweppes Original Bitter Lemon + Schweppes Pomegranate.
- `assets/drinks_verified_part3_sadochok.json`: Sadochok Multifruit.
- `assets/drinks_verified_part4_sadochok.json`: Sadochok Tomato with salt.
- `assets/drinks_verified_part5_sandora.json` through `assets/drinks_verified_part10_nash_sik.json`: Sandora, Jaffa, Galicia, Biola and Nash Sik juice/nectar identities audited under A/B/C.
- `assets/drinks_verified_part11_ua_juices.json`: revalidated 2026-09-16; Nash Sik Orange corrected to 10.0 g carbs/100 ml with uncertain secondary fields stored as null; Biola Tomato exact EAN 4820209111217 corrected to 3.3 g carbs/100 ml; the previously unsupported Nash Sik Peach 11.5 g identity was removed from verified.

Confirmed drinks audit count after part11 revalidation: **27**. This is an audit checkpoint, not a runtime count. No drinks runtime whitelist or merge yet. Before runtime integration perform branch-specific `assets/products.json` duplicate/identity check, revalidate any weak earlier files if encountered, create an explicit whitelist, then parse/test.

Known unresolved/excluded drink cases include Galicia tomato recipe/EAN generations with conflicting carbohydrate values and old Sandora orange generations with conflicting exact-EAN nutrition. Keep such cases pending rather than averaging values.

## APK/runtime checkpoint

APK **#233** is current USER-TESTED STABLE Android checkpoint.
- run ID `34860877221`
- head `7be9e02ab0f21caba4f247f4658eb1529edf72b3`
- artifact `CarbCalcUA-0.6.0-build-233`
- analyze/tests/release build/publish succeeded
- user Android test 2026-09-14 confirmed product-selection navigation works correctly
- remaining UI follow-up: final `Додати до щоденника` button needs bottom safe-area/scroll clearance so it cannot be obscured by app or Android navigation.

APK **#224** is previous USER-TESTED stable checkpoint. APK #226 was tested but its navigation fix was incomplete.

## Planned category sequence

Current checkpoint: **напої — CLOSED AUDIT CHECKPOINT (27 confirmed)**. Next: **заморожені напівфабрикати**. Canned and drinks candidates await later explicit runtime-whitelist validation. The next meaningful catalog APK should combine a safely whitelisted catalog batch with the deferred bottom-safe-area UI fix.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
