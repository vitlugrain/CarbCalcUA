#!/usr/bin/env python3
"""Merge generated Ukrainian core into the app's local products asset.

Generated ua_core_* entries replace older same-name generic entries at build time,
so the APK uses source-traceable USDA-backed values while preserving all other
legacy/local products for compatibility.
"""
import json
import re
from pathlib import Path

BASE = Path("assets/products.json")
CORE = Path("assets/ua_core_products.json")


def norm_name(value: str) -> str:
    return re.sub(r"\s+", " ", value.strip().lower())


def main():
    base = json.loads(BASE.read_text(encoding="utf-8"))
    core = json.loads(CORE.read_text(encoding="utf-8"))
    core_names = {norm_name(x.get("name", "")) for x in core}
    kept = [
        x for x in base
        if not str(x.get("id", "")).startswith("ua_core_")
        and norm_name(x.get("name", "")) not in core_names
    ]
    merged = [*core, *kept]
    BASE.write_text(json.dumps(merged, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Merged {len(core)} core foods + {len(kept)} legacy/local foods = {len(merged)}")


if __name__ == "__main__":
    main()
