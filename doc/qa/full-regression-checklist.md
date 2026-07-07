# Full Regression Checklist

Pre-release manual regression for BidsCube iOS SDK. Complement with unit tests and CI build.

**Version under test:** __________  
**Tester:** __________  
**Date:** __________  
**Device / iOS:** __________  

---

## Build & smoke

- [ ] `pod install` succeeds
- [ ] `bidscubeSdk` scheme builds Debug + Release
- [ ] `testApp-ios` scheme builds
- [ ] `pod spec lint bidscubeSdk.podspec --allow-warnings` passes
- [ ] SDK version in app matches release (`Constants.sdkVersion`)

---

## Initialization

- [ ] `BidscubeSDK.initialize()` without crash
- [ ] `BidscubeSDK.isInitialized()` returns true
- [ ] Second initialize is safe (no crash)
- [ ] `cleanup()` resets state

---

## Banner

- [ ] `showFooterBanner` displays WebView content
- [ ] Tap fires `onAdClicked` (if clickable creative)
- [ ] `removeAllBanners()` detaches banners
- [ ] Corner radius variant renders

---

## Image

- [ ] `getImageAdView` returns view
- [ ] `onAdLoading`, delayed `onAdLoaded` / `onAdDisplayed`
- [ ] `presentImageAd` fullscreen works
- [ ] Invalid placement → `onAdFailed`

---

## Native

- [ ] `getNativeAdView` renders layout
- [ ] Impression trackers fire once on display
- [ ] `presentNativeAd` fullscreen works

---

## Video interstitial (1.2.4)

Use [video-interstitial-qa.md](video-interstitial-qa.md):

- [ ] TC-1: No preview — no skip, close after video
- [ ] TC-2: Skip flow → end card
- [ ] TC-3: Complete flow → end card
- [ ] TC-4: CTA, preview tap, close button
- [ ] TC-5: Preview-only screens
- [ ] TC-6: Production placement smoke (if staging available)

---

## Video rewarded (legacy)

- [ ] `showRewardedVideoAd` plays video
- [ ] Full watch → `onUserRewarded` + `onAdClosed`
- [ ] Skip / early close → `onVideoAdSkipped`, **no** `onUserRewarded`
- [ ] `getRewardedVideoAdView` inline works

---

## Callback integrity

- [ ] `onAdClosed` fires once per session
- [ ] No crash when callback is nil
- [ ] Weak delegate: retained delegate receives all events

---

## SKAdNetwork (optional)

- [ ] `getSKAdNetworkIDs()` returns plist entries
- [ ] `registerSKAdNetwork()` no crash on iOS 14+

---

## Consent stub

- [ ] `requestConsentInfoUpdate` → `onConsentInfoUpdated`
- [ ] `showConsentForm` → grant callbacks

---

## Mediation (optional)

- [ ] MAX tab loads (if Pods present)
- [ ] MAX interstitial/rewarded smoke

---

## Release artifacts

- [ ] README changelog updated
- [ ] `RELEASE.md` version correct
- [ ] Git tag created and pushed
- [ ] GitHub Actions green
- [ ] CocoaPods version searchable

---

## Sign-off

| Role | Name | Approved |
|------|------|----------|
| iOS dev | | |
| QA | | |
| PM | | |

**Notes:**

_____________________________________________
