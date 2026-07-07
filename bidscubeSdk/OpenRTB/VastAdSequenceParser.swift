import Foundation

enum VastAdSequenceParser {

    static func contentLikelyContainsVAST(_ content: String) -> Bool {
        content.range(of: "<VAST", options: .caseInsensitive) != nil
    }

    static func firstAdSequence(from vastXml: String) -> Int? {
        guard let adTag = firstMatch(in: vastXml, pattern: "<Ad[^>]*>", options: [.caseInsensitive]) else {
            return nil
        }
        return sequenceFromAdTag(adTag)
    }

    static func firstLinearDurationSeconds(from vastXml: String) -> Int? {
        guard let duration = firstMatch(in: vastXml, pattern: "<Duration[^>]*>([\\s\\S]*?)</Duration>", options: [.caseInsensitive]) else {
            return nil
        }
        return VastMetadataParser.parseVastDurationToSeconds(cleanText(duration))
    }

    static func extractAdNodes(from vastXml: String) -> [String] {
        guard let regex = try? NSRegularExpression(pattern: "<Ad[^>]*>[\\s\\S]*?</Ad>", options: [.caseInsensitive]) else {
            return []
        }
        let range = NSRange(vastXml.startIndex..<vastXml.endIndex, in: vastXml)
        return regex.matches(in: vastXml, options: [], range: range).compactMap { match in
            guard let fullRange = Range(match.range(at: 0), in: vastXml) else { return nil }
            return String(vastXml[fullRange])
        }
    }

    static func isAdTagURL(_ adm: String) -> Bool {
        let trimmed = adm.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.hasPrefix("http://") || trimmed.hasPrefix("https://")
    }

    static func wrapInVastDocumentIfNeeded(_ content: String) -> String {
        if contentLikelyContainsVAST(content) {
            return content
        }
        return """
        <VAST version="3.0">
        \(content)
        </VAST>
        """
    }

    static func assignSequence(to adNode: String, sequence: Int) -> String {
        if adNode.range(of: "sequence\\s*=\\s*\"[^\"]*\"", options: [.regularExpression, .caseInsensitive]) != nil {
            return adNode.replacingOccurrences(
                of: "sequence\\s*=\\s*\"[^\"]*\"",
                with: "sequence=\"\(sequence)\"",
                options: [.regularExpression, .caseInsensitive]
            )
        }
        if let range = adNode.range(of: "<Ad", options: .caseInsensitive) {
            let insertIndex = adNode.index(range.upperBound, offsetBy: 0)
            return String(adNode[..<insertIndex]) + " sequence=\"\(sequence)\"" + String(adNode[insertIndex...])
        }
        return adNode
    }

    private static func sequenceFromAdTag(_ adTag: String) -> Int? {
        guard let value = firstMatch(in: adTag, pattern: "sequence\\s*=\\s*\"([^\"]+)\"", options: [.caseInsensitive]) else {
            return nil
        }
        return Int(value.trimmingCharacters(in: .whitespacesAndNewlines))
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
