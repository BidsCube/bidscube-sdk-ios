import Foundation

enum PoddedPlaybackPlanBuilder {

    private static let logPrefix = "OpenRTB"

    static func build(
        from response: OpenRTBPoddedResponse,
        config: SDKConfig?
    ) -> VideoPlaybackPlan? {
        let validationMode = config?.videoPodDurationValidationMode ?? .lenient
        let sorted = sortMarkups(response.markups)
        var podType = response.podContext.type

        Logger.info("Building playback plan: podType=\(podType), markups=\(sorted.count)", prefix: logPrefix)

        var candidates = sorted.flatMap { makeCandidates(from: $0) }
        guard !candidates.isEmpty else {
            Logger.warning("No playable candidates after markup inspection", prefix: logPrefix)
            return nil
        }

        if candidates.count > 1 && podType == .single {
            podType = .structured
            candidates = sortCandidates(candidates)
            Logger.debug("Expanded multi-ad markup into \(candidates.count) candidates", prefix: logPrefix)
        }

        switch podType {
        case .single:
            candidates = Array(candidates.prefix(1))
        case .unknown:
            candidates = sortCandidates(candidates)
        case .structured:
            candidates = applyStructuredSelection(candidates, context: response.podContext, mode: validationMode)
        case .dynamic:
            candidates = applyDynamicSelection(candidates, context: response.podContext, mode: validationMode)
        case .hybrid:
            candidates = applyHybridSelection(candidates, context: response.podContext, mode: validationMode)
        }

        guard !candidates.isEmpty else {
            if validationMode == .strict {
                Logger.warning("Strict validation removed all pod slots", prefix: logPrefix)
            }
            return nil
        }

        if let maxSeq = response.podContext.maxSeq, candidates.count > maxSeq {
            Logger.debug("Trimming to maxseq=\(maxSeq)", prefix: logPrefix)
            candidates = Array(candidates.prefix(maxSeq))
        }

        let slots = candidates.enumerated().map { index, candidate in
            VideoPlaybackSlot(
                adm: candidate.adm,
                adTagUrl: candidate.adTagUrl,
                vastXml: candidate.vastXml,
                slotIndex: index,
                slotInPod: candidate.slotInPod,
                durationSeconds: candidate.durationSeconds,
                metadata: candidate.metadata
            )
        }

        Logger.info("Selected \(slots.count) playback slot(s)", prefix: logPrefix)
        let context = OpenRTBPodContext(
            podId: response.podContext.podId,
            podSeq: response.podContext.podSeq,
            podDurSeconds: response.podContext.podDurSeconds,
            rqddursSeconds: response.podContext.rqddursSeconds,
            maxSeq: response.podContext.maxSeq,
            minCpmPerSec: response.podContext.minCpmPerSec,
            type: podType
        )
        return VideoPlaybackPlan(podContext: context, slots: slots)
    }

    private struct Candidate {
        let adm: String
        let adTagUrl: String?
        let vastXml: String?
        let slotInPod: Int?
        let vastSequence: Int?
        let durationSeconds: Int?
        let responseOrder: Int
        let metadata: VideoInterstitialMetadata
    }

    private static func makeCandidates(from markup: OpenRTBAdMarkup) -> [Candidate] {
        let trimmed = markup.adm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        if VastAdSequenceParser.isAdTagURL(trimmed) {
            return [Candidate(
                adm: trimmed,
                adTagUrl: trimmed,
                vastXml: nil,
                slotInPod: markup.slotInPod,
                vastSequence: markup.vastSequence,
                durationSeconds: markup.durationSeconds,
                responseOrder: markup.responseOrder,
                metadata: VideoInterstitialMetadata()
            )]
        }

        if VastAdSequenceParser.contentLikelyContainsVAST(trimmed) {
            let adNodes = VastAdSequenceParser.extractAdNodes(from: trimmed)
            if adNodes.count > 1 {
                Logger.debug("Single ADM contains \(adNodes.count) VAST ads; using VAST sequence fallback", prefix: logPrefix)
                return adNodes.enumerated().map { index, node in
                    Candidate(
                        adm: node,
                        adTagUrl: nil,
                        vastXml: node,
                        slotInPod: nil,
                        vastSequence: VastAdSequenceParser.firstAdSequence(from: node) ?? (index + 1),
                        durationSeconds: VastAdSequenceParser.firstLinearDurationSeconds(from: node),
                        responseOrder: markup.responseOrder + index,
                        metadata: VastMetadataParser.parse(node)
                    )
                }
            }
            return [Candidate(
                adm: trimmed,
                adTagUrl: nil,
                vastXml: trimmed,
                slotInPod: markup.slotInPod,
                vastSequence: markup.vastSequence ?? VastAdSequenceParser.firstAdSequence(from: trimmed),
                durationSeconds: markup.durationSeconds ?? VastAdSequenceParser.firstLinearDurationSeconds(from: trimmed),
                responseOrder: markup.responseOrder,
                metadata: VastMetadataParser.parse(trimmed)
            )]
        }

        return []
    }

    private static func sortMarkups(_ markups: [OpenRTBAdMarkup]) -> [OpenRTBAdMarkup] {
        markups.enumerated().sorted { lhs, rhs in
            let leftSlot = lhs.element.slotInPod ?? Int.max
            let rightSlot = rhs.element.slotInPod ?? Int.max
            if leftSlot != rightSlot { return leftSlot < rightSlot }
            let leftSeq = lhs.element.vastSequence ?? Int.max
            let rightSeq = rhs.element.vastSequence ?? Int.max
            if leftSeq != rightSeq { return leftSeq < rightSeq }
            return lhs.element.responseOrder < rhs.element.responseOrder
        }.map(\.element)
    }

    private static func applyStructuredSelection(
        _ candidates: [Candidate],
        context: OpenRTBPodContext,
        mode: OpenRTBPodDurationValidationMode
    ) -> [Candidate] {
        var selected = candidates
        if !context.rqddursSeconds.isEmpty {
            selected = selected.filter { candidate in
                guard let duration = candidate.durationSeconds else { return mode == .lenient }
                let matches = context.rqddursSeconds.contains(duration)
                if !matches {
                    Logger.warning("Slot duration \(duration)s not in rqddurs \(context.rqddursSeconds)", prefix: logPrefix)
                }
                return mode == .lenient ? true : matches
            }
        }
        return selected
    }

    private static func applyDynamicSelection(
        _ candidates: [Candidate],
        context: OpenRTBPodContext,
        mode: OpenRTBPodDurationValidationMode
    ) -> [Candidate] {
        guard let budget = context.podDurSeconds else { return candidates }
        var remaining = budget
        var selected: [Candidate] = []

        for candidate in candidates {
            guard let duration = candidate.durationSeconds else {
                if mode == .lenient {
                    selected.append(candidate)
                }
                continue
            }
            if duration > budget {
                Logger.warning("Skipping slot duration \(duration)s exceeding poddur \(budget)s", prefix: logPrefix)
                continue
            }
            if duration <= remaining {
                selected.append(candidate)
                remaining -= duration
            } else if mode == .lenient {
                Logger.debug("Slot duration \(duration)s exceeds remaining budget \(remaining)s", prefix: logPrefix)
            }
            if remaining <= 0 { break }
        }

        return selected
    }

    private static func applyHybridSelection(
        _ candidates: [Candidate],
        context: OpenRTBPodContext,
        mode: OpenRTBPodDurationValidationMode
    ) -> [Candidate] {
        let fixed = candidates.filter { $0.slotInPod != nil }
        let dynamicPool = candidates.filter { $0.slotInPod == nil }
        var selected = applyStructuredSelection(fixed, context: context, mode: mode)

        guard let budget = context.podDurSeconds else { return selected + dynamicPool }
        let used = selected.compactMap(\.durationSeconds).reduce(0, +)
        var remaining = max(budget - used, 0)

        for candidate in dynamicPool {
            guard let duration = candidate.durationSeconds else {
                if mode == .lenient { selected.append(candidate) }
                continue
            }
            if duration <= remaining {
                selected.append(candidate)
                remaining -= duration
            }
            if remaining <= 0 { break }
        }

        return sortCandidates(selected)
    }

    private static func sortCandidates(_ candidates: [Candidate]) -> [Candidate] {
        candidates.enumerated().sorted { lhs, rhs in
            let leftSlot = lhs.element.slotInPod ?? Int.max
            let rightSlot = rhs.element.slotInPod ?? Int.max
            if leftSlot != rightSlot { return leftSlot < rightSlot }
            let leftSeq = lhs.element.vastSequence ?? Int.max
            let rightSeq = rhs.element.vastSequence ?? Int.max
            if leftSeq != rightSeq { return leftSeq < rightSeq }
            return lhs.element.responseOrder < rhs.element.responseOrder
        }.map(\.element)
    }
}
