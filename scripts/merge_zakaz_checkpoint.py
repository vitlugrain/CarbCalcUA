#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets' / 'products.json'

CATALOGS = [
    'zakaz_grains_legumes_verified_part1.json',
    'zakaz_grains_legumes_verified_part2.json',
    'zakaz_grains_legumes_verified_part4.json',
    'zakaz_grains_legumes_verified_part6.json',
    'zakaz_grains_legumes_verified_part7.json',
    'zakaz_bread_bakery_verified_part1.json',
    'zakaz_bread_bakery_verified_part2.json',
    'zakaz_bread_bakery_verified_part3.json',
    'zakaz_sweet_bakery_verified_part1.json',
    'zakaz_sweet_bakery_verified_part2.json',
    'zakaz_sauces_runtime_verified.json',
]

EXCLUDED_IDS = {
    'ua_zakaz_barley_groats_raw',
    'ua_zakaz_sto_pudiv_green_split_peas_400g',
}


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8'))


def number(value):
    if value is None:
        return None
    return float(value)


def normalize(item):
    out = dict(item)
    nested = out.get('nutrition_100g') if isinstance(out.get('nutrition_100g'), dict) else {}

    carbs = out.get('carbs')
    protein = out.get('protein')
    fat = out.get('fat')
    calories = out.get('calories')

    if carbs is None:
        carbs = out.get('carbs_100g', nested.get('carbs'))
    if protein is None:
        protein = out.get('protein_100g', nested.get('protein'))
    if fat is None:
        fat = out.get('fat_100g', nested.get('fat'))
    if calories is None:
        calories = out.get('kcal_100g', nested.get('calories'))

    if carbs is None or protein is None or fat is None:
        raise SystemExit(f"Missing required nutrition for {out.get('id')}: P/F/C must all be present")

    out['carbs'] = number(carbs)
    out['protein'] = number(protein)
    out['fat'] = number(fat)
    if calories is not None:
        out['calories'] = number(calories)
    out.setdefault('nutrition_basis', '100g')
    return out


def eligible(item):
    product_id = str(item.get('id', '')).strip()
    if not product_id or product_id in EXCLUDED_IDS:
        return False
    if item.get('verified') is not True:
        return False
    if item.get('runtime_merge') is False:
        return False
    status = str(item.get('status', '')).strip().lower()
    if status in {'pending_review', 'duplicate_not_for_runtime'}:
        return False
    return True


base = read_json(BASE)
if not isinstance(base, list):
    raise SystemExit('assets/products.json must be a JSON list')

by_id = {str(row.get('id', '')).strip(): row for row in base if str(row.get('id', '')).strip()}
added = 0
updated = 0
selected_ids = []

for filename in CATALOGS:
    path = ROOT / 'assets' / filename
    rows = read_json(path)
    if not isinstance(rows, list):
        raise SystemExit(f'{filename} must be a JSON list')
    for raw in rows:
        if not eligible(raw):
            continue
        item = normalize(raw)
        product_id = str(item['id']).strip()
        selected_ids.append(product_id)
        if product_id in by_id:
            by_id[product_id].clear()
            by_id[product_id].update(item)
            updated += 1
        else:
            base.append(item)
            by_id[product_id] = item
            added += 1

if len(selected_ids) != len(set(selected_ids)):
    duplicates = sorted({x for x in selected_ids if selected_ids.count(x) > 1})
    raise SystemExit(f'Duplicate checkpoint IDs across verified catalogs: {duplicates}')

for excluded in EXCLUDED_IDS:
    if excluded in by_id:
        base[:] = [row for row in base if str(row.get('id', '')).strip() != excluded]
        by_id.pop(excluded, None)

BASE.write_text(json.dumps(base, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(f'Zakaz checkpoint merge: selected={len(selected_ids)}, added={added}, updated={updated}, total={len(base)}')
