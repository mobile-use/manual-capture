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
    var aspectRatio: CGFloat = 16 / 9 {
        didSet { bounds = requestedBound ?? bounds.standardized /* recalculate*/ }
    }
    
    override func preferredFrameSize() -> CGSize {
        let ratioW = bounds.height * aspectRatio
        let ratioH = bounds.width / aspectRatio
        let pRect = bounds.insetBy(
            dx: max(bounds.width - ratioW, 0) / 2, // clipped
            dy: max(bounds.height - ratioH, 0) / 2 // clipped
        )
        return pRect.size
    }
    
    var requestedBound: CGRect?
    
    override var frame: CGRect {
        willSet(newFrame) {
            if superlayer != nil {
                requestedBound = self.convert(newFrame, from: self.superlayer)
            }else{
                var newBound = newFrame
                newBound.origin = CGPoint.zero
                requestedBound = newBound
            }
        }
    }
    
    override var bounds: CGRect {
        set {
            let ratioW = newValue.height * aspectRatio
            let ratioH = newValue.width / aspectRatio
            
            super.bounds = newValue.insetBy(
                dx: max(newValue.width - ratioW, 0) / 2, // clipped
                dy: max(newValue.height - ratioH, 0) / 2 // clipped
            )
        }
        get {
            return super.bounds
        }
    }
    
    func didInit(){
        if videoGravity != AVLayerVideoGravity.resizeAspectFill {
            videoGravity = AVLayerVideoGravity.resizeAspectFill
        }
    }
    
    override init(session: AVCaptureSession) {
        super.init(session: session)
        didInit()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
