import UIKit
import AVFoundation

public final class VideoAdView: UIView {
    public private(set) var playerLayer: AVPlayerLayer?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        layer.masksToBounds = true
        layer.cornerRadius = 6
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        backgroundColor = .black
        layer.masksToBounds = true
        layer.cornerRadius = 6
    }

    public func attach(player: AVPlayer) {
        let layer = AVPlayerLayer(player: player)
        layer.videoGravity = .resizeAspect
        layer.frame = bounds
        self.layer.addSublayer(layer)
        self.playerLayer = layer
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}


