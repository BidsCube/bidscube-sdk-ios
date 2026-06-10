import Foundation

public struct VideoInterstitialMetadata {
    public let appTitle: String
    public let rating: Double
    public let downloadCount: String
    public let priceText: String
    public let ctaText: String
    public let previewImageUrl: URL?
    public let clickUrl: URL?
    public let skipOffsetSeconds: Int

    public init(
        appTitle: String = "Test game android",
        rating: Double = 4.5,
        downloadCount: String = "10 k",
        priceText: String = "FREE",
        ctaText: String = "Install Now",
        previewImageUrl: URL? = nil,
        clickUrl: URL? = URL(string: "https://example.com/clickthrough"),
        skipOffsetSeconds: Int = 5
    ) {
        self.appTitle = appTitle
        self.rating = rating
        self.downloadCount = downloadCount
        self.priceText = priceText
        self.ctaText = ctaText
        self.previewImageUrl = previewImageUrl
        self.clickUrl = clickUrl
        self.skipOffsetSeconds = skipOffsetSeconds
    }
}

enum VideoInterstitialDefaults {
    static let appTitle = "Test game android"
    static let rating = 4.5
    static let downloadCount = "10 k"
    static let priceText = "FREE"
    static let ctaText = "Install Now"
    static let previewImageUrl = URL(string: "https://www.gstatic.com/webp/gallery/3.jpg")
    static let clickUrl = URL(string: "https://example.com/clickthrough")
    static let skipOffsetSeconds = 5
}
