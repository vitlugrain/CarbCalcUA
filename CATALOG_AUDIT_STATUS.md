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
| Консерви | CLOSED AUDIT CHECKPOINT | Category-first audit closed at 21 verified identities. Runtime whitelist still required before merge. |
| Напої | IN PROGRESS | Part1: 2 verified identities (Sprite, Schweppes Indian Tonic). Coca-Cola/Pepsi families must always be checked for existing runtime identity before any addition. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`.
Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`.
Whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`.
Merge-script commit: `13211d27d99b78f35d589b553357ba6ffa373350`.
Generated runtime commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.
Merge workflow `Merge verified catalogs #110` completed successfully.

## Canned foods audit checkpoint — CLOSED

Audit ran 2026-09-14 through 2026-09-16 from Zakaz.ua top-level `Консерви` using category-first hybrid generic+branded policy. Final canned audit verified count: **21**. No canned-food runtime whitelist or merge has yet been created. Olives/hummus were skipped after poor verification yield; jams and fruit preserves used the user-approved limited-pass rule.

Before any canned runtime integration: revalidate verified files → check current runtime again → deduplicate identities/package variants → create explicit canned runtime whitelist → merge only whitelist → parse/test → combine with deferred bottom-safe-area UI fix in the next meaningful APK.

## Drinks audit checkpoint — IN PROGRESS

Start 2026-09-16 after canned audit closure. Prioritize carbohydrate-relevant packaged drinks: regular carbonated soft drinks, juices/nectars/juice drinks, kvass, sweetened iced tea, energy drinks and other sugar-containing beverages. Zero/sugar-free drinks are selective; plain water low priority.

Mandatory drinks duplicate rule reinforced by user: before every candidate check current `assets/products.json` by EAN plus brand/name/aliases/recipe identity. Do not add a package-size duplicate merely because the exact EAN is new. Coca-Cola and Pepsi families are known to have existing runtime representation and must not be blindly re-added.

### Drinks part1 — carbonated soft drinks
- `assets/drinks_verified_part1.json` contains 2 verified identities; commit `c1226792a10dcbf89c99bfd5bc3a4fb7e20e430d`.
- **Sprite**, exact current Zakaz EAN `05449000027368`: current official Coca-Cola Ukraine recipe gives В 9.0 / Б 0 / Ж 0 / 37 kcal per 100 ml. Zakaz exact-EAN card identifies Ukrainian 0.5 L Sprite but its displayed 7 g carbs / 29 kcal conflicts internally with its 9 g sugar field and with current official Ukrainian recipe; official current manufacturer nutrition is used. No Sprite packaged-drink identity or exact EAN found in current runtime before audit-file creation.
- **Schweppes Indian Tonic**, EAN `05449000312105`: official Coca-Cola Ukraine and current exact-EAN Zakaz card agree on В 8.9 / Б 0 / Ж 0 / 37 kcal per 100 ml. No Schweppes identity or exact EAN found in current runtime before creation.
- Mirinda / 7UP / other Schweppes variants remain for subsequent passes; do not add until runtime gap and exact recipe/EAN are verified.

Current drinks verified count: **2**. No drinks runtime whitelist or merge yet.

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

Current: **напої**. Then **заморожені напівфабрикати**. Canned foods are closed at audit checkpoint and await later explicit runtime-whitelist validation.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
