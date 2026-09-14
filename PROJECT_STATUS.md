# CarbCalc UA — Project Status

Updated: 2026-09-14
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

GitHub is the source of truth. APK **#224** remains the current USER-TESTED STABLE Android checkpoint. APK **#226** has been built successfully with the add-food quantity autoscroll UX fix and is awaiting device verification.

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
Post-merge checkpoint commit used for APK #224: `d5ce632273c7c648513a9613386e90b57da39678`.

## APK checkpoints

**APK #226 — BUILD SUCCESS / AWAITING DEVICE TEST**
- Android APK run #226
- run ID: `34855752440`
- head: `df4d81e320341048156cfd6c1555cb5b770c8bac`
- UI code commit: `2ee4713f7b1c659632b3f2b82e18f5ea05eff6c1`
- artifact: `CarbCalcUA-0.6.0-build-226`
- artifact ID: `10352364258`
- artifact archive digest: `sha256:6349e80ca33ad8a40b5a4e155fb91d9d574651ee136435627f1b18ba9bd66810`
- analyze: success
- tests: success
- release APK build: success
- artifact publication: success
- device verification still required before promoting to stable.

**APK #224 — USER-TESTED STABLE**
- Android APK run #224
- run ID: `34852026300`
- head: `d5ce632273c7c648513a9613386e90b57da39678`
- installed on Android and reported working normally by user on 2026-09-14.

Previous stable checkpoint: APK #148, run ID `34769645259`, head `6aa3f719e8653b66fc6bce2ce3c25d445d7ddee3`.

## UI fix — add-food quantity autoscroll

User feedback: after typing a product name and selecting a result, the app switches to the quantity controls but may leave them below the visible scroll area, so the user has to scroll manually.

Fix applied in `lib/main.dart` at commit `2ee4713f7b1c659632b3f2b82e18f5ea05eff6c1`:
- keep the first `Scrollable.ensureVisible` after selecting a product;
- focus the quantity field;
- after the keyboard changes the viewport, wait briefly and perform a second `Scrollable.ensureVisible` so the quantity controls remain visible;
- selected product and existing add-food flow are preserved.

APK #226 contains this fix. If user confirms the behavior is correct, promote APK #226 to USER-TESTED STABLE.

## Next catalog category

**Консерви**, then **напої → заморожені напівфабрикати**.

## Working rule for continuation

At the start of every new chat, read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md`. Before each runtime merge: verify → check existing runtime → dedup → explicit whitelist → merge → parse/test → APK. Do not bulk-merge audit files merely because their filenames contain `verified`.
