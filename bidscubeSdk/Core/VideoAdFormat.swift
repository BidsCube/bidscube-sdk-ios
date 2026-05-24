import Foundation

/// Distinguishes interstitial fullscreen video vs rewarded video (reward only after natural IMA `.COMPLETE`).
public enum VideoAdFormat {
    case interstitial
    case rewarded
}
