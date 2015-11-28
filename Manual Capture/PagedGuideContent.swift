//
//  PagedGuideContent.swift
//  Capture
//
//  Created by Jean Flaherty on 11/27/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVKit

let videoQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)//dispatch_queue_create("Video Preparing", DISPATCH_QUEUE_SERIAL)


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
            let fixedWidth = descriptionTextView?.frame.width
            descriptionTextView?.frame.size = descriptionTextView.sizeThatFits(CGSize(width: fixedWidth!, height: CGFloat.max))
        }
    }
    var index = -1
    
    override func viewDidLoad() {
        titleLabel?.text = content.title
        descriptionTextView?.text = content.description
        let fixedWidth = descriptionTextView?.frame.width
        descriptionTextView?.frame.size = descriptionTextView.sizeThatFits(CGSize(width: fixedWidth!, height: CGFloat.max))
        
        

        
        let url = NSBundle.mainBundle().URLForResource(content.videoName, withExtension: "mov")
        mediaPlayer = AVPlayer(URL: url!)
        let mediaLayer = AVPlayerLayer(player: mediaPlayer)
        mediaLayer.frame = mediaContainer.layer.bounds
        mediaContainer.layer.addSublayer(mediaLayer)
        
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "playerItemDidReachEnd:",
            name: AVPlayerItemDidPlayToEndTimeNotification,
            object: mediaPlayer.currentItem)

    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    func playerItemDidReachEnd(notification: NSNotification) {
        mediaPlayer.seekToTime(kCMTimeZero)
        mediaPlayer.play()
    }
    
    override func viewDidAppear(animated: Bool) {
        mediaPlayer.play()
    }
    
    override func viewWillDisappear(animated: Bool) {
        mediaPlayer.pause()
    }
}
