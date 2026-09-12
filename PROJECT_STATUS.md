# CarbCalc UA — Project Status

Updated: 2026-09-12
Branch: `dev-large-update`

## Current workstream

Audit and expansion of the product catalog using `zakaz.ua` as the discovery source, with nutrition values and EANs verified against official manufacturer pages whenever available.

Current manufacturer: **Рудь**.

## Completed: frozen vegetables / berries — Рудь

Core frozen vegetables and berries block is considered closed for now.

Latest verified batch:
- `assets/rud_verified_part7.json`
- commit: `493bb67561430c727d1676ca16cf85b0bcaaf2a5`

Pending review items with incomplete official nutrition data are kept separately:
- `assets/rud_pending_review.json`
- commit: `e7e537124c72222c8a5e64292cd82804883e9cf1`

Rule: do not invent missing protein / fat / carbohydrate values.

## In progress: ice cream — Рудь

Verified batches created so far:
- `assets/rud_icecream_verified_part1.json` — initial Ескімос / 100% МОРОЗИВО / IMPERIUM / MOCHI; commit `36336cd096f1ac6c9bced490f94c63b58ba2d8bc`
- `assets/rud_icecream_verified_part2.json` — additional Ескімос; commit `fbdd59826696c341bd4433966fbe344df07ca906`
- `assets/rud_icecream_verified_part3.json` — IMPERIUM cones; commit `ad843df689ac1e4571777d28afc26cbc481bf946`
- `assets/rud_icecream_verified_part4.json` — 100% МОРОЗИВО verified items
- `assets/rud_icecream_verified_part5.json` — IMPERIUM tray products including Тірамісу, Червоний бархат, Празький
- `assets/rud_icecream_verified_part6.json` — additional IMPERIUM / 100% МОРОЗИВО; commit `bd8b3a62bbc1daa0638803847dcd8b30a9838fc0`
- `assets/rud_icecream_verified_part7.json` — additional 100% МОРОЗИВО / MOCHI; commit `696237c240e753041159eb9a9528e302369cbf4e`
- `assets/rud_icecream_verified_part8.json` — large dessert/new-products batch: MINI MOCHI Mango, BLACK COOKIES dessert + pail, DUBAI CHOCOLATE STYLE dessert + eskimo, Fruit Bites grape + raspberry, Frenzy Coconut + Orange, IMPERIUM Hazelnut Candies + Coconut Candies, ESKIMOS BUBBLES, Frozen Yogurt blueberry, ESKIMOS 500 g; commit `3747cecf7b6791aaefe937d1daf180ece2dab409`

### Important audit note

For IMPERIUM «Празький» 500 g the official manufacturer page currently shows EAN `4803097807644`. Keep the manufacturer-published value for now but recheck before final merge because the prefix differs from typical Rud EANs.

### Deduplication rule

If the same recipe is sold in multiple package sizes with identical nutrition values, keep one base product and represent package/EAN variants as SKUs instead of creating duplicate products.

Examples already identified:
- `100% МОРОЗИВО` 500 g and 1000 g share the same nutrition profile and should be deduplicated at final merge.
- MOCHI «Шоколад – вишня» 50 g and 240 g share the same nutrition profile and should be represented as packaging/SKU variants if recipe identity is confirmed at final review.

### Exclusions

Do not add products that the official Rud site marks as **«тимчасово не виробляється»** to the current verified catalog.
Do not add an item to verified data if the official page does not publish a complete protein/fat/carbohydrate profile; keep such items pending instead.

## Next exact step

Continue the current Rud ice cream audit in larger batches. Priority:
1. Remaining current dessert/new products: ESKIMOS CANDY BUBBLES, IMPERIUM MINI, MILLENNIUM MINI, Fruit Bites blueberry and other current dessert pages.
2. Current cones / eskimo / cups / fruit ice not yet covered, including newly listed items.
3. Family packs / trays / buckets and any remaining current retail SKUs.
4. Final cross-check against the current official Rud catalog and Zakaz.ua.
5. Final deduplication by recipe + SKU packaging.
6. Merge the complete Rud verified package into the main CarbCalc UA product catalog.
7. After TM Rud is fully closed, return to Zakaz.ua and continue auditing other manufacturers/products systematically.

## Working rules

- Discovery source: `https://zakaz.ua/uk/`
- Verification priority: official manufacturer page.
- Verify EAN where available.
- Never infer missing B/F/C values.
- Keep uncertain items in `pending_review` rather than in verified data.
- Do not perform final merge until the manufacturer/category pass is complete and duplicates are reviewed.
- Work in larger verified batches where practical (roughly 20–30 items), but never trade verification quality for batch size.

## Chat continuity rule

This file is the canonical handoff point for continuing the project in a new ChatGPT conversation. Update it after each major manufacturer/category block or every significant batch of commits.
