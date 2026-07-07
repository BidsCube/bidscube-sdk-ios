import UIKit

enum VideoInterstitialContent {
    case inlineVAST(String)
    case adTagUrl(String)
}

enum VideoInterstitialPresenter {

    static func present(
        placementId: String,
        from viewController: UIViewController,
        callback: AdCallback?
    ) {
        callback?.onAdLoading(placementId)
        loadContent(placementId: placementId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let payload):
                    callback?.onAdLoaded(placementId)
                    let interstitial = VideoInterstitialViewController(
                        placementId: placementId,
                        metadata: payload.metadata,
                        adTagUrl: payload.adTagUrl,
                        adsResponse: payload.adsResponse,
                        vastXmlForSkipParsing: payload.vastXml,
                        callback: callback
                    )
                    viewController.present(interstitial, animated: true)
                case .failure(let error):
                    callback?.onAdFailed(placementId, errorCode: error.code, errorMessage: error.message)
                }
            }
        }
    }

    static func push(
        placementId: String,
        onto navigationController: UINavigationController,
        callback: AdCallback?
    ) {
        callback?.onAdLoading(placementId)
        loadContent(placementId: placementId) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let payload):
                    callback?.onAdLoaded(placementId)
                    let interstitial = VideoInterstitialViewController(
                        placementId: placementId,
                        metadata: payload.metadata,
                        adTagUrl: payload.adTagUrl,
                        adsResponse: payload.adsResponse,
                        vastXmlForSkipParsing: payload.vastXml,
                        callback: callback
                    )
                    navigationController.pushViewController(interstitial, animated: true)
                case .failure(let error):
                    callback?.onAdFailed(placementId, errorCode: error.code, errorMessage: error.message)
                }
            }
        }
    }

    static func presentTestInterstitial(
        content: VideoInterstitialContent,
        metadata: VideoInterstitialMetadata = VideoInterstitialMetadata(),
        from viewController: UIViewController,
        placementId: String = "test-interstitial",
        callback: AdCallback?
    ) {
        let interstitial: VideoInterstitialViewController
        switch content {
        case .inlineVAST(let vast):
            interstitial = VideoInterstitialViewController(
                placementId: placementId,
                metadata: metadata,
                adsResponse: vast,
                vastXmlForSkipParsing: vast,
                callback: callback
            )
        case .adTagUrl(let url):
            interstitial = VideoInterstitialViewController(
                placementId: placementId,
                metadata: metadata,
                adTagUrl: url,
                callback: callback
            )
        }
        viewController.present(interstitial, animated: true)
    }

    /// Shows only the preview/end-card screen (no video). For QA layout checks.
    static func presentTestEndCardPreview(
        metadata: VideoInterstitialMetadata,
        from viewController: UIViewController,
        placementId: String = "test-end-card-preview",
        callback: AdCallback?
    ) {
        let preview = VideoInterstitialEndCardPreviewViewController(
            placementId: placementId,
            metadata: metadata,
            callback: callback
        )
        viewController.present(preview, animated: true)
    }

    /// Parses VAST metadata and shows preview/end-card screen only.
    static func presentTestEndCardPreview(
        vastXML: String,
        from viewController: UIViewController,
        metadata: VideoInterstitialMetadata? = nil,
        placementId: String = "test-end-card-preview",
        callback: AdCallback?
    ) {
        let resolved = metadata ?? VastMetadataParser.parse(vastXML)
        presentTestEndCardPreview(
            metadata: resolved,
            from: viewController,
            placementId: placementId,
            callback: callback
        )
    }

    private struct LoadedPayload {
        let metadata: VideoInterstitialMetadata
        let adTagUrl: String?
        let adsResponse: String?
        let vastXml: String?
    }

    private struct LoadError: Error {
        let code: Int
        let message: String
    }

    private static func loadContent(
        placementId: String,
        completion: @escaping (Result<LoadedPayload, LoadError>) -> Void
    ) {
        guard let url = BidscubeSDK.buildRequestURL(placementId: placementId, adType: .video) else {
            completion(.failure(LoadError(code: Constants.ErrorCodes.invalidURL, message: Constants.ErrorMessages.failedToBuildURL)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error {
                completion(.failure(LoadError(code: Constants.ErrorCodes.networkError, message: error.localizedDescription)))
                return
            }

            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                completion(.failure(LoadError(code: Constants.ErrorCodes.invalidResponse, message: "Invalid HTTP response (\(http.statusCode))")))
                return
            }

            guard let data, !data.isEmpty, let content = String(data: data, encoding: .utf8) else {
                completion(.failure(LoadError(code: Constants.ErrorCodes.invalidResponse, message: Constants.ErrorMessages.invalidResponse)))
                return
            }

            let payload = resolvePayload(from: content)
            guard payload != nil else {
                completion(.failure(LoadError(code: Constants.ErrorCodes.invalidAdMarkup, message: Constants.ErrorMessages.invalidAdMarkup)))
                return
            }
            completion(.success(payload!))
        }.resume()
    }

    private static func resolvePayload(from content: String) -> LoadedPayload? {
        let config = BidscubeSDK.getConfiguration()
        guard let resolved = VideoAdPayloadResolver.resolve(content: content, config: config) else {
            return nil
        }

        return LoadedPayload(
            metadata: resolved.metadata,
            adTagUrl: resolved.adTagUrl,
            adsResponse: resolved.adsResponse,
            vastXml: resolved.vastXml ?? resolved.adsResponse
        )
    }
}
