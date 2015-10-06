//
//  CaptureControlSliderLayer.swift
//  Manual Capture
//
//  Created by Jean Flaherty on 8/13/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import QuartzCore
import CoreGraphics

enum CaptureControlScrubberVisibility {
    case Active, Visible, Fading, Hidden
}

let captureColor = UIColor(red: 221/255, green: 0/255, blue: 63/255, alpha: 1.0)

class CaptureControlScrubber: CALayer {
    private let defaultDiameter: CGFloat = 18
    
    var fadeScalePerRateOfChange: Float = 1/0.15/*{
        switch type {
        case .ExposureDuration: return 1/0.005
        default: return 1/0.1
        }
    }*/
    let activeOpactiy:Float = 1.0
    let visibleOpactiy:Float = 0.6
    let hiddenOpactiy:Float = 0.0
    
    
    var fadeScale: Float = 0.0 {
        didSet {
            if _visibility == .Fading {
                animateOpacity(hiddenOpactiy + (visibleOpactiy - hiddenOpactiy) * fadeScale)
                //opacity = hiddenOpactiy + (visibleOpactiy - hiddenOpactiy) * fadeScale
            }
        }
    }
    
    private var _lastChange: Float = 0
    private var _progress: Float = 0
    
    var progress: Float {
        set {
            let changeSince = fabs(_progress - newValue)
            _lastChange = changeSince
            _progress = newValue
            let currentChangeTimestamp = NSProcessInfo().systemUptime
            let timeSince = currentChangeTimestamp - _lastChangeTimestamp
            _lastChangeTimestamp = currentChangeTimestamp
            let rateOfChange = changeSince / Float(timeSince)
            fadeScale = max(0, min(rateOfChange * fadeScalePerRateOfChange, 1))
            //if type == .ExposureDuration {print(fadeScale)}
            
            func updateFadeScaleAfterDelay(delay: Double){
                let delayNSEC = delay * Double(NSEC_PER_SEC)  // nanoseconds per seconds
                let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayNSEC))
                _updateFadeScaleWhenZeroCount++
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                    self._updateFadeScaleWhenZeroCount--
                    if self._updateFadeScaleWhenZeroCount == 0 {
                        self.fadeScale = 0
                        
                    }
                })
            }
            updateFadeScaleAfterDelay(0.3)
        }
        
        get {
            return _progress
        }
    }
    
    private var _updateFadeScaleWhenZeroCount: Int = 0
    
    
    
    private var _visibility: CaptureControlScrubberVisibility = .Fading {
        didSet {
            switch _visibility {
            case .Active:
                opacity = activeOpactiy
            case .Visible:
                opacity = visibleOpactiy
            case .Hidden:
                opacity = hiddenOpactiy
            case .Fading:
                animateOpacity(hiddenOpactiy + (visibleOpactiy - hiddenOpactiy) * fadeScale)
                //opacity = hiddenOpactiy + (visibleOpactiy - hiddenOpactiy) * fadeScale
            }
        }
        
    }
    
    // mode is on locked needs active opacity to show that the users custom value is taking effect
    var active: Bool = false {didSet{updateVisibility()}}
    var selected: Bool = false {didSet{updateVisibility()}}
    var controlShown: Bool = false {didSet{updateVisibility()}}
    
    private var _lastChangeTimestamp: NSTimeInterval = 0
    
    var type: CaptureControlSliderType = .Custom /*{
        didSet {
            
        }
    }*/
    
    /*override var opacity: Float {
        set {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
            
            if (self.animationForKey("opacity") != nil) {
                self.removeAnimationForKey("opacity")
                opacityAnimation.values = [presentationLayer()!.opacity, newValue]
            }else {
                opacityAnimation.values = [opacity, newValue]
            }
            //opacityAnimation.keyTimes = [0,1]
            //opacityAnimation.calculationMode = (type == .ExposureDuration) ? kCAAnimationLinear : kCAAnimationCubicPaced
            opacityAnimation.calculationMode = kCAAnimationCubicPaced
            opacityAnimation.removedOnCompletion = true
            opacityAnimation.duration = 0.4
            self.addAnimation(opacityAnimation, forKey: "opacity")
            super.opacity = newValue
            CATransaction.commit()
        }
        
        get {
            return super.opacity
        }
    }*/
    
    func animateOpacity(aOpacity: Float){
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        let opacityAnimation = CAKeyframeAnimation(keyPath: "opacity")
        
        if (self.animationForKey("opacity") != nil) {
            self.removeAnimationForKey("opacity")
            opacityAnimation.values = [presentationLayer()!.opacity, aOpacity]
        }else {
            opacityAnimation.values = [opacity, aOpacity]
        }
        //opacityAnimation.keyTimes = [0,1]
        //opacityAnimation.calculationMode = (type == .ExposureDuration) ? kCAAnimationLinear : kCAAnimationCubicPaced
        opacityAnimation.calculationMode = kCAAnimationCubicPaced
        opacityAnimation.removedOnCompletion = true
        opacityAnimation.duration = 0.4
        self.addAnimation(opacityAnimation, forKey: "opacity")
        opacity = aOpacity
        CATransaction.commit()
    }
    
    
    func updateVisibility() {
        if selected || (controlShown && active) {
            _visibility = .Active
        }else if controlShown || active {
            _visibility = .Visible
        }else{
            _visibility = .Fading
        }
    }
    
    func setPosition(position aPosition: CGPoint, animated:Bool) {
        if animated {
            position = aPosition
        }else {
            CATransaction.begin()
            CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
            position = aPosition
            CATransaction.commit()
        }
    }
    
    private func _drawFocus() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.fillColor = UIColor.magentaColor().CGColor
        addSublayer(shapeLayer)
        
        let textLayer = CATextLayer()
        textLayer.string = "F"
        textLayer.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 11)
        textLayer.fontSize = 11
        textLayer.preferredFrameSize()
        textLayer.contentsScale = UIScreen.mainScreen().scale
        let pSize = textLayer.preferredFrameSize()
        let x = (bounds.width - pSize.width)/2
        let y = (bounds.height - pSize.height)/2
        textLayer.frame = CGRectMake(x, y, pSize.width, pSize.height)
        textLayer.alignmentMode = kCAAlignmentCenter
        addSublayer(textLayer)
    }
    
    private func _drawTemp() {
        let gradientLayer = CAGradientLayer()
        let firstHalfColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1).CGColor
        let secondHalfColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1).CGColor
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 1)
        gradientLayer.colors = [firstHalfColor, firstHalfColor, secondHalfColor, secondHalfColor]
        gradientLayer.locations = [0.0, 0.5, 0.5, 1.0]
            let gradientMaskLayer = CAShapeLayer()
            gradientMaskLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        gradientLayer.mask = gradientMaskLayer
        addSublayer(gradientLayer)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        addSublayer(shapeLayer)
    }
    
    private func _drawTint() {
        let gradientLayer = CAGradientLayer()
        let firstHalfColor = UIColor(red: 0, green: 0.75, blue: 0.25, alpha: 1).CGColor
        let secondHalfColor = UIColor(red: 1, green: 0.25, blue: 0.75, alpha: 1).CGColor
        gradientLayer.frame = bounds
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 1)
        gradientLayer.colors = [firstHalfColor, firstHalfColor, secondHalfColor, secondHalfColor]
        gradientLayer.locations = [0.0, 0.5, 0.5, 1.0]
        let gradientMaskLayer = CAShapeLayer()
        gradientMaskLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        gradientLayer.mask = gradientMaskLayer
        addSublayer(gradientLayer)
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.fillColor = UIColor.clearColor().CGColor
        addSublayer(shapeLayer)
    }
    
    private func _drawISO() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.fillColor = captureColor.CGColor
        addSublayer(shapeLayer)
        
        let textLayer = CATextLayer()
        //textLayer.position = CGPointMake(bounds.midX, bounds.midY)
        textLayer.string = "ISO"
        textLayer.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 9)
        textLayer.fontSize = 9
        textLayer.preferredFrameSize()
        textLayer.contentsScale = UIScreen.mainScreen().scale
        let pSize = textLayer.preferredFrameSize()
        let x = (bounds.width - pSize.width)/2
        let y = (bounds.height - pSize.height)/2
        textLayer.frame = CGRectMake(x, y, pSize.width, pSize.height)
        textLayer.alignmentMode = kCAAlignmentCenter
        addSublayer(textLayer)
    }
    
    private func _drawExposureDuration() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: bounds).CGPath
        shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        shapeLayer.fillColor = captureColor.CGColor
        addSublayer(shapeLayer)
    }
    
    override init() {
        super.init()
    }
    
    
    init(type aType: CaptureControlSliderType) {
        super.init(layer: CALayer())
        bounds = CGRectMake(0, 0, defaultDiameter, defaultDiameter)
        rasterizationScale = UIScreen.mainScreen().scale
        shouldRasterize = true
        type = aType
        switch type {
        case .ISO: _drawISO()
        case .ExposureDuration: _drawExposureDuration()
        case .Temp: _drawTemp()
        case .Tint: _drawTint()
        default: break
        }
        shadowColor = UIColor.blackColor().CGColor
        shadowOffset = CGSizeMake(0, 1)
        shadowRadius = 1
        shadowOpacity = 0.75
    }
    
    override init(layer: AnyObject) {
        super.init(layer: layer)
        //setUpScrubber()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
