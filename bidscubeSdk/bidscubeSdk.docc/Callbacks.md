# Callbacks

Implement ``AdCallback`` to receive ad lifecycle events from ``BidscubeSDK``.

## Required methods

```swift
func onAdLoading(_ placementId: String)
func onAdLoaded(_ placementId: String)
func onAdDisplayed(_ placementId: String)
func onAdClicked(_ placementId: String)
func onAdClosed(_ placementId: String)
func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String)
```

These six methods are required by the protocol.

## Optional methods (default implementations)

```swift
func onVideoAdStarted(_ placementId: String)
func onVideoAdCompleted(_ placementId: String)
func onVideoAdSkipped(_ placementId: String)
func onUserRewarded(_ placementId: String)
func onVideoAdSkippable(_ placementId: String)
func onEndCardShown(_ placementId: String)
func onInstallButtonClicked(_ placementId: String, buttonText: String)
func onAdRenderOverride(adm: String, position: AdPosition)
```

Video-specific methods have empty default implementations in a ``AdCallback`` protocol extension.

## Video reward policy

`onUserRewarded` is only for rewarded video and only after natural IMA completion. Skip, close, error, or failed playback must not reward the user.

## Custom rendering

`onAdRenderOverride(adm:position:)` allows app-side custom rendering when the response includes both `adm` markup and a suggested `AdPosition`. The SDK skips built-in rendering when this override path is taken.

## Consent callbacks

Optional consent helpers use ``ConsentCallback``:

```swift
BidscubeSDK.requestConsentInfoUpdate(callback: self)
BidscubeSDK.showConsentForm(self)
```

Consent APIs are stubbed for integration testing; they do not connect to a live CMP.
