# CarbCalc UA — Catalog Audit Registry

Updated: 2026-09-13
Branch: `dev-large-update`

GitHub is the source of truth. Workflow: `Zakaz.ua discovery → existing-catalog gap check → nutrition verification → pending review → cross-brand generic dedup → runtime integration → parse test`.

## Governing dedup rule

Brand/package/EAN alone never creates a new food. Compare food type, preparation/state and nutrition per 100 g. If an existing generic/base food is nutritionally equivalent or practically equivalent, do not add a branded duplicate. Small label differences caused by rounding/raw-material variation are not enough. Add a new runtime food only for a genuine food/state gap or a nutritionally/culinarily meaningful subtype.

## Workstream registry

| Workstream | Status | Checkpoint |
|---|---|---|
| Рудь | CLOSED | Runtime integrated and device-tested. |
| Danone | SKIPPED | Predominantly dairy groups already covered; reopen only for a genuinely new group. |
| Zakaz.ua — крупи та бобові | FINAL GAP CHECK | Generic gap batches prepared; conflicts isolated; no Zakaz grains runtime merge yet. |

## Крупи та бобові checkpoint

Verified/generic audit batches currently include: red and green lentils, dry chickpeas, dry bulgur, dry semolina, spelt, Artek wheat groats, parboiled rice, sushi rice, barley/yachna candidate, Bandolia/coloured bean candidates, green split peas, dried Vicia faba, Poltava wheat variants, whole oat groats and adzuki beans. Each candidate must still pass final runtime dedup before canonical merge.

Important correction: `assets/zakaz_grains_legumes_verified_part3.json` is now explicitly `duplicate_not_for_runtime` because `assets/products.json` already contains `ua_bonduelle_brown_rice_dry` (`Рис коричневий, сухий`, alias `бурий рис сухий`). Brown rice must therefore not be added again.

Pending/held groups include mung beans, white-bean conflicting labels, quinoa variants, red/black rice, Poltava №3 and wheat/yachna profiles where current retail labels disagree materially. Do not select an arbitrary brand value for these.

Existing staples such as ordinary dry buckwheat, millet, pearl barley, corn grits, couscous, soybeans and brown rice are not to be duplicated by another trademark.

### Runtime state

Zakaz grains/legumes files are **not yet included in `scripts/merge_verified_catalogs.py`**. APK #112 remains the stable device checkpoint. Next gate: final dedup of every verified batch against `assets/products.json`; only surviving generic gaps enter the canonical merge, followed by full runtime parse validation and one APK checkpoint.

### Next category

After successful grains/legumes runtime integration and device test, continue with **Макаронні вироби**, using the same generic nutritional dedup rule.

## Persistence rule

Commit significant audit changes to `dev-large-update`, keep this registry and `PROJECT_STATUS.md` current, and never infer missing nutrition values.
