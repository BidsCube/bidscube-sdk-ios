# API Reference — `BidscubeSDK`

Complete reference for public static methods on `BidscubeSDK` (`bidscubeSdk/BidscubeSDK.swift`).

**SwiftUI extensions:** see `BidscubeSDK+SwiftUI.swift` at the end.

---

## Initialization & lifecycle

| Method | Description |
|--------|-------------|
| `initialize(config: SDKConfig)` | Required before ads. Configures logger, optional SKAdNetwork. |
| `initialize()` | Default config: logging on, SKAdNetwork on, default base URL. |
| `isInitialized() -> Bool` | Whether config exists. |
| `getConfiguration() -> SDKConfig?` | Current config snapshot. |
| `cleanup()` | Removes banners, clears config, consent flags, positions. |

### `SDKConfig.Builder` options

| Builder method | Default | Purpose |
|----------------|---------|---------|
| `enableLogging(_:)` | true | SDK log output |
| `enableDebugMode(_:)` | false | Debug query params |
| `defaultAdTimeout(_:)` | 30000 ms | Ad load timeout hint |
| `defaultAdPosition(_:)` | `.unknown` | Fallback layout position |
| `baseURL(_:)` | `Constants.baseURL` | SSP endpoint |
| `enableSKAdNetwork(_:)` | false in builder, true in `initialize()` | SKAdNetwork on init |
| `skAdNetworkId(_:)` | nil | Optional network ID |
| `skAdNetworkConversionValue(_:)` | 0 | Initial conversion value 0–63 |
| `userId(_:)` | nil | Publisher user id; sent as `user_id` on ad requests |
| `openRtbPodMetadataEnabled(_:)` | true | Enable OpenRTB pod metadata parsing on video responses |
| `videoPodDurationValidationMode(_:)` | `.lenient` | `.lenient` or `.strict` slot duration checks |
| `videoPodSkipPolicy(_:)` | `.skipCurrentAndContinue` | Pod behaviour on skip |
| `videoPodContinueOnSlotError(_:)` | true | Continue pod after slot failure |
| `videoPodShowCounter(_:)` | true | Show pod slot counter in UI |

See [openrtb-podded-video.md](openrtb-podded-video.md).

---

## Ad position

| Method | Description |
|--------|-------------|
| `setAdPosition(_: AdPosition)` | Manual override for layout |
| `getCurrentAdPosition()` | Manual position if set |
| `getResponseAdPosition()` | Last position from ad server JSON |
| `setResponseAdPosition(_:)` | Internal / response handler |
| `getEffectiveAdPosition()` | Manual ?? response |
| `shouldPresentFullScreen(_:callback:)` | Helper for fullscreen routing |

---

## Banner (image type `c=b`)

Uses `BannerAdView` (WKWebView). Banners are tracked in `activeBanners`.

| Method | Description |
|--------|-------------|
| `getBannerAdView(placementId:position:callback:)` | Returns banner view, starts load |
| `getBannerAdView(..., cornerRadius:)` | Same with rounded corners |
| `showHeaderBanner` / `showFooterBanner` / `showSidebarBanner` | Attach to view controller |
| `showCustomBanner(placementId:position:width:height:in:callback:)` | Custom size banner |
| `showCustomBanner(..., cornerRadius:)` | With corner radius |
| `showBannerWithCornerRadius(...)` | Convenience wrapper |
| `untrackBanner(_:)` | Stop tracking a banner instance |
| `removeAllBanners()` | Detach all active banners |
| `getActiveBannerCount()` | Count of tracked banners |

---

## Image ads

| Method | Description |
|--------|-------------|
| `showImageAd(placementId, callback)` | Network fetch → parse → display logic; SKAdNetwork |
| `getImageAdView(placementId, callback)` | Returns `BannerAdView` or `ImageAdView`; **fires loaded/displayed after 1s delay** |
| `presentImageAd(placementId, from:callback:)` | Fullscreen via `AdViewController` |
| `pushImageAd(placementId, onto:callback:)` | Push onto navigation stack |

**Override path:** if JSON contains both `adm` and `position`, calls `onAdRenderOverride` instead of default render.

---

## Native ads

| Method | Description |
|--------|-------------|
| `showNativeAd(placementId, callback)` | Network fetch + native render |
| `getNativeAdView(placementId, callback)` | Returns `NativeAdView`; 1s delayed loaded/displayed |
| `presentNativeAd` / `pushNativeAd` | Fullscreen / push via `AdViewController` |

Native ads fire **impression trackers** on display (once per load).

---

## Video — interstitial (new module, 1.2.4)

| Method | Description |
|--------|-------------|
| `showInterstitialVideoAd(placementId, from:callback:)` | **Primary API** — modal fullscreen interstitial |
| `showVideoAd(placementId, callback)` | Legacy; finds top VC → `showInterstitialVideoAd` |
| `getInterstitialVideoAdView(placementId, callback)` | Inline embedded interstitial |
| `getVideoAdView(placementId, callback)` | Alias for `getInterstitialVideoAdView` |
| `presentVideoAd(placementId, from:callback:)` | Same as show interstitial |
| `pushVideoAd(placementId, onto:callback:)` | Push interstitial onto nav stack |
| `presentAd(placementId, adType: .video, from:callback:)` | Generic presenter; video → interstitial module |

---

## Video — rewarded (legacy IMA path)

| Method | Description |
|--------|-------------|
| `showRewardedVideoAd(placementId, from:callback:)` | Modal `AdViewController`, `VideoAdFormat.rewarded` |
| `getRewardedVideoAdView(placementId, callback)` | Inline rewarded |
| `pushRewardedVideoAd(placementId, onto:callback:)` | Push rewarded host |

**`onUserRewarded`** fires only on IMA `.COMPLETE`, never on skip/close.

---

## Generic ad host

| Method | Description |
|--------|-------------|
| `getAdViewController(placementId, adType, callback, videoAdFormat:)` | Factory for `AdViewController` |
| `presentAd(placementId, adType, from:callback:)` | Present by type |
| `buildRequestURL(placementId:adType:ctaText:)` | Expose URL builder for debugging |

---

## Consent (stub implementation)

Current implementation is a **placeholder** — auto-grants on form show.

| Method | Description |
|--------|-------------|
| `requestConsentInfoUpdate(callback:)` | Delayed `onConsentInfoUpdated` |
| `showConsentForm(callback:)` | Shows form callback chain; grants ads + analytics |
| `enableConsentDebugMode(testDeviceId:)` | Stores debug device ID |
| `resetConsent()` | Clears consent flags |
| `isConsentRequired()` | Returns internal flag (default false) |
| `hasAdsConsent()` / `hasAnalyticsConsent()` | Flag getters |
| `getConsentStatusSummary()` | Debug string |

---

## SKAdNetwork & conversion tracking

| Method | Description |
|--------|-------------|
| `registerSKAdNetwork()` | Register for attribution |
| `trackAdView()` / `trackAdClick()` / `trackAdInteraction()` | Increment conversion helpers |
| `updateSKAdNetworkConversionValue(_:completion:)` | Async update 0–63 |
| `updateConversionValue(_:)` | Sync helper |
| `isSKAdNetworkAvailable()` | iOS 14+ check |
| `getSKAdNetworkIDs()` | From host app Info.plist |
| `displaySKAdNetworkIDsInConsole()` | Debug print |
| `getSKAdNetworkIDsAsString()` | Formatted list |
| `debugInfoPlistStructure()` | Plist debug dump |
| `getSKAdNetworkStatus()` | Status string |

### `ConversionTracker` helpers (via BidscubeSDK wrappers)

`trackAdImpression`, `trackAdClick`, `trackAppOpen`, `trackUserRegistration`, `trackFirstPurchase`, `trackSubscription`, `trackHighValuePurchase`, `trackRetention`, `trackEngagement`, `trackPremiumFeature`, `trackSocialShare`, `trackReferral`, `trackLoyaltyProgram`, `trackPremiumSubscription`

---

## Test / QA APIs (not for production apps)

| Method | Description |
|--------|-------------|
| `presentTestVideoInterstitial(from:vastXML:metadata:placementId:callback:)` | Inline VAST interstitial |
| `presentTestVideoInterstitialFromAdTag(from:adTagUrl:metadata:placementId:callback:)` | Live IMA ad tag |
| `presentTestEndCardPreview(from:vastXML:metadata:placementId:callback:)` | End card only |

### `BidscubeSDKVideoInterstitialQA`

| Constant | Description |
|----------|-------------|
| `vastWithoutPreview` | No companion — no skip, close after video |
| `vastWithPreview` | Companion + skip 5s — end card after skip/complete |

---

## SwiftUI (`BidscubeSDK+SwiftUI.swift`)

| Type | Description |
|------|-------------|
| `IMAVideoAdView` | UIViewControllerRepresentable → legacy IMA path |
| `AdViewControllerView` | Wraps `AdViewController` |

Note: SwiftUI IMA wrapper uses **legacy** handler, not the new interstitial module.

---

## Internal (package-visible, not for integrators)

| Symbol | File |
|--------|------|
| `makeVideoAdViewForFullscreenHosting` | Used by `AdViewController` for rewarded |
| `setResponseAdPosition` | Set from network parsers |
| `VideoInterstitialDefaults` | Internal end card defaults |
