# CarbCalc UA — Project Status

Updated: 2026-09-14
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

APK **#148** remains the verified/stable Android checkpoint after successful device testing on 2026-09-14. GitHub is the source of truth.

Closed/integrated checkpoints:
1. **Крупи та бобові**;
2. **Хліб та випічка**.

Closed audit checkpoints awaiting dedicated runtime whitelist validation:
3. **Макаронні вироби**;
4. **Пластівці та сухі сніданки**;
5. **Продукти швидкого приготування**;
6. **Солодощі**.

## MANDATORY catalog identity policy

CarbCalc UA uses a **hybrid generic + branded catalog**.

**Simple/raw foods:** generic-first cross-brand dedup. Another trademark/package/EAN does not justify another runtime food when food type/state and nutrition are practically equivalent.

**Manufactured / recipe-dependent foods:** multiple trademark-specific products may and should coexist when verified nutrition is meaningfully different for carbohydrate counting or recipe/subtype is distinct.

Practical review threshold: a branded variant is normally justified when carbohydrate content differs by roughly **5 g/100 g or more** from the closest equivalent, or whenever recipe/subtype is materially different. This is a catalog heuristic, not a medical threshold.

Near-identical branded products should still be deduplicated. Same recipe/nutrition in multiple package sizes should preferably be one product identity.

## Продукти швидкого приготування — audit checkpoint closed

Final review is persisted in `assets/zakaz_instant_final_review.json`. The mandatory dry-product basis rule remains in force: if verified nutrition is given for the dry packaged product, calculations must use dry-product basis unless a verified prepared-product basis or final yield is known. Do not invent water absorption/yield coefficients. Runtime merge has not been forced; dedicated whitelist validation is still required.

## Солодощі — audit checkpoint closed

Verified audit blocks cover the current useful checkpoint across chocolate, bars, candies, caramel, toffee, marshmallow, jelly and gummies. Final decisions are persisted in `assets/zakaz_sweets_final_review.json`. Conflicting recipe/nutrition versions remain pending and outside runtime. Audit candidates remain `runtime_merge:false` until dedicated whitelist validation.

## Current active category — Снеки

Next workflow:
`Zakaz.ua discovery → existing-catalog gap check → nutrition verification → recipe/dedup decision → pending review where needed → verified audit parts → final review`.

Audit order: chips → corn snacks → croutons/toasts → crackers and other salty snacks.

## Next category order

After snacks: **соуси → консерви → напої → заморожені напівфабрикати**.

## Working rules

Zakaz.ua is the discovery/current-retail source; official manufacturer data is preferred. Never invent missing P/F/C. Conflicting/incomplete data remains pending. Work only on `dev-large-update`. Preserve app behavior, signing/update continuity and local data. Before runtime merge: verify → dedup → whitelist → merge → parse/test → APK. On every new chat, read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md` before continuing catalog work.