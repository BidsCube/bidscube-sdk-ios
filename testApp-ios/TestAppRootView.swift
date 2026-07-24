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
                let config = SDKConfig.Builder()
                    .enableLogging(true)
                    .userId("test-app-user-001")
                    .build()
                BidscubeSDK.initialize(config: config)
            }
            BidscubeSDK.requestConsentInfoUpdate(callback: delegate)
        }
    }
}
