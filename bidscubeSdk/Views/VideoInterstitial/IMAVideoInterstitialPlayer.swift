import UIKit
import AVFoundation
import GoogleInteractiveMediaAds

protocol IMAVideoInterstitialPlayerDelegate: AnyObject {
    func imaPlayerDidLoadAd()
    func imaPlayerDidStart()
    func imaPlayerDidComplete()
    func imaPlayerDidSkip()
    func imaPlayerDidFail(code: Int, message: String)
}

final class IMAVideoInterstitialPlayer: UIView {

    weak var delegate: IMAVideoInterstitialPlayerDelegate?

    private var contentPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var adsLoader: IMAAdsLoader?
    private var adsManager: IMAAdsManager?
    private var adDisplayContainer: IMAAdDisplayContainer?
    private var contentPlayhead: IMAAVPlayerContentPlayhead?

    private let adTagUrl: String?
    private let adsResponse: String?
    private weak var hostViewController: UIViewController?

    private(set) var isPlaying = false
    private(set) var isSkippableAd = false
    private(set) var skipOffsetReached = false
    private var hasStarted = false
    private var endEventNotified = false

    init(adTagUrl: String, hostViewController: UIViewController) {
        self.adTagUrl = adTagUrl
        self.adsResponse = nil
        self.hostViewController = hostViewController
        super.init(frame: .zero)
        commonInit()
    }

    init(adsResponse: String, hostViewController: UIViewController) {
        self.adTagUrl = nil
        self.adsResponse = adsResponse
        self.hostViewController = hostViewController
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        destroy()
    }

    func loadAd() {
        setupIMAIfNeeded()
        guard let adsLoader, let adDisplayContainer else {
            delegate?.imaPlayerDidFail(code: Constants.ErrorCodes.invalidAdMarkup, message: Constants.ErrorMessages.invalidAdMarkup)
            return
        }

        let request: IMAAdsRequest
        if let adsResponse {
            // Match `IMAVideoAdHandler`: inline VAST via data URI is more reliable than `adsResponse`.
            let dataURI = "data:application/xml;base64,\(Data(adsResponse.utf8).base64EncodedString())"
            request = IMAAdsRequest(
                adTagUrl: dataURI,
                adDisplayContainer: adDisplayContainer,
                contentPlayhead: contentPlayhead,
                userContext: nil
            )
        } else if let adTagUrl {
            request = IMAAdsRequest(
                adTagUrl: adTagUrl,
                adDisplayContainer: adDisplayContainer,
                contentPlayhead: contentPlayhead,
                userContext: nil
            )
        } else {
            delegate?.imaPlayerDidFail(code: Constants.ErrorCodes.invalidAdMarkup, message: Constants.ErrorMessages.invalidAdMarkup)
            return
        }

        adsLoader.requestAds(with: request)
    }

    func markSkipOffsetReached() {
        skipOffsetReached = true
    }

    func skip() {
        guard skipOffsetReached, !endEventNotified else { return }
        if isSkippableAd {
            adsManager?.skip()
        }
        notifySkipped()
    }

    private func notifySkipped() {
        guard !endEventNotified else { return }
        endEventNotified = true
        isPlaying = false
        adsManager?.destroy()
        adsManager = nil
        delegate?.imaPlayerDidSkip()
    }

    private func notifyCompleted() {
        guard !endEventNotified else { return }
        endEventNotified = true
        isPlaying = false
        adsManager?.destroy()
        adsManager = nil
        delegate?.imaPlayerDidComplete()
    }

    func destroy() {
        isPlaying = false
        adsManager?.destroy()
        adsManager = nil
        adsLoader = nil
        adDisplayContainer = nil
        contentPlayer = nil
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        contentPlayhead = nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }

    private func commonInit() {
        backgroundColor = .black
        isUserInteractionEnabled = true
    }

    private func setupIMAIfNeeded() {
        guard adsLoader == nil else { return }

        try? AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
        try? AVAudioSession.sharedInstance().setActive(true)

        contentPlayer = AVPlayer()
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer!)
        playerLayer = AVPlayerLayer(player: contentPlayer)
        playerLayer?.videoGravity = .resizeAspect
        if let playerLayer {
            layer.addSublayer(playerLayer)
        }

        guard let hostViewController else {
            delegate?.imaPlayerDidFail(code: Constants.ErrorCodes.presenterUnavailable, message: Constants.ErrorMessages.presenterUnavailable)
            return
        }

        adDisplayContainer = IMAAdDisplayContainer(adContainer: self, viewController: hostViewController)

        let settings = IMASettings()
        settings.enableDebugMode = false
        settings.maxRedirects = 5
        settings.autoPlayAdBreaks = true
        adsLoader = IMAAdsLoader(settings: settings)
        adsLoader?.delegate = self
    }

    private func makeRenderingSettings() -> IMAAdsRenderingSettings {
        let settings = IMAAdsRenderingSettings()
        settings.uiElements = []
        settings.disableUi = true
        settings.linkOpenerPresentingController = hostViewController
        return settings
    }
}

extension IMAVideoInterstitialPlayer: IMAAdsLoaderDelegate {
    func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        adsManager = adsLoadedData.adsManager
        adsManager?.delegate = self
        adsManager?.initialize(with: makeRenderingSettings())
        delegate?.imaPlayerDidLoadAd()
    }

    func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        let message = adErrorData.adError.message ?? Constants.ErrorMessages.invalidResponse
        let code = adErrorData.adError.code.rawValue
        destroy()
        delegate?.imaPlayerDidFail(code: code, message: message)
    }
}

extension IMAVideoInterstitialPlayer: IMAAdsManagerDelegate {
    func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        switch event.type {
        case .LOADED:
            adsManager.start()
        case .STARTED:
            guard !hasStarted else { break }
            hasStarted = true
            isPlaying = true
            isSkippableAd = event.ad?.isSkippable ?? isSkippableAd
            delegate?.imaPlayerDidStart()
        case .COMPLETE:
            notifyCompleted()
        case .SKIPPED:
            notifySkipped()
        default:
            break
        }
    }

    func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        let message = error.message ?? Constants.ErrorMessages.invalidResponse
        destroy()
        delegate?.imaPlayerDidFail(code: error.code.rawValue, message: message)
    }

    func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        contentPlayer?.pause()
    }

    func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        contentPlayer?.play()
    }
}
