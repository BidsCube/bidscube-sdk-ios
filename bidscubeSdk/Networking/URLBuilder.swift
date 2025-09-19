import Foundation
import UIKit


public struct URLBuilder {
    
    
    
    
    
    
    
    
    
    
    
    
    public static func buildAdRequestURL(placementId: String,
                                        adType: AdType,
                                        position: AdPosition,
                                        timeoutMs: Int,
                                        debug: Bool,
                                        ctaText: String? = nil) -> URL? {
        return buildAdRequestURL(base: Constants.baseURL,
                                placementId: placementId,
                                adType: adType,
                                position: position,
                                timeoutMs: timeoutMs,
                                debug: debug,
                                ctaText: ctaText)
    }
    
    
    
    
    
    
    
    
    
    
    
    public static func buildAdRequestURL(base: String,
                                        placementId: String,
                                        adType: AdType,
                                        position: AdPosition,
                                        timeoutMs: Int,
                                        debug: Bool,
                                        ctaText: String? = nil) -> URL? {
        guard var components = URLComponents(string: base) else {
            logError("Failed to create URL components from base: \(base)")
            return nil
        }
        
        var queryItems = buildCommonQueryItems(placementId: placementId, adType: adType)
        queryItems.append(contentsOf: buildAdTypeSpecificQueryItems(adType: adType, placementId: placementId))
        queryItems.append(contentsOf: buildPrivacyQueryItems())
        
        if let ctaText = ctaText {
            queryItems.append(URLQueryItem(name: Constants.QueryParams.ctaText, value: ctaText))
        }
        
        components.queryItems = queryItems
        
        guard let finalURL = components.url else {
            logError("Failed to construct final URL")
            return nil
        }
        
        logSuccess("Built \(adType.rawValue) ad URL: \(finalURL.absoluteString)")
        return finalURL
    }
    
    
    
    private static func buildCommonQueryItems(placementId: String, adType: AdType) -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        
        items.append(URLQueryItem(name: Constants.QueryParams.app, value: "1"))
        items.append(URLQueryItem(name: Constants.QueryParams.bundle, value: DeviceInfo.bundleId))
        items.append(URLQueryItem(name: Constants.QueryParams.name, value: DeviceInfo.appName))
        items.append(URLQueryItem(name: Constants.QueryParams.appStoreURL, value: DeviceInfo.appStoreURL))
        items.append(URLQueryItem(name: Constants.QueryParams.userAgent, value: DeviceInfo.userAgent))
        items.append(URLQueryItem(name: Constants.QueryParams.advertisingId, value: DeviceInfo.advertisingIdentifier))
        items.append(URLQueryItem(name: Constants.QueryParams.doNotTrack, value: String(DeviceInfo.doNotTrack)))
        
        return items
    }
    
    private static func buildAdTypeSpecificQueryItems(adType: AdType, placementId: String) -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        switch adType {
        case .image:
            items.append(URLQueryItem(name: Constants.QueryParams.placementId, value: placementId))
            items.append(URLQueryItem(name: Constants.QueryParams.contentType, value: Constants.AdTypes.image))
            items.append(URLQueryItem(name: Constants.QueryParams.method, value: Constants.Methods.api))
            items.append(URLQueryItem(name: Constants.QueryParams.response, value: Constants.ResponseFormats.js))
            items.append(URLQueryItem(name: Constants.QueryParams.language, value: DeviceInfo.language))
            items.append(URLQueryItem(name: Constants.QueryParams.deviceWidth, value: String(DeviceInfo.deviceWidth)))
            items.append(URLQueryItem(name: Constants.QueryParams.deviceHeight, value: String(DeviceInfo.deviceHeight)))
            
        case .video:
            items.append(URLQueryItem(name: Constants.QueryParams.id, value: placementId))
            items.append(URLQueryItem(name: Constants.QueryParams.contentType, value: Constants.AdTypes.video))
            items.append(URLQueryItem(name: Constants.QueryParams.method, value: Constants.Methods.xml))
            items.append(URLQueryItem(name: Constants.QueryParams.width, value: String(DeviceInfo.deviceWidth)))
            items.append(URLQueryItem(name: Constants.QueryParams.height, value: String(DeviceInfo.deviceHeight)))
            items.append(URLQueryItem(name: Constants.QueryParams.appVersion, value: DeviceInfo.appVersion))
            
        case .native:
            items.append(URLQueryItem(name: Constants.QueryParams.placementId, value: placementId))
            items.append(URLQueryItem(name: Constants.QueryParams.contentType, value: Constants.AdTypes.native))
            items.append(URLQueryItem(name: Constants.QueryParams.method, value: Constants.Methods.api))
            items.append(URLQueryItem(name: Constants.QueryParams.response, value: Constants.ResponseFormats.json))
            items.append(URLQueryItem(name: Constants.QueryParams.language, value: DeviceInfo.language))
            items.append(URLQueryItem(name: Constants.QueryParams.deviceWidth, value: String(DeviceInfo.deviceWidth)))
            items.append(URLQueryItem(name: Constants.QueryParams.deviceHeight, value: String(DeviceInfo.deviceHeight)))
        }
        
        return items
    }
    
    private static func buildPrivacyQueryItems() -> [URLQueryItem] {
        var items: [URLQueryItem] = []
        
        
        items.append(URLQueryItem(name: Constants.Privacy.gdprKey, value: DeviceInfo.gdpr))
        items.append(URLQueryItem(name: Constants.Privacy.gdprConsentKey, value: DeviceInfo.gdprConsent))
        items.append(URLQueryItem(name: Constants.Privacy.usPrivacyKey, value: DeviceInfo.usPrivacy))
        items.append(URLQueryItem(name: Constants.Privacy.ccpaKey, value: DeviceInfo.ccpa))
        items.append(URLQueryItem(name: Constants.Privacy.coppaKey, value: DeviceInfo.coppa))
        
        return items
    }
    
    
    
    private static func logSuccess(_ message: String) {
        Logger.urlBuilder(message)
    }
    
    private static func logError(_ message: String) {
        Logger.error(message, prefix: Constants.LogPrefixes.urlBuilder)
    }
}







