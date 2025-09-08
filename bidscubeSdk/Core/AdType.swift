import Foundation

public enum AdType: String {
    case image
    case video
    case skippableVideo
    case native

    var pathSegment: String {
        switch self {
        case .image: return "image"
        case .video: return "video"
        case .skippableVideo: return "video"
        case .native: return "native"
        }
    }
}


