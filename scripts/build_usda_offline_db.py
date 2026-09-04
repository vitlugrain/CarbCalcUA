#!/usr/bin/env python3
"""Build a compact offline USDA food database for CarbCalc UA.

Sources:
- FoodData Central Foundation Foods
- FoodData Central SR Legacy

The generated JSON contains only fields needed by CarbCalc UA and is embedded
into the APK, so runtime food lookup remains offline.
"""
from __future__ import annotations

import io
import json
import urllib.request
import zipfile
from pathlib import Path

SOURCES = [
    (
        "USDA Foundation Foods",
        "https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_foundation_food_json_2026-04-30.zip",
    ),
    (
        "USDA SR Legacy",
        "https://fdc.nal.usda.gov/fdc-datasets/FoodData_Central_sr_legacy_food_json_2018-04.zip",
    ),
]

OUT = Path("assets/usda_products.json")

NUTRIENT_KEYS = {
    "carbs": {
        "carbohydrate, by difference",
        "carbohydrate, by summation",
    },
    "protein": {"protein"},
    "fat": {"total lipid (fat)", "total fat (nlea)"},
    "fiber": {"fiber, total dietary"},
    "calories": {"energy"},
}


def n(value):
    try:
        return float(value)
    except (TypeError, ValueError):
        return 0.0


def nutrient_name(item):
    nutrient = item.get("nutrient") or {}
    return str(nutrient.get("name") or item.get("nutrientName") or "").strip().lower()


def nutrient_unit(item):
    nutrient = item.get("nutrient") or {}
    return str(nutrient.get("unitName") or item.get("unitName") or "").strip().upper()


def nutrient_amount(item):
    return n(item.get("amount", item.get("value", 0)))


def nutrients(food):
    result = {"carbs": 0.0, "protein": 0.0, "fat": 0.0, "fiber": 0.0, "calories": 0.0}
    found = set()
    for item in food.get("foodNutrients") or []:
        name = nutrient_name(item)
        for key, names in NUTRIENT_KEYS.items():
            if key in found or name not in names:
                continue
            value = nutrient_amount(item)
            if key == "calories":
                unit = nutrient_unit(item)
                if unit == "KJ":
                    value /= 4.184
            result[key] = value
            found.add(key)
    return result


def extract_foods(payload):
    if isinstance(payload, list):
        return payload
    if not isinstance(payload, dict):
        return []
    for key in ("FoundationFoods", "SRLegacyFoods", "foods"):
        value = payload.get(key)
        if isinstance(value, list):
            return value
    # Be tolerant to future wrapper-name changes.
    for value in payload.values():
        if isinstance(value, list) and value and isinstance(value[0], dict) and (
            "description" in value[0] or "fdcId" in value[0]
        ):
            return value
    return []


def category(food):
    c = food.get("foodCategory")
    if isinstance(c, dict):
        c = c.get("description")
    return str(c or "USDA").strip()


def state_from_name(name):
    x = name.lower()
    cooked = ("cooked", "boiled", "baked", "roasted", "fried", "prepared")
    return "cooked" if any(v in x for v in cooked) else "raw"


def read_source(label, url):
    print(f"Downloading {label}...")
    req = urllib.request.Request(url, headers={"User-Agent": "CarbCalc-UA/0.6"})
    with urllib.request.urlopen(req, timeout=120) as response:
        raw = response.read()
    with zipfile.ZipFile(io.BytesIO(raw)) as z:
        json_files = [x for x in z.namelist() if x.lower().endswith(".json")]
        if not json_files:
            raise RuntimeError(f"No JSON file in {url}")
        with z.open(json_files[0]) as f:
            payload = json.load(f)
    return extract_foods(payload)


def main():
    output = []
    seen = set()
    for label, url in SOURCES:
        for food in read_source(label, url):
            fdc_id = food.get("fdcId") or food.get("fdc_id") or food.get("ndbNumber")
            name = str(food.get("description") or "").strip()
            if not fdc_id or not name:
                continue
            vals = nutrients(food)
            # Nutrient values are per 100 g in Foundation/SR food records.
            # Keep foods with carbohydrate data; zero-carb foods are valid if
            # they have other macronutrient/energy data.
            if not any(vals.values()):
                continue
            key = (name.lower(), round(vals["carbs"], 2), label)
            if key in seen:
                continue
            seen.add(key)
            output.append(
                {
                    "id": f"usda_{fdc_id}",
                    "name": name,
                    "category": category(food),
                    "carbs": round(vals["carbs"], 3),
                    "protein": round(vals["protein"], 3),
                    "fat": round(vals["fat"], 3),
                    "fiber": round(vals["fiber"], 3),
                    "calories": round(vals["calories"], 1),
                    "state": state_from_name(name),
                    "barcode": "",
                    "source": label,
                }
            )

    output.sort(key=lambda x: (x["category"], x["name"]))
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(output, ensure_ascii=False, separators=(",", ":")) + "\n", encoding="utf-8")
    print(f"Wrote {len(output)} USDA foods to {OUT}")


if __name__ == "__main__":
    main()
