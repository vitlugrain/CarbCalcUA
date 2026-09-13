# CarbCalc UA — Project Status

Updated: 2026-09-13
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Current checkpoint

Two catalog workstreams are now intentionally grouped before the next Android APK:
1. **Крупи та бобові** — FINAL GAP CHECK / FINAL DEDUP;
2. **Хліб та випічка** — new category pass, GAP REVIEW in progress.

GitHub is the source of truth.

### Governing catalog rule

Do not collect brands. Brand, package size or EAN alone is not a reason for a new runtime food. Compare food type + preparation/state + P/F/C per 100 g. If an existing generic/base food is equivalent or practically equivalent, skip the branded candidate. Small label/rounding/raw-material differences do not justify duplication. New runtime records are only for genuine food/state gaps or nutritionally/culinarily meaningful subtypes.

## APK checkpoint

**APK #112 remains VERIFIED / STABLE on the user's Android device.** Workflow run `34754770248`, head `c1d3169450b4d1a9c63e72798ef6582ad5f8ba39`, artifact `CarbCalcUA-0.6.0-build-112`.

Do not build the next APK yet. First finish grains/legumes final dedup and the bread/bakery gap pass, then integrate both in one checkpoint build.

## Крупи та бобові

Prepared candidate batches cover useful gaps across lentils, chickpeas, bulgur, semolina, spelt, wheat groats, selected rice types, barley/yachna, bean subtypes, split peas, dried broad beans, oat groats and adzuki. Conflicting/uncertain records remain pending (mung beans, white-bean conflicting labels, quinoa variants, red/black rice, Poltava №3 and conflicting wheat/yachna profiles).

Brown-rice candidate part3 was corrected to `duplicate_not_for_runtime` because `assets/products.json` already contains generic dry brown rice.

Zakaz grains/legumes files are still **not wired into the canonical runtime merge**.

## Хліб та випічка — new pass

Initial current-database comparison confirms existing generic coverage for:
- Хліб пшеничний;
- Хліб житній;
- Хліб житньо-пшеничний;
- Хліб гречаний;
- Хліб цільнозерновий;
- Хліб з висівками;
- Лаваш пшеничний;
- Батон нарізний;
- Сушки прості;
- Бублики;
- Пиріжки печені.

These must not be re-added merely because Zakaz lists branded versions.

Initial candidate gaps are recorded in `assets/zakaz_bread_bakery_gap_review.json` (commit `736c51c0e603c905ac833d631ffff2b301350d52`):
- Бородинський / житній заварний хліб;
- тостовий хліб subtypes;
- пшеничний багет;
- чіабата (currently pending because retail carb values differ materially);
- булочка для бургера;
- хлібці/crispbread as a separate group.

Next bread steps: audit current Zakaz examples across these groups plus common buns/rolls, verify cross-brand macro agreement, and create generic verified entries only where defensible. Sweet pastries/croissants should be treated separately because recipe-specific fat/sugar makes generic collapse less reliable.

## Runtime integration plan before next APK

1. Finish grains/legumes final dedup against `assets/products.json`.
2. Finish a practical bread/bakery gap pass and isolate conflicts.
3. Add only surviving generic gaps from both categories to the canonical merge.
4. Run full runtime catalog parse validation/tests.
5. Build one Android APK checkpoint.
6. User device-tests Add Food, search, Diary add flow and performance.
7. If stable, close both category checkpoints and continue to the next category (likely pasta).

## Working rules

- Zakaz.ua is the discovery/current-retail source; official manufacturer data is preferred for verification.
- Never invent missing P/F/C.
- Uncertain/incomplete/conflicting records stay pending and out of runtime.
- Active branch is `dev-large-update`; do not audit on `main`.
- Preserve app behavior, signing/update continuity and local-data upgrade path.
- `CATALOG_AUDIT_STATUS.md` plus this file are the canonical chat handoff.
