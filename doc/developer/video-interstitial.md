# Video Interstitial — Developer Deep Dive

Complete technical reference for the video interstitial module (release 1.2.4).

---

## Module files

| File | Lines of responsibility |
|------|-------------------------|
| `VideoInterstitialPresenter.swift` | Network load, payload resolution, present/push/test |
| `VideoInterstitialViewController.swift` | UI state machine, callback orchestration |
| `IMAVideoInterstitialPlayer.swift` | Google IMA integration |
| `VideoInterstitialOverlayView.swift` | Skip countdown + close button |
| `VideoInterstitialEndCardView.swift` | Preview end card UI |
| `VideoInterstitialEndCardPreviewViewController.swift` | QA preview-only screen |
| `VideoInterstitialInlineContainerView.swift` | Non-modal embedding |
| `VastMetadataParser.swift` | VAST XML parsing |
| `VideoInterstitialMetadata.swift` | Metadata model |
| `VideoInterstitialTestVAST.swift` | Internal QA fixtures |

---

## End-to-end flow

```mermaid
sequenceDiagram
    participant App
    participant SDK as BidscubeSDK
    participant Pres as VideoInterstitialPresenter
    participant SSP
    participant VC as VideoInterstitialViewController
    participant IMA as IMAVideoInterstitialPlayer
    participant End as VideoInterstitialEndCardView

    App->>SDK: showInterstitialVideoAd
    SDK->>Pres: present
    Pres->>App: onAdLoading
    Pres->>SSP: GET video placement
    SSP-->>Pres: VAST or JSON adm
    Pres->>Pres: VastMetadataParser.parse
    Pres->>App: onAdLoaded
    Pres->>VC: present modal
    VC->>App: onAdDisplayed
    VC->>IMA: loadAd (viewDidAppear)
    IMA->>VC: onVideoAdStarted
    alt has companion
        VC->>VC: skip countdown
        opt user skips
            IMA->>VC: onVideoAdSkipped
            VC->>End: showEndCard
            VC->>App: onEndCardShown
        else video completes
            IMA->>VC: onVideoAdCompleted
            VC->>End: showEndCard
        end
    else no companion
        IMA->>VC: onVideoAdCompleted
        VC->>App: onAdClosed
    end
```

---

## VAST parsing (`VastMetadataParser`)

### Extracted fields

| Field | XML source |
|-------|------------|
| `previewImageUrl` | `<Companion>…<StaticResource>URL</StaticResource>` |
| `clickUrl` | `CompanionClickThrough` → else `VideoClicks/ClickThrough` |
| `skipOffsetSeconds` | `<Linear skipoffset="HH:MM:SS">` — **only if companion exists** |

### Duration parsing

Supports:
- `00:00:05` (HH:MM:SS)
- `00:05` (MM:SS)
- `7.9` (seconds as decimal)

### Parser implementation note

`firstMatch()` returns capture group 1 if present, else full match (group 0). Required for patterns like `<Companion>…</Companion>` without parentheses.

### Product gating

```swift
hasPreviewEndCard = metadata.previewImageUrl != nil
```

If nil:
- `skipOverlay.hideOverlay()` for entire video
- `finishVideoPhase` → `dismissInterstitial()` not `showEndCard()`

---

## IMA player (`IMAVideoInterstitialPlayer`)

### Configuration

```swift
settings.uiElements = []
settings.disableUi = true
```

All skip/close UX is custom via `VideoInterstitialOverlayView`.

### Inline VAST loading

```swift
let dataURI = "data:application/xml;base64,\(Data(vast.utf8).base64EncodedString())"
IMAAdsRequest(adTagUrl: dataURI, adDisplayContainer: …)
```

Same approach as legacy `IMAVideoAdHandler` — do not use `adsResponse:` parameter.

### Skip implementation

1. Overlay countdown completes → `markSkipOffsetReached()`
2. User taps Skip → `adsManager.skip()` if skippable, then **always** `notifySkipped()` locally
3. Prevents IMA silent skip failures with custom UI

### Audio

```swift
AVAudioSession.setCategory(.playback)
```

Set in `setupIMAIfNeeded`.

---

## Overlay (`VideoInterstitialOverlayView`)

| Mode | UI | Size |
|------|-----|------|
| Countdown | `Skip in N` | Wide 108×36, monospaced digits |
| Skip enabled | `Skip` | Wide |
| End card close | `✕` | Compact 36×36 |
| Close only | `✕` | Compact |

Countdown uses `Timer.scheduledTimer` (1s interval).

---

## End card (`VideoInterstitialEndCardView`)

- Background `#F2F2F2`
- Preview container flexes (no scroll)
- Default metadata: `VideoInterstitialMetadata()` init defaults
- Preview image: `metadata.previewImageUrl` only (loaded via URLSession)
- Fallback default image used only in preview-only QA when testing layout without companion
- CTA min height 56pt
- Close overlay compact ✕ on preview container

Actions:
- Preview tap → `onAdClicked` + open URL
- Install Now → same
- ✕ → `onAdClosed`

---

## Inline embedding

`VideoInterstitialInlineContainerView`:
1. Loads placement like presenter
2. Adds `VideoInterstitialViewController` as child
3. `isEmbedded: true` → dismiss removes from parent, no modal

---

## Test fixtures (`VideoInterstitialTestVAST`)

| Fixture | Video | Companion | Skip | Use |
|---------|-------|-----------|------|-----|
| `qaWithoutPreview` | Doordash MP4 | No | No | Case 1 |
| `qaWithPreview` | Big Buck Bunny | gstatic image | 5s | Case 2 |
| `withCompanionAndSkip` | Sample URLs | Yes | 5s | Unit tests |
| `withoutCompanion` | Sample | No | 0 | Unit tests |
| `liveIMAAdTag` | Google sample tag | — | — | Ad tag test |

Public QA access:
```swift
BidscubeSDKVideoInterstitialQA.vastWithoutPreview
BidscubeSDKVideoInterstitialQA.vastWithPreview
```

---

## Unit tests

`Tests/bidscubeSdkTests/VastMetadataParserTests.swift`:
- Companion parsing
- Skip without companion = 0
- QA fixture expectations
- Duration format parsing

Run via Xcode test action on `bidscubeSdkTests` target (when configured in scheme).

---

## Android parity notes

Aligned behaviours:
- Custom skip overlay (no IMA default UI)
- End card only with VAST companion
- No skip without companion
- Close after video when no end card

iOS-specific:
- Base64 data URI for inline VAST
- App-store-style end card layout (UIKit stack, no scroll)

---

## Related

- [callbacks-and-events.md](callbacks-and-events.md)
- [../qa/video-interstitial-qa.md](../qa/video-interstitial-qa.md)
- [troubleshooting.md](troubleshooting.md)
