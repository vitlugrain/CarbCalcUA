# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-13
Branch: `dev-large-update`

GitHub is the source of truth. Workflow: `Zakaz.ua discovery → existing-catalog gap check → nutrition verification → pending review → product-type dedup → runtime integration → parse test`.

## Governing catalog identity rule — IMPORTANT

CarbCalc UA uses a **hybrid generic + branded model**. This rule must be preserved when work continues in a new chat.

### 1. Simple/raw foods: generic-first, cross-brand dedup
For foods whose nutrition is fundamentally determined by the raw ingredient rather than a manufacturer's recipe (for example dry rice, buckwheat, millet, plain dry legumes, basic grains), brand/package/EAN alone does NOT create a new runtime food. Compare food type + preparation/state + P/F/C per 100 g. If an existing generic/base food is nutritionally equivalent or practically equivalent, do not add another branded record. Small differences caused by rounding, crop/raw-material variation or label conventions are not enough.

### 2. Manufactured/recipe-dependent foods: branded variants ARE allowed and desirable when nutritionally meaningful
For foods whose recipe/process can materially change carbohydrate content (for example toast bread, crispbread, bakery, cookies, breakfast cereals/granola, yogurt/desserts, sauces, ready foods), several products of the same broad type from different trademarks may coexist when their verified nutrition differs enough to matter for carbohydrate counting or their recipe/subtype is genuinely different.

Keep a generic/base food when it is useful as a fallback, but also add verified branded products when users may realistically identify the exact package/product.

### 3. Practical threshold
A branded variant is normally justified when carbohydrates differ by about **5 g/100 g or more** from the closest existing equivalent, OR when recipe/subtype is materially different even if the carbohydrate difference is smaller (for example white toast vs wholegrain/multigrain; plain vs seeded; brioche; distinct filling/coating).

The 5 g/100 g value is a practical catalog-review threshold, not a medical threshold. Use judgment: do not discard a clearly useful exact branded product solely because the difference is 4.9 g, and do not create meaningless duplicates solely because it is 5.1 g.

### 4. Near-identical branded products
If two branded products have effectively the same recipe/type and near-identical P/F/C, avoid duplicate runtime records unless a barcode-specific exact product lookup provides clear user value. Package-size variants of the same recipe should preferably map to one food/product identity with package/barcode variants where schema permits.

### 5. Verification
Use Zakaz.ua for current retail discovery and prefer official manufacturer data for verification. Never invent missing P/F/C. Conflicting or incomplete nutrition stays pending and outside runtime until resolved.

## Workstream registry

| Workstream | Status | Checkpoint |
|---|---|---|
| Рудь | CLOSED | Runtime integrated and device-tested. |
| Danone | SKIPPED | Predominantly dairy groups already covered; reopen for a genuinely useful product/group. |
| Zakaz.ua — крупи та бобові | FINAL DEDUP | Mostly simple/raw foods: generic-first rule applies. No Zakaz grains runtime merge yet. |
| Zakaz.ua — хліб та випічка | IN PROGRESS | Recipe-dependent category: generic fallback plus nutritionally meaningful branded variants allowed. |

## Крупи та бобові checkpoint

Generic audit batches cover red/green lentils, dry chickpeas, dry bulgur, dry semolina, spelt, wheat variants, selected rice types, legumes, whole oat groats and adzuki. Brown-rice Zakaz part3 is explicitly `duplicate_not_for_runtime` because runtime already contains generic dry brown rice. Mung beans, conflicting white-bean data, quinoa variants, red/black rice, Poltava №3 and unresolved yachna/wheat profiles remain pending.

Zakaz grains files are not yet included in `scripts/merge_verified_catalogs.py`.

## Хліб та випічка checkpoint

Existing generic coverage includes common wheat, rye, rye-wheat, buckwheat, wholegrain and bran bread, wheat lavash and sliced loaf/baton. Do not add ordinary brand copies automatically.

Because bakery is recipe-dependent, exact branded variants may be added when verified carbohydrate values materially differ. Toast bread is the key example: different trademarks/subtypes can have substantially different carbohydrate values, so multiple branded toast products are appropriate instead of forcing one universal value. The same logic applies to crispbread, brioche and other recipe-dependent bakery.

Current audit files include `assets/zakaz_bread_bakery_gap_review.json` and verified bread/bakery batches. No bread Zakaz runtime merge yet.

## APK/runtime checkpoint

APK #112 remains the stable device checkpoint. Before the next APK: finish bread/bakery audit to a useful checkpoint, final-dedup grains, integrate only verified runtime-safe records through the canonical merge, run full runtime parse validation, then build one APK for device testing.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. The hybrid **generic-first for simple/raw foods + branded variants for recipe-dependent foods** rule is mandatory unless the user explicitly changes it.
