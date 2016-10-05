//
// Created by Chope on 2016. 10. 5..
// Copyright (c) 2016 Chope. All rights reserved.
//

import UIKit

public enum DownloadState {
    case ready
    case downloading
    case complete
}

public class DownloadButton: UIButton {
    static let notificationNameForDidChangeDownloadState = Notification.Name("DownloadButtonDidChangeDownloadState")

    final let maxDownloadPercent: CGFloat = 100.0

    public var downloadPercent: CGFloat = 0.0 {
        didSet {
            print("download : \(downloadPercent) / \(maxDownloadPercent)")
            self.setNeedsDisplay()

            if maxDownloadPercent <= downloadPercent {
                runAfterDelay(sec: 0.1) {
                    self.downloadState = .complete
                    self.setNeedsDisplay()
                }
            }
        }
    }

    public private(set) var downloadState: DownloadState = .ready {
        didSet {
            setImagesForDownloadState()
            NotificationCenter.default.post(name: DownloadButton.notificationNameForDidChangeDownloadState, object: self)
        }
    }

    public convenience init(type buttonType: UIButtonType) {
        self.init(frame:CGRect())
        self.configure()
    }
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.configure()
    }
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configure()
    }

    private func configure() {
        self.backgroundColor = UIColor.white
        self.tintColor = UIColor.green
        
        self.setImagesForDownloadState()
        self.addTarget(self, action: #selector(onTap(_:)), for: .touchUpInside)
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        self.layer.cornerRadius = self.bounds.size.width / 2.0
        self.layer.masksToBounds = true
    }

    public override func draw(_ rect: CGRect) {
        guard self.downloadState == .downloading else {
            super.draw(rect)
            return
        }

        print("downloadPercent: \(downloadPercent)")

        let angle = (min(downloadPercent, maxDownloadPercent) * 3.6 + 270.0)
        let endAngle: CGFloat = ((CGFloat(M_PI) * angle) / 180.0)
        let radius = self.bounds.width / 2.0 - 1.0
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let bezierPath = UIBezierPath()
        bezierPath.move(to: center)
        bezierPath.addArc(withCenter: center,
                radius: radius,
                startAngle: CGFloat(M_PI_2) * 3.0,
                endAngle: endAngle,
                clockwise: true)
        tintColor.setFill()
        bezierPath.fill()
    }

    private func getPath(percent: CGFloat) -> UIBezierPath {
        let angle = (min(100.0, maxDownloadPercent) * 3.6 + 270.0)
        let endAngle: CGFloat = ((CGFloat(M_PI) * angle) / 180.0)
        let radius = self.bounds.width / 2.0 - 10.0
        let center = CGPoint(x: self.bounds.midX, y: self.bounds.midY)
        let bezierPath = UIBezierPath()
//        bezierPath.move(to: center)
        bezierPath.addArc(withCenter: center,
                radius: radius,
                startAngle: CGFloat(M_PI_2) * 3.0,
                endAngle: endAngle,
                clockwise: true)
        return bezierPath
    }

    private func setImagesForDownloadState() {
        switch self.downloadState {
        case .ready:
            self.setImage(UIImage(named: "icDownload"), for: .normal)
        case .downloading:
            self.setImage(nil, for: .normal)
        case .complete:
            self.setImage(UIImage(named: "icComplete"), for: .normal)
        }
    }

    @objc
    public func onTap(_ button: UIButton) {
        switch self.downloadState {
        case .ready:
            self.isUserInteractionEnabled = false

            UIView.animate(withDuration: 0.5, animations: {
                self.imageView?.alpha = 0.0
            }, completion: { completed in
                self.imageView?.alpha = 1.0
                self.downloadState = .downloading
                self.setNeedsDisplay()
            })
        default:
            break
        }
    }

    private func runAfterDelay(sec: Double, execute: @escaping @convention(block)()->()) {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(sec * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: execute)
    }
}
