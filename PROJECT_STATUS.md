# CarbCalc UA — Project Status

Updated: 2026-09-14
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

GitHub is the source of truth. APK **#148** remains the last user-tested stable Android checkpoint until the new post-sauce APK is installed and tested.

### Runtime integrated
1. Крупи та бобові — safe checkpoint merge.
2. Хліб та випічка — safe checkpoint merge.
3. Соуси — 8 explicitly whitelisted verified ketchup products integrated; existing Torchin sauce block preserved without duplication.

### Closed audit checkpoints awaiting dedicated runtime whitelist/revalidation
4. Макаронні вироби.
5. Пластівці та сухі сніданки.
6. Продукти швидкого приготування.
7. Солодощі — some earlier audit parts require revalidation before runtime.
8. Снеки — revalidate part5/part12 and verify part9/10/11 before runtime.

## Mandatory catalog policy

Use a hybrid generic + branded catalog. Simple/raw foods are generic-first and deduplicated across brands. Recipe/manufactured foods may have separate branded identities when verified nutrition materially differs or recipe/subtype is distinct. Same recipe with different package sizes should normally be one identity. Before adding any SKU, check `assets/products.json`. Never invent nutrition values. Conflicts/incomplete data stay pending and outside runtime.

## Instant foods rule

When nutrition is given for dry product, calculate/store on dry basis. Added water changes weight, not total carbohydrates. Never invent water absorption or yield coefficients. Rule file: `assets/INSTANT_FOODS_RULES.md`.

## Sauces checkpoint

Audit checkpoint: `assets/sauces_checkpoint.json`.
Runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`.
Whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`.
Merge-script commit: `13211d27d99b78f35d589b553357ba6ffa373350`.
Generated `products.json` commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`.
Merge verified catalogs run #110 completed successfully.
Post-merge checkpoint commit: `d5ce632273c7c648513a9613386e90b57da39678`.

New Android APK build: run #224, run ID `34852026300`, head `d5ce632273c7c648513a9613386e90b57da39678`. Mark it verified/stable only after successful build and user device test.

## Last stable APK

APK #148 — run ID `34769645259`, head `6aa3f719e8653b66fc6bce2ce3c25d445d7ddee3`; user tested successfully.

## Next catalog category

**Консерви**, then **напої → заморожені напівфабрикати**.

## Working rule for continuation

At the start of every new chat, read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md`. Before each runtime merge: verify → check existing runtime → dedup → explicit whitelist → merge → parse/test → APK. Do not bulk-merge audit files merely because their filenames contain `verified`.
