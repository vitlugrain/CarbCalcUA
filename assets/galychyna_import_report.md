# ТМ «Галичина» — звіт імпорту каталогу

Дата завершення проходу: 2026-09-11

## Статус

Поточний прохід каталогу ТМ «Галичина» завершено на основі актуальних офіційних сторінок виробника та офіційного магазину.

Підсумок опрацьованих харчових позицій:

- 72 verified nutrition records у шести файлах `galychyna_verified_part1.json` … `galychyna_verified_part6.json`;
- 5 підтверджених міжбрендових/внутрішньолінійних дублікатів у `galychyna_dedup_review.json`;
- 2 позиції/конфлікти офіційних даних у `galychyna_pending_review.json`;
- усього 79 класифікованих позицій/випадків у межах цього проходу.

## Verified

До verified увійшли актуальні продукти з категорій молока, кефіру, ряжанки, вершків, сметани, кисломолочного сиру, глазурованих сирків, Карпатських йогуртів, екзотичних йогуртів, лінійки «ҐоКарпати», Milk Shake та рослинних напоїв YOMMY.

Verified-файли:

- `assets/galychyna_verified_part1.json` — 12 records;
- `assets/galychyna_verified_part2.json` — 9 records;
- `assets/galychyna_verified_part3.json` — 7 records;
- `assets/galychyna_verified_part4.json` — 22 records;
- `assets/galychyna_verified_part5.json` — 19 records;
- `assets/galychyna_verified_part6.json` — 3 records.

Усі шість verified-файлів підключені до `scripts/merge_verified_catalogs.py` і повинні входити до зведеного `assets/products.json` через workflow `Merge verified catalogs`.

## Dedup

`assets/galychyna_dedup_review.json` містить 5 позицій, для яких не створюється окремий основний nutrition record:

1. Сметана «Галичина» 15% — профіль збігається з наявною стандартною сметаною 15%.
2. Масло «Галичина» екстра 82,5% — Б/Ж/В збігаються з наявним 82,5% маслом; ознаку `lactose_free` від базового запису не переносити.
3. Масло «Галичина» селянське 72,6% — розглядається як бренд/SKU-варіант стандартного масла ~73%; точну жирність 72,6% зберігати в metadata варіанта; `lactose_free` не переносити.
4. «ҐоКарпати» ложковий кефір 1% — стандартний профіль кефіру 1%.
5. «ҐоКарпати» питний кефір 1% — стандартний профіль кефіру 1%.

Бренд, фасування, форма продукту та офіційне джерело мають зберігатися як SKU/variant metadata навіть коли окремий nutrition record не створюється.

## Pending / official conflicts

`assets/galychyna_pending_review.json` містить 2 зафіксовані конфлікти, пов'язані зі сметаною:

- картка офіційного магазину для сметани 20% фактично містить Б/Ж/В від 15%-ї сметани;
- картка магазину з назвою 15% містить Б/Ж/В, характерні для 20%-ї сметани, тоді як окрема офіційна продуктова сторінка 15% дає Б3.0 / Ж15 / В3.0 / 159 ккал.

Через це сумнівний профіль сметани 20% не імпортується як verified до уточнення виробником. Для сметани 15% використовується окрема офіційна продуктова сторінка, а конфлікт магазину збережений для аудиту.

## Аудиторські примітки

- Для частини екзотичних йогуртів на офіційній сторінці переставлені місцями позначення kcal і kJ. У verified-записах це явно відмічено в `source_note`; значення kcal обирається лише там, де воно однозначно узгоджується з наведеним другим енергетичним значенням і Б/Ж/В.
- Для окремих карток із суперечливою енергетичною цінністю Б/Ж/В зберігаються як опубліковані виробником, а конфлікт енергії фіксується в `source_note`; значення не підміняються оцінкою «на око».
- Функціональні ознаки на кшталт `lactose_free` не переносяться між брендами лише через збіг Б/Ж/В.

## Джерела

Основні офіційні джерела:

- `https://galychyna.com.ua/products/`
- `https://galychyna.com.ua/production/galychyna/`
- `https://galychyna.com.ua/production/kefirs/`
- `https://galychyna.com.ua/production/yogurts/`
- `https://galychyna.com.ua/production/yogurts_no_sugar/`
- `https://galychyna.com.ua/production/yogurts_potable/`
- `https://galychyna.com.ua/production/fruit-carpathian-yogurt/`
- `https://galychyna.com.ua/production/exotic-yogurts/`
- `https://galychyna.com.ua/production/gokarpaty/`
- `https://galychyna.com.ua/production/bezlaktozni-prodyktu/`
- `https://dostavka.galychyna.com.ua/`

## Рішення по блоку

ТМ «Галичина» вважається закритою для поточного проходу каталогу. Нові або виправлені позиції можна додавати пізніше при появі нових офіційних даних. На цьому етапі APK не збирається.
