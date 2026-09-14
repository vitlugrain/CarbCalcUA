# CarbCalc UA — Project Status

Updated: 2026-09-14
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

APK **#148** remains the verified/stable Android checkpoint after successful device testing on 2026-09-14. GitHub is the source of truth. APK #148 supersedes APK #112.

Closed/integrated checkpoints:
1. **Крупи та бобові**;
2. **Хліб та випічка**.

Closed audit checkpoints awaiting dedicated runtime whitelist validation:
3. **Макаронні вироби**;
4. **Пластівці та сухі сніданки**.

## MANDATORY catalog identity policy

CarbCalc UA uses a **hybrid generic + branded catalog**.

**Simple/raw foods:** generic-first cross-brand dedup. Another trademark/package/EAN does not justify another runtime food when food type/state and nutrition are practically equivalent.

**Manufactured / recipe-dependent foods:** multiple trademark-specific products may and should coexist when verified nutrition is meaningfully different for carbohydrate counting or recipe/subtype is distinct.

Practical review threshold: a branded variant is normally justified when carbohydrate content differs by roughly **5 g/100 g or more** from the closest equivalent, or whenever recipe/subtype is materially different. This is a catalog heuristic, not a medical threshold.

Near-identical branded products should still be deduplicated. Same recipe/nutrition in multiple package sizes should preferably be one product identity.

## Макаронні вироби — audit checkpoint closed

Verified pasta audit parts are retained. Ordinary durum pasta remains generic-first; useful specialty subtypes remain separate candidates. Conflicting Udon/Soba records remain pending and outside runtime. **Legume pasta was explicitly skipped by user decision.** Runtime merge has not been forced; dedicated whitelist validation is still required.

## Пластівці та сухі сніданки — audit checkpoint closed

Five verified audit parts have been completed and final dedup decisions are persisted in `assets/zakaz_breakfast_final_review.json`.

Simple/plain flakes remain generic-first. Recipe-dependent cereals, muesli and granola remain branded where nutrition or recipe meaningfully differs. Package-size duplicates are one product identity. Conflicting recipe/label versions are not automatically merged. Audit candidates remain outside runtime until whitelist validation.

## Current active category — Продукти швидкого приготування

Next workflow:
`Zakaz.ua discovery → existing-catalog gap check → nutrition verification → recipe/dedup decision → pending review where needed → verified audit parts → final review`.

Include instant noodles/pasta with seasoning or sauce, instant porridges/cereals, instant mashed potato and comparable ready-by-adding-water products. Keep plain dry pasta/noodles in the pasta category and ordinary ready meals in their appropriate category. Recipe-dependent instant products should normally retain exact branded identity when nutrition differs materially.

## Next category order

After instant products: **солодощі → снеки → соуси → консерви → напої → заморожені напівфабрикати**.

## Working rules

Zakaz.ua is the discovery/current-retail source; official manufacturer data is preferred. Never invent missing P/F/C. Conflicting/incomplete data remains pending. Work only on `dev-large-update`. Preserve app behavior, signing/update continuity and local data. On every new chat, read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md` before continuing catalog work.
