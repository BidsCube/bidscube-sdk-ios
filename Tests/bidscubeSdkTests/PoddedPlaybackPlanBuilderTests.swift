import Testing
@testable import bidscubeSdk

struct PoddedPlaybackPlanBuilderTests {

    @Test func structuredPodSortsBySlotInPod() throws {
        let json = OpenRTBTestFixtures.structuredPodJSON()
        let normalized = try #require(OpenRTBPoddedResponseNormalizer.normalize(json: json))
        let plan = try #require(PoddedPlaybackPlanBuilder.build(from: normalized, config: OpenRTBTestFixtures.defaultConfig()))
        #expect(plan.slots.count == 2)
        #expect(plan.slots[0].slotInPod == 1)
        #expect(plan.slots[1].slotInPod == 2)
        #expect(plan.slots[0].durationSeconds == 15)
        #expect(plan.slots[1].durationSeconds == 30)
    }

    @Test func dynamicPodRespectsBudgetAndSkipsOversizedSlot() throws {
        let json = OpenRTBTestFixtures.dynamicPodJSON()
        let normalized = try #require(OpenRTBPoddedResponseNormalizer.normalize(json: json))
        #expect(normalized.podContext.type == .dynamic)
        let plan = try #require(PoddedPlaybackPlanBuilder.build(from: normalized, config: OpenRTBTestFixtures.defaultConfig()))
        let durations = plan.slots.compactMap(\.durationSeconds)
        #expect(!durations.contains(45))
        #expect(durations.reduce(0, +) <= 30)
    }

    @Test func hybridPodKeepsFixedSlotsThenFillsBudget() throws {
        let json = OpenRTBTestFixtures.hybridPodJSON()
        let normalized = try #require(OpenRTBPoddedResponseNormalizer.normalize(json: json))
        #expect(normalized.podContext.type == .hybrid)
        let plan = try #require(PoddedPlaybackPlanBuilder.build(from: normalized, config: OpenRTBTestFixtures.defaultConfig()))
        #expect(plan.slots.first?.slotInPod == 1)
        let total = plan.slots.compactMap(\.durationSeconds).reduce(0, +)
        #expect(total <= 40)
    }

    @Test func singleAdmMultiAdVastDoesNotCopySlotInPod() throws {
        let json = OpenRTBTestFixtures.singleAdmMultiAdVastJSON(slotInPod: 1)
        let normalized = try #require(OpenRTBPoddedResponseNormalizer.normalize(json: json))
        let plan = try #require(PoddedPlaybackPlanBuilder.build(from: normalized, config: OpenRTBTestFixtures.defaultConfig()))
        #expect(plan.slots.count == 2)
        #expect(plan.slots.allSatisfy { $0.slotInPod == nil })
        #expect(plan.slots[0].durationSeconds == 15)
        #expect(plan.slots[1].durationSeconds == 20)
    }

    @Test func strictValidationCanFailStructuredPlan() throws {
        let json: [String: Any] = [
            "openrtb": ["video": ["podid": "pod-strict", "rqddurs": [15]]],
            "bids": [
                ["adm": OpenRTBTestFixtures.vastDocument(ads: [OpenRTBTestFixtures.vastAd(sequence: 1, durationSeconds: 30)]), "duration": 30]
            ]
        ]
        let normalized = try #require(OpenRTBPoddedResponseNormalizer.normalize(json: json))
        let config = OpenRTBTestFixtures.defaultConfig(validation: .strict)
        let plan = PoddedPlaybackPlanBuilder.build(from: normalized, config: config)
        #expect(plan == nil)
    }
}
