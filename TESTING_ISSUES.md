# CarbCalc UA — Device Testing Issues Registry

Updated: 2026-09-23
Branch: `dev-large-update`
Repository: `vitlugrain/CarbCalcUA`

## Purpose

This file is the persistent anti-repeat registry for concrete bugs, regressions, UX problems, search problems, catalog defects, and other observations reported during real-device APK testing.

GitHub is the source of truth. Important test findings must not live only in a ChatGPT conversation.

## Mandatory continuation rule

At the start of every new CarbCalc UA development chat, read all three files from `dev-large-update` before doing work:

1. `PROJECT_STATUS.md`
2. `CATALOG_AUDIT_STATUS.md`
3. `TESTING_ISSUES.md`

Before changing any existing GitHub file, refetch its current blob SHA immediately before the write.

Before implementing a reported problem, search this registry first. Do not redo work already recorded here unless the current APK demonstrates a regression or the user explicitly asks to reopen it.

## Status lifecycle

- **OPEN** — reported by the user and not yet fixed.
- **IN PROGRESS** — root cause/code is being investigated or changed.
- **FIXED / AWAITING APK** — code/data fix is committed, but the user has not yet verified it on the target Android APK.
- **VERIFIED** — user confirmed on a real device that the fix works.
- **CLOSED** — verified and no further work is required.
- **REOPENED** — a previously fixed/verified issue is observed again in a later APK.

A code commit alone is never sufficient to mark a device issue VERIFIED or CLOSED.

## Current Android test cycle

- Target under test: **APK #419**
- APK #405 workflow: success.
- APK #405 source commit: `9ac1ebec2d6ed7cd4e8152fa66eacffebc3e3e3e`.
- Installed successfully on Android.
- Existing diary data was preserved.
- APK #419 is the current **device-test checkpoint**; installed successfully and existing diary data was preserved.
- User has indicated that at least one previously discussed correction is still not behaving as agreed. Do not guess the identity of that issue; record it when the user reports the concrete case.

## Issue record format

Each new issue should record:

- stable issue ID, e.g. `T-001`;
- first reported APK;
- latest affected APK;
- status;
- exact user-observed behavior;
- expected behavior agreed with the user;
- root cause when known;
- related files/components;
- fix commit(s);
- APK containing the fix;
- device verification result/date;
- notes about related cases checked to prevent recurrence.

## Registered issues

### T-001 — Base query "картопля" omits "Картопля смажена"

- **First reported APK:** #380 (also reported in an earlier chat before the persistent registry existed).
- **Latest affected APK:** #419 (potato case fixed; cookie/Oreo case still incomplete).
- **Status:** PARTIALLY VERIFIED / REOPENED FOR COOKIE SEARCH.
- **Observed:** searching for `картопля` does not show `Картопля смажена`, while searching for `смаж...` does show it.
- **Expected:** a base-product query such as `картопля` should include relevant preparation variants, including fried potato.
- **Root cause:** the catalog entry and aliases are correct, and the search service was already expanded from 10 to 30 results. APK #405 exposed the remaining UI-level cap: `FoodSearchService.search()` returned the expanded list, but `lib/main.dart` still rendered only `list.take(10)`. Thus changing the service limit alone could not expand the visible suggestions.
- **Fix:** service default remains 30; the Add Food UI cap was also changed from `list.take(10)` to `list.take(30)`, so the expanded ranked result set is actually visible. Existing regression test covers a fried-potato result beyond the first 10.
- **Fix commits:** `10510dd66872131beb813ea52d4edb35d26c184a`, `c36e18b9b87cc1a8139e90928dee31e5f854ab65`, `885f0ee0fa91e6e76b4a97cc4c020f325466f877`.
- **APK containing latest fix:** #419.
- **Device verification:** APK #419 installed successfully and preserved diary data. `картопля` now shows `Картопля смажена` — potato case VERIFIED. `печиво` still does not show Oreo; `Орео` finds it, while Latin `Oreo` shows a broader/noisier result set. Keep the cookie/Oreo search case open.
- **Related check:** `Картопля смажена` exists in runtime as `ua_prodiabet_fried_potatoes` with aliases `смажена картопля`, `картопля смажена`, `жарена картопля`; therefore no duplicate/new catalog product is needed.


### T-002 — Default quantity should be immediately replaceable

- **First reported APK:** #380.
- **Latest affected APK:** #380; verified fixed on #405.
- **Status:** VERIFIED.
- **Observed:** after selecting a product, the quantity field defaults to `100`; tapping the field places the cursor but makes replacing the default value unnecessarily cumbersome.
- **Expected:** if the user leaves the field untouched, `100` remains the default; if the user taps the quantity field, the existing value should be selected so the next typed number replaces it immediately.
- **Implementation:** tapping the main Add Food quantity field now selects the entire current text. This preserves the default value until the user actually types and also works for other current/default quantities, not only `100`.
- **Fix commit:** `71c6e33a092e8bd2f2b4da9412c44e0a7c01fcc2`.
- **APK containing fix:** #405.
- **Device verification:** user confirmed on 2026-09-23 that tapping the default `100` and typing replaces it in one action.


## Build policy during testing

Do not create a new APK after every small correction. Accumulate a meaningful logical batch of fixes, run appropriate validation/tests, then build the next Android test candidate. Every included issue remains **FIXED / AWAITING APK** until the user verifies it on the phone.
