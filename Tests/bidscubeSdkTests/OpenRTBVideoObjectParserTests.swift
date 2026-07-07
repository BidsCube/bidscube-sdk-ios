import Foundation
import Testing
@testable import bidscubeSdk

struct OpenRTBVideoObjectParserTests {

    @Test func intValueReturnsNilForNonNumericString() {
        #expect(OpenRTBVideoObjectParser.intValue("abc") == nil)
        #expect(OpenRTBVideoObjectParser.intValue("not-a-number") == nil)
        #expect(OpenRTBVideoObjectParser.intValue("") == nil)
    }

    @Test func intValueParsesValidNumericStrings() {
        #expect(OpenRTBVideoObjectParser.intValue("15") == 15)
        #expect(OpenRTBVideoObjectParser.intValue("1.9") == 1)
    }

    @Test func intValueReturnsNilForNonFiniteNumbers() {
        #expect(OpenRTBVideoObjectParser.intValue(Double.nan) == nil)
        #expect(OpenRTBVideoObjectParser.intValue(Double.infinity) == nil)
        #expect(OpenRTBVideoObjectParser.intValue(NSNumber(value: Double.nan)) == nil)
        #expect(OpenRTBVideoObjectParser.intValue(NSNumber(value: Double.infinity)) == nil)
    }

    @Test func doubleValueReturnsNilForNonFiniteNumbers() {
        #expect(OpenRTBVideoObjectParser.doubleValue(Double.nan) == nil)
        #expect(OpenRTBVideoObjectParser.doubleValue(Double.infinity) == nil)
        #expect(OpenRTBVideoObjectParser.doubleValue("nan") == nil)
        #expect(OpenRTBVideoObjectParser.doubleValue(NSNumber(value: Double.nan)) == nil)
        #expect(OpenRTBVideoObjectParser.doubleValue(1.5) == 1.5)
    }

    @Test func intArrayValueParsesRqddursAndSkipsInvalidEntries() {
        #expect(OpenRTBVideoObjectParser.intArrayValue([15, 30]) == [15, 30])
        #expect(OpenRTBVideoObjectParser.intArrayValue(["15", "abc", 30]) == [15, 30])
        #expect(OpenRTBVideoObjectParser.intArrayValue([Double.nan, 15.0, Double.infinity]) == [15])
    }

    @Test func normalizerUsesRqddursPrimaryKey() {
        let json: [String: Any] = [
            "openrtb": ["video": ["podid": "pod-rqddurs", "rqddurs": [15, 30]]],
            "bids": [["adm": OpenRTBTestFixtures.rawVast, "duration": 15]]
        ]
        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized?.podContext.rqddursSeconds == [15, 30])
    }

    @Test func normalizerFallsBackToRqdDursWhenRqddursMissing() {
        let json: [String: Any] = [
            "openrtb": ["video": ["podid": "pod-rqddurs-alt", "rqdDurs": [10, 20]]],
            "bids": [["adm": OpenRTBTestFixtures.rawVast, "duration": 10]]
        ]
        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized?.podContext.rqddursSeconds == [10, 20])
    }

    @Test func normalizerPrefersRqddursOverRqdDursWhenBothPresent() {
        let json: [String: Any] = [
            "openrtb": ["video": ["podid": "pod-both", "rqddurs": [15], "rqdDurs": [99]]],
            "bids": [["adm": OpenRTBTestFixtures.rawVast, "duration": 15]]
        ]
        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized?.podContext.rqddursSeconds == [15])
    }

    @Test func normalizerDoesNotCrashOnMalformedPodFields() {
        let json: [String: Any] = [
            "openrtb": [
                "video": [
                    "podid": "pod-bad",
                    "poddur": "invalid",
                    "rqddurs": ["abc", 15],
                    "maxseq": "not-a-number"
                ]
            ],
            "bids": [
                [
                    "adm": OpenRTBTestFixtures.rawVast,
                    "slotinpod": "abc",
                    "duration": "not-a-number"
                ]
            ]
        ]

        let normalized = OpenRTBPoddedResponseNormalizer.normalize(json: json)
        #expect(normalized != nil)
        #expect(normalized?.markups.first?.slotInPod == nil)
        #expect(normalized?.markups.first?.durationSeconds == nil)
        #expect(normalized?.podContext.podDurSeconds == nil)
        #expect(normalized?.podContext.maxSeq == nil)
        #expect(normalized?.podContext.rqddursSeconds == [15])
    }

    @Test func malformedNumericFieldsDoNotCrashPlanBuilder() throws {
        let json: [String: Any] = [
            "openrtb": ["video": ["podid": "pod-bad", "poddur": "invalid"]],
            "bids": [
                [
                    "adm": OpenRTBTestFixtures.vastDocument(ads: [
                        OpenRTBTestFixtures.vastAd(sequence: 1, durationSeconds: 15)
                    ]),
                    "slotinpod": "abc",
                    "duration": "not-a-number"
                ]
            ]
        ]

        let normalized = try #require(OpenRTBPoddedResponseNormalizer.normalize(json: json))
        let plan = PoddedPlaybackPlanBuilder.build(from: normalized, config: OpenRTBTestFixtures.defaultConfig())
        #expect(plan != nil)
        #expect(plan?.slots.count == 1)
        #expect(plan?.slots.first?.slotInPod == nil)
    }
}
