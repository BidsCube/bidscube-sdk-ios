import Foundation

enum VastMetadataParser {

    static func parse(_ vastXml: String) -> VideoInterstitialMetadata {
        let trimmed = vastXml.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            return VideoInterstitialMetadata()
        }

        let companionImage = extractCompanionImageUrl(from: trimmed)
        let companionClick = extractCompanionClickThrough(from: trimmed)
        let videoClick = extractVideoClickThrough(from: trimmed)
        let parsedSkip = extractSkipOffsetSeconds(from: trimmed)

        let resolvedClickString = firstNonEmpty(companionClick, videoClick)
        let resolvedClickUrl = resolvedClickString.flatMap { URL(string: $0) } ?? VideoInterstitialDefaults.clickUrl
        let parsedPreviewUrl = companionImage.flatMap { URL(string: $0) }
        let hasCompanionPreview = parsedPreviewUrl != nil
        let resolvedSkip: Int
        if hasCompanionPreview {
            resolvedSkip = parsedSkip > 0 ? parsedSkip : VideoInterstitialDefaults.skipOffsetSeconds
        } else {
            resolvedSkip = 0
        }

        return VideoInterstitialMetadata(
            previewImageUrl: parsedPreviewUrl,
            clickUrl: resolvedClickUrl,
            skipOffsetSeconds: resolvedSkip
        )
    }

    static func extractCompanionImageUrl(from vastXml: String) -> String? {
        guard let companionBlock = firstMatch(in: vastXml, pattern: "<Companion[^>]*>[\\s\\S]*?</Companion>", options: [.caseInsensitive]) else {
            return nil
        }
        return firstMatch(in: companionBlock, pattern: "<StaticResource[^>]*>([\\s\\S]*?)</StaticResource>", options: [.caseInsensitive])
            .map(cleanText)
    }

    static func extractCompanionClickThrough(from vastXml: String) -> String? {
        guard let companionBlock = firstMatch(in: vastXml, pattern: "<Companion[^>]*>[\\s\\S]*?</Companion>", options: [.caseInsensitive]) else {
            return nil
        }
        return firstMatch(in: companionBlock, pattern: "<CompanionClickThrough[^>]*>([\\s\\S]*?)</CompanionClickThrough>", options: [.caseInsensitive])
            .map(cleanText)
    }

    static func extractVideoClickThrough(from vastXml: String) -> String? {
        if let videoClicksBlock = firstMatch(in: vastXml, pattern: "<VideoClicks[^>]*>[\\s\\S]*?</VideoClicks>", options: [.caseInsensitive]),
           let url = firstMatch(in: videoClicksBlock, pattern: "<ClickThrough[^>]*>([\\s\\S]*?)</ClickThrough>", options: [.caseInsensitive]) {
            return cleanText(url)
        }
        if let url = firstMatch(in: vastXml, pattern: "<ClickThrough[^>]*>([\\s\\S]*?)</ClickThrough>", options: [.caseInsensitive]) {
            return cleanText(url)
        }
        return nil
    }

    static func extractSkipOffsetSeconds(from vastXml: String) -> Int {
        guard let linearTag = firstMatch(in: vastXml, pattern: "<Linear[^>]*>", options: [.caseInsensitive]) else {
            return 0
        }
        guard let skipValue = firstMatch(in: linearTag, pattern: "skipoffset\\s*=\\s*\"([^\"]+)\"", options: [.caseInsensitive]) else {
            return 0
        }
        return parseVastDurationToSeconds(skipValue)
    }

    static func parseVastDurationToSeconds(_ value: String) -> Int {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return 0 }

        if trimmed.contains(":") {
            let parts = trimmed.split(separator: ":").map(String.init)
            if parts.count == 3,
               let hours = Int(parts[0]),
               let minutes = Int(parts[1]),
               let seconds = Double(parts[2]) {
                return hours * 3600 + minutes * 60 + Int(floor(seconds))
            }
            if parts.count == 2,
               let minutes = Int(parts[0]),
               let seconds = Double(parts[1]) {
                return minutes * 60 + Int(floor(seconds))
            }
            return 0
        }

        if let numeric = Double(trimmed) {
            return Int(floor(numeric))
        }
        return 0
    }

    private static func firstNonEmpty(_ primary: String?, _ fallback: String?) -> String? {
        if let primary, !primary.isEmpty { return primary }
        if let fallback, !fallback.isEmpty { return fallback }
        return nil
    }

    private static func firstMatch(in text: String, pattern: String, options: NSRegularExpression.Options = []) -> String? {
        guard let regex = try? NSRegularExpression(pattern: pattern, options: options) else { return nil }
        let range = NSRange(text.startIndex..<text.endIndex, in: text)
        guard let match = regex.firstMatch(in: text, options: [], range: range) else { return nil }

        if match.numberOfRanges > 1, let captureRange = Range(match.range(at: 1), in: text) {
            return String(text[captureRange])
        }
        if let fullRange = Range(match.range(at: 0), in: text) {
            return String(text[fullRange])
        }
        return nil
    }

    private static func cleanText(_ raw: String) -> String {
        var value = raw
        if value.hasPrefix("<![CDATA[") && value.hasSuffix("]]>") {
            value = String(value.dropFirst(9).dropLast(3))
        }
        return value.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
