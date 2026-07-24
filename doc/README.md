# BidsCube iOS SDK — Documentation

**Repository:** `bidscube-sdk-ios`  
**Package:** `bidscubeSdk`  
**Current version:** 1.2.6  
**Minimum iOS:** 13.0  

Ця папка містить **внутрішню та інтеграційну** документацію для команди BidsCube (інженери, QA, продукт, реліз).

Публічна документація для інтеграторів:

| Location | Audience |
|----------|----------|
| [`README.md`](../README.md) | Publishers — quick start, installation |
| [`bidscubeSdk/bidscubeSdk.docc/`](../bidscubeSdk/bidscubeSdk.docc/) | DocC — structured API docs in Xcode |

---

## Start here

| Role | Read first | Then |
|------|------------|------|
| **New engineer** | [developer/team-onboarding.md](developer/team-onboarding.md) | [developer/codebase-map.md](developer/codebase-map.md), [developer/architecture.md](developer/architecture.md) |
| **Integrator / client support** | [developer/integration-guide.md](developer/integration-guide.md) | [developer/api-reference.md](developer/api-reference.md), [developer/callbacks-and-events.md](developer/callbacks-and-events.md) |
| **PM / management** | [management/product-overview.md](management/product-overview.md) | [management/release-1.2.6.md](management/release-1.2.6.md) |
| **QA** | [qa/test-app-guide.md](qa/test-app-guide.md) | [qa/video-interstitial-qa.md](qa/video-interstitial-qa.md), [qa/full-regression-checklist.md](qa/full-regression-checklist.md) |
| **Release owner** | [developer/build-release-ci.md](developer/build-release-ci.md) | [`RELEASE.md`](../RELEASE.md) |

---

## Documentation index

### Management

| Document | Description |
|----------|-------------|
| [product-overview.md](management/product-overview.md) | SDK capabilities, ad formats, distribution |
| [release-1.2.6.md](management/release-1.2.6.md) | Publisher `user_id` on ad requests |
| [release-1.2.5.md](management/release-1.2.5.md) | OpenRTB podded video, packaging, sign-off |
| [release-1.2.4.md](management/release-1.2.4.md) | Video interstitial module, end card UX |

### Developers

| Document | Description |
|----------|-------------|
| [team-onboarding.md](developer/team-onboarding.md) | Local setup, schemes, day-one workflow |
| [architecture.md](developer/architecture.md) | System design, dual video paths, data flow |
| [codebase-map.md](developer/codebase-map.md) | Major files and folders |
| [api-reference.md](developer/api-reference.md) | Complete `BidscubeSDK` public API |
| [callbacks-and-events.md](developer/callbacks-and-events.md) | Callback ordering and pitfalls |
| [ad-formats.md](developer/ad-formats.md) | Banner, image, native, video |
| [networking.md](developer/networking.md) | URLBuilder, GET flow, response parsing |
| [openrtb-podded-video.md](developer/openrtb-podded-video.md) | **1.2.5** — response-side OpenRTB pod parsing |
| [video-interstitial.md](developer/video-interstitial.md) | Video interstitial module (1.2.4+) |
| [skadnetwork-consent.md](developer/skadnetwork-consent.md) | SKAdNetwork, consent stub |
| [integration-guide.md](developer/integration-guide.md) | Host app integration |
| [build-release-ci.md](developer/build-release-ci.md) | Version bump, tags, CI, CocoaPods |
| [troubleshooting.md](developer/troubleshooting.md) | Common issues |

### QA

| Document | Description |
|----------|-------------|
| [test-app-guide.md](qa/test-app-guide.md) | `testApp-ios` structure |
| [video-interstitial-qa.md](qa/video-interstitial-qa.md) | Video interstitial TC-1…TC-6 |
| [full-regression-checklist.md](qa/full-regression-checklist.md) | Pre-release regression |

---

## Key facts (quick reference)

| Topic | Detail |
|-------|--------|
| SSP base URL | `https://ssp-bcc-ads.com/sdk` |
| Min iOS (SPM / CocoaPods) | 13.0 |
| Swift tools | 6.0 |
| IMA dependency | `GoogleInteractiveMediaAds` from 3.19.0 (SPM) / `GoogleAds-IMA-iOS-SDK ~> 3.19` (Pods) |
| Ad request flow | Legacy GET (`c=b|v|n`, `m=api|xml`) |
| OpenRTB | Response-side pod parsing only — **no POST bid client** |
| Video interstitial | `showInterstitialVideoAd` → `VideoInterstitialPresenter` |
| Rewarded video | `showRewardedVideoAd` → `AdViewController` / `VideoAdView` |
| Git release tag | `v1.2.6` |
| CI | `.github/workflows/publish.yml` on tag push |

---

## Public API (correct entry points)

Do **not** use non-existent APIs such as `showSkippableVideoAd(_:cta:callback:)`.

```swift
BidscubeSDK.initialize(config: config)
BidscubeSDK.showImageAd("placement_id", callback)
BidscubeSDK.showInterstitialVideoAd("placement_id", from: viewController, callback: callback)
BidscubeSDK.showRewardedVideoAd("placement_id", from: viewController, callback: callback)
BidscubeSDK.getBannerAdView("placement_id", position: .header, callback: callback)
```

Full list: [api-reference.md](developer/api-reference.md).

---

## Related repo files (outside `doc/`)

| Path | Purpose |
|------|---------|
| [`README.md`](../README.md) | Public integrator documentation |
| [`RELEASE.md`](../RELEASE.md) | Release checklist |
| [`bidscubeSdk.podspec`](../bidscubeSdk.podspec) | CocoaPods spec |
| [`Package.swift`](../Package.swift) | SPM manifest |
| [`bidscubeSdk/bidscubeSdk.docc/`](../bidscubeSdk/bidscubeSdk.docc/) | Xcode DocC catalog |
| [`testApp-ios/`](../testApp-ios/) | Internal QA app |
| [`Tests/bidscubeSdkTests/`](../Tests/bidscubeSdkTests/) | Unit tests |
