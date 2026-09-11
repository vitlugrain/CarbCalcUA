#!/usr/bin/env python3
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
BASE = ROOT / 'assets' / 'products.json'
CATALOGS = [
    ROOT / 'assets' / 'ua_dishes.json',
    ROOT / 'assets' / 'mcdonalds_ua_products.json',
]


def load(path):
    if not path.exists():
        raise SystemExit(f'Missing catalog: {path.relative_to(ROOT)}')
    data = json.loads(path.read_text(encoding='utf-8'))
    if not isinstance(data, list):
        raise SystemExit(f'Catalog must be a JSON list: {path.relative_to(ROOT)}')
    return data


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

# Replace only records with the exact same stable id. Names are deliberately not
# deduplicated here: raw/cooked/water/milk/recipe variants must remain separate.
merged = verified + [item for item in base if str(item.get('id', '')).strip() not in seen_verified]
BASE.write_text(json.dumps(merged, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(f'Merged {len(verified)} verified records; products.json now has {len(merged)} records.')
