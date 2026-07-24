# Release 1.2.6 — Summary

**Version:** 1.2.6  
**Tag:** `v1.2.6`  
**Focus:** Publisher `user_id` on ad requests

## Highlights

- `SDKConfig.Builder().userId(_:)` — optional publisher user identifier
- Sent to SSP as GET query parameter **`user_id`** on all ad formats (image, banner, native, video)
- Empty/whitespace-only values are omitted from requests
- DocC and internal documentation updates

## Sign-off

- [ ] `xcodebuild build -target bidscubeSdk`
- [ ] Video interstitial smoke test on simulator
- [ ] Verify ad request URL contains `user_id=` when configured

See [release-1.2.5.md](release-1.2.5.md) for OpenRTB podded video details.
