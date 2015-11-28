//
//  CapturePreviewLayer.swift
//  Capture
//
//  Created by Jean on 10/1/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation

class CapturePreviewLayer: AVCaptureVideoPreviewLayer {
    var cropAspectRatio: CGFloat = 16 / 9 {
        didSet { bounds = requestedBound ?? bounds.standardized /* recalculate*/}
    }
    
    override func preferredFrameSize() -> CGSize {
        let ratioW = bounds.height * cropAspectRatio
        let ratioH = bounds.width / cropAspectRatio
        let pRect = CGRectInset(bounds,
            max(bounds.width - ratioW, 0) / 2, // clipped
            max(bounds.height - ratioH, 0) / 2 // clipped
        )
        return pRect.size
    }
    
    private var requestedBound: CGRect?
    
    override var frame: CGRect {
        willSet(newFrame) {
            if superlayer != nil {
                requestedBound = self.convertRect(newFrame, fromLayer: self.superlayer)
            }else{
                var newBound = newFrame
                newBound.origin = CGPointZero
                requestedBound = newBound
            }
        }
    }
    
    override var bounds: CGRect {
        set {
            if videoGravity != AVLayerVideoGravityResizeAspectFill {
                videoGravity = AVLayerVideoGravityResizeAspectFill
            }
            let ratioW = newValue.height * cropAspectRatio
            let ratioH = newValue.width / cropAspectRatio
            
            super.bounds = CGRectInset(newValue,
                max(newValue.width - ratioW, 0) / 2, // clipped
                max(newValue.height - ratioH, 0) / 2 // clipped
            )
        }
        get {
            return super.bounds
        }
    }
}
