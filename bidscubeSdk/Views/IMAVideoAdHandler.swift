import UIKit
import SwiftUI
import AVFoundation
import GoogleInteractiveMediaAds

public final class IMAVideoAdHandler: UIView {
    
    private var contentPlayer: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var adsLoader: IMAAdsLoader?
    private var adsManager: IMAAdsManager?
    private var adDisplayContainer: IMAAdDisplayContainer?
    private var contentPlayhead: IMAAVPlayerContentPlayhead?
    
    private var vastURL: String?
    private var vastXML: String?
    private var clickURL: String?
    private var placementId: String = ""
    private weak var callback: AdCallback?
    private weak var parentViewController: UIViewController?
    
    /// Interstitial vs rewarded (reward fires only after IMA `.COMPLETE` for rewarded).
    private var videoAdFormat: VideoAdFormat = .interstitial
    
    private var hasStarted = false
    private var hasCompleted = false
    private var hasEmittedClosed = false
    private var hasRewarded = false
    /// True after IMA `.SKIPPED` or after we synthesize skip for early user dismiss mid-playback.
    private var skipReported = false
    
    private var closeButton: UIButton?
    
    public init(vastURL: String, clickURL: String? = nil) {
        self.vastURL = vastURL
        self.vastXML = nil
        self.clickURL = clickURL
        super.init(frame: .zero)
        setupBasicView()
    }
    
    public init(vastXML: String, clickURL: String? = nil) {
        self.vastURL = nil
        self.vastXML = vastXML
        self.clickURL = clickURL
        super.init(frame: .zero)
        setupBasicView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setPlacementInfo(_ placementId: String, callback: AdCallback?, videoAdFormat: VideoAdFormat = .interstitial) {
        self.placementId = placementId
        self.callback = callback
        self.videoAdFormat = videoAdFormat
    }
    
    public func setParentViewController(_ viewController: UIViewController?) {
        self.parentViewController = viewController
    }
    
    public func refreshIMASetup() {
        print("🔄 IMAVideoAdHandler: Refreshing IMA setup due to view controller hierarchy change")
        
        adsManager?.destroy()
        adsManager = nil
        adDisplayContainer = nil
        
        let viewController: UIViewController? = findStableViewController() ?? createFallbackViewController()
        
        if let vc = viewController {
            adDisplayContainer = IMAAdDisplayContainer(adContainer: self, viewController: vc)
            print(" IMAVideoAdHandler: Recreated ad display container with view controller: \(type(of: vc))")
        } else {
            print("Error: IMAVideoAdHandler: Failed to find view controller for refreshed setup")
        }
    }
    
    /// Host `AdViewController` back/close taps (no reward; may synthesize skip if playback started but did not finish).
    public func userInitiatedDismissFromHost(completion: (() -> Void)? = nil) {
        userInitiatedDismiss(completion: completion)
    }

    /// Report skip once if playback has started but the creative has not completed.
    private func reportSkipIfPlaybackStartedIncomplete() {
        guard !skipReported else { return }
        guard hasStarted, !hasCompleted else { return }
        skipReported = true
        callback?.onVideoAdSkipped(placementId)
    }
    
    /// Emit `onAdClosed` at most once.
    private func emitAdClosedIfNeeded() {
        guard !hasEmittedClosed else { return }
        hasEmittedClosed = true
        callback?.onAdClosed(placementId)
    }

    private func dismissHostingViewController(completion: (() -> Void)? = nil) {
        if let viewController = findViewController() {
            if viewController.presentingViewController != nil {
                viewController.dismiss(animated: true, completion: completion)
            } else if let navigationController = viewController.navigationController,
                      navigationController.viewControllers.count > 1 {
                navigationController.popViewController(animated: true)
                completion?()
            } else {
                completion?()
            }
        } else {
            completion?()
        }
    }

    private var isUserDismissalRunning = false
    
    private func userInitiatedDismiss(completion: (() -> Void)? = nil) {
        guard !isUserDismissalRunning else {
            completion?()
            return
        }
        isUserDismissalRunning = true
        reportSkipIfPlaybackStartedIncomplete()
        emitAdClosedIfNeeded()
        cleanup()
        dismissHostingViewController(completion: completion)
    }

    /// Release IMA and player resources. Safe to call multiple times while tearing down playback.
    public func cleanup() {
        adsManager?.destroy()
        adsManager = nil
        adsLoader = nil
        adDisplayContainer = nil
        contentPlayer = nil
        playerLayer = nil
        contentPlayhead = nil
        gestureRecognizers?.forEach { removeGestureRecognizer($0) }
        backgroundColor = .clear
    }
    
    deinit {
        cleanup()
    }
    
    public func loadAd() {
        if adsLoader == nil || adDisplayContainer == nil {
            print("🔄 IMAVideoAdHandler: Setting up IMA before loading ad")
            setupIMA()
        }
        
        guard let adsLoader = adsLoader else {
            print("Error: IMAVideoAdHandler: AdsLoader not initialized")
            return
        }
        
        guard let adDisplayContainer = adDisplayContainer else {
            print("Error: IMAVideoAdHandler: AdDisplayContainer not initialized")
            return
        }
        
        print("🔍 IMAVideoAdHandler: Starting ad load...")
        print("   - AdDisplayContainer: \(adDisplayContainer)")
        print("   - ViewController: \(adDisplayContainer.adContainerViewController?.description ?? "nil")")
        
        if let vastURL = vastURL {
            let adsRequest = IMAAdsRequest(
                adTagUrl: vastURL,
                adDisplayContainer: adDisplayContainer,
                contentPlayhead: contentPlayhead,
                userContext: nil
            )
            
            adsLoader.requestAds(with: adsRequest)
        }
        else if let vastXML = vastXML {
            let dataURI = "data:application/xml;base64,\(Data(vastXML.utf8).base64EncodedString())"
            
            let adsRequest = IMAAdsRequest(
                adTagUrl: dataURI,
                adDisplayContainer: adDisplayContainer,
                contentPlayhead: contentPlayhead,
                userContext: nil
            )
            
            adsLoader.requestAds(with: adsRequest)
        } else {
            print("Error: IMAVideoAdHandler: No VAST URL or XML content provided")
            callback?.onAdFailed(placementId, errorCode: Constants.ErrorCodes.invalidAdMarkup, errorMessage: Constants.ErrorMessages.invalidAdMarkup)
        }
    }
    
    private func setupBasicView() {
        backgroundColor = .black
        isUserInteractionEnabled = true
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleAdClick))
        addGestureRecognizer(tapGesture)
        
        setupCloseButton()
    }
    
    private func setupCloseButton() {
        closeButton = UIButton(type: .system)
        closeButton?.setTitle("✕", for: .normal)
        closeButton?.setTitleColor(.white, for: .normal)
        closeButton?.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        closeButton?.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        closeButton?.layer.cornerRadius = 20
        closeButton?.layer.borderWidth = 2
        closeButton?.layer.borderColor = UIColor.white.cgColor
        closeButton?.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        closeButton?.isHidden = true
        
        if let closeButton = closeButton {
            addSubview(closeButton)
            closeButton.translatesAutoresizingMaskIntoConstraints = false
            
            NSLayoutConstraint.activate([
                closeButton.topAnchor.constraint(equalTo: topAnchor, constant: 16),
                closeButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
                closeButton.widthAnchor.constraint(equalToConstant: 40),
                closeButton.heightAnchor.constraint(equalToConstant: 40)
            ])
        }
        
        
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeGesture))
        swipeGesture.direction = .right
        addGestureRecognizer(swipeGesture)
        
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
    }
    
    private func setupIMA() {
        contentPlayer = AVPlayer()
        contentPlayhead = IMAAVPlayerContentPlayhead(avPlayer: contentPlayer!)
        
        playerLayer = AVPlayerLayer(player: contentPlayer)
        playerLayer?.videoGravity = .resizeAspect
        playerLayer?.frame = bounds
        if let layer = playerLayer {
            self.layer.addSublayer(layer)
        }
        
        let viewController: UIViewController? = findStableViewController() ?? createFallbackViewController()
        
        if let vc = viewController {
            adDisplayContainer = IMAAdDisplayContainer(adContainer: self, viewController: vc)
            print(" IMAVideoAdHandler: Using view controller: \(type(of: vc))")
            print("   - VC description: \(vc.description)")
            print("   - Parent: \(vc.parent?.description ?? "nil")")
            print("   - Nav: \(vc.navigationController?.description ?? "nil")")
        } else {
            print("Error: IMAVideoAdHandler: No view controller available for IMAAdDisplayContainer")
        }
        
        let settings = IMASettings()
        settings.enableDebugMode = true
        settings.maxRedirects = 5  
        settings.autoPlayAdBreaks = true
        settings.language = "en"
        adsLoader = IMAAdsLoader(settings: settings)
        adsLoader?.delegate = self
    }

    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    @objc private func handleAdClick() {
        print("🔍 IMAVideoAdHandler: Ad clicked for placement: \(placementId)")
        
        callback?.onAdClicked(placementId)
        
        if let clickURL = clickURL, let url = URL(string: clickURL) {
            print("🔍 IMAVideoAdHandler: Opening URL in browser: \(clickURL)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("⚠️ IMAVideoAdHandler: No click URL available")
        }
    }
    
    @objc private func closeButtonTapped() {
        print("🔍 IMAVideoAdHandler: Close button tapped")
        closeAd()
    }
    
    @objc private func handleSwipeGesture(_ gesture: UISwipeGestureRecognizer) {
        print("🔍 IMAVideoAdHandler: Swipe gesture detected")
        closeAd()
    }
    
    @objc private func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
        print("🔍 IMAVideoAdHandler: Double tap gesture detected")
        closeAd()
    }
    
    private func closeAd() {
        userInitiatedDismiss()
    }
    
    private func showCloseButton() {
        DispatchQueue.main.async {
            self.closeButton?.isHidden = false
            self.closeButton?.alpha = 0
            
            UIView.animate(withDuration: 0.3, delay: 0.5, options: .curveEaseInOut) {
                self.closeButton?.alpha = 1.0
            }
        }
    }
    
    private func hideCloseButton() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2) {
                self.closeButton?.alpha = 0
            } completion: { _ in
                self.closeButton?.isHidden = true
            }
        }
    }
    
    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                print(" IMAVideoAdHandler: Found view controller in responder chain: \(type(of: viewController))")
                
                if let hostingController = viewController as? UIHostingController<AnyView> {
                    print("   - SwiftUI hosting controller detected")
                    return hostingController
                }
                
                if let navController = viewController as? UINavigationController {
                    print("   - Navigation controller detected, using top view controller")
                    return navController.topViewController ?? navController
                }
                
                var topVC = viewController
                while let presentedVC = topVC.presentedViewController {
                    topVC = presentedVC
                }
                
                return topVC
            }
            responder = responder?.next
        }
        print("Error: IMAVideoAdHandler: No view controller found in responder chain")
        return nil
    }
    
    private func getRootViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            print("Error: IMAVideoAdHandler: No window found")
            return nil
        }
        
        guard let rootVC = window.rootViewController else {
            print("Error: IMAVideoAdHandler: No root view controller found")
            return nil
        }
        
        if let hostingController = rootVC as? UIHostingController<AnyView> {
            print(" IMAVideoAdHandler: Found SwiftUI hosting controller: \(type(of: hostingController))")
            return hostingController
        }
        
        if let navController = rootVC as? UINavigationController {
            print(" IMAVideoAdHandler: Found navigation controller, using top view controller")
            return navController.topViewController ?? navController
        }
        
        var topVC = rootVC
        while let presentedVC = topVC.presentedViewController {
            topVC = presentedVC
        }
        
        print(" IMAVideoAdHandler: Using top view controller: \(type(of: topVC))")
        return topVC
    }
    
    private func createFallbackViewController() -> UIViewController? {
        let fallbackVC = UIViewController()
        fallbackVC.view.backgroundColor = .clear
        print(" IMAVideoAdHandler: Created fallback view controller")
        return fallbackVC
    }
    
    private func findContentViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                if let navController = viewController as? UINavigationController {
                    if let topVC = navController.topViewController {
                        print(" IMAVideoAdHandler: Found content view controller in navigation: \(type(of: topVC))")
                        return topVC
                    }
                } else if !(viewController is UINavigationController) {
                    print(" IMAVideoAdHandler: Found content view controller: \(type(of: viewController))")
                    return viewController
                }
            }
            responder = responder?.next
        }
        return nil
    }
    
    private func findStableViewController() -> UIViewController? {
        let candidates = [
            parentViewController,
            findContentViewController(),
            findViewController(),
            getRootViewController()
        ]
        
        for candidate in candidates {
            if let vc = candidate {
                if vc.isViewLoaded && vc.view.window != nil {
                    print(" IMAVideoAdHandler: Found stable view controller: \(type(of: vc))")
                    return vc
                }
            }
        }
        
        for candidate in candidates {
            if let vc = candidate {
                print("⚠️ IMAVideoAdHandler: Using fallback view controller: \(type(of: vc))")
                return vc
            }
        }
        
        return nil
    }
}

extension IMAVideoAdHandler: IMAAdsLoaderDelegate {
    
    public func adsLoader(_ loader: IMAAdsLoader, adsLoadedWith adsLoadedData: IMAAdsLoadedData) {
        print(" IMAVideoAdHandler: Ads loaded successfully")
        
        adsManager = adsLoadedData.adsManager
        
        adsManager?.delegate = self
        adsManager?.initialize(with: nil)
    }
    
    public func adsLoader(_ loader: IMAAdsLoader, failedWith adErrorData: IMAAdLoadingErrorData) {
        let errorMessage = adErrorData.adError.message ?? "Unknown error"
        let errorCode = adErrorData.adError.code.rawValue
        
        print("Error: IMAVideoAdHandler: Failed to load ads: \(errorMessage)")
        print("   - Error code: \(errorCode)")
        print("   - Error type: \(adErrorData.adError.type)")
        
        
        var userFriendlyMessage = errorMessage
        
        
        if errorMessage.contains("VAST") || errorMessage.contains("No Ads") {
            userFriendlyMessage = "No ads available for this placement. The ad type could be mismatch, try different placementId"
        } else if errorMessage.contains("timeout") {
            userFriendlyMessage = "Ad loading timeout. Please check your network connection"
        } else if errorMessage.contains("malformed") {
            userFriendlyMessage = "Invalid ad response format"
        } else if errorMessage.contains("redirect") {
            userFriendlyMessage = "Too many ad redirects. Please try again"
        } else if errorMessage.contains("network") {
            userFriendlyMessage = "Network error. Please check your internet connection"
        } else if errorMessage.contains("load") {
            userFriendlyMessage = "Ad loading failed. Please try again"
        } else if errorMessage.contains("play") {
            userFriendlyMessage = "Ad playback failed"
        } else {
            
            userFriendlyMessage = errorMessage
        }
        
        cleanup()
        callback?.onAdFailed(placementId, errorCode: errorCode, errorMessage: userFriendlyMessage)
    }
}

extension IMAVideoAdHandler: IMAAdsManagerDelegate {
    
    public func adsManager(_ adsManager: IMAAdsManager, didReceive event: IMAAdEvent) {
        print("🎯 IMAVideoAdHandler: Ad event: \(event.type)")
        
        switch event.type {
        case .LOADED:
            print("📺 IMAVideoAdHandler: Ad loaded, starting playback")
            print("   - AdDisplayContainer: \(adDisplayContainer?.description ?? "nil")")
            print("   - ViewController: \(adDisplayContainer?.adContainerViewController?.description ?? "nil")")
            callback?.onAdLoaded(placementId)
            adsManager.start()
            
        case .STARTED:
            guard !hasStarted else { break }
            hasStarted = true
            print("▶️ IMAVideoAdHandler: Ad started playing")
            callback?.onAdDisplayed(placementId)
            callback?.onVideoAdStarted(placementId)
            hideCloseButton()
            
            
            if let adViewController = findViewController() as? AdViewController {
                adViewController.setVideoPlayingState(true)
                adViewController.disableSwipeGestures()
            }
            
        case .COMPLETE:
            guard !hasCompleted else { break }
            hasCompleted = true
            print("🏁 IMAVideoAdHandler: Ad completed")
            callback?.onVideoAdCompleted(placementId)
            if videoAdFormat == .rewarded && !hasRewarded {
                hasRewarded = true
                callback?.onUserRewarded(placementId)
            }
            showCloseButton()
            
            
            if let adViewController = findViewController() as? AdViewController {
                adViewController.setVideoPlayingState(false)
                adViewController.enableSwipeGestures()
                adViewController.showBackButtonOnVideoComplete()
            }
            
        case .SKIPPED:
            guard !skipReported else { break }
            skipReported = true
            print("⏭️ IMAVideoAdHandler: Ad skipped")
            callback?.onVideoAdSkipped(placementId)
            showCloseButton()
            
            
            if let adViewController = findViewController() as? AdViewController {
                adViewController.setVideoPlayingState(false)
                adViewController.enableSwipeGestures()
                adViewController.showBackButtonOnVideoComplete()
            }
            
        case .CLICKED:
            print("🖱️ IMAVideoAdHandler: Ad clicked")
            callback?.onAdClicked(placementId)
            
        case .PAUSE:
            print("⏸️ IMAVideoAdHandler: Ad paused")
            
            
            if let adViewController = findViewController() as? AdViewController {
                adViewController.setVideoPlayingState(false)
                adViewController.enableSwipeGestures()
            }
            
        case .RESUME:
            print("▶️ IMAVideoAdHandler: Ad resumed")
            
            
            if let adViewController = findViewController() as? AdViewController {
                adViewController.setVideoPlayingState(true)
                adViewController.disableSwipeGestures()
            }
            
        default:
            print("Info: IMAVideoAdHandler: Other ad event: \(event.type)")
        }
    }
    
    public func adsManager(_ adsManager: IMAAdsManager, didReceive error: IMAAdError) {
        let message = error.message ?? Constants.ErrorMessages.invalidResponse
        print("Error: IMAVideoAdHandler: Ad error: \(message)")
        cleanup()
        callback?.onAdFailed(placementId, errorCode: error.code.rawValue, errorMessage: message)
    }
    
    public func adsManagerDidRequestContentPause(_ adsManager: IMAAdsManager) {
        print("⏸️ IMAVideoAdHandler: Content pause requested")
        contentPlayer?.pause()
    }
    
    public func adsManagerDidRequestContentResume(_ adsManager: IMAAdsManager) {
        print("▶️ IMAVideoAdHandler: Content resume requested")
        contentPlayer?.play()
    }
}
