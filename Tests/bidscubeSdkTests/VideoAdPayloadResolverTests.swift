import Testing
@testable import bidscubeSdk

struct VideoAdPayloadResolverTests {

    @Test func rawVastStillWorks() {
        let resolved = VideoAdPayloadResolver.resolve(
            content: OpenRTBTestFixtures.rawVast,
            config: OpenRTBTestFixtures.defaultConfig()
        )
        #expect(resolved?.adsResponse?.contains("<VAST") == true)
        #expect(resolved?.adTagUrl == nil)
    }

    @Test func legacyRootAdmStillWorks() {
        let content = OpenRTBTestFixtures.jsonString(OpenRTBTestFixtures.legacyRootAdmJSON())
        let resolved = VideoAdPayloadResolver.resolve(content: content, config: OpenRTBTestFixtures.defaultConfig())
        #expect(resolved?.adsResponse?.contains("<VAST") == true)
        #expect(resolved?.playbackPlan == nil)
    }

    @Test func structuredPodBuildsComposedVastResponse() throws {
        let content = OpenRTBTestFixtures.jsonString(OpenRTBTestFixtures.structuredPodJSON())
        let resolved = try #require(VideoAdPayloadResolver.resolve(content: content, config: OpenRTBTestFixtures.defaultConfig()))
        #expect(resolved.playbackPlan?.slots.count == 2)
        #expect(resolved.adsResponse?.contains("<VAST") == true)
        #expect(VastAdSequenceParser.extractAdNodes(from: resolved.adsResponse ?? "").count == 2)
    }

    @Test func adTagUrlLegacyAdmStillWorks() {
        let content = OpenRTBTestFixtures.jsonString(["adm": "https://example.com/vast.xml"])
        let resolved = VideoAdPayloadResolver.resolve(content: content, config: OpenRTBTestFixtures.defaultConfig())
        #expect(resolved?.adTagUrl == "https://example.com/vast.xml")
    }

    @Test func invalidOpenRTBFallsBackToLegacyWhenPossible() {
        let content = OpenRTBTestFixtures.jsonString([
            "openrtb": ["video": ["podid": "x"]],
            "adm": OpenRTBTestFixtures.rawVast
        ])
        let resolved = VideoAdPayloadResolver.resolve(content: content, config: OpenRTBTestFixtures.defaultConfig())
        #expect(resolved?.adsResponse?.contains("<VAST") == true)
    }

    @Test func invalidPayloadReturnsNil() {
        let resolved = VideoAdPayloadResolver.resolve(content: "not-json-or-vast", config: OpenRTBTestFixtures.defaultConfig())
        #expect(resolved == nil)
    }

    @Test func configDisabledSkipsOpenRTBPodLogic() throws {
        let podOnly = OpenRTBTestFixtures.jsonString(OpenRTBTestFixtures.structuredPodJSON())
        let config = OpenRTBTestFixtures.defaultConfig(openRtbEnabled: false)
        #expect(VideoAdPayloadResolver.resolve(content: podOnly, config: config) == nil)

        let legacy = OpenRTBTestFixtures.jsonString(OpenRTBTestFixtures.legacyRootAdmJSON())
        let resolved = try #require(VideoAdPayloadResolver.resolve(content: legacy, config: config))
        #expect(resolved.playbackPlan == nil)
        #expect(resolved.adsResponse?.contains("<VAST") == true)
    }

    @Test func seatbidResponseResolvesPlayableVast() throws {
        let content = OpenRTBTestFixtures.jsonString(OpenRTBTestFixtures.seatbidJSON())
        let resolved = try #require(VideoAdPayloadResolver.resolve(content: content, config: OpenRTBTestFixtures.defaultConfig()))
        #expect(resolved.playbackPlan?.slots.count == 1)
        #expect(resolved.adsResponse?.contains("seat-1") == true)
    }
}
