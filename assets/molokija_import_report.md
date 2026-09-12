# ТМ «Молокія» — звіт імпорту

Статус: **закрито для поточного проходу каталогу**.

## Verified

Підготовлено 7 verified-файлів:

- `molokija_verified_part1.json`
- `molokija_verified_part2.json`
- `molokija_verified_part3.json`
- `molokija_verified_part4.json`
- `molokija_verified_part5.json`
- `molokija_verified_part6.json`
- `molokija_verified_part7.json`

Після вилучення сумнівного нежирного кефіру у verified залишено **32 підтверджені товарні позиції/профілі до dedup-обробки**.

## Dedup / brand SKU variants

Файл: `molokija_dedup_review.json`.

Для однакових generic nutrition-профілів не створюється зайвий повний nutrition record. Бренд, фасування, точне маркування та джерело зберігаються як SKU/brand variant.

Технічна підтримка variant-архітектури додана через `molokija_brand_variants.json` і `scripts/merge_verified_catalogs.py`.

У поточному merge застосовано 3 brand/SKU variants:

1. Вершки Молокія 10% -> canonical nutrition profile `ua_galychyna_lactose_free_cream_10`; ознака `lactose_free` **не переноситься** на SKU Молокія.
2. Масло Молокія селянське 72,5% -> canonical profile `ua_yagotynske_lactose_free_butter_73`; точні 72,5%/661 ккал збережені у variant metadata, `lactose_free` **не переноситься**.
3. Кефір густий Молокія 2,5% -> variant до `ua_molokija_kefir_drinking_25`, оскільки Б/Ж/В збігаються, а консистенція є SKU-властивістю.

Функціонально відмінні продукти з однаковими макросами (наприклад lactose-free та probiotic) не зливаються так, щоб втрачалася функціональна ознака.

## Pending

Файл: `molokija_pending_review.json`.

3 випадки залишено поза verified merge:

1. Кефір нежирний — конфлікт Б/Ж/В між доступними джерелами при однакових 29 ккал.
2. Йогурт Полуниця 1,4% — старий 400 г SKU має іншу рецептуру ніж поточна пляшкова лінійка.
3. Йогурт Абрикос 1,4% — старі 290/770 г SKU мають іншу рецептуру ніж поточний 250 г SKU.

Суперечливі значення не усереднювалися і не імпортувалися як актуальні.

## Merge

`molokija_verified_part1.json` ... `molokija_verified_part7.json` підключені до `scripts/merge_verified_catalogs.py`.

Для variant source IDs повний дубль nutrition record у фінальний каталог не потрапляє; SKU metadata додається у `brand_variants` canonical record.

GitHub Actions `Merge verified catalogs`, run #18 (`34708689338`) завершився успішно:

- 624 verified records у загальному verified merge;
- 7 audited corrections;
- 33 GI enrichments;
- 3 brand/SKU variants;
- 0 equivalent base records skipped старим name-based механізмом;
- `assets/products.json` після merge: **758 records**.

Автоматичний commit regenerated DB: `72b6fb2` (`data: regenerate products from verified catalogs`).

## Джерела та політика якості

- Офіційні Molokija / HoReCa / PDF-каталоги використовувалися для ідентичності продукту, жирності, складу та фасування.
- Коли офіційна сторінка не показувала Б/Ж/В, точні nutrition values перевірялися за актуальними товарними картками ритейлерів.
- Retail nutrition не позначається як official nutrition.
- Конфліктні старі/нові рецептури не усереднюються.
- `lactose_free`, `probiotic` та інші функціональні атрибути не успадковуються між SKU лише через однакові Б/Ж/В.

APK на цьому етапі **не збирається**.
