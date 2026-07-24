# OpenRTB 2.6-Style Podded Video (Response Parsing)

**Version:** 1.2.5  
**Scope:** Response-side OpenRTB support only

---

## Summary

The iOS SDK supports **OpenRTB 2.6-style podded video response parsing**.

This is response-side support only.
The SDK does not currently build or POST OpenRTB bid requests.
The existing legacy GET ad request flow remains unchanged.
`OpenRTBBidRequestBuilder.swift` is a placeholder for future full OpenRTB client work.

Ad requests still use GET with `c=v`, `m=xml`. Only the **response payload** may be OpenRTB-like JSON or VAST.

---

## Supported response shapes

- raw VAST XML
- root JSON `adm`
- root `openrtb.video`
- root `openRtb.video`
- root `video`
- root `bids[]`
- `seatbid[].bid[]`
- bid-level `ext`

---

## Supported pod fields

`podid`, `podseq`, `poddur`, `rqddurs`, `rqdDurs`, `maxseq`, `slotinpod`, `duration`, `minduration`, `maxduration`, `price`, `crid`, `id`, `adm`

---

## Supported pod modes

| Mode | Detection |
|------|-----------|
| single | One ad / fallback |
| structured | `maxseq`, `rqddurs` / `rqdDurs` |
| dynamic | `poddur`-driven |
| hybrid | Mixed metadata |
| unknown | Fallback ordering |

---

## Ordering priority

1. `slotinpod`
2. VAST `<Ad sequence="...">`
3. response order

---

## Pipeline (source files)

| Component | File | Role |
|-----------|------|------|
| `VideoAdPayloadResolver` | `OpenRTB/VideoAdPayloadResolver.swift` | Entry: JSON, root ADM, raw VAST |
| `OpenRTBVideoObjectParser` | `OpenRTB/OpenRTBVideoObjectParser.swift` | Reads `openrtb.video` / `openRtb.video` / `video` |
| `OpenRTBPoddedResponseNormalizer` | `OpenRTB/OpenRTBPoddedResponseNormalizer.swift` | Normalizes `bids[]`, `seatbid[].bid[]` |
| `PoddedPlaybackPlanBuilder` | `OpenRTB/PoddedPlaybackPlanBuilder.swift` | Slot selection and ordering |
| `VastAdSequenceParser` | `OpenRTB/VastAdSequenceParser.swift` | VAST sequence from inline XML |
| `VastPodComposer` | `OpenRTB/VastPodComposer.swift` | Composes multi-slot inline VAST for Google IMA |
| `OpenRTBBidRequestBuilder` | `OpenRTB/OpenRTBBidRequestBuilder.swift` | **Placeholder only** — not wired |

Integration points:

- `VideoAdView.loadVideoAdFromURL`
- `VideoInterstitialPresenter.resolvePayload`
- `VideoInterstitialInlineContainerView.resolvePayload`

---

## Configuration

```swift
SDKConfig.Builder()
    .openRtbPodMetadataEnabled(true)              // default: true
    .videoPodDurationValidationMode(.lenient)     // or .strict
    .videoPodSkipPolicy(.skipCurrentAndContinue)  // or .failEntirePod
    .videoPodContinueOnSlotError(true)
    .videoPodShowCounter(true)
```

Set `openRtbPodMetadataEnabled(false)` to skip OpenRTB pod logic. Legacy root `adm` and raw VAST XML should still work.

---

## Limitations

- **Mixed URL/XML pods:** URL-only or mixed URL/XML pod composition is limited. The implementation uses the first URL slot and logs a warning.
- **No POST bid client:** Do not document or assume OpenRTB auction POST from the SDK.
- **Multi-ad root ADM:** A single root `adm` containing multiple `<Ad>` nodes is split into slots; `slotinpod` is not copied to every ad.

---

## JSON examples

### Root ADM + pod metadata

```json
{
  "adm": "<VAST>...</VAST>",
  "position": 7,
  "openrtb": {
    "video": {
      "podid": "pod-1",
      "poddur": 60,
      "rqddurs": [15, 30],
      "maxseq": 3
    }
  }
}
```

### Root `bids[]`

```json
{
  "openrtb": {
    "video": {
      "podid": "pod-1",
      "poddur": 60,
      "rqddurs": [15, 30],
      "maxseq": 3
    }
  },
  "bids": [
    {
      "adm": "<VAST>...</VAST>",
      "slotinpod": 1,
      "duration": 15
    },
    {
      "adm": "<VAST>...</VAST>",
      "slotinpod": 2,
      "duration": 30
    }
  ]
}
```

### `seatbid[].bid[]`

```json
{
  "seatbid": [
    {
      "bid": [
        {
          "id": "bid-1",
          "adm": "<VAST>...</VAST>",
          "crid": "creative-1",
          "price": 1.2,
          "ext": {
            "slotinpod": 1,
            "duration": 15,
            "podid": "pod-1"
          }
        }
      ]
    }
  ],
  "openrtb": {
    "video": {
      "podid": "pod-1",
      "poddur": 60,
      "rqddurs": [15, 30],
      "maxseq": 3
    }
  }
}
```

---

## Tests

| File | Coverage |
|------|----------|
| `OpenRTBPoddedResponseNormalizerTests.swift` | Normalizer |
| `PoddedPlaybackPlanBuilderTests.swift` | Plan builder |
| `VideoAdPayloadResolverTests.swift` | Resolver |
| `VastPodComposerTests.swift` | Composer |
| `OpenRTBVideoObjectParserTests.swift` | Video object parser |
| `OpenRTBTestFixtures.swift` | Shared fixtures |

Run: `xcodebuild build -target bidscubeSdkTests` (simulator tests require a configured simulator).

---

## Related docs

- [networking.md](networking.md) — GET request params
- [video-interstitial.md](video-interstitial.md) — IMA presentation
- [troubleshooting.md](troubleshooting.md) — OpenRTB JSON / pod order issues
- DocC: `bidscubeSdk/bidscubeSdk.docc/OpenRTB-2.6-Podded-Video.md`
- Public: [README.md](../../README.md)
