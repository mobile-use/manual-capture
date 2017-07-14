//
//  CapturePreviewView.swift
//  Capture
//
//  Created by Jean Flaherty on 11/24/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation

class CapturePreviewView: UIView {
    let previewLayer: AVCaptureVideoPreviewLayer!
    var aspectRatio: CGFloat = 16 / 9 {
        didSet{
            layer.setNeedsLayout()
        }
    }
    
    init!(session:AVCaptureSession){
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        super.init(frame:CGRectZero)
        guard previewLayer != nil else { return nil }
        
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        layer.addSublayer(previewLayer)
        self.backgroundColor = UIColor.blackColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        guard layer == self.layer else {
            super.layoutSublayersOfLayer(layer)
            return
        }
        
        let ratio = (
            width: layer.bounds.height * aspectRatio,
            height: layer.bounds.width / aspectRatio
        )
        previewLayer.frame = CGRectInset(layer.bounds,
            max(layer.bounds.width - ratio.width, 0) / 2, // clipped
            max(layer.bounds.height - ratio.height, 0) / 2 // clipped
        )
    }
    
    
}
