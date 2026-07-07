# Release 1.2.5 — Summary

**Version:** 1.2.5  
**Tag:** `v1.2.5`  
**Focus:** OpenRTB 2.6-style podded video response parsing (response-side only)

## Highlights

- OpenRTB-like pod metadata: `openrtb.video`, `openRtb.video`, root `video`, `bids[]`, `seatbid[].bid[]`
- Shared `VideoAdPayloadResolver` for video interstitial, inline, and `VideoAdView`
- Multi-slot inline VAST composition for IMA playback
- Optional `SDKConfig` pod flags (`openRtbPodMetadataEnabled`, validation mode, skip policy)
- SPM/CocoaPods packaging excludes demo/test Swift files from production SDK
- Unit tests for normalizer, plan builder, resolver, and VAST composer

## Not in scope

- Full OpenRTB 2.6 bid-request POST client (`OpenRTBBidRequestBuilder` remains placeholder)
- Legacy GET ad request flow unchanged (`c=v`, `m=xml`)

## Sign-off

- [ ] `xcodebuild build -target bidscubeSdk`
- [ ] `xcodebuild build -target bidscubeSdkTests`
- [ ] Video interstitial QA (companion / no companion)
- [ ] Legacy root `adm` + raw VAST still work
- [ ] Podded OpenRTB fixture smoke test on staging placement

See also [release-1.2.4.md](release-1.2.4.md) for video interstitial UX rules.
