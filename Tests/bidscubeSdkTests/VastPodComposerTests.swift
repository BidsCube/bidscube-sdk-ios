import Testing
@testable import bidscubeSdk

struct VastPodComposerTests {

    @Test func singleSlotReturnsWrappedVastUnchanged() {
        let slot = VideoPlaybackSlot(
            adm: OpenRTBTestFixtures.rawVast,
            adTagUrl: nil,
            vastXml: OpenRTBTestFixtures.rawVast,
            slotIndex: 0,
            slotInPod: 1,
            durationSeconds: 15,
            metadata: VideoInterstitialMetadata()
        )
        let composed = VastPodComposer.compose(from: [slot])
        #expect(composed?.contains("<VAST") == true)
        #expect(composed?.contains("id=\"ad\"") == true)
    }

    @Test func multipleInlineSlotsComposeSingleVastDocument() throws {
        let slots = [
            VideoPlaybackSlot(
                adm: OpenRTBTestFixtures.vastAd(sequence: 1, durationSeconds: 15, id: "one"),
                adTagUrl: nil,
                vastXml: OpenRTBTestFixtures.vastAd(sequence: 1, durationSeconds: 15, id: "one"),
                slotIndex: 0,
                slotInPod: 1,
                durationSeconds: 15,
                metadata: VideoInterstitialMetadata()
            ),
            VideoPlaybackSlot(
                adm: OpenRTBTestFixtures.vastAd(sequence: 2, durationSeconds: 20, id: "two"),
                adTagUrl: nil,
                vastXml: OpenRTBTestFixtures.vastAd(sequence: 2, durationSeconds: 20, id: "two"),
                slotIndex: 1,
                slotInPod: 2,
                durationSeconds: 20,
                metadata: VideoInterstitialMetadata()
            )
        ]
        let composed = try #require(VastPodComposer.compose(from: slots))
        #expect(composed.contains("<VAST"))
        #expect(composed.contains("id=\"one\""))
        #expect(composed.contains("id=\"two\""))
        #expect(VastAdSequenceParser.extractAdNodes(from: composed).count == 2)
    }

    @Test func mixedUrlAndXmlUsesFirstUrlOnly() {
        let slots = [
            VideoPlaybackSlot(
                adm: "https://example.com/vast1.xml",
                adTagUrl: "https://example.com/vast1.xml",
                vastXml: nil,
                slotIndex: 0,
                slotInPod: 1,
                durationSeconds: nil,
                metadata: VideoInterstitialMetadata()
            ),
            VideoPlaybackSlot(
                adm: OpenRTBTestFixtures.rawVast,
                adTagUrl: nil,
                vastXml: OpenRTBTestFixtures.rawVast,
                slotIndex: 1,
                slotInPod: 2,
                durationSeconds: 15,
                metadata: VideoInterstitialMetadata()
            )
        ]
        let composed = VastPodComposer.compose(from: slots)
        #expect(composed == "https://example.com/vast1.xml")
    }
}
