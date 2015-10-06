//
//  SmartSliderKnobLayer.swift
//  Capture
//
//  Created by Jean on 9/25/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class SmartSliderKnobLayer: CAShapeLayer {
    enum PositionType {
        case Center, Left, Right
    }
    
    let labelTextLayer = CATextLayer()
    var labelTextMinWidth: CGFloat = 0.0 { didSet{ updateTextFrame() } }
    let glyphMargin: CGFloat = 2.0
    let glyph: CALayer
    
    override var bounds: CGRect {
        didSet {
            guard oldValue != bounds else { return }
            updateAnchorPoint()
            updateRoundedRect()
        }
    }
    
    var positionType: PositionType = .Center {
        didSet {
            guard oldValue != positionType else { return }
            updateAnchorPoint()
            updateRoundedRect()
        }
    }
    
    var text: String = "?" {
        didSet {
            guard oldValue != text else { return }
            labelTextLayer.string = text
            updateTextFrame()
        }
    }
    
    init(glyph g:CALayer) {
        glyph = g
        super.init()
        
        fillColor = UIColor.whiteColor().CGColor
        
        labelTextLayer.string = "?"
        labelTextLayer.font = UIFont(name: "HelveticaNeue", size: 12)
        labelTextLayer.fontSize = 12
        labelTextLayer.foregroundColor = kCaptureTintColor.CGColor
        labelTextLayer.contentsScale = UIScreen.mainScreen().scale
        labelTextLayer.alignmentMode = kCAAlignmentRight
        addSublayer(labelTextLayer)
        addSublayer(glyph)
        
        updateTextFrame()
    }
    
    convenience override init(layer: AnyObject) {
        guard let sskLayer = layer as? SmartSliderKnobLayer else {fatalError()}
        self.init(glyph:CALayer(layer: sskLayer.glyph))
        positionType = sskLayer.positionType
        text = sskLayer.text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAnchorPoint() {
        switch positionType {
        case .Left:
            let h = bounds.height, w = bounds.width
            let aCoord = CGPointMake(h / 2, h / 2)
            anchorPoint = CGPointMake(aCoord.x / w, aCoord.y / h)
        case .Center: anchorPoint = CGPointMake(0.5, 0.5)
        case .Right:
            let h = bounds.height, w = bounds.width
            let aCoord = CGPointMake(w - h / 2, h / 2)
            anchorPoint = CGPointMake(aCoord.x / w, aCoord.y / h)
        }
    }
    func updateRoundedRect(){
        let l = min(bounds.width, bounds.height)
        path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: UIRectCorner.AllCorners,
            cornerRadii: CGSizeMake((l / 2), (l / 2))
            ).CGPath
    }
    func updateTextFrame(){
        let pSize = labelTextLayer.preferredFrameSize()
        let glyphDiameter: CGFloat = 22
        let w = max(labelTextMinWidth, pSize.width)
        labelTextLayer.frame = CGRectMake(glyphDiameter, (glyphDiameter-pSize.height)/2, w, glyphDiameter)
        bounds = CGRectMake(0, 0, glyphDiameter + w + 2 + glyphMargin , glyphDiameter)
        glyph.frame = CGRectMake(glyphMargin, glyphMargin, glyph.frame.width, glyph.frame.height)
    }
}
