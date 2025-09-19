import Foundation
import UIKit
import AdSupport

public struct DeviceInfo {
    
    public static var bundleId: String {
        Bundle.main.bundleIdentifier ?? "com.unknown.app"
    }
    
    public static var appName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Unknown App"
    }
    
    public static var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0"
    }
    
    public static var appStoreURL: String {
        if let appStoreURL = Bundle.main.object(forInfoDictionaryKey: "AppStoreURL") as? String {
            return appStoreURL
        }
        
        return "https://apps.apple.com"
    }
    
    public static var deviceWidth: Int {
        Int(UIScreen.main.bounds.width * UIScreen.main.scale)
    }
    
    public static var deviceHeight: Int {
        Int(UIScreen.main.bounds.height * UIScreen.main.scale)
    }
    
    public static var language: String {
        Locale.preferredLanguages.first ?? "en"
    }
    
    public static var userAgent: String {
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        let appName = self.appName
        let appVersion = self.appVersion
        
        return "\(appName)/\(appVersion) (iOS \(systemVersion); \(model))"
    }
    
    public static var isTrackingEnabled: Bool {
        if #available(iOS 14, *) {
            return ASIdentifierManager.shared().isAdvertisingTrackingEnabled
        } else {
            return true
        }
    }
    
    public static var advertisingIdentifier: String {
        guard isTrackingEnabled else {
            return "12345678-1234-1234-1234-123456789012"
        }
        
        return ASIdentifierManager.shared().advertisingIdentifier.uuidString
    }
    
    public static var doNotTrack: Int {
        return isTrackingEnabled ? 0 : 1
    }
    
    public static var gdpr: String {
        let euCountries = ["AT", "BE", "BG", "HR", "CY", "CZ", "DK", "EE", "FI", "FR", "DE", "GR", "HU", "IE", "IT", "LV", "LT", "LU", "MT", "NL", "PL", "PT", "RO", "SK", "SI", "ES", "SE"]
        let currentCountry = Locale.current.regionCode ?? ""
        return euCountries.contains(currentCountry) ? "1" : "0"
    }
    
    public static var gdprConsent: String {
        return "0"
    }
    
    public static var usPrivacy: String {
        return "1---"
    }
    
    public static var ccpa: String {
        return "0"
    }
    
    public static var coppa: String {
        return "0"
    }
    
    public static var networkType: String {
        return "wifi" 
    }
    
    public static var debugInfo: [String: Any] {
        return [
            "bundleId": bundleId,
            "appName": appName,
            "appVersion": appVersion,
            "deviceWidth": deviceWidth,
            "deviceHeight": deviceHeight,
            "language": language,
            "userAgent": userAgent,
            "trackingEnabled": isTrackingEnabled,
            "advertisingId": advertisingIdentifier,
            "doNotTrack": doNotTrack,
            "systemVersion": UIDevice.current.systemVersion,
            "deviceModel": UIDevice.current.model
        ]
    }
}
