import Foundation
import os

/// `os.Logger` is iOS 14+; SDK minimum is iOS 13 — use `print` everywhere and unified logging only when available.
class SDKLogger {
    private static var isLoggingEnabled = true
    private static let logSubsystem = "com.bidscube.sdk"
    private static let logCategory = "SDK"

    @available(iOS 14.0, tvOS 14.0, watchOS 7.0, *)
    private static func write(_ level: String, tag: String, message: String) {
        let logger = os.Logger(subsystem: logSubsystem, category: logCategory)
        let line = "[\(tag)] \(message)"
        switch level {
        case "debug": logger.debug("\(line)")
        case "info": logger.info("\(line)")
        case "warning": logger.warning("\(line)")
        case "error": logger.error("\(line)")
        default: logger.debug("\(line)")
        }
    }

    static func setLoggingEnabled(_ enabled: Bool) {
        isLoggingEnabled = enabled
    }

    static func d(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            write("debug", tag: tag, message: message)
        }
        print("🔍 [DEBUG] [\(tag)] \(message)")
    }

    static func i(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            write("info", tag: tag, message: message)
        }
        print("Info: [INFO] [\(tag)] \(message)")
    }

    static func w(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            write("warning", tag: tag, message: message)
        }
        print("⚠️ [WARNING] [\(tag)] \(message)")
    }

    static func e(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            write("error", tag: tag, message: message)
        }
        print("Error: [ERROR] [\(tag)] \(message)")
    }

    static func v(_ tag: String, _ message: String) {
        guard isLoggingEnabled else { return }
        if #available(iOS 14.0, tvOS 14.0, watchOS 7.0, *) {
            write("debug", tag: tag, message: message)
        }
        print("📝 [VERBOSE] [\(tag)] \(message)")
    }
}
