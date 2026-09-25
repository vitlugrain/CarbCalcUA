# CarbCalc UA — Device Testing Issues Registry

Updated: 2026-09-24
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

- Current USER-TESTED STABLE checkpoint: **APK #458**
- APK #405 workflow: success.
- APK #405 source commit: `9ac1ebec2d6ed7cd4e8152fa66eacffebc3e3e3e`.
- Installed successfully on Android.
- Existing diary data was preserved.
- APK #458 installed successfully over the previous version and preserved existing diary data.
- APK #458 device verification completed 2026-09-24: `картопля` includes `Картопля смажена`; `печиво` includes Oreo; `Орео` works; Latin `Oreo` no longer returns unrelated products.

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
- **Latest affected APK:** #419. Fully verified fixed on #458.
- **Status:** CLOSED.
- **Observed:** searching for `картопля` does not show `Картопля смажена`, while searching for `смаж...` does show it.
- **Expected:** a base-product query such as `картопля` should include relevant preparation variants, including fried potato.
- **Root cause:** the catalog entry and aliases are correct, and the search service was already expanded from 10 to 30 results. APK #405 exposed the remaining UI-level cap: `FoodSearchService.search()` returned the expanded list, but `lib/main.dart` still rendered only `list.take(10)`. Thus changing the service limit alone could not expand the visible suggestions.
- **Fix:** service default remains 30; the Add Food UI cap was also changed from `list.take(10)` to `list.take(30)`, so the expanded ranked result set is actually visible. Existing regression test covers a fried-potato result beyond the first 10.
- **Fix commits:** `10510dd66872131beb813ea52d4edb35d26c184a`, `c36e18b9b87cc1a8139e90928dee31e5f854ab65`, `885f0ee0fa91e6e76b4a97cc4c020f325466f877`.
- **APK containing latest fix:** #458.
- **Device verification:** APK #458 installed successfully on 2026-09-24 and preserved diary data. User confirmed: `картопля` shows `Картопля смажена`; `печиво` shows Oreo; `Орео` works; Latin `Oreo` returns no unrelated products. T-001 is VERIFIED and CLOSED.
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


## CarbCalc UA 1.0 release verification — APK #478 — 2026-09-24
- Current USER-TESTED STABLE checkpoint: **APK #478**.
- Installed successfully over APK #475; existing food diary preserved.
- Release-scope verification passed: **Імпорт глюкози** and **Історія глюкози** are no longer present in the production UI.
- User reported the application otherwise works normally after the change.
- No regression issue opened from this test cycle.


## CarbCalc UA 1.0 pre-release preparation checkpoint — 2026-09-25
- Source branch: `dev-large-update`. GitHub remains source of truth.
- Current USER-TESTED STABLE baseline remains **APK #478**. Do not replace this stable checkpoint until the next release-candidate APK is installed and verified on the user's Android phone.
- Release positioning remains a Ukrainian **carbohydrate/nutrition tracker and food diary**. Glucose import/history remains out of the production 1.0 UI/runtime scope; legacy SQLite glucose schema remains only for non-destructive upgrade compatibility.
- Runtime food catalog remains **1312 products** and broad catalog expansion remains frozen for 1.0.
- Pre-release Android work completed after #478:
  - `7cf0b08c56a5e456be765a98b4a2eb8b390a35ac`: API 36/app-label preparation. A later compatibility correction intentionally reverted the temporary `--org ua.carbcalc` change.
  - `98159110542c1439f0470c16a1ca6d95c868d92d`: pubspec version set to **1.0.0+1** and unused legacy glucose-import dependencies `file_picker`, `csv`, `syncfusion_flutter_pdf` removed.
  - `90407c09af27886769ad68a34f352f3fdff93df9`: CI aligned to CarbCalc UA 1.0; artifact naming updated and workflow permission reduced to `contents: read`.
  - `eb4da941babcd0b1e913e206addf012b57abee4e`: release manifest generation explicitly includes only required app permissions **INTERNET** (Open Food Facts) and **CAMERA** (barcode scanner); signed release **AAB** build/upload added alongside APK.
  - `1e9bc2e259bb3ea0fb82fa38d88471938499610f`: restored the historical `flutter create --platforms=android --project-name carbcalc_ua .` generation command used by the #478 line, avoiding an application-ID change that could break in-place upgrades/local diary continuity. Do not re-add `--org ua.carbcalc` without an explicit migration/release decision.
  - User approved the second generated CarbCalc UA app icon (plate/vegetables + calculator + blue/yellow arc) and uploaded it to `assets/carbcalc_ua_icon.png` on `dev-large-update` (blob SHA `b8712895960e4d76a62c688592d26fa9975606ad`).
  - `1abe9ba430aa57958c931b0d7daa0dc80d94d352`: CI generates Android launcher PNGs for mdpi/hdpi/xhdpi/xxhdpi/xxxhdpi from the approved icon.
  - `a60ded00fc57037aec4e6e073d0843cf96ba8e66`: final known Ukrainian lexical cleanup in `assets/products.json`: removed alias `жарена картопля`, replaced `кешью` with `кеш’ю` while retaining `кеш'ю`, renamed `Творожні маси та сирки` to `Сиркові маси та сирки`.
- Known remaining pre-release work before the next device APK is considered a release candidate:
  1. Run a control CI pass: dependency resolution, `flutter analyze`, tests, signed APK and signed AAB build with the new icon/API 36/version 1.0.0 configuration.
  2. Inspect any CI failure and fix before asking for device testing.
  3. Install the resulting APK over #478 and verify: in-place upgrade, diary preservation, launch, new icon, search, barcode/camera permission flow, online Open Food Facts fallback, Add/Diary basics, and absence of glucose UI.
  4. Only after user verification, mark the new APK as USER-TESTED STABLE / 1.0 release candidate and proceed with the signed AAB / Google Play Console work.
  5. Update stale documentation such as `BUILD_APK.md` if still inconsistent with Flutter 3.35.7/release signing/1.0 artifact naming.
- Important build policy: do not create APKs after individual micro-fixes. The next build should be the consolidated 1.0 release-candidate test build.

## CarbCalc UA 1.0 release-candidate verification — APK #498 — 2026-09-25
- **Current USER-TESTED STABLE checkpoint: APK #498.** This supersedes #478 and is the CarbCalc UA 1.0 release candidate.
- GitHub Actions run #498 completed fully green from commit `0035ca0ffcf612eb6562486d70767c036d888b46`; analyze, tests, signed APK and signed AAB all passed.
- Installed successfully over #478 without uninstalling; existing diary data was preserved.
- User verified the new launcher icon and confirmed glucose import/history UI remains absent.
- Search verified on device: `картопля`, `печиво`, and `Орео/Oreo` work correctly.
- Add-to-diary flow verified on device.
- Barcode scanner/camera verified on device; online Open Food Facts lookup responded successfully. A non-food barcode returned an unrelated external food record, reinforcing the intentional rule that Open Food Facts results are not automatically added to the verified local catalog.
- No release-blocking regression was reported in this verification cycle.
- Release artifacts: `CarbCalcUA-1.0.0-build-498` (APK) and `CarbCalcUA-1.0.0-AAB-build-498` (signed AAB).
- Next action: proceed to Google Play Console preparation with AAB #498. Any later code/catalog change requires a new CI build and another appropriate verification cycle before replacing this release candidate.
