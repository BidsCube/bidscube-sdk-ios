import Foundation

enum OpenRTBVideoObjectParser {

    static func findVideoObject(in root: [String: Any]) -> [String: Any]? {
        if let openrtb = root["openrtb"] as? [String: Any],
           let video = openrtb["video"] as? [String: Any] {
            return video
        }

        if let openRtb = root["openRtb"] as? [String: Any],
           let video = openRtb["video"] as? [String: Any] {
            return video
        }

        if let video = root["video"] as? [String: Any] {
            return video
        }

        return nil
    }

    static func intValue(_ value: Any?) -> Int? {
        switch value {
        case let int as Int:
            return int
        case let double as Double:
            return double.isFinite ? Int(double) : nil
        case let string as String:
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return nil }
            if trimmed.contains(":") {
                return VastMetadataParser.parseVastDurationToSeconds(trimmed)
            }
            if let int = Int(trimmed) {
                return int
            }
            if let double = Double(trimmed), double.isFinite {
                return Int(double)
            }
            return nil
        case let number as NSNumber:
            let double = number.doubleValue
            return double.isFinite ? Int(double) : nil
        default:
            return nil
        }
    }

    static func doubleValue(_ value: Any?) -> Double? {
        switch value {
        case let double as Double:
            return double.isFinite ? double : nil
        case let int as Int:
            return Double(int)
        case let string as String:
            guard let double = Double(string.trimmingCharacters(in: .whitespacesAndNewlines)) else {
                return nil
            }
            return double.isFinite ? double : nil
        case let number as NSNumber:
            let double = number.doubleValue
            return double.isFinite ? double : nil
        default:
            return nil
        }
    }

    static func stringValue(_ value: Any?) -> String? {
        switch value {
        case let string as String:
            let trimmed = string.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : trimmed
        case let int as Int:
            return String(int)
        case let double as Double:
            return String(double)
        case let number as NSNumber:
            return number.stringValue
        default:
            return nil
        }
    }

    static func intArrayValue(_ value: Any?) -> [Int] {
        if let array = value as? [Int] {
            return array
        }
        if let array = value as? [Double] {
            return array.compactMap { $0.isFinite ? Int($0) : nil }
        }
        if let array = value as? [String] {
            return array.compactMap { intValue($0) }
        }
        if let array = value as? [Any] {
            return array.compactMap { intValue($0) }
        }
        if let single = intValue(value) {
            return [single]
        }
        return []
    }

    static func dictionaryValue(_ value: Any?) -> [String: Any]? {
        value as? [String: Any]
    }
}
