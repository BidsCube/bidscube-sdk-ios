import Foundation

enum VastPodComposer {

    private static let logPrefix = "OpenRTB"

    static func compose(from slots: [VideoPlaybackSlot]) -> String? {
        guard !slots.isEmpty else { return nil }
        guard slots.count > 1 else {
            let single = slots[0].vastXml ?? slots[0].adm
            return VastAdSequenceParser.wrapInVastDocumentIfNeeded(single)
        }

        let urlSlots = slots.filter { $0.adTagUrl != nil }
        let xmlSlots = slots.filter { $0.vastXml != nil }

        if !urlSlots.isEmpty && !xmlSlots.isEmpty {
            Logger.warning("Mixed URL/XML pod composition unsupported; using first URL slot only", prefix: logPrefix)
            return urlSlots.first?.adTagUrl
        }

        if !urlSlots.isEmpty {
            Logger.warning("Multiple URL pod slots unsupported; using first URL slot only", prefix: logPrefix)
            return urlSlots.first?.adTagUrl
        }

        var adNodes: [String] = []
        for (index, slot) in xmlSlots.enumerated() {
            guard let vastXml = slot.vastXml else { continue }
            let nodes = VastAdSequenceParser.extractAdNodes(from: vastXml)
            if nodes.isEmpty {
                Logger.warning("No <Ad> node in slot \(index); skipping", prefix: logPrefix)
                continue
            }
            for node in nodes {
                let sequence = slot.slotInPod ?? (index + 1)
                adNodes.append(VastAdSequenceParser.assignSequence(to: node, sequence: sequence))
            }
        }

        guard !adNodes.isEmpty else {
            Logger.warning("VAST pod composition failed; falling back to first slot", prefix: logPrefix)
            return xmlSlots.first?.vastXml ?? xmlSlots.first?.adm
        }

        let body = adNodes.joined(separator: "\n")
        return """
        <VAST version="3.0">
        \(body)
        </VAST>
        """
    }
}
