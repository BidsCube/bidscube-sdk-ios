# Banner Ads

Banner ads are image placements rendered in fixed screen positions using ``BannerAdView``.

## Get a banner view

```swift
let banner = BidscubeSDK.getBannerAdView("placement_id", position: .header, callback: callback)
view.addSubview(banner)
```

Supported ``AdPosition`` values include `.header`, `.footer`, `.sidebar`, and custom sizes.

## Convenience helpers

```swift
BidscubeSDK.showHeaderBanner("placement_id", in: viewController, callback: callback)
BidscubeSDK.showFooterBanner("placement_id", in: viewController, callback: callback)
BidscubeSDK.showSidebarBanner("placement_id", in: viewController, callback: callback)
BidscubeSDK.showCustomBanner("placement_id", position: .footer, width: 320, height: 50, in: viewController, callback: callback)
```

## Banner management

```swift
BidscubeSDK.removeAllBanners()
let count = BidscubeSDK.getActiveBannerCount()
```

Additional APIs:

- `showBannerWithCornerRadius(_:position:cornerRadius:in:callback:)`
- `showCustomBanner(_:position:width:height:cornerRadius:in:callback:)`
- `getBannerAdView(_:position:cornerRadius:callback:)`
- `untrackBanner(_:)`

Banners attached through the `show*` helpers are tracked automatically and removed with `removeAllBanners()`.
