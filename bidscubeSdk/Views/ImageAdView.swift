import UIKit

public final class ImageAdView: UIImageView {
    public init() {
        super.init(frame: .zero)
        contentMode = .scaleAspectFit
        clipsToBounds = true
        isUserInteractionEnabled = true
        backgroundColor = .lightGray
        layer.cornerRadius = 6
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
}


