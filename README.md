# BidsCube iOS SDK

A comprehensive iOS SDK for displaying image, video, and native ads in iOS applications. The SDK supports various ad formats and positions with easy integration.

## Features

- **Image, Video, and Native ad support**
- **Multiple ad positions** (header, footer, sidebar, fullscreen)
- **VAST video ad support** with IMA SDK integration
- **OpenRTB 2.6-style podded video response parsing** (response-side only; legacy GET requests unchanged)
- **Banner ad management**
- **Error handling and timeout management**
- **Production-ready** with comprehensive logging

## Requirements
- iOS **13.0+** (Swift Package Manager and CocoaPods; single minimum for all integrations)
- Xcode 15.0+
- Swift 6.0+
- CocoaPods 1.10.0+ or Swift Package Manager

### AppLovin MAX mediation
**Versions are separate:** the BidsCube iOS library is **`bidscubeSdk`** (e.g. **1.2.5**). The AppLovin pod **`AppLovinMediationBidscubeAdapter`** has its **own** version (e.g. **1.0.3**) and declares `bidscubeSdk ~> 1.2` — CocoaPods installs **bidscubeSdk** transitively; you do **not** add `pod 'bidscubeSdk'` when you already use the adapter. Also add **AppLovinSDK** (≥ 13.0). Deployment target iOS 13.0+.

## Installation
### Swift Package Manager (recommended)
1. File → **Add Package Dependencies** → `https://github.com/bidscube/bidscube-sdk-ios.git`
2. Pick BidsCube library version **1.2.5** (or `from: "1.2.5"` in `Package.swift`)
```swift
dependencies: [
    .package(url: "https://github.com/bidscube/bidscube-sdk-ios.git", from: "1.2.5")
]
```

### CocoaPods
```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'bidscubeSdk', '~> 1.2.5'
end
```
Run `pod install`.

### CocoaPods + AppLovin MAX (example)
Adapter pod version (e.g. **1.0.3**) ≠ `bidscubeSdk` version (**1.2.5**). Only adapter + AppLovinSDK; `bidscubeSdk` comes transitively.

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'AppLovinSDK', '~> 13.0'
  pod 'AppLovinMediationBidscubeAdapter', '~> 1.0.3' # resolves bidscubeSdk ~> 1.2
end
```

### Manual Installation
1. Download the repo.
2. Add `bidscubeSdk` to your project.
3. Link `UIKit`, `WebKit`, `AVFoundation`, `MediaPlayer`, and `GoogleAds-IMA-iOS-SDK`.

## Quick start
### 1. Initialize the SDK
```swift
import bidscubeSdk

let config = SDKConfig.Builder()
   .enableLogging(true)
    .enableDebugMode(false)
    .defaultAdTimeout(Constants.defaultTimeoutMs)
    .defaultAdPosition(Constants.defaultAdPosition)
    .baseURL(Constants.baseURL)
    .enableSKAdNetwork(true)
    .skAdNetworkId("skadnetwork.com.example")
    .skAdNetworkConversionValue(1)
    .build()

BidscubeSDK.initialize(config: config)
```

### OpenRTB 2.6-style podded video responses

The iOS SDK supports **OpenRTB 2.6-style podded video response parsing**. This is **response-side only** — it is **not** a full OpenRTB bid-request client yet. Ad requests still use the existing legacy GET flow (`c=v`, `m=xml`).

Supported response shapes:

- Root `adm` (VAST XML or VAST ad tag URL)
- Raw inline VAST XML
- `openrtb.video`, `openRtb.video`, or root `video` pod metadata
- Podded bids via `bids[]` or `seatbid[].bid[]` (including bid-level `ext`)

Supported pod modes: **structured**, **dynamic**, **hybrid**, and single-ad fallback.

Optional configuration:

```swift
SDKConfig.Builder()
    .openRtbPodMetadataEnabled(true)              // default: true
    .videoPodDurationValidationMode(.lenient)     // or .strict
    .videoPodSkipPolicy(.skipCurrentAndContinue)
    .videoPodContinueOnSlotError(true)
    .videoPodShowCounter(true)
```

Set `openRtbPodMetadataEnabled(false)` to disable pod parsing and keep legacy root-`adm`/raw-VAST behavior only.

### 2. Request Ads

```swift
// Set up callback delegate
class AdDelegate: AdCallback {
    func onAdLoading(_ placementId: String) {
        print("Ad loading: \(placementId)")
    }
    
    func onAdLoaded(_ placementId: String) {
        print("Ad loaded: \(placementId)")
    }
    
    func onAdDisplayed(_ placementId: String) {
        print("Ad displayed: \(placementId)")
    }
    
    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String) {
        print("Ad failed: \(placementId) - \(errorMessage)")
    }
    
    func onAdClicked(_ placementId: String) {
        print("Ad clicked: \(placementId)")
    }
    
    func onAdClosed(_ placementId: String) {
        print("Ad closed: \(placementId)")
    }
    
    func onVideoAdStarted(_ placementId: String) {
        print("Video ad started: \(placementId)")
    }
    
    func onVideoAdCompleted(_ placementId: String) {
        print("Video ad completed: \(placementId)")
    }
    
    func onVideoAdSkipped(_ placementId: String) {
        print("Video ad skipped: \(placementId)")
    }
}

let adDelegate = AdDelegate()
```

## Usage Examples

### Image Ads

```swift
// Get image ad view
let imageAdView = BidscubeSDK.getImageAdView("your_image_placement_id", adDelegate)

// Add to your view hierarchy
view.addSubview(imageAdView)
imageAdView.translatesAutoresizingMaskIntoConstraints = false

### Video Ads

```swift
// Get video ad view
let videoAdView = BidscubeSDK.getVideoAdView("your_video_placement_id", adDelegate)

// Add to your view hierarchy
view.addSubview(videoAdView)
videoAdView.translatesAutoresizingMaskIntoConstraints = false

// Set constraints
NSLayoutConstraint.activate([
    videoAdView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    videoAdView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    videoAdView.widthAnchor.constraint(equalToConstant: 320),
    videoAdView.heightAnchor.constraint(equalToConstant: 240)
])
```

### Native Ads

```swift
// Get native ad view
let nativeAdView = BidscubeSDK.getNativeAdView("your_native_placement_id", adDelegate)

// Add to your view hierarchy
view.addSubview(nativeAdView)
nativeAdView.translatesAutoresizingMaskIntoConstraints = false

// Set constraints
NSLayoutConstraint.activate([
    nativeAdView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
    nativeAdView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
    nativeAdView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
    nativeAdView.heightAnchor.constraint(equalToConstant: 300)
])
```

## Placement IDs

The SDK supports different placement IDs for various ad types and positions:

### Test Placement IDs

| Placement ID | Ad Type | Description |
|--------------|---------|-------------|
| `20213` | Video | Test video ad with VAST response |
| `20212` | Image | Test image ad |
| `20214` | Native | Test native ad |

### Production Placement IDs

Contact BidsCube support to get your production placement IDs for:
- **Image Ads**: Banner, header, footer positions
- **Video Ads**: Interstitial, rewarded video
- **Native Ads**: In-feed, content recommendations

## Ad Positions

The SDK supports various ad positions:

```swift
enum AdPosition {
    case header      // Top of screen
    case footer      // Bottom of screen
    case sidebar     // Side panel
    case fullScreen  // Full screen overlay
    case aboveTheFold // Above content fold
    case belowTheFold // Below content fold
    case unknown     // Default position
}
```

## Running the Test App

### Prerequisites

1. **Clone the repository**:
   ```bash
   git clone https://github.com/bidscube/bidscube-sdk-ios.git
   cd bidscube-sdk-ios
   ```

2. **Install dependencies**:
   ```bash
   pod install
   ```

3. **Open the workspace**:
   ```bash
   open bidscubeSdk.xcworkspace
   ```

### Running Tests

1. **Select the test app target** in Xcode
2. **Choose a simulator** or connected device
3. **Build and run** (⌘+R)

### Test App Features

The test app includes:

- **Ad Type Selection**: Choose between Image, Video, and Native ads
- **Placement ID Input**: Test different placement IDs
- **Position Selection**: Test various ad positions
- **Real-time Logging**: View SDK logs and responses
- **Error Handling**: Test error scenarios and recovery

### Test App Usage

1. **Launch the app**
2. **Select ad type** (Image/Video/Native)
3. **Enter placement ID** (use test IDs or your own)
4. **Choose position** (Header/Footer/Sidebar/FullScreen)
5. **Tap "Load Ad"** to request the ad
6. **Monitor logs** for detailed information

## Configuration Options

### SDK Configuration

```swift
let config = SDKConfig.Builder()
    .baseURL(Constants.baseURL)                   // API endpoint
    .enableLogging(true)                          // Enable console logging
    .enableDebugMode(true)                        // Enable debug mode
    .defaultAdTimeout(30000)                      // Timeout in milliseconds
    .defaultAdPosition(.header)                   // Default ad position
    .build()
```

## Ads, positions, and rendering override

- **Ad types**: image, video, native.
- **Test placements**: `20212` (image/banner), `20213` (video), `20214` (native).
- **Positions** (`AdPosition` raw values): `unknown` (0), `aboveTheFold` (1), `dependOnScreenSize` (2), `belowTheFold` (3), `header` (4), `footer` (5), `sidebar` (6), `fullScreen` (7).
- You can set a manual position before requesting with `BidscubeSDK.setAdPosition(_:)`; SDK falls back to server `position`, then `unknown`.
- If the ad response contains both `adm` (ad markup) and `position`, the SDK triggers `onAdRenderOverride(adm:position:)` and skips built-in rendering so you can render the markup yourself.

Example override hook:
```swift
class CustomDelegate: AdCallback {
    func onAdRenderOverride(adm: String, position: AdPosition) {
        // adm: ad markup (HTML/VAST/snippet); position: where server suggests
        render(adm, at: position)
    }
}
```

See the in-repo demo `bidscubeSdk/Views/CustomAdRenderView.swift` for a working override flow.

## Troubleshooting

### Common Issues

1. **Ad not loading**:
   - Check network connectivity
   - Verify placement ID is correct
   - Check console logs for error messages

2. **Video ads not playing**:
   - Ensure IMA SDK is properly integrated
   - Check VAST response format
   - Verify video URL is accessible

3. **Build errors**:
   - Ensure iOS 13.0+ deployment target
   - Check all required frameworks are linked
   - Verify CocoaPods installation

### Debug Mode

Enable debug mode for detailed logging:

```swift
let config = SDKConfig.Builder()
    .enableDebugMode(true)
    .build()
```

## Building the Package

**Important**: This is an iOS-only package and cannot be built from the command line using `swift build` because UIKit is iOS-only. This is expected behavior.

### To Build and Test:

1. **Using Xcode** (Recommended):
   - Create a new iOS project
   - File → Add Package Dependencies
   - Enter: `https://github.com/bidscube/bidscube-sdk-ios.git`
   - Build the project

2. **Using existing workspace**:
   ```bash
   open bidscubeSdk.xcworkspace
   # Select bidscubeSdk scheme and build
   ```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Changelog

### Version 1.2.5
- **OpenRTB 2.6-style podded video:** response parsing for `bids[]`, `seatbid[].bid[]`, and `openrtb.video` / `openRtb.video` / root `video`; composes multi-slot inline VAST for IMA playback. Legacy GET requests unchanged; not a full OpenRTB bid-request client.
- **OpenRTB config:** optional `openRtbPodMetadataEnabled`, pod validation mode, skip policy, and related builder flags on `SDKConfig`.
- **Packaging:** SPM/CocoaPods exclude demo/test views under `bidscubeSdk/Tests/` and sample controllers from the production SDK.
- **Tests:** OpenRTB normalizer, playback plan builder, payload resolver, and VAST pod composer unit tests.

### Version 1.2.4
- **Video interstitial (IMA/VAST):** fullscreen interstitial with custom skip overlay, preview end card, and VAST metadata parsing (companion image, click-through, skip offset).
- **Preview flow:** end card after skip/complete when VAST has companion preview; without companion — no skip button, closes after video.
- **`onEndCardShown`:** new callback when preview/end-card screen is displayed.
- **APIs:** `showInterstitialVideoAd`, `presentAd(.video)`, `pushVideoAd`, inline `getInterstitialVideoAdView`; test helpers `presentTestVideoInterstitial`, `presentTestEndCardPreview`, `BidscubeSDKVideoInterstitialQA` fixtures.
- **Test app:** Video Interstitial QA tab with Case 1 / Case 2 and preview-only screens.

### Version 1.2.3
- **Video (IMA/VAST):** correct lifecycle callbacks from real playback (`LOADED`, `STARTED`, `COMPLETE`, `SKIPPED`); removed timer/fake completions.
- **Interstitial vs rewarded:** `VideoAdFormat`, `showInterstitialVideoAd` / `showRewardedVideoAd`, inline `getInterstitialVideoAdView` / `getRewardedVideoAdView`; legacy `showVideoAd` / `getVideoAdView` remain **interstitial**-compatible.
- **`onUserRewarded`:** only for rewarded format, only after IMA `.COMPLETE` (never on skip/close/failure).
- **Dismiss / skip:** closing mid-play reports `onVideoAdSkipped`; `onAdClosed` fires once.
- **`onAdLoading`:** deduplicated between fullscreen presenter and nested views.
- **Errors:** richer `onAdFailed` from video fetch/markup parsing; simulator presentation errors (`presenterUnavailable`).
- **Logging:** `SDKLogger` safe on iOS 13 (`os.Logger` gated to iOS 14+).

### Version 1.2.2
- Fire Native `imptrackers` on ad display with one-time guard per load
- Add impression tracker success/failure logging for validation

### Version 1.2.1
- Automated release via GitHub Actions
- Bug fixes and improvements

### Version 1.1.0
- Automated release via GitHub Actions
- Bug fixes and improvements

### Version 1.1.0
- Release version

### Version 0.2.1
- Automated release via GitHub Actions
- Hot fix for BidscubeSDK Flutter version compatibility
- Bug fixes and improvements

### Version 0.1
- Automated release via GitHub Actions
- Bug fixes and improvements

### Version 0.0.2
- Initial release
- Image, Video, and Native ad support
- Multiple ad positions
- VAST video ad integration
- Comprehensive error handling
- Production-ready logging

---

**BidsCube iOS SDK** - Making mobile advertising simple and effective.
