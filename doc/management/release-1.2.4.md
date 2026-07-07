# Release 1.2.4 — Summary

**Version:** 1.2.4  
**Tag:** `v1.2.4`  
**Type:** Patch/minor feature release (video interstitial + preview end card)

## Documentation

Full internal docs: [`doc/README.md`](../README.md)

| Audience | Key doc |
|----------|---------|
| Management | [product-overview.md](../management/product-overview.md) |
| Engineering | [video-interstitial.md](../developer/video-interstitial.md) |
| QA | [video-interstitial-qa.md](../qa/video-interstitial-qa.md) |

## Highlights

- New **video interstitial** stack (IMA, custom skip overlay, VAST-driven preview end card).
- Behaviour parity with Android: **no end card without VAST companion**; **skip only with companion**.
- New callback: **`onEndCardShown`**.
- Internal **test app** QA tab and hardcoded VAST fixtures for regression.

## User-facing changes

### Video interstitial (production placements)

- `showInterstitialVideoAd`, `presentAd(.video)`, `pushVideoAd`, inline `getInterstitialVideoAdView` route through the new presenter.
- Legacy `showVideoAd` / `getVideoAdView` remain **interstitial-compatible** entry points.

### Preview end card

- Shown after video **complete** or **skip** when VAST includes companion `StaticResource`.
- App-store-style UI: preview image, title, rating, downloads, price, Install Now.
- No scroll on end card screen.

### Without companion in VAST

- No skip control during video.
- Ad closes automatically after video completes.

## Technical notes (for engineering leads)

- Inline VAST loaded via IMA **data URI** (base64), matching the proven `IMAVideoAdHandler` approach.
- `VastMetadataParser` extracts companion image, click URLs, and skip offset from VAST XML.
- Rewarded video still uses `AdViewController` + `IMAVideoAdHandler` (separate code path).

## QA sign-off checklist

- [ ] Case 1 (no preview): video plays, no skip, closes at end — no end card
- [ ] Case 2 (with preview): skip countdown 5→1, Skip works, end card after skip
- [ ] Case 2: watch full video → end card appears
- [ ] End card: Install Now and preview open click URL once
- [ ] End card: ✕ closes ad, `onAdClosed` once
- [ ] Production placement smoke test with real `placementId`

Detailed steps: [../qa/video-interstitial-qa.md](../qa/video-interstitial-qa.md).

## Out of scope for 1.2.4

- Rewarded interstitial UI refresh (still legacy handler).
- Server-side VAST changes (client parses existing VAST fields only).
- AppLovin adapter version bump (optional follow-up if pinning `~> 1.2.4`).
