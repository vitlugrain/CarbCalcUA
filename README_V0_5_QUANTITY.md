# CarbCalc UA MVP 0.5 — Quantity / Units checkpoint

## Що додано

- Окрема модель `Quantity` з одиницями: `г`, `мл`, `шт`, `порція`.
- Користувач обирає одиницю кількості після вибору продукту.
- Внутрішній розрахунок приводить кількість до грамів, коли для продукту є необхідні коефіцієнти.
- У щоденнику зберігаються `amount_value` та `amount_unit`, тому запис відображається як введено користувачем: `150 г`, `200 мл`, `2 шт`, `1 порція`.
- Старе поле `grams` зберігається для сумісності та для внутрішніх розрахунків.
- SQLite піднято до версії 4 з міграцією існуючих записів.

## Дані для конвертації

- `г` доступні завжди.
- `шт` доступні, якщо продукт має `gramsPerPiece`.
- `мл` доступні, якщо продукт має `gramsPerMl`.
- `порція` доступна, якщо продукт має `servingGrams`.

Застосунок не припускає автоматично, що 1 мл = 1 г.

## V0.5 Smart Food Search

The add-food screen now accepts natural quantity prefixes such as `150 г гречки вареної на воді` and `2 шт печива Марія`. The quantity and unit are parsed separately from the product query, then matching local products are ranked and presented for confirmation.

The search remains conservative: a query with multiple plausible products shows candidates rather than silently choosing a potentially wrong food.
