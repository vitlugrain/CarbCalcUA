#!/usr/bin/env python3
"""Build the curated Ukrainian CarbCalc UA food core from USDA output.

The full USDA Foundation/SR database is generated first by build_usda_offline_db.py.
This script selects simple, common foods, gives them Ukrainian names/aliases and
keeps the original USDA description in the source field. No nutrient values are
invented here: macros/calories are copied from the matched USDA record.
"""
from __future__ import annotations

import json
import re
from pathlib import Path

SRC = Path("assets/usda_products.json")
OUT = Path("assets/ua_core_products.json")


def norm(s: str) -> str:
    return re.sub(r"[^a-z0-9]+", " ", s.lower()).strip()


def entry(name, category, include, aliases=(), exclude=(), state=None, grams_per_piece=None):
    return {
        "name": name,
        "category": category,
        "include": tuple(norm(x) for x in include),
        "exclude": tuple(norm(x) for x in exclude),
        "aliases": list(aliases),
        "state": state,
        "gramsPerPiece": grams_per_piece,
    }


# First Food Database 1.0 batch: everyday foods relevant to Ukrainian users.
# Selectors intentionally favor simple unbranded USDA descriptions.
CORE = [
    # Овочі
    entry("Картопля, сира", "Овочі", ["potato", "raw"], ["картопля", "сира картопля"], ["sweet", "skin only"]),
    entry("Картопля, варена", "Овочі", ["potato", "boiled"], ["картопля", "варена картопля"], ["sweet"] , "cooked"),
    entry("Картопля, запечена", "Овочі", ["potato", "baked"], ["картопля", "запечена картопля"], ["sweet"], "cooked"),
    entry("Морква, сира", "Овочі", ["carrot", "raw"], ["морква", "сира морква"]),
    entry("Морква, варена", "Овочі", ["carrot", "cooked", "boiled"], ["морква", "варена морква"], state="cooked"),
    entry("Буряк, сирий", "Овочі", ["beets", "raw"], ["буряк", "сирий буряк"]),
    entry("Буряк, варений", "Овочі", ["beets", "cooked", "boiled"], ["буряк", "варений буряк"], state="cooked"),
    entry("Капуста білокачанна, сира", "Овочі", ["cabbage", "raw"], ["капуста", "білокачанна капуста"], ["red", "savoy", "chinese"]),
    entry("Капуста білокачанна, варена", "Овочі", ["cabbage", "cooked", "boiled"], ["капуста", "варена капуста"], ["red", "savoy", "chinese"], "cooked"),
    entry("Помідор, сирий", "Овочі", ["tomatoes", "raw"], ["помідор", "томат", "помідори"]),
    entry("Огірок, сирий", "Овочі", ["cucumber", "raw"], ["огірок", "огірки"]),
    entry("Цибуля ріпчаста, сира", "Овочі", ["onions", "raw"], ["цибуля", "ріпчаста цибуля"]),
    entry("Часник, сирий", "Овочі", ["garlic", "raw"], ["часник"]),
    entry("Перець солодкий червоний, сирий", "Овочі", ["peppers", "sweet", "red", "raw"], ["перець", "болгарський перець"]),
    entry("Кабачок, сирий", "Овочі", ["zucchini", "raw"], ["кабачок", "цукіні"]),
    entry("Баклажан, сирий", "Овочі", ["eggplant", "raw"], ["баклажан"]),
    entry("Гарбуз, варений", "Овочі", ["pumpkin", "cooked", "boiled"], ["гарбуз"], state="cooked"),
    entry("Кукурудза солодка, варена", "Овочі", ["corn", "sweet", "cooked", "boiled"], ["кукурудза"], state="cooked"),
    entry("Горох зелений, варений", "Бобові", ["peas", "green", "cooked", "boiled"], ["горох", "зелений горошок"], state="cooked"),
    entry("Квасоля біла, варена", "Бобові", ["beans", "white", "cooked", "boiled"], ["квасоля", "біла квасоля"], state="cooked"),
    entry("Сочевиця, варена", "Бобові", ["lentils", "cooked", "boiled"], ["сочевиця"], state="cooked"),
    entry("Нут, варений", "Бобові", ["chickpeas", "cooked", "boiled"], ["нут", "турецький горох"], state="cooked"),

    # Фрукти та ягоди
    entry("Яблуко, свіже", "Фрукти", ["apples", "raw", "with skin"], ["яблуко", "яблука", "свіже яблуко"]),
    entry("Банан, свіжий", "Фрукти", ["bananas", "raw"], ["банан", "банани"]),
    entry("Груша, свіжа", "Фрукти", ["pears", "raw"], ["груша", "груші"]),
    entry("Апельсин, свіжий", "Фрукти", ["oranges", "raw"], ["апельсин", "апельсини"]),
    entry("Мандарин, свіжий", "Фрукти", ["tangerines", "raw"], ["мандарин", "мандарини"]),
    entry("Лимон, свіжий", "Фрукти", ["lemons", "raw"], ["лимон", "лимони"]),
    entry("Виноград, свіжий", "Фрукти", ["grapes", "raw"], ["виноград"]),
    entry("Персик, свіжий", "Фрукти", ["peaches", "raw"], ["персик", "персики"]),
    entry("Абрикос, свіжий", "Фрукти", ["apricots", "raw"], ["абрикос", "абрикоси"]),
    entry("Слива, свіжа", "Фрукти", ["plums", "raw"], ["слива", "сливи"]),
    entry("Полуниця, свіжа", "Ягоди", ["strawberries", "raw"], ["полуниця", "клубніка"]),
    entry("Малина, свіжа", "Ягоди", ["raspberries", "raw"], ["малина"]),
    entry("Чорниця, свіжа", "Ягоди", ["blueberries", "raw"], ["чорниця"]),
    entry("Кавун, свіжий", "Фрукти", ["watermelon", "raw"], ["кавун"]),
    entry("Диня, свіжа", "Фрукти", ["melons", "cantaloupe", "raw"], ["диня"]),

    # Крупи / макарони
    entry("Рис білий, варений", "Крупи", ["rice", "white", "cooked"], ["рис", "білий рис"], ["long grain enriched parboiled"], "cooked"),
    entry("Рис коричневий, варений", "Крупи", ["rice", "brown", "cooked"], ["рис", "бурий рис", "коричневий рис"], state="cooked"),
    entry("Гречка, варена", "Крупи", ["buckwheat", "groats", "cooked"], ["гречка", "гречана каша"], state="cooked"),
    entry("Вівсяна каша на воді", "Крупи", ["oatmeal", "cooked", "water"], ["вівсянка", "вівсяна каша"], state="cooked"),
    entry("Булгур, варений", "Крупи", ["bulgur", "cooked"], ["булгур"], state="cooked"),
    entry("Кускус, варений", "Крупи", ["couscous", "cooked"], ["кускус"], state="cooked"),
    entry("Кіноа, варена", "Крупи", ["quinoa", "cooked"], ["кіноа"], state="cooked"),
    entry("Макарони, варені", "Макарони", ["pasta", "cooked"], ["макарони", "паста"], ["corn", "rice", "gluten free"], "cooked"),
    entry("Спагетті, варені", "Макарони", ["spaghetti", "cooked"], ["спагетті", "паста спагетті"], ["spinach"], "cooked"),
    entry("Спагетті, сухі", "Макарони", ["spaghetti", "dry"], ["спагетті", "сухі спагетті"], ["spinach"]),

    # Молочні / яйця
    entry("Молоко 2%", "Молочні", ["milk", "reduced fat", "2%"], ["молоко", "молоко 2%"]),
    entry("Молоко незбиране", "Молочні", ["milk", "whole", "3.25%"], ["молоко", "незбиране молоко"]),
    entry("Йогурт натуральний", "Молочні", ["yogurt", "plain", "whole milk"], ["йогурт", "натуральний йогурт"]),
    entry("Кефір, нежирний", "Молочні", ["kefir", "lowfat", "plain"], ["кефір"]),
    entry("Сир кисломолочний", "Молочні", ["cottage cheese", "lowfat"], ["сир кисломолочний", "творог"]),
    entry("Сир моцарела", "Молочні", ["cheese", "mozzarella"], ["моцарела", "сир моцарела"]),
    entry("Сир фета", "Молочні", ["cheese", "feta"], ["фета", "сир фета"]),
    entry("Масло вершкове", "Молочні", ["butter", "salted"], ["масло", "вершкове масло"]),
    entry("Яйце куряче, сире", "Яйця", ["egg", "whole", "raw", "fresh"], ["яйце", "яйця", "куряче яйце"], grams_per_piece=50),
    entry("Яйце куряче, варене", "Яйця", ["egg", "whole", "cooked", "hard boiled"], ["яйце", "варене яйце", "яйця варені"], state="cooked", grams_per_piece=50),

    # М'ясо / риба
    entry("Куряче філе, сире", "М'ясо та птиця", ["chicken", "breast", "meat only", "raw"], ["курка", "курятина", "куряче філе", "куряча грудка"]),
    entry("Куряче філе, запечене", "М'ясо та птиця", ["chicken", "breast", "meat only", "roasted"], ["курка", "курятина", "куряче філе"], state="cooked"),
    entry("Куряче стегно, запечене", "М'ясо та птиця", ["chicken", "thigh", "meat only", "roasted"], ["курка", "куряче стегно"], state="cooked"),
    entry("Індичка, філе запечене", "М'ясо та птиця", ["turkey", "breast", "meat only", "roasted"], ["індичка", "індичатина"], state="cooked"),
    entry("Яловичина, приготована", "М'ясо та птиця", ["beef", "cooked"], ["яловичина", "говядина"], ["liver", "kidney", "heart", "brain", "luncheon"], "cooked"),
    entry("Свинина, приготована", "М'ясо та птиця", ["pork", "cooked"], ["свинина"], ["liver", "kidney", "heart", "sausage", "bacon"], "cooked"),
    entry("Сало свиняче, сире", "М'ясо та птиця", ["pork", "fat", "raw"], ["сало", "свиняче сало"], ["rendered", "lard"]),
    entry("Лосось, запечений", "Риба", ["salmon", "cooked", "dry heat"], ["лосось", "сьомга", "риба"], state="cooked"),
    entry("Форель, запечена", "Риба", ["trout", "cooked", "dry heat"], ["форель", "риба"], state="cooked"),
    entry("Скумбрія, приготована", "Риба", ["mackerel", "cooked", "dry heat"], ["скумбрія", "риба"], state="cooked"),
    entry("Тріска, приготована", "Риба", ["cod", "cooked", "dry heat"], ["тріска", "риба"], state="cooked"),
    entry("Тунець консервований у воді", "Риба", ["tuna", "canned", "water"], ["тунець", "риба"], state="prepared"),
    entry("Оселедець, приготований", "Риба", ["herring", "cooked", "dry heat"], ["оселедець", "риба"], state="cooked"),

    # Гриби / горіхи / насіння
    entry("Печериці, сирі", "Гриби", ["mushrooms", "white", "raw"], ["гриби", "печериці", "шампіньйони"]),
    entry("Печериці, приготовані", "Гриби", ["mushrooms", "white", "cooked"], ["гриби", "печериці", "шампіньйони"], state="cooked"),
    entry("Гливи, сирі", "Гриби", ["mushrooms", "oyster", "raw"], ["гриби", "гливи"]),
    entry("Шиїтаке, сирі", "Гриби", ["mushrooms", "shiitake", "raw"], ["гриби", "шиїтаке"]),
    entry("Волоські горіхи", "Горіхи", ["nuts", "walnuts", "english"], ["горіх", "горіхи", "волоські горіхи"]),
    entry("Мигдаль", "Горіхи", ["nuts", "almonds"], ["мигдаль"]),
    entry("Арахіс, сирий", "Горіхи", ["peanuts", "raw"], ["арахіс"]),
    entry("Насіння соняшнику, очищене", "Насіння", ["seeds", "sunflower", "dried"], ["насіння", "соняшникове насіння"]),
]


def score(food: dict, spec: dict) -> int | None:
    n = norm(food.get("name", ""))
    if not all(term in n for term in spec["include"]):
        return None
    if any(term in n for term in spec["exclude"]):
        return None
    # Prefer Foundation Foods and shorter/simple descriptions.
    s = 100 if str(food.get("source", "")).startswith("USDA Foundation") else 0
    s += 60 * len(spec["include"])
    s -= len(n.split())
    if "," not in food.get("name", ""):
        s += 4
    return s


def main():
    foods = json.loads(SRC.read_text(encoding="utf-8"))
    out = []
    missing = []
    used_ids = set()

    for spec in CORE:
        candidates = []
        for food in foods:
            s = score(food, spec)
            if s is not None:
                candidates.append((s, food))
        if not candidates:
            missing.append(spec["name"])
            continue
        candidates.sort(key=lambda x: (-x[0], len(x[1].get("name", ""))))
        src = candidates[0][1]
        if src["id"] in used_ids:
            missing.append(spec["name"] + " [duplicate source]")
            continue
        used_ids.add(src["id"])
        x = dict(src)
        x["id"] = "ua_core_" + src["id"].removeprefix("usda_")
        x["name"] = spec["name"]
        x["category"] = spec["category"]
        x["aliases"] = spec["aliases"]
        x["source"] = f"{src.get('source', 'USDA FoodData Central')} · {src.get('name', '')}"
        if spec.get("state"):
            x["state"] = spec["state"]
        if spec.get("gramsPerPiece"):
            x["gramsPerPiece"] = spec["gramsPerPiece"]
        out.append(x)

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(out, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
    print(f"Wrote {len(out)} Ukrainian core foods to {OUT}")
    if missing:
        print("Selectors not matched:")
        for name in missing:
            print(" -", name)
    # Keep the build useful even if a few selectors change in a future USDA release,
    # but fail if the core unexpectedly collapses.
    if len(out) < 45:
        raise SystemExit(f"Ukrainian core unexpectedly small: {len(out)}")


if __name__ == "__main__":
    main()
