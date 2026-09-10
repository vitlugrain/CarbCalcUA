#!/usr/bin/env python3
"""Validate curated Ukrainian prepared dishes before they enter the app catalog."""
from __future__ import annotations
import json
import sys
from pathlib import Path

ALLOWED_BASES = {"100g", "100ml"}
REQUIRED = {"id", "name", "category", "carbs", "source", "nutrition_basis"}


def fail(message: str) -> None:
    raise ValueError(message)


def validate_item(item: dict, index: int) -> None:
    missing = [key for key in REQUIRED if key not in item or item[key] in (None, "")]
    if missing:
        fail(f"row {index}: missing {', '.join(missing)}")
    if not str(item["id"]).startswith("ua_dish_"):
        fail(f"row {index}: prepared dish id must start with ua_dish_")
    basis = str(item["nutrition_basis"]).lower()
    if basis not in ALLOWED_BASES:
        fail(f"row {index}: unsupported nutrition_basis {basis}")
    for key in ("carbs", "protein", "fat", "fiber", "calories"):
        value = float(item.get(key, 0) or 0)
        if value < 0:
            fail(f"row {index}: negative {key}")
    source = str(item["source"])
    if "znaimo.gov.ua" not in source and "ЗНАЇМО" not in source.upper():
        fail(f"row {index}: source is not traceable to the approved Ukrainian source")
    aliases = item.get("aliases", [])
    if aliases is not None and not isinstance(aliases, list):
        fail(f"row {index}: aliases must be a list")
    units = item.get("quantity_units", [])
    if units is not None and not isinstance(units, list):
        fail(f"row {index}: quantity_units must be a list")
    if basis == "100ml" and units and not any(str(x).lower() in {"мл", "ml"} for x in units):
        fail(f"row {index}: 100ml dish must expose ml")


def main() -> int:
    path = Path(sys.argv[1] if len(sys.argv) > 1 else "assets/ua_dishes.json")
    if not path.exists():
        print(f"No curated dishes file yet: {path}. Validator ready for the next import batch.")
        return 0
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, list):
        fail("catalog root must be a JSON list")
    ids = set()
    for i, item in enumerate(data, 1):
        if not isinstance(item, dict):
            fail(f"row {i}: expected object")
        validate_item(item, i)
        if item["id"] in ids:
            fail(f"row {i}: duplicate id {item['id']}")
        ids.add(item["id"])
    print(f"Validated {len(data)} Ukrainian prepared dishes")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
