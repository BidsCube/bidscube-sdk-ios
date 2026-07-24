# Product Overview — BidsCube iOS SDK

Document for product managers, project managers, and leadership.

---

## Executive summary

The **BidsCube iOS SDK** (`bidscubeSdk`) enables mobile apps to monetize through BidsCube's SSP. Publishers integrate a single library to display **banners**, **image ads**, **native ads**, and **video ads** (VAST via Google IMA).

**Current version:** 1.2.5  
**Distribution:** Swift Package Manager, CocoaPods; AppLovin MAX via separately distributed mediation adapter  
**Platform:** iOS 13.0+

Version **1.2.5** adds OpenRTB 2.6-style podded video response parsing. This is **response-side support only**; the SDK still uses the legacy GET request flow and does **not** build or POST OpenRTB bid requests.

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

## Release 1.2.5 — headline feature

### OpenRTB 2.6-style podded video response parsing

The SDK can parse video responses that describe ad pods using:

- root `adm`
- `bids[]`
- `seatbid[].bid[]`
- `openrtb.video`
- `openRtb.video`
- root `video`

Supported pod metadata includes:

- `podid`
- `podseq`
- `poddur`
- `rqddurs`
- `rqdDurs`
- `maxseq`
- `slotinpod`
- `duration`

This improves podded video delivery without changing publisher integration. It is **not** a full OpenRTB bidder/client.

---

## Release 1.2.4 — headline feature (historical)

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

AppLovin MAX mediation adapter is **distributed separately**. It is not part of this SDK source package unless the adapter module/podspec is included in the repository.

If integrating through AppLovin MAX, use the separately distributed Bidscube MAX mediation adapter. Do not add a duplicate direct `bidscubeSdk` dependency if the adapter already pulls the SDK transitively.

### Versioning policy

- **Patch** (1.2.x): bug fixes, small UX tweaks (1.2.5 = OpenRTB podded video parsing)
- **Minor** (1.x.0): new features (1.2.4 = video interstitial module)
- Tags: `v1.2.5` on GitHub triggers automated CocoaPods publish

---

## QA & acceptance

Internal test app validates:
- Case 1: no preview flow
- Case 2: preview + skip + end card

Sign-off checklist: [release-1.2.5.md](release-1.2.5.md), [release-1.2.4.md](release-1.2.4.md) (historical), and [../qa/full-regression-checklist.md](../qa/full-regression-checklist.md).

---

## Known limitations (1.2.5)

| Limitation | Impact |
|------------|--------|
| Consent is stub | Auto-grants; not production CMP |
| End card metadata defaults | Title/rating/etc. use SDK defaults until server-driven |
| `onInstallButtonClicked` reserved | End card CTA taps use `onAdClicked` today |
| OpenRTB bid request client | Not implemented; GET flow only |
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
