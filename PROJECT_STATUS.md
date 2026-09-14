# CarbCalc UA — Project Status

Updated: 2026-09-14
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

APK **#148** is now the verified/stable Android checkpoint after successful device testing on 2026-09-14.

Checkpoint scope now closed:
1. **Крупи та бобові** — checkpoint integrated with explicit exclusions for unresolved/raw duplicates;
2. **Хліб та випічка** — useful checkpoint integrated under the hybrid catalog policy.

GitHub is the source of truth. APK #148 supersedes APK #112 as the current stable device checkpoint.

## MANDATORY catalog identity policy for future chats

CarbCalc UA uses a **hybrid generic + branded catalog**.

**Simple/raw foods** (plain rice, buckwheat, millet, basic dry legumes/grains, plain dry pasta from the same basic raw material, etc.): use generic-first cross-brand dedup. Another trademark/package/EAN does not justify another runtime food when food type/state and nutrition are practically equivalent.

**Manufactured / recipe-dependent foods** (toast bread, crispbread, bakery, cookies, cereals/granola, yogurts/desserts, sauces, ready foods, filled/flavoured/specialty pasta, etc.): multiple trademark-specific products MAY and SHOULD coexist when the verified nutrition is meaningfully different for carbohydrate counting or the recipe/subtype is distinct. Keep a generic item as fallback where useful, but exact branded products are valuable when a user knows/scans the package.

Practical review threshold: a branded variant is normally justified when carbohydrate content differs by roughly **5 g/100 g or more** from the closest equivalent, or whenever the recipe/subtype is materially different. This is a catalog heuristic, not a medical threshold; use judgment around the boundary.

Near-identical branded products should still be deduplicated. Same recipe/nutrition in multiple package sizes should preferably be one product identity with package/barcode variants where schema allows.

This policy supersedes the earlier overly broad rule that branded duplicates should always be avoided. Full wording is persisted in `CATALOG_AUDIT_STATUS.md`.

## Крупи та бобові — checkpoint closed

Generic-first dedup applies. Verified runtime-safe additions were merged through the checkpoint flow. Unresolved/conflicting items remain outside runtime, including yachna-type conflicts and other explicitly pending records. Brown-rice Zakaz part3 remains `duplicate_not_for_runtime` because generic dry brown rice already exists. Green split peas remain excluded where they would duplicate the generic dry-pea identity.

## Хліб та випічка — checkpoint closed

Recipe-dependent category: generic fallback plus exact branded variants where B/F/C or recipe/subtype materially differ. Verified checkpoint candidates were merged. Sweet bakery remains recipe-specific and is handled as distinct products when justified.

## Current active category — Макаронні вироби

Continue category-first audit using:
`Zakaz.ua discovery → existing-catalog gap check → nutrition verification → subtype/dedup decision → pending review where needed → verified whitelist → runtime integration only after validation`.

Policy for pasta:
- ordinary plain dry durum-wheat pasta with near-identical nutrition is **generic-first**; shape/brand/package alone does not justify duplicate runtime foods;
- materially different subtypes may coexist as separate products, including wholegrain/integrale, egg pasta, protein-enriched pasta, gluten-free pasta, legume-based pasta, tricolore/vegetable variants, filled pasta and other genuinely distinct recipes;
- same recipe in several pack sizes should not create separate product identities;
- never invent P/F/C; conflicting/incomplete labels remain `pending_review`.

## Next category order

After pasta: **пластівці та сухі сніданки → продукти швидкого приготування → солодощі → снеки → соуси → консерви → напої → заморожені напівфабрикати**.

## Working rules

Zakaz.ua is the discovery/current-retail source; official manufacturer data is preferred. Never invent missing P/F/C. Conflicting/incomplete data remains pending. Work only on `dev-large-update`. Preserve app behavior, signing/update continuity and local data. On every new chat, read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md` before continuing catalog work.
