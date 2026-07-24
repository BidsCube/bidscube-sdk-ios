# Integration Guide — Host Applications

How publisher apps integrate the BidsCube iOS SDK. For internal team supporting clients.

---

## Installation

### Swift Package Manager (recommended)

```
https://github.com/bidscube/bidscube-sdk-ios.git
Version: 1.2.5 (or from: "1.2.5")
```

Product name: **`bidscubeSdk`**. SPM also resolves **GoogleInteractiveMediaAds** from **3.19.0**.

### CocoaPods

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'bidscubeSdk', '~> 1.2.5'
end
```

### AppLovin MAX

If integrating through AppLovin MAX, use the separately distributed Bidscube MAX mediation adapter. Do not add a duplicate direct `bidscubeSdk` dependency if the adapter already pulls the SDK transitively.

The AppLovin MAX adapter is **not** part of this SDK source package.

---

## Minimum integration

```swift
import bidscubeSdk

// AppDelegate or @main App init
BidscubeSDK.initialize()

// Optional consent stub
BidscubeSDK.requestConsentInfoUpdate(callback: myConsentDelegate)
```

---

## OpenRTB podded video responses (1.2.5)

The SDK supports **OpenRTB 2.6-style podded video response parsing** (response-side only). Ad requests remain legacy GET; the server may return JSON with `bids[]`, `seatbid[].bid[]`, or pod metadata under `openrtb.video`.

See [openrtb-podded-video.md](openrtb-podded-video.md) and [networking.md](networking.md).

---

## Show interstitial video

```swift
final class MyAds: AdCallback {
    func onAdLoading(_ id: String) { }
    func onAdLoaded(_ id: String) { }
    func onAdDisplayed(_ id: String) { }
    func onAdFailed(_ id: String, errorCode: Int, errorMessage: String) { }
    func onAdClosed(_ id: String) { }
    func onVideoAdStarted(_ id: String) { }
    func onVideoAdCompleted(_ id: String) { }
    func onVideoAdSkipped(_ id: String) { }
    func onVideoAdSkippable(_ id: String) { }
    func onEndCardShown(_ id: String) { }
    func onAdClicked(_ id: String) { }
}

// From UIViewController on screen
BidscubeSDK.showInterstitialVideoAd(
    "placement-id",
    from: self,
    callback: myAds
)
```

**Retain** the callback object — SDK holds weak reference.

---

## SwiftUI

Present from resolved view controller:

```swift
struct ContentView: View {
    var body: some View {
        Button("Show Ad") {
            guard let vc = UIApplication.shared.topViewController else { return }
            BidscubeSDK.showInterstitialVideoAd("id", from: vc, callback: delegate)
        }
    }
}
```

Or embed inline:

```swift
BidscubeSDK.getInterstitialVideoAdView("id", callback)
    .frame(height: 300)
```

---

## Other ad formats (quick reference)

| Need | API |
|------|-----|
| Footer banner | `BidscubeSDK.showFooterBanner(...)` |
| Native in feed | `BidscubeSDK.getNativeAdView(...)` |
| Fullscreen image | `BidscubeSDK.presentImageAd(...)` |
| Rewarded video | `BidscubeSDK.showRewardedVideoAd(...)` |

See [api-reference.md](api-reference.md).

---

## Configuration

```swift
let config = SDKConfig.Builder()
    .enableLogging(true)
    .enableDebugMode(false)
    .defaultAdTimeout(30_000)
    .baseURL("https://ssp-bcc-ads.com/sdk")
    .enableSKAdNetwork(true)
    .openRtbPodMetadataEnabled(true)
    .videoPodDurationValidationMode(.lenient)
    .build()

BidscubeSDK.initialize(config: config)
```

---

## Info.plist requirements

### SKAdNetwork (recommended)

```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>example.skadnetwork</string>
  </dict>
</array>
```

SDK reads **host app** plist entries.

### App Transport Security

All endpoints HTTPS — no ATS exceptions typically needed.

### IDFA (optional)

Add `NSUserTrackingUsageDescription` if using IDFA in requests.

---

## Analytics mapping (suggested)

| SDK callback | Suggested event |
|--------------|-----------------|
| `onAdLoading` | ad_request |
| `onAdLoaded` | ad_load_success |
| `onAdDisplayed` | ad_impression |
| `onAdClicked` | ad_click |
| `onVideoAdStarted` | video_start |
| `onVideoAdSkippable` | video_skip_available |
| `onVideoAdSkipped` | video_skip |
| `onVideoAdCompleted` | video_complete |
| `onEndCardShown` | end_card_impression |
| `onAdClosed` | ad_close |
| `onAdFailed` | ad_error |
| `onUserRewarded` | reward_granted (rewarded only) |

---

## Common integration mistakes

1. Using `showRewardedVideoAd` for interstitial with end card — wrong path.
2. Using `showVideoAd` without visible window — use explicit `from: viewController`.
3. Expecting end card without VAST companion — won't happen.
4. Not implementing `onAdFailed`.
5. Releasing delegate before callbacks complete.

---

## Support escalation

1. Get placement ID + SDK version (`Constants.sdkVersion`, currently **1.2.5**).
2. Reproduce with test fixtures if client VAST unknown.
3. Check [troubleshooting.md](troubleshooting.md).
4. Escalate to iOS team with callback log + VAST sample.
