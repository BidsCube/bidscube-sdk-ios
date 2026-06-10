import UIKit

final class VideoInterstitialOverlayView: UIView {

    enum Mode {
        case countdown
        case skipEnabled
        case closeOnly
        case endCardClose
    }

    private enum LayoutStyle {
        case skipWide
        case closeCompact
    }

    var onSkipTapped: (() -> Void)?
    var onCloseTapped: (() -> Void)?
    var onSkipEnabled: (() -> Void)?

    private let actionButton = UIButton(type: .system)
    private var countdownTimer: Timer?
    private var remainingSeconds = 0
    private var mode: Mode = .countdown
    private var hasSkipOffset = false
    private var buttonWidthConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopCountdown()
    }

    func startSkipCountdown(_ skipOffsetSeconds: Int) {
        stopCountdown()
        isHidden = false
        applyLayout(.skipWide)
        hasSkipOffset = skipOffsetSeconds > 0
        remainingSeconds = max(skipOffsetSeconds, 0)
        mode = .countdown

        if !hasSkipOffset {
            showCloseOnly()
            return
        }

        updateCountdownLabel()
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self else {
                timer.invalidate()
                return
            }
            self.remainingSeconds -= 1
            if self.remainingSeconds > 0 {
                self.updateCountdownLabel()
            } else {
                self.enableSkip()
            }
        }
    }

    func enableSkip() {
        stopCountdown()
        applyLayout(.skipWide)
        mode = .skipEnabled
        actionButton.setTitle("Skip", for: .normal)
        actionButton.isHidden = false
        onSkipEnabled?()
    }

    func showCloseOnly() {
        stopCountdown()
        applyLayout(.closeCompact)
        mode = .closeOnly
        actionButton.setTitle("✕", for: .normal)
        actionButton.isHidden = false
    }

    func showEndCardClose() {
        stopCountdown()
        isHidden = false
        applyLayout(.closeCompact)
        mode = .endCardClose
        actionButton.setTitle("✕", for: .normal)
        actionButton.isHidden = false
    }

    func hideOverlay() {
        stopCountdown()
        isHidden = true
    }

    private func setupButton() {
        isUserInteractionEnabled = true
        actionButton.setTitleColor(.white, for: .normal)
        actionButton.titleLabel?.lineBreakMode = .byTruncatingTail
        actionButton.titleLabel?.textAlignment = .center
        actionButton.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.6)
        actionButton.layer.cornerRadius = 18
        actionButton.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        addSubview(actionButton)

        actionButton.translatesAutoresizingMaskIntoConstraints = false
        let widthConstraint = actionButton.widthAnchor.constraint(equalToConstant: 108)
        buttonWidthConstraint = widthConstraint
        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: topAnchor),
            actionButton.trailingAnchor.constraint(equalTo: trailingAnchor),
            actionButton.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor),
            actionButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            widthConstraint,
            actionButton.heightAnchor.constraint(equalToConstant: 36)
        ])
        applyLayout(.skipWide)
    }

    private func applyLayout(_ style: LayoutStyle) {
        switch style {
        case .skipWide:
            buttonWidthConstraint?.constant = 108
            actionButton.titleLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 13, weight: .regular)
            actionButton.contentEdgeInsets = UIEdgeInsets(top: 8, left: 12, bottom: 8, right: 12)
            actionButton.layer.cornerRadius = 18
        case .closeCompact:
            buttonWidthConstraint?.constant = 36
            actionButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            actionButton.contentEdgeInsets = .zero
            actionButton.layer.cornerRadius = 18
        }
    }

    @objc private func handleTap() {
        switch mode {
        case .skipEnabled:
            onSkipTapped?()
        case .closeOnly, .endCardClose:
            onCloseTapped?()
        case .countdown:
            break
        }
    }

    private func updateCountdownLabel() {
        actionButton.setTitle(String(format: "Skip in %d", remainingSeconds), for: .normal)
        actionButton.isHidden = false
    }

    private func stopCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
    }
}
