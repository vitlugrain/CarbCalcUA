#!/usr/bin/env python3
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets' / 'products.json'
CATALOGS = [
    ROOT / 'assets' / 'ua_dishes.json',
    ROOT / 'assets' / 'bonduelle_diabetes_table_verified.json',
    ROOT / 'assets' / 'bonduelle_ua_verified.json',
    ROOT / 'assets' / 'prodiabet_ua_verified.json',
    ROOT / 'assets' / 'prodiabet_ua_verified_part2.json',
    ROOT / 'assets' / 'torchyn_ua_verified.json',
    ROOT / 'assets' / 'torchyn_ua_verified_part2.json',
    ROOT / 'assets' / 'torchyn_ua_verified_part3.json',
    ROOT / 'assets' / 'torchyn_ua_verified_part4.json',
    ROOT / 'assets' / 'torchyn_ua_verified_part5.json',
    ROOT / 'assets' / 'prostonashe_ua_verified.json',
    ROOT / 'assets' / 'mcdonalds_ua_products.json',
    ROOT / 'assets' / 'mcdonalds_ua_chicken_rolls_supplement.json',
    ROOT / 'assets' / 'mcdonalds_ua_sides_sauces.json',
    ROOT / 'assets' / 'mcdonalds_ua_desserts_drinks.json',
    ROOT / 'assets' / 'mcdonalds_ua_desserts_drinks_2.json',
    ROOT / 'assets' / 'mcdonalds_ua_coffee.json',
    ROOT / 'assets' / 'mcdonalds_ua_final_verified.json',
    ROOT / 'assets' / 'kfc_ua_core_verified.json',
    ROOT / 'assets' / 'kfc_ua_chicken_verified.json',
    ROOT / 'assets' / 'kfc_ua_desserts_verified.json',
]
CORRECTIONS = ROOT / 'assets' / 'mcdonalds_ua_corrections.json'
GI_ENRICHMENT = ROOT / 'assets' / 'prodiabet_gi_enrichment.json'


def load(path):
    if not path.exists():
        raise SystemExit(f'Missing catalog: {path.relative_to(ROOT)}')
    data = json.loads(path.read_text(encoding='utf-8'))
    if not isinstance(data, list):
        raise SystemExit(f'Catalog must be a JSON list: {path.relative_to(ROOT)}')
    return data


def norm(text):
    text = unicodedata.normalize('NFKD', str(text or '')).lower().replace('’', "'")
    text = re.sub(r"\bmcdonald'?s\b|\bмакдональдс\b|\bмакдональдз\b", ' ', text)
    text = re.sub(r'\b(мал(а|ий)|середн(я|ій)|велик(а|ий))\b', ' ', text)
    text = re.sub(r'\b\d+\s*(мл|ml|г|g)\b', ' ', text)
    text = re.sub(r'[^a-zа-яіїєґ0-9]+', ' ', text)
    return ' '.join(text.split())


def names(item):
    values = [item.get('name', '')] + list(item.get('aliases') or [])
    return {norm(v) for v in values if norm(v)}


def same_nutrition(a, b):
    basis_a = a.get('nutrition_basis', a.get('nutritionBasis', '100g'))
    basis_b = b.get('nutrition_basis', b.get('nutritionBasis', '100g'))
    if basis_a != basis_b:
        return False
    for key in ('carbs', 'protein', 'fat'):
        try:
            if abs(float(a.get(key, 0) or 0) - float(b.get(key, 0) or 0)) > 0.35:
                return False
        except (TypeError, ValueError):
            return False
    return True


def equivalent(a, b):
    state_a = str(a.get('state', '')).strip().lower()
    state_b = str(b.get('state', '')).strip().lower()
    if state_a and state_b and state_a != state_b:
        return False
    if not (names(a) & names(b)):
        return False
    return same_nutrition(a, b)


base = load(BASE)

gi_rows = load(GI_ENRICHMENT)
base_by_id = {str(x.get('id', '')).strip(): x for x in base}
applied_gi = 0
for row in gi_rows:
    target_id = str(row.get('target_id', '')).strip()
    if not target_id or target_id not in base_by_id:
        raise SystemExit(f'GI enrichment target not found in base catalog: {target_id!r}')
    item = base_by_id[target_id]
    item['glycemic_index'] = row['glycemic_index']
    item['glycemic_index_source'] = row['source']
    item['glycemic_index_source_name'] = row.get('source_name', '')
    item['glycemic_load_source_100g'] = row.get('glycemic_load_source_100g')
    item['glycemic_source_carbs_100g'] = row.get('source_carbs_100g')
    item['glycemic_source_calories_100g'] = row.get('source_calories_100g')
    applied_gi += 1

corrections = {str(x.get('id', '')).strip(): x for x in load(CORRECTIONS)}
if '' in corrections:
    raise SystemExit('Missing id in McDonald corrections')

verified = []
seen_verified = set()
applied_corrections = set()
for path in CATALOGS:
    for original in load(path):
        product_id = str(original.get('id', '')).strip()
        if not product_id:
            raise SystemExit(f'Missing id in {path.relative_to(ROOT)}')
        item = corrections.get(product_id, original)
        if product_id in corrections:
            applied_corrections.add(product_id)
        if product_id in seen_verified:
            raise SystemExit(f'Duplicate verified id: {product_id}')
        seen_verified.add(product_id)
        verified.append(item)

unused = set(corrections) - applied_corrections
if unused:
    raise SystemExit(f'Correction ids not found in verified catalogs: {sorted(unused)}')

remaining = []
skipped_equivalent = 0
for item in base:
    product_id = str(item.get('id', '')).strip()
    if product_id in seen_verified:
        continue
    if any(equivalent(item, v) for v in verified):
        skipped_equivalent += 1
        continue
    remaining.append(item)

merged = verified + remaining
BASE.write_text(json.dumps(merged, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(
    f'Merged {len(verified)} verified records; applied {len(applied_corrections)} audited corrections; '
    f'applied GI enrichment to {applied_gi} existing products; skipped {skipped_equivalent} equivalent base records; '
    f'products.json now has {len(merged)} records.'
)
