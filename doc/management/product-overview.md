# Product Overview — BidsCube iOS SDK

Document for product managers, project managers, and leadership.

---

## Executive summary

The **BidsCube iOS SDK** (`bidscubeSdk`) enables mobile apps to monetize through BidsCube's SSP. Publishers integrate a single library to display **banners**, **image ads**, **native ads**, and **video ads** (VAST via Google IMA).

**Current version:** 1.2.4  
**Distribution:** Swift Package Manager, CocoaPods, AppLovin MAX mediation adapter  
**Platform:** iOS 13.0+

---

## What publishers get

| Capability | User-visible outcome |
|------------|---------------------|
| Banner / image | HTML/display ads in app layout |
| Native | In-feed sponsored content |
| Video interstitial | Fullscreen video ad between app screens |
| Video rewarded | User watches video for in-app reward |
| SKAdNetwork | Install attribution support |
| Consent hooks | Placeholder for privacy compliance (stub today) |

---

## Release 1.2.4 — headline feature

### Video interstitial with preview end card

Matches Android product spec:

1. User sees fullscreen video.
2. Depending on ad creative (VAST):
   - **With preview image in ad** → skip timer, optional skip, then app-store-style end screen.
   - **Without preview** → user must watch; ad closes when video ends.

This drives higher engagement on playable/app-install campaigns with companion creatives.

---

## Business rules (video interstitial)

### When VAST includes companion preview image

| Phase | Behaviour |
|-------|-----------|
| Video | Skip countdown (default 5s from VAST or SDK default) |
| User skips | End card with preview, Install CTA, close button |
| User watches full video | Same end card |
| Analytics | `onEndCardShown` fires when end card visible |

### When VAST has no companion preview

| Phase | Behaviour |
|-------|-----------|
| Video | No skip button |
| End | Ad closes automatically |
| Analytics | No `onEndCardShown` |

### Why this matters

- **Advertisers with rich creatives** get end card + CTA after video.
- **Simple video-only campaigns** don't force an extra screen.
- Avoids showing generic placeholder end cards that weren't in the ad contract.

---

## End card screen (with preview)

App-store-inspired layout:

- Large preview image (from ad)
- App title, star rating, download count, price
- **Install Now** button
- Close (✕) in corner
- Single screen, no scrolling

Taps on preview or Install open advertiser landing page (click-through URL from VAST).

---

## Rewarded vs interstitial video

| | Interstitial (new) | Rewarded (existing) |
|--|-------------------|---------------------|
| Use case | Between levels, natural breaks | Give user coins/lives |
| End card | Yes, if VAST has companion | No |
| Reward callback | No | Yes, after full watch |
| API | `showInterstitialVideoAd` | `showRewardedVideoAd` |

Product should not promise rewarded grants on interstitial API.

---

## Distribution & partners

### Direct SDK integration

Publishers add SPM or CocoaPods dependency on `bidscubeSdk`.

### AppLovin MAX mediation

Publishers use **`AppLovinMediationBidscubeAdapter`** — separate pod version from SDK. BidsCube SDK is pulled automatically.

### Versioning policy

- **Patch** (1.2.x): bug fixes, small UX tweaks
- **Minor** (1.x.0): new features (1.2.4 = video interstitial module)
- Tags: `v1.2.4` on GitHub triggers automated CocoaPods publish

---

## QA & acceptance

Internal test app validates:
- Case 1: no preview flow
- Case 2: preview + skip + end card

Sign-off checklist: [release-1.2.4.md](release-1.2.4.md) and [../qa/full-regression-checklist.md](../qa/full-regression-checklist.md).

---

## Known limitations (1.2.4)

| Limitation | Impact |
|------------|--------|
| Consent is stub | Auto-grants; not production CMP |
| End card metadata defaults | Title/rating/etc. use SDK defaults until server-driven |
| `onInstallButtonClicked` unused | Use `onAdClicked` for CTA |
| iOS 13 vs 14 project target | Published min 13; internal Xcode 14 |

---

## Roadmap considerations (not committed)

- Server-driven end card metadata (title, rating from API)
- Real UMP/consent integration
- Unified video module for rewarded + interstitial
- Android/iOS metadata parity from single spec

---

## Glossary

| Term | Meaning |
|------|---------|
| **VAST** | Video ad serving template (XML) |
| **IMA** | Google Interactive Media Ads SDK (video playback) |
| **Companion** | Static image in VAST shown on end card |
| **Placement ID** | BidsCube identifier for ad slot |
| **SSP** | Supply-side platform (`ssp-bcc-ads.com`) |
| **End card** | Post-video preview screen |
| **SKAdNetwork** | Apple install attribution framework |

---

## Contacts & docs

| Need | Resource |
|------|----------|
| Technical detail | [../developer/architecture.md](../developer/architecture.md) |
| API list | [../developer/api-reference.md](../developer/api-reference.md) |
| Release process | [../../RELEASE.md](../../RELEASE.md) |
| Public docs | [../../README.md](../../README.md) |
