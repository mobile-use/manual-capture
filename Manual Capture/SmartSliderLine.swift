//
//  SmartSliderLine.swift
//  Capture
//
//  Created by Jean on 9/27/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class SliderLine: CALayer {

}

class SmartSliderLine: CALayer {
    let dashLineLayer1 = CAShapeLayer()
    let dashLineLayer2 = CAShapeLayer()
    let regularLine = CAShapeLayer()
    
    let dashSpace: CGFloat = 4.5
    
    var startPoint: CGPoint
    var endPoint: CGPoint
    private(set) var splitStartPoint: CGPoint
    private(set) var splitEndPoint: CGPoint
    var gapLength: CGFloat
    var progress: CGFloat = 0.0 {
        didSet{
            let sps = SmartSliderLine.splitPoints(
                progress: progress,
                startPoint: startPoint,
                endPoint: endPoint,
                gapLength: gapLength
            )
            splitEndPoint = sps.end
            splitStartPoint = sps.start
        }
    }

    private class func splitPoints(progress progress: CGFloat, startPoint: CGPoint, endPoint: CGPoint, gapLength: CGFloat) -> (start: CGPoint, end: CGPoint) {
        let d = CGSizeMake(
            (endPoint.x - startPoint.x),
            (endPoint.y - startPoint.y)
        )
        
        let ht = sqrt(pow(d.width, 2) + pow(d.height, 2))
        
        let hs = progressValue(progress, 0, ht - gapLength)
        let he = progressValue(progress, gapLength, ht)
        
        let angle = atan(d.height / d.width)
        let ycoef = sin(angle)
        let xcoef = cos(angle)
        
        let sp = CGPointApplyAffineTransform(startPoint, CGAffineTransformMakeTranslation(hs * xcoef, hs * ycoef))
        let ep = CGPointApplyAffineTransform(startPoint, CGAffineTransformMakeTranslation(he * xcoef, he * ycoef))
        return (start: sp, end: ep)
    }
    
    override class func needsDisplayForKey(key: String) -> Bool{
        switch key {
        case "startPoint", "endPoint", "splitStartPoint", "splitEndPoint":
            return true
        default:
            return super.needsDisplayForKey(key)
        }
    }
    
    override init() {
        
        self.startPoint = CGPointZero
        self.endPoint = CGPointZero
        self.gapLength = 0.0
        
        splitEndPoint = CGPointZero
        splitStartPoint = CGPointZero
        
        super.init()
        dashLineLayer1.strokeColor = UIColor.whiteColor().CGColor
        dashLineLayer1.lineWidth = 5
        dashLineLayer1.lineDashPattern = [(0.5), (dashSpace + 0.5)]
        dashLineLayer1.opacity = 0
        dashLineLayer1.hidden = true
        dashLineLayer1.zPosition = -1
        addSublayer(dashLineLayer1)
        
        dashLineLayer2.strokeColor = UIColor.whiteColor().CGColor
        dashLineLayer2.lineWidth = 10
        dashLineLayer2.lineDashPattern = [(0.5), (0.5 + (dashSpace + 1) * 10 - 1)]
        dashLineLayer2.opacity = 0
        dashLineLayer2.hidden = true
        dashLineLayer2.zPosition = -1
        addSublayer(dashLineLayer2)
        
        regularLine.strokeColor = UIColor.whiteColor().CGColor
        regularLine.opacity = 1
        regularLine.lineWidth = 1
        addSublayer(regularLine)
        
        //backgroundColor = UIColor.redColor().CGColor
    }
    
    init(startPoint: CGPoint, endPoint: CGPoint, gapLength: CGFloat) {
        
        let sps = SmartSliderLine.splitPoints(
            progress: progress,
            startPoint: startPoint,
            endPoint: endPoint,
            gapLength: gapLength
        )
        
        self.startPoint = startPoint
        self.endPoint = endPoint
        self.gapLength = gapLength
        
        splitEndPoint = sps.end
        splitStartPoint = sps.start
        
        super.init()
        dashLineLayer1.strokeColor = UIColor.whiteColor().CGColor
        dashLineLayer1.lineWidth = 5
        dashLineLayer1.lineDashPattern = [(0.5), (dashSpace + 0.5)]
        dashLineLayer1.opacity = 0
        dashLineLayer1.hidden = true
        dashLineLayer1.zPosition = -1
        addSublayer(dashLineLayer1)
        
        dashLineLayer2.strokeColor = UIColor.whiteColor().CGColor
        dashLineLayer2.lineWidth = 10
        dashLineLayer2.lineDashPattern = [(0.5), (0.5 + (dashSpace + 1) * 10 - 1)]
        dashLineLayer2.opacity = 0
        dashLineLayer2.hidden = true
        dashLineLayer2.zPosition = -1
        addSublayer(dashLineLayer2)
        
        regularLine.strokeColor = UIColor.whiteColor().CGColor
        regularLine.opacity = 1
        regularLine.lineWidth = 1
        addSublayer(regularLine)
        
        //backgroundColor = UIColor.redColor().CGColor
    }
    
    convenience override init(layer: AnyObject) {
        guard let sslLayer = layer as? SmartSliderLine else { fatalError() }
        self.init(
            startPoint: sslLayer.startPoint,
            endPoint: sslLayer.endPoint,
            gapLength: sslLayer.gapLength
        )
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateLineApearance(initialSensitivity:CGFloat, _ transitionScale: Float, _ travelDistance:CGFloat, _ fingerProgress: Float, _ progress: Float, _ totalDistance: CGFloat) {
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        if (transitionScale != 1) {
            let initScale = 1 / (initialSensitivity)
            let initDisplayScale = min(6, initScale / 2)
            let scale = 1 / (initialSensitivity + abs(1.0 - initialSensitivity) * CGFloat(transitionScale) * 2)
            let displayScale = min(6, scale / 2)
            
            let length = max(bounds.width, bounds.height)
            
            // retina round
            func r(f:CGFloat) -> CGFloat {
                let rs = UIScreen.mainScreen().nativeScale
                return round(f * rs) / rs
            }
            
            let lineWidth1: CGFloat = 0.50
            let lineWidth2: CGFloat = 1.00
            
            /// scaled dash space
            let sDS = dashSpace * displayScale
            
            /// rounded scaled dash space (not)
            let rsDS = r(sDS)//sDS
            
            /// difference of rounded scaled dash space and scaled dash space
            //let drsDS = rsDS - sDS
            
            /// dash pattern length 1
            let dpl1 = rsDS + lineWidth1
            
            //let dashSpeedMag: CGFloat = 1.5 + CGFloat(transitionScale)
            
            //let absTD = abs(travelDistance)
            //let boundFinger = min(1, max(fingerProgress, 0))
            let relDScale = Float(displayScale/initDisplayScale)
            let warpSpeed = relDScale * progress + ((fingerProgress-progress)*2/Float(initialSensitivity) + progress)
            let sabsTD = totalDistance * CGFloat(progressValue(transitionScale, relDScale * fingerProgress, warpSpeed)) //* dashSpeedMag
            let rsabsTD = r(sabsTD)
            //let scaleCenter = r(absTD * 0)//CGFloat(fingerProgress))
            /// dash pattern lengths in in travel distance
            //let dplCount = rsabsTD / dpl1
            
            /// offset resulting from rounding dash space
            //let difT = dplCount * drsDS
            
            let maxLeadingLength = length * (displayScale/initDisplayScale) * CGFloat(progressValue(transitionScale, 1.0, 1.0 / Float(initialSensitivity) ))
            let leadingLength = rsabsTD//, maxLeadingLength)// + scaleCenter //+ difT
            
            dashLineLayer1.lineDashPattern = [lineWidth1, rsDS]
            dashLineLayer1.lineDashPhase = CGFloat(-leadingLength)
            dashLineLayer1.opacity = 1 - Float(transitionScale)
            dashLineLayer1.lineWidth = CGFloat(5 - (4 * transitionScale))
            
            dashLineLayer2.lineDashPattern = [lineWidth2, (dpl1 * 10 - lineWidth2)]
            dashLineLayer2.lineDashPhase = CGFloat(-leadingLength)
            dashLineLayer2.opacity = 1 - Float(transitionScale)
            dashLineLayer2.lineWidth = CGFloat(10 - (9 * transitionScale))
        }
        
        if dashLineLayer1.hidden != (transitionScale == 1.0) || dashLineLayer2.hidden != (transitionScale == 1.0) {
            dashLineLayer1.hidden = (transitionScale == 1.0)
            dashLineLayer2.hidden = (transitionScale == 1.0)
        }
        if regularLine.hidden != (transitionScale == 0.0) {
            regularLine.hidden = (transitionScale == 0.0)
        }
        regularLine.opacity = Float(transitionScale)
        CATransaction.commit()
    }
    
    /*
    override func drawInContext(ctx: CGContext) {
    
    if (transitionScale != 1) {
    var scale = 1 / (initialSensitivity + abs(1.0 - initialSensitivity) * CGFloat(transitionScale) * 0.5)
    //scale = 1 / initialSensitivity
    
    // retina round
    func r(f:CGFloat) -> CGFloat {
    let rs = UIScreen.mainScreen().nativeScale
    return round(f * rs) / rs
    }
    
    let lineWidth1: CGFloat = 0.50
    let lineWidth2: CGFloat = 1.00
    
    /// scaled dash space
    let sDS = dashSpace * scale
    
    /// rounded scaled dash space (not)
    let rsDS = sDS//r(sDS)
    
    /// difference of rounded scaled dash space and scaled dash space
    //let drsDS = rsDS - sDS
    
    /// dash pattern length 1
    let dpl1 = rsDS + lineWidth1
    
    //let dashSpeedMag: CGFloat = 1.5 + CGFloat(transitionScale)
    
    let absTD = abs(travelDistance)
    let sabsTD = absTD * scale //* dashSpeedMag
    let rsabsTD = r(sabsTD)
    let scaleCenter = r(absTD * CGFloat(fingerProgress))
    
    /// dash pattern lengths in in travel distance
    //let dplCount = rsabsTD / dpl1
    
    /// offset resulting from rounding dash space
    //let difT = dplCount * drsDS
    
    let leadingLength = rsabsTD + scaleCenter //+ difT
    
    dashLineLayer1.lineDashPattern = [lineWidth1, rsDS]
    dashLineLayer1.lineDashPhase = CGFloat(-leadingLength)
    dashLineLayer1.opacity = 1 - Float(transitionScale)
    dashLineLayer1.lineWidth = CGFloat(5 - (4 * transitionScale))
    
    dashLineLayer2.lineDashPattern = [lineWidth2, (dpl1 * 10 - lineWidth2)]
    dashLineLayer2.lineDashPhase = CGFloat(-leadingLength)
    dashLineLayer2.opacity = 1 - Float(transitionScale)
    dashLineLayer2.lineWidth = CGFloat(10 - (9 * transitionScale))
    }
    
    if dashLineLayer1.hidden != (transitionScale == 1.0) || dashLineLayer2.hidden != (transitionScale == 1.0) {
    dashLineLayer1.hidden = (transitionScale == 1.0)
    dashLineLayer2.hidden = (transitionScale == 1.0)
    }
    if regularLine.hidden != (transitionScale == 0.0) {
    regularLine.hidden = (transitionScale == 0.0)
    }
    regularLine.opacity = Float(transitionScale)
    
    let dashedColor = UIColor.whiteColor().colorWithAlphaComponent(1 - transitionScale)
    
    CGContextSetLineDash(ctx, CGFloat(-leadingLength), [lineWidth1, rsDS], 2)
    CGContextSetStrokeColorWithColor(ctx, dashedColor)
    }
    
    */ */
}
