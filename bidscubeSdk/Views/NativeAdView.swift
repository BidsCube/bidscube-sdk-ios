import UIKit
import bidscubeSdk

struct NativeAdData: Codable {
    let native: NativeAdContent
}

struct NativeAdContent: Codable {
    let ver: String
    let assets: [NativeAdAsset]
    let link: NativeAdLink
    let imptrackers: [String]
}

struct NativeAdAsset: Codable {
    let id: Int
    let title: NativeAdTitle?
    let data: NativeAdDataValue?
    let img: NativeAdImage?
}

struct NativeAdTitle: Codable {
    let text: String
}

struct NativeAdDataValue: Codable {
    let value: String
}

struct NativeAdImage: Codable {
    let url: String
    let w: Int
    let h: Int
}

struct NativeAdLink: Codable {
    let url: String
    let clicktrackers: [String]
}

public final class NativeAdView: UIView {
    private let titleLabel = UILabel()
    private let priceLabel = UILabel()
    private let ctaButton = UIButton(type: .system)
    private let adImageView = UIImageView()
    private let iconImageView = UIImageView()
    private let loadingLabel = UILabel()
    private var clickURL: String?
    private var placementId: String = ""
    private weak var callback: AdCallback?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 8
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor

        loadingLabel.text = "Loading Native Ad..."
        loadingLabel.textAlignment = .center
        loadingLabel.textColor = .white
        loadingLabel.backgroundColor = .black.withAlphaComponent(0.7)
        loadingLabel.layer.cornerRadius = 4
        loadingLabel.clipsToBounds = true

        titleLabel.text = "Bidscube Native Ad"
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        priceLabel.text = ""
        priceLabel.textAlignment = .left
        priceLabel.font = UIFont.systemFont(ofSize: 14)
        priceLabel.textColor = .systemGreen
        priceLabel.translatesAutoresizingMaskIntoConstraints = false

        adImageView.contentMode = .scaleAspectFill
        adImageView.clipsToBounds = true
        adImageView.backgroundColor = .lightGray
        adImageView.layer.cornerRadius = 4
        adImageView.translatesAutoresizingMaskIntoConstraints = false
        
        let placeholderImage = UIImage(systemName: "photo") ?? UIImage()
        adImageView.image = placeholderImage
        adImageView.tintColor = .gray
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        iconImageView.backgroundColor = .clear
        iconImageView.layer.cornerRadius = 2
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.isHidden = true 

        ctaButton.setTitle("Install Now", for: .normal)
        ctaButton.backgroundColor = .systemBlue
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 6
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.addTarget(self, action: #selector(ctaButtonTapped), for: .touchUpInside)

        addSubview(adImageView)
        addSubview(iconImageView)
        addSubview(titleLabel)
        addSubview(priceLabel)
        addSubview(ctaButton)
        addSubview(loadingLabel)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(adTapped))
        addGestureRecognizer(tapGesture)
        isUserInteractionEnabled = true

        NSLayoutConstraint.activate([
            adImageView.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            adImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            adImageView.widthAnchor.constraint(equalToConstant: 80),
            adImageView.heightAnchor.constraint(equalToConstant: 80),
            
            iconImageView.topAnchor.constraint(equalTo: adImageView.bottomAnchor, constant: 4),
            iconImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            iconImageView.widthAnchor.constraint(equalToConstant: 20),
            iconImageView.heightAnchor.constraint(equalToConstant: 20),

            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: adImageView.trailingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            priceLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 4),
            priceLabel.leadingAnchor.constraint(equalTo: adImageView.trailingAnchor, constant: 8),
            priceLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            ctaButton.topAnchor.constraint(equalTo: priceLabel.bottomAnchor, constant: 8),
            ctaButton.leadingAnchor.constraint(equalTo: adImageView.trailingAnchor, constant: 8),
            ctaButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),

            loadingLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingLabel.widthAnchor.constraint(equalToConstant: 150),
            loadingLabel.heightAnchor.constraint(equalToConstant: 30)
        ])
    }

    public func setPlacementInfo(_ placementId: String, callback: AdCallback?) {
        self.placementId = placementId
        self.callback = callback
    }
    
    public func testWithExampleResponse() {
        let exampleResponse = """
        {
            "adm": "{\\"native\\":{\\"ver\\":\\"1.1\\",\\"assets\\":[{\\"id\\":2,\\"title\\":{\\"text\\":\\"High Performance Wall Cutter Concrete Cutter Semi-Automatic Wall Cutter\\"}},{\\"id\\":6,\\"data\\":{\\"value\\":\\"$795.00\\"}},{\\"id\\":1,\\"data\\":{\\"value\\":\\"source now\\"}},{\\"id\\":4,\\"img\\":{\\"url\\":\\"https:
            "position": 0
        }
        """
        
        print("🧪 NativeAdView: Testing with example response")
        loadNativeAdContent(exampleResponse)
    }
    
    public func testWithDirectAdm() {
        let directAdm = """
        {"native":{"ver":"1.1","assets":[{"id":2,"title":{"text":"High Performance Wall Cutter Concrete Cutter Semi-Automatic Wall Cutter"}},{"id":6,"data":{"value":"$795.00"}},{"id":1,"data":{"value":"source now"}},{"id":4,"img":{"url":"https:
        """
        
        print("🧪 NativeAdView: Testing with direct ADM (Android-style)")
        parseAdmField(directAdm)
    }
    
    public func testWithDirectNativeAdJSON() {
        let directNativeAdJSON = """
        {"native":{"ver":"1.1","assets":[{"id":2,"title":{"text":"High Performance Wall Cutter Concrete Cutter Semi-Automatic Wall Cutter"}},{"id":6,"data":{"value":"$795.00"}},{"id":1,"data":{"value":"source now"}},{"id":4,"img":{"url":"https:
        """
        
        print("🧪 NativeAdView: Testing with direct native ad JSON")
        loadNativeAdContent(directNativeAdJSON)
    }
    
    public func loadNativeAdContent(_ jsonString: String) {
        print("🔍 NativeAdView: Loading native ad content from JSON string")
        print("📄 NativeAdView: JSON content: \(jsonString)")
        
        loadingLabel.isHidden = false
        
        do {
            let data = jsonString.data(using: .utf8) ?? Data()
            print("🔍 NativeAdView: JSON data size: \(data.count) bytes")
            
            if let outerJson = try JSONSerialization.jsonObject(with: data) as? [String: Any],
               let admString = outerJson["adm"] as? String {
                print(" NativeAdView: Found adm field in outer JSON")
                print("📄 NativeAdView: ADM content: \(admString)")
                
                parseAdmField(admString)
                
            } else {
                print("⚠️ NativeAdView: No adm field found, trying direct parsing")
                parseAdmField(jsonString)
            }
            
        } catch {
            print("Error: NativeAdView: Error parsing native ad JSON: \(error)")
            print("Error: NativeAdView: JSON string was: \(jsonString)")
            loadingLabel.text = "Error loading ad"
        }
    }
    
    private func parseAdmField(_ admString: String) {
        print("🔍 NativeAdView: Parsing ADM field: \(String(admString.prefix(100)))...")
        
        guard let admData = admString.data(using: .utf8) else {
            print("Error: NativeAdView: Failed to convert ADM string to data")
            loadingLabel.text = "Error: Invalid ADM data"
            return
        }
        
        do {
            guard let admJson = try JSONSerialization.jsonObject(with: admData) as? [String: Any] else {
                print("Error: NativeAdView: ADM is not a valid JSON object")
                loadingLabel.text = "Error: Invalid ADM JSON"
                return
            }
            
            print(" NativeAdView: Successfully parsed ADM JSON")
            
            guard let nativeJson = admJson["native"] as? [String: Any] else {
                print("Error: NativeAdView: ADM does not contain native ad data")
                loadingLabel.text = "Error: No native data"
                return
            }
            
            print(" NativeAdView: Found native object with keys: \(Array(nativeJson.keys))")
            
            if let version = nativeJson["ver"] as? String {
                print("🔍 NativeAdView: Native ad version: \(version)")
            }
            
            if let assetsArray = nativeJson["assets"] as? [[String: Any]] {
                print("🔍 NativeAdView: Parsing \(assetsArray.count) assets")
                parseAssets(assetsArray)
            } else {
                print("⚠️ NativeAdView: No assets found")
            }
            
            if let linkDict = nativeJson["link"] as? [String: Any] {
                parseLink(linkDict)
            }
            
            if let imptrackers = nativeJson["imptrackers"] as? [String] {
                print("🔍 NativeAdView: Found \(imptrackers.count) impression trackers")
            }
            
            if let eventtrackers = nativeJson["eventtrackers"] as? [[String: Any]] {
                print("🔍 NativeAdView: Found \(eventtrackers.count) event trackers")
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.loadingLabel.isHidden = true
            }
            
        } catch {
            print("Error: NativeAdView: Failed to parse native ad from ADM: \(error)")
            loadingLabel.text = "Error parsing ADM"
        }
    }
    
    private func parseAssets(_ assetsArray: [[String: Any]]) {
        print("🔍 NativeAdView: Parsing \(assetsArray.count) assets")
        
        for (index, assetDict) in assetsArray.enumerated() {
            print("🔍 NativeAdView: Parsing asset \(index) with keys: \(Array(assetDict.keys))")
            
            guard let assetId = assetDict["id"] as? Int else {
                print("⚠️ NativeAdView: Asset \(index) has no ID")
                continue
            }
            
            print("🔍 NativeAdView: Asset \(index) ID: \(assetId)")
            
            if let titleDict = assetDict["title"] as? [String: Any],
               let titleText = titleDict["text"] as? String {
                print("🔍 NativeAdView: Asset \(index) title: \(titleText)")
                if assetId == 2 { 
                    titleLabel.text = titleText
                    print(" NativeAdView: Set title: \(titleText)")
                }
            }
            
            if let imgDict = assetDict["img"] as? [String: Any],
               let imageUrl = imgDict["url"] as? String {
                let width = imgDict["w"] as? Int ?? 0
                let height = imgDict["h"] as? Int ?? 0
                print("🔍 NativeAdView: Asset \(index) image: \(imageUrl) (\(width)x\(height))")
                
                if assetId == 4 { 
                    print(" NativeAdView: Found main image asset (ID: 4): \(imageUrl)")
                    loadImage(from: imageUrl, into: adImageView)
                } else if assetId == 3 { 
                    print(" NativeAdView: Found icon image asset (ID: 3): \(imageUrl)")
                    loadImage(from: imageUrl, into: iconImageView)
                    iconImageView.isHidden = false
                }
            }
            
            if let dataDict = assetDict["data"] as? [String: Any],
               let dataValue = dataDict["value"] as? String {
                print("🔍 NativeAdView: Asset \(index) data: \(dataValue)")
                
                if assetId == 6 { 
                    priceLabel.text = dataValue
                    print(" NativeAdView: Set price: \(dataValue)")
                } else if assetId == 1 { 
                    ctaButton.setTitle(dataValue, for: .normal)
                    print(" NativeAdView: Set CTA text: \(dataValue)")
                }
            }
        }
        
        print(" NativeAdView: Successfully parsed \(assetsArray.count) assets")
    }
    
    private func parseLink(_ linkDict: [String: Any]) {
        if let url = linkDict["url"] as? String {
            self.clickURL = url
            print(" NativeAdView: Extracted click URL: \(url)")
        }
        
        if let clicktrackers = linkDict["clicktrackers"] as? [String] {
            print("🔍 NativeAdView: Found \(clicktrackers.count) click trackers")
        }
    }
    
    
    public func loadNativeAdFromURL(_ url: URL) {
        loadingLabel.isHidden = false
        loadingLabel.text = "Loading Native Ad..."
        
        print("🔍 NativeAdView: Making HTTP request to: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("Error: NativeAdView: Network error: \(error.localizedDescription)")
                    self.loadingLabel.text = "Error: \(error.localizedDescription)"
                    return
                }
                
                guard let data = data else {
                    print("Error: NativeAdView: No data received from server")
                    self.loadingLabel.text = "Error: No data received"
                    return
                }
                
                guard let content = String(data: data, encoding: .utf8) else {
                    print("Error: NativeAdView: Invalid response encoding")
                    self.loadingLabel.text = "Error: Invalid response"
                    return
                }
                
                print(" NativeAdView: Received response: \(content)")
                
                do {
                    if let jsonData = content.data(using: .utf8),
                       let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] {
                        
                        print(" NativeAdView: Successfully parsed JSON response")
                        
                        if let adm = json["adm"] as? String {
                            print(" NativeAdView: Found adm field in response")
                            
                            if let positionValue = json["position"] as? Int,
                               let position = bidscubeSdk.AdPosition(rawValue: positionValue) {
                                print("🔍 NativeAdView: Received position from server: \(positionValue) - \(self.displayName(for: position))")
                                DispatchQueue.main.async {
                                    BidscubeSDK.setResponseAdPosition(position)
                                }
                            }
                            
                            self.loadNativeAdContent(adm)
                        } else {
                            print("⚠️ NativeAdView: No adm field found in response, treating entire content as native ad")
                            self.loadNativeAdContent(content)
                        }
                    } else {
                        print("⚠️ NativeAdView: Response is not valid JSON, treating as direct native ad content")
                        self.loadNativeAdContent(content)
                    }
                } catch {
                    print("Error: NativeAdView: JSON parsing failed: \(error), treating as direct native ad content")
                    self.loadNativeAdContent(content)
                }
            }
        }.resume()
    }
    
    private func loadImage(from urlString: String, into imageView: UIImageView) {
        print("🔍 NativeAdView: Loading image from URL: \(urlString)")
        
        let decodedUrlString = decodeEscapedString(urlString)
        
        print("🔍 NativeAdView: Decoded URL: \(decodedUrlString)")
        
        guard let url = URL(string: decodedUrlString) else {
            print("Error: NativeAdView: Invalid image URL after decoding: \(decodedUrlString)")
            imageView.backgroundColor = .systemRed
            return
        }
        
        print("🔍 NativeAdView: Starting image download from: \(url.absoluteString)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let error = error {
                    print("Error: NativeAdView: Image download error: \(error.localizedDescription)")
                    imageView.backgroundColor = .systemRed
                    return
                }
                
                guard let data = data else {
                    print("Error: NativeAdView: No image data received")
                    imageView.backgroundColor = .systemRed
                    return
                }
                
                print(" NativeAdView: Received image data: \(data.count) bytes")
                
                if data.count == 0 {
                    print("Error: NativeAdView: Received empty image data")
                    imageView.backgroundColor = .systemRed
                    return
                }
                
                guard let image = UIImage(data: data) else {
                    print("Error: NativeAdView: Failed to create UIImage from data")
                    imageView.backgroundColor = .systemRed
                    return
                }
                
                print(" NativeAdView: Successfully loaded image: \(image.size)")
                imageView.image = image
                imageView.backgroundColor = .clear
            }
        }.resume()
    }
    
    private func decodeEscapedString(_ string: String) -> String {
        var decoded = string
        
        decoded = decoded.replacingOccurrences(of: "\\u0026", with: "&")
        decoded = decoded.replacingOccurrences(of: "\\/", with: "/")
        decoded = decoded.replacingOccurrences(of: "\\\"", with: "\"")
        decoded = decoded.replacingOccurrences(of: "\\\\", with: "\\")
        decoded = decoded.replacingOccurrences(of: "\\n", with: "\n")
        decoded = decoded.replacingOccurrences(of: "\\t", with: "\t")
        decoded = decoded.replacingOccurrences(of: "\\r", with: "\r")
        
        if let data = decoded.data(using: .utf8),
           let decodedString = String(data: data, encoding: .utf8) {
            return decodedString
        }
        
        return decoded
    }

    public func setCTAText(_ text: String) {
        ctaButton.setTitle(text, for: .normal)
    }

    public func setCustomStyle(_ background: UIColor, _ textColor: UIColor, _ accent: UIColor) {
        backgroundColor = background
        titleLabel.textColor = textColor
        ctaButton.backgroundColor = accent
    }

    public func setCTAButton(_ title: String, _ background: UIColor, _ textColor: UIColor) {
        ctaButton.setTitle(title, for: .normal)
        ctaButton.backgroundColor = background
        ctaButton.setTitleColor(textColor, for: .normal)
        ctaButton.layer.cornerRadius = 6
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    }
    
    private func displayName(for position: bidscubeSdk.AdPosition) -> String {
        switch position {
        case .unknown: return "UNKNOWN"
        case .aboveTheFold: return "ABOVE_THE_FOLD"
        case .dependOnScreenSize: return "DEPEND_ON_SCREEN_SIZE"
        case .belowTheFold: return "BELOW_THE_FOLD"
        case .header: return "HEADER"
        case .footer: return "FOOTER"
        case .sidebar: return "SIDEBAR"
        case .fullScreen: return "FULL_SCREEN"
        }
    }
    
    @objc private func ctaButtonTapped() {
        print("🔍 NativeAdView: CTA button tapped for placement: \(placementId)")
        handleAdClick()
    }
    
    @objc private func adTapped() {
        print("🔍 NativeAdView: Ad tapped for placement: \(placementId)")
        handleAdClick()
    }
    
    private func handleAdClick() {
        callback?.onAdClicked(placementId)
        
        if let clickURL = clickURL, let url = URL(string: clickURL) {
            print("🔍 NativeAdView: Opening URL in browser: \(clickURL)")
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("⚠️ NativeAdView: No click URL available")
        }
    }
}


