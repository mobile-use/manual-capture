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
        case Focus = "Focus", ISO = "ISO", ExposureDuration = "Shutter Speed", Temperature = "Temperature", Tint = "Tint", Zoom = "Zoom", Exposure = "Exposure", WhiteBalance = "White Balance", RGBRed = "RGB Red", RGBGreen = "RGB Green", RGBBlue = "RGB Blue"
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
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        switch type {
        case .Focus: drawFocusGlyph()
        case .ISO: drawISOGlyph()
        case .ExposureDuration: drawShutterSpeedGlyph()
        case .Temperature: drawTemperatureGlyph()
        case .Tint: drawTintGlyph()
        case .Zoom: drawZoomGlyph()
        case .Exposure: drawExposureGlyph()
        case .WhiteBalance: drawWhiteBalanceGlyph()
        case .RGBRed: drawRedRGBGlyph()
        case .RGBGreen: drawGreenRGBGlyph()
        case .RGBBlue: drawBlueRGBGlyph()
        }
        
        let image = UIGraphicsGetImageFromCurrentImageContext().CGImage
        UIGraphicsEndImageContext()
        contents = image
        //_drawSublayers()
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
    
    func drawRedRGBGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// Color Declarations
        let red = UIColor(red: 0.924, green: 0.088, blue: 0.088, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRectMake(frame.minX + 1, frame.minY + 1, 16, 16)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath(ovalInRect: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        red.setFill()
        layerBGPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRectMake(strokeAccountedFrame.minX, strokeAccountedFrame.minY, strokeAccountedFrame.width, strokeAccountedFrame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArcWithCenter(CGPointMake(topHalfRect.midX, topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(M_PI)/180, endAngle: -45 * CGFloat(M_PI)/180, clockwise: true)
        topHalfPath.addLineToPoint(CGPointMake(topHalfRect.midX, topHalfRect.midY))
        topHalfPath.closePath()
        
        UIColor.whiteColor().setFill()
        topHalfPath.fill()
    }
    func drawGreenRGBGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// Color Declarations
        let green = UIColor(red: 0.044, green: 0.825, blue: 0.044, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRectMake(frame.minX + 1, frame.minY + 1, 16, 16)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath(ovalInRect: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        green.setFill()
        layerBGPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRectMake(strokeAccountedFrame.minX, strokeAccountedFrame.minY, strokeAccountedFrame.width, strokeAccountedFrame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArcWithCenter(CGPointMake(topHalfRect.midX, topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(M_PI)/180, endAngle: -45 * CGFloat(M_PI)/180, clockwise: true)
        topHalfPath.addLineToPoint(CGPointMake(topHalfRect.midX, topHalfRect.midY))
        topHalfPath.closePath()
        
        UIColor.whiteColor().setFill()
        topHalfPath.fill()
    }
    func drawBlueRGBGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        
        
        //// Subframes
        let strokeAccountedFrame = CGRectMake(frame.minX + 1, frame.minY + 1, 16, 16)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath(ovalInRect: CGRectMake(frame.minX, frame.minY, frame.width, frame.height))
        UIColor.blueColor().setFill()
        layerBGPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRectMake(strokeAccountedFrame.minX, strokeAccountedFrame.minY, strokeAccountedFrame.width, strokeAccountedFrame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArcWithCenter(CGPointMake(topHalfRect.midX, topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(M_PI)/180, endAngle: -45 * CGFloat(M_PI)/180, clockwise: true)
        topHalfPath.addLineToPoint(CGPointMake(topHalfRect.midX, topHalfRect.midY))
        topHalfPath.closePath()
        
        UIColor.whiteColor().setFill()
        topHalfPath.fill()
    }
    func drawTintGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// Color Declarations
        let whiteBalanceGreen = UIColor(red: 0.010, green: 0.827, blue: 0.173, alpha: 1.000)
        let whiteBalanceMagenta = UIColor(red: 1.000, green: 0.209, blue: 0.889, alpha: 1.000)
        
        //// Bottom Half Drawing
        let bottomHalfRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let bottomHalfPath = UIBezierPath()
        bottomHalfPath.addArcWithCenter(CGPointMake(bottomHalfRect.midX, bottomHalfRect.midY), radius: bottomHalfRect.width / 2, startAngle: -45 * CGFloat(M_PI)/180, endAngle: 135 * CGFloat(M_PI)/180, clockwise: true)
        bottomHalfPath.addLineToPoint(CGPointMake(bottomHalfRect.midX, bottomHalfRect.midY))
        bottomHalfPath.closePath()
        
        whiteBalanceMagenta.setFill()
        bottomHalfPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArcWithCenter(CGPointMake(topHalfRect.midX, topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(M_PI)/180, endAngle: -45 * CGFloat(M_PI)/180, clockwise: true)
        topHalfPath.addLineToPoint(CGPointMake(topHalfRect.midX, topHalfRect.midY))
        topHalfPath.closePath()
        
        whiteBalanceGreen.setFill()
        topHalfPath.fill()
    }
    func drawTemperatureGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// Color Declarations
        let whiteBalanceTan = UIColor(red: 1.000, green: 0.617, blue: 0.000, alpha: 1.000)
        let whiteBalanceCyan = UIColor(red: 0.000, green: 0.625, blue: 1.000, alpha: 1.000)
        
        //// Bottom Half Drawing
        let bottomHalfRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let bottomHalfPath = UIBezierPath()
        bottomHalfPath.addArcWithCenter(CGPointMake(bottomHalfRect.midX, bottomHalfRect.midY), radius: bottomHalfRect.width / 2, startAngle: -45 * CGFloat(M_PI)/180, endAngle: 135 * CGFloat(M_PI)/180, clockwise: true)
        bottomHalfPath.addLineToPoint(CGPointMake(bottomHalfRect.midX, bottomHalfRect.midY))
        bottomHalfPath.closePath()
        
        whiteBalanceTan.setFill()
        bottomHalfPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArcWithCenter(CGPointMake(topHalfRect.midX, topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(M_PI)/180, endAngle: -45 * CGFloat(M_PI)/180, clockwise: true)
        topHalfPath.addLineToPoint(CGPointMake(topHalfRect.midX, topHalfRect.midY))
        topHalfPath.closePath()
        
        whiteBalanceCyan.setFill()
        topHalfPath.fill()
    }
    func drawExposureGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// Color Declarations
        let exposureStrokeColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let exposureBGColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalInRect: CGRectMake(frame.minX, frame.minY, 18, 18))
        exposureStrokeColor.setFill()
        ovalPath.fill()
        
        
        //// Exposure Drawing
        let exposurePath = UIBezierPath()
        exposurePath.moveToPoint(CGPointMake(frame.minX + 14.8, frame.minY + 2.12))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 7.12, frame.minY + 5.25), controlPoint1: CGPointMake(frame.minX + 13.14, frame.minY + 2.79), controlPoint2: CGPointMake(frame.minX + 9.1, frame.minY + 4.44))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 8.78, frame.minY + 1.31), controlPoint1: CGPointMake(frame.minX + 7.7, frame.minY + 3.87), controlPoint2: CGPointMake(frame.minX + 8.32, frame.minY + 2.39))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 9.33, frame.minY + 0.01), controlPoint1: CGPointMake(frame.minX + 9.02, frame.minY + 0.75), controlPoint2: CGPointMake(frame.minX + 9.21, frame.minY + 0.29))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 14.8, frame.minY + 2.12), controlPoint1: CGPointMake(frame.minX + 11.41, frame.minY + 0.08), controlPoint2: CGPointMake(frame.minX + 13.31, frame.minY + 0.86))
        exposurePath.closePath()
        exposurePath.moveToPoint(CGPointMake(frame.minX + 7.76, frame.minY + 1.16))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 5.02, frame.minY + 7.66), controlPoint1: CGPointMake(frame.minX + 6.95, frame.minY + 3.09), controlPoint2: CGPointMake(frame.minX + 5.7, frame.minY + 6.05))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 2.87, frame.minY + 2.41), controlPoint1: CGPointMake(frame.minX + 4.16, frame.minY + 5.56), controlPoint2: CGPointMake(frame.minX + 3.21, frame.minY + 3.23))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 3.53, frame.minY + 1.85), controlPoint1: CGPointMake(frame.minX + 3.08, frame.minY + 2.21), controlPoint2: CGPointMake(frame.minX + 3.3, frame.minY + 2.03))
        exposurePath.addLineToPoint(CGPointMake(frame.minX + 3.68, frame.minY + 1.74))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 5.3, frame.minY + 0.79), controlPoint1: CGPointMake(frame.minX + 4.19, frame.minY + 1.37), controlPoint2: CGPointMake(frame.minX + 4.73, frame.minY + 1.05))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 8.23, frame.minY + 0.03), controlPoint1: CGPointMake(frame.minX + 6.24, frame.minY + 0.37), controlPoint2: CGPointMake(frame.minX + 7.22, frame.minY + 0.12))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 7.76, frame.minY + 1.16), controlPoint1: CGPointMake(frame.minX + 8.11, frame.minY + 0.34), controlPoint2: CGPointMake(frame.minX + 7.94, frame.minY + 0.72))
        exposurePath.closePath()
        exposurePath.moveToPoint(CGPointMake(frame.minX + 17.97, frame.minY + 8.23))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 10.34, frame.minY + 5.02), controlPoint1: CGPointMake(frame.minX + 16.32, frame.minY + 7.54), controlPoint2: CGPointMake(frame.minX + 12.31, frame.minY + 5.85))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 15.59, frame.minY + 2.87), controlPoint1: CGPointMake(frame.minX + 12.44, frame.minY + 4.16), controlPoint2: CGPointMake(frame.minX + 14.76, frame.minY + 3.21))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 17.97, frame.minY + 8.23), controlPoint1: CGPointMake(frame.minX + 16.92, frame.minY + 4.3), controlPoint2: CGPointMake(frame.minX + 17.79, frame.minY + 6.17))
        exposurePath.closePath()
        exposurePath.moveToPoint(CGPointMake(frame.minX + 2.85, frame.minY + 4.99))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 5.25, frame.minY + 10.88), controlPoint1: CGPointMake(frame.minX + 3.63, frame.minY + 6.9), controlPoint2: CGPointMake(frame.minX + 4.66, frame.minY + 9.44))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 0.01, frame.minY + 8.67), controlPoint1: CGPointMake(frame.minX + 3.15, frame.minY + 9.99), controlPoint2: CGPointMake(frame.minX + 0.83, frame.minY + 9.02))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 2.12, frame.minY + 3.2), controlPoint1: CGPointMake(frame.minX + 0.08, frame.minY + 6.63), controlPoint2: CGPointMake(frame.minX + 0.84, frame.minY + 4.71))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 2.85, frame.minY + 4.99), controlPoint1: CGPointMake(frame.minX + 2.3, frame.minY + 3.65), controlPoint2: CGPointMake(frame.minX + 2.56, frame.minY + 4.27))
        exposurePath.closePath()
        exposurePath.moveToPoint(CGPointMake(frame.minX + 17.91, frame.minY + 9.3))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 15.88, frame.minY + 14.8), controlPoint1: CGPointMake(frame.minX + 17.92, frame.minY + 11.41), controlPoint2: CGPointMake(frame.minX + 17.14, frame.minY + 13.31))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 12.75, frame.minY + 7.12), controlPoint1: CGPointMake(frame.minX + 15.21, frame.minY + 13.14), controlPoint2: CGPointMake(frame.minX + 13.56, frame.minY + 9.1))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 17.95, frame.minY + 9.31), controlPoint1: CGPointMake(frame.minX + 14.82, frame.minY + 7.99), controlPoint2: CGPointMake(frame.minX + 17.1, frame.minY + 8.95))
        exposurePath.addLineToPoint(CGPointMake(frame.minX + 17.91, frame.minY + 9.3))
        exposurePath.closePath()
        exposurePath.moveToPoint(CGPointMake(frame.minX + 0.03, frame.minY + 9.77))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 7.66, frame.minY + 12.98), controlPoint1: CGPointMake(frame.minX + 1.68, frame.minY + 10.46), controlPoint2: CGPointMake(frame.minX + 5.69, frame.minY + 12.15))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 2.41, frame.minY + 15.13), controlPoint1: CGPointMake(frame.minX + 5.56, frame.minY + 13.84), controlPoint2: CGPointMake(frame.minX + 3.24, frame.minY + 14.79))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 0.03, frame.minY + 9.77), controlPoint1: CGPointMake(frame.minX + 1.08, frame.minY + 13.7), controlPoint2: CGPointMake(frame.minX + 0.21, frame.minY + 11.83))
        exposurePath.closePath()
        exposurePath.moveToPoint(CGPointMake(frame.minX + 14.4, frame.minY + 13.82))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 15.13, frame.minY + 15.59), controlPoint1: CGPointMake(frame.minX + 14.72, frame.minY + 14.6), controlPoint2: CGPointMake(frame.minX + 14.98, frame.minY + 15.24))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 9.77, frame.minY + 17.97), controlPoint1: CGPointMake(frame.minX + 13.7, frame.minY + 16.92), controlPoint2: CGPointMake(frame.minX + 11.83, frame.minY + 17.79))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 12.98, frame.minY + 10.34), controlPoint1: CGPointMake(frame.minX + 10.46, frame.minY + 16.32), controlPoint2: CGPointMake(frame.minX + 12.15, frame.minY + 12.31))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 14.4, frame.minY + 13.82), controlPoint1: CGPointMake(frame.minX + 13.47, frame.minY + 11.53), controlPoint2: CGPointMake(frame.minX + 13.99, frame.minY + 12.8))
        exposurePath.closePath()
        exposurePath.moveToPoint(CGPointMake(frame.minX + 8.87, frame.minY + 17.52))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 8.67, frame.minY + 17.99), controlPoint1: CGPointMake(frame.minX + 8.79, frame.minY + 17.71), controlPoint2: CGPointMake(frame.minX + 8.72, frame.minY + 17.87))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 3.2, frame.minY + 15.88), controlPoint1: CGPointMake(frame.minX + 6.59, frame.minY + 17.92), controlPoint2: CGPointMake(frame.minX + 4.69, frame.minY + 17.14))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 10.88, frame.minY + 12.75), controlPoint1: CGPointMake(frame.minX + 4.86, frame.minY + 15.21), controlPoint2: CGPointMake(frame.minX + 8.9, frame.minY + 13.56))
        exposurePath.addCurveToPoint(CGPointMake(frame.minX + 8.87, frame.minY + 17.52), controlPoint1: CGPointMake(frame.minX + 10.13, frame.minY + 14.53), controlPoint2: CGPointMake(frame.minX + 9.31, frame.minY + 16.47))
        exposurePath.closePath()
        exposureBGColor.setFill()
        exposurePath.fill()
    }
    func drawShutterSpeedGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// Color Declarations
        let shutterSpeedStrokeColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let shutterSpeedBGColor = UIColor(red: 0.867, green: 0.000, blue: 0.247, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRectMake(frame.minX + 0.5, frame.minY + 0.5, frame.width - 1, frame.height - 1)
        let clockFrame = CGRectMake(strokeAccountedFrame.minX + 0.5, strokeAccountedFrame.minY + 1.5, strokeAccountedFrame.width - 2, strokeAccountedFrame.height - 2)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath()
        layerBGPath.moveToPoint(CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height))
        layerBGPath.closePath()
        shutterSpeedBGColor.setFill()
        layerBGPath.fill()
        shutterSpeedBGColor.setStroke()
        layerBGPath.lineWidth = 1
        layerBGPath.stroke()
        
        
        //// Clock Hands Drawing
        let clockHandsPath = UIBezierPath()
        clockHandsPath.moveToPoint(CGPointMake(clockFrame.minX + 0.50000 * clockFrame.width, clockFrame.minY + 0.03333 * clockFrame.height))
        clockHandsPath.addLineToPoint(CGPointMake(clockFrame.minX + 0.50000 * clockFrame.width, clockFrame.minY + 0.50000 * clockFrame.height))
        clockHandsPath.moveToPoint(CGPointMake(clockFrame.minX + 0.50000 * clockFrame.width, clockFrame.minY + 0.50000 * clockFrame.height))
        clockHandsPath.addLineToPoint(CGPointMake(clockFrame.minX + 0.83333 * clockFrame.width, clockFrame.minY + 0.63333 * clockFrame.height))
        clockHandsPath.lineCapStyle = .Round;
        
        clockHandsPath.lineJoinStyle = .Round;
        
        shutterSpeedStrokeColor.setStroke()
        clockHandsPath.lineWidth = 1
        clockHandsPath.stroke()
    }
    func drawWhiteBalanceGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let whiteBalanceTan = UIColor(red: 1.000, green: 0.617, blue: 0.000, alpha: 1.000)
        let whiteBalanceCyan = UIColor(red: 0.000, green: 0.625, blue: 1.000, alpha: 1.000)
        let whiteBalanceGreen = UIColor(red: 0.010, green: 0.827, blue: 0.173, alpha: 1.000)
        let whiteBalanceMagenta = UIColor(red: 1.000, green: 0.209, blue: 0.889, alpha: 1.000)
        let whiteBalanceTextColor = UIColor(red: 0.611, green: 0.611, blue: 0.611, alpha: 1.000)
        let whiteBalanceBGColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRectMake(frame.minX + 1, frame.minY + 1, frame.width - 2, frame.height - 2)
        
        
        //// Layer BG Drawing
        CGContextSaveGState(context)
        CGContextTranslateCTM(context, strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height)
        
        let layerBGPath = UIBezierPath()
        layerBGPath.moveToPoint(CGPointMake(9, 0))
        layerBGPath.addCurveToPoint(CGPointMake(-0, 9), controlPoint1: CGPointMake(9, 4.97), controlPoint2: CGPointMake(4.97, 9))
        layerBGPath.addCurveToPoint(CGPointMake(-9, 0), controlPoint1: CGPointMake(-4.97, 9), controlPoint2: CGPointMake(-9, 4.97))
        layerBGPath.addCurveToPoint(CGPointMake(0, -9), controlPoint1: CGPointMake(-9, -4.97), controlPoint2: CGPointMake(-4.97, -9))
        layerBGPath.addCurveToPoint(CGPointMake(9, 0), controlPoint1: CGPointMake(4.97, -9), controlPoint2: CGPointMake(9, -4.97))
        layerBGPath.closePath()
        UIColor.whiteColor().setFill()
        layerBGPath.fill()
        
        CGContextRestoreGState(context)
        
        
        //// Tan Pie Drawing
        let tanPieRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let tanPiePath = UIBezierPath()
        tanPiePath.addArcWithCenter(CGPointMake(tanPieRect.midX, tanPieRect.midY), radius: tanPieRect.width / 2, startAngle: 0 * CGFloat(M_PI)/180, endAngle: 90 * CGFloat(M_PI)/180, clockwise: true)
        tanPiePath.addLineToPoint(CGPointMake(tanPieRect.midX, tanPieRect.midY))
        tanPiePath.closePath()
        
        whiteBalanceTan.setFill()
        tanPiePath.fill()
        
        
        //// Magenta Pie Drawing
        let magentaPieRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let magentaPiePath = UIBezierPath()
        magentaPiePath.addArcWithCenter(CGPointMake(magentaPieRect.midX, magentaPieRect.midY), radius: magentaPieRect.width / 2, startAngle: -90 * CGFloat(M_PI)/180, endAngle: 0 * CGFloat(M_PI)/180, clockwise: true)
        magentaPiePath.addLineToPoint(CGPointMake(magentaPieRect.midX, magentaPieRect.midY))
        magentaPiePath.closePath()
        
        whiteBalanceMagenta.setFill()
        magentaPiePath.fill()
        
        
        //// Cyan Pie Drawing
        let cyanPieRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let cyanPiePath = UIBezierPath()
        cyanPiePath.addArcWithCenter(CGPointMake(cyanPieRect.midX, cyanPieRect.midY), radius: cyanPieRect.width / 2, startAngle: -180 * CGFloat(M_PI)/180, endAngle: -90 * CGFloat(M_PI)/180, clockwise: true)
        cyanPiePath.addLineToPoint(CGPointMake(cyanPieRect.midX, cyanPieRect.midY))
        cyanPiePath.closePath()
        
        whiteBalanceCyan.setFill()
        cyanPiePath.fill()
        
        
        //// Green Pie Drawing
        let greenPieRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let greenPiePath = UIBezierPath()
        greenPiePath.addArcWithCenter(CGPointMake(greenPieRect.midX, greenPieRect.midY), radius: greenPieRect.width / 2, startAngle: 90 * CGFloat(M_PI)/180, endAngle: 180 * CGFloat(M_PI)/180, clockwise: true)
        greenPiePath.addLineToPoint(CGPointMake(greenPieRect.midX, greenPieRect.midY))
        greenPiePath.closePath()
        
        whiteBalanceGreen.setFill()
        greenPiePath.fill()
        
        
        //// InnerCircle Drawing
        let innerCirclePath = UIBezierPath()
        innerCirclePath.moveToPoint(CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height))
        innerCirclePath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height))
        innerCirclePath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height))
        innerCirclePath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.20436 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.09673 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.33447 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.08044 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.18773 * strokeAccountedFrame.height))
        innerCirclePath.addLineToPoint(CGPointMake(strokeAccountedFrame.minX + 0.21333 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.09029 * strokeAccountedFrame.height))
        innerCirclePath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.29450 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.03339 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.39335 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height))
        innerCirclePath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height))
        innerCirclePath.closePath()
        whiteBalanceBGColor.setFill()
        innerCirclePath.fill()
        
        
        //// White Balance Text Drawing
        let whiteBalanceTextRect = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        let whiteBalanceTextTextContent = NSString(string: "WB")
        let whiteBalanceTextStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        whiteBalanceTextStyle.alignment = .Center
        
        let whiteBalanceTextFontAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBold", size: 9)!, NSForegroundColorAttributeName: whiteBalanceTextColor, NSParagraphStyleAttributeName: whiteBalanceTextStyle]
        
        let whiteBalanceTextTextHeight: CGFloat = whiteBalanceTextTextContent.boundingRectWithSize(CGSizeMake(whiteBalanceTextRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: whiteBalanceTextFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, whiteBalanceTextRect);
        whiteBalanceTextTextContent.drawInRect(CGRectMake(whiteBalanceTextRect.minX, whiteBalanceTextRect.minY + (whiteBalanceTextRect.height - whiteBalanceTextTextHeight) / 2, whiteBalanceTextRect.width, whiteBalanceTextTextHeight), withAttributes: whiteBalanceTextFontAttributes)
        CGContextRestoreGState(context)
    }
    func drawFocusGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let focusBGColor = UIColor(red: 0.867, green: 0.000, blue: 0.247, alpha: 1.000)
        let focusStrokeColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        
        //// Subframes
        let strokeAcountedFrame = CGRectMake(frame.minX + 1.5, frame.minY + 1.5, frame.width - 3, frame.height - 3)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath()
        layerBGPath.moveToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.50000 * frame.height))
        layerBGPath.addCurveToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 1.00000 * frame.height), controlPoint1: CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.77614 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.77614 * frame.width, frame.minY + 1.00000 * frame.height))
        layerBGPath.addCurveToPoint(CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.50000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.22386 * frame.width, frame.minY + 1.00000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.77614 * frame.height))
        layerBGPath.addCurveToPoint(CGPointMake(frame.minX + 0.50000 * frame.width, frame.minY + 0.00000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.00000 * frame.width, frame.minY + 0.22386 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.22386 * frame.width, frame.minY + 0.00000 * frame.height))
        layerBGPath.addCurveToPoint(CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.50000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.77614 * frame.width, frame.minY + 0.00000 * frame.height), controlPoint2: CGPointMake(frame.minX + 1.00000 * frame.width, frame.minY + 0.22386 * frame.height))
        layerBGPath.closePath()
        focusBGColor.setFill()
        layerBGPath.fill()
        
        
        //// Focus Text Drawing
        let focusTextRect = CGRectMake(strokeAcountedFrame.minX, strokeAcountedFrame.minY, strokeAcountedFrame.width, strokeAcountedFrame.height)
        let focusTextTextContent = NSString(string: "F")
        let focusTextStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        focusTextStyle.alignment = .Center
        
        let focusTextFontAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBold", size: 8)!, NSForegroundColorAttributeName: focusStrokeColor, NSParagraphStyleAttributeName: focusTextStyle]
        
        let focusTextTextHeight: CGFloat = focusTextTextContent.boundingRectWithSize(CGSizeMake(focusTextRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: focusTextFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, focusTextRect);
        focusTextTextContent.drawInRect(CGRectMake(focusTextRect.minX, focusTextRect.minY + (focusTextRect.height - focusTextTextHeight) / 2, focusTextRect.width, focusTextTextHeight), withAttributes: focusTextFontAttributes)
        CGContextRestoreGState(context)
        
        
        //// Target Drawing
        let targetPath = UIBezierPath()
        targetPath.moveToPoint(CGPointMake(strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        targetPath.addCurveToPoint(CGPointMake(strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 1.00000 * strokeAcountedFrame.height), controlPoint1: CGPointMake(strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.77614 * strokeAcountedFrame.height), controlPoint2: CGPointMake(strokeAcountedFrame.minX + 0.77614 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 1.00000 * strokeAcountedFrame.height))
        targetPath.addCurveToPoint(CGPointMake(strokeAcountedFrame.minX + 0.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height), controlPoint1: CGPointMake(strokeAcountedFrame.minX + 0.22386 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 1.00000 * strokeAcountedFrame.height), controlPoint2: CGPointMake(strokeAcountedFrame.minX + 0.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.77614 * strokeAcountedFrame.height))
        targetPath.addCurveToPoint(CGPointMake(strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.00000 * strokeAcountedFrame.height), controlPoint1: CGPointMake(strokeAcountedFrame.minX + 0.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.22386 * strokeAcountedFrame.height), controlPoint2: CGPointMake(strokeAcountedFrame.minX + 0.22386 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.00000 * strokeAcountedFrame.height))
        targetPath.addCurveToPoint(CGPointMake(strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height), controlPoint1: CGPointMake(strokeAcountedFrame.minX + 0.77614 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.00000 * strokeAcountedFrame.height), controlPoint2: CGPointMake(strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.22386 * strokeAcountedFrame.height))
        targetPath.closePath()
        targetPath.moveToPoint(CGPointMake(strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.00000 * strokeAcountedFrame.height))
        targetPath.addLineToPoint(CGPointMake(strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.16667 * strokeAcountedFrame.height))
        targetPath.moveToPoint(CGPointMake(strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.83333 * strokeAcountedFrame.height))
        targetPath.addLineToPoint(CGPointMake(strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 1.00000 * strokeAcountedFrame.height))
        targetPath.moveToPoint(CGPointMake(strokeAcountedFrame.minX + 0.16667 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        targetPath.addLineToPoint(CGPointMake(strokeAcountedFrame.minX + 0.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        targetPath.moveToPoint(CGPointMake(strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        targetPath.addLineToPoint(CGPointMake(strokeAcountedFrame.minX + 0.83333 * strokeAcountedFrame.width, strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        focusStrokeColor.setStroke()
        targetPath.lineWidth = 1
        targetPath.stroke()
    }
    func drawISOGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// General Declarations
        let context = UIGraphicsGetCurrentContext()
        
        //// Color Declarations
        let isoBGColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let isoStrokeColor = UIColor(red: 0.867, green: 0.000, blue: 0.247, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRectMake(frame.minX + 0.5, frame.minY + 0.5, floor((frame.width - 0.5) * 0.97143 + 0.5), floor((frame.height - 0.5) * 0.97143 + 0.5))
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath()
        layerBGPath.moveToPoint(CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height))
        layerBGPath.closePath()
        isoBGColor.setFill()
        layerBGPath.fill()
        isoStrokeColor.setStroke()
        layerBGPath.lineWidth = 1
        layerBGPath.stroke()
        
        
        //// iso Text Drawing
        let isoTextRect = CGRectMake(frame.minX + floor(frame.width * 0.00000 + 0.5), frame.minY + floor(frame.height * 0.00000 + 0.5), floor(frame.width * 1.00000 + 0.5) - floor(frame.width * 0.00000 + 0.5), floor(frame.height * 1.00000 + 0.5) - floor(frame.height * 0.00000 + 0.5))
        let isoTextTextContent = NSString(string: "ISO")
        let isoTextStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        isoTextStyle.alignment = .Center
        
        let isoTextFontAttributes = [NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBold", size: 9)!, NSForegroundColorAttributeName: isoStrokeColor, NSParagraphStyleAttributeName: isoTextStyle]
        
        let isoTextTextHeight: CGFloat = isoTextTextContent.boundingRectWithSize(CGSizeMake(isoTextRect.width, CGFloat.infinity), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: isoTextFontAttributes, context: nil).size.height
        CGContextSaveGState(context)
        CGContextClipToRect(context, isoTextRect);
        isoTextTextContent.drawInRect(CGRectMake(isoTextRect.minX, isoTextRect.minY + (isoTextRect.height - isoTextTextHeight) / 2, isoTextRect.width, isoTextTextHeight), withAttributes: isoTextFontAttributes)
        CGContextRestoreGState(context)
    }
    func drawZoomGlyph(frame frame: CGRect = CGRectMake(0, 0, 18, 18)) {
        //// Color Declarations
        let zoomBGColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let zoomStrokeColor = UIColor(red: 0.867, green: 0.000, blue: 0.247, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRectMake(frame.minX + 0.5, frame.minY + 0.5, floor((frame.width - 0.5) * 0.97143 + 0.5), floor((frame.height - 0.5) * 0.97143 + 0.5))
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath()
        layerBGPath.moveToPoint(CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height))
        layerBGPath.closePath()
        zoomBGColor.setFill()
        layerBGPath.fill()
        zoomStrokeColor.setStroke()
        layerBGPath.lineWidth = 1
        layerBGPath.stroke()
        
        
        //// Zoom Drawing
        let zoomPath = UIBezierPath()
        zoomPath.moveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.54427 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.28831 * strokeAccountedFrame.height))
        zoomPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.54427 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.54427 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.61496 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.35899 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.61496 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.47359 * strokeAccountedFrame.height))
        zoomPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.28831 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.54427 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.47359 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.61496 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.35899 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.61496 * strokeAccountedFrame.height))
        zoomPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.28831 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.28831 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.21762 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.47359 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.21762 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.35899 * strokeAccountedFrame.height))
        zoomPath.addCurveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.54427 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.28831 * strokeAccountedFrame.height), controlPoint1: CGPointMake(strokeAccountedFrame.minX + 0.35899 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.21762 * strokeAccountedFrame.height), controlPoint2: CGPointMake(strokeAccountedFrame.minX + 0.47359 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.21762 * strokeAccountedFrame.height))
        zoomPath.closePath()
        zoomPath.moveToPoint(CGPointMake(strokeAccountedFrame.minX + 0.54427 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.54427 * strokeAccountedFrame.height))
        zoomPath.addLineToPoint(CGPointMake(strokeAccountedFrame.minX + 0.76471 * strokeAccountedFrame.width, strokeAccountedFrame.minY + 0.76471 * strokeAccountedFrame.height))
        zoomStrokeColor.setStroke()
        zoomPath.lineWidth = 1.5
        zoomPath.stroke()
    }
    //    final private func _drawSublayers(){
    //        if let sublayers = sublayers {
    //            for sublayer in sublayers {sublayer.removeFromSuperlayer()}
    //        }
    //        switch type {
    //        case .Focus: _drawFocus()
    //        case .ISO: _drawISO()
    //        case .ExposureDuration: _drawExposureDuration()
    //        case .Temperature: _drawTemperature()
    //        case .Tint: _drawTint()
    //        }
    //    }
    //    final private func _drawFocus() {
    //        let b = bounds
    //        let shapeLayer = CAShapeLayer()
    //        shapeLayer.path = UIBezierPath(ovalInRect: b).CGPath
    //        shapeLayer.fillColor = kCaptureTintColor.CGColor
    //        addSublayer(shapeLayer)
    //
    //        let pointer = CAShapeLayer()
    //        let lp1 = CGPathCreateMutable()
    //        let lp2 = CGPathCreateMutable()
    //        let lp3 = CGPathCreateMutable()
    //        let lp4 = CGPathCreateMutable()
    //        CGPathMoveToPoint(lp1, nil, b.midX, b.minY + 1.5)
    //        CGPathAddLineToPoint(lp1, nil, b.midX, b.minY + 3.5)
    //        CGPathMoveToPoint(lp2, nil, b.minX + 1.5, b.midY)
    //        CGPathAddLineToPoint(lp2, nil, b.minX + 3.5, b.midY)
    //        CGPathMoveToPoint(lp3, nil, b.midX, b.maxY - 1.5)
    //        CGPathAddLineToPoint(lp3, nil, b.midX, b.maxY - 3.5)
    //        CGPathMoveToPoint(lp4, nil, b.maxX - 1.5, b.midY)
    //        CGPathAddLineToPoint(lp4, nil, b.maxX - 3.5, b.midY)
    //        let combinedPath: CGMutablePathRef = CGPathCreateMutableCopy(UIBezierPath(ovalInRect: CGRectMake(1.5, 1.5, b.width-3, b.height-3)).CGPath)!
    //        CGPathAddPath(combinedPath, nil, lp1)
    //        CGPathAddPath(combinedPath, nil, lp2)
    //        CGPathAddPath(combinedPath, nil, lp3)
    //        CGPathAddPath(combinedPath, nil, lp4)
    //        pointer.lineCap = kCALineCapButt
    //        pointer.path = combinedPath
    //        pointer.strokeColor = UIColor.whiteColor().CGColor
    //        pointer.fillColor = UIColor.clearColor().CGColor
    //        addSublayer(pointer)
    //
    //        let textLayer = CATextLayer()
    //        textLayer.string = "F"
    //        textLayer.font = UIFont(name: "HelveticaNeue-CondensedBlack", size: 9)
    //        textLayer.fontSize = 9
    //        textLayer.preferredFrameSize()
    //        textLayer.contentsScale = UIScreen.mainScreen().scale
    //        let pSize = textLayer.preferredFrameSize()
    //        let x = (b.width - pSize.width)/2
    //        let y = (b.height - pSize.height)/2
    //        textLayer.frame = CGRectMake(x, y, pSize.width, pSize.height)
    //        textLayer.alignmentMode = kCAAlignmentCenter
    //        addSublayer(textLayer)
    //    }
    //    final private func _drawISO() {
    //        let b = bounds
    //        let shapeLayer = CAShapeLayer()
    //        shapeLayer.path = UIBezierPath(ovalInRect: b).CGPath
    //        //shapeLayer.strokeColor = kCaptureTintColor.CGColor
    //        shapeLayer.fillColor = UIColor.whiteColor().CGColor
    //        addSublayer(shapeLayer)
    //
    //        let textLayer = CATextLayer()
    //        //textLayer.position = CGPointMake(bounds.midX, bounds.midY)
    //        textLayer.string = "ISO"
    //        textLayer.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 10)
    //        textLayer.fontSize = 10
    //        textLayer.foregroundColor = kCaptureTintColor.CGColor
    //        textLayer.preferredFrameSize()
    //        textLayer.contentsScale = UIScreen.mainScreen().scale
    //        let pSize = textLayer.preferredFrameSize()
    //        let x = (b.width - pSize.width)/2
    //        let y = (b.height - pSize.height)/2
    //        textLayer.frame = CGRectMake(x, y, pSize.width, pSize.height)
    //        textLayer.alignmentMode = kCAAlignmentCenter
    //        addSublayer(textLayer)
    //    }
    //    final private func _drawExposureDuration() {
    //        let b = bounds
    //        let shapeLayer = CAShapeLayer()
    //        shapeLayer.path = UIBezierPath(ovalInRect: b).CGPath
    //        //shapeLayer.strokeColor = UIColor.whiteColor().CGColor
    //        //shapeLayer.fillColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).CGColor
    //        shapeLayer.fillColor = kCaptureTintColor.CGColor
    //        addSublayer(shapeLayer)
    //
    //        let hands = CAShapeLayer()
    //        hands.strokeColor = UIColor.whiteColor().CGColor
    //        hands.lineCap = kCALineCapRound
    //        hands.lineJoin = kCALineJoinRound
    //        hands.lineWidth = 1
    //        hands.fillColor = UIColor.clearColor().CGColor
    //        let c = CGPointMake(b.midX, b.midY)
    //        let ma:CGFloat = 0
    //        let ha:CGFloat = 3.1415*7/9
    //        let mr:CGFloat = (kSliderKnobRadius-2)
    //        let hr:CGFloat = (kSliderKnobRadius-5)
    //        let mp = CGPointMake(c.x+sin(ma)*mr, c.y-cos(ma)*mr)
    //        let hp = CGPointMake(c.x+sin(ha)*hr, c.y-cos(ha)*hr)
    //        let handsPath = CGPathCreateMutable()
    //        CGPathMoveToPoint(handsPath, nil, mp.x-1, mp.y)
    //        CGPathAddLineToPoint(handsPath, nil, c.x-1, c.y+1)
    //        CGPathAddLineToPoint(handsPath, nil, hp.x, hp.y)
    //        hands.path = handsPath
    //        addSublayer(hands)
    //    }
    //    final private func _drawTemperature() {
    //        let b = bounds
    //        let gradientLayer = CAGradientLayer()
    //        let firstHalfColor = UIColor(red: 0, green: 0.5, blue: 1, alpha: 1).CGColor
    //        let secondHalfColor = UIColor(red: 1, green: 0.5, blue: 0, alpha: 1).CGColor
    //        gradientLayer.frame = b
    //        gradientLayer.startPoint = CGPointMake(0, 0)
    //        gradientLayer.endPoint = CGPointMake(1, 1)
    //        gradientLayer.colors = [firstHalfColor, firstHalfColor, secondHalfColor, secondHalfColor]
    //        gradientLayer.locations = [0.0, 0.5, 0.5, 1.0]
    //        let gradientMaskLayer = CAShapeLayer()
    //        gradientMaskLayer.path = UIBezierPath(ovalInRect: b).CGPath
    //        gradientLayer.mask = gradientMaskLayer
    //        addSublayer(gradientLayer)
    //    }
    //    final private func _drawTint() {
    //        let b = bounds
    //        let gradientLayer = CAGradientLayer()
    //        let firstHalfColor = UIColor(red: 0, green: 0.75, blue: 0.25, alpha: 1).CGColor
    //        let secondHalfColor = UIColor(red: 1, green: 0.25, blue: 0.75, alpha: 1).CGColor
    //        gradientLayer.frame = b
    //        gradientLayer.startPoint = CGPointMake(0, 0)
    //        gradientLayer.endPoint = CGPointMake(1, 1)
    //        gradientLayer.colors = [firstHalfColor, firstHalfColor, secondHalfColor, secondHalfColor]
    //        gradientLayer.locations = [0.0, 0.5, 0.5, 1.0]
    //        let gradientMaskLayer = CAShapeLayer()
    //        gradientMaskLayer.path = UIBezierPath(ovalInRect: b).CGPath
    //        gradientLayer.mask = gradientMaskLayer
    //        addSublayer(gradientLayer)
    //    }



}
