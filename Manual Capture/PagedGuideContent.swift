//
//  PagedGuideContent.swift
//  Capture
//
//  Created by Jean Flaherty on 11/27/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVKit

//let videoQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)//dispatch_queue_create("Video Preparing", DISPATCH_QUEUE_SERIAL)


class PagedGuideContent: UIViewController {
    typealias Content = (title: String, description: String, videoName: String)
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var mediaContainer: UIView!
    var mediaPlayer: AVPlayer!
    
    var content: Content = ("Title", "Description.", "TestFoot1") {
        didSet {
            titleLabel?.text = content.title
            descriptionTextView?.text = content.description
            let fixedWidth = descriptionTextView?.frame.width ?? 0
            descriptionTextView?.frame.size = descriptionTextView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        }
    }
    var index = -1
    
    override func viewDidLoad() {
        titleLabel.text = content.title
        descriptionTextView.text = content.description
        let fixedWidth = descriptionTextView.frame.width
        let discriptionFitSize = CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude)
        descriptionTextView.frame.size = descriptionTextView.sizeThatFits(discriptionFitSize)
        
        if let url = Bundle.main.url(forResource: content.videoName, withExtension: "mov") {
            mediaPlayer = AVPlayer(url: url)
            let mediaLayer = AVPlayerLayer(player: mediaPlayer)
            mediaLayer.frame = mediaContainer.layer.bounds
            mediaContainer.layer.addSublayer(mediaLayer)
            
            let selector = #selector(self.playerItemDidReachEnd(notification:))
            NotificationCenter.default.addObserver(self, selector: selector, name: .AVPlayerItemDidPlayToEndTime,
                                                   object: mediaPlayer.currentItem)
        } else {
            print("Could not locate movie file at: \(content.videoName).mov")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc func playerItemDidReachEnd(notification: NSNotification) {
        mediaPlayer.seek(to: CMTime.zero)
        mediaPlayer.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        mediaPlayer.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        mediaPlayer.pause()
    }
}
