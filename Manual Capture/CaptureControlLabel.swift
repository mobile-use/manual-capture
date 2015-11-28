//
//  CaptureControlLabel.swift
//  Capture
//
//  Created by Jean Flaherty on 8/19/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class CaptureControlLabel: UILabel {
    var roundedRect = CAShapeLayer()
    //var textLayer = CATextLayer()
    var showAndHideEnabeled = false
    private var _delaysCount = 0
    override var text: String? {
        didSet{
            guard text != nil else{layer.opacity = 0;return}
            if text!.isEmpty {
                layer.opacity = 0
            }else{
                layer.opacity = 1
                if showAndHideEnabeled {
                    delay(2){
                        // Subtract 1 from timer count
                        self._delaysCount--
                        if self._delaysCount == 0 {
                            let animation = CABasicAnimation(keyPath: "opacity")
                            animation.duration = 0.25
                            self.layer.addAnimation(animation, forKey: "opacityAnimation")
                            self.layer.opacity = 0
                        }
                    }
                    // Add 1 to timer count
                    self._delaysCount++
                }
            }
        }
    }
    
    init() {
        super.init(frame: CGRectZero)
        didInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        didInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        didInit()
    }
    
    
    func didInit(){
        textColor = UIColor.whiteColor()
        layoutMargins = UIEdgeInsetsMake(-5, -5, -5, -5)
        font = UIFont(name: "HelveticaNeue", size: 14)
        textAlignment = NSTextAlignment.Center
        //roundedRect.fillColor = kCaptureTintColor.CGColor
        self.backgroundColor = kCaptureTintColor
    }
    
    override func intrinsicContentSize() -> CGSize {
        let sContentSize = super.intrinsicContentSize()
        return CGSizeMake(sContentSize.width+12, sContentSize.height+6)
    }

    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        guard layer.isEqual(self.layer) else{return}
        roundedRect.path = UIBezierPath(roundedRect: bounds, cornerRadius: 3).CGPath
        self.layer.mask = roundedRect
        //self.backgroundColor = kCaptureTintColor
    }

}
