#!/usr/bin/env python3
import json
import re
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets' / 'products.json'
CATALOGS = [
    ROOT / 'assets' / 'ua_dishes.json',
    ROOT / 'assets' / 'mcdonalds_ua_products.json',
    ROOT / 'assets' / 'mcdonalds_ua_chicken_rolls_supplement.json',
    ROOT / 'assets' / 'mcdonalds_ua_sides_sauces.json',
    ROOT / 'assets' / 'mcdonalds_ua_desserts_drinks.json',
    ROOT / 'assets' / 'mcdonalds_ua_desserts_drinks_2.json',
]


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
    # Never collapse distinct preparation/recipe states. This check is intended
    # for the same packaged/beverage product appearing in several source catalogs.
    state_a = str(a.get('state', '')).strip().lower()
    state_b = str(b.get('state', '')).strip().lower()
    if state_a and state_b and state_a != state_b:
        return False
    if not (names(a) & names(b)):
        return False
    return same_nutrition(a, b)


base = load(BASE)
verified = []
seen_verified = set()
for path in CATALOGS:
    for item in load(path):
        product_id = str(item.get('id', '')).strip()
        if not product_id:
            raise SystemExit(f'Missing id in {path.relative_to(ROOT)}')
        if product_id in seen_verified:
            raise SystemExit(f'Duplicate verified id: {product_id}')
        seen_verified.add(product_id)
        verified.append(item)

# Stable IDs replace exact records. Equivalent generic products already present
# in the base catalog are also kept only once. Restaurant-specific portion sizes
# remain represented by servingGrams/servingMl/aliases on the verified record,
# while different preparation states/recipes remain separate products.
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
    f'Merged {len(verified)} verified records; skipped {skipped_equivalent} equivalent base records; '
    f'products.json now has {len(merged)} records.'
)
