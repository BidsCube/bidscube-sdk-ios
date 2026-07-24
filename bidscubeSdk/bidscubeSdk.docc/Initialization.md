# Initialization

Call `BidscubeSDK.initialize(config:)` once before requesting ads.

## Custom configuration

```swift
import bidscubeSdk

let config = SDKConfig.Builder()
    .enableLogging(true)
    .enableDebugMode(false)
    .defaultAdTimeout(30_000)
    .defaultAdPosition(.unknown)
    .baseURL(Constants.baseURL)
    .userId("your-user-id")
    .build()

BidscubeSDK.initialize(config: config)
```

## Default initialization

```swift
BidscubeSDK.initialize()
```

The parameterless initializer enables logging, uses `Constants.baseURL`, and enables SKAdNetwork with placeholder defaults.

## Builder options

| Method | Description |
|--------|-------------|
| `enableLogging(_:)` | Console logging |
| `enableDebugMode(_:)` | Debug query parameters on ad requests |
| `defaultAdTimeout(_:)` | Request timeout in milliseconds |
| `defaultAdPosition(_:)` | Default `AdPosition` when none is set |
| `baseURL(_:)` | Legacy GET ad endpoint base URL |
| `enableSKAdNetwork(_:)` | Enable SKAdNetwork helpers |
| `skAdNetworkId(_:)` | Optional network identifier |
| `skAdNetworkConversionValue(_:)` | Initial conversion value (0–63) |
| `openRtbPodMetadataEnabled(_:)` | Enable OpenRTB pod metadata parsing |
| `videoPodDurationValidationMode(_:)` | `.lenient` or `.strict` |
| `videoPodSkipPolicy(_:)` | Pod skip behavior |
| `videoPodContinueOnSlotError(_:)` | Continue pod after slot failure |
| `videoPodShowCounter(_:)` | Show pod slot counter in UI |
| `userId(_:)` | Publisher user id sent as `user_id` query param on ad requests |

## OpenRTB defaults

When not overridden, the builder uses:

```swift
openRtbPodMetadataEnabled = true
videoPodDurationValidationMode = .lenient
videoPodSkipPolicy = .skipCurrentAndContinue
videoPodContinueOnSlotError = true
videoPodShowCounter = true
```

Set `openRtbPodMetadataEnabled(false)` to skip OpenRTB pod logic while keeping legacy root `adm` and raw VAST XML support.

## Ad position override

```swift
BidscubeSDK.setAdPosition(.header)
let effective = BidscubeSDK.getEffectiveAdPosition()
```

## Cleanup

```swift
BidscubeSDK.cleanup()
```

Removes tracked banners and clears SDK configuration.
