import Testing
@testable import bidscubeSdk

struct VastMetadataParserTests {

    @Test func parsesCompanionImageAndClickThrough() {
        let metadata = VastMetadataParser.parse(VideoInterstitialTestVAST.withCompanionAndSkip)
        #expect(metadata.previewImageUrl?.absoluteString == VideoInterstitialTestVAST.sampleCompanionImage)
        #expect(metadata.clickUrl?.absoluteString == VideoInterstitialTestVAST.sampleEndCardClick)
        #expect(metadata.skipOffsetSeconds == 5)
    }

    @Test func leavesPreviewNilWhenCompanionMissing() {
        let metadata = VastMetadataParser.parse(VideoInterstitialTestVAST.withoutCompanion)
        #expect(metadata.previewImageUrl == nil)
        #expect(metadata.clickUrl?.absoluteString == VideoInterstitialTestVAST.sampleVideoClick)
        #expect(metadata.skipOffsetSeconds == 0)
    }

    @Test func qaWithoutPreviewHasNoParsedPreview() {
        let metadata = VastMetadataParser.parse(VideoInterstitialTestVAST.qaWithoutPreview)
        #expect(metadata.previewImageUrl == nil)
        #expect(metadata.skipOffsetSeconds == 0)
    }

    @Test func qaWithPreviewParsesCompanionImageAndClick() {
        let metadata = VastMetadataParser.parse(VideoInterstitialTestVAST.qaWithPreview)
        #expect(metadata.previewImageUrl?.absoluteString == "https://www.gstatic.com/webp/gallery/3.jpg")
        #expect(metadata.clickUrl?.absoluteString == "https://www.google.com")
        #expect(metadata.skipOffsetSeconds == 5)
    }

    @Test func extractsCompanionBlockWithoutCaptureGroupPattern() {
        #expect(VastMetadataParser.extractCompanionImageUrl(from: VideoInterstitialTestVAST.qaWithPreview) == "https://www.gstatic.com/webp/gallery/3.jpg")
    }

    @Test func usesDefaultSkipWhenCompanionPresentButSkipMissing() {
        let vast = """
        <VAST version="3.0">
          <Ad>
            <InLine>
              <Creatives>
                <Creative>
                  <Linear>
                    <Duration>00:00:20</Duration>
                    <MediaFiles>
                      <MediaFile delivery="progressive" type="video/mp4"><![CDATA[https://example.com/video.mp4]]></MediaFile>
                    </MediaFiles>
                  </Linear>
                  <CompanionAds>
                    <Companion width="640" height="360">
                      <StaticResource creativeType="image/jpeg"><![CDATA[https://example.com/preview.jpg]]></StaticResource>
                    </Companion>
                  </CompanionAds>
                </Creative>
              </Creatives>
            </InLine>
          </Ad>
        </VAST>
        """
        let metadata = VastMetadataParser.parse(vast)
        #expect(metadata.previewImageUrl?.absoluteString == "https://example.com/preview.jpg")
        #expect(metadata.skipOffsetSeconds == VideoInterstitialDefaults.skipOffsetSeconds)
    }

    @Test func noSkipWithoutCompanionEvenWhenLinearHasNoSkipOffset() {
        let metadata = VastMetadataParser.parse(VideoInterstitialTestVAST.withoutSkipOffset)
        #expect(metadata.previewImageUrl == nil)
        #expect(metadata.skipOffsetSeconds == 0)
    }

    @Test func invalidXmlReturnsDefaultsSafely() {
        let metadata = VastMetadataParser.parse(VideoInterstitialTestVAST.invalid)
        #expect(metadata.appTitle == VideoInterstitialDefaults.appTitle)
        #expect(metadata.rating == VideoInterstitialDefaults.rating)
        #expect(metadata.skipOffsetSeconds == VideoInterstitialDefaults.skipOffsetSeconds)
    }

    @Test func parseSkipOffsetFormats() {
        #expect(VastMetadataParser.parseVastDurationToSeconds("00:00:05") == 5)
        #expect(VastMetadataParser.parseVastDurationToSeconds("01:02:03") == 3723)
        #expect(VastMetadataParser.parseVastDurationToSeconds("02:30") == 150)
        #expect(VastMetadataParser.parseVastDurationToSeconds("7.9") == 7)
        #expect(VastMetadataParser.parseVastDurationToSeconds("invalid") == 0)
    }
}
