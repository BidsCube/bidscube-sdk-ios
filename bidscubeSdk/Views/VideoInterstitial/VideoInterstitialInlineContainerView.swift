import UIKit

/// Inline host for interstitial video with preview end card (non-modal embedding).
final class VideoInterstitialInlineContainerView: UIView {

    private let placementId: String
    private weak var callback: AdCallback?
    private var childController: VideoInterstitialViewController?

    init(placementId: String, callback: AdCallback?) {
        self.placementId = placementId
        self.callback = callback
        super.init(frame: .zero)
        backgroundColor = .black
        clipsToBounds = true
        layer.cornerRadius = 6
        loadContent()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setParentViewController(_ viewController: UIViewController?) {
        guard let viewController, let childController else { return }
        embedChild(childController, in: viewController)
    }

    private func loadContent() {
        callback?.onAdLoading(placementId)
        guard let url = BidscubeSDK.buildRequestURL(placementId: placementId, adType: .video) else {
            callback?.onAdFailed(placementId, errorCode: Constants.ErrorCodes.invalidURL, errorMessage: Constants.ErrorMessages.failedToBuildURL)
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self else { return }
                if let error {
                    self.callback?.onAdFailed(self.placementId, errorCode: Constants.ErrorCodes.networkError, errorMessage: error.localizedDescription)
                    return
                }
                guard let data,
                      let content = String(data: data, encoding: .utf8),
                      let payload = VideoInterstitialInlineContainerView.resolvePayload(from: content) else {
                    self.callback?.onAdFailed(self.placementId, errorCode: Constants.ErrorCodes.invalidAdMarkup, errorMessage: Constants.ErrorMessages.invalidAdMarkup)
                    return
                }

                self.callback?.onAdLoaded(self.placementId)

                let controller = VideoInterstitialViewController(
                    placementId: self.placementId,
                    metadata: payload.metadata,
                    adTagUrl: payload.adTagUrl,
                    adsResponse: payload.adsResponse,
                    vastXmlForSkipParsing: payload.vastXml,
                    isEmbedded: true,
                    callback: self.callback
                )
                self.childController = controller
                if let parent = self.findViewController() {
                    self.embedChild(controller, in: parent)
                }
            }
        }.resume()
    }

    private func embedChild(_ controller: VideoInterstitialViewController, in parent: UIViewController) {
        parent.addChild(controller)
        controller.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(controller.view)
        NSLayoutConstraint.activate([
            controller.view.topAnchor.constraint(equalTo: topAnchor),
            controller.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            controller.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            controller.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        controller.didMove(toParent: parent)
    }

    private func findViewController() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            responder = responder?.next
        }
        return nil
    }

    private struct Payload {
        let metadata: VideoInterstitialMetadata
        let adTagUrl: String?
        let adsResponse: String?
        let vastXml: String?
    }

    private static func resolvePayload(from content: String) -> Payload? {
        let config = BidscubeSDK.getConfiguration()
        guard let resolved = VideoAdPayloadResolver.resolve(content: content, config: config) else {
            return nil
        }

        return Payload(
            metadata: resolved.metadata,
            adTagUrl: resolved.adTagUrl,
            adsResponse: resolved.adsResponse,
            vastXml: resolved.vastXml ?? resolved.adsResponse
        )
    }
}
