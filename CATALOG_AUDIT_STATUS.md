# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-14
Branch: `dev-large-update`

GitHub is the source of truth. Workflow: `Zakaz.ua discovery → existing-catalog gap check → nutrition verification → pending review → product-type dedup → runtime integration → parse test`.

## Governing catalog identity rule — IMPORTANT

CarbCalc UA uses a **hybrid generic + branded model**.

### 1. Simple/raw foods: generic-first, cross-brand dedup
For foods whose nutrition is fundamentally determined by the raw ingredient rather than a manufacturer's recipe (for example dry rice, buckwheat, millet, plain dry legumes, basic grains, ordinary plain dry pasta from the same basic raw material), brand/package/EAN alone does NOT create a new runtime food. Compare food type + preparation/state + P/F/C per 100 g. If an existing generic/base food is nutritionally equivalent or practically equivalent, do not add another branded record.

### 2. Manufactured/recipe-dependent foods
For toast bread, crispbread, bakery, cookies, breakfast cereals/granola, yogurt/desserts, sauces, ready foods and specialty pasta, several products may coexist when verified nutrition differs enough to matter for carbohydrate counting or recipe/subtype is genuinely different.

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
| Zakaz.ua — макаронні вироби | CLOSED AUDIT CHECKPOINT | Verified parts retained; Udon/Soba conflicts remain pending; legume pasta explicitly skipped by user decision. Runtime integration still requires whitelist validation. |
| Zakaz.ua — пластівці та сухі сніданки | CLOSED AUDIT CHECKPOINT | Five verified audit parts + final dedup review completed. Runtime integration still requires dedicated whitelist validation. |
| Zakaz.ua — продукти швидкого приготування | NEXT | Next category in sequence. |

## Макаронні вироби checkpoint

Ordinary plain dry durum pasta is generic-first. Distinct wholegrain, egg, gluten-free and Asian noodle subtypes may coexist where justified. Conflicting Metro Chef Udon/Soba and suspicious JS Soba data remain pending and outside runtime. Protein/legume pasta is not pursued at this checkpoint because the user explicitly chose to skip legume pasta. Same-recipe package variants are not separate nutrition identities.

## Пластівці та сухі сніданки checkpoint

Audit parts `zakaz_breakfast_verified_part1.json` through `part5.json` are complete for the current useful checkpoint. Final decisions are persisted in `assets/zakaz_breakfast_final_review.json`.

Plain/simple flakes are generic-first and must not be blindly averaged when labels conflict materially. Recipe-dependent cereals, granola and muesli may retain exact branded identities where recipe/subtype or carbohydrate values materially differ. Same-recipe package-size variants are deduplicated. All audit candidates remain `runtime_merge:false` until a dedicated whitelist/runtime validation step.

## APK/runtime checkpoint

APK **#148** is VERIFIED / STABLE after successful Android device testing on 2026-09-14 and remains the current stable checkpoint.

Run: `Android APK #148`, run ID `34769645259`, head commit `6aa3f719e8653b66fc6bce2ce3c25d445d7ddee3`.

## Planned category sequence

Current next category: **продукти швидкого приготування**. Then: **солодощі → снеки → соуси → консерви → напої → заморожені напівфабрикати**.

## Persistence rule

On a new chat, read `PROJECT_STATUS.md` and this file first. The hybrid **generic-first for simple/raw foods + branded variants for recipe-dependent foods** rule is mandatory unless the user explicitly changes it.
