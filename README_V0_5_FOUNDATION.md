# CarbCalc UA — V0.5 foundation

This checkpoint is based on MVP 0.4 and prepares the barcode pipeline without replacing the existing UI flow.

## Included
- `mobile_scanner` dependency for the upcoming camera scanner UI.
- `http` dependency for external product lookup.
- Expanded `Product` model: barcode, manufacturer, source, updatedAt.
- SQLite schema migration to version 3 for barcode metadata in custom products.
- `BarcodeService` with local JSON/custom-product lookup and Open Food Facts lookup fallback.

## Lookup order
1. Local custom products.
2. Bundled `assets/products.json`.
3. Open Food Facts over HTTPS.

External data is returned as a candidate product and must be confirmed by the user before it becomes a trusted local product.

## Not yet included
- Camera scanner screen.
- Product confirmation/edit screen.
- Saving an externally found product from the scanner flow.
- End-to-end add-to-diary barcode flow.

These are the next V0.5 implementation steps.
