import UIKit

/// Fullscreen preview/end-card screen only (test & QA — no video phase).
final class VideoInterstitialEndCardPreviewViewController: UIViewController {

    private let placementId: String
    private let metadata: VideoInterstitialMetadata
    private weak var callback: AdCallback?

    private var clickCallbackEmitted = false
    private var closedCallbackEmitted = false
    private var endCardShownEmitted = false

    init(
        placementId: String,
        metadata: VideoInterstitialMetadata,
        callback: AdCallback?
    ) {
        self.placementId = placementId
        self.metadata = metadata
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .fullScreen
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let endCard = VideoInterstitialEndCardView(metadata: metadata)
        endCard.translatesAutoresizingMaskIntoConstraints = false
        endCard.onPreviewTapped = { [weak self] in self?.openLandingPage() }
        endCard.onCTATapped = { [weak self] in self?.openLandingPage() }
        endCard.onCloseTapped = { [weak self] in self?.dismissPreview() }

        view.addSubview(endCard)
        NSLayoutConstraint.activate([
            endCard.topAnchor.constraint(equalTo: view.topAnchor),
            endCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            endCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            endCard.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard !endCardShownEmitted else { return }
        endCardShownEmitted = true
        callback?.onEndCardShown(placementId)
    }

    private func openLandingPage() {
        guard !clickCallbackEmitted else { return }
        guard let url = metadata.clickUrl else { return }
        clickCallbackEmitted = true
        callback?.onAdClicked(placementId)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func dismissPreview() {
        guard !closedCallbackEmitted else { return }
        closedCallbackEmitted = true
        callback?.onAdClosed(placementId)
        dismiss(animated: true)
    }
}
