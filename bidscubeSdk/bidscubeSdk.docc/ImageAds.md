# Image Ads

Image ads use the legacy GET ad request flow and render through `ImageAdView` or `BannerAdView` when the effective position is header, footer, or sidebar.

## Show an image ad

Implement ``AdCallback`` and call ``BidscubeSDK/showImageAd(_:_:)``:

```swift
final class MyAdCallback: AdCallback {
    func onAdLoading(_ placementId: String) {}
    func onAdLoaded(_ placementId: String) {}
    func onAdDisplayed(_ placementId: String) {}
    func onAdClicked(_ placementId: String) {}
    func onAdClosed(_ placementId: String) {}
    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String) {}
}

let callback = MyAdCallback()
BidscubeSDK.showImageAd("placement_id", callback)
```

## Embedded image ad view

```swift
let adView = BidscubeSDK.getImageAdView("placement_id", callback)
containerView.addSubview(adView)
```

## Custom rendering

If the response contains both `adm` and `position`, the SDK calls `onAdRenderOverride(adm:position:)` instead of built-in rendering. See <doc:Callbacks>.

## Test placement

| Placement ID | Type |
|--------------|------|
| `20212` | Image / banner test placement |
