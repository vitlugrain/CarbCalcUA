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
