# BidsCube iOS SDK — Internal Documentation

**Repository:** `bidscube-sdk-ios`  
**Current version:** 1.2.5  
**Audience:** BidsCube iOS team — engineering, QA, product, release management

This folder is **internal only**. Public integrator documentation lives in [`README.md`](../README.md) at the repo root.

---

## Start here

| Role | Read first | Then |
|------|------------|------|
| **New engineer** | [developer/team-onboarding.md](developer/team-onboarding.md) | [developer/codebase-map.md](developer/codebase-map.md), [developer/architecture.md](developer/architecture.md) |
| **Integrator / client support** | [developer/integration-guide.md](developer/integration-guide.md) | [developer/api-reference.md](developer/api-reference.md), [developer/callbacks-and-events.md](developer/callbacks-and-events.md) |
| **PM / management** | [management/product-overview.md](management/product-overview.md) | [management/release-1.2.4.md](management/release-1.2.4.md) |
| **QA** | [qa/test-app-guide.md](qa/test-app-guide.md) | [qa/video-interstitial-qa.md](qa/video-interstitial-qa.md), [qa/full-regression-checklist.md](qa/full-regression-checklist.md) |
| **Release owner** | [developer/build-release-ci.md](developer/build-release-ci.md) | [`RELEASE.md`](../RELEASE.md) |

---

## Documentation index

### Management

| Document | Description |
|----------|-------------|
| [product-overview.md](management/product-overview.md) | SDK capabilities, ad formats, video interstitial UX rules, distribution |
| [release-1.2.4.md](management/release-1.2.4.md) | What shipped in 1.2.4, sign-off checklist |

### Developers

| Document | Description |
|----------|-------------|
| [team-onboarding.md](developer/team-onboarding.md) | Local setup, schemes, day-one workflow |
| [architecture.md](developer/architecture.md) | System design, dual video paths, data flow diagrams |
| [codebase-map.md](developer/codebase-map.md) | Every major file and folder explained |
| [api-reference.md](developer/api-reference.md) | Complete `BidscubeSDK` public API by category |
| [callbacks-and-events.md](developer/callbacks-and-events.md) | All callbacks, when they fire, ordering, pitfalls |
| [ad-formats.md](developer/ad-formats.md) | Banner, image, native, video interstitial, rewarded |
| [networking.md](developer/networking.md) | URLBuilder, request params, response parsing |
| [video-interstitial.md](developer/video-interstitial.md) | Video interstitial module deep dive (1.2.4) |
| [skadnetwork-consent.md](developer/skadnetwork-consent.md) | SKAdNetwork, conversion values, consent stub |
| [integration-guide.md](developer/integration-guide.md) | How host apps integrate |
| [build-release-ci.md](developer/build-release-ci.md) | Build, version bump, tags, GitHub Actions, CocoaPods |
| [troubleshooting.md](developer/troubleshooting.md) | Common issues and fixes |

### QA

| Document | Description |
|----------|-------------|
| [test-app-guide.md](qa/test-app-guide.md) | `testApp-ios` structure and how to run |
| [video-interstitial-qa.md](qa/video-interstitial-qa.md) | Video interstitial test cases TC-1…TC-6 |
| [full-regression-checklist.md](qa/full-regression-checklist.md) | Pre-release regression across all formats |

---

## Key facts (quick reference)

| Topic | Detail |
|-------|--------|
| SSP base URL | `https://ssp-bcc-ads.com/sdk` |
| Min iOS (published) | 13.0 (SPM / CocoaPods) |
| Xcode project targets | iOS 14.0 (`bidscubeSdk`, `testApp-ios`) |
| IMA dependency | Google IMA ~> 3.19 (SPM resolves 3.27.x) |
| Video interstitial API | `showInterstitialVideoAd` → `VideoInterstitialPresenter` |
| Rewarded video API | `showRewardedVideoAd` → `AdViewController` → `IMAVideoAdHandler` |
| Git release tag | `v1.2.5` |
| CI | `.github/workflows/publish.yml` on tag push |

---

## Related repo files (outside `doc/`)

| Path | Purpose |
|------|---------|
| [`README.md`](../README.md) | Public documentation |
| [`RELEASE.md`](../RELEASE.md) | Release checklist (commit, tag, push) |
| [`bidscubeSdk.podspec`](../bidscubeSdk.podspec) | CocoaPods spec |
| [`Package.swift`](../Package.swift) | SPM manifest |
| [`testApp-ios/`](../testApp-ios/) | Internal QA application |
| [`Tests/bidscubeSdkTests/`](../Tests/bidscubeSdkTests/) | Unit tests |
