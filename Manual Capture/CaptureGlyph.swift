//
//  CaptureGlyph.swift
//  Capture
//
//  Created by Jean on 9/27/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class CaptureGlyph: CALayer {

    enum GlyphType : String {
        case focus = "Focus", iso = "ISO", exposureDuration = "Shutter Speed", temperature = "Temperature", tint = "Tint", zoom = "Zoom", exposure = "Exposure", whiteBalance = "White Balance", rgbRed = "RGB Red", rgbGreen = "RGB Green", rgbBlue = "RGB Blue"
    }
    let type: GlyphType
    var radius: CGFloat = 9 {didSet{
        bounds = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        }
    }
    
    init(type: GlyphType) {
        self.type = type
        super.init()
        frame = CGRect(x: 0, y: 0, width: radius*2, height: radius*2)
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        
        switch type {
        case .focus: drawFocusGlyph()
        case .iso: drawISOGlyph()
        case .exposureDuration: drawShutterSpeedGlyph()
        case .temperature: drawTemperatureGlyph()
        case .tint: drawTintGlyph()
        case .zoom: drawZoomGlyph()
        case .exposure: drawExposureGlyph()
        case .whiteBalance: drawWhiteBalanceGlyph()
        case .rgbRed: drawRedRGBGlyph()
        case .rgbGreen: drawGreenRGBGlyph()
        case .rgbBlue: drawBlueRGBGlyph()
        }
        
        guard let image = UIGraphicsGetImageFromCurrentImageContext()?.cgImage else { fatalError() }
        UIGraphicsEndImageContext()
        contents = image
        //_drawSublayers()
        //backgroundColor = UIColor.redColor().CGColor
    }
    
    convenience override init(layer: Any) {
        guard let gLayer = layer as? CaptureGlyph else {fatalError()}
        self.init(type:gLayer.type)
        self.radius = gLayer.radius
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawRedRGBGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// Color Declarations
        let red = UIColor(red: 0.924, green: 0.088, blue: 0.088, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRect(x: frame.minX + 1, y: frame.minY + 1, width: 16, height: 16)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath(ovalIn: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
        red.setFill()
        layerBGPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRect(x: strokeAccountedFrame.minX, y: strokeAccountedFrame.minY, width: strokeAccountedFrame.width, height: strokeAccountedFrame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArc(withCenter: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(Double.pi)/180, endAngle: -45 * CGFloat(Double.pi)/180, clockwise: true)
        topHalfPath.addLine(to: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY))
        topHalfPath.close()
        
        UIColor.white.setFill()
        topHalfPath.fill()
    }
    func drawGreenRGBGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// Color Declarations
        let green = UIColor(red: 0.044, green: 0.825, blue: 0.044, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRect(x: frame.minX + 1, y: frame.minY + 1, width: 16, height: 16)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath(ovalIn: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
        green.setFill()
        layerBGPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRect(x: strokeAccountedFrame.minX, y: strokeAccountedFrame.minY, width: strokeAccountedFrame.width, height: strokeAccountedFrame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArc(withCenter: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(Double.pi)/180, endAngle: -45 * CGFloat(Double.pi)/180, clockwise: true)
        topHalfPath.addLine(to: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY))
        topHalfPath.close()
        
        UIColor.white.setFill()
        topHalfPath.fill()
    }
    func drawBlueRGBGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        
        
        //// Subframes
        let strokeAccountedFrame = CGRect(x: frame.minX + 1, y: frame.minY + 1, width: 16, height: 16)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath(ovalIn: CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height))
        UIColor.blue.setFill()
        layerBGPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRect(x: strokeAccountedFrame.minX, y: strokeAccountedFrame.minY, width: strokeAccountedFrame.width, height: strokeAccountedFrame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArc(withCenter: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(Double.pi)/180, endAngle: -45 * CGFloat(Double.pi)/180, clockwise: true)
        topHalfPath.addLine(to: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY))
        topHalfPath.close()
        
        UIColor.white.setFill()
        topHalfPath.fill()
    }
    func drawTintGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// Color Declarations
        let whiteBalanceGreen = UIColor(red: 0.010, green: 0.827, blue: 0.173, alpha: 1.000)
        let whiteBalanceMagenta = UIColor(red: 1.000, green: 0.209, blue: 0.889, alpha: 1.000)
        
        //// Bottom Half Drawing
        let bottomHalfRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let bottomHalfPath = UIBezierPath()
        bottomHalfPath.addArc(withCenter: CGPoint(x: bottomHalfRect.midX, y: bottomHalfRect.midY), radius: bottomHalfRect.width / 2, startAngle: -45 * CGFloat(Double.pi)/180, endAngle: 135 * CGFloat(Double.pi)/180, clockwise: true)
        bottomHalfPath.addLine(to: CGPoint(x: bottomHalfRect.midX, y: bottomHalfRect.midY))
        bottomHalfPath.close()
        
        whiteBalanceMagenta.setFill()
        bottomHalfPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArc(withCenter: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(Double.pi)/180, endAngle: -45 * CGFloat(Double.pi)/180, clockwise: true)
        topHalfPath.addLine(to: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY))
        topHalfPath.close()
        
        whiteBalanceGreen.setFill()
        topHalfPath.fill()
    }
    func drawTemperatureGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// Color Declarations
        let whiteBalanceTan = UIColor(red: 1.000, green: 0.617, blue: 0.000, alpha: 1.000)
        let whiteBalanceCyan = UIColor(red: 0.000, green: 0.625, blue: 1.000, alpha: 1.000)
        
        //// Bottom Half Drawing
        let bottomHalfRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let bottomHalfPath = UIBezierPath()
        bottomHalfPath.addArc(withCenter: CGPoint(x: bottomHalfRect.midX, y: bottomHalfRect.midY), radius: bottomHalfRect.width / 2, startAngle: -45 * CGFloat(Double.pi)/180, endAngle: 135 * CGFloat(Double.pi)/180, clockwise: true)
        bottomHalfPath.addLine(to: CGPoint(x: bottomHalfRect.midX, y: bottomHalfRect.midY))
        bottomHalfPath.close()
        
        whiteBalanceTan.setFill()
        bottomHalfPath.fill()
        
        
        //// Top Half Drawing
        let topHalfRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let topHalfPath = UIBezierPath()
        topHalfPath.addArc(withCenter: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY), radius: topHalfRect.width / 2, startAngle: -225 * CGFloat(Double.pi)/180, endAngle: -45 * CGFloat(Double.pi)/180, clockwise: true)
        topHalfPath.addLine(to: CGPoint(x: topHalfRect.midX, y: topHalfRect.midY))
        topHalfPath.close()
        
        whiteBalanceCyan.setFill()
        topHalfPath.fill()
    }
    func drawExposureGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// Color Declarations
        let exposureStrokeColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let exposureBGColor = UIColor(red: 0.000, green: 0.000, blue: 0.000, alpha: 1.000)
        
        //// Oval Drawing
        let ovalPath = UIBezierPath(ovalIn: CGRect(x: frame.minX, y: frame.minY, width: 18, height: 18))
        exposureStrokeColor.setFill()
        ovalPath.fill()
        
        
        //// Exposure Drawing
        let exposurePath = UIBezierPath()
        exposurePath.move(to: CGPoint(x: frame.minX + 14.8, y: frame.minY + 2.12))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 7.12, y: frame.minY + 5.25), controlPoint1: CGPoint(x: frame.minX + 13.14, y: frame.minY + 2.79), controlPoint2: CGPoint(x: frame.minX + 9.1, y: frame.minY + 4.44))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 8.78, y: frame.minY + 1.31), controlPoint1: CGPoint(x: frame.minX + 7.7, y: frame.minY + 3.87), controlPoint2: CGPoint(x: frame.minX + 8.32, y: frame.minY + 2.39))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 9.33, y: frame.minY + 0.01), controlPoint1: CGPoint(x: frame.minX + 9.02, y: frame.minY + 0.75), controlPoint2: CGPoint(x: frame.minX + 9.21, y: frame.minY + 0.29))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 14.8, y: frame.minY + 2.12), controlPoint1: CGPoint(x: frame.minX + 11.41, y: frame.minY + 0.08), controlPoint2: CGPoint(x: frame.minX + 13.31, y: frame.minY + 0.86))
        exposurePath.close()
        exposurePath.move(to: CGPoint(x: frame.minX + 7.76, y: frame.minY + 1.16))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 5.02, y: frame.minY + 7.66), controlPoint1: CGPoint(x: frame.minX + 6.95, y: frame.minY + 3.09), controlPoint2: CGPoint(x: frame.minX + 5.7, y: frame.minY + 6.05))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 2.87, y: frame.minY + 2.41), controlPoint1: CGPoint(x: frame.minX + 4.16, y: frame.minY + 5.56), controlPoint2: CGPoint(x: frame.minX + 3.21, y: frame.minY + 3.23))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 3.53, y: frame.minY + 1.85), controlPoint1: CGPoint(x: frame.minX + 3.08, y: frame.minY + 2.21), controlPoint2: CGPoint(x: frame.minX + 3.3, y: frame.minY + 2.03))
        exposurePath.addLine(to: CGPoint(x: frame.minX + 3.68, y: frame.minY + 1.74))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 5.3, y: frame.minY + 0.79), controlPoint1: CGPoint(x: frame.minX + 4.19, y: frame.minY + 1.37), controlPoint2: CGPoint(x: frame.minX + 4.73, y: frame.minY + 1.05))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 8.23, y: frame.minY + 0.03), controlPoint1: CGPoint(x: frame.minX + 6.24, y: frame.minY + 0.37), controlPoint2: CGPoint(x: frame.minX + 7.22, y: frame.minY + 0.12))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 7.76, y: frame.minY + 1.16), controlPoint1: CGPoint(x: frame.minX + 8.11, y: frame.minY + 0.34), controlPoint2: CGPoint(x: frame.minX + 7.94, y: frame.minY + 0.72))
        exposurePath.close()
        exposurePath.move(to: CGPoint(x: frame.minX + 17.97, y: frame.minY + 8.23))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 10.34, y: frame.minY + 5.02), controlPoint1: CGPoint(x: frame.minX + 16.32, y: frame.minY + 7.54), controlPoint2: CGPoint(x: frame.minX + 12.31, y: frame.minY + 5.85))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 15.59, y: frame.minY + 2.87), controlPoint1: CGPoint(x: frame.minX + 12.44, y: frame.minY + 4.16), controlPoint2: CGPoint(x: frame.minX + 14.76, y: frame.minY + 3.21))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 17.97, y: frame.minY + 8.23), controlPoint1: CGPoint(x: frame.minX + 16.92, y: frame.minY + 4.3), controlPoint2: CGPoint(x: frame.minX + 17.79, y: frame.minY + 6.17))
        exposurePath.close()
        exposurePath.move(to: CGPoint(x: frame.minX + 2.85, y: frame.minY + 4.99))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 5.25, y: frame.minY + 10.88), controlPoint1: CGPoint(x: frame.minX + 3.63, y: frame.minY + 6.9), controlPoint2: CGPoint(x: frame.minX + 4.66, y: frame.minY + 9.44))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 0.01, y: frame.minY + 8.67), controlPoint1: CGPoint(x: frame.minX + 3.15, y: frame.minY + 9.99), controlPoint2: CGPoint(x: frame.minX + 0.83, y: frame.minY + 9.02))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 2.12, y: frame.minY + 3.2), controlPoint1: CGPoint(x: frame.minX + 0.08, y: frame.minY + 6.63), controlPoint2: CGPoint(x: frame.minX + 0.84, y: frame.minY + 4.71))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 2.85, y: frame.minY + 4.99), controlPoint1: CGPoint(x: frame.minX + 2.3, y: frame.minY + 3.65), controlPoint2: CGPoint(x: frame.minX + 2.56, y: frame.minY + 4.27))
        exposurePath.close()
        exposurePath.move(to: CGPoint(x: frame.minX + 17.91, y: frame.minY + 9.3))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 15.88, y: frame.minY + 14.8), controlPoint1: CGPoint(x: frame.minX + 17.92, y: frame.minY + 11.41), controlPoint2: CGPoint(x: frame.minX + 17.14, y: frame.minY + 13.31))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 12.75, y: frame.minY + 7.12), controlPoint1: CGPoint(x: frame.minX + 15.21, y: frame.minY + 13.14), controlPoint2: CGPoint(x: frame.minX + 13.56, y: frame.minY + 9.1))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 17.95, y: frame.minY + 9.31), controlPoint1: CGPoint(x: frame.minX + 14.82, y: frame.minY + 7.99), controlPoint2: CGPoint(x: frame.minX + 17.1, y: frame.minY + 8.95))
        exposurePath.addLine(to: CGPoint(x: frame.minX + 17.91, y: frame.minY + 9.3))
        exposurePath.close()
        exposurePath.move(to: CGPoint(x: frame.minX + 0.03, y: frame.minY + 9.77))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 7.66, y: frame.minY + 12.98), controlPoint1: CGPoint(x: frame.minX + 1.68, y: frame.minY + 10.46), controlPoint2: CGPoint(x: frame.minX + 5.69, y: frame.minY + 12.15))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 2.41, y: frame.minY + 15.13), controlPoint1: CGPoint(x: frame.minX + 5.56, y: frame.minY + 13.84), controlPoint2: CGPoint(x: frame.minX + 3.24, y: frame.minY + 14.79))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 0.03, y: frame.minY + 9.77), controlPoint1: CGPoint(x: frame.minX + 1.08, y: frame.minY + 13.7), controlPoint2: CGPoint(x: frame.minX + 0.21, y: frame.minY + 11.83))
        exposurePath.close()
        exposurePath.move(to: CGPoint(x: frame.minX + 14.4, y: frame.minY + 13.82))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 15.13, y: frame.minY + 15.59), controlPoint1: CGPoint(x: frame.minX + 14.72, y: frame.minY + 14.6), controlPoint2: CGPoint(x: frame.minX + 14.98, y: frame.minY + 15.24))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 9.77, y: frame.minY + 17.97), controlPoint1: CGPoint(x: frame.minX + 13.7, y: frame.minY + 16.92), controlPoint2: CGPoint(x: frame.minX + 11.83, y: frame.minY + 17.79))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 12.98, y: frame.minY + 10.34), controlPoint1: CGPoint(x: frame.minX + 10.46, y: frame.minY + 16.32), controlPoint2: CGPoint(x: frame.minX + 12.15, y: frame.minY + 12.31))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 14.4, y: frame.minY + 13.82), controlPoint1: CGPoint(x: frame.minX + 13.47, y: frame.minY + 11.53), controlPoint2: CGPoint(x: frame.minX + 13.99, y: frame.minY + 12.8))
        exposurePath.close()
        exposurePath.move(to: CGPoint(x: frame.minX + 8.87, y: frame.minY + 17.52))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 8.67, y: frame.minY + 17.99), controlPoint1: CGPoint(x: frame.minX + 8.79, y: frame.minY + 17.71), controlPoint2: CGPoint(x: frame.minX + 8.72, y: frame.minY + 17.87))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 3.2, y: frame.minY + 15.88), controlPoint1: CGPoint(x: frame.minX + 6.59, y: frame.minY + 17.92), controlPoint2: CGPoint(x: frame.minX + 4.69, y: frame.minY + 17.14))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 10.88, y: frame.minY + 12.75), controlPoint1: CGPoint(x: frame.minX + 4.86, y: frame.minY + 15.21), controlPoint2: CGPoint(x: frame.minX + 8.9, y: frame.minY + 13.56))
        exposurePath.addCurve(to: CGPoint(x: frame.minX + 8.87, y: frame.minY + 17.52), controlPoint1: CGPoint(x: frame.minX + 10.13, y: frame.minY + 14.53), controlPoint2: CGPoint(x: frame.minX + 9.31, y: frame.minY + 16.47))
        exposurePath.close()
        exposureBGColor.setFill()
        exposurePath.fill()
    }
    func drawShutterSpeedGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// Color Declarations
        let shutterSpeedStrokeColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let shutterSpeedBGColor = UIColor(red: 0.867, green: 0.000, blue: 0.247, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRect(x: frame.minX + 0.5, y: frame.minY + 0.5, width:frame.width - 1, height: frame.height - 1)
        let clockFrame = CGRect(x: strokeAccountedFrame.minX + 0.5, y: strokeAccountedFrame.minY + 1.5, width: strokeAccountedFrame.width - 2, height: strokeAccountedFrame.height - 2)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath()
        layerBGPath.move(to: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height))
        layerBGPath.close()
        shutterSpeedBGColor.setFill()
        layerBGPath.fill()
        shutterSpeedBGColor.setStroke()
        layerBGPath.lineWidth = 1
        layerBGPath.stroke()
        
        
        //// Clock Hands Drawing
        let clockHandsPath = UIBezierPath()
        clockHandsPath.move(to: CGPoint(x: clockFrame.minX + 0.50000 * clockFrame.width, y: clockFrame.minY + 0.03333 * clockFrame.height))
        clockHandsPath.addLine(to: CGPoint(x: clockFrame.minX + 0.50000 * clockFrame.width, y: clockFrame.minY + 0.50000 * clockFrame.height))
        clockHandsPath.move(to: CGPoint(x: clockFrame.minX + 0.50000 * clockFrame.width, y: clockFrame.minY + 0.50000 * clockFrame.height))
        clockHandsPath.addLine(to: CGPoint(x: clockFrame.minX + 0.83333 * clockFrame.width, y: clockFrame.minY + 0.63333 * clockFrame.height))
        clockHandsPath.lineCapStyle = .round;
        
        clockHandsPath.lineJoinStyle = .round;
        
        shutterSpeedStrokeColor.setStroke()
        clockHandsPath.lineWidth = 1
        clockHandsPath.stroke()
    }
    func drawWhiteBalanceGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// General Declarations
        guard let context = UIGraphicsGetCurrentContext() else { fatalError() }
        
        //// Color Declarations
        let whiteBalanceTan = UIColor(red: 1.000, green: 0.617, blue: 0.000, alpha: 1.000)
        let whiteBalanceCyan = UIColor(red: 0.000, green: 0.625, blue: 1.000, alpha: 1.000)
        let whiteBalanceGreen = UIColor(red: 0.010, green: 0.827, blue: 0.173, alpha: 1.000)
        let whiteBalanceMagenta = UIColor(red: 1.000, green: 0.209, blue: 0.889, alpha: 1.000)
        let whiteBalanceTextColor = UIColor(red: 0.611, green: 0.611, blue: 0.611, alpha: 1.000)
        let whiteBalanceBGColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRect(x: frame.minX + 1, y: frame.minY + 1, width: frame.width - 2, height: frame.height - 2)
        
        
        //// Layer BG Drawing
        context.saveGState()
        context.translateBy(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height)
        
        let layerBGPath = UIBezierPath()
        layerBGPath.move(to: CGPoint(x: 9, y: 0))
        layerBGPath.addCurve(to: CGPoint(x: -0, y: 9), controlPoint1: CGPoint(x: 9, y: 4.97), controlPoint2: CGPoint(x: 4.97, y: 9))
        layerBGPath.addCurve(to: CGPoint(x: -9, y: 0), controlPoint1: CGPoint(x: -4.97, y: 9), controlPoint2: CGPoint(x: -9, y: 4.97))
        layerBGPath.addCurve(to: CGPoint(x: 0, y: -9), controlPoint1: CGPoint(x: -9, y: -4.97), controlPoint2: CGPoint(x: -4.97, y: -9))
        layerBGPath.addCurve(to: CGPoint(x: 9, y: 0), controlPoint1: CGPoint(x: 4.97, y: -9), controlPoint2: CGPoint(x: 9, y: -4.97))
        layerBGPath.close()
        UIColor.white.setFill()
        layerBGPath.fill()
        
        context.saveGState()
        
        
        //// Tan Pie Drawing
        let tanPieRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let tanPiePath = UIBezierPath()
        tanPiePath.addArc(withCenter: CGPoint(x: tanPieRect.midX, y: tanPieRect.midY), radius: tanPieRect.width / 2, startAngle: 0 * CGFloat(Double.pi)/180, endAngle: 90 * CGFloat(Double.pi)/180, clockwise: true)
        tanPiePath.addLine(to: CGPoint(x: tanPieRect.midX, y: tanPieRect.midY))
        tanPiePath.close()
        
        whiteBalanceTan.setFill()
        tanPiePath.fill()
        
        
        //// Magenta Pie Drawing
        let magentaPieRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let magentaPiePath = UIBezierPath()
        magentaPiePath.addArc(withCenter: CGPoint(x: magentaPieRect.midX, y: magentaPieRect.midY), radius: magentaPieRect.width / 2, startAngle: -90 * CGFloat(Double.pi)/180, endAngle: 0 * CGFloat(Double.pi)/180, clockwise: true)
        magentaPiePath.addLine(to: CGPoint(x: magentaPieRect.midX, y: magentaPieRect.midY))
        magentaPiePath.close()
        
        whiteBalanceMagenta.setFill()
        magentaPiePath.fill()
        
        
        //// Cyan Pie Drawing
        let cyanPieRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let cyanPiePath = UIBezierPath()
        cyanPiePath.addArc(withCenter: CGPoint(x: cyanPieRect.midX, y: cyanPieRect.midY), radius: cyanPieRect.width / 2, startAngle: -180 * CGFloat(Double.pi)/180, endAngle: -90 * CGFloat(Double.pi)/180, clockwise: true)
        cyanPiePath.addLine(to: CGPoint(x: cyanPieRect.midX, y: cyanPieRect.midY))
        cyanPiePath.close()
        
        whiteBalanceCyan.setFill()
        cyanPiePath.fill()
        
        
        //// Green Pie Drawing
        let greenPieRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let greenPiePath = UIBezierPath()
        greenPiePath.addArc(withCenter: CGPoint(x: greenPieRect.midX, y: greenPieRect.midY), radius: greenPieRect.width / 2, startAngle: 90 * CGFloat(Double.pi)/180, endAngle: 180 * CGFloat(Double.pi)/180, clockwise: true)
        greenPiePath.addLine(to: CGPoint(x: greenPieRect.midX, y: greenPieRect.midY))
        greenPiePath.close()
        
        whiteBalanceGreen.setFill()
        greenPiePath.fill()
        
        
        //// InnerCircle Drawing
        let innerCirclePath = UIBezierPath()
        innerCirclePath.move(to: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height))
        innerCirclePath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height))
        innerCirclePath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height))
        innerCirclePath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.20436 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.09673 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.33447 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.08044 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.18773 * strokeAccountedFrame.height))
        innerCirclePath.addLine(to: CGPoint(x: strokeAccountedFrame.minX + 0.21333 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.09029 * strokeAccountedFrame.height))
        innerCirclePath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.29450 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.03339 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.39335 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height))
        innerCirclePath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height))
        innerCirclePath.close()
        whiteBalanceBGColor.setFill()
        innerCirclePath.fill()
        
        
        //// White Balance Text Drawing
        let whiteBalanceTextRect = CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: frame.height)
        let whiteBalanceTextTextContent = NSString(string: "WB")
        let whiteBalanceTextStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        whiteBalanceTextStyle.alignment = .center
        
        let whiteBalanceTextFontAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBold", size: 9)!, NSAttributedString.Key.foregroundColor: whiteBalanceTextColor, NSAttributedString.Key.paragraphStyle: whiteBalanceTextStyle]
        
        let whiteBalanceTextTextHeight: CGFloat = whiteBalanceTextTextContent.boundingRect(with: CGSize(width: whiteBalanceTextRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: whiteBalanceTextFontAttributes, context: nil).size.height
        context.saveGState()
        context.clip(to: whiteBalanceTextRect)
        whiteBalanceTextTextContent.draw(in: CGRect(x: whiteBalanceTextRect.minX, y: whiteBalanceTextRect.minY + (whiteBalanceTextRect.height - whiteBalanceTextTextHeight) / 2, width: whiteBalanceTextRect.width, height: whiteBalanceTextTextHeight), withAttributes: whiteBalanceTextFontAttributes)
        context.restoreGState()
    }
    func drawFocusGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// General Declarations
        guard let context = UIGraphicsGetCurrentContext() else { fatalError() }
        
        //// Color Declarations
        let focusBGColor = UIColor(red: 0.867, green: 0.000, blue: 0.247, alpha: 1.000)
        let focusStrokeColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        
        
        //// Subframes
        let strokeAcountedFrame = CGRect(x: frame.minX + 1.5, y: frame.minY + 1.5, width: frame.width - 3, height: frame.height - 3)
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath()
        layerBGPath.move(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.50000 * frame.height))
        layerBGPath.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.77614 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.77614 * frame.width, y: frame.minY + 1.00000 * frame.height))
        layerBGPath.addCurve(to: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.22386 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.77614 * frame.height))
        layerBGPath.addCurve(to: CGPoint(x: frame.minX + 0.50000 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.00000 * frame.width, y: frame.minY + 0.22386 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.22386 * frame.width, y: frame.minY + 0.00000 * frame.height))
        layerBGPath.addCurve(to: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.50000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.77614 * frame.width, y: frame.minY + 0.00000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 1.00000 * frame.width, y: frame.minY + 0.22386 * frame.height))
        layerBGPath.close()
        focusBGColor.setFill()
        layerBGPath.fill()
        
        
        //// Focus Text Drawing
        let focusTextRect = CGRect(x: strokeAcountedFrame.minX, y: strokeAcountedFrame.minY, width: strokeAcountedFrame.width, height: strokeAcountedFrame.height)
        let focusTextTextContent = NSString(string: "F")
        let focusTextStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        focusTextStyle.alignment = .center
        
        let focusTextFontAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBold", size: 8)!, NSAttributedString.Key.foregroundColor: focusStrokeColor, NSAttributedString.Key.paragraphStyle: focusTextStyle]
        
        let focusTextTextHeight: CGFloat = focusTextTextContent.boundingRect(with: CGSize(width: focusTextRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: focusTextFontAttributes, context: nil).size.height
        context.saveGState()
        context.clip(to: focusTextRect)
        focusTextTextContent.draw(in: CGRect(x: focusTextRect.minX, y: focusTextRect.minY + (focusTextRect.height - focusTextTextHeight) / 2, width: focusTextRect.width, height: focusTextTextHeight), withAttributes: focusTextFontAttributes)
        context.restoreGState()
        
        
        //// Target Drawing
        let targetPath = UIBezierPath()
        targetPath.move(to: CGPoint(x: strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        targetPath.addCurve(to: CGPoint(x: strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 1.00000 * strokeAcountedFrame.height), controlPoint1: CGPoint(x: strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.77614 * strokeAcountedFrame.height), controlPoint2: CGPoint(x: strokeAcountedFrame.minX + 0.77614 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 1.00000 * strokeAcountedFrame.height))
        targetPath.addCurve(to: CGPoint(x: strokeAcountedFrame.minX + 0.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height), controlPoint1: CGPoint(x: strokeAcountedFrame.minX + 0.22386 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 1.00000 * strokeAcountedFrame.height), controlPoint2: CGPoint(x: strokeAcountedFrame.minX + 0.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.77614 * strokeAcountedFrame.height))
        targetPath.addCurve(to: CGPoint(x: strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.00000 * strokeAcountedFrame.height), controlPoint1: CGPoint(x: strokeAcountedFrame.minX + 0.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.22386 * strokeAcountedFrame.height), controlPoint2: CGPoint(x: strokeAcountedFrame.minX + 0.22386 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.00000 * strokeAcountedFrame.height))
        targetPath.addCurve(to: CGPoint(x: strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height), controlPoint1: CGPoint(x: strokeAcountedFrame.minX + 0.77614 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.00000 * strokeAcountedFrame.height), controlPoint2: CGPoint(x: strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.22386 * strokeAcountedFrame.height))
        targetPath.close()
        targetPath.move(to: CGPoint(x: strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.00000 * strokeAcountedFrame.height))
        targetPath.addLine(to: CGPoint(x: strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.16667 * strokeAcountedFrame.height))
        targetPath.move(to: CGPoint(x: strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.83333 * strokeAcountedFrame.height))
        targetPath.addLine(to: CGPoint(x: strokeAcountedFrame.minX + 0.50000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 1.00000 * strokeAcountedFrame.height))
        targetPath.move(to: CGPoint(x: strokeAcountedFrame.minX + 0.16667 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        targetPath.addLine(to: CGPoint(x: strokeAcountedFrame.minX + 0.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        targetPath.move(to: CGPoint(x: strokeAcountedFrame.minX + 1.00000 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        targetPath.addLine(to: CGPoint(x: strokeAcountedFrame.minX + 0.83333 * strokeAcountedFrame.width, y: strokeAcountedFrame.minY + 0.50000 * strokeAcountedFrame.height))
        focusStrokeColor.setStroke()
        targetPath.lineWidth = 1
        targetPath.stroke()
    }
    func drawISOGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// General Declarations
        guard let context = UIGraphicsGetCurrentContext() else { fatalError() }
        
        //// Color Declarations
        let isoBGColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let isoStrokeColor = UIColor(red: 0.867, green: 0.000, blue: 0.247, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRect(x: frame.minX + 0.5, y: frame.minY + 0.5, width: floor((frame.width - 0.5) * 0.97143 + 0.5), height: floor((frame.height - 0.5) * 0.97143 + 0.5))
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath()
        layerBGPath.move(to: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height))
        layerBGPath.close()
        isoBGColor.setFill()
        layerBGPath.fill()
        isoStrokeColor.setStroke()
        layerBGPath.lineWidth = 1
        layerBGPath.stroke()
        
        
        //// iso Text Drawing
        let isoTextRect = CGRect(x: frame.minX + floor(frame.width * 0.00000 + 0.5), y: frame.minY + floor(frame.height * 0.00000 + 0.5), width: floor(frame.width * 1.00000 + 0.5) - floor(frame.width * 0.00000 + 0.5), height: floor(frame.height * 1.00000 + 0.5) - floor(frame.height * 0.00000 + 0.5))
        let isoTextTextContent = NSString(string: "ISO")
        let isoTextStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
        isoTextStyle.alignment = .center
        
        let isoTextFontAttributes = [NSAttributedString.Key.font: UIFont(name: "HelveticaNeue-CondensedBold", size: 9)!, NSAttributedString.Key.foregroundColor: isoStrokeColor, NSAttributedString.Key.paragraphStyle: isoTextStyle]
        
        let isoTextTextHeight: CGFloat = isoTextTextContent.boundingRect(with: CGSize(width: isoTextRect.width, height: CGFloat.infinity), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: isoTextFontAttributes, context: nil).size.height
        context.saveGState()
        context.clip(to: isoTextRect)
        isoTextTextContent.draw(in: CGRect(x: isoTextRect.minX, y: isoTextRect.minY + (isoTextRect.height - isoTextTextHeight) / 2, width: isoTextRect.width, height: isoTextTextHeight), withAttributes: isoTextFontAttributes)
        context.restoreGState()
    }
    func drawZoomGlyph(_ frame: CGRect = CGRect(x: 0, y: 0, width: 18, height: 18)) {
        //// Color Declarations
        let zoomBGColor = UIColor(red: 1.000, green: 1.000, blue: 1.000, alpha: 1.000)
        let zoomStrokeColor = UIColor(red: 0.867, green: 0.000, blue: 0.247, alpha: 1.000)
        
        
        //// Subframes
        let strokeAccountedFrame = CGRect(x: frame.minX + 0.5, y: frame.minY + 0.5, width: floor((frame.width - 0.5) * 0.97143 + 0.5), height: floor((frame.height - 0.5) * 0.97143 + 0.5))
        
        
        //// Layer BG Drawing
        let layerBGPath = UIBezierPath()
        layerBGPath.move(to: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 1.00000 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.77614 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.50000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.22386 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height))
        layerBGPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.50000 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.77614 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.00000 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 1.00000 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.22386 * strokeAccountedFrame.height))
        layerBGPath.close()
        zoomBGColor.setFill()
        layerBGPath.fill()
        zoomStrokeColor.setStroke()
        layerBGPath.lineWidth = 1
        layerBGPath.stroke()
        
        
        //// Zoom Drawing
        let zoomPath = UIBezierPath()
        zoomPath.move(to: CGPoint(x: strokeAccountedFrame.minX + 0.54427 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.28831 * strokeAccountedFrame.height))
        zoomPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.54427 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.54427 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.61496 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.35899 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.61496 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.47359 * strokeAccountedFrame.height))
        zoomPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.28831 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.54427 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.47359 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.61496 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.35899 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.61496 * strokeAccountedFrame.height))
        zoomPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.28831 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.28831 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.21762 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.47359 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.21762 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.35899 * strokeAccountedFrame.height))
        zoomPath.addCurve(to: CGPoint(x: strokeAccountedFrame.minX + 0.54427 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.28831 * strokeAccountedFrame.height), controlPoint1: CGPoint(x: strokeAccountedFrame.minX + 0.35899 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.21762 * strokeAccountedFrame.height), controlPoint2: CGPoint(x: strokeAccountedFrame.minX + 0.47359 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.21762 * strokeAccountedFrame.height))
        zoomPath.close()
        zoomPath.move(to: CGPoint(x: strokeAccountedFrame.minX + 0.54427 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.54427 * strokeAccountedFrame.height))
        zoomPath.addLine(to: CGPoint(x: strokeAccountedFrame.minX + 0.76471 * strokeAccountedFrame.width, y: strokeAccountedFrame.minY + 0.76471 * strokeAccountedFrame.height))
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
    //        let combinedPath: CGMutablePathRef = CGPathCreateMutableCopy(UIBezierPath(ovalInRect: CGRect(1.5, 1.5, b.width-3, b.height-3)).CGPath)!
    //        CGPathAddPath(combinedPath, nil, lp1)
    //        CGPathAddPath(combinedPath, nil, lp2)
    //        CGPathAddPath(combinedPath, nil, lp3)
    //        CGPathAddPath(combinedPath, nil, lp4)
    //        pointer.lineCap = kCALineCapButt
    //        pointer.path = combinedPath
    //        pointer.strokeColor = UIColor.white.CGColor
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
    //        textLayer.frame = CGRect(x, y, pSize.width, pSize.height)
    //        textLayer.alignmentMode = kCAAlignmentCenter
    //        addSublayer(textLayer)
    //    }
    //    final private func _drawISO() {
    //        let b = bounds
    //        let shapeLayer = CAShapeLayer()
    //        shapeLayer.path = UIBezierPath(ovalInRect: b).CGPath
    //        //shapeLayer.strokeColor = kCaptureTintColor.CGColor
    //        shapeLayer.fillColor = UIColor.white.CGColor
    //        addSublayer(shapeLayer)
    //
    //        let textLayer = CATextLayer()
    //        //textLayer.position = CGPoint(bounds.midX, bounds.midY)
    //        textLayer.string = "ISO"
    //        textLayer.font = UIFont(name: "HelveticaNeue-CondensedBold", size: 10)
    //        textLayer.fontSize = 10
    //        textLayer.foregroundColor = kCaptureTintColor.CGColor
    //        textLayer.preferredFrameSize()
    //        textLayer.contentsScale = UIScreen.mainScreen().scale
    //        let pSize = textLayer.preferredFrameSize()
    //        let x = (b.width - pSize.width)/2
    //        let y = (b.height - pSize.height)/2
    //        textLayer.frame = CGRect(x, y, pSize.width, pSize.height)
    //        textLayer.alignmentMode = kCAAlignmentCenter
    //        addSublayer(textLayer)
    //    }
    //    final private func _drawExposureDuration() {
    //        let b = bounds
    //        let shapeLayer = CAShapeLayer()
    //        shapeLayer.path = UIBezierPath(ovalInRect: b).CGPath
    //        //shapeLayer.strokeColor = UIColor.white.CGColor
    //        //shapeLayer.fillColor = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1).CGColor
    //        shapeLayer.fillColor = kCaptureTintColor.CGColor
    //        addSublayer(shapeLayer)
    //
    //        let hands = CAShapeLayer()
    //        hands.strokeColor = UIColor.white.CGColor
    //        hands.lineCap = kCALineCapRound
    //        hands.lineJoin = kCALineJoinRound
    //        hands.lineWidth = 1
    //        hands.fillColor = UIColor.clearColor().CGColor
    //        let c = CGPoint(b.midX, b.midY)
    //        let ma:CGFloat = 0
    //        let ha:CGFloat = 3.1415*7/9
    //        let mr:CGFloat = (kSliderKnobRadius-2)
    //        let hr:CGFloat = (kSliderKnobRadius-5)
    //        let mp = CGPoint(c.x+sin(ma)*mr, c.y-cos(ma)*mr)
    //        let hp = CGPoint(c.x+sin(ha)*hr, c.y-cos(ha)*hr)
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
    //        gradientLayer.startPoint = CGPoint(0, 0)
    //        gradientLayer.endPoint = CGPoint(1, 1)
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
    //        gradientLayer.startPoint = CGPoint(0, 0)
    //        gradientLayer.endPoint = CGPoint(1, 1)
    //        gradientLayer.colors = [firstHalfColor, firstHalfColor, secondHalfColor, secondHalfColor]
    //        gradientLayer.locations = [0.0, 0.5, 0.5, 1.0]
    //        let gradientMaskLayer = CAShapeLayer()
    //        gradientMaskLayer.path = UIBezierPath(ovalInRect: b).CGPath
    //        gradientLayer.mask = gradientMaskLayer
    //        addSublayer(gradientLayer)
    //    }



}
