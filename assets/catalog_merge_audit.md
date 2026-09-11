# Аудит інтеграції каталогів CarbCalc UA

Дата аудиту: 2026-09-11
Гілка: `dev-large-update`

## Мета

Перевірити, що опрацьовані verified-набори не лише збережені в `assets/`, а реально підключені до `scripts/merge_verified_catalogs.py` і потрапляють у фінальний `assets/products.json`.

## Перевірені блоки

### Українські готові страви
- `assets/ua_dishes.json` — підключено до merge.
- `assets/ua_dishes_approved.json` — файл погодження/підготовки, напряму до merge не підключається; робочим джерелом є `ua_dishes.json`.

### Bonduelle
- `assets/bonduelle_diabetes_table_verified.json` — підключено.
- `assets/bonduelle_ua_verified.json` — підключено.
- `assets/bonduelle_ua_pending.json` — не підключається, що правильно.

### ProDiabet
- `assets/prodiabet_ua_verified.json` — підключено.
- `assets/prodiabet_ua_verified_part2.json` — підключено.
- `assets/prodiabet_gi_enrichment.json` — застосовується окремим механізмом GI enrichment.
- `assets/prodiabet_pending_review.json` — не підключається, що правильно.

### Torchyn
- `assets/torchyn_ua_verified.json` — підключено.
- `assets/torchyn_ua_verified_part2.json` — підключено.
- `assets/torchyn_ua_verified_part3.json` — підключено.
- `assets/torchyn_ua_verified_part4.json` — підключено.
- `assets/torchyn_ua_verified_part5.json` — підключено.
- `assets/torchyn_pending_review.json` — не підключається, що правильно.

### ПРОСТОНАШЕ
- `assets/prostonashe_ua_verified.json` — підключено.

### Молочний Альянс — Яготинське
- `assets/milkalliance_yagotynske_verified.json` — підключено.
- `assets/milkalliance_yagotynske_verified_part2.json` — підключено.
- `assets/milkalliance_yagotynske_verified_part3.json` — підключено.
- `assets/milkalliance_yagotynske_verified_part4.json` — підключено.
- `assets/milkalliance_yagotynske_verified_part5.json` — підключено.
- `assets/milkalliance_yagotynske_verified_part6.json` — підключено.
- pending-файл не підключається.

### Молочний Альянс — Пирятин
- `assets/milkalliance_pyriatyn_verified.json` — підключено.
- `assets/milkalliance_pyriatyn_verified_part2.json` — підключено.
- pending-файл не підключається.

### Молочний Альянс — Славія
- `assets/milkalliance_slavia_verified.json` — підключено (на поточному етапі порожній після дедуплікації).
- `assets/milkalliance_slavia_verified_part2.json` — підключено.
- dedup-review і pending не підключаються, що правильно.

### Молочний Альянс — Яготинське для дітей
- `assets/milkalliance_yagotynske_children_verified.json` — підключено.
- `assets/milkalliance_yagotynske_children_verified_part2.json` — підключено.
- `assets/milkalliance_yagotynske_children_verified_part3.json` — підключено.
- dedup-review і pending не підключаються, що правильно.

### McDonald’s Україна
Підключено всі робочі набори:
- `mcdonalds_ua_products.json`
- `mcdonalds_ua_chicken_rolls_supplement.json`
- `mcdonalds_ua_sides_sauces.json`
- `mcdonalds_ua_desserts_drinks.json`
- `mcdonalds_ua_desserts_drinks_2.json`
- `mcdonalds_ua_coffee.json`
- `mcdonalds_ua_final_verified.json`

`mcdonalds_ua_corrections.json` застосовується окремо як audited corrections.

### KFC Україна
- `assets/kfc_ua_core_verified.json` — підключено.
- `assets/kfc_ua_chicken_verified.json` — підключено.
- `assets/kfc_ua_desserts_verified.json` — підключено.

## Виявлена проблема

На момент аудиту всі verified-файли вже були правильно перелічені у `scripts/merge_verified_catalogs.py`, але `assets/products.json` був застарілим і не містив нових verified-блоків. Тобто дані були безпечно збережені в GitHub, але фінальна зведена база не була повторно згенерована після останніх пакетів.

## Виправлення

Додано GitHub Actions workflow:
- `.github/workflows/catalog-merge.yml`

Workflow:
1. запускає `python scripts/merge_verified_catalogs.py`;
2. перевіряє наявність контрольних verified ID з Bonduelle, Пирятина та «Яготинське для дітей»;
3. комітить оновлений `assets/products.json`, якщо він змінився;
4. не запускає збірку APK.

Перший запуск workflow завершився успішно.

Результат merge:
- **522 verified records** об'єднано;
- **7 audited McDonald’s corrections** застосовано;
- **33 GI enrichments** ProDiabet застосовано до існуючих продуктів;
- фінальний `assets/products.json` містить **656 записів**.

Контрольна перевірка після merge успішно підтвердила наявність нових verified-блоків у `products.json`.

## Поточний статус

**PASS — усі поточні робочі verified-каталоги підключені до merge, а фінальний `products.json` синхронізований з ними.**

Pending та dedup-review файли навмисно не створюють основних харчових записів.

APK у межах цього аудиту не збирався.
