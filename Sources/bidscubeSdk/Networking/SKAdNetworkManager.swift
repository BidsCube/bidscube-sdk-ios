import Foundation
import StoreKit

/// SKAdNetwork manager for handling ad attribution
public final class SKAdNetworkManager {
    
    // MARK: - Properties
    
    private static let shared = SKAdNetworkManager()
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Register SKAdNetwork for ad attribution
    /// - Parameters:
    ///   - adNetworkId: The SKAdNetwork identifier
    ///   - completion: Completion handler with success status
    public static func registerAdNetwork(_ adNetworkId: String, completion: @escaping (Bool) -> Void) {
        guard #available(iOS 14.0, *) else {
            print("SKAdNetwork: iOS 14.0+ required")
            completion(false)
            return
        }
        
        // Register the ad network
        SKAdNetwork.registerAppForAdNetworkAttribution()
        
        // Log the registration
        print("SKAdNetwork: Registered ad network: \(adNetworkId)")
        completion(true)
    }
    
    /// Update conversion value for SKAdNetwork
    /// - Parameters:
    ///   - conversionValue: The conversion value (0-63)
    ///   - completion: Completion handler with success status
    public static func updateConversionValue(_ conversionValue: Int, completion: @escaping (Bool) -> Void) {
        guard #available(iOS 15.4, *) else {
            print("SKAdNetwork: iOS 15.4+ required for conversion value updates")
            completion(false)
            return
        }
        
        guard conversionValue >= 0 && conversionValue <= 63 else {
            print("SKAdNetwork: Conversion value must be between 0-63")
            completion(false)
            return
        }
        
        // Update conversion value
        SKAdNetwork.updateConversionValue(conversionValue)
        
        print("SKAdNetwork: Updated conversion value to: \(conversionValue)")
        completion(true)
    }
    
    /// Update conversion value with coarse value
    /// - Parameters:
    ///   - conversionValue: The conversion value (0-63)
    ///   - coarseValue: The coarse value (low, medium, high)
    ///   - completion: Completion handler with success status
    public static func updateConversionValue(_ conversionValue: Int, coarseValue: SKAdNetwork.CoarseConversionValue, completion: @escaping (Bool) -> Void) {
        guard #available(iOS 16.1, *) else {
            print("SKAdNetwork: iOS 16.1+ required for coarse conversion values")
            completion(false)
            return
        }
        
        guard conversionValue >= 0 && conversionValue <= 63 else {
            print("SKAdNetwork: Conversion value must be between 0-63")
            completion(false)
            return
        }
        
        // Update conversion value with coarse value
        SKAdNetwork.updateConversionValue(conversionValue, coarseValue: coarseValue)
        
        print("SKAdNetwork: Updated conversion value to: \(conversionValue), coarse: \(coarseValue)")
        completion(true)
    }
    
    /// Check if SKAdNetwork is available
    /// - Returns: True if SKAdNetwork is available
    public static func isAvailable() -> Bool {
        if #available(iOS 14.0, *) {
            return true
        }
        return false
    }
    
    /// Get SKAdNetwork attribution data
    /// - Parameter completion: Completion handler with attribution data
    public static func getAttributionData(completion: @escaping ([String: Any]?) -> Void) {
        guard #available(iOS 14.0, *) else {
            print("SKAdNetwork: iOS 14.0+ required")
            completion(nil)
            return
        }
        
        // This would typically be handled by the app, not the SDK
        // The SDK can provide helper methods for the app to use
        print("SKAdNetwork: Attribution data should be handled by the app")
        completion(nil)
    }
}

// MARK: - SKAdNetwork Extensions

extension SKAdNetworkManager {
    
    /// Predefined conversion values for common ad events
    public enum ConversionValue: Int, CaseIterable {
        case adView = 1
        case adClick = 2
        case adInteraction = 3
        case purchase = 10
        case subscription = 20
        case levelComplete = 30
        case achievement = 40
        case tutorialComplete = 50
        case highValue = 60
        
        public var description: String {
            switch self {
            case .adView: return "Ad View"
            case .adClick: return "Ad Click"
            case .adInteraction: return "Ad Interaction"
            case .purchase: return "Purchase"
            case .subscription: return "Subscription"
            case .levelComplete: return "Level Complete"
            case .achievement: return "Achievement"
            case .tutorialComplete: return "Tutorial Complete"
            case .highValue: return "High Value"
            }
        }
    }
    
    /// Track ad events with SKAdNetwork
    /// - Parameters:
    ///   - event: The ad event to track
    ///   - completion: Completion handler with success status
    public static func trackAdEvent(_ event: ConversionValue, completion: @escaping (Bool) -> Void) {
        updateConversionValue(event.rawValue) { success in
            if success {
                print("SKAdNetwork: Tracked ad event: \(event.description)")
            }
            completion(success)
        }
    }
}
