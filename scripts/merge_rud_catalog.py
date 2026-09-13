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
    if not isinstance(data, list):
        raise SystemExit(f'Expected JSON list: {path.relative_to(ROOT)}')
    return data


def num(row, *keys, default=0.0):
    for key in keys:
        if row.get(key) is not None:
            try:
                return float(row[key])
            except (TypeError, ValueError):
                raise SystemExit(f'Invalid numeric {key} for {row.get("id")}: {row.get(key)!r}')
    return float(default)


def text(row, *keys):
    for key in keys:
        value = row.get(key)
        if value is not None and str(value).strip():
            return str(value).strip()
    return None


def canonical(row):
    pid = text(row, 'id')
    name = text(row, 'name', 'name_uk')
    category = text(row, 'category') or 'Продукти'
    if not pid or not name:
        raise SystemExit(f'Missing id/name in Rud row: {row!r}')

    carbs = num(row, 'carbs', 'carbs_100g')
    protein = num(row, 'protein', 'protein_100g')
    fat = num(row, 'fat', 'fat_100g')
    calories = num(row, 'calories', 'kcal_100g')
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
for path in RUD_FILES:
    if not path.exists():
        raise SystemExit(f'Missing Rud verified file: {path.relative_to(ROOT)}')
    for raw in load(path):
        item = canonical(raw)
        pid = item['id']
        ean = str(item.get('barcode', '')).strip()
        if pid in rud_by_id:
            prev = rud_by_id[pid]
            keys = ('carbs', 'protein', 'fat', 'calories', 'barcode')
            if any(str(prev.get(k, '')) != str(item.get(k, '')) for k in keys):
                raise SystemExit(f'Conflicting duplicate Rud id: {pid}')
            duplicate_rows += 1
            continue
        if ean and ean in rud_ean_to_id and rud_ean_to_id[ean] != pid:
            prev_id = rud_ean_to_id[ean]
            prev = rud_by_id[prev_id]
            keys = ('carbs', 'protein', 'fat', 'calories')
            if any(abs(float(prev.get(k, 0)) - float(item.get(k, 0))) > 0.01 for k in keys):
                raise SystemExit(f'Conflicting Rud EAN {ean}: {prev_id} vs {pid}')
            duplicate_rows += 1
            continue
        rud_by_id[pid] = item
        if ean:
            rud_ean_to_id[ean] = pid

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
