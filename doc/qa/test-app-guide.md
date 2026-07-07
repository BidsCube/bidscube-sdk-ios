# Test App Guide — `testApp-ios`

Internal QA application for manual SDK testing.

---

## Setup

```bash
cd bidscube-sdk-ios
pod install
open bidscubeSdk.xcworkspace
```

Select scheme **`testApp-ios`**, run on simulator or device.

**Bundle ID:** `com.bidscube.ios.testApp`

---

## App structure

| File | Role |
|------|------|
| `testApp_iosApp.swift` | `@main` entry; optional AppLovin MAX init via runtime reflection |
| `TestAppRootView.swift` | TabView root; calls `BidscubeSDK.initialize()` + consent update |
| `VideoInterstitialTestView.swift` | Video interstitial QA buttons |
| `TestAdDelegate.swift` | Logs all callbacks to console |
| `MAXTestView.swift` | AppLovin mediation tests (requires Pods) |
| `UIViewRepresentableWrapper.swift` | SwiftUI/UIKit helpers |

---

## Tabs

### Video Interstitial

Primary QA for release 1.2.4.

| Button | Action |
|--------|--------|
| Case 1: VAST without preview | Full interstitial, no skip, close after video |
| Case 2: VAST with preview | Skip + end card |
| Preview: default fallback | End card only (layout QA) |
| Preview: parsed companion | End card only with VAST image |

See [video-interstitial-qa.md](video-interstitial-qa.md).

### MAX (if AppLovin linked)

Mediation smoke tests — banner, MREC, interstitial, rewarded via MAX SDK.

Requires CocoaPods workspace build.

---

## Console logging

`TestAdDelegate` prints:
```
[TestAdDelegate] loading: test-interstitial
[TestAdDelegate] video started: …
[TestAdDelegate] end card shown: …
```

Filter Xcode console by `TestAdDelegate`.

---

## Presenting ads from SwiftUI

`VideoInterstitialTestView` resolves presenter via:
```swift
UIApplication.shared.connectedScenes
  → key window → rootViewController → top presented VC
```

If buttons do nothing, check window/scene availability (iOS 15+ multi-window edge cases).

---

## Building without MAX

`TestAppRootView` wraps MAX tab in `#if canImport(AppLovinSDK)`. Video Interstitial tab works without AppLovin.

---

## Adding new QA scenarios

1. Add fixture to `VideoInterstitialTestVAST.swift` (SDK).
2. Expose via `BidscubeSDKVideoInterstitialQA` if needed publicly for test app.
3. Add button in `VideoInterstitialTestView.swift`.
4. Document in [video-interstitial-qa.md](video-interstitial-qa.md).

---

## Simulator tips

- Network required for remote video/image URLs.
- Reset simulator if IMA state stuck: Device → Erase All Content and Settings.
- Prefer iPhone simulator for fullscreen interstitial layout.
