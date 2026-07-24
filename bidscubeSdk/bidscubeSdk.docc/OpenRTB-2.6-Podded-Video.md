# OpenRTB 2.6 Podded Video

The iOS SDK supports OpenRTB 2.6-style podded video response parsing.

This is response-side support only.
The SDK does not currently build or POST OpenRTB bid requests.
The existing legacy GET ad request flow remains unchanged.
`OpenRTBBidRequestBuilder.swift` is a placeholder for future full OpenRTB client work.

## Supported response shapes

- raw VAST XML
- root JSON `adm`
- root `openrtb.video`
- root `openRtb.video`
- root `video`
- root `bids[]`
- `seatbid[].bid[]`
- bid-level `ext`

## Supported pod fields

`podid`, `podseq`, `poddur`, `rqddurs`, `rqdDurs`, `maxseq`, `slotinpod`, `duration`, `minduration`, `maxduration`, `price`, `crid`, `id`, `adm`

## Supported pod modes

- single
- structured
- dynamic
- hybrid
- unknown/fallback

## Ordering priority

1. `slotinpod`
2. VAST `<Ad sequence="...">`
3. response order

## Pipeline

| Component | Role |
|-----------|------|
| ``VideoAdPayloadResolver`` | Resolves JSON/OpenRTB/root ADM/raw VAST |
| ``OpenRTBPoddedResponseNormalizer`` | Normalizes `bids[]` and `seatbid[].bid[]` |
| ``PoddedPlaybackPlanBuilder`` | Selects ordered playback slots |
| ``VastPodComposer`` | Composes multiple inline VAST slots into one VAST response for Google IMA |

### URL-only or mixed pods

URL-only or mixed URL/XML pod composition is limited: the current implementation uses the first URL slot and logs a warning.

### Disabling pod metadata

If `openRtbPodMetadataEnabled(false)`, OpenRTB pod logic is skipped, but legacy root `adm` and raw VAST should still work.

Configure pod behavior in ``SDKConfig.Builder``. See <doc:Initialization>.

## JSON examples

### Root ADM

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

### Root bids

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

### Seatbid

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

## Terminology

Use **OpenRTB 2.6-style podded video response parsing** and **response-side OpenRTB support**. The SDK does not provide a full OpenRTB integration, OpenRTB bidder, or POST auction request client.
