# Codebase Map

Complete map of the `bidscubeSdk` module and supporting repo files.

## Root entry points

| File | Description |
|------|-------------|
| `bidscubeSdk/BidscubeSDK.swift` | **Main public façade** — all static SDK methods |
| `bidscubeSdk/BidscubeSDK+SwiftUI.swift` | SwiftUI wrappers (`IMAVideoAdView`, `AdViewControllerView`) |
| `bidscubeSdk/bidscubeSdk.h` | Obj-C header (minimal) |

---

## Core (`bidscubeSdk/Core/`)

| File | Public | Description |
|------|--------|-------------|
| `Constants.swift` | Yes | Base URL, error codes, query param keys, `sdkVersion` |
| `SDKConfig.swift` | Yes | Builder for SDK initialization options |
| `Callbacks.swift` | Yes | `AdCallback`, `ConsentCallback` protocols |
| `AdType.swift` | Yes | `.image`, `.video`, `.native` |
| `AdPosition.swift` | Yes | `.header`, `.footer`, `.sidebar`, `.fullScreen`, `.unknown` |
| `VideoAdFormat.swift` | Internal | `.interstitial` vs `.rewarded` for legacy video path |
| `VideoInterstitialMetadata.swift` | Yes | End card model (title, rating, preview URL, skip offset) |
| `SKAdNetworkManager.swift` | Partial | SKAdNetwork registration, conversion values, plist parsing |
| `SKAdNetworkModels.swift` | Yes | Response models v2.15 / v2.16 |
| `ConversionTracker.swift` | Yes | Predefined conversion value helpers |
| `Logger.swift` | Internal | Logging wrapper |

---

## Networking (`bidscubeSdk/Networking/`)

| File | Description |
|------|-------------|
| `URLBuilder.swift` | Builds GET URLs with device, privacy, SKAdNetwork params |
| `NetworkManager.swift` | Singleton HTTP client (GET/POST, error mapping) |
| `DeviceInfo.swift` | Bundle ID, screen size, UA, IDFA, privacy strings |

---

## Views — general ads (`bidscubeSdk/Views/`)

| File | Description |
|------|-------------|
| `BannerAdView.swift` | WKWebView banner; attach to header/footer/sidebar; tracked in `activeBanners` |
| `ImageAdView.swift` | WKWebView image ad from JSON `adm` |
| `NativeAdView.swift` | Native layout from JSON; fires impression trackers |
| `VideoAdView.swift` | **Legacy** inline video host; loads VAST URL; embeds `IMAVideoAdHandler` |
| `IMAVideoAdHandler.swift` | **Legacy** IMA player (rewarded + old interstitial inline) |
| `IMAViewController.swift` | UIKit host for SwiftUI IMA representable |
| `AdViewController.swift` | Fullscreen/pushed host for image, native, **rewarded video** |
| `CustomAdRenderView.swift` | Demo view for `onAdRenderOverride` |
| `ContentView.swift` | Internal SwiftUI demo launcher (excluded from some builds) |
| `SDKTestView.swift` | Internal comprehensive test UI (excluded from framework in pbxproj) |

---

## Views — Video Interstitial module (`bidscubeSdk/Views/VideoInterstitial/`)

| File | Description |
|------|-------------|
| `VideoInterstitialPresenter.swift` | Load placement, present/push, test helpers |
| `VideoInterstitialViewController.swift` | State machine, overlays, end card orchestration |
| `IMAVideoInterstitialPlayer.swift` | IMA with `disableUi`; base64 VAST data URI |
| `VideoInterstitialOverlayView.swift` | Skip countdown (wide) / close ✕ (compact 36×36) |
| `VideoInterstitialEndCardView.swift` | App-store-style end card (no scroll) |
| `VideoInterstitialEndCardPreviewViewController.swift` | QA: end card only, no video |
| `VideoInterstitialInlineContainerView.swift` | Embeds interstitial as child VC |
| `VastMetadataParser.swift` | Regex VAST parser (companion, clicks, skip) |
| `VideoInterstitialTestVAST.swift` | Hardcoded QA VAST strings (internal) |

---

## Logger (`bidscubeSdk/Logger/`)

| File | Description |
|------|-------------|
| `SDKLogger.swift` | os.Logger wrapper with iOS 14+ gating |

---

## Internal demo / test (inside SDK folder, not shipped to all targets)

| Path | Description |
|------|-------------|
| `bidscubeSdk/Controller/` | UIKit test controllers |
| `bidscubeSdk/Tests/` | ConsentTestView, SKAdNetworkTestView, etc. |

---

## Test app (`testApp-ios/`)

| File | Description |
|------|-------------|
| `testApp_iosApp.swift` | App entry; optional AppLovin init |
| `TestAppRootView.swift` | TabView: Video Interstitial + MAX |
| `VideoInterstitialTestView.swift` | QA buttons for VAST fixtures |
| `TestAdDelegate.swift` | Logs all callbacks to console |
| `MAXTestView.swift` | AppLovin MAX mediation tests |
| `UIViewRepresentableWrapper.swift` | SwiftUI helpers |

---

## Unit tests (`Tests/bidscubeSdkTests/`)

| File | Description |
|------|-------------|
| `VastMetadataParserTests.swift` | VAST parser + QA fixture tests |

---

## Build & distribution files

| File | Description |
|------|-------------|
| `Package.swift` | SPM: iOS 13+, IMA from Google SPM |
| `bidscubeSdk.podspec` | CocoaPods spec v1.2.4 |
| `Podfile` | Test app dependencies |
| `bidscubeSdk.xcodeproj/project.pbxproj` | Targets, exclusions, IMA SPM link |
| `.github/workflows/publish.yml` | Tag-triggered CocoaPods + GitHub Release |

---

## Documentation (`doc/`)

This tree — internal team documentation.

---

## Files often confused

| Wrong assumption | Reality |
|------------------|---------|
| `showVideoAd` uses new interstitial UI | It calls `showInterstitialVideoAd` (new module) |
| `presentVideoAd` uses `AdViewController` | Routes to `VideoInterstitialPresenter` |
| `getVideoAdView` is rewarded | Alias for **interstitial** inline view |
| `IMAVideoAdHandler` powers interstitial fullscreen | **No** — `IMAVideoInterstitialPlayer` does |
| Companion missing → default end card after video | **No** — ad closes; default image only in preview-only QA API |
