//
//  ManualCaptureGlyph.swift
//  Capture
//
//  Created by Jean on 9/27/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class ManualCaptureGlyph: CALayer {

    enum GlyphType : String {
        case Focus = "Focus", ISO = "ISO", ExposureDuration = "Exposure Time", Temperature = "Temperature", Tint = "Tint"
    }
    let type: GlyphType
    var radius: CGFloat = 9 {didSet{
            bounds = CGRectMake(0, 0, radius*2, radius*2)
        }
    }
    
    init(type: GlyphType) {
        self.type = type
        super.init()
        frame = CGRectMake(0, 0, radius*2, radius*2)
        _drawSublayers()
        //backgroundColor = UIColor.redColor().CGColor
    }
    
    convenience override init(layer: AnyObject) {
        guard let gLayer = layer as? ManualCaptureGlyph else {fatalError()}
        self.init(type:gLayer.type)
        self.radius = gLayer.radius
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    final private func _drawSublayers(){
        if let sublayers = sublayers {
            for sublayer in sublayers {sublayer.removeFromSuperlayer()}
        }
        switch type {
        case .Focus: _drawFocus()
        case .ISO: _drawISO()
        case .ExposureDuration: _drawExposureDuration()
        case .Temperature: _drawTemperature()
        case .Tint: _drawTint()
        }
    }
    final private func _drawFocus() {
        let b = bounds
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: b).CGPath
        shapeLayer.fillColor = kCaptureTintColor.CGColor
        addSublayer(shapeLayer)
        
        let pointer = CAShapeLayer()
        let lp1 = CGPathCreateMutable()
        let lp2 = CGPathCreateMutable()
        let lp3 = CGPathCreateMutable()
        let lp4 = CGPathCreateMutable()
        CGPathMoveToPoint(lp1, nil, b.midX, b.minY + 1.5)
        CGPathAddLineToPoint(lp1, nil, b.midX, b.minY + 3.5)
        CGPathMoveToPoint(lp2, nil, b.minX + 1.5, b.midY)
        CGPathAddLineToPoint(lp2, nil, b.minX + 3.5, b.midY)
        CGPathMoveToPoint(lp3, nil, b.midX, b.maxY - 1.5)
        CGPathAddLineToPoint(lp3, nil, b.midX, b.maxY - 3.5)
        CGPathMoveToPoint(lp4, nil, b.maxX - 1.5, b.midY)
        CGPathAddLineToPoint(lp4, nil, b.maxX - 3.5, b.midY)
        let combinedPath: CGMutablePathRef = CGPathCreateMutableCopy(UIBezierPath(ovalInRect: CGRectMake(1.5, 1.5, b.width-3, b.height-3)).CGPath)!
        CGPathAddPath(combinedPath, nil, lp1)
        CGPathAddPath(combinedPath, nil, lp2)
        CGPathAddPath(combinedPath, nil, lp3)
        CGPathAddPath(combinedPath, nil, lp4)
        pointer.lineCap = kCALineCapButt
        pointer.path = combinedPath
        pointer.strokeColor = UIColor.whiteColor().CGColor
        pointer.fillColor = UIColor.clearColor().CGColor
        addSublayer(pointer)
        
        let textLayer = CATextLayer()
        textLayer.string = "F"
        textLayer.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 9)
        textLayer.fontSize = 9
        textLayer.preferredFrameSize()
        textLayer.contentsScale = UIScreen.mainScreen().scale
        let pSize = textLayer.preferredFrameSize()
        let x = (b.width - pSize.width)/2
        let y = (b.height - pSize.height)/2
        textLayer.frame = CGRectMake(x, y, pSize.width, pSize.height)
        textLayer.alignmentMode = kCAAlignmentCenter
        addSublayer(textLayer)
    }
    final private func _drawISO() {
        let b = bounds
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: b).CGPath
        //shapeLayer.strokeColor = kCaptureTintColor.CGColor
        shapeLayer.fillColor = UIColor.whiteColor().CGColor
        addSublayer(shapeLayer)
        
        let textLayer = CATextLayer()
        //textLayer.position = CGPointMake(bounds.midX, bounds.midY)
        textLayer.string = "ISO"
        textLayer.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 10)
        textLayer.fontSize = 10
        textLayer.foregroundColor = kCaptureTintColor.CGColor
        textLayer.preferredFrameSize()
        textLayer.contentsScale = UIScreen.mainScreen().scale
        let pSize = textLayer.preferredFrameSize()
        let x = (b.width - pSize.width)/2
        let y = (b.height - pSize.height)/2
        textLayer.frame = CGRectMake(x, y, pSize.width, pSize.height)
        textLayer.alignmentMode = kCAAlignmentCenter
        addSublayer(textLayer)
    }
    final private func _drawExposureDuration() {
        let b = bounds
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(ovalInRect: b).CGPath
        //shapeLayer.strokeColor = UIColor.whiteColor().CGColor
        //shapeLayer.fillColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).CGColor
        shapeLayer.fillColor = kCaptureTintColor.CGColor
        addSublayer(shapeLayer)
        
        let hands = CAShapeLayer()
        hands.strokeColor = UIColor.whiteColor().CGColor
        hands.lineCap = kCALineCapRound
        hands.lineJoin = kCALineJoinRound
        hands.lineWidth = 1
        hands.fillColor = UIColor.clearColor().CGColor
        let c = CGPointMake(b.midX, b.midY)
        let ma:CGFloat = 0
        let ha:CGFloat = 3.1415*7/9
        let mr:CGFloat = (kSliderKnobRadius-2)
        let hr:CGFloat = (kSliderKnobRadius-5)
        let mp = CGPointMake(c.x+sin(ma)*mr, c.y-cos(ma)*mr)
        let hp = CGPointMake(c.x+sin(ha)*hr, c.y-cos(ha)*hr)
        let handsPath = CGPathCreateMutable()
        CGPathMoveToPoint(handsPath, nil, mp.x-1, mp.y)
        CGPathAddLineToPoint(handsPath, nil, c.x-1, c.y+1)
        CGPathAddLineToPoint(handsPath, nil, hp.x, hp.y)
        hands.path = handsPath
        addSublayer(hands)
    }
    final private func _drawTemperature() {
        let b = bounds
        let gradientLayer = CAGradientLayer()
        let firstHalfColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1).CGColor
        let secondHalfColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1).CGColor
        gradientLayer.frame = b
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 1)
        gradientLayer.colors = [firstHalfColor, firstHalfColor, secondHalfColor, secondHalfColor]
        gradientLayer.locations = [0.0, 0.5, 0.5, 1.0]
        let gradientMaskLayer = CAShapeLayer()
        gradientMaskLayer.path = UIBezierPath(ovalInRect: b).CGPath
        gradientLayer.mask = gradientMaskLayer
        addSublayer(gradientLayer)
    }
    final private func _drawTint() {
        let b = bounds
        let gradientLayer = CAGradientLayer()
        let firstHalfColor = UIColor(red: 0, green: 0.75, blue: 0.25, alpha: 1).CGColor
        let secondHalfColor = UIColor(red: 1, green: 0.25, blue: 0.75, alpha: 1).CGColor
        gradientLayer.frame = b
        gradientLayer.startPoint = CGPointMake(0, 0)
        gradientLayer.endPoint = CGPointMake(1, 1)
        gradientLayer.colors = [firstHalfColor, firstHalfColor, secondHalfColor, secondHalfColor]
        gradientLayer.locations = [0.0, 0.5, 0.5, 1.0]
        let gradientMaskLayer = CAShapeLayer()
        gradientMaskLayer.path = UIBezierPath(ovalInRect: b).CGPath
        gradientLayer.mask = gradientMaskLayer
        addSublayer(gradientLayer)
    }

}
