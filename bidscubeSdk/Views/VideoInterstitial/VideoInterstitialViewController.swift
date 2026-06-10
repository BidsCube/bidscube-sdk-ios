import UIKit

enum VideoInterstitialState {
    case idle
    case loading
    case playing
    case skippable
    case skipped
    case completed
    case showingEndCard
    case closed
    case failed
}

final class VideoInterstitialViewController: UIViewController {

    private enum SessionEnd {
        case none
        case completed
        case skipped
        case failed
    }

    private let placementId: String
    private let metadata: VideoInterstitialMetadata
    private weak var callback: AdCallback?

    private let adTagUrl: String?
    private let adsResponse: String?
    private let vastXmlForSkipParsing: String?
    private let isEmbedded: Bool

    private var state: VideoInterstitialState = .idle
    private var sessionEnd: SessionEnd = .none

    private var endCardShown = false
    private var skippableCallbackEmitted = false
    private var closedCallbackEmitted = false
    private var clickCallbackEmitted = false
    private var displayedCallbackEmitted = false

    private let videoContainer = UIView()
    private var imaPlayer: IMAVideoInterstitialPlayer?
    private let skipOverlay = VideoInterstitialOverlayView()
    private var endCardView: VideoInterstitialEndCardView?
    private var hasStartedPlayback = false
    private var videoPhaseFinished = false

    private var hasPreviewEndCard: Bool {
        metadata.previewImageUrl != nil
    }

    init(
        placementId: String,
        metadata: VideoInterstitialMetadata,
        adTagUrl: String? = nil,
        adsResponse: String? = nil,
        vastXmlForSkipParsing: String? = nil,
        isEmbedded: Bool = false,
        callback: AdCallback?
    ) {
        self.placementId = placementId
        self.metadata = metadata
        self.adTagUrl = adTagUrl
        self.adsResponse = adsResponse
        self.vastXmlForSkipParsing = vastXmlForSkipParsing ?? adsResponse
        self.isEmbedded = isEmbedded
        self.callback = callback
        super.init(nibName: nil, bundle: nil)
        if !isEmbedded {
            modalPresentationStyle = .fullScreen
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        imaPlayer?.destroy()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupVideoPhase()
        transition(to: .loading)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        emitDisplayedIfNeeded()
        startPlaybackIfNeeded()
    }

    private func setupVideoPhase() {
        videoContainer.translatesAutoresizingMaskIntoConstraints = false
        videoContainer.backgroundColor = .black
        view.addSubview(videoContainer)

        skipOverlay.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(skipOverlay)

        NSLayoutConstraint.activate([
            videoContainer.topAnchor.constraint(equalTo: view.topAnchor),
            videoContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            videoContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            videoContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            skipOverlay.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 14),
            skipOverlay.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -14)
        ])

        skipOverlay.onSkipTapped = { [weak self] in
            self?.handleSkipTapped()
        }
        skipOverlay.onCloseTapped = { [weak self] in
            self?.handleVideoCloseTapped()
        }
        skipOverlay.onSkipEnabled = { [weak self] in
            self?.handleSkipBecameActive()
        }
        skipOverlay.isHidden = true
    }

    private func startPlaybackIfNeeded() {
        guard !hasStartedPlayback else { return }
        hasStartedPlayback = true
        startPlayback()
    }

    private func startPlayback() {
        let player: IMAVideoInterstitialPlayer
        if let adsResponse {
            player = IMAVideoInterstitialPlayer(adsResponse: adsResponse, hostViewController: self)
        } else if let adTagUrl {
            player = IMAVideoInterstitialPlayer(adTagUrl: adTagUrl, hostViewController: self)
        } else {
            fail(code: Constants.ErrorCodes.invalidAdMarkup, message: Constants.ErrorMessages.invalidAdMarkup)
            return
        }

        player.delegate = self
        player.translatesAutoresizingMaskIntoConstraints = false
        videoContainer.addSubview(player)
        NSLayoutConstraint.activate([
            player.topAnchor.constraint(equalTo: videoContainer.topAnchor),
            player.leadingAnchor.constraint(equalTo: videoContainer.leadingAnchor),
            player.trailingAnchor.constraint(equalTo: videoContainer.trailingAnchor),
            player.bottomAnchor.constraint(equalTo: videoContainer.bottomAnchor)
        ])

        imaPlayer = player
        player.loadAd()
    }

    private func handleSkipBecameActive() {
        imaPlayer?.markSkipOffsetReached()
        emitSkippableIfNeeded()
    }

    private func handleSkipTapped() {
        guard state == .playing || state == .skippable else { return }
        guard sessionEnd == .none else { return }
        imaPlayer?.skip()
    }

    private func handleVideoCloseTapped() {
        guard hasPreviewEndCard else { return }
        guard sessionEnd == .none else {
            dismissInterstitial()
            return
        }
        finishVideoPhase(skipped: true)
    }

    func openLandingPage() {
        guard !clickCallbackEmitted else { return }
        guard let url = metadata.clickUrl else { return }
        clickCallbackEmitted = true
        callback?.onAdClicked(placementId)
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func showEndCard() {
        guard hasPreviewEndCard else { return }
        guard !endCardShown else { return }
        endCardShown = true
        transition(to: .showingEndCard)

        let endCard = VideoInterstitialEndCardView(metadata: metadata)
        endCard.translatesAutoresizingMaskIntoConstraints = false
        endCard.onPreviewTapped = { [weak self] in self?.openLandingPage() }
        endCard.onCTATapped = { [weak self] in self?.openLandingPage() }
        endCard.onCloseTapped = { [weak self] in self?.dismissInterstitial() }

        view.addSubview(endCard)
        NSLayoutConstraint.activate([
            endCard.topAnchor.constraint(equalTo: view.topAnchor),
            endCard.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            endCard.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            endCard.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        endCardView = endCard
        videoContainer.isHidden = true
        view.bringSubviewToFront(endCard)
        callback?.onEndCardShown(placementId)
    }

    private func resolvedSkipOffsetSeconds() -> Int {
        guard hasPreviewEndCard else { return 0 }
        let parsedSkip = vastXmlForSkipParsing.map { VastMetadataParser.extractSkipOffsetSeconds(from: $0) } ?? 0
        if parsedSkip > 0 { return parsedSkip }
        return metadata.skipOffsetSeconds
    }

    private func finishVideoPhase(skipped: Bool) {
        guard !videoPhaseFinished else { return }
        videoPhaseFinished = true

        if skipped {
            markSkippedIfNeeded()
            transition(to: .skipped)
        } else {
            markCompletedIfNeeded()
            transition(to: .completed)
        }

        imaPlayer?.destroy()
        imaPlayer?.removeFromSuperview()
        imaPlayer = nil
        skipOverlay.hideOverlay()

        if hasPreviewEndCard {
            showEndCard()
        } else {
            dismissInterstitial()
        }
    }

    private func dismissInterstitial() {
        guard !closedCallbackEmitted else { return }
        closedCallbackEmitted = true
        transition(to: .closed)
        imaPlayer?.destroy()
        callback?.onAdClosed(placementId)

        if isEmbedded {
            willMove(toParent: nil)
            view.removeFromSuperview()
            removeFromParent()
            return
        }

        if presentingViewController != nil {
            dismiss(animated: true)
        } else if let navigationController, navigationController.viewControllers.count > 1 {
            navigationController.popViewController(animated: true)
        }
    }

    private func emitDisplayedIfNeeded() {
        guard !displayedCallbackEmitted else { return }
        displayedCallbackEmitted = true
        callback?.onAdDisplayed(placementId)
    }

    private func markCompletedIfNeeded() {
        guard sessionEnd == .none else { return }
        sessionEnd = .completed
        callback?.onVideoAdCompleted(placementId)
    }

    private func markSkippedIfNeeded() {
        guard sessionEnd == .none else { return }
        sessionEnd = .skipped
        callback?.onVideoAdSkipped(placementId)
    }

    private func emitSkippableIfNeeded() {
        guard !skippableCallbackEmitted else { return }
        skippableCallbackEmitted = true
        transition(to: .skippable)
        callback?.onVideoAdSkippable(placementId)
    }

    private func fail(code: Int, message: String) {
        guard sessionEnd == .none else { return }
        sessionEnd = .failed
        transition(to: .failed)
        imaPlayer?.destroy()
        callback?.onAdFailed(placementId, errorCode: code, errorMessage: message)
        dismissInterstitial()
    }

    private func transition(to newState: VideoInterstitialState) {
        state = newState
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        guard isBeingDismissed || isMovingFromParent else { return }

        if sessionEnd == .none {
            markSkippedIfNeeded()
        }
        if !closedCallbackEmitted {
            closedCallbackEmitted = true
            callback?.onAdClosed(placementId)
        }
        imaPlayer?.destroy()
    }
}

extension VideoInterstitialViewController: IMAVideoInterstitialPlayerDelegate {
    func imaPlayerDidLoadAd() {
        // `onAdLoaded` is emitted before presentation by `VideoInterstitialPresenter` / inline loader.
    }

    func imaPlayerDidStart() {
        transition(to: .playing)
        callback?.onVideoAdStarted(placementId)

        if hasPreviewEndCard {
            skipOverlay.isHidden = false
            skipOverlay.startSkipCountdown(resolvedSkipOffsetSeconds())
        } else {
            skipOverlay.hideOverlay()
        }
    }

    func imaPlayerDidComplete() {
        finishVideoPhase(skipped: false)
    }

    func imaPlayerDidSkip() {
        finishVideoPhase(skipped: true)
    }

    func imaPlayerDidFail(code: Int, message: String) {
        fail(code: code, message: message)
    }
}
