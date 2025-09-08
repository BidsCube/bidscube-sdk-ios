import Foundation
import UIKit

public final class BidscubeSDK {
    private static var configuration: SDKConfig?
    private static var manualAdPosition: AdPosition?
    private static var responseAdPosition: AdPosition = .unknown
    private static var consentRequired: Bool = false
    private static var hasAdsConsentFlag: Bool = false
    private static var hasAnalyticsConsentFlag: Bool = false
    private static var consentDebugDeviceId: String?

    // Initialization
    public static func initialize(config: SDKConfig) {
        self.configuration = config
    }

    private static func createOnMainThread<T>(_ make: () -> T) -> T {
        if Thread.isMainThread {
            return make()
        } else {
            var result: T!
            DispatchQueue.main.sync {
                result = make()
            }
            return result
        }
    }

    public static func isInitialized() -> Bool {
        return configuration != nil
    }

    public static func cleanup() {
        configuration = nil
        manualAdPosition = nil
        responseAdPosition = .unknown
        consentRequired = false
        hasAdsConsentFlag = false
        hasAnalyticsConsentFlag = false
        consentDebugDeviceId = nil
    }

    // Ad Positioning
    public static func setAdPosition(_ position: AdPosition) {
        manualAdPosition = position
    }

    public static func getCurrentAdPosition() -> AdPosition? {
        return manualAdPosition
    }

    public static func getResponseAdPosition() -> AdPosition {
        return responseAdPosition
    }

    public static func getEffectiveAdPosition() -> AdPosition {
        return manualAdPosition ?? responseAdPosition
    }

    public static func requestConsentInfoUpdate(callback: ConsentCallback) {
        // emulate async update
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            callback.onConsentInfoUpdated()
        }
    }

    public static func showConsentForm(_ callback: ConsentCallback) {
        // Stubbed: fake form then grant
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            callback.onConsentFormShown()
            self.hasAdsConsentFlag = true
            self.hasAnalyticsConsentFlag = true
            callback.onConsentGranted()
            callback.onConsentStatusChanged(true)
        }
    }

    public static func enableConsentDebugMode(_ testDeviceId: String) {
        consentDebugDeviceId = testDeviceId
    }

    public static func resetConsent() {
        hasAdsConsentFlag = false
        hasAnalyticsConsentFlag = false
        consentRequired = false
    }

    public static func isConsentRequired() -> Bool {
        return consentRequired
    }

    public static func hasAdsConsent() -> Bool {
        return hasAdsConsentFlag
    }

    public static func hasAnalyticsConsent() -> Bool {
        return hasAnalyticsConsentFlag
    }

    public static func getConsentStatusSummary() -> String {
        return "required=\(consentRequired), ads=\(hasAdsConsentFlag), analytics=\(hasAnalyticsConsentFlag)"
    }

    // Ad URL Builder
    public static func buildRequestURL(base: String, placementId: String, adType: AdType, ctaText: String? = nil) -> URL? {
        let config = configuration
        let timeout = config?.defaultAdTimeoutMs ?? 30_000
        let debug = config?.enableDebugMode ?? false
        let position = getEffectiveAdPosition()
        return URLBuilder.buildAdRequestURL(
            base: base,
            placementId: placementId,
            adType: adType,
            position: position,
            timeoutMs: timeout,
            debug: debug,
            ctaText: ctaText
        )
    }
    public static func showImageAd(_ placementId: String, _ callback: AdCallback?) {
        callback?.onAdLoading(placementId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.responseAdPosition = .unknown
            callback?.onAdLoaded(placementId)
            callback?.onAdDisplayed(placementId)
        }
    }

    public static func getImageAdView(_ placementId: String, _ callback: AdCallback?) -> UIView {
        let view = createOnMainThread { ImageAdView() }
        showImageAd(placementId, callback)
        return view
    }

    public static func showVideoAd(_ placementId: String, _ callback: AdCallback?) {
        callback?.onAdLoading(placementId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.responseAdPosition = .fullScreen
            callback?.onAdLoaded(placementId)
            callback?.onAdDisplayed(placementId)
            callback?.onVideoAdStarted(placementId)
            callback?.onVideoAdCompleted(placementId)
        }
    }

    public static func showSkippableVideoAd(_ placementId: String, _ ctaText: String, _ callback: AdCallback?) {
        callback?.onAdLoading(placementId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.responseAdPosition = .fullScreen
            callback?.onAdLoaded(placementId)
            callback?.onAdDisplayed(placementId)
            callback?.onVideoAdSkippable(placementId)
            callback?.onInstallButtonClicked(placementId, buttonText: ctaText)
        }
    }

    public static func getVideoAdView(_ placementId: String, _ callback: AdCallback?) -> UIView {
        let view = createOnMainThread { VideoAdView() }
        showVideoAd(placementId, callback)
        return view
    }

    public static func showNativeAd(_ placementId: String, _ callback: AdCallback?) {
        callback?.onAdLoading(placementId)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.responseAdPosition = .unknown
            callback?.onAdLoaded(placementId)
            callback?.onAdDisplayed(placementId)
        }
    }

    public static func getNativeAdView(_ placementId: String, _ callback: AdCallback?) -> UIView {
        let view: NativeAdView = createOnMainThread { NativeAdView() }
        showNativeAd(placementId, callback)
        return view
    }
}


