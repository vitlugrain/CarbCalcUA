#!/usr/bin/env python3
"""Build a curated Ukraine-market branded-food cache from Open Food Facts.

Only products with barcode, name, brand and a plausible carbohydrates_100g
value are kept. The result stays separate from USDA/local data for provenance.
Open Food Facts data is ODbL licensed; keep attribution/source metadata.
"""
from __future__ import annotations
import json, time, urllib.parse, urllib.request, urllib.error
from pathlib import Path

OUT=Path("assets/ua_branded_products.json")
API="https://world.openfoodfacts.org/api/v2/search"
TARGET=1000
PAGE_SIZE=100
MAX_PAGES=30

def num(v):
    try: return float(v)
    except (TypeError,ValueError): return None

def fetch(page):
    params={
      "countries_tags_en":"ukraine",
      "page":str(page),"page_size":str(PAGE_SIZE),
      "sort_by":"popularity_key",
      "fields":"code,product_name,product_name_uk,brands,categories,nutriments,serving_size,quantity",
    }
    url=API+"?"+urllib.parse.urlencode(params)
    req=urllib.request.Request(url,headers={"User-Agent":"CarbCalc-UA/0.7 (offline database builder)"})
    last_error=None
    for attempt in range(5):
        try:
            with urllib.request.urlopen(req,timeout=60) as r:
                return json.load(r)
        except (urllib.error.HTTPError, urllib.error.URLError) as e:
            last_error=e
            if isinstance(e, urllib.error.HTTPError) and e.code not in (429, 500, 502, 503, 504):
                raise
            wait=2 ** attempt
            print(f"Open Food Facts temporary error ({e}); retrying in {wait}s...")
            time.sleep(wait)
    raise last_error

def clean(p):
    code=str(p.get("code") or "").strip()
    name=str(p.get("product_name_uk") or p.get("product_name") or "").strip()
    brand=str(p.get("brands") or "").strip()
    n=p.get("nutriments") or {}
    carbs=num(n.get("carbohydrates_100g"))
    if not code or not name or not brand or carbs is None or carbs < 0 or carbs > 100:
        return None
    protein=num(n.get("proteins_100g")) or 0
    fat=num(n.get("fat_100g")) or 0
    fiber=num(n.get("fiber_100g")) or 0
    kcal=num(n.get("energy-kcal_100g")) or 0
    return {
      "id":"off_"+code,"name":name,"category":str(p.get("categories") or "Брендовані продукти"),
      "carbs":round(carbs,3),"protein":round(protein,3),"fat":round(fat,3),
      "fiber":round(fiber,3),"calories":round(kcal,1),"state":"prepared",
      "barcode":code,"manufacturer":brand,"source":"Open Food Facts (ODbL)",
    }

def main():
    out=[]; seen=set()
    for page in range(1,MAX_PAGES+1):
        try:
            payload=fetch(page)
        except urllib.error.HTTPError as e:
            if out and e.code in (401, 403, 429, 500, 502, 503, 504):
                print(f"Stopping import after {len(out)} accepted products because API returned HTTP {e.code}.")
                break
            raise
        except urllib.error.URLError as e:
            if out:
                print(f"Stopping import after {len(out)} accepted products because API is unavailable: {e}")
                break
            raise
        products=payload.get("products") or []
        if not products: break
        for p in products:
            x=clean(p)
            if x and x["barcode"] not in seen:
                seen.add(x["barcode"]); out.append(x)
                if len(out)>=TARGET: break
        print(f"page {page}: {len(out)} accepted")
        if len(out)>=TARGET: break
        time.sleep(0.15)
    OUT.parent.mkdir(parents=True,exist_ok=True)
    OUT.write_text(json.dumps(out,ensure_ascii=False,separators=(",",":"))+"\n",encoding="utf-8")
    print(f"Wrote {len(out)} Ukraine-market branded foods to {OUT}")

if __name__=="__main__": main()
