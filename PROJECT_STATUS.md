# CarbCalc UA — Project Status

Updated: 2026-09-12
Branch: `dev-large-update`

## Current workstream

Audit and expansion of the product catalog using `zakaz.ua` as the discovery source, with nutrition values and EANs verified against official manufacturer pages whenever available.

## TM Рудь — CLOSED

The current Zakaz.ua-driven audit of TM Рудь is closed. The pass covered frozen vegetables/berries, ice cream and frozen desserts, dairy/butter/glazed curds, bakery and the current frozen-semi-finished retail gaps found during the final cross-check.

Important: CLOSED means the current systematic Zakaz.ua audit is complete; it does not mean every historical or every manufacturer-only Horeca SKU has been imported. Products marked by the manufacturer as temporarily not produced remain excluded. Incomplete/ambiguous products remain in pending-review files and must not be given invented nutrition values.

### Verified Rud audit files

Frozen vegetables/berries:
- `assets/rud_verified_part7.json`
- pending: `assets/rud_pending_review.json`

Ice cream / desserts:
- `assets/rud_icecream_verified_part1.json`
- `assets/rud_icecream_verified_part2.json`
- `assets/rud_icecream_verified_part3.json`
- `assets/rud_icecream_verified_part4.json`
- `assets/rud_icecream_verified_part5.json`
- `assets/rud_icecream_verified_part6.json`
- `assets/rud_icecream_verified_part7.json`
- `assets/rud_icecream_verified_part8.json`
- `assets/rud_icecream_verified_part9.json`
- `assets/rud_icecream_verified_part10.json`
- `assets/rud_icecream_verified_part11.json`
- `assets/rud_final_verified_supplement.json`
- `assets/rud_final_retail_verified.json`
- pending: `assets/rud_icecream_pending_review.json`

Non-ice-cream / curds / retail:
- `assets/rud_non_icecream_verified_part1.json`
- `assets/rud_curds_verified_part2.json`
- `assets/rud_frozen_semis_verified_final.json`

### Final retail-gap additions

Final cross-check added verified/current retail records for:
- DOCHI «Вершкове тістечко» and «Лимонне тістечко»;
- Fruit Bites Лохина в молочному шоколаді;
- Kochubey's Oaks Фісташка, Гарбузове насіння та мед, Мигдаль, Кокос-Шоколад;
- frozen butter croissants;
- Пельмені 100%, Ескімос, Супер, Imperium;
- frozen pizza base;
- current official potato vareniki retained in the Rud package.

Final batch commits:
- `7ca63221cd18e6057724e401bfa3826497802316` — final dessert/bakery retail gaps
- `af854cbe26a5419deb1946da01cc6bb0f3a5e053` — final frozen-semis batch

### Audit flags preserved

- IMPERIUM «Празький» 500 g: manufacturer-published EAN has an unusual prefix; preserve and recheck when merging.
- «СЕЛЯНСЬКЕ» family pack: official URL/card weight mismatch remains flagged.
- «ЕСКІМОС» ВАНІЛЬ — ПОЛУНИЦЯ — ШОКОЛАД: manufacturer page has an internal sugars/carbohydrates inconsistency; total carbohydrates remain as published and flagged.
- Some Zakaz.ua cards disagree with manufacturer nutrition; manufacturer data has priority when the EAN/recipe match.
- Croissants have an alternate older Zakaz EAN; current manufacturer EAN `4823097809549` is canonical.
- Kochubey's Oaks retail cards are sold under Rud branding while Zakaz lists producer АТ Полтавхолод; preserve this provenance.

### Deduplication rule for final catalog merge

If the same recipe is sold in multiple package sizes with identical nutrition, keep one base product and attach packaging/EAN variants as SKUs rather than duplicate foods. Known candidates include 100% МОРОЗИВО 500/1000 g, MOCHI «Шоколад–вишня» 50/240 g, and other explicitly matching package variants.

## Next exact step

1. Treat TM Рудь as CLOSED for the current Zakaz.ua manufacturer audit.
2. Keep Rud pending-review records separate; never infer missing B/F/C or EAN values.
3. During the eventual catalog merge, deduplicate Rud records by recipe + nutrition + packaging SKU and preserve audit flags.
4. Return to Zakaz.ua and begin the next manufacturer/product block systematically.
5. Continue working in large verified batches where practical.

## Working rules

- Discovery source: Zakaz.ua.
- Verification priority: official manufacturer page.
- Verify EAN where available.
- Never infer missing protein/fat/carbohydrate values.
- Keep uncertain items in pending review.
- Official `тимчасово не виробляється` products are excluded from the current verified catalog.
- GitHub branch for this audit: `dev-large-update`.

## Chat continuity rule

This file is the canonical handoff point for continuing the project in a new ChatGPT conversation. Update it after each major manufacturer/category block or every significant batch of commits.
