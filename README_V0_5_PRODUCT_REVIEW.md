# CarbCalc UA MVP 0.5 — Product Review & Confirmation

Checkpoint after Unified Search + Barcode.

## Added

- Review screen for products returned by Open Food Facts.
- Editable product name, manufacturer and nutrition values.
- Editable unit-conversion data: grams/piece, grams/ml and serving grams.
- Barcode and data source shown as read-only metadata.
- Two confirmation paths:
  - **Use once** — use verified/edited data without saving locally.
  - **Confirm and save** — save verified/edited product to the local SQLite database.
- The verified product is then used by the same quantity/carbohydrate calculation flow.

## Safety/data principle

External food data is not treated as automatically verified. The user sees the source and can correct the data before using it. CarbCalc UA does not calculate or recommend insulin doses.
