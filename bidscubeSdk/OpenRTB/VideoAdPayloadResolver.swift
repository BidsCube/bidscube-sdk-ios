import Foundation

enum VideoAdPayloadResolver {

    private static let logPrefix = "OpenRTB"

    struct ResolvedPayload {
        let playbackPlan: VideoPlaybackPlan?
        let metadata: VideoInterstitialMetadata
        let adTagUrl: String?
        let adsResponse: String?
        let vastXml: String?
    }

    static func resolve(content: String, config: SDKConfig?) -> ResolvedPayload? {
        let trimmed = content.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        if let jsonData = trimmed.data(using: .utf8),
           let json = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
            applyResponsePosition(from: json)

            if config?.openRtbPodMetadataEnabled ?? true,
               OpenRTBPoddedResponseNormalizer.isOpenRTBLike(json: json),
               let podded = OpenRTBPoddedResponseNormalizer.normalize(json: json),
               let plan = PoddedPlaybackPlanBuilder.build(from: podded, config: config),
               !plan.slots.isEmpty {
                Logger.info("Resolved OpenRTB podded playback plan with \(plan.slots.count) slot(s)", prefix: logPrefix)
                return resolve(plan: plan)
            }

            if let legacy = resolveLegacyJSON(json: json) {
                Logger.debug("Resolved legacy JSON ADM/VAST payload", prefix: logPrefix)
                return legacy
            }
        }

        if VastAdSequenceParser.contentLikelyContainsVAST(trimmed) {
            Logger.debug("Resolved raw VAST XML payload", prefix: logPrefix)
            return ResolvedPayload(
                playbackPlan: nil,
                metadata: VastMetadataParser.parse(trimmed),
                adTagUrl: nil,
                adsResponse: trimmed,
                vastXml: trimmed
            )
        }

        return nil
    }

    private static func resolve(plan: VideoPlaybackPlan) -> ResolvedPayload? {
        guard let first = plan.slots.first else { return nil }
        let metadata = first.metadata

        if plan.slots.count == 1 {
            if let url = first.adTagUrl {
                return ResolvedPayload(playbackPlan: plan, metadata: metadata, adTagUrl: url, adsResponse: nil, vastXml: first.vastXml)
            }
            if let vast = first.vastXml {
                return ResolvedPayload(playbackPlan: plan, metadata: metadata, adTagUrl: nil, adsResponse: vast, vastXml: vast)
            }
            return nil
        }

        if let composed = VastPodComposer.compose(from: plan.slots) {
            if VastAdSequenceParser.isAdTagURL(composed) {
                return ResolvedPayload(playbackPlan: plan, metadata: metadata, adTagUrl: composed, adsResponse: nil, vastXml: nil)
            }
            return ResolvedPayload(playbackPlan: plan, metadata: metadata, adTagUrl: nil, adsResponse: composed, vastXml: composed)
        }

        Logger.warning("Pod composition failed; falling back to first slot", prefix: logPrefix)
        return resolve(plan: VideoPlaybackPlan(podContext: plan.podContext, slots: [first]))
    }

    private static func resolveLegacyJSON(json: [String: Any]) -> ResolvedPayload? {
        guard let adm = OpenRTBVideoObjectParser.stringValue(json["adm"]) else { return nil }
        let trimmedAdm = adm.trimmingCharacters(in: .whitespacesAndNewlines)

        if VastAdSequenceParser.isAdTagURL(trimmedAdm) {
            return ResolvedPayload(
                playbackPlan: nil,
                metadata: VideoInterstitialMetadata(),
                adTagUrl: trimmedAdm,
                adsResponse: nil,
                vastXml: nil
            )
        }

        if VastAdSequenceParser.contentLikelyContainsVAST(trimmedAdm) {
            return ResolvedPayload(
                playbackPlan: nil,
                metadata: VastMetadataParser.parse(trimmedAdm),
                adTagUrl: nil,
                adsResponse: trimmedAdm,
                vastXml: trimmedAdm
            )
        }

        return nil
    }

    private static func applyResponsePosition(from json: [String: Any]) {
        if let positionValue = OpenRTBVideoObjectParser.intValue(json["position"]),
           let position = AdPosition(rawValue: positionValue) {
            BidscubeSDK.setResponseAdPosition(position)
        }
    }
}
