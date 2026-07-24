# Callbacks & Events

Reference for `AdCallback` and `ConsentCallback` (`bidscubeSdk/Core/Callbacks.swift`).

Optional methods have empty default implementations in `AdCallback` extension — implement only what you need.

---

## AdCallback — required methods

| Callback | Typical trigger |
|----------|-----------------|
| `onAdLoading(placementId)` | Load started |
| `onAdLoaded(placementId)` | Creative ready to show |
| `onAdDisplayed(placementId)` | Visible to user |
| `onAdClicked(placementId)` | User tapped ad / CTA |
| `onAdClosed(placementId)` | Session ended (once) |
| `onAdFailed(placementId, errorCode, errorMessage)` | Unrecoverable error |

---

## AdCallback — optional video methods

| Callback | Interstitial module | Legacy IMA (`IMAVideoAdHandler`) |
|----------|--------------------|---------------------------------|
| `onVideoAdStarted` | IMA `.STARTED` | IMA `.STARTED` |
| `onVideoAdCompleted` | Natural completion | IMA `.COMPLETE` |
| `onVideoAdSkipped` | User skip / close-with-preview | IMA `.SKIPPED` or synthetic on dismiss |
| `onVideoAdSkippable` | Skip countdown finished | **Not fired** |
| `onEndCardShown` | End card visible | **Not fired** |
| `onUserRewarded` | **Never** | IMA `.COMPLETE` + rewarded format only |

---

## AdCallback — other optional

| Callback | When |
|----------|------|
| `onInstallButtonClicked(placementId, buttonText)` | **Reserved for future CTA-specific reporting.** Current end card CTA taps are reported through `onAdClicked` |
| `onAdRenderOverride(adm, position)` | Image/native JSON has both `adm` and `position` |

---

## Callback sequences by format

### Banner / getImageAdView / getNativeAdView

```
onAdLoading → (network) → onAdLoaded (+1s) → onAdDisplayed (+1s)
```

Note: view-return APIs fire loaded/displayed on a **1 second delay** without waiting for WebView load completion.

### showImageAd / showNativeAd

```
onAdLoading → network success → onAdLoaded → onAdDisplayed
(or onAdFailed / onAdRenderOverride)
```

### Video interstitial — with VAST companion

**Skip path:**
```
onAdLoading → onAdLoaded → onAdDisplayed → onVideoAdStarted
→ onVideoAdSkippable → onVideoAdSkipped → onEndCardShown
→ [onAdClicked] → onAdClosed
```

**Complete path:**
```
onAdLoading → onAdLoaded → onAdDisplayed → onVideoAdStarted
→ onVideoAdCompleted → onEndCardShown → onAdClosed
```

### Video interstitial — without companion

```
onAdLoading → onAdLoaded → onAdDisplayed → onVideoAdStarted
→ onVideoAdCompleted → onAdClosed
```

No `onVideoAdSkippable`, no `onEndCardShown`.

### Rewarded video (legacy)

**Complete (reward granted):**
```
onAdLoading → onAdLoaded → onAdDisplayed → onVideoAdStarted
→ onVideoAdCompleted → onUserRewarded → onAdClosed
```

**Skip / early close:**
```
… → onVideoAdStarted → onVideoAdSkipped → onAdClosed
(no onUserRewarded)
```

---

## onAdClosed guarantees

| Rule | Detail |
|------|--------|
| Fires **once** per session | Guards in VC / handler |
| Interstitial dismiss | After end card ✕ or no-preview auto-close |
| Legacy video | User dismiss, swipe, or close button |
| `viewDidDisappear` | May emit skip + closed if session incomplete |

---

## onAdFailed error codes

From `Constants.ErrorCodes`:

| Code | Constant | Common causes |
|------|----------|---------------|
| -1 | `invalidURL` | SDK not init, bad placement |
| -2 | `networkError` | HTTP failure, timeout in AdViewController |
| -3 | `invalidResponse` | Empty body, bad HTTP status |
| -4 | `parsingError` | Rare direct use |
| -5 | `timeoutError` | URLError timed out |
| -6 | `consentError` | Reserved |
| -7 | `presenterUnavailable` | `showVideoAd` with no key window |
| -8 | `invalidAdMarkup` | VAST/IMA load failure |

---

## ConsentCallback

| Callback | Current behaviour |
|----------|-----------------|
| `onConsentInfoUpdated` | Always after `requestConsentInfoUpdate` (0.1s delay) |
| `onConsentInfoUpdateFailed` | **Never called** (stub) |
| `onConsentFormShown` | `showConsentForm` |
| `onConsentFormError` | **Never called** |
| `onConsentGranted` | Auto after form |
| `onConsentDenied` | **Never called** |
| `onConsentNotRequired` | **Never called** |
| `onConsentStatusChanged` | `true` after grant |

**Important:** Consent is a stub. Real UMP/consent SDK integration is future work.

---

## Pitfalls for integrators (support team notes)

1. **Duplicate `onAdLoading`** — possible if both presenter and nested view report loading; fullscreen video suppresses duplicate in some paths.
2. **1s delayed loaded/displayed** — banner/image/native view APIs; document for analytics teams.
3. **`onUserRewarded` on interstitial** — will never fire; use rewarded API.
4. **`onEndCardShown` without companion** — will never fire in production interstitial flow.
5. **Weak callback** — host must retain delegate object; SDK holds weak reference.

---

## Testing callbacks

Use `testApp-ios/TestAdDelegate.swift` — prints all events to Xcode console.

Filter console: `[TestAdDelegate]`
