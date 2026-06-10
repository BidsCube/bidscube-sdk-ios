import UIKit

final class VideoInterstitialEndCardView: UIView {

    var onPreviewTapped: (() -> Void)?
    var onCTATapped: (() -> Void)?
    var onCloseTapped: (() -> Void)?

    private let previewContainer = UIView()
    private let previewImageView = UIImageView()
    private let closeOverlay = VideoInterstitialOverlayView()
    private let titleLabel = UILabel()
    private let starsStack = UIStackView()
    private let downloadsLabel = UILabel()
    private let priceCaptionLabel = UILabel()
    private let priceValueLabel = UILabel()
    private let ctaButton = UIButton(type: .system)

    init(metadata: VideoInterstitialMetadata) {
        super.init(frame: .zero)
        setupLayout(metadata: metadata)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayout(metadata: VideoInterstitialMetadata) {
        backgroundColor = UIColor(red: 0xF2 / 255.0, green: 0xF2 / 255.0, blue: 0xF2 / 255.0, alpha: 1)

        previewContainer.translatesAutoresizingMaskIntoConstraints = false
        previewContainer.layer.cornerRadius = 28
        previewContainer.clipsToBounds = true
        previewContainer.backgroundColor = UIColor(red: 0x5C / 255.0, green: 0x4B / 255.0, blue: 0x8A / 255.0, alpha: 1)
        previewContainer.setContentHuggingPriority(.defaultLow, for: .vertical)
        previewContainer.setContentCompressionResistancePriority(.defaultLow, for: .vertical)

        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        previewImageView.contentMode = .scaleAspectFill
        previewImageView.clipsToBounds = true
        previewImageView.isUserInteractionEnabled = true
        previewImageView.backgroundColor = previewContainer.backgroundColor
        previewContainer.addSubview(previewImageView)

        closeOverlay.translatesAutoresizingMaskIntoConstraints = false
        closeOverlay.showEndCardClose()
        closeOverlay.onCloseTapped = { [weak self] in self?.onCloseTapped?() }
        previewContainer.addSubview(closeOverlay)

        let previewTap = UITapGestureRecognizer(target: self, action: #selector(previewTapped))
        previewImageView.addGestureRecognizer(previewTap)

        titleLabel.text = metadata.appTitle
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = UIColor(red: 0x1A / 255.0, green: 0x1A / 255.0, blue: 0x1A / 255.0, alpha: 1)
        titleLabel.numberOfLines = 2

        configureStars(rating: metadata.rating)

        downloadsLabel.text = metadata.downloadCount
        downloadsLabel.font = UIFont.systemFont(ofSize: 13)
        downloadsLabel.textColor = UIColor(red: 0x9E / 255.0, green: 0x9E / 255.0, blue: 0x9E / 255.0, alpha: 1)

        priceCaptionLabel.text = "Price"
        priceCaptionLabel.font = UIFont.systemFont(ofSize: 13)
        priceCaptionLabel.textColor = downloadsLabel.textColor

        priceValueLabel.text = metadata.priceText
        priceValueLabel.font = UIFont.boldSystemFont(ofSize: 16)
        priceValueLabel.textColor = titleLabel.textColor

        ctaButton.setTitle(metadata.ctaText, for: .normal)
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        ctaButton.backgroundColor = UIColor(red: 0x00 / 255.0, green: 0x7A / 255.0, blue: 0xFF / 255.0, alpha: 1)
        ctaButton.layer.cornerRadius = 28
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 18, left: 36, bottom: 18, right: 36)
        ctaButton.layer.shadowColor = UIColor.black.cgColor
        ctaButton.layer.shadowOpacity = 0.15
        ctaButton.layer.shadowOffset = CGSize(width: 0, height: 2)
        ctaButton.layer.shadowRadius = 4
        ctaButton.addTarget(self, action: #selector(ctaTapped), for: .touchUpInside)

        let infoStack = UIStackView(arrangedSubviews: [titleLabel, starsStack, downloadsLabel])
        infoStack.axis = .vertical
        infoStack.spacing = 4
        infoStack.setCustomSpacing(4, after: starsStack)

        let priceStack = UIStackView(arrangedSubviews: [priceCaptionLabel, priceValueLabel])
        priceStack.axis = .vertical
        priceStack.spacing = 2
        priceStack.alignment = .leading

        let bottomRow = UIStackView(arrangedSubviews: [priceStack, ctaButton])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .center
        bottomRow.distribution = .fill
        bottomRow.spacing = 12

        let rootStack = UIStackView(arrangedSubviews: [previewContainer, infoStack, bottomRow])
        rootStack.axis = .vertical
        rootStack.spacing = 14
        rootStack.setCustomSpacing(40, after: infoStack)
        rootStack.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rootStack)

        NSLayoutConstraint.activate([
            rootStack.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 14),
            rootStack.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 20),
            rootStack.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            rootStack.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -16),

            previewImageView.topAnchor.constraint(equalTo: previewContainer.topAnchor),
            previewImageView.leadingAnchor.constraint(equalTo: previewContainer.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: previewContainer.bottomAnchor),

            closeOverlay.topAnchor.constraint(equalTo: previewContainer.topAnchor, constant: 14),
            closeOverlay.trailingAnchor.constraint(equalTo: previewContainer.trailingAnchor, constant: -14),

            ctaButton.heightAnchor.constraint(greaterThanOrEqualToConstant: 56)
        ])

        loadPreviewImage(from: metadata.previewImageUrl ?? VideoInterstitialDefaults.previewImageUrl)
    }

    private func configureStars(rating: Double) {
        starsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        starsStack.axis = .horizontal
        starsStack.spacing = 2
        starsStack.alignment = .center

        let clamped = min(max(rating, 0), 5)
        for index in 1...5 {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 18)
            label.text = "★"
            if Double(index) <= floor(clamped + 0.0001) {
                label.textColor = UIColor(red: 1, green: 0x98 / 255.0, blue: 0, alpha: 1)
            } else if Double(index) - 0.5 <= clamped {
                label.textColor = UIColor(red: 1, green: 0x98 / 255.0, blue: 0, alpha: 0.4)
            } else {
                label.textColor = UIColor(red: 1, green: 0x98 / 255.0, blue: 0, alpha: 0.2)
            }
            starsStack.addArrangedSubview(label)
        }
    }

    private func loadPreviewImage(from url: URL?) {
        guard let url else { return }
        URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async {
                self?.previewImageView.image = image
            }
        }.resume()
    }

    @objc private func previewTapped() {
        onPreviewTapped?()
    }

    @objc private func ctaTapped() {
        onCTATapped?()
    }
}
