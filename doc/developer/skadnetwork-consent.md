# SKAdNetwork & Consent

Internal reference for attribution and privacy stubs.

---

## SKAdNetwork

### Initialization

SKAdNetwork is initialized when:
```swift
BidscubeSDK.initialize(config: SDKConfig.Builder()
    .enableSKAdNetwork(true)
    ...
    .build())
```

Default `initialize()` enables SKAdNetwork with conversion value `1`.

### Manager

**File:** `bidscubeSdk/Core/SKAdNetworkManager.swift`

| Capability | Description |
|------------|-------------|
| `register()` | Calls `SKAdNetwork.registerAppForAdNetworkAttribution()` (iOS 14+) |
| `updateConversionValue(_:)` | Updates 0–63, monotonic increase only |
| `getSKAdNetworkIDs()` | Reads `SKAdNetworkItems` from host Info.plist |
| Response parsing | v2.15 and v2.16 JSON formats |

### Conversion tracking

**File:** `bidscubeSdk/Core/ConversionTracker.swift`

Predefined values (examples):
- Ad impression: +1
- Ad click: +2
- First purchase: +10
- Subscription: +15

Exposed via `BidscubeSDK.trackAdImpression()`, `trackFirstPurchase()`, etc.

### In ad requests

When enabled, `URLBuilder` repeats `skadnet` query params for each ID from publisher app's Info.plist.

Image/native responses may contain SKAdNetwork signature JSON — parsed and logged by manager.

### Publisher requirements

Host app must include **`SKAdNetworkItems`** in Info.plist with all required network IDs. SDK reads publisher plist, not its own.

Debug: `BidscubeSDK.debugInfoPlistStructure()`

---

## Consent (current stub)

**Location:** `BidscubeSDK.swift` consent section

### Current behaviour

| API | Behaviour |
|-----|-----------|
| `requestConsentInfoUpdate` | 0.1s delay → `onConsentInfoUpdated` |
| `showConsentForm` | Auto-grants ads + analytics consent |
| `resetConsent` | Clears internal flags |
| `isConsentRequired` | Returns stored flag (default false) |

### Not implemented

- Real TCF / UMP integration
- `onConsentDenied`, `onConsentInfoUpdateFailed`, geographic rules
- Persistent consent storage

### Internal flags

```swift
consentRequired: Bool
hasAdsConsentFlag: Bool
hasAnalyticsConsentFlag: Bool
consentDebugDeviceId: String?
```

### Future work

Replace stub with Google UMP or custom CMP; wire privacy params in URLBuilder from real consent strings.

---

## Privacy query parameters

**File:** `Constants.Privacy` + `DeviceInfo`

Sent on ad requests when available:
- `gdpr`, `gdpr_consent`
- `us_privacy`
- `ccpa`, `coppa`
- `dnt`, `ifa`

Source: UserDefaults / app configuration (see DeviceInfo implementation).

---

## iOS version fallbacks

`SKAdNetworkManagerLegacy` and `ConversionTrackerLegacy` provide no-op stubs for iOS < 14 with log messages.

---

## Testing

Internal views (may be excluded from framework build):
- `bidscubeSdk/Tests/SKAdNetworkTestView.swift`
- `bidscubeSdk/Tests/ConsentTestView.swift`

Test app calls `BidscubeSDK.requestConsentInfoUpdate(callback:)` in `TestAppRootView`.
