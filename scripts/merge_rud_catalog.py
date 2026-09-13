#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets' / 'products.json'
RUD_FILES = [
    *[ROOT / 'assets' / f'rud_verified_part{i}.json' for i in range(1, 8)],
    *[ROOT / 'assets' / f'rud_icecream_verified_part{i}.json' for i in range(1, 12)],
    ROOT / 'assets' / 'rud_non_icecream_verified_part1.json',
    ROOT / 'assets' / 'rud_curds_verified_part2.json',
    ROOT / 'assets' / 'rud_final_verified_supplement.json',
    ROOT / 'assets' / 'rud_final_retail_verified.json',
    ROOT / 'assets' / 'rud_frozen_semis_verified_final.json',
]


def load(path):
    data = json.loads(path.read_text(encoding='utf-8'))
    if isinstance(data, list):
        return data
    if isinstance(data, dict):
        for key in ('products', 'items', 'records'):
            rows = data.get(key)
            if isinstance(rows, list):
                return rows
    raise SystemExit(f'Expected JSON list or object with products/items/records list: {path.relative_to(ROOT)}')


def text(row, *keys):
    for key in keys:
        value = row.get(key)
        if value is not None and str(value).strip():
            return str(value).strip()
    return None


def direct_num(row, *keys):
    for key in keys:
        if row.get(key) is not None:
            try:
                return float(row[key])
            except (TypeError, ValueError):
                raise SystemExit(f'Invalid numeric {key} for {row.get("id")}: {row.get(key)!r}')
    return None


def nutrition_num(row, direct_keys, nested_keys, default=0.0):
    value = direct_num(row, *direct_keys)
    if value is not None:
        return value
    nested = row.get('nutrition_100g')
    if isinstance(nested, dict):
        for key in nested_keys:
            if nested.get(key) is not None:
                try:
                    return float(nested[key])
                except (TypeError, ValueError):
                    raise SystemExit(f'Invalid nutrition_100g.{key} for {row.get("id")}: {nested.get(key)!r}')
    return float(default)


def canonical(row):
    pid = text(row, 'id')
    name = text(row, 'name', 'name_uk')
    category = text(row, 'category') or 'Продукти'
    if not pid or not name:
        raise SystemExit(f'Missing id/name in Rud row: {row!r}')

    carbs = nutrition_num(row, ('carbs', 'carbs_100g'), ('carbs_g', 'carbs'))
    protein = nutrition_num(row, ('protein', 'protein_100g'), ('protein_g', 'protein'))
    fat = nutrition_num(row, ('fat', 'fat_100g'), ('fat_g', 'fat'))
    calories = nutrition_num(row, ('calories', 'kcal_100g'), ('kcal', 'calories'))
    barcode = text(row, 'barcode', 'ean')
    manufacturer = text(row, 'manufacturer', 'brand') or 'Рудь'
    source = text(row, 'source', 'source_url')

    out = dict(row)
    out.update({
        'id': pid,
        'name': name,
        'category': category,
        'carbs': carbs,
        'protein': protein,
        'fat': fat,
        'calories': calories,
        'manufacturer': manufacturer,
        'nutritionBasis': text(row, 'nutritionBasis', 'nutrition_basis') or '100g',
    })
    if barcode:
        out['barcode'] = barcode
    if source:
        out['source'] = source
    aliases = row.get('aliases')
    if aliases is not None:
        out['aliases'] = aliases
    return out


def same_nutrition(a, b, tol=0.05):
    return all(
        abs(float(a.get(k, 0)) - float(b.get(k, 0))) <= tol
        for k in ('carbs', 'protein', 'fat', 'calories')
    )


base = load(BASE)
base_by_id = {str(x.get('id', '')).strip(): x for x in base if str(x.get('id', '')).strip()}
base_barcodes = {}
for item in base:
    values = []
    if item.get('barcode'):
        values.append(str(item['barcode']).strip())
    for code in item.get('barcodes') or []:
        values.append(str(code).strip())
    for code in values:
        if code:
            base_barcodes.setdefault(code, str(item.get('id', '')).strip())

rud_by_id = {}
rud_ean_to_id = {}
duplicate_rows = 0
duplicate_details = []
conflicts = []

for path in RUD_FILES:
    if not path.exists():
        raise SystemExit(f'Missing Rud verified file: {path.relative_to(ROOT)}')
    for raw in load(path):
        item = canonical(raw)
        pid = item['id']
        ean = str(item.get('barcode', '')).strip()

        if pid in rud_by_id:
            prev = rud_by_id[pid]
            same_barcode = str(prev.get('barcode', '')).strip() == ean
            if same_barcode and same_nutrition(prev, item):
                duplicate_rows += 1
                duplicate_details.append(f'ID {pid}')
                continue
            conflicts.append(f'ID {pid}: conflicting records')
            continue

        if ean and ean in rud_ean_to_id and rud_ean_to_id[ean] != pid:
            prev_id = rud_ean_to_id[ean]
            prev = rud_by_id[prev_id]
            if same_nutrition(prev, item):
                duplicate_rows += 1
                duplicate_details.append(f'EAN {ean}: {prev_id} == {pid}')
                continue
            conflicts.append(f'EAN {ean}: {prev_id} vs {pid}')
            continue

        rud_by_id[pid] = item
        if ean:
            rud_ean_to_id[ean] = pid

if duplicate_details:
    print('Collapsed equivalent Rud duplicates:')
    for detail in duplicate_details:
        print(f' - {detail}')

if conflicts:
    print('Conflicting Rud duplicates found:')
    for conflict in conflicts:
        print(f' - {conflict}')
    raise SystemExit(f'Found {len(conflicts)} conflicting Rud duplicate groups; resolve them before merge.')

added = []
skipped_id = 0
skipped_ean = 0
for pid, item in rud_by_id.items():
    if pid in base_by_id:
        skipped_id += 1
        continue
    ean = str(item.get('barcode', '')).strip()
    if ean and ean in base_barcodes:
        skipped_ean += 1
        continue
    added.append(item)

merged = base + added
BASE.write_text(json.dumps(merged, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(
    f'Rud audit rows after internal dedup: {len(rud_by_id)}; '
    f'added to products.json: {len(added)}; skipped existing IDs: {skipped_id}; '
    f'skipped existing EANs: {skipped_ean}; duplicate Rud rows collapsed: {duplicate_rows}; '
    f'products.json total: {len(merged)}.'
)
