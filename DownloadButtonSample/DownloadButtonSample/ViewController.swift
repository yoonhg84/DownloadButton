//
//  ViewController.swift
//  DownloadButtonSample
//
//  Created by Chope on 2016. 10. 5..
//  Copyright © 2016년 Chope. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var downloadButton: DownloadButton?
    @IBOutlet weak var stateLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        guard let downloadButton = downloadButton else { return }
        NotificationCenter.default.addObserver(self, selector: #selector(self.didChangedState(_:)), name: DownloadButton.notificationNameForDidChangeDownloadState, object: downloadButton)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @objc
    public func didChangedState(_ notification: Notification) {
        guard let downloadButton = downloadButton else { return }
        stateLabel?.text = "\(downloadButton.downloadState)"

        if downloadButton.downloadState == .downloading {
            increaseDownloadPercent()
        }
    }

    private func increaseDownloadPercent() {
        self.runAfterDelay(sec: 0.1) { [weak self] in
            guard let downloadButton = self?.downloadButton else { return }
            downloadButton.downloadPercent = min(100.0, downloadButton.downloadPercent + 10.0)

            if downloadButton.downloadPercent < 100.0 {
                self?.increaseDownloadPercent()
            }
        }
    }

    private func runAfterDelay(sec: Double, execute: @escaping @convention(block)()->()) {
        let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(sec * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: execute)
    }
}

