# Troubleshooting

Common issues for internal support and engineering.

---

## Video interstitial

### Black screen, no video

| Cause | Fix |
|-------|-----|
| `loadAd` before view laid out | Fixed: loads in `viewDidAppear` |
| Inline VAST via wrong IMA API | Must use base64 data URI (not raw `adsResponse`) |
| Invalid VAST / bad MediaFile URL | Check SSP response; test with `BidscubeSDKVideoInterstitialQA.vastWithPreview` |
| No network on simulator | Enable network; check ATS (all HTTPS) |

### Skip button doesn't work

| Cause | Fix |
|-------|-----|
| Countdown not finished | Wait for `onVideoAdSkippable` |
| No companion in VAST | Skip hidden by design |
| IMA skip silent failure | Module synthesizes skip locally after tap |

### End card never shows

| Cause | Fix |
|-------|-----|
| No companion in VAST | Expected — ad closes instead |
| Parser failed on `<Companion>` | Fixed: `firstMatch` returns full match without capture group |
| `previewImageUrl` nil | Debug with `VastMetadataParser.parse(vast)` |

### End card shows when it shouldn't

| Cause | Fix |
|-------|-----|
| VAST contains companion | Expected for Case 2 |
| Using preview-only QA API | `presentTestEndCardPreview` always shows end card |

---

## Presentation errors

### `presenterUnavailable` (-7)

- `showVideoAd` couldn't find key window / top VC.
- **Fix:** Use `showInterstitialVideoAd(from: self, …)` with visible view controller.
- SwiftUI: resolve hosting controller before present.

### Modal doesn't appear

- Check `presenter()` returns non-nil in test app.
- Ensure no other modal blocking presentation.

---

## Callback anomalies

### Duplicate `onAdLoading`

- Fullscreen flows: presenter + AdViewController may both fire in legacy paths.
- Interstitial module: presenter owns loading callback.

### `onAdLoaded` before content visible

- **By design** for `getBannerAdView` / `getImageAdView` / `getNativeAdView` (1s delay).

### No `onUserRewarded`

- Using interstitial API instead of `showRewardedVideoAd`.
- User skipped or closed before complete.

### Double `onAdClosed`

- Bug if guards fail — check `closedCallbackEmitted` in VC.
- Report with reproduction steps.

---

## Build issues

### `AppLovinSDK` not found (test app)

- Build via **`bidscubeSdk.xcworkspace`**, not `.xcodeproj` alone.
- Run `pod install`.

### IMA module not found

- Resolve SPM packages in Xcode.
- Clean build folder.

### iOS 14 vs 15 color API

- Test app uses iOS 14-safe colors (e.g. `.blue` not `.indigo`).

---

## CocoaPods / release

### `pod spec lint` fails

- Network to CDN for IMA pod
- Tag must exist on GitHub for git source validation
- Try `--allow-warnings`

### Trunk push duplicate

- Version already published — bump patch version

---

## VAST debugging

```swift
let meta = VastMetadataParser.parse(vastXML)
print(meta.previewImageUrl, meta.skipOffsetSeconds)
```

Unit tests: `Tests/bidscubeSdkTests/VastMetadataParserTests.swift`

Raw SSP response:
```swift
print(BidscubeSDK.buildRequestURL(placementId: id, adType: .video)!)
```

---

## Logging

Enable SDK logging:
```swift
BidscubeSDK.initialize(config: SDKConfig.Builder().enableLogging(true).build())
```

IMA legacy handler prints verbose logs when `enableDebugMode` — interstitial player uses `enableDebugMode = false`.

Filter Xcode console: `BidscubeSDK`, `IMAVideoAdHandler`, `[TestAdDelegate]`

---

## Who fixes what

| Issue type | Owner |
|------------|-------|
| SSP / VAST content | Ad ops / server |
| SDK parser / UI | iOS SDK team |
| Mediation / MAX | Adapter + MAX config |
| Publisher integration | Client app team |
