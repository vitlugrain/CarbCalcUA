# CarbCalc UA — handoff for new chat

Date: 2026-09-14
Repository: `vitlugrain/CarbCalcUA`
Branch: `dev-large-update`

## Start here
Read `PROJECT_STATUS.md` and `CATALOG_AUDIT_STATUS.md` first. GitHub is the source of truth.

## Current runtime
Integrated safe checkpoints:
- Крупи та бобові
- Хліб та випічка
- Соуси: explicit whitelist of 8 verified ketchup products from Heinz, Щедро and Чумак; existing Torchin runtime block preserved without duplication.

Sauces files/commits:
- audit checkpoint: `assets/sauces_checkpoint.json`
- runtime whitelist: `assets/zakaz_sauces_runtime_verified.json`
- whitelist commit: `4fdadb009977e6cdf87592dad0f5e93161e44ccf`
- merge script commit: `13211d27d99b78f35d589b553357ba6ffa373350`
- regenerated runtime commit: `c5a784ece1de2b1e7f15a99447ebc92259fa414d`
- post-merge APK checkpoint commit: `d5ce632273c7c648513a9613386e90b57da39678`
- Merge verified catalogs #110: SUCCESS

## APK
APK #224 BUILD SUCCESS, awaiting user device test.
- run ID: `34852026300`
- head: `d5ce632273c7c648513a9613386e90b57da39678`
- artifact: `CarbCalcUA-0.6.0-build-224`
- artifact ID: `10350169458`
- analyze: success
- tests: success
- release build: success
- artifact publish: success

APK #148 remains the last USER-TESTED stable APK until #224 is installed and confirmed by the user.

## Closed audit checkpoints not yet safe for bulk runtime merge
- Макаронні вироби
- Пластівці та сухі сніданки
- Продукти швидкого приготування
- Солодощі: some earlier parts require revalidation
- Снеки: revalidate part5/part12 and verify part9/10/11 before runtime

## Mandatory rules
1. Before adding every SKU, check `assets/products.json` first.
2. Exact valid runtime product: skip, no duplicate.
3. Conflicting external nutrition: correction/pending review, do not duplicate or overwrite blindly.
4. Same recipe/different package size: one identity where practical.
5. Simple/raw foods: generic-first.
6. Recipe/manufactured foods: branded variants allowed when verified nutrition or subtype meaningfully differs.
7. Never invent P/F/C.
8. Pending/unverified data stays outside runtime.
9. Before runtime merge: verify → dedup → explicit whitelist → merge → validation → APK.
10. Instant foods prepared mainly with water must preserve dry-product nutrition basis unless verified prepared yield/basis exists.

## Next work
After the user tests APK #224:
- if normal, mark APK #224 USER-TESTED STABLE in both status files;
- then start category **Консерви**;
- after canned foods: **Напої → Заморожені напівфабрикати**.

Do not reopen completed sauce work unless correcting a known conflict or adding a genuinely useful missing product.
