import Foundation

/// SKAdNetwork configuration helper for Info.plist
public struct SKAdNetworkConfig {
    
    /// Common SKAdNetwork identifiers for popular ad networks
    public static let commonAdNetworkIds = [
        // Google Ads
        "cstr6suwn9.skadnetwork",
        "4fzdc2evr5.skadnetwork",
        "t38b2kh725.skadnetwork",
        "hs6bdukanm.skadnetwork",
        "prcb7njmu6.skadnetwork",
        "v72qych5uu.skadnetwork",
        "ludvb6z3bs.skadnetwork",
        "cp8zw746q7.skadnetwork",
        "3sh42y64q3.skadnetwork",
        "3qy4746246.skadnetwork",
        "f38h382jlk.skadnetwork",
        "24t9a8vw3c.skadnetwork",
        "6xzpu9s2p5.skadnetwork",
        "9rd848q2bz.skadnetwork",
        "y5ghdn5j9k.skadnetwork",
        "n6fk4nfna4.skadnetwork",
        "v9wttpbfk9.skadnetwork",
        "n38lu8286q.skadnetwork",
        "47vhws6wlr.skadnetwork",
        "kbd757ywx3.skadnetwork",
        "9t245vhmpl.skadnetwork",
        "eh6m2bh4zr.skadnetwork",
        "a2p9lx4jpn.skadnetwork",
        "22mmun2rn5.skadnetwork",
        "4468km3ulz.skadnetwork",
        "2u9pt9hc89.skadnetwork",
        "8s468mfl3y.skadnetwork",
        "klf5c3l5u5.skadnetwork",
        "ppxm28t8ap.skadnetwork",
        "ecpz2srf59.skadnetwork",
        "uw77j35x4d.skadnetwork",
        "p78axxw29g.skadnetwork",
        "mlmmfzh3r3.skadnetwork",
        "578prtvx9j.skadnetwork",
        "4dzt52r2t5.skadnetwork",
        "e5fvkxwrpn.skadnetwork",
        "8c4e2ghe7u.skadnetwork",
        "zq492l623r.skadnetwork",
        "3rd42ekr43.skadnetwork",
        "3qcr597p9d.skadnetwork",
        
        // Facebook/Meta
        "v9wttpbfk9.skadnetwork",
        "n38lu8286q.skadnetwork",
        "47vhws6wlr.skadnetwork",
        "kbd757ywx3.skadnetwork",
        "9t245vhmpl.skadnetwork",
        "eh6m2bh4zr.skadnetwork",
        "a2p9lx4jpn.skadnetwork",
        "22mmun2rn5.skadnetwork",
        "4468km3ulz.skadnetwork",
        "2u9pt9hc89.skadnetwork",
        "8s468mfl3y.skadnetwork",
        "klf5c3l5u5.skadnetwork",
        "ppxm28t8ap.skadnetwork",
        "ecpz2srf59.skadnetwork",
        "uw77j35x4d.skadnetwork",
        "p78axxw29g.skadnetwork",
        "mlmmfzh3r3.skadnetwork",
        "578prtvx9j.skadnetwork",
        "4dzt52r2t5.skadnetwork",
        "e5fvkxwrpn.skadnetwork",
        "8c4e2ghe7u.skadnetwork",
        "zq492l623r.skadnetwork",
        "3rd42ekr43.skadnetwork",
        "3qcr597p9d.skadnetwork",
        
        // Unity Ads
        "4fzdc2evr5.skadnetwork",
        "t38b2kh725.skadnetwork",
        "hs6bdukanm.skadnetwork",
        "prcb7njmu6.skadnetwork",
        "v72qych5uu.skadnetwork",
        "ludvb6z3bs.skadnetwork",
        "cp8zw746q7.skadnetwork",
        "3sh42y64q3.skadnetwork",
        "3qy4746246.skadnetwork",
        "f38h382jlk.skadnetwork",
        "24t9a8vw3c.skadnetwork",
        "6xzpu9s2p5.skadnetwork",
        "9rd848q2bz.skadnetwork",
        "y5ghdn5j9k.skadnetwork",
        "n6fk4nfna4.skadnetwork",
        "v9wttpbfk9.skadnetwork",
        "n38lu8286q.skadnetwork",
        "47vhws6wlr.skadnetwork",
        "kbd757ywx3.skadnetwork",
        "9t245vhmpl.skadnetwork",
        "eh6m2bh4zr.skadnetwork",
        "a2p9lx4jpn.skadnetwork",
        "22mmun2rn5.skadnetwork",
        "4468km3ulz.skadnetwork",
        "2u9pt9hc89.skadnetwork",
        "8s468mfl3y.skadnetwork",
        "klf5c3l5u5.skadnetwork",
        "ppxm28t8ap.skadnetwork",
        "ecpz2srf59.skadnetwork",
        "uw77j35x4d.skadnetwork",
        "p78axxw29g.skadnetwork",
        "mlmmfzh3r3.skadnetwork",
        "578prtvx9j.skadnetwork",
        "4dzt52r2t5.skadnetwork",
        "e5fvkxwrpn.skadnetwork",
        "8c4e2ghe7u.skadnetwork",
        "zq492l623r.skadnetwork",
        "3rd42ekr43.skadnetwork",
        "3qcr597p9d.skadnetwork",
        
        // AppLovin
        "ludvb6z3bs.skadnetwork",
        "cp8zw746q7.skadnetwork",
        "3sh42y64q3.skadnetwork",
        "3qy4746246.skadnetwork",
        "f38h382jlk.skadnetwork",
        "24t9a8vw3c.skadnetwork",
        "6xzpu9s2p5.skadnetwork",
        "9rd848q2bz.skadnetwork",
        "y5ghdn5j9k.skadnetwork",
        "n6fk4nfna4.skadnetwork",
        "v9wttpbfk9.skadnetwork",
        "n38lu8286q.skadnetwork",
        "47vhws6wlr.skadnetwork",
        "kbd757ywx3.skadnetwork",
        "9t245vhmpl.skadnetwork",
        "eh6m2bh4zr.skadnetwork",
        "a2p9lx4jpn.skadnetwork",
        "22mmun2rn5.skadnetwork",
        "4468km3ulz.skadnetwork",
        "2u9pt9hc89.skadnetwork",
        "8s468mfl3y.skadnetwork",
        "klf5c3l5u5.skadnetwork",
        "ppxm28t8ap.skadnetwork",
        "ecpz2srf59.skadnetwork",
        "uw77j35x4d.skadnetwork",
        "p78axxw29g.skadnetwork",
        "mlmmfzh3r3.skadnetwork",
        "578prtvx9j.skadnetwork",
        "4dzt52r2t5.skadnetwork",
        "e5fvkxwrpn.skadnetwork",
        "8c4e2ghe7u.skadnetwork",
        "zq492l623r.skadnetwork",
        "3rd42ekr43.skadnetwork",
        "3qcr597p9d.skadnetwork"
    ]
    
    /// Generate Info.plist SKAdNetworkItems configuration
    /// - Returns: Array of SKAdNetworkItems for Info.plist
    public static func generateInfoPlistConfig() -> [[String: String]] {
        return commonAdNetworkIds.map { adNetworkId in
            return [
                "SKAdNetworkIdentifier": adNetworkId
            ]
        }
    }
    
    /// Generate Info.plist SKAdNetworkItems configuration for specific ad networks
    /// - Parameter adNetworkIds: Array of specific ad network IDs to include
    /// - Returns: Array of SKAdNetworkItems for Info.plist
    public static func generateInfoPlistConfig(for adNetworkIds: [String]) -> [[String: String]] {
        return adNetworkIds.map { adNetworkId in
            return [
                "SKAdNetworkIdentifier": adNetworkId
            ]
        }
    }
    
    /// Validate SKAdNetwork identifier format
    /// - Parameter adNetworkId: The ad network identifier to validate
    /// - Returns: True if the identifier is valid
    public static func isValidAdNetworkId(_ adNetworkId: String) -> Bool {
        // SKAdNetwork identifiers should be in format: xxxxxx.skadnetwork
        let pattern = "^[a-z0-9]{10}\\.skadnetwork$"
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let range = NSRange(location: 0, length: adNetworkId.utf16.count)
        return regex?.firstMatch(in: adNetworkId, options: [], range: range) != nil
    }
    
    /// Get recommended SKAdNetwork identifiers for your app
    /// - Returns: Array of recommended ad network IDs
    public static func getRecommendedAdNetworkIds() -> [String] {
        return [
            "cstr6suwn9.skadnetwork", // Google Ads
            "v9wttpbfk9.skadnetwork", // Facebook/Meta
            "4fzdc2evr5.skadnetwork", // Unity Ads
            "ludvb6z3bs.skadnetwork", // AppLovin
            "t38b2kh725.skadnetwork", // IronSource
            "hs6bdukanm.skadnetwork", // Vungle
            "prcb7njmu6.skadnetwork", // Chartboost
            "v72qych5uu.skadnetwork", // AdColony
            "cp8zw746q7.skadnetwork", // MoPub
            "3sh42y64q3.skadnetwork"  // Tapjoy
        ]
    }
}
