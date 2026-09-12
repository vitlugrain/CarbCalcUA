# CarbCalc UA — Project Status

Updated: 2026-09-12
Branch: `dev-large-update`

## Current workstream

Audit and expansion of the product catalog using `zakaz.ua` as the discovery source, with nutrition values and EANs verified against official manufacturer pages whenever available.

Current manufacturer: **Рудь**.
Current phase: **final cross-check before closing TM Рудь**.

## Completed: frozen vegetables / berries — Рудь

Core frozen vegetables and berries block is considered closed for now.

Latest verified batch:
- `assets/rud_verified_part7.json`
- commit: `493bb67561430c727d1676ca16cf85b0bcaaf2a5`

Pending review items with incomplete official nutrition data are kept separately:
- `assets/rud_pending_review.json`
- commit: `e7e537124c72222c8a5e64292cd82804883e9cf1`

Rule: do not invent missing protein / fat / carbohydrate values.

## Ice cream — Рудь

Verified/audited batches created so far:
- `assets/rud_icecream_verified_part1.json` — initial Ескімос / 100% МОРОЗИВО / IMPERIUM / MOCHI; commit `36336cd096f1ac6c9bced490f94c63b58ba2d8bc`
- `assets/rud_icecream_verified_part2.json` — additional Ескімос; commit `fbdd59826696c341bd4433966fbe344df07ca906`
- `assets/rud_icecream_verified_part3.json` — IMPERIUM cones; commit `ad843df689ac1e4571777d28afc26cbc481bf946`
- `assets/rud_icecream_verified_part4.json` — 100% МОРОЗИВО verified items
- `assets/rud_icecream_verified_part5.json` — IMPERIUM tray products including Тірамісу, Червоний бархат, Празький
- `assets/rud_icecream_verified_part6.json` — additional IMPERIUM / 100% МОРОЗИВО; commit `bd8b3a62bbc1daa0638803847dcd8b30a9838fc0`
- `assets/rud_icecream_verified_part7.json` — additional 100% МОРОЗИВО / MOCHI; commit `696237c240e753041159eb9a9528e302369cbf4e`
- `assets/rud_icecream_verified_part8.json` — large dessert/new-products batch; commit `3747cecf7b6791aaefe937d1daf180ece2dab409`
- `assets/rud_icecream_verified_part9.json` — ESKIMOS CANDY BUBBLES, MINI MOCHI multipack, Galactic freeze-dried products, Ice Fashion, cups and other current SKUs; commit `b52599fbe90b0257a986a5bd06bd700c46815cbd`
- `assets/rud_icecream_verified_part10.json` — final official-site gap batch including ЕСКІМОС у шоколаді, cylindrical Ескімос, fruit/berry eskimo, Тоффі cone, МОРОЗИВО РУДЬ brick, ЕСКІМОС ПАНКЕЙК, ЕСКІМОС vanilla-strawberry-chocolate brick, MILLENNIUM VERY PERI, СЕЛЯНСЬКЕ, Цукрова вата, Супершоколад, Полуниця-ківі, Чорниця-ожина, Дитяче бажання; commit `e373cbc4562d3bfe288fbd2fcba6725fffe30bca`

Ice-cream pending review:
- `assets/rud_icecream_pending_review.json`
- includes IMPERIUM MINI, MILLENNIUM MINI, Fruit Bites Лохина where complete verified data was not available during the audit pass
- commit `d5d308e6145d7383c0a9807f8af10f491864cfea`

### Important audit notes

- IMPERIUM «Празький» 500 g: official manufacturer page shows EAN `4803097807644`; preserve as published but recheck before final merge because prefix differs from typical Rud EANs.
- «СЕЛЯНСЬКЕ» family pack: official URL contains `600g`, but current product card states 500 g; preserve the card value and recheck before merge.
- «ЕСКІМОС» ВАНІЛЬ — ПОЛУНИЦЯ — ШОКОЛАД: official card displays sugars higher than total carbohydrates; keep total carbohydrates as published but flag the card inconsistency.
- Zakaz.ua and manufacturer pages can occasionally disagree on nutrition for the same apparent SKU; manufacturer values have priority unless the retail item clearly represents another recipe/EAN.

## Non-ice-cream Rud products discovered on Zakaz.ua

The final cross-check confirmed that TM Рудь on Zakaz.ua is not limited to ice cream/frozen products. Current retail listings also include dairy/butter/glazed curds.

First verified retail batch:
- `assets/rud_non_icecream_verified_part1.json`
- includes milk 3.2% 1 L, sweet-cream butter extra 82.5% 200 g, and three current Ескімос glazed curds (strawberry, boiled condensed milk, vanilla)
- commit `0ad37a1c2196b60511e4f5a5b17901d6722f1975`

Before TM Рудь is marked fully closed, finish the Zakaz.ua cross-check for any remaining current Rud dairy / butter / glazed-curd / frozen-semi-finished / dough listings and compare against existing CarbCalc UA data.

### Deduplication rule

If the same recipe is sold in multiple package sizes with identical nutrition values, keep one base product and represent package/EAN variants as SKUs instead of creating duplicate products.

Examples already identified:
- `100% МОРОЗИВО` 500 g and 1000 g share the same nutrition profile and should be deduplicated at final merge.
- MOCHI «Шоколад – вишня» 50 g and 240 g share the same nutrition profile and should be represented as packaging/SKU variants if recipe identity is confirmed at final review.
- ЕСКІМОС у шоколаді 80 g and cylindrical Ескімос 70 g currently publish the same nutrition profile; verify recipe identity before combining package variants.

### Exclusions

Do not add products that the official Rud site marks as **«тимчасово не виробляється»** to the current verified catalog.
Do not add an item to verified data if reliable nutrition data is incomplete; keep such items pending instead.

## Next exact step

1. Finish remaining current non-ice-cream TM Рудь products found on Zakaz.ua.
2. Run one final Zakaz.ua vs current Rud files gap check, including any retail-only ice-cream SKUs.
3. Resolve or explicitly preserve audit flags / pending-review items.
4. Final deduplication by recipe + SKU packaging.
5. Prepare the complete Rud package for merge into the main CarbCalc UA product catalog.
6. Mark TM Рудь CLOSED in this file.
7. Immediately return to Zakaz.ua and continue auditing other manufacturers/products systematically.

## Working rules

- Discovery source: `https://zakaz.ua/uk/`
- Verification priority: official manufacturer page.
- Verify EAN where available.
- Never infer missing B/F/C values.
- Keep uncertain items in `pending_review` rather than in verified data.
- Do not perform final merge until the manufacturer/category pass is complete and duplicates are reviewed.
- Work in larger verified batches where practical, but never trade verification quality for batch size.

## Chat continuity rule

This file is the canonical handoff point for continuing the project in a new ChatGPT conversation. Update it after each major manufacturer/category block or every significant batch of commits.
