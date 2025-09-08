import Foundation
import UIKit

public final class SDKConfig {
    public let enableLogging: Bool
    public let enableDebugMode: Bool
    public let defaultAdTimeoutMs: Int
    public let defaultAdPosition: AdPosition

    private init(enableLogging: Bool,
                 enableDebugMode: Bool,
                 defaultAdTimeoutMs: Int,
                 defaultAdPosition: AdPosition) {
        self.enableLogging = enableLogging
        self.enableDebugMode = enableDebugMode
        self.defaultAdTimeoutMs = defaultAdTimeoutMs
        self.defaultAdPosition = defaultAdPosition
    }

    public final class Builder {
        private var enableLogging: Bool = true
        private var enableDebugMode: Bool = false
        private var defaultAdTimeoutMs: Int = 30000
        private var defaultAdPosition: AdPosition = .unknown

        public init() {}

        @discardableResult
        public func enableLogging(_ value: Bool) -> Builder {
            self.enableLogging = value
            return self
        }

        @discardableResult
        public func enableDebugMode(_ value: Bool) -> Builder {
            self.enableDebugMode = value
            return self
        }

        @discardableResult
        public func defaultAdTimeout(_ millis: Int) -> Builder {
            self.defaultAdTimeoutMs = millis
            return self
        }

        @discardableResult
        public func defaultAdPosition(_ position: AdPosition) -> Builder {
            self.defaultAdPosition = position
            return self
        }

        public func build() -> SDKConfig {
            SDKConfig(
                enableLogging: enableLogging,
                enableDebugMode: enableDebugMode,
                defaultAdTimeoutMs: defaultAdTimeoutMs,
                defaultAdPosition: defaultAdPosition
            )
        }
    }

    public static var detectedAppId: String {
        Bundle.main.bundleIdentifier ?? ""
    }

    public static var detectedAppName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String ?? ""
    }

    public static var detectedAppVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? ""
        let build = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? ""
        return build.isEmpty ? version : "\(version) (\(build))"
    }

    public static var detectedLanguage: String {
        Locale.preferredLanguages.first ?? Locale.current.identifier
    }

    public static var detectedUserAgent: String {
        let systemVersion = UIDevice.current.systemVersion
        let model = UIDevice.current.model
        return "BidscubeSDK-iOS/1.0 (iOS \(systemVersion); \(model))"
    }
}


