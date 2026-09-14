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
| Соуси | CLOSED CHECKPOINT | Audit checkpoint closed; explicit runtime whitelist integrated for 8 verified ketchup products. Existing Torchin runtime block remains source of truth and is not duplicated. |
| Консерви | NEXT | Next catalog category. |

## Sauces runtime checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`.
Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`.
Whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`.
Merge-script commit: `13211d27d99b78f35d589b553357ba6ffa373350`.
Generated runtime commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.
Merge workflow `Merge verified catalogs #110` completed successfully.

Integrated sauce whitelist contains 8 verified ketchup products from Heinz, Щедро and Чумак. Audit-only sauce files remain `runtime_merge:false`; conflicting Torchin retailer values were not used to overwrite existing runtime products.

## Stable APK checkpoint

APK **#148** remains the last user-tested stable APK until the new post-sauce build is installed and tested. Run ID `34769645259`, head commit `6aa3f719e8653b66fc6bce2ce3c25d445d7ddee3`.

A new post-sauce APK build is being produced from checkpoint commit `d5ce632273c7c648513a9613386e90b57da39678` (Android APK run #224, run ID `34852026300`). It must not replace #148 as the verified stable checkpoint until build success and device testing.

## Planned category sequence

Next: **консерви → напої → заморожені напівфабрикати**.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. Before runtime merge always use: verify → dedup → explicit whitelist → merge → full validation → APK.
