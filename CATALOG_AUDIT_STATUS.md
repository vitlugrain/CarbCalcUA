# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-14
Branch: `dev-large-update`

GitHub is the source of truth. Workflow: `Zakaz.ua discovery → existing-catalog gap check → nutrition verification → pending review → product-type dedup → runtime integration → parse test`.

## Governing catalog identity rule — IMPORTANT

CarbCalc UA uses a **hybrid generic + branded model**.

### 1. Simple/raw foods: generic-first, cross-brand dedup
For foods whose nutrition is fundamentally determined by the raw ingredient rather than a manufacturer's recipe (for example dry rice, buckwheat, millet, plain dry legumes, basic grains, ordinary plain dry pasta from the same basic raw material), brand/package/EAN alone does NOT create a new runtime food. Compare food type + preparation/state + P/F/C per 100 g. If an existing generic/base food is nutritionally equivalent or practically equivalent, do not add another branded record.

### 2. Manufactured/recipe-dependent foods
For toast bread, crispbread, bakery, cookies, breakfast cereals/granola, yogurt/desserts, sauces, ready foods, specialty pasta, instant foods and sweets, several products may coexist when verified nutrition differs enough to matter for carbohydrate counting or recipe/subtype is genuinely different.

### 3. Practical threshold
A branded variant is normally justified when carbohydrates differ by about **5 g/100 g or more** from the closest equivalent, OR when recipe/subtype is materially different even if the carbohydrate difference is smaller. This is a catalog-review heuristic, not a medical threshold.

### 4. Near-identical branded products
Avoid duplicate runtime records for near-identical recipe/type and P/F/C. Same-recipe package-size variants should preferably map to one identity.

### 5. Verification
Use Zakaz.ua for current retail discovery and prefer official manufacturer data for verification. Never invent missing P/F/C. Conflicting or incomplete nutrition stays pending and outside runtime.

## Workstream registry

| Workstream | Status | Checkpoint |
|---|---|---|
| Рудь | CLOSED | Runtime integrated and device-tested. |
| Danone | SKIPPED | Predominantly dairy groups already covered; reopen for a genuinely useful product/group. |
| Zakaz.ua — крупи та бобові | CLOSED CHECKPOINT | Integrated through safe checkpoint merge; unresolved conflicts/duplicates remain excluded. |
| Zakaz.ua — хліб та випічка | CLOSED CHECKPOINT | Useful verified checkpoint integrated under hybrid policy. |
| Zakaz.ua — макаронні вироби | CLOSED AUDIT CHECKPOINT | Verified parts retained; unresolved conflicts remain pending; runtime whitelist validation still required. |
| Zakaz.ua — пластівці та сухі сніданки | CLOSED AUDIT CHECKPOINT | Final dedup review completed; runtime whitelist validation still required. |
| Zakaz.ua — продукти швидкого приготування | CLOSED AUDIT CHECKPOINT | `assets/zakaz_instant_final_review.json`; mandatory dry-basis rule applies; runtime whitelist validation still required. |
| Zakaz.ua — солодощі | CLOSED AUDIT CHECKPOINT | Verified audit parts retained through part10b; final decisions in `assets/zakaz_sweets_final_review.json`; conflicts remain pending; runtime whitelist validation still required. |
| Zakaz.ua — снеки | ACTIVE | Current audit category. |

## Instant foods checkpoint

Instant products prepared mainly by adding water must preserve the verified nutrition basis. When the label gives dry-product nutrition, store and calculate on dry-product basis. Added water changes final weight but not total carbohydrate amount. Never invent water absorption/yield coefficients. Final review is stored in `assets/zakaz_instant_final_review.json`.

## Sweets checkpoint

Chocolate, bars, candies, caramel, toffee, marshmallow, jelly and gummy audit blocks have been reviewed as the current useful checkpoint. Conflicting nutrition, including unresolved recipe-version conflicts, remains pending and outside verified/runtime data. Final decisions are stored in `assets/zakaz_sweets_final_review.json`. All sweets audit candidates remain `runtime_merge:false` until a dedicated whitelist/runtime validation step.

## APK/runtime checkpoint

APK **#148** is VERIFIED / STABLE after successful Android device testing on 2026-09-14 and remains the current stable checkpoint.

Run: `Android APK #148`, run ID `34769645259`, head commit `6aa3f719e8653b66fc6bce2ce3c25d445d7ddee3`.

## Planned category sequence

Current active category: **снеки**. Then: **соуси → консерви → напої → заморожені напівфабрикати**.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. The hybrid **generic-first for simple/raw foods + branded variants for recipe-dependent foods** rule is mandatory unless the user explicitly changes it. Before any runtime merge: verify → dedup → whitelist → merge → full parse/test → APK.