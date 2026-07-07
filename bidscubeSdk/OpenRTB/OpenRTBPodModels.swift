import Foundation

struct OpenRTBPodContext {
    let podId: String?
    let podSeq: Int?
    let podDurSeconds: Int?
    let rqddursSeconds: [Int]
    let maxSeq: Int?
    let minCpmPerSec: Double?
    let type: OpenRTBPodType
}

struct OpenRTBAdMarkup {
    let adm: String
    let adId: String?
    let crid: String?
    let price: Double?
    let podId: String?
    let podSeq: Int?
    let slotInPod: Int?
    let durationSeconds: Int?
    let vastSequence: Int?
    let rawBid: [String: Any]
    let responseOrder: Int
}

struct OpenRTBPoddedResponse {
    let podContext: OpenRTBPodContext
    let markups: [OpenRTBAdMarkup]
}

struct VideoPlaybackSlot {
    let adm: String
    let adTagUrl: String?
    let vastXml: String?
    let slotIndex: Int
    let slotInPod: Int?
    let durationSeconds: Int?
    let metadata: VideoInterstitialMetadata
}

struct VideoPlaybackPlan {
    let podContext: OpenRTBPodContext?
    let slots: [VideoPlaybackSlot]
}
