#!/usr/bin/env bash
# Build testApp-ios and install+launch on a booted Simulator.
# Usage:
#   ./scripts/sim-build-run.sh        # prefers iPhone 17 Pro when both booted
#   ./scripts/sim-build-run.sh 16e   # uses iPhone 16e when booted
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

pick_udid_matching() {
  local sub="$1"
  local line ud
  while IFS= read -r line; do
    [[ "$line" == *"(Booted)"* ]] || continue
    [[ -z "$sub" ]] || [[ "$line" == *"$sub"* ]] || continue
    ud="$(echo "$line" | grep -Eo '[0-9A-F]{8}-([0-9A-F]{4}-){3}[0-9A-F]{12}' | head -1)"
    if [[ -n "$ud" ]]; then
      echo "$ud"
      return 0
    fi
  done < <(xcrun simctl list devices booted)
  return 1
}

BOOTED_UDID=""
case "${1:-}" in
  16*|16e)
    BOOTED_UDID="$(pick_udid_matching "16e" || true)"
    if [[ -z "${BOOTED_UDID:-}" ]]; then
      echo "iPhone 16e is not booted. Boot it first, or omit the argument to use iPhone 17 Pro."
      exit 1
    fi
    ;;
  *)
    BOOTED_UDID="$(pick_udid_matching "iPhone 17 Pro" || true)"
    if [[ -z "${BOOTED_UDID:-}" ]]; then
      BOOTED_UDID="$(pick_udid_matching "" || true)"
    fi
    ;;
esac

if [[ -z "${BOOTED_UDID:-}" ]]; then
  echo "No booted simulator found. Open Simulator, boot iPhone 16e or iPhone 17 Pro, then rerun."
  exit 1
fi

DEST="platform=iOS Simulator,id=${BOOTED_UDID}"
DD="$ROOT/build/DerivedData-simrun"
APP="$DD/Build/Products/Debug-iphonesimulator/testApp-ios.app"
BUNDLE_ID="com.bidscube.ios.testApp"

echo "→ Simulator UDID: $BOOTED_UDID"
echo "→ Destination:    $DEST"

xcodebuild -workspace bidscubeSdk.xcworkspace \
  -scheme testApp-ios \
  -configuration Debug \
  -derivedDataPath "$DD" \
  -destination "$DEST" \
  build

if [[ ! -d "$APP" ]]; then
  echo "Built .app not found at: $APP"
  exit 1
fi

xcrun simctl install "$BOOTED_UDID" "$APP"
xcrun simctl launch "$BOOTED_UDID" "$BUNDLE_ID"
echo "→ Launched $BUNDLE_ID on $BOOTED_UDID"
