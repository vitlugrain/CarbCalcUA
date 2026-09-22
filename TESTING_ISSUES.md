# CarbCalc UA — Device Testing Issues Registry

Updated: 2026-09-22
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

- Target under test: **APK #380**
- APK #380 workflow: success.
- APK #380 source commit: `180e4889b6fbecc8adde9c1dc9b434b5d42ad4b4`.
- Installed successfully on Android.
- Existing diary data was preserved.
- APK #380 is a **test checkpoint**, not yet a stable baseline.
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

No concrete APK #380 issue has been entered yet. Add the user's next specific observation as `T-001`.

## Build policy during testing

Do not create a new APK after every small correction. Accumulate a meaningful logical batch of fixes, run appropriate validation/tests, then build the next Android test candidate. Every included issue remains **FIXED / AWAITING APK** until the user verifies it on the phone.
