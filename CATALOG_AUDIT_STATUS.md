# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-17
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
| Заморожені напівфабрикати | ACTIVE | Pelmeni + varenyky + pancakes representative audit completed; continue with other product types. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`. Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`. Whitelist commit `4fdadb009977e6cdf87592dad0f5e93161e44ccf`; merge-script `13211d27d99b78f35d589b553357ba6ffa373350`; generated runtime `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.

## Canned foods audit checkpoint — CLOSED

Baseline canned audit verified count: **21**. A/B/C pending sweep produced additional audit candidates. They are not runtime-ready until fresh revalidation, branch-specific duplicate checks, dedup and explicit whitelist.

## Drinks audit checkpoint — CLOSED

Confirmed drinks audit count: **27**. Zhivchyk was explicitly skipped. Coca-Cola/Pepsi already have runtime representation and must not be blindly re-added. Galicia tomato and old Sandora orange recipe/EAN conflicts remain excluded. No drinks runtime whitelist/merge yet.

## Frozen convenience foods — ACTIVE CHECKPOINT 2026-09-17

Category-first strategy was refined during the audit: do **not** fill the database with many near-identical pelmeni/varenyky from every brand. Use representative popular brands and materially different fillings/profiles, then broaden into other frozen convenience-food types.

Audit files created so far:
- `assets/frozen_semifinished_verified_part1_levada.json` — 4 Levada pelmeni identities; commit `b698fbb132d6035eeadfe6d8c8923660eb458517`.
- `assets/frozen_semifinished_verified_part2_levada_varenyky.json` — Levada potato + potato/mushroom varenyky; commit `578848d6cc0167ec1c238e2d0275e7734fddd335`.
- `assets/frozen_semifinished_verified_part3_hercules.json` — representative Hercules pelmeni; commit `10ad61210f185fe08d464c3b48288a8be83ad83e`. Current recipe C25.5 must not be mixed with older C26.3 generation.
- `assets/frozen_semifinished_verified_part4_three_bears.json` — representative Three Bears pelmeni; commit `4b2324f1d5d6deb6da6dd8c4635631d113e53747`.
- `assets/frozen_semifinished_verified_part5_three_bears_varenyky.json` — cherry + sweet cottage-cheese varenyky; commit `75c982fc893d641185c5f2b8e4ae3c9a404f0b2b`.
- `assets/frozen_semifinished_verified_part6_levada_pancakes.json` — representative pancakes: sweet cottage cheese, chicken, sweet unfilled; commit `555e8d833528eec6b9ad4e433ac0c32b9f3686f7`.

Pelmeni block is intentionally stopped. Varenyky block is intentionally stopped after distinct fillings. Pancake/nalysnyky block is considered sufficiently represented after the three Levada profiles above; do not exhaustively add more brands unless a materially different/common product is identified.

Important frozen notes:
- Three Bears cherry varenyky: manufacturer/exact identity profile retained; retailer discrepancy documented, never averaged.
- Levada sweet-cottage-cheese pancakes exact EAN `4823074611448`, C25.1/P7.9/F8.1/205.
- Levada chicken pancakes current 310 g, C23.1/P7.5/F11.4/225; exact current EAN not established, so barcode is null.
- Levada sweet unfilled pancakes EAN `4823074611851`, exact-EAN Auchan profile C19.5/P4.4/F10.2/188.65; small retailer generation/profile drift documented.
- Branch-specific `assets/products.json` was checked for these identities before creating audit entries; no matching Levada pancake identities/EANs were found.

**Next frozen groups:** сирники → нагетси/панірована курка → заморожена піца/тісто та інші common carbohydrate-relevant frozen prepared foods. Also revisit/revalidate the existing Bonduelle frozen A/B/C candidate files rather than duplicating them.

No frozen audit files have been runtime-merged yet. Before runtime: revalidate weak candidates → branch-specific runtime check → dedup → explicit whitelist → merge → parse/test.

## APK/runtime checkpoint

APK **#233** remains USER-TESTED STABLE. Run ID `34860877221`, head `7be9e02ab0f21caba4f247f4658eb1529edf72b3`, artifact `CarbCalcUA-0.6.0-build-233`. Core product-selection navigation works on device.

Deferred non-blocking UI fix: ensure final `Додати до щоденника` button has sufficient bottom safe-area/scroll clearance above app and Android navigation. Do **not** build a standalone APK for this; bundle it with the next meaningful catalog APK.

## Planned continuation

Continue frozen breadth-first audit: **сирники → нагетси/панірована курка → піца/тісто → other useful frozen prepared foods → repair/revalidate Bonduelle frozen candidates**. Then perform explicit runtime whitelist/dedup across a meaningful catalog batch. The next meaningful APK should combine safe catalog integration with the deferred bottom-safe-area UI fix.

## Persistence rule

At the start of every new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → runtime gap check → dedup → explicit whitelist → merge → full validation → APK.
