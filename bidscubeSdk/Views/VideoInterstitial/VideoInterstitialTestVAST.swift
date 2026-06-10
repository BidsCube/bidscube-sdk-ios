import Foundation

/// Local VAST fixtures for SDK test/demo flows only.
enum VideoInterstitialTestVAST {

    static let sampleMediaURL = "https://storage.googleapis.com/interactive-media-ads/media/big_buck_bunny.mp4"
    static let sampleCompanionImage = "https://storage.googleapis.com/gvabox/media/images/big_buck_bunny.jpg"
    static let sampleVideoClick = "https://example.com/clickthrough"
    static let sampleEndCardClick = "https://example.com/endcard-click"
    static let liveIMAAdTag = "https://pubads.g.doubleclick.net/gampad/ads?iu=/21775744923/external/single_ad_samples&sz=640x480&ciu_szs=300x250%2C728x90&gdfp_req=1&output=vast&unviewed_position_start=1&env=vp&correlator="

    /// QA fixture: no Companion / StaticResource — video only, no skip, closes after playback.
    static let qaWithoutPreview: String = """
    <VAST version="3.0">
      <Ad id="20">
        <InLine>
          <AdSystem version="3.0">Bidscube</AdSystem>
          <AdTitle><![CDATA[Doordash-35min-burger-3-1x1.mp4]]></AdTitle>
          <Creatives>
            <Creative>
              <Linear>
                <Duration>00:00:12.867</Duration>
                <MediaFiles>
                  <MediaFile
                    delivery="progressive"
                    type="video/mp4"
                    bitrate="800"
                    width="1024"
                    height="1024">
                    <![CDATA[https://assets.remerge.io/ad_assets/files/003/411/782/1024x1024_800_mp4/Doordash-35min-burger-3-1x1.mp4]]>
                  </MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
    </VAST>
    """

    /// QA fixture: companion preview + skip offset + click-through for manual QA.
    static let qaWithPreview: String = """
    <?xml version="1.0" encoding="UTF-8"?>
    <VAST version="4.2">
        <Ad id="12345">
            <InLine>
                <AdSystem version="1.0">BidscubeTest</AdSystem>
                <AdTitle>Sample Skippable VAST Ad With Preview</AdTitle>
                <Impression><![CDATA[https://example.com/impression]]></Impression>
                <Creatives>
                    <Creative id="1" sequence="1">
                        <Linear skipoffset="00:00:05">
                            <Duration>00:00:30</Duration>
                            <TrackingEvents>
                                <Tracking event="start"><![CDATA[https://example.com/start]]></Tracking>
                                <Tracking event="complete"><![CDATA[https://example.com/complete]]></Tracking>
                                <Tracking event="skip"><![CDATA[https://example.com/skip]]></Tracking>
                            </TrackingEvents>
                            <VideoClicks>
                                <ClickThrough><![CDATA[https://www.google.com]]></ClickThrough>
                                <ClickTracking><![CDATA[https://example.com/clicktracking]]></ClickTracking>
                            </VideoClicks>
                            <MediaFiles>
                                <MediaFile delivery="progressive" type="video/mp4"
                                           width="1280" height="720" bitrate="1500">
                                    <![CDATA[https://storage.googleapis.com/interactive-media-ads/media/big_buck_bunny.mp4]]>
                                </MediaFile>
                            </MediaFiles>
                        </Linear>
                    </Creative>

                    <Creative sequence="2">
                        <CompanionAds>
                            <Companion width="1280" height="720">
                                <StaticResource creativeType="image/jpeg">
                                    <![CDATA[https://www.gstatic.com/webp/gallery/3.jpg]]>
                                </StaticResource>
                                <CompanionClickThrough>
                                    <![CDATA[https://www.google.com]]>
                                </CompanionClickThrough>
                            </Companion>
                        </CompanionAds>
                    </Creative>
                </Creatives>
            </InLine>
        </Ad>
    </VAST>
    """

    static let withCompanionAndSkip: String = """
    <VAST version="3.0">
      <Ad id="1">
        <InLine>
          <AdSystem>BidsCube Test</AdSystem>
          <Impression><![CDATA[https://example.com/impression]]></Impression>
          <Creatives>
            <Creative>
              <Linear skipoffset="00:00:05">
                <Duration>00:00:30</Duration>
                <VideoClicks>
                  <ClickThrough><![CDATA[\(sampleVideoClick)]]></ClickThrough>
                </VideoClicks>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4"><![CDATA[\(sampleMediaURL)]]></MediaFile>
                </MediaFiles>
              </Linear>
              <CompanionAds>
                <Companion width="640" height="360">
                  <StaticResource creativeType="image/jpeg"><![CDATA[\(sampleCompanionImage)]]></StaticResource>
                  <CompanionClickThrough><![CDATA[\(sampleEndCardClick)]]></CompanionClickThrough>
                </Companion>
              </CompanionAds>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
    </VAST>
    """

    static let withoutCompanion: String = """
    <VAST version="3.0">
      <Ad id="2">
        <InLine>
          <Creatives>
            <Creative>
              <Linear skipoffset="00:00:05">
                <Duration>00:00:20</Duration>
                <VideoClicks>
                  <ClickThrough><![CDATA[\(sampleVideoClick)]]></ClickThrough>
                </VideoClicks>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4"><![CDATA[\(sampleMediaURL)]]></MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
    </VAST>
    """

    static let withoutSkipOffset: String = """
    <VAST version="3.0">
      <Ad id="3">
        <InLine>
          <Creatives>
            <Creative>
              <Linear>
                <Duration>00:00:20</Duration>
                <VideoClicks>
                  <ClickThrough><![CDATA[\(sampleVideoClick)]]></ClickThrough>
                </VideoClicks>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4"><![CDATA[\(sampleMediaURL)]]></MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
    </VAST>
    """

    static let missingClickURL: String = """
    <VAST version="3.0">
      <Ad id="4">
        <InLine>
          <Creatives>
            <Creative>
              <Linear skipoffset="00:00:05">
                <Duration>00:00:20</Duration>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4"><![CDATA[\(sampleMediaURL)]]></MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
    </VAST>
    """

    static let invalid: String = "<not-vast></not-vast>"

    static let nonSkippable: String = """
    <VAST version="3.0">
      <Ad id="5">
        <InLine>
          <Creatives>
            <Creative>
              <Linear>
                <Duration>00:00:15</Duration>
                <VideoClicks>
                  <ClickThrough><![CDATA[\(sampleVideoClick)]]></ClickThrough>
                </VideoClicks>
                <MediaFiles>
                  <MediaFile delivery="progressive" type="video/mp4"><![CDATA[\(sampleMediaURL)]]></MediaFile>
                </MediaFiles>
              </Linear>
            </Creative>
          </Creatives>
        </InLine>
      </Ad>
    </VAST>
    """
}
