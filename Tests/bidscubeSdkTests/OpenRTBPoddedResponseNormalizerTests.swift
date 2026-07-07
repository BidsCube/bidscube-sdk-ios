import Testing
@testable import bidscubeSdk

struct OpenRTBPoddedResponseNormalizerTests {

    @Test func parsesStructuredBidsArray() {
        let json = OpenRTBTestFixtures.structuredPodJSON()
        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized != nil)
        #expect(normalized?.markups.count == 2)
        #expect(normalized?.podContext.type == .hybrid)
        #expect(normalized?.podContext.podId == "pod-1")
    }

    @Test func parsesSeatbidWithExtMetadata() {
        let json = OpenRTBTestFixtures.seatbidJSON()
        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized?.markups.count == 1)
        #expect(normalized?.markups.first?.slotInPod == 1)
        #expect(normalized?.markups.first?.durationSeconds == 15)
        #expect(normalized?.markups.first?.crid == "creative-1")
    }

    @Test func rootAdmWithVideoObjectCreatesSingleMarkup() {
        let json: [String: Any] = [
            "adm": OpenRTBTestFixtures.rawVast,
            "openrtb": ["video": ["podid": "pod-root", "maxseq": 1]]
        ]
        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized?.markups.count == 1)
        #expect(normalized?.podContext.podId == "pod-root")
    }

    @Test func ignoresBidsWithoutUsableAdm() {
        let json: [String: Any] = [
            "openrtb": ["video": ["podid": "pod-1"]],
            "bids": [
                ["adm": "not-vast-or-url"],
                ["adm": OpenRTBTestFixtures.rawVast]
            ]
        ]
        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized?.markups.count == 1)
    }

    @Test func selectsDeterministicPodGroupWhenMultipleExist() {
        let json = OpenRTBTestFixtures.multiPodSeatbidJSON()
        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized?.markups.count == 1)
        #expect(normalized?.markups.first?.podId == "pod-a")
    }

    @Test func returnsNilForNonOpenRTBLikePayload() {
        let json = ["foo": "bar"]
        #expect(OpenRTBPoddedResponseNormalizer.isOpenRTBLike(json: json) == false)
        #expect(OpenRTBPoddedResponseNormalizer.normalize(json: json) == nil)
    }
}
