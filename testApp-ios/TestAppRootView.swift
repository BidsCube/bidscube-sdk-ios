import SwiftUI
import bidscubeSdk

struct TestAppRootView: View {
    private let delegate = TestAdDelegate()

    var body: some View {
        TabView {
            NavigationView {
                VideoInterstitialTestView()
            }
            .tabItem {
                Label("Video Interstitial", systemImage: "play.rectangle.fill")
            }

            #if canImport(AppLovinSDK)
            NavigationView {
                MAXMediationTestView()
            }
            .tabItem {
                Label("MAX", systemImage: "square.grid.2x2")
            }
            #endif
        }
        .onAppear {
            if !BidscubeSDK.isInitialized() {
                BidscubeSDK.initialize()
            }
            BidscubeSDK.requestConsentInfoUpdate(callback: delegate)
        }
    }
}
