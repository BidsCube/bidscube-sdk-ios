# BidsCube iOS SDK

A comprehensive iOS SDK for displaying image, video, and native ads in iOS applications. The SDK supports various ad formats and positions with easy integration.

## Features

- **Image, Video, and Native ad support**
- **Multiple ad positions** (header, footer, sidebar, fullscreen)
- **VAST video ad support** with IMA SDK integration
- **Banner ad management**
- **Error handling and timeout management**
- **Production-ready** with comprehensive logging

## Requirements

- iOS 13.0+
- Xcode 15.0+
- Swift 6.0+
- CocoaPods 1.10.0+
- Swift Package Manager (recommended)
 
## Installation

### Swift Package Manager (Recommended)

1. In Xcode, go to **File** → **Add Package Dependencies**
2. Enter the repository URL: `https://github.com/bidscube/bidscube-sdk-ios.git`
3. Select the version you want to use
4. Click **Add Package**

Alternatively, add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/bidscube/bidscube-sdk-ios.git", from: "0.0.1")
]
```

### CocoaPods

Add the following to your `Podfile`:

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'bidscubeSdk'
end
```

Then run:

```bash
pod install
```

### Manual Installation

1. Download the latest release from GitHub
2. Add the `bidscubeSdk` folder to your Xcode project
3. Add the following frameworks to your project:
   - UIKit
   - WebKit
   - AVFoundation
   - MediaPlayer
   - GoogleAds-IMA-iOS-SDK

## Quick Start

### 1. Initialize the SDK

```swift
import bidscubeSdk

// Configure the SDK
let config = SDKConfig.Builder()
    .enableLogging(true)
    .enableDebugMode(true)
    .defaultAdTimeout(30000) // 30 seconds
    .build()

// Initialize the SDK
BidscubeSDK.initialize(config: config)
```

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
| `19483` | Video | Test video ad with VAST response |
| `test_image` | Image | Test image ad |
| `test_native` | Native | Test native ad |

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

### Version 0.0.7
- Automated release via GitHub Actions
- Bug fixes and improvements

### Version 0.0.5
- Automated release via GitHub Actions
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
