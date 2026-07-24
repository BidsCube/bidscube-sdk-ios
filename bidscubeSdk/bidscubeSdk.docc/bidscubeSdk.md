# ``bidscubeSdk``

Bidscube iOS SDK is a lightweight ad SDK for displaying image, banner, native, and video ads on iOS.

## Overview

Current capabilities:

- Image ads
- Banner ads
- Native ads
- Video ads
- Interstitial video
- Rewarded video
- Inline/embedded video ad views
- SKAdNetwork helper methods
- Optional consent helper stubs
- OpenRTB 2.6-style podded video response parsing

The SDK uses the existing legacy GET ad request flow.
OpenRTB support is response-side parsing only.
The SDK does not currently build or POST OpenRTB bid requests.

## Package structure

**Core:**

- `SDKConfig`
- `Callbacks`
- `Constants`
- `SKAdNetworkManager`

**Networking:**

- `URLBuilder`
- `NetworkManager`
- `DeviceInfo`

**Views:**

- `ImageAdView`
- `BannerAdView`
- `NativeAdView`
- `VideoAdView`
- `VideoInterstitial/*`

**OpenRTB:**

- `OpenRTBVideoObjectParser`
- `OpenRTBPoddedResponseNormalizer`
- `PoddedPlaybackPlanBuilder`
- `VastPodComposer`
- `VideoAdPayloadResolver`

## Topics

### Getting Started

- <doc:Installation>
- <doc:Initialization>

### Ad Formats

- <doc:ImageAds>
- <doc:BannerAds>
- <doc:NativeAds>
- <doc:VideoAds>

### Advanced Video

- <doc:OpenRTB-2.6-Podded-Video>

### Platform Features

- <doc:Callbacks>
- <doc:SKAdNetwork>
- <doc:Troubleshooting>
