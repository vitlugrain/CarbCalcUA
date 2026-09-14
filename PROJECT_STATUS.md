# CarbCalc UA — Project Status

Updated: 2026-09-14
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

GitHub is the source of truth. APK **#233** is the current USER-TESTED STABLE Android checkpoint. The user verified on Android that the add-food navigation fix works: after selecting a product the keyboard closes, search results disappear, and the screen moves to the quantity/unit section. A remaining UI issue was observed: the `Додати до щоденника` action can be partially hidden behind the app bottom navigation or Android system navigation, so bottom safe-area/scroll padding needs a follow-up fix.

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

**APK #224 — PREVIOUS USER-TESTED STABLE**
- Android APK run #224
- run ID: `34852026300`
- head: `d5ce632273c7c648513a9613386e90b57da39678`
- installed on Android and reported working normally by user on 2026-09-14.

**APK #226 — TESTED / UX FIX INCOMPLETE**
- Android APK run #226
- run ID: `34855752440`
- head: `df4d81e320341048156cfd6c1555cb5b770c8bac`
- keyboard closes after product selection, but list does not scroll to quantity/portion controls.
- do not promote to stable.

**APK #233 — USER-TESTED STABLE**
- Android APK run #233
- run ID: `34860877221`
- head: `7be9e02ab0f21caba4f247f4658eb1529edf72b3`
- UI source fix: `579efe7c00d8e3564a33164c171e052e19613c6a`
- CI performance-fix compatibility: `2d05bc63773aff34b5c2b823b2699722e180e6cb`
- Open Food Facts fallback: `7be9e02ab0f21caba4f247f4658eb1529edf72b3`
- artifact: `CarbCalcUA-0.6.0-build-233`
- artifact ID: `10354139918`
- artifact archive digest: `sha256:2fe83151372a88c1adf596388665e047dc8868e7aaafdcc3a17aacaa29d39588`
- analyze/tests/release build/artifact publication: success
- user device test on 2026-09-14: core add-food selection/navigation scenario works correctly.
- remaining non-blocking UI issue: `Додати до щоденника` can sit under bottom app/system navigation; follow-up safe-area/scroll-padding fix required.

## UI fix v2 — explicit quantity navigation

Verified by user in APK #233. After product selection:
- keyboard closes;
- search-result cards collapse;
- page scrolls to `Кількість + Одиниця`;
- keyboard does not automatically reopen.

Follow-up UI task: ensure the final `Додати до щоденника` button always has sufficient bottom scroll/safe-area clearance above both CarbCalc UA bottom navigation and Android system navigation.

## Next catalog category

**Консерви**, then **напої → заморожені напівфабрикати**.

## Working rule for continuation

At the start of every new chat, read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md`. Before each runtime merge: verify → check existing runtime → dedup → explicit whitelist → merge → parse/test → APK. Do not bulk-merge audit files merely because their filenames contain `verified`.
