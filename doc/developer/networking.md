# Networking

How the SDK communicates with the BidsCube SSP.

---

## Base URL

```
https://ssp-bcc-ads.com/sdk
```

Configured via `SDKConfig.Builder.baseURL(_:)` or `Constants.baseURL`.

---

## URLBuilder

**File:** `bidscubeSdk/Networking/URLBuilder.swift`

### Common query parameters (all ad types)

| Param | Source |
|-------|--------|
| `placementId` / `id` | Caller |
| `app`, `bundle`, `name` | Host app bundle |
| `app_store_url` | iTunes URL if available |
| `lang` | Device language |
| `w`, `h` | Screen dimensions |
| `ua` | Device user agent |
| `ifa` | IDFA (if authorized) |
| `dnt` | Do-not-track flag |
| Privacy | `gdpr`, `gdpr_consent`, `us_privacy`, `ccpa`, `coppa` from UserDefaults / app |

### Per ad type

| Type | `c` | `m` | `res` | Notes |
|------|-----|-----|-------|-------|
| Image/banner | `b` | `api` | `js` | HTML/JS creative |
| Video | `v` | `xml` | — | VAST; includes `app_version`, width, height |
| Native | `n` | `api` | `json` | JSON native object |

Optional: `cta_text`, repeated `skadnet` entries from Info.plist `SKAdNetworkItems`.

### Debug mode

When `SDKConfig.enableDebugMode == true`, additional debug query params may be appended (see URLBuilder implementation).

---

## NetworkManager

**File:** `bidscubeSdk/Networking/NetworkManager.swift`

- Singleton with 30s timeout.
- `get(url:completion:)` — primary method for `showImageAd` / `showNativeAd`.
- Maps errors to `Constants.ErrorCodes`.
- HTTP status: only 2xx treated as success.

### NetworkError enum

Maps URLError and HTTP failures to SDK error codes for consistent `onAdFailed` reporting.

---

## DeviceInfo

**File:** `bidscubeSdk/Networking/DeviceInfo.swift`

Provides:
- Bundle identifier, app name, version
- Screen width/height
- Safari-like user agent string
- IDFA via `ASIdentifierManager`
- Privacy consent strings from standard keys

---

## Response handling by format

### Image / native (JSON)

Typical response fields:
```json
{
  "adm": "<html or json string>",
  "position": 3
}
```

- `position` → `BidscubeSDK.setResponseAdPosition`
- SKAdNetwork data may be embedded — processed by `SKAdNetworkManager`

### Video (VAST or wrapper)

Video responses are normalized by `VideoAdPayloadResolver` (`bidscubeSdk/OpenRTB/`) and played through the existing IMA flow.

**Request:** the SDK still uses the legacy GET ad request flow (`c=v`, `m=xml`). This is **not** a full OpenRTB bid-request client yet.

**Supported response shapes:**

- Raw inline VAST XML
- JSON root `adm` (VAST XML or VAST ad tag URL)
- OpenRTB-like pod metadata via `openrtb.video`, `openRtb.video`, or root `video`
- Podded bids via root `bids[]` or `seatbid[].bid[]` (including bid-level `ext`)
- Pod modes: structured (`maxseq` / `rqddurs`), dynamic (`poddur`), hybrid

**Legacy paths (unchanged):**

1. GET placement URL.
2. `VideoAdPayloadResolver.resolve` tries OpenRTB pod parsing when `openRtbPodMetadataEnabled` is true (default).
3. Falls back to root `adm` or raw VAST.
4. Multiple inline VAST pod slots are composed into one VAST document for IMA.

**Config (optional):**

```swift
SDKConfig.Builder()
    .openRtbPodMetadataEnabled(true)              // default true
    .videoPodDurationValidationMode(.lenient)     // or .strict
    .videoPodSkipPolicy(.skipCurrentAndContinue)
    .videoPodContinueOnSlotError(true)
    .videoPodShowCounter(true)
```

**VideoInterstitialPresenter** / **VideoAdView** / inline interstitial container all use the shared resolver.

---

## SKAdNetwork in requests

When `enableSKAdNetwork` in config:
- URLBuilder appends SKAdNetwork IDs from host app Info.plist.
- `showImageAd` / `showNativeAd` may POST-process SKAdNetwork response JSON.

See [skadnetwork-consent.md](skadnetwork-consent.md).

---

## Logging

Network logs use prefix `🌐 Network` (`Constants.LogPrefixes.network`).

Enable via `SDKConfig.enableLogging(true)`.

---

## Debugging tips

```swift
if let url = BidscubeSDK.buildRequestURL(placementId: "xxx", adType: .video) {
    print(url.absoluteString)
}
```

Paste URL in browser/curl to inspect raw SSP response (staging placements only).

Common failures:
- Empty `adm` → `invalidAdMarkup`
- Non-VAST video response → parser fails
- Missing network permission / ATS — rare (all HTTPS)
