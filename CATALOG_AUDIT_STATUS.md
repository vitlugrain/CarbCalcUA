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
- Existing pending files are not automatically promoted. After the current juice/drinks pass, revisit pending items under this A/B/C policy and promote only those that now qualify.

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
| Консерви | CLOSED AUDIT CHECKPOINT | Category-first audit closed at 21 verified identities. Runtime whitelist still required before merge. |
| Напої | IN PROGRESS | A/B/C policy active. 6 verified audit identities so far: Sprite, 3 Schweppes, 2 Sadochok. Continue juices, then revisit pending. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`.
Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`.
Whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`.
Merge-script commit: `13211d27d99b78f35d589b553357ba6ffa373350`.
Generated runtime commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.
Merge workflow `Merge verified catalogs #110` completed successfully.

## Canned foods audit checkpoint — CLOSED

Audit ran 2026-09-14 through 2026-09-16. Final canned audit verified count: **21**. No canned-food runtime whitelist or merge has yet been created. Olives/hummus were skipped after poor verification yield; jams and fruit preserves used the user-approved limited-pass rule.

Before canned runtime integration: revalidate verified files → check current runtime → deduplicate identities/package variants → create explicit whitelist → merge only whitelist → parse/test → combine with deferred bottom-safe-area UI fix in next meaningful APK.

## Drinks audit checkpoint — IN PROGRESS

Start 2026-09-16 after canned audit closure. Prioritize carbohydrate-relevant packaged drinks: regular carbonated soft drinks, juices/nectars/juice drinks, kvass, sweetened iced tea, energy drinks and other sugar-containing beverages. Zero/sugar-free selective; plain water low priority.

Mandatory duplicate rule: before every candidate check current `assets/products.json` by EAN plus brand/name/aliases/recipe identity. Do not add a package-size duplicate merely because exact EAN is new. Coca-Cola and Pepsi families are known to have runtime representation and must not be blindly re-added.

Verified audit files currently:
- `assets/drinks_verified_part1.json`: Sprite + Schweppes Indian Tonic; commit `c1226792a10dcbf89c99bfd5bc3a4fb7e20e430d`.
- `assets/drinks_verified_part2_schweppes.json`: Schweppes Original Bitter Lemon + Schweppes Pomegranate; commit `0528aeeddeb10dd39967b4278486728beaf119e4`.
- `assets/drinks_verified_part3_sadochok.json`: Sadochok Multifruit; commit `84ec44c5a248a3cc11faba56af6d42d99a2363a3`.
- `assets/drinks_verified_part4_sadochok.json`: Sadochok Tomato with salt; commit `5a2c771ccb5a4f37a0be6dfae06cc07d712d2623`.

Current drinks verified audit count: **6**. No drinks runtime whitelist or merge yet. Zhivchyk explicitly skipped by user. Continue juices under A/B/C policy; after juice pass return to pending review files and reassess them under the new policy.

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

Current: **напої / соки** → **revisit pending under A/B/C** → **заморожені напівфабрикати**. Canned foods remain closed at audit checkpoint and await later explicit runtime-whitelist validation.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
