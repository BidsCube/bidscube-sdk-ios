# Native Ads

Native ads load OpenRTB-style native JSON from the legacy GET ad request flow and render in ``NativeAdView``.

## Show a native ad

```swift
BidscubeSDK.showNativeAd("placement_id", callback)
```

## Embedded native ad view

```swift
let nativeView = BidscubeSDK.getNativeAdView("placement_id", callback)
containerView.addSubview(nativeView)
```

## Customization

``NativeAdView`` supports optional styling after creation:

```swift
nativeView.setCTAText("Shop Now")
nativeView.setCustomStyle(.white, .black, .systemBlue)
nativeView.setCTAButton("Install", .systemBlue, .white)
nativeView.setLayoutMode(.compact)
nativeView.setLayoutModeForPosition(.header)
nativeView.setLayoutModeForSize(CGSize(width: 320, height: 250))
```

Layout modes are defined by ``NativeAdLayoutMode``: `.full`, `.compact`, `.minimal`, and `.banner`.

## Test placement

| Placement ID | Type |
|--------------|------|
| `20214` | Native test placement |
