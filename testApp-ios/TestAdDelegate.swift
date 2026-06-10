import bidscubeSdk
import Foundation

final class TestAdDelegate: AdCallback, ConsentCallback {
    func onAdLoading(_ placementId: String) {
        print("[TestAdDelegate] loading: \(placementId)")
    }

    func onAdLoaded(_ placementId: String) {
        print("[TestAdDelegate] loaded: \(placementId)")
    }

    func onAdDisplayed(_ placementId: String) {
        print("[TestAdDelegate] displayed: \(placementId)")
    }

    func onAdClicked(_ placementId: String) {
        print("[TestAdDelegate] clicked: \(placementId)")
    }

    func onAdClosed(_ placementId: String) {
        print("[TestAdDelegate] closed: \(placementId)")
    }

    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String) {
        print("[TestAdDelegate] failed: \(placementId) \(errorCode) \(errorMessage)")
    }

    func onVideoAdStarted(_ placementId: String) {
        print("[TestAdDelegate] video started: \(placementId)")
    }

    func onVideoAdCompleted(_ placementId: String) {
        print("[TestAdDelegate] video completed: \(placementId)")
    }

    func onVideoAdSkipped(_ placementId: String) {
        print("[TestAdDelegate] video skipped: \(placementId)")
    }

    func onVideoAdSkippable(_ placementId: String) {
        print("[TestAdDelegate] video skippable: \(placementId)")
    }

    func onEndCardShown(_ placementId: String) {
        print("[TestAdDelegate] end card shown: \(placementId)")
    }

    func onConsentInfoUpdated() {}
    func onConsentInfoUpdateFailed(_ error: Error) {}
    func onConsentFormShown() {}
    func onConsentFormError(_ error: Error) {}
    func onConsentGranted() {}
    func onConsentDenied() {}
    func onConsentNotRequired() {}
    func onConsentStatusChanged(_ hasConsent: Bool) {}
}
