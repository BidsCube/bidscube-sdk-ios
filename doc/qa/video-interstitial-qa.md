# QA — Video Interstitial

## Environment

- App: **`testApp-ios`** (workspace `bidscubeSdk.xcworkspace`)
- Tab: **Video Interstitial**
- Simulator or device with network (video URLs are remote)

## Fixtures

| Button | Fixture | Expected |
|--------|---------|----------|
| Case 1: VAST without preview | `BidscubeSDKVideoInterstitialQA.vastWithoutPreview` | Doordash burger video |
| Case 2: VAST with preview | `BidscubeSDKVideoInterstitialQA.vastWithPreview` | Big Buck Bunny + companion image |
| Preview: default fallback | `vastWithoutPreview` (preview-only API) | End card with SDK default image — **QA layout only** |
| Preview: parsed companion | `vastWithPreview` (preview-only API) | End card with gstatic companion image |

---

## TC-1 — No companion (Case 1)

**Steps**

1. Tap **Case 1: VAST without preview**.
2. Watch video until end.

**Expected**

- [ ] Video plays (IMA).
- [ ] **No** skip / countdown overlay during playback.
- [ ] When video finishes, ad **closes** (returns to test app).
- [ ] **No** end card / preview screen.
- [ ] Callbacks (console): `onVideoAdStarted`, `onVideoAdCompleted`, `onAdClosed` — **not** `onEndCardShown`, **not** `onVideoAdSkippable`.

---

## TC-2 — With companion: skip flow (Case 2)

**Steps**

1. Tap **Case 2: VAST with preview**.
2. Wait for skip countdown (`Skip in 5` … `Skip in 1`).
3. Tap **Skip**.

**Expected**

- [ ] Countdown visible; button width stable (no flicker).
- [ ] Skip becomes active after 5 seconds.
- [ ] Skip stops video and shows **end card**.
- [ ] End card shows companion image, title, stars, Install Now.
- [ ] Callbacks: `onVideoAdSkippable`, `onVideoAdSkipped`, `onEndCardShown`.

---

## TC-3 — With companion: complete flow (Case 2)

**Steps**

1. Tap **Case 2**.
2. Do **not** skip; watch until video ends (~30s sample).

**Expected**

- [ ] End card appears after completion.
- [ ] Callbacks: `onVideoAdCompleted`, `onEndCardShown` (not `onVideoAdSkipped`).

---

## TC-4 — End card interactions

**Precondition:** End card visible (TC-2 or TC-3).

**Steps**

1. Tap **Install Now**.
2. Relaunch ad, reach end card again, tap preview image.
3. Tap **✕** (top-right, compact button).

**Expected**

- [ ] Install Now opens browser (google.com for Case 2 fixture).
- [ ] Preview tap opens same click URL once (`onAdClicked` once per session).
- [ ] ✕ closes ad (`onAdClosed`); button is **not** excessively wide.

---

## TC-5 — Preview-only screens

**Steps**

1. Tap **Preview: parsed companion image**.
2. Dismiss, tap **Preview: default fallback image**.

**Expected**

- [ ] No video phase; end card shows immediately.
- [ ] Parsed variant uses companion from VAST.
- [ ] Fallback variant uses default placeholder image (QA only — not used after video without companion).

---

## TC-6 — Production placement (smoke)

**Steps**

1. Integrate real `placementId` via `showInterstitialVideoAd` in a staging app build.
2. Trigger with live VAST from ad server.

**Expected**

- [ ] Behaviour matches VAST: companion present → skip + end card; absent → close after video.

---

## Regression checklist (release gate)

- [ ] TC-1 through TC-5 pass on latest iOS simulator
- [ ] `bidscubeSdk` scheme builds Release
- [ ] Rewarded ad (`showRewardedVideoAd`) still works (legacy path)
- [ ] No duplicate `onAdClosed` on dismiss

Report issues with: fixture name, iOS version, callback log, screenshot/recording.
