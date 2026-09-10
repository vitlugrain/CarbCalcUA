# Food search stage 1

Checkpoint for CarbCalc UA search quality and barcode compatibility.

- Require direct or translated evidence before showing a search result.
- Do not treat every zero-carbohydrate food as a Zero beverage.
- Prefer `ua_core_` records over raw USDA fallback.
- Deduplicate obvious equivalent result names such as Pepsi / Пепсі variants.
- Preserve legacy single `barcode` while adding optional `barcodes` for multiple package EANs.
- Barcode lookup checks all stored barcodes before Open Food Facts.

Regression tests cover unrelated mushroom/Zero results, Ukrainian core priority, Pepsi deduplication, and backward-compatible barcode handling.
