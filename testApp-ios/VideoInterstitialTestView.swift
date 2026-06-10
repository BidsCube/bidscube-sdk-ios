import SwiftUI
import bidscubeSdk

struct VideoInterstitialTestView: View {
    private let delegate = TestAdDelegate()

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                Text("Video Interstitial Tests")
                    .font(.headline)
                    .padding(.top)

                Group {
                    Text("QA — Preview Fallback")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    qaButton(
                        title: "Case 1: VAST without preview",
                        subtitle: "No skip · closes after video",
                        color: .orange
                    ) {
                        present(vast: BidscubeSDKVideoInterstitialQA.vastWithoutPreview)
                    }

                    qaButton(
                        title: "Case 2: VAST with preview",
                        subtitle: "Skip after 5s · end card with companion image",
                        color: .green
                    ) {
                        present(vast: BidscubeSDKVideoInterstitialQA.vastWithPreview)
                    }
                }

                Group {
                    Text("QA — Preview screen only (end card)")
                        .font(.subheadline.weight(.semibold))
                        .frame(maxWidth: .infinity, alignment: .leading)

                    qaButton(
                        title: "Preview: default fallback image",
                        subtitle: "No VAST companion · SDK default preview",
                        color: .purple
                    ) {
                        presentEndCardPreview(vast: BidscubeSDKVideoInterstitialQA.vastWithoutPreview)
                    }

                    qaButton(
                        title: "Preview: parsed companion image",
                        subtitle: "From VAST StaticResource · google.com",
                        color: .blue
                    ) {
                        presentEndCardPreview(vast: BidscubeSDKVideoInterstitialQA.vastWithPreview)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Video Interstitial")
    }

    private func qaButton(
        title: String,
        subtitle: String,
        color: Color,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                Text(subtitle)
                    .font(.caption)
                    .opacity(0.9)
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(color)
            .cornerRadius(10)
        }
    }

    private func presenter() -> UIViewController? {
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .flatMap(\.windows)
            .first(where: \.isKeyWindow)?
            .rootViewController
            .flatMap(topViewController)
    }

    private func topViewController(from root: UIViewController) -> UIViewController {
        if let presented = root.presentedViewController {
            return topViewController(from: presented)
        }
        if let nav = root as? UINavigationController, let visible = nav.visibleViewController {
            return topViewController(from: visible)
        }
        return root
    }

    private func present(vast: String) {
        guard let host = presenter() else { return }
        BidscubeSDK.presentTestVideoInterstitial(from: host, vastXML: vast, callback: delegate)
    }

    private func presentEndCardPreview(vast: String) {
        guard let host = presenter() else { return }
        BidscubeSDK.presentTestEndCardPreview(from: host, vastXML: vast, callback: delegate)
    }
}
