import Foundation

enum OpenRTBPoddedResponseNormalizer {

    private static let logPrefix = "OpenRTB"

    static func normalize(json root: [String: Any]) -> OpenRTBPoddedResponse? {
        let videoObject = OpenRTBVideoObjectParser.findVideoObject(in: root)
        var markups = collectMarkups(from: root, videoObject: videoObject)

        if markups.isEmpty, let rootAdm = usableAdm(from: root["adm"]) {
            markups = [makeMarkup(adm: rootAdm, bid: root, ext: nil, videoObject: videoObject, order: 0)]
        }

        markups = markups.filter { isUsableAdm($0.adm) }
        guard !markups.isEmpty else {
            Logger.debug("No usable ADM in OpenRTB-like response", prefix: logPrefix)
            return nil
        }

        markups = dedupePodGroups(markups)
        let podContext = buildPodContext(from: root, videoObject: videoObject, markups: markups)

        Logger.info("Parsed OpenRTB response: \(markups.count) bid(s), podId=\(podContext.podId ?? "nil")", prefix: logPrefix)
        return OpenRTBPoddedResponse(podContext: podContext, markups: markups)
    }

    static func isOpenRTBLike(json root: [String: Any]) -> Bool {
        if OpenRTBVideoObjectParser.findVideoObject(in: root) != nil { return true }
        if root["bids"] is [Any] { return true }
        if root["seatbid"] is [Any] { return true }
        if let adm = root["adm"] as? String, !adm.isEmpty,
           OpenRTBVideoObjectParser.findVideoObject(in: root) != nil {
            return true
        }
        return false
    }

    private static func collectMarkups(from root: [String: Any], videoObject: [String: Any]?) -> [OpenRTBAdMarkup] {
        var results: [OpenRTBAdMarkup] = []
        var order = 0

        if let bids = root["bids"] as? [[String: Any]] {
            Logger.debug("Detected root bids[] shape", prefix: logPrefix)
            for bid in bids {
                guard let adm = usableAdm(from: bid["adm"]) else { continue }
                results.append(makeMarkup(adm: adm, bid: bid, ext: nil, videoObject: videoObject, order: order))
                order += 1
            }
        }

        if let seatbid = root["seatbid"] as? [[String: Any]] {
            Logger.debug("Detected seatbid[].bid[] shape", prefix: logPrefix)
            for seat in seatbid {
                guard let bids = seat["bid"] as? [[String: Any]] else { continue }
                for bid in bids {
                    guard let adm = usableAdm(from: bid["adm"]) else { continue }
                    let ext = OpenRTBVideoObjectParser.dictionaryValue(bid["ext"])
                    results.append(makeMarkup(adm: adm, bid: bid, ext: ext, videoObject: videoObject, order: order))
                    order += 1
                }
            }
        }

        return results
    }

    private static func makeMarkup(
        adm: String,
        bid: [String: Any],
        ext: [String: Any]?,
        videoObject: [String: Any]?,
        order: Int
    ) -> OpenRTBAdMarkup {
        let mergedExt = ext ?? OpenRTBVideoObjectParser.dictionaryValue(bid["ext"])
        let slotInPod = OpenRTBVideoObjectParser.intValue(bid["slotinpod"])
            ?? OpenRTBVideoObjectParser.intValue(bid["slotInPod"])
            ?? OpenRTBVideoObjectParser.intValue(mergedExt?["slotinpod"])
            ?? OpenRTBVideoObjectParser.intValue(mergedExt?["slotInPod"])

        let duration = OpenRTBVideoObjectParser.intValue(bid["duration"])
            ?? OpenRTBVideoObjectParser.intValue(mergedExt?["duration"])
            ?? (VastAdSequenceParser.contentLikelyContainsVAST(adm) ? VastAdSequenceParser.firstLinearDurationSeconds(from: adm) : nil)

        let podId = OpenRTBVideoObjectParser.stringValue(bid["podid"])
            ?? OpenRTBVideoObjectParser.stringValue(bid["podId"])
            ?? OpenRTBVideoObjectParser.stringValue(mergedExt?["podid"])
            ?? OpenRTBVideoObjectParser.stringValue(videoObject?["podid"])
            ?? OpenRTBVideoObjectParser.stringValue(videoObject?["podId"])

        let podSeq = OpenRTBVideoObjectParser.intValue(bid["podseq"])
            ?? OpenRTBVideoObjectParser.intValue(bid["podSeq"])
            ?? OpenRTBVideoObjectParser.intValue(mergedExt?["podseq"])
            ?? OpenRTBVideoObjectParser.intValue(videoObject?["podseq"])

        let vastSequence = VastAdSequenceParser.contentLikelyContainsVAST(adm)
            ? VastAdSequenceParser.firstAdSequence(from: adm)
            : nil

        var rawBid = bid
        if let mergedExt {
            rawBid["ext"] = mergedExt
        }

        return OpenRTBAdMarkup(
            adm: adm,
            adId: OpenRTBVideoObjectParser.stringValue(bid["id"]),
            crid: OpenRTBVideoObjectParser.stringValue(bid["crid"]),
            price: OpenRTBVideoObjectParser.doubleValue(bid["price"]),
            podId: podId,
            podSeq: podSeq,
            slotInPod: slotInPod,
            durationSeconds: duration,
            vastSequence: vastSequence,
            rawBid: rawBid,
            responseOrder: order
        )
    }

    private static func buildPodContext(
        from root: [String: Any],
        videoObject: [String: Any]?,
        markups: [OpenRTBAdMarkup]
    ) -> OpenRTBPodContext {
        let video = videoObject ?? [:]
        let podId = OpenRTBVideoObjectParser.stringValue(video["podid"])
            ?? OpenRTBVideoObjectParser.stringValue(video["podId"])
            ?? markups.compactMap(\.podId).first
        let podSeq = OpenRTBVideoObjectParser.intValue(video["podseq"])
            ?? OpenRTBVideoObjectParser.intValue(video["podSeq"])
            ?? markups.compactMap(\.podSeq).first
        let podDur = OpenRTBVideoObjectParser.intValue(video["poddur"])
            ?? OpenRTBVideoObjectParser.intValue(video["podDur"])
        let rqddursPrimary = OpenRTBVideoObjectParser.intArrayValue(video["rqddurs"])
        let rqddurs = rqddursPrimary.isEmpty
            ? OpenRTBVideoObjectParser.intArrayValue(video["rqdDurs"])
            : rqddursPrimary
        let maxSeq = OpenRTBVideoObjectParser.intValue(video["maxseq"])
            ?? OpenRTBVideoObjectParser.intValue(video["maxSeq"])
        let minCpm = OpenRTBVideoObjectParser.doubleValue(video["mincpmpersec"])
            ?? OpenRTBVideoObjectParser.doubleValue(video["minCpmPerSec"])
        let minDuration = OpenRTBVideoObjectParser.intValue(video["minduration"])
        let maxDuration = OpenRTBVideoObjectParser.intValue(video["maxduration"])

        let hasFixedStructure = maxSeq != nil || !rqddurs.isEmpty || markups.contains { $0.slotInPod != nil }
        let hasDynamicBudget = podDur != nil

        let type: OpenRTBPodType
        if markups.count <= 1 {
            type = .single
        } else if hasFixedStructure && hasDynamicBudget {
            type = .hybrid
        } else if hasDynamicBudget && !hasFixedStructure {
            type = .dynamic
        } else if hasFixedStructure {
            type = .structured
        } else {
            type = .unknown
        }

        _ = minDuration
        _ = maxDuration

        return OpenRTBPodContext(
            podId: podId,
            podSeq: podSeq,
            podDurSeconds: podDur,
            rqddursSeconds: rqddurs,
            maxSeq: maxSeq,
            minCpmPerSec: minCpm,
            type: type
        )
    }

    private static func dedupePodGroups(_ markups: [OpenRTBAdMarkup]) -> [OpenRTBAdMarkup] {
        let grouped = Dictionary(grouping: markups) { $0.podId ?? "__default__" }
        guard grouped.count > 1 else { return markups }

        let selectedKey = grouped.keys.sorted().first ?? "__default__"
        Logger.warning("Multiple pod groups detected; using podId=\(selectedKey)", prefix: logPrefix)
        return grouped[selectedKey] ?? markups
    }

    private static func usableAdm(from value: Any?) -> String? {
        guard let string = OpenRTBVideoObjectParser.stringValue(value) else { return nil }
        return isUsableAdm(string) ? string : nil
    }

    private static func isUsableAdm(_ adm: String) -> Bool {
        let trimmed = adm.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        return VastAdSequenceParser.isAdTagURL(trimmed) || VastAdSequenceParser.contentLikelyContainsVAST(trimmed)
    }
}
