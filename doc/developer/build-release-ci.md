# Build, Release & CI

How to build, version, tag, and publish the SDK.

---

## Version sources of truth

All must match before release:

| File | Field |
|------|-------|
| `bidscubeSdk/Core/Constants.swift` | `sdkVersion = "X.Y.Z"` |
| `bidscubeSdk.podspec` | `spec.version = "X.Y.Z"` |
| `README.md` / `doc/README.md` | Current version and install snippets |
| Git tag | `vX.Y.Z` |

Helper script (optional):
```bash
./scripts/update-version.sh 1.2.5
```
Review diff manually — script also adds generic changelog line.

---

## Local build checklist

```bash
cd bidscube-sdk-ios
pod install

# Framework
xcodebuild -workspace bidscubeSdk.xcworkspace \
  -scheme bidscubeSdk \
  -destination 'generic/platform=iOS Simulator' \
  build

# Test app
xcodebuild -workspace bidscubeSdk.xcworkspace \
  -scheme testApp-ios \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build

# Podspec lint
pod spec lint bidscubeSdk.podspec --allow-warnings --verbose
```

---

## Git release workflow

See [`RELEASE.md`](../../RELEASE.md) for full checklist.

```bash
./scripts/update-version.sh 1.2.5

git commit -m "release: bidscubeSdk 1.2.5"
git tag -a v1.2.5 -m "bidscubeSdk 1.2.5"
git push origin main
git push origin v1.2.5
```

Or use placeholders:

```bash
VERSION=1.2.5
./scripts/update-version.sh "$VERSION"
git commit -m "release: bidscubeSdk $VERSION"
git tag -a "v$VERSION" -m "bidscubeSdk $VERSION"
git push origin main
git push origin "v$VERSION"
```

---

## GitHub Actions — `publish.yml`

**Trigger:** push tag matching `v*`

### Job 1: `publish-cocoapods` (Ubuntu)

1. Extract version from tag (strip `v`)
2. Update podspec + Constants.swift via sed
3. Skip if version already on CocoaPods trunk
4. `pod spec lint --allow-warnings`
5. `pod trunk push` with `COCOAPODS_TRUNK_TOKEN` secret

### Job 2: `publish-spm` (macOS)

1. Validate `Package.swift` resolves
2. Create GitHub Release with install snippets

### Job 3: `notify`

Success notification.

**Environment:** `bidscube_env` on GitHub.

---

## Distribution channels

| Channel | Consumer action |
|---------|-----------------|
| **SPM** | `.package(url: "…", from: "1.2.5")` |
| **CocoaPods** | `pod 'bidscubeSdk', '~> 1.2.5'` |
| **MAX adapter** | Separately distributed Bidscube MAX mediation adapter; pulls `bidscubeSdk` transitively when configured — do not duplicate the SDK pod |

Tag must exist on GitHub before CocoaPods trunk validation succeeds (podspec `source.tag`).

---

## Framework vs published minimum iOS

| | iOS |
|--|-----|
| podspec / Package.swift | 13.0 |
| Xcode project targets | 14.0 |

When dropping iOS 13, update all three consistently.

---

## Excluded from framework build

`project.pbxproj` synchronized group excludes demo/test views:
- `ContentView.swift`, `SDKTestView.swift`, `ConsentTestView.swift`, etc.

Video interstitial module is **included** in framework.

---

## Post-release

1. Verify GitHub Release created
2. `pod search bidscubeSdk` — shows new version
3. Notify adapter team if minimum SDK version changes
4. Update Flutter/other platform wrappers if applicable

---

## Rollback

CocoaPods versions cannot be deleted easily. If bad release:
1. Ship **1.2.6** fix forward
2. Yank only as last resort via CocoaPods trunk (requires owner)
