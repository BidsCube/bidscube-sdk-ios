import Foundation
import UIKit

struct URLBuilder {
    static func buildAdRequestURL(base: String,
                                  placementId: String,
                                  adType: AdType,
                                  position: AdPosition,
                                  timeoutMs: Int,
                                  debug: Bool,
                                  ctaText: String? = nil) -> URL? {
        var components = URLComponents(string: base)
        if var path = components?.path {
            if !path.hasSuffix("/") { path += "/" }
            path += adType.pathSegment
            components?.path = path
        }
        var items: [URLQueryItem] = []

        items.append(URLQueryItem(name: "placement_id", value: placementId))
        items.append(URLQueryItem(name: "ad_type", value: adType.rawValue))
        items.append(URLQueryItem(name: "timeout_ms", value: String(timeoutMs)))
        items.append(URLQueryItem(name: "position", value: String(position.rawValue)))
        items.append(URLQueryItem(name: "sdk", value: "ios"))
        items.append(URLQueryItem(name: "sdk_version", value: "1.0"))

        switch adType {
        case .video:
            items.append(URLQueryItem(name: "skippable", value: "0"))
        case .skippableVideo:
            items.append(URLQueryItem(name: "skippable", value: "1"))
            if let ctaText, !ctaText.isEmpty { items.append(URLQueryItem(name: "cta", value: ctaText)) }
        case .image:
            break
        case .native:
            items.append(URLQueryItem(name: "native_format", value: "openrtb_v1"))
        }

        items.append(URLQueryItem(name: "app_id", value: SDKConfig.detectedAppId))
        items.append(URLQueryItem(name: "app_name", value: SDKConfig.detectedAppName))
        items.append(URLQueryItem(name: "app_version", value: SDKConfig.detectedAppVersion))
        items.append(URLQueryItem(name: "lang", value: SDKConfig.detectedLanguage))
        items.append(URLQueryItem(name: "ua", value: SDKConfig.detectedUserAgent))

        items.append(URLQueryItem(name: "consent_required", value: BidscubeSDK.isConsentRequired() ? "1" : "0"))
        items.append(URLQueryItem(name: "consent_ads", value: BidscubeSDK.hasAdsConsent() ? "1" : "0"))
        items.append(URLQueryItem(name: "consent_analytics", value: BidscubeSDK.hasAnalyticsConsent() ? "1" : "0"))

        if debug { items.append(URLQueryItem(name: "debug", value: "1")) }

        components?.queryItems = items
        return components?.url
    }
}


