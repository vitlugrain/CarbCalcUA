# CarbCalc UA — Project Status

Updated: 2026-09-13
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

Before the next Android APK we are grouping two catalog workstreams:
1. **Крупи та бобові** — FINAL DEDUP;
2. **Хліб та випічка** — audit in progress.

GitHub is the source of truth. APK #112 remains VERIFIED / STABLE.

## MANDATORY catalog identity policy for future chats

CarbCalc UA uses a **hybrid generic + branded catalog**.

**Simple/raw foods** (plain rice, buckwheat, millet, basic dry legumes/grains, etc.): use generic-first cross-brand dedup. Another trademark/package/EAN does not justify another runtime food when food type/state and nutrition are practically equivalent.

**Manufactured / recipe-dependent foods** (toast bread, crispbread, bakery, cookies, cereals/granola, yogurts/desserts, sauces, ready foods, etc.): multiple trademark-specific products MAY and SHOULD coexist when the verified nutrition is meaningfully different for carbohydrate counting or the recipe/subtype is distinct. Keep a generic item as fallback where useful, but exact branded products are valuable when a user knows/scans the package.

Practical review threshold: a branded variant is normally justified when carbohydrate content differs by roughly **5 g/100 g or more** from the closest equivalent, or whenever the recipe/subtype is materially different. This is a catalog heuristic, not a medical threshold; use judgment around the boundary.

Near-identical branded products should still be deduplicated. Same recipe/nutrition in multiple package sizes should preferably be one product identity with package/barcode variants where schema allows.

This policy supersedes the earlier overly broad rule that branded duplicates should always be avoided. Full wording is persisted in `CATALOG_AUDIT_STATUS.md`.

## Крупи та бобові

Mostly simple/raw foods, so generic-first dedup applies. Prepared candidate batches cover useful gaps across lentils, chickpeas, bulgur, semolina, spelt, wheat/rice variants, legumes, oat groats and adzuki. Conflicting records remain pending. Brown-rice Zakaz part3 is `duplicate_not_for_runtime` because generic dry brown rice already exists. No Zakaz grains runtime merge yet.

## Хліб та випічка

Recipe-dependent category: use generic fallback plus exact branded variants where B/F/C materially differ.

Existing generic coverage includes wheat, rye, rye-wheat, buckwheat, wholegrain and bran bread, wheat lavash, sliced loaf/baton, simple sushki/bubliki and baked pirozhki. Do not create brand copies automatically when nutrition is effectively the same.

Current audit covers Borodinsky/custard rye, toast bread, baguette, ciabatta, burger buns and crispbread. Toast bread specifically demonstrates why branded variants are needed: products sold under the same broad name can have materially different carbohydrate values. Do not force these into one universal value.

Sweet pastries/croissants are recipe-specific and should be audited separately rather than collapsed into generic bread.

## Runtime plan before next APK

1. Finish useful bread/bakery pass using the hybrid policy.
2. Final-dedup grains/legumes using generic-first policy.
3. Integrate only verified runtime-safe records through the canonical merge.
4. Run full runtime catalog parse validation/tests.
5. Build one Android APK checkpoint.
6. User tests Add Food, search, Diary add flow and performance.
7. If stable, continue with the next category.

## Working rules

Zakaz.ua is the discovery/current-retail source; official manufacturer data is preferred. Never invent missing P/F/C. Conflicting/incomplete data remains pending. Work only on `dev-large-update`. Preserve app behavior, signing/update continuity and local data. On every new chat, read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md` before continuing catalog work.
