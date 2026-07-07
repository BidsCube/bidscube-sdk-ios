import Foundation

public enum OpenRTBPodDurationValidationMode {
    case lenient
    case strict
}

public enum OpenRTBPodSkipPolicy {
    case skipCurrentAndContinue
    case failEntirePod
}

public enum OpenRTBPodType {
    case single
    case structured
    case dynamic
    case hybrid
    case unknown
}
