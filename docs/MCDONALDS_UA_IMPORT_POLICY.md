# McDonald's Ukraine catalog import policy

## Scope

The CarbCalc UA verified branded catalog may include all current food and beverage positions published in the official McDonald's Ukraine menu. These entries are separate from the approved list of 45 Ukrainian prepared dishes; adding a McDonald's menu item does not consume or modify that approved list.

## Source of truth

Use official McDonald's Ukraine sources first:
- current full menu;
- nutrition calculator;
- official product pages / consumer nutrition information.

Do not invent nutrition values. If an item is visible in the menu but an official carbohydrate value cannot be verified, keep it out of the nutrient catalog until the value is verified.

## Product identity

Store each materially different serving as its own searchable catalog entry when the official menu/nutrition data distinguishes it. Examples: Chicken McNuggets 4/6/9/20 pieces; small/medium/large fries; drink sizes.

Preserve the official Ukrainian product name and add practical aliases only for search. Mark manufacturer/brand as McDonald's Ukraine and retain a human-readable official source reference.

## Nutrition basis and units

Prefer the official serving nutrition for restaurant items because the user normally orders a defined menu portion. Also store verified serving mass/volume when officially available so CarbCalc UA can normalize values safely.

Use 100 ml for beverages only when the official source provides enough information to calculate/verify that basis. Never assume 1 ml = 1 g. Solids remain gram-based when a reliable mass is available.

For piece-based products, expose pieces when the serving is naturally counted in pieces and preserve the exact official serving size.

## Menu lifecycle

Current, seasonal, and temporary McDonald's Ukraine items may be imported. Keep source/provenance so discontinued items can later be marked inactive without changing historical diary entries.

## Safety / historical data

Catalog updates must not recalculate old diary records. Saved diary nutrition remains the value recorded at the time of entry.
