import Foundation
import StoreKit

/// Manager for handling SKAdNetwork attribution and conversion tracking
@available(iOS 14.0, *)
public class SKAdNetworkManager {
    
    // MARK: - Properties
    
    private static var isRegistered = false
    private static var currentConversionValue: Int = 0
    private static var maxConversionValue: Int = 63
    
    // MARK: - Public Methods
    
    /// Register the app for ad network attribution
    /// This should be called at app launch
    public static func registerForAdNetworkAttribution() {
        guard !isRegistered else {
            Logger.info("SKAdNetwork already registered")
            return
        }
        
        SKAdNetwork.registerAppForAdNetworkAttribution()
        isRegistered = true
        Logger.info("SKAdNetwork registered for attribution")
    }
    
    /// Update the conversion value for post-install attribution
    /// - Parameter value: Conversion value (0-63)
    public static func updateConversionValue(_ value: Int) {
        let clampedValue = max(0, min(value, maxConversionValue))
        
        guard clampedValue > currentConversionValue else {
            Logger.debug("Conversion value \(clampedValue) not higher than current \(currentConversionValue)")
            return
        }
        
        SKAdNetwork.updateConversionValue(clampedValue)
        currentConversionValue = clampedValue
        Logger.info("SKAdNetwork conversion value updated to \(clampedValue)")
    }
    
    /// Get the current conversion value
    public static func getCurrentConversionValue() -> Int {
        return currentConversionValue
    }
    
    /// Reset conversion value (useful for testing)
    public static func resetConversionValue() {
        currentConversionValue = 0
        Logger.info("SKAdNetwork conversion value reset")
    }
    
    /// Check if SKAdNetwork is available
    public static func isAvailable() -> Bool {
        return true
    }
    
    /// Get SKAdNetwork attribution status
    public static func getAttributionStatus() -> String {
        return isRegistered ? "registered" : "not_registered"
    }
    
    // MARK: - Conversion Value Helpers
    
    /// Update conversion value for ad impression
    public static func trackAdImpression() {
        updateConversionValue(currentConversionValue + 1)
    }
    
    /// Update conversion value for ad click
    public static func trackAdClick() {
        updateConversionValue(currentConversionValue + 2)
    }
    
    /// Update conversion value for app install
    public static func trackAppInstall() {
        updateConversionValue(currentConversionValue + 5)
    }
    
    /// Update conversion value for in-app purchase
    public static func trackInAppPurchase() {
        updateConversionValue(currentConversionValue + 10)
    }
    
    /// Update conversion value for subscription
    public static func trackSubscription() {
        updateConversionValue(currentConversionValue + 15)
    }
}

// MARK: - Pre-iOS 14 Compatibility

/// Fallback implementation for iOS versions before 14.0
public class SKAdNetworkManagerLegacy {
    
    public static func registerForAdNetworkAttribution() {
        Logger.info("SKAdNetwork not available on this iOS version")
    }
    
    public static func updateConversionValue(_ value: Int) {
        Logger.info("SKAdNetwork not available on this iOS version")
    }
    
    public static func getCurrentConversionValue() -> Int {
        return 0
    }
    
    public static func resetConversionValue() {
        Logger.info("SKAdNetwork not available on this iOS version")
    }
    
    public static func isAvailable() -> Bool {
        return false
    }
    
    public static func getAttributionStatus() -> String {
        return "not_available"
    }
    
    public static func trackAdImpression() {
        Logger.info("SKAdNetwork not available on this iOS version")
    }
    
    public static func trackAdClick() {
        Logger.info("SKAdNetwork not available on this iOS version")
    }
    
    public static func trackAppInstall() {
        Logger.info("SKAdNetwork not available on this iOS version")
    }
    
    public static func trackInAppPurchase() {
        Logger.info("SKAdNetwork not available on this iOS version")
    }
    
    public static func trackSubscription() {
        Logger.info("SKAdNetwork not available on this iOS version")
    }
}
