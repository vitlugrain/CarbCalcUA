# CarbCalc UA — Ukrainian dishes source policy

## Goal
Build the Ukrainian prepared-dish layer only from traceable sources. Do not invent carbohydrate values and do not silently treat recipe ingredient weight as the finished-dish nutrition value.

## Primary source
The preferred recipe/technology-card source is the Ukrainian Znaimo platform (ЗНАЇМО), including the verified collections of technological cards and the 2024 recipe collection for educational, recreation and social-protection institutions.

Reference pages:
- https://znaimo.gov.ua/techCards
- https://znaimo.gov.ua/Contents/ContentItems/4rm07tk52aq6a092gzvs0bz6n0
- https://znaimo.gov.ua/Contents/ContentItems/466ybsmgtezpx7enf99mnqgtwb

The collection states that the Ministry of Health considers the 2024 recipe collection usable in general secondary education institutions; it also records sanitary-epidemiological review and educational approval.

## Import rules
1. Every prepared dish must retain a human-readable source reference and technological-card number/name when available.
2. A dish may enter the verified catalog only when its carbohydrate value can be derived from explicit nutrition data in the source or from traceable ingredient nutrition plus an explicit finished yield.
3. Finished yield must be respected. Never divide ingredient carbohydrates by raw ingredient mass when the technological card gives a different finished-dish yield.
4. Water, cooking loss/gain and recipe yield must not be replaced by a guessed density or guessed conversion.
5. Values are normalized to 100 g for solid prepared dishes and to 100 ml only when the source explicitly provides a volume-based nutrition basis.
6. Different recipes/preparation states remain separate when they materially change carbohydrate content (for example, buckwheat cooked on water vs milk).
7. Near-identical names must not be collapsed unless recipe identity and nutrition are genuinely equivalent.
8. Source provenance is part of the product record. Historical saved diary entries are never retroactively recalculated when the catalog changes.

## Initial verified targets
Start with common dishes useful for carbohydrate counting, prioritizing:
- porridges and cereal side dishes;
- potato and vegetable side dishes;
- soups/borshch/kapusniak;
- syrnyky, casseroles and flour dishes;
- compotes and other drinks where a reliable volume basis is available.

Example confirmed source card: Znaimo technological card 10.6, «Гречана каша з чебрецем», category «гарніри», Ukrainian cuisine, with an explicit finished yield of 1000 g and portion yields.

## Quality gate
A generated catalog build must fail rather than publish an entry with missing provenance, non-positive finished yield, negative macros, or an unsupported nutrition basis.
