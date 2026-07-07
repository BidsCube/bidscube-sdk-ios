import Foundation
@testable import bidscubeSdk

enum OpenRTBTestFixtures {

    static func vastAd(sequence: Int, durationSeconds: Int, id: String = "ad") -> String {
        let minutes = durationSeconds / 60
        let seconds = durationSeconds % 60
        let duration = String(format: "%02d:%02d:%02d", 0, minutes, seconds)
        return """
        <Ad sequence="\(sequence)" id="\(id)">
          <InLine>
            <Creatives>
              <Creative>
                <Linear>
                  <Duration>\(duration)</Duration>
                  <MediaFiles>
                    <MediaFile delivery="progressive" type="video/mp4"><![CDATA[https://example.com/\(id).mp4]]></MediaFile>
                  </MediaFiles>
                </Linear>
              </Creative>
            </Creatives>
          </InLine>
        </Ad>
        """
    }

    static func vastDocument(ads: [String]) -> String {
        """
        <VAST version="3.0">
        \(ads.joined(separator: "\n"))
        </VAST>
        """
    }

    static let rawVast = vastDocument(ads: [vastAd(sequence: 1, durationSeconds: 15)])

    static func legacyRootAdmJSON() -> [String: Any] {
        ["adm": rawVast, "position": 6]
    }

    static func structuredPodJSON() -> [String: Any] {
        [
            "openrtb": [
                "video": [
                    "podid": "pod-1",
                    "poddur": 60,
                    "rqddurs": [15, 30],
                    "maxseq": 3
                ]
            ],
            "bids": [
                [
                    "adm": vastDocument(ads: [vastAd(sequence: 2, durationSeconds: 30, id: "second")]),
                    "slotinpod": 2,
                    "duration": 30
                ],
                [
                    "adm": vastDocument(ads: [vastAd(sequence: 1, durationSeconds: 15, id: "first")]),
                    "slotinpod": 1,
                    "duration": 15
                ]
            ]
        ]
    }

    static func dynamicPodJSON() -> [String: Any] {
        [
            "openrtb": [
                "video": [
                    "podid": "pod-dynamic",
                    "poddur": 30
                ]
            ],
            "bids": [
                [
                    "adm": vastDocument(ads: [vastAd(sequence: 1, durationSeconds: 45, id: "too-long")]),
                    "duration": 45
                ],
                [
                    "adm": vastDocument(ads: [vastAd(sequence: 2, durationSeconds: 15, id: "ok")]),
                    "duration": 15
                ],
                [
                    "adm": vastDocument(ads: [vastAd(sequence: 3, durationSeconds: 10, id: "also-ok")]),
                    "duration": 10
                ]
            ]
        ]
    }

    static func hybridPodJSON() -> [String: Any] {
        [
            "openrtb": [
                "video": [
                    "podid": "pod-hybrid",
                    "poddur": 40,
                    "rqddurs": [15],
                    "maxseq": 4
                ]
            ],
            "bids": [
                [
                    "adm": vastDocument(ads: [vastAd(sequence: 1, durationSeconds: 15, id: "fixed")]),
                    "slotinpod": 1,
                    "duration": 15
                ],
                [
                    "adm": vastDocument(ads: [vastAd(sequence: 2, durationSeconds: 10, id: "dynamic-a")]),
                    "duration": 10
                ],
                [
                    "adm": vastDocument(ads: [vastAd(sequence: 3, durationSeconds: 20, id: "dynamic-b")]),
                    "duration": 20
                ]
            ]
        ]
    }

    static func seatbidJSON() -> [String: Any] {
        [
            "seatbid": [
                [
                    "bid": [
                        [
                            "id": "bid-1",
                            "impid": "imp-1",
                            "adm": vastDocument(ads: [vastAd(sequence: 1, durationSeconds: 15, id: "seat-1")]),
                            "crid": "creative-1",
                            "price": 1.2,
                            "ext": [
                                "slotinpod": 1,
                                "duration": 15,
                                "podid": "pod-seat"
                            ]
                        ]
                    ]
                ]
            ],
            "openrtb": [
                "video": [
                    "podid": "pod-seat",
                    "poddur": 60,
                    "rqddurs": [15],
                    "maxseq": 3
                ]
            ]
        ]
    }

    static func multiPodSeatbidJSON() -> [String: Any] {
        [
            "seatbid": [
                [
                    "bid": [
                        [
                            "id": "bid-b",
                            "adm": vastDocument(ads: [vastAd(sequence: 1, durationSeconds: 10, id: "pod-b")]),
                            "ext": ["podid": "pod-b", "slotinpod": 1, "duration": 10]
                        ]
                    ]
                ],
                [
                    "bid": [
                        [
                            "id": "bid-a",
                            "adm": vastDocument(ads: [vastAd(sequence: 1, durationSeconds: 15, id: "pod-a")]),
                            "ext": ["podid": "pod-a", "slotinpod": 1, "duration": 15]
                        ]
                    ]
                ]
            ],
            "openrtb": ["video": ["podid": "pod-a"]]
        ]
    }

    static func singleAdmMultiAdVastJSON(slotInPod: Int = 1) -> [String: Any] {
        [
            "adm": vastDocument(ads: [
                vastAd(sequence: 1, durationSeconds: 15, id: "seq-1"),
                vastAd(sequence: 2, durationSeconds: 20, id: "seq-2")
            ]),
            "slotinpod": slotInPod,
            "openrtb": [
                "video": [
                    "podid": "pod-multi-ad",
                    "rqddurs": [15, 20],
                    "maxseq": 2
                ]
            ]
        ]
    }

    static func jsonString(_ object: [String: Any]) -> String {
        let data = try! JSONSerialization.data(withJSONObject: object, options: [.sortedKeys])
        return String(data: data, encoding: .utf8)!
    }

    static func defaultConfig(openRtbEnabled: Bool = true, validation: OpenRTBPodDurationValidationMode = .lenient) -> SDKConfig {
        SDKConfig.Builder()
            .openRtbPodMetadataEnabled(openRtbEnabled)
            .videoPodDurationValidationMode(validation)
            .build()
    }
}
