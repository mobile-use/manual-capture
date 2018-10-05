//
//  WarpSliderKnobLayer.swift
//  Capture
//
//  Created by Jean on 9/25/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class WarpSliderKnobLayer: CAShapeLayer {
    enum PositionType {
        case center, left, right
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
    
    var positionType: PositionType = .center {
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
        
        fillColor = UIColor.white.cgColor
        
        labelTextLayer.string = "?"
        labelTextLayer.font = UIFont(name: "HelveticaNeue", size: 12)
        labelTextLayer.fontSize = 12
        labelTextLayer.foregroundColor = kCaptureTintColor.cgColor
        labelTextLayer.contentsScale = UIScreen.main.scale
        labelTextLayer.alignmentMode = .right
        addSublayer(labelTextLayer)
        addSublayer(glyph)
        
        updateTextFrame()
    }
    
    convenience override init(layer: Any) {
        guard let sskLayer = layer as? WarpSliderKnobLayer else {fatalError()}
        self.init(glyph:CALayer(layer: sskLayer.glyph))
        positionType = sskLayer.positionType
        text = sskLayer.text
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAnchorPoint() {
        switch positionType {
        case .left:
            let h = bounds.height, w = bounds.width
            let aCoord = CGPoint(x: h / 2, y: h / 2)
            anchorPoint = CGPoint(x: aCoord.x / w, y: aCoord.y / h)
        case .center: anchorPoint = CGPoint(x: 0.5, y: 0.5)
        case .right:
            let h = bounds.height, w = bounds.width
            let aCoord = CGPoint(x: w - h / 2, y: h / 2)
            anchorPoint = CGPoint(x: aCoord.x / w, y: aCoord.y / h)
        }
    }
    func updateRoundedRect(){
        let l = min(bounds.width, bounds.height)
        path = UIBezierPath(
            roundedRect: bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: (l / 2), height: (l / 2))
        ).cgPath
    }
    func updateTextFrame(){
        let pSize = labelTextLayer.preferredFrameSize()
        let glyphDiameter: CGFloat = 22
        let w = max(labelTextMinWidth, pSize.width)
        labelTextLayer.frame = CGRect(x: glyphDiameter, y: (glyphDiameter-pSize.height)/2, width: w, height: glyphDiameter)
        bounds = CGRect(x: 0, y: 0, width: glyphDiameter + w + 2 + glyphMargin , height: glyphDiameter)
        glyph.frame = CGRect(x: glyphMargin, y: glyphMargin, width: glyph.frame.width, height: glyph.frame.height)
    }
}
