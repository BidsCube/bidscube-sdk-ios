# Video Ads

Video ads use **Google IMA** for playback. The SDK passes either an **ad tag URL** or inline **VAST XML** as `adsResponse` to IMA after resolving the server payload.

## Fullscreen interstitial

```swift
BidscubeSDK.showInterstitialVideoAd("placement_id", from: viewController, callback: callback)
```

Presented by ``VideoInterstitialPresenter`` using ``VideoInterstitialViewController`` and ``IMAVideoInterstitialPlayer``.

## Fullscreen rewarded

```swift
BidscubeSDK.showRewardedVideoAd("placement_id", from: viewController, callback: callback)
```

`onUserRewarded` fires only after natural IMA completion (`.COMPLETE`). Skip, close, error, or failed playback must not reward the user.

## Legacy fullscreen entry point

```swift
BidscubeSDK.showVideoAd("placement_id", callback)
```

Uses the key window’s top view controller. Equivalent to interstitial presentation.

## Inline / embedded views

```swift
let interstitialView = BidscubeSDK.getInterstitialVideoAdView("placement_id", callback)

let rewardedView = BidscubeSDK.getRewardedVideoAdView("placement_id", callback)

let videoView = BidscubeSDK.getVideoAdView("placement_id", callback)
```

- ``VideoInterstitialInlineContainerView`` handles inline interstitial playback.
- ``VideoAdView`` handles inline rewarded playback.
- ``getVideoAdView`` is an alias for ``getInterstitialVideoAdView`` (interstitial-compatible legacy API).

## Video callbacks

Implement optional ``AdCallback`` methods for video lifecycle events. See <doc:Callbacks>.

## OpenRTB podded responses

Multi-slot podded JSON/VAST responses are resolved before IMA playback. See <doc:OpenRTB-2.6-Podded-Video>.

## Test placement

| Placement ID | Type |
|--------------|------|
| `20213` | Video test placement |

## Additional presentation APIs

- `presentVideoAd(_:from:callback:)`
- `pushVideoAd(_:onto:callback:)`
- `pushRewardedVideoAd(_:onto:callback:)`
- `presentAd(_:_:from:_:)` with `.video`

Test-only helpers (`presentTestVideoInterstitial`, `presentTestEndCardPreview`) are for the SDK test app and are not production APIs.
