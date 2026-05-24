import AppLovinSDK
import Combine
import SwiftUI
import UIKit

struct ContentView: View {
    @State private var bannerAdUnitId = ""
    @State private var mrecAdUnitId = ""
    @State private var interstitialAdUnitId = ""
    @State private var rewardedAdUnitId = ""

    @StateObject private var bannerModel = MAAdViewModel(format: .banner)
    @StateObject private var mrecModel = MAAdViewModel(format: .mrec)
    @StateObject private var interstitialModel = InterstitialAdManager()
    @StateObject private var rewardedModel = RewardedAdManager()

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Bidscube MAX Test App")
                        .font(.title2.weight(.semibold))
                    Text("Use MAX ad unit IDs configured with custom network class `ALBidscubeMediationAdapter` and BidCube Placement ID in App ID.")
                        .font(.footnote)
                        .foregroundColor(.secondary)

                    adInputField(title: "Banner Ad Unit ID", text: $bannerAdUnitId)
                    Button("Load Banner") { bannerModel.load(adUnitId: bannerAdUnitId) }
                        .buttonStyle(.automatic)
                        .disabled(bannerAdUnitId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    MAAdContainerView(model: bannerModel, height: 50)
                    Text(bannerModel.statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Divider()

                    adInputField(title: "MREC Ad Unit ID", text: $mrecAdUnitId)
                    Button("Load MREC") { mrecModel.load(adUnitId: mrecAdUnitId) }
                        .buttonStyle(.automatic)
                        .disabled(mrecAdUnitId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    MAAdContainerView(model: mrecModel, height: 250)
                    Text(mrecModel.statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Divider()

                    adInputField(title: "Interstitial Ad Unit ID", text: $interstitialAdUnitId)
                    HStack {
                        Button("Load Interstitial") { interstitialModel.load(adUnitId: interstitialAdUnitId) }
                            .buttonStyle(.automatic)
                            .disabled(interstitialAdUnitId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        Button("Show Interstitial") { interstitialModel.show() }
                            .buttonStyle(.automatic)
                            .disabled(!interstitialModel.isReady)
                    }
                    Text(interstitialModel.statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Divider()

                    adInputField(title: "Rewarded Ad Unit ID", text: $rewardedAdUnitId)
                    HStack {
                        Button("Load Rewarded") { rewardedModel.load(adUnitId: rewardedAdUnitId) }
                            .buttonStyle(.automatic)
                            .disabled(rewardedAdUnitId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        Button("Show Rewarded") { rewardedModel.show() }
                            .buttonStyle(.automatic)
                            .disabled(!rewardedModel.isReady)
                    }
                    Text(rewardedModel.statusText)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("MAX Mediation")
        }
    }

    private func adInputField(title: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
            TextField("Enter MAX ad unit ID", text: text)
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct MAAdContainerView: UIViewRepresentable {
    @ObservedObject var model: MAAdViewModel
    let height: CGFloat

    func makeUIView(context: Context) -> UIView {
        model.containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        uiView.frame.size.height = height
    }
}

final class MAAdViewModel: NSObject, ObservableObject, MAAdViewAdDelegate {
    @Published private(set) var statusText = "Not loaded"
    let containerView = UIView()

    private let format: MAAdFormat
    private var adView: MAAdView?

    init(format: MAAdFormat) {
        self.format = format
        super.init()
        containerView.backgroundColor = .clear
        containerView.translatesAutoresizingMaskIntoConstraints = false
    }

    func load(adUnitId: String) {
        let trimmed = adUnitId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusText = "Ad unit ID is empty"
            return
        }

        adView?.removeFromSuperview()

        let newAdView = MAAdView(adUnitIdentifier: trimmed, adFormat: format)
        newAdView.delegate = self
        newAdView.translatesAutoresizingMaskIntoConstraints = false

        containerView.addSubview(newAdView)
        NSLayoutConstraint.activate([
            newAdView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            newAdView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            newAdView.topAnchor.constraint(equalTo: containerView.topAnchor),
            newAdView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])

        adView = newAdView
        statusText = "Loading \(format.label)..."
        newAdView.loadAd()
    }

    func didLoad(_ ad: MAAd) {
        statusText = "\(format.label) loaded"
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        statusText = "\(format.label) failed to load (\(error.code)): \(error.message)"
    }

    func didDisplay(_ ad: MAAd) {
        statusText = "\(format.label) displayed"
    }

    func didHide(_ ad: MAAd) {
        statusText = "\(format.label) hidden"
    }

    func didClick(_ ad: MAAd) {
        statusText = "\(format.label) clicked"
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        statusText = "\(format.label) display failed (\(error.code)): \(error.message)"
    }

    func didExpand(_ ad: MAAd) {}

    func didCollapse(_ ad: MAAd) {}
}

final class InterstitialAdManager: NSObject, ObservableObject, MAAdDelegate {
    @Published private(set) var statusText = "Not loaded"
    @Published private(set) var isReady = false

    private var adUnitId = ""
    private var interstitialAd: MAInterstitialAd?

    func load(adUnitId: String) {
        let trimmed = adUnitId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusText = "Ad unit ID is empty"
            isReady = false
            return
        }

        self.adUnitId = trimmed
        let ad = MAInterstitialAd(adUnitIdentifier: trimmed)
        ad.delegate = self
        interstitialAd = ad
        statusText = "Loading interstitial..."
        isReady = false
        ad.load()
    }

    func show() {
        guard isReady, let ad = interstitialAd else {
            statusText = "Interstitial is not ready"
            return
        }
        ad.show()
    }

    func didLoad(_ ad: MAAd) {
        isReady = true
        statusText = "Interstitial loaded"
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        isReady = false
        statusText = "Interstitial failed to load (\(error.code)): \(error.message)"
    }

    func didDisplay(_ ad: MAAd) {
        statusText = "Interstitial displayed"
    }

    func didHide(_ ad: MAAd) {
        isReady = false
        statusText = "Interstitial closed; reloading..."
        interstitialAd?.load()
    }

    func didClick(_ ad: MAAd) {
        statusText = "Interstitial clicked"
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        isReady = false
        statusText = "Interstitial display failed (\(error.code)): \(error.message)"
        interstitialAd?.load()
    }
}

final class RewardedAdManager: NSObject, ObservableObject, MARewardedAdDelegate {
    @Published private(set) var statusText = "Not loaded"
    @Published private(set) var isReady = false

    private var adUnitId = ""
    private var rewardedAd: MARewardedAd?

    func load(adUnitId: String) {
        let trimmed = adUnitId.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            statusText = "Ad unit ID is empty"
            isReady = false
            return
        }

        self.adUnitId = trimmed
        let ad = MARewardedAd.shared(withAdUnitIdentifier: trimmed)
        ad.delegate = self
        rewardedAd = ad
        statusText = "Loading rewarded..."
        isReady = false
        ad.load()
    }

    func show() {
        guard isReady, let ad = rewardedAd else {
            statusText = "Rewarded is not ready"
            return
        }
        ad.show()
    }

    func didLoad(_ ad: MAAd) {
        isReady = true
        statusText = "Rewarded loaded"
    }

    func didFailToLoadAd(forAdUnitIdentifier adUnitIdentifier: String, withError error: MAError) {
        isReady = false
        statusText = "Rewarded failed to load (\(error.code)): \(error.message)"
    }

    func didDisplay(_ ad: MAAd) {
        statusText = "Rewarded displayed"
    }

    func didHide(_ ad: MAAd) {
        isReady = false
        statusText = "Rewarded closed; reloading..."
        rewardedAd?.load()
    }

    func didClick(_ ad: MAAd) {
        statusText = "Rewarded clicked"
    }

    func didFail(toDisplay ad: MAAd, withError error: MAError) {
        isReady = false
        statusText = "Rewarded display failed (\(error.code)): \(error.message)"
        rewardedAd?.load()
    }

    func didStartRewardedVideo(for ad: MAAd) {
        statusText = "Rewarded video started"
    }

    func didCompleteRewardedVideo(for ad: MAAd) {
        statusText = "Rewarded video completed"
    }

    func didRewardUser(for ad: MAAd, with reward: MAReward) {
        statusText = "Reward user: \(reward.label) \(reward.amount)"
    }
}

private extension MAAdFormat {
    var label: String {
        if self == .banner { return "Banner" }
        if self == .mrec { return "MREC" }
        if self == .leader { return "Leader" }
        if self == .native { return "Native" }
        return "Ad"
    }
}
