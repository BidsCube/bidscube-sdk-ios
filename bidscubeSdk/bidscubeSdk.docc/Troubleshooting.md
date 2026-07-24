# Troubleshooting

Common integration issues and how to resolve them.

## SDK not initialized

Call `BidscubeSDK.initialize(config:)` once before requesting ads.

Check `BidscubeSDK.isInitialized()` during debugging.

## Video does not play

Check:

- iOS 13+
- GoogleInteractiveMediaAds dependency is resolved
- placement id is valid
- response contains raw VAST, root `adm`, or supported OpenRTB-like podded JSON
- VAST contains playable media or valid ad tag URL

Enable logging with `SDKConfig.Builder().enableLogging(true)` to inspect payload resolution.

## OpenRTB JSON returned but no video

Check:

- `openRtbPodMetadataEnabled(true)`
- response contains usable `adm`
- supported shapes: root `adm`, `bids[]`, `seatbid[].bid[]`
- supported video metadata: `openrtb.video`, `openRtb.video`, root `video`
- each selected bid has inline VAST XML or ad tag URL

Remember: response-side OpenRTB support does not change the legacy GET ad request flow.

## Pod order looks wrong

Ordering priority:

1. `slotinpod`
2. VAST `<Ad sequence>`
3. response order

## Rewarded video did not reward

Reward fires only after natural video completion.
Skip, close, failed playback, or invalid markup does not reward.

## Mixed URL/XML pod

Current limitation:
Mixed URL/XML pod composition is not fully supported.
The SDK uses the first URL slot and logs a warning.

## SPM build includes demo files

`Package.swift` excludes:

- `Tests`
- `Controller/ViewController.swift`
- `Controller/WindowedAdTestViewController.swift`
- `Views/ContentView.swift`
- `Views/SDKTestView.swift`

If demo sources appear in a consumer build, verify you depend on the **`bidscubeSdk`** product, not a local path that includes test controllers.

## Build from command line

This is an iOS-only package. `swift build` on macOS fails because UIKit is unavailable. Build with Xcode or `xcodebuild` targeting iOS.

## Fullscreen video presentation failed

Error code `presenterUnavailable` (-7) means no key window or host view controller was found for `showVideoAd(_:_:)`. Prefer `showInterstitialVideoAd(_:from:callback:)` with an explicit view controller.
