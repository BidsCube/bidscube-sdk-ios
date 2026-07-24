# Ad Formats — Internal Reference

How each ad format works inside the SDK.

---

## Format overview

| Format | AdType | Query `c=` | Response | Primary view | Entry API |
|--------|--------|------------|----------|--------------|-----------|
| Banner | `.image` | `b` | JS/HTML | `BannerAdView` | `getBannerAdView`, `showHeaderBanner`, … |
| Image | `.image` | `b` | JSON/HTML | `ImageAdView` / `BannerAdView` | `showImageAd`, `getImageAdView` |
| Native | `.native` | `n` | JSON | `NativeAdView` | `showNativeAd`, `getNativeAdView` |
| Video interstitial | `.video` | `v` | VAST / OpenRTB JSON | `VideoInterstitialViewController` | `showInterstitialVideoAd` |
| Video rewarded | `.video` | `v` | VAST / OpenRTB JSON | `VideoAdView` + IMA | `showRewardedVideoAd` |

---

## Banner ads

**Implementation:** `BannerAdView.swift`

- WKWebView renders HTML/JS from SSP.
- Positions: header (top), footer (bottom), sidebar (trailing).
- SDK tracks instances in `BidscubeSDK.activeBanners` for lifecycle.
- Supports corner radius variants.
- Clicks → `onAdClicked`.

**Load flow:**
1. `buildRequestURL(placementId, .image)` with banner position params.
2. `loadAdFromURL` → GET → inject HTML.

---

## Image ads

**Implementation:** `ImageAdView.swift`, sometimes `BannerAdView` by position.

**Fullscreen / push:** `AdViewController` hosts the view.

**`showImageAd` flow:**
1. GET with SKAdNetwork params if enabled.
2. Parse JSON: `adm`, optional `position`.
3. If `onAdRenderOverride` conditions met → delegate to app.
4. Else render + SKAdNetwork response processing.

**`getImageAdView` quirk:** Returns view immediately; fires `onAdLoaded` + `onAdDisplayed` after **1 second** on main queue.

---

## Native ads

**Implementation:** `NativeAdView.swift`

- Parses native JSON (title, image, CTA, etc.).
- Layout modes: full, compact, minimal, banner-style.
- **Impression trackers:** HTTP ping on first display (guarded once per load).
- Override path same as image (`onAdRenderOverride`).

---

## OpenRTB podded video (1.2.5)

**Implementation:** `OpenRTB/*`, shared `VideoAdPayloadResolver`

- Response-side only — legacy GET unchanged.
- Composes multi-slot inline VAST for Google IMA `adsResponse`.
- See [openrtb-podded-video.md](openrtb-podded-video.md).

---

## Video interstitial (1.2.4+)

**Implementation:** `Views/VideoInterstitial/*`

See [video-interstitial.md](video-interstitial.md).

**UX rules:**
- Companion in VAST → skip + end card.
- No companion → no skip, close after video.

**Presentation:** Modal fullscreen or inline child VC.

---

## Video rewarded (legacy)

**Implementation:** `VideoAdView` → `IMAVideoAdHandler` inside `AdViewController`

- Full IMA UI disabled in handler but close button / gestures exist via host.
- **`onUserRewarded`** only after full watch (`IMA .COMPLETE`).
- Skip → `onVideoAdSkipped`, no reward.
- Used for MAX/mediation compatibility paths that expect legacy behaviour.

**Do not** route new interstitial product requirements through this path unless explicitly for rewarded.

---

## AdViewController (shared fullscreen host)

**File:** `AdViewController.swift`

Used for:
- Image fullscreen
- Native fullscreen  
- **Rewarded video** (not new interstitial)

Features:
- Layout adapts to `AdPosition` (polls every 0.5s).
- Swipe-right / double-tap dismiss (disabled during video playback).
- Load timeout: 10s video, 5s other formats.
- Back button on video complete (legacy path).

---

## Ad position system

| Source | Priority |
|--------|----------|
| `setAdPosition` (manual) | Overrides response |
| Server JSON `position` field | Sets `responseAdPosition` |
| Default | `.unknown` |

Positions affect `AdViewController` layout and `shouldPresentFullScreen` helper.

---

## Custom ad rendering

When server returns JSON with both:
- `adm` (markup string)
- `position` (AdPosition int)

SDK calls `onAdRenderOverride(adm:position:)` and skips default WebView/native render.

Demo: `CustomAdRenderView.swift`

---

## Mediation (AppLovin MAX)

Test app includes `MAXTestView` — separate from SDK core.

If integrating through AppLovin MAX, use the separately distributed Bidscube MAX mediation adapter. Do not add a duplicate direct `bidscubeSdk` dependency if the adapter already pulls the SDK transitively.

Adapter version ≠ SDK version. The adapter is distributed separately from this repository. See public README.

---

## Choosing the right API (support cheat sheet)

| Client need | Recommend |
|-------------|-----------|
| Fullscreen video ad with preview end card | `showInterstitialVideoAd` |
| Reward users after watching | `showRewardedVideoAd` |
| Banner at bottom | `showFooterBanner` |
| Native in feed | `getNativeAdView` |
| Legacy code using `showVideoAd` | Still works → interstitial module |
