# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-14
Branch: `dev-large-update`

GitHub is the source of truth. Workflow: `Zakaz.ua discovery → existing-catalog gap check → nutrition verification → pending review → product-type dedup → runtime integration → parse test`.

## Governing catalog identity rule — IMPORTANT

CarbCalc UA uses a **hybrid generic + branded model**. This rule must be preserved when work continues in a new chat.

### 1. Simple/raw foods: generic-first, cross-brand dedup
For foods whose nutrition is fundamentally determined by the raw ingredient rather than a manufacturer's recipe (for example dry rice, buckwheat, millet, plain dry legumes, basic grains, ordinary plain dry pasta from the same basic raw material), brand/package/EAN alone does NOT create a new runtime food. Compare food type + preparation/state + P/F/C per 100 g. If an existing generic/base food is nutritionally equivalent or practically equivalent, do not add another branded record. Small differences caused by rounding, raw-material variation or label conventions are not enough.

### 2. Manufactured/recipe-dependent foods: branded variants ARE allowed and desirable when nutritionally meaningful
For foods whose recipe/process can materially change carbohydrate content (for example toast bread, crispbread, bakery, cookies, breakfast cereals/granola, yogurt/desserts, sauces, ready foods, specialty pasta), several products of the same broad type from different trademarks may coexist when their verified nutrition differs enough to matter for carbohydrate counting or their recipe/subtype is genuinely different.

Keep a generic/base food when it is useful as a fallback, but also add verified branded products when users may realistically identify the exact package/product.

### 3. Practical threshold
A branded variant is normally justified when carbohydrates differ by about **5 g/100 g or more** from the closest existing equivalent, OR when recipe/subtype is materially different even if the carbohydrate difference is smaller.

The 5 g/100 g value is a practical catalog-review threshold, not a medical threshold. Use judgment around the boundary.

### 4. Near-identical branded products
If two branded products have effectively the same recipe/type and near-identical P/F/C, avoid duplicate runtime records unless a barcode-specific exact product lookup provides clear user value. Package-size variants of the same recipe should preferably map to one food/product identity with package/barcode variants where schema permits.

### 5. Verification
Use Zakaz.ua for current retail discovery and prefer official manufacturer data for verification. Never invent missing P/F/C. Conflicting or incomplete nutrition stays pending and outside runtime until resolved.

## Workstream registry

| Workstream | Status | Checkpoint |
|---|---|---|
| Рудь | CLOSED | Runtime integrated and device-tested. |
| Danone | SKIPPED | Predominantly dairy groups already covered; reopen for a genuinely useful product/group. |
| Zakaz.ua — крупи та бобові | CLOSED CHECKPOINT | Integrated through safe checkpoint merge; unresolved conflicts/duplicates remain excluded. |
| Zakaz.ua — хліб та випічка | CLOSED CHECKPOINT | Useful verified checkpoint integrated under hybrid policy. |
| Zakaz.ua — макаронні вироби | IN PROGRESS | Category-first audit started after APK #148 became stable. |

## Крупи та бобові checkpoint

Generic-first audit completed to the current useful checkpoint. Verified runtime-safe items were integrated. Unresolved/conflicting records remain pending and outside runtime. Brown-rice Zakaz part3 remains explicitly `duplicate_not_for_runtime`. Yachna conflict remains unresolved; green split peas remain excluded where they duplicate generic dry peas.

## Хліб та випічка checkpoint

Recipe-dependent checkpoint integrated. Exact branded variants are allowed where B/F/C or recipe/subtype materially differs; ordinary near-identical brand copies are deduplicated. Same recipe in multiple pack sizes should remain one product identity where possible.

## Макаронні вироби — active audit

Apply the hybrid policy at subtype level.

**Generic-first candidates:** ordinary plain dry pasta made from durum wheat/semolina with near-identical nutrition. Spaghetti, penne, fusilli, farfalle and other shapes do not automatically become separate branded runtime foods purely because of shape, trademark, pack size or EAN. Preserve useful generic identities and avoid brand inflation.

**Potential branded/subtype records:** wholegrain/integrale pasta, egg pasta, protein-enriched pasta, gluten-free pasta, legume-based pasta, tricolore/vegetable variants, filled pasta and other materially different recipes or nutritional profiles.

Audit procedure:
1. discover current Ukrainian assortment on Zakaz.ua;
2. compare against `assets/products.json` and existing generic/runtime coverage;
3. verify P/F/C using official manufacturer data where available;
4. classify as generic duplicate, useful distinct subtype, branded variant, or `pending_review`;
5. keep same-recipe package variants out of duplicate identities;
6. only verified whitelist items may enter runtime;
7. run full parse/tests before next APK checkpoint.

## APK/runtime checkpoint

APK **#148** is VERIFIED / STABLE after successful Android device testing on 2026-09-14. It supersedes APK #112 as the current stable checkpoint.

Run: `Android APK #148`, run ID `34769645259`, head commit `6aa3f719e8653b66fc6bce2ce3c25d445d7ddee3`.

## Planned category sequence

After pasta: **пластівці та сухі сніданки → продукти швидкого приготування → солодощі → снеки → соуси → консерви → напої → заморожені напівфабрикати**.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. The hybrid **generic-first for simple/raw foods + branded variants for recipe-dependent foods** rule is mandatory unless the user explicitly changes it.
