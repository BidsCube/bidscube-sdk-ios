# SKAdNetwork

Configure SKAdNetwork when building ``SDKConfig``:

```swift
let config = SDKConfig.Builder()
    .enableSKAdNetwork(true)
    .skAdNetworkId("your-network-id")
    .skAdNetworkConversionValue(1)
    .build()

BidscubeSDK.initialize(config: config)
```

SKAdNetwork registration and conversion updates require iOS 14+. On iOS 13, helper methods no-op when SKAdNetwork APIs are unavailable.

## Conversion tracking helpers

```swift
BidscubeSDK.trackAdImpression()
BidscubeSDK.trackAdClick()
BidscubeSDK.trackAppOpen()
BidscubeSDK.trackUserRegistration()
BidscubeSDK.trackFirstPurchase()
BidscubeSDK.trackSubscription()
BidscubeSDK.updateConversionValue(10)
```

Additional helpers: `trackHighValuePurchase()`, `trackRetention()`, `trackEngagement()`, and others on ``BidscubeSDK``.

## Status and identifiers

```swift
let status = BidscubeSDK.getSKAdNetworkStatus()
let available = BidscubeSDK.isSKAdNetworkAvailable()
let ids = BidscubeSDK.getSKAdNetworkIDs()
```

Add SKAdNetwork IDs to your app **Info.plist** under `SKAdNetworkItems`. The SDK reads registered IDs from the host app bundle.

## Response-driven SKAdNetwork

When ad responses include a `skadnetwork` JSON object, ``SKAdNetworkManager`` parses and processes server-provided attribution data during ad load.
