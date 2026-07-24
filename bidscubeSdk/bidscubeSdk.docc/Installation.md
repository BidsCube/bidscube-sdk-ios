# Installation

Install **bidscubeSdk** version **1.2.6** using Swift Package Manager or CocoaPods.

## Requirements

- iOS **13.0+**
- Swift tools version **6.0**
- Xcode 15.0+ recommended

## Swift Package Manager

Add the package dependency:

```swift
dependencies: [
    .package(url: "https://github.com/bidscube/bidscube-sdk-ios.git", from: "1.2.6")
]
```

Link the product **`bidscubeSdk`** to your app target.

The SDK depends on **GoogleInteractiveMediaAds** from **3.19.0** (Google IMA for video playback).

Import the module:

```swift
import bidscubeSdk
```

## CocoaPods

```ruby
platform :ios, '13.0'
use_frameworks!

target 'YourApp' do
  pod 'bidscubeSdk', '~> 1.2.6'
end
```

Run `pod install`, then open the `.xcworkspace`.

The podspec declares a dependency on **GoogleAds-IMA-iOS-SDK** `~> 3.19`.

## AppLovin MAX mediation

When using **AppLovinMediationBidscubeAdapter**, add the adapter and AppLovinSDK only. The adapter resolves `bidscubeSdk` transitively; you do not need a separate `pod 'bidscubeSdk'` entry.
