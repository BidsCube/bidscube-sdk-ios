import Foundation

public protocol AdCallback: AnyObject {
    func onAdLoading(_ placementId: String)
    func onAdLoaded(_ placementId: String)
    func onAdDisplayed(_ placementId: String)
    func onAdClicked(_ placementId: String)
    func onAdClosed(_ placementId: String)
    func onAdFailed(_ placementId: String, errorCode: Int, errorMessage: String)

    func onVideoAdStarted(_ placementId: String)
    func onVideoAdCompleted(_ placementId: String)
    func onVideoAdSkipped(_ placementId: String)
    func onVideoAdSkippable(_ placementId: String)
    func onInstallButtonClicked(_ placementId: String, buttonText: String)
}

public extension AdCallback {
    func onVideoAdStarted(_ placementId: String) {}
    func onVideoAdCompleted(_ placementId: String) {}
    func onVideoAdSkipped(_ placementId: String) {}
    func onVideoAdSkippable(_ placementId: String) {}
    func onInstallButtonClicked(_ placementId: String, buttonText: String) {}
}

public protocol ConsentCallback: AnyObject {
    func onConsentInfoUpdated()
    func onConsentInfoUpdateFailed(_ error: Error)
    func onConsentFormShown()
    func onConsentFormError(_ error: Error)
    func onConsentGranted()
    func onConsentDenied()
    func onConsentNotRequired()
    func onConsentStatusChanged(_ hasConsent: Bool)
}


