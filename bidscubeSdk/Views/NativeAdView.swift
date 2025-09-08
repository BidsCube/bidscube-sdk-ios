import UIKit

public final class NativeAdView: UIView {
    private let titleLabel = UILabel()
    private let ctaButton = UIButton(type: .system)

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

        titleLabel.text = "Bidscube Native Ad"
        titleLabel.textAlignment = .center
        titleLabel.translatesAutoresizingMaskIntoConstraints = false

        ctaButton.setTitle("Install Now", for: .normal)
        ctaButton.translatesAutoresizingMaskIntoConstraints = false
        ctaButton.backgroundColor = .systemBlue
        ctaButton.tintColor = .white
        ctaButton.setTitleColor(.white, for: .normal)
        ctaButton.layer.cornerRadius = 6
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 14, bottom: 8, right: 14)

        addSubview(titleLabel)
        addSubview(ctaButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),

            ctaButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            ctaButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            ctaButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    public func setCTAText(_ text: String) {
        ctaButton.setTitle(text, for: .normal)
    }

    public func setCustomStyle(_ background: UIColor, _ textColor: UIColor, _ accent: UIColor) {
        backgroundColor = background
        titleLabel.textColor = textColor
        ctaButton.tintColor = accent
    }

    public func setCTAButton(_ title: String, _ background: UIColor, _ textColor: UIColor) {
        ctaButton.setTitle(title, for: .normal)
        ctaButton.backgroundColor = background
        ctaButton.setTitleColor(textColor, for: .normal)
        ctaButton.layer.cornerRadius = 6
        ctaButton.contentEdgeInsets = UIEdgeInsets(top: 6, left: 12, bottom: 6, right: 12)
    }
}


