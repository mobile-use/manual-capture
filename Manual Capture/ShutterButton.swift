//
//  CaptureShutterButton.swift
//  Capture
//
//  Created by Jean Flaherty on 8/20/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit


let kShutterButtonSize = CGSize(width: 60, height: 60)
let kGalleryButtonSize = CGSize(width: 40, height: 40)
let kUndoButtonSize = CGSize(width: 40, height: 40)
extension UIButton {
    class func shutterButton() -> UIButton {
        func iconImageWithColor(_ color:UIColor, _ bgcolor:UIColor) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(kShutterButtonSize, false, 0)
            
            //// Ring Drawing
            let ringPath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 60, height: 60))
            bgcolor.setFill()
            ringPath.fill()
            
            //// Camera Glyph Drawing
            let cameraGlyphPath = UIBezierPath()
            cameraGlyphPath.move(to: CGPoint(x: 34, y: 31))
            cameraGlyphPath.addCurve(to: CGPoint(x: 30, y: 35), controlPoint1: CGPoint(x: 34, y: 33.21), controlPoint2: CGPoint(x: 32.21, y: 35))
            cameraGlyphPath.addCurve(to: CGPoint(x: 26, y: 31), controlPoint1: CGPoint(x: 27.79, y: 35), controlPoint2: CGPoint(x: 26, y: 33.21))
            cameraGlyphPath.addCurve(to: CGPoint(x: 29.58, y: 27.02), controlPoint1: CGPoint(x: 26, y: 28.93), controlPoint2: CGPoint(x: 27.57, y: 27.23))
            cameraGlyphPath.addCurve(to: CGPoint(x: 30, y: 27), controlPoint1: CGPoint(x: 29.72, y: 27.01), controlPoint2: CGPoint(x: 29.86, y: 27))
            cameraGlyphPath.addCurve(to: CGPoint(x: 34, y: 31), controlPoint1: CGPoint(x: 32.21, y: 27), controlPoint2: CGPoint(x: 34, y: 28.79))
            cameraGlyphPath.close()
            cameraGlyphPath.move(to: CGPoint(x: 30, y: 25))
            cameraGlyphPath.addCurve(to: CGPoint(x: 29.05, y: 25.08), controlPoint1: CGPoint(x: 29.68, y: 25), controlPoint2: CGPoint(x: 29.36, y: 25.03))
            cameraGlyphPath.addCurve(to: CGPoint(x: 28.01, y: 25.34), controlPoint1: CGPoint(x: 28.69, y: 25.13), controlPoint2: CGPoint(x: 28.35, y: 25.22))
            cameraGlyphPath.addCurve(to: CGPoint(x: 24, y: 31), controlPoint1: CGPoint(x: 25.68, y: 26.16), controlPoint2: CGPoint(x: 24, y: 28.38))
            cameraGlyphPath.addCurve(to: CGPoint(x: 30, y: 37), controlPoint1: CGPoint(x: 24, y: 34.31), controlPoint2: CGPoint(x: 26.69, y: 37))
            cameraGlyphPath.addCurve(to: CGPoint(x: 36, y: 31), controlPoint1: CGPoint(x: 33.31, y: 37), controlPoint2: CGPoint(x: 36, y: 34.31))
            cameraGlyphPath.addCurve(to: CGPoint(x: 30, y: 25), controlPoint1: CGPoint(x: 36, y: 27.69), controlPoint2: CGPoint(x: 33.31, y: 25))
            cameraGlyphPath.close()
            cameraGlyphPath.move(to: CGPoint(x: 37.99, y: 19.2))
            cameraGlyphPath.addLine(to: CGPoint(x: 38.11, y: 19.22))
            cameraGlyphPath.addCurve(to: CGPoint(x: 39.78, y: 20.89), controlPoint1: CGPoint(x: 38.88, y: 19.51), controlPoint2: CGPoint(x: 39.49, y: 20.12))
            cameraGlyphPath.addCurve(to: CGPoint(x: 39.97, y: 22), controlPoint1: CGPoint(x: 39.89, y: 21.25), controlPoint2: CGPoint(x: 39.94, y: 21.59))
            cameraGlyphPath.addLine(to: CGPoint(x: 41.41, y: 22))
            cameraGlyphPath.addCurve(to: CGPoint(x: 43.99, y: 22.2), controlPoint1: CGPoint(x: 42.73, y: 22), controlPoint2: CGPoint(x: 43.39, y: 22))
            cameraGlyphPath.addLine(to: CGPoint(x: 44.11, y: 22.22))
            cameraGlyphPath.addCurve(to: CGPoint(x: 45.78, y: 23.89), controlPoint1: CGPoint(x: 44.88, y: 22.51), controlPoint2: CGPoint(x: 45.49, y: 23.12))
            cameraGlyphPath.addCurve(to: CGPoint(x: 46, y: 26.59), controlPoint1: CGPoint(x: 46, y: 24.61), controlPoint2: CGPoint(x: 46, y: 25.27))
            cameraGlyphPath.addLine(to: CGPoint(x: 46, y: 35.41))
            cameraGlyphPath.addCurve(to: CGPoint(x: 45.8, y: 37.99), controlPoint1: CGPoint(x: 46, y: 36.73), controlPoint2: CGPoint(x: 46, y: 37.39))
            cameraGlyphPath.addLine(to: CGPoint(x: 45.78, y: 38.11))
            cameraGlyphPath.addCurve(to: CGPoint(x: 44.11, y: 39.78), controlPoint1: CGPoint(x: 45.49, y: 38.88), controlPoint2: CGPoint(x: 44.88, y: 39.49))
            cameraGlyphPath.addCurve(to: CGPoint(x: 41.41, y: 40), controlPoint1: CGPoint(x: 43.39, y: 40), controlPoint2: CGPoint(x: 42.73, y: 40))
            cameraGlyphPath.addLine(to: CGPoint(x: 18.59, y: 40))
            cameraGlyphPath.addCurve(to: CGPoint(x: 16.01, y: 39.8), controlPoint1: CGPoint(x: 17.27, y: 40), controlPoint2: CGPoint(x: 16.61, y: 40))
            cameraGlyphPath.addLine(to: CGPoint(x: 15.89, y: 39.78))
            cameraGlyphPath.addCurve(to: CGPoint(x: 14.22, y: 38.11), controlPoint1: CGPoint(x: 15.12, y: 39.49), controlPoint2: CGPoint(x: 14.51, y: 38.88))
            cameraGlyphPath.addCurve(to: CGPoint(x: 14, y: 35.41), controlPoint1: CGPoint(x: 14, y: 37.39), controlPoint2: CGPoint(x: 14, y: 36.73))
            cameraGlyphPath.addLine(to: CGPoint(x: 14, y: 26.59))
            cameraGlyphPath.addCurve(to: CGPoint(x: 14.2, y: 24.01), controlPoint1: CGPoint(x: 14, y: 25.27), controlPoint2: CGPoint(x: 14, y: 24.61))
            cameraGlyphPath.addLine(to: CGPoint(x: 14.22, y: 23.89))
            cameraGlyphPath.addCurve(to: CGPoint(x: 15.89, y: 22.22), controlPoint1: CGPoint(x: 14.51, y: 23.12), controlPoint2: CGPoint(x: 15.12, y: 22.51))
            cameraGlyphPath.addCurve(to: CGPoint(x: 18.59, y: 22), controlPoint1: CGPoint(x: 16.61, y: 22), controlPoint2: CGPoint(x: 17.27, y: 22))
            cameraGlyphPath.addLine(to: CGPoint(x: 20.03, y: 22))
            cameraGlyphPath.addCurve(to: CGPoint(x: 20.2, y: 21.01), controlPoint1: CGPoint(x: 20.05, y: 21.61), controlPoint2: CGPoint(x: 20.1, y: 21.3))
            cameraGlyphPath.addLine(to: CGPoint(x: 20.22, y: 20.89))
            cameraGlyphPath.addCurve(to: CGPoint(x: 21.89, y: 19.22), controlPoint1: CGPoint(x: 20.51, y: 20.12), controlPoint2: CGPoint(x: 21.12, y: 19.51))
            cameraGlyphPath.addCurve(to: CGPoint(x: 24.59, y: 19), controlPoint1: CGPoint(x: 22.61, y: 19), controlPoint2: CGPoint(x: 23.27, y: 19))
            cameraGlyphPath.addLine(to: CGPoint(x: 35.41, y: 19))
            cameraGlyphPath.addCurve(to: CGPoint(x: 37.99, y: 19.2), controlPoint1: CGPoint(x: 36.73, y: 19), controlPoint2: CGPoint(x: 37.39, y: 19))
            cameraGlyphPath.close()
            color.setFill()
            cameraGlyphPath.fill()
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
            UIGraphicsEndImageContext()
            return image
        }
        
        func alpha(_ image: UIImage, _ value:CGFloat)->UIImage
        {
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
            
            guard let ctx = UIGraphicsGetCurrentContext() else { fatalError() }
            let area = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            
            ctx.scaleBy(x: 1, y: -1)
            ctx.translateBy(x: 0, y: -area.size.height)
            ctx.setBlendMode(.multiply)
            ctx.setAlpha(value)
            guard let cgImage = image.cgImage else { fatalError() }
            ctx.draw(cgImage, in: area)
            
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
            UIGraphicsEndImageContext()
            return image
        }
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: kShutterButtonSize.width, height:  kShutterButtonSize.height)
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate, appDelegate.isVideoMode {
            let n = kCaptureTintColor, h = UIColor(white: 1, alpha: 0.8), c = UIColor.clear
            button.setBackgroundImage(iconImageWithColor(c, n), for: .normal)
            button.setBackgroundImage(iconImageWithColor(c, h), for: .highlighted)
            button.setBackgroundImage(iconImageWithColor(c, n), for: .disabled)
        } else {
            button.setBackgroundImage(iconImageWithColor(kCaptureTintColor, UIColor.white), for: .normal)
            button.setBackgroundImage(iconImageWithColor(UIColor.white, kCaptureTintColor), for: .highlighted)
            button.setBackgroundImage(alpha(iconImageWithColor(kCaptureTintColor, UIColor.white), 1.0) , for: .disabled)
        }
        
        return button
    }
    
    class func galleryButton() -> UIButton {
        func drawGalleryButton(_ color: UIColor,_ color2: UIColor, frame: CGRect = CGRect(x: 8, y: 8, width: 24, height: 24)) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(kGalleryButtonSize, false, 0)
            
            //// Oval 2 Drawing
            let oval2Path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 40, height: 40))
            color2.setFill()
            oval2Path.fill()
            
            
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath()
            rectanglePath.move(to: CGPoint(x: frame.minX + 0.21287 * frame.width, y: frame.minY + 0.15000 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.78713 * frame.width, y: frame.minY + 0.15000 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.87301 * frame.width, y: frame.minY + 0.15655 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.83115 * frame.width, y: frame.minY + 0.15000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.85316 * frame.width, y: frame.minY + 0.15000 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.87685 * frame.width, y: frame.minY + 0.15749 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.93251 * frame.width, y: frame.minY + 0.21315 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.90272 * frame.width, y: frame.minY + 0.16691 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.92309 * frame.width, y: frame.minY + 0.18728 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.94000 * frame.width, y: frame.minY + 0.30287 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.94000 * frame.width, y: frame.minY + 0.23684 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.94000 * frame.width, y: frame.minY + 0.25885 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.94000 * frame.width, y: frame.minY + 0.71713 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.93345 * frame.width, y: frame.minY + 0.80301 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.94000 * frame.width, y: frame.minY + 0.76115 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.94000 * frame.width, y: frame.minY + 0.78316 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.93251 * frame.width, y: frame.minY + 0.80685 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.87685 * frame.width, y: frame.minY + 0.86251 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.92309 * frame.width, y: frame.minY + 0.83272 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.90272 * frame.width, y: frame.minY + 0.85309 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.78713 * frame.width, y: frame.minY + 0.87000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.85316 * frame.width, y: frame.minY + 0.87000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.83115 * frame.width, y: frame.minY + 0.87000 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.21287 * frame.width, y: frame.minY + 0.87000 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.12699 * frame.width, y: frame.minY + 0.86345 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.16885 * frame.width, y: frame.minY + 0.87000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.14684 * frame.width, y: frame.minY + 0.87000 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.12315 * frame.width, y: frame.minY + 0.86251 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.06749 * frame.width, y: frame.minY + 0.80685 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.09728 * frame.width, y: frame.minY + 0.85309 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.07691 * frame.width, y: frame.minY + 0.83272 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.06000 * frame.width, y: frame.minY + 0.71713 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.06000 * frame.width, y: frame.minY + 0.78316 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.06000 * frame.width, y: frame.minY + 0.76115 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.06000 * frame.width, y: frame.minY + 0.30287 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.06655 * frame.width, y: frame.minY + 0.21699 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.06000 * frame.width, y: frame.minY + 0.25885 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.06000 * frame.width, y: frame.minY + 0.23684 * frame.height))
            rectanglePath.addLine(to: CGPoint(x: frame.minX + 0.06749 * frame.width, y: frame.minY + 0.21315 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.12315 * frame.width, y: frame.minY + 0.15749 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.07691 * frame.width, y: frame.minY + 0.18728 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.09728 * frame.width, y: frame.minY + 0.16691 * frame.height))
            rectanglePath.addCurve(to: CGPoint(x: frame.minX + 0.21287 * frame.width, y: frame.minY + 0.15000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.14684 * frame.width, y: frame.minY + 0.15000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.16885 * frame.width, y: frame.minY + 0.15000 * frame.height))
            rectanglePath.close()
            color.setStroke()
            rectanglePath.lineWidth = 1
            rectanglePath.stroke()
            
            
            //// Oval Drawing
            let ovalPath = UIBezierPath()
            ovalPath.move(to: CGPoint(x: frame.minX + 0.37000 * frame.width, y: frame.minY + 0.33000 * frame.height))
            ovalPath.addCurve(to: CGPoint(x: frame.minX + 0.27000 * frame.width, y: frame.minY + 0.43000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.37000 * frame.width, y: frame.minY + 0.38523 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.32523 * frame.width, y: frame.minY + 0.43000 * frame.height))
            ovalPath.addCurve(to: CGPoint(x: frame.minX + 0.17000 * frame.width, y: frame.minY + 0.33000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.21477 * frame.width, y: frame.minY + 0.43000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.17000 * frame.width, y: frame.minY + 0.38523 * frame.height))
            ovalPath.addCurve(to: CGPoint(x: frame.minX + 0.27000 * frame.width, y: frame.minY + 0.23000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.17000 * frame.width, y: frame.minY + 0.27477 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.21477 * frame.width, y: frame.minY + 0.23000 * frame.height))
            ovalPath.addCurve(to: CGPoint(x: frame.minX + 0.37000 * frame.width, y: frame.minY + 0.33000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.32523 * frame.width, y: frame.minY + 0.23000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.37000 * frame.width, y: frame.minY + 0.27477 * frame.height))
            ovalPath.close()
            color.setStroke()
            ovalPath.lineWidth = 1
            ovalPath.stroke()
            
            
            //// Bezier Drawing
            let bezierPath = UIBezierPath()
            bezierPath.move(to: CGPoint(x: frame.minX + 0.77108 * frame.width, y: frame.minY + 0.53178 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.77483 * frame.width, y: frame.minY + 0.53416 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.77235 * frame.width, y: frame.minY + 0.53253 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.77360 * frame.width, y: frame.minY + 0.53333 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.82187 * frame.width, y: frame.minY + 0.58870 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.79082 * frame.width, y: frame.minY + 0.54597 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.80117 * frame.width, y: frame.minY + 0.56021 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.93983 * frame.width, y: frame.minY + 0.75105 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.82187 * frame.width, y: frame.minY + 0.58870 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.88157 * frame.width, y: frame.minY + 0.67087 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.93345 * frame.width, y: frame.minY + 0.80301 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.93942 * frame.width, y: frame.minY + 0.77404 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.93805 * frame.width, y: frame.minY + 0.78905 * frame.height))
            bezierPath.addLine(to: CGPoint(x: frame.minX + 0.93251 * frame.width, y: frame.minY + 0.80685 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.87685 * frame.width, y: frame.minY + 0.86251 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.92309 * frame.width, y: frame.minY + 0.83272 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.90272 * frame.width, y: frame.minY + 0.85309 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.78713 * frame.width, y: frame.minY + 0.87000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.85316 * frame.width, y: frame.minY + 0.87000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.83115 * frame.width, y: frame.minY + 0.87000 * frame.height))
            bezierPath.addLine(to: CGPoint(x: frame.minX + 0.22664 * frame.width, y: frame.minY + 0.87000 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.50934 * frame.width, y: frame.minY + 0.66460 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.31585 * frame.width, y: frame.minY + 0.80518 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.42437 * frame.width, y: frame.minY + 0.72634 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.63708 * frame.width, y: frame.minY + 0.57179 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.56758 * frame.width, y: frame.minY + 0.62229 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.61476 * frame.width, y: frame.minY + 0.58801 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.65105 * frame.width, y: frame.minY + 0.56165 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.64609 * frame.width, y: frame.minY + 0.56525 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.65105 * frame.width, y: frame.minY + 0.56165 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.70971 * frame.width, y: frame.minY + 0.52550 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.67954 * frame.width, y: frame.minY + 0.54095 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.69378 * frame.width, y: frame.minY + 0.53060 * frame.height))
            bezierPath.addLine(to: CGPoint(x: frame.minX + 0.71264 * frame.width, y: frame.minY + 0.52431 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.77108 * frame.width, y: frame.minY + 0.53178 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.73238 * frame.width, y: frame.minY + 0.51865 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.75351 * frame.width, y: frame.minY + 0.52140 * frame.height))
            bezierPath.close()
            bezierPath.move(to: CGPoint(x: frame.minX + 0.40907 * frame.width, y: frame.minY + 0.56801 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.44050 * frame.width, y: frame.minY + 0.58004 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.42020 * frame.width, y: frame.minY + 0.56956 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.43096 * frame.width, y: frame.minY + 0.57361 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.48753 * frame.width, y: frame.minY + 0.63459 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.45648 * frame.width, y: frame.minY + 0.59185 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.46683 * frame.width, y: frame.minY + 0.60610 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.50934 * frame.width, y: frame.minY + 0.66460 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.48753 * frame.width, y: frame.minY + 0.63459 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.49586 * frame.width, y: frame.minY + 0.64606 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.22664 * frame.width, y: frame.minY + 0.87000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.42437 * frame.width, y: frame.minY + 0.72634 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.31585 * frame.width, y: frame.minY + 0.80518 * frame.height))
            bezierPath.addLine(to: CGPoint(x: frame.minX + 0.21287 * frame.width, y: frame.minY + 0.87000 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.12699 * frame.width, y: frame.minY + 0.86345 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.16885 * frame.width, y: frame.minY + 0.87000 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.14684 * frame.width, y: frame.minY + 0.87000 * frame.height))
            bezierPath.addLine(to: CGPoint(x: frame.minX + 0.12315 * frame.width, y: frame.minY + 0.86251 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.06749 * frame.width, y: frame.minY + 0.80685 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.09728 * frame.width, y: frame.minY + 0.85309 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.07691 * frame.width, y: frame.minY + 0.83272 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.06360 * frame.width, y: frame.minY + 0.79143 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.06587 * frame.width, y: frame.minY + 0.80171 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.06459 * frame.width, y: frame.minY + 0.79665 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.31671 * frame.width, y: frame.minY + 0.60753 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.06402 * frame.width, y: frame.minY + 0.79113 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.31671 * frame.width, y: frame.minY + 0.60753 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.37537 * frame.width, y: frame.minY + 0.57139 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.34520 * frame.width, y: frame.minY + 0.58683 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.35945 * frame.width, y: frame.minY + 0.57648 * frame.height))
            bezierPath.addLine(to: CGPoint(x: frame.minX + 0.37830 * frame.width, y: frame.minY + 0.57019 * frame.height))
            bezierPath.addCurve(to: CGPoint(x: frame.minX + 0.40907 * frame.width, y: frame.minY + 0.56801 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.38841 * frame.width, y: frame.minY + 0.56729 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.39889 * frame.width, y: frame.minY + 0.56660 * frame.height))
            bezierPath.close()
            color.setStroke()
            bezierPath.lineWidth = 1
            bezierPath.stroke()
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else { fatalError() }
            UIGraphicsEndImageContext()
            return image
        }
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: kGalleryButtonSize.width, height:  kGalleryButtonSize.height)
        
        //button.adjustsImageWhenHighlighted = true
        button.setBackgroundImage(drawGalleryButton(
            kCaptureTintColor,
            UIColor.white
            ),
                                  for: []
        )
        button.setBackgroundImage(drawGalleryButton(
            UIColor.white,
            kCaptureTintColor
            ),
                                  for: .highlighted
        )
        button.setBackgroundImage(drawGalleryButton(
            kCaptureTintColor,
            UIColor.white
            ),
                                  for: .disabled
        )
        
        return button
    }

    
    class func undoButton() -> UIButton {
        func drawUndoButton(_ color: UIColor,_ color2: UIColor, frame: CGRect = CGRect(x: 10, y: 10, width: 20, height: 20)) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(kUndoButtonSize, false, 0)
                
            //// Oval 2 Drawing
            let oval2Path = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: kUndoButtonSize.width, height: kUndoButtonSize.height))
            color2.setFill()
            oval2Path.fill()
            
            
            //// undoGlyph Drawing
            let undoGlyphPath = UIBezierPath()
            undoGlyphPath.move(to: CGPoint(x: frame.minX + 0.43649 * frame.width, y: frame.minY + 0.20588 * frame.height))
            undoGlyphPath.addLine(to: CGPoint(x: frame.minX + 0.43649 * frame.width, y: frame.minY + 0.00000 * frame.height))
            undoGlyphPath.addLine(to: CGPoint(x: frame.minX + 0.12500 * frame.width, y: frame.minY + 0.35294 * frame.height))
            undoGlyphPath.addLine(to: CGPoint(x: frame.minX + 0.43649 * frame.width, y: frame.minY + 0.67647 * frame.height))
            undoGlyphPath.addLine(to: CGPoint(x: frame.minX + 0.43692 * frame.width, y: frame.minY + 0.47059 * frame.height))
            undoGlyphPath.addCurve(to: CGPoint(x: frame.minX + 0.60640 * frame.width, y: frame.minY + 1.00000 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.55019 * frame.width, y: frame.minY + 0.47059 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.90249 * frame.width, y: frame.minY + 0.60576 * frame.height))
            undoGlyphPath.addCurve(to: CGPoint(x: frame.minX + 0.83294 * frame.width, y: frame.minY + 0.64706 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.69501 * frame.width, y: frame.minY + 0.93688 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.83294 * frame.width, y: frame.minY + 0.83262 * frame.height))
            undoGlyphPath.addCurve(to: CGPoint(x: frame.minX + 0.43649 * frame.width, y: frame.minY + 0.20588 * frame.height), controlPoint1: CGPoint(x: frame.minX + 0.83294 * frame.width, y: frame.minY + 0.62532 * frame.height), controlPoint2: CGPoint(x: frame.minX + 0.86126 * frame.width, y: frame.minY + 0.20588 * frame.height))
            undoGlyphPath.close()
            color.setFill()
            undoGlyphPath.fill()
            guard let image = UIGraphicsGetImageFromCurrentImageContext() else {
                fatalError("UIGraphicsGetImageFromCurrentImageContext")
            }
            UIGraphicsEndImageContext()
            return image
        }
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: kGalleryButtonSize.width, height: kGalleryButtonSize.height)
        
        button.adjustsImageWhenHighlighted = true
//        button.setBackgroundImage(drawUndoButton(
//            kCaptureTintColor,
//            UIColor.white
//            ),
//            forState: .Normal
//        )
//        button.setBackgroundImage(drawUndoButton(
//            UIColor.white,
//            kCaptureTintColor
//            ),
//            forState: .Highlighted
//        )
//        button.setBackgroundImage(drawUndoButton(
//            kCaptureTintColor,
//            UIColor.white
//            ),
//            forState: .Disabled
//        )

        let a: CGFloat = 0.15
        button.setBackgroundImage(drawUndoButton(
            UIColor.white,//.colorWithAlphaComponent(0.5),
            UIColor(white: 0.08, alpha: a)
            ),
            for: .normal
        )
        button.setBackgroundImage(drawUndoButton(
            UIColor(white: 0.08, alpha: a),
            UIColor(white: 1, alpha: 1)
            ),
            for: .highlighted
        )
        button.setBackgroundImage(drawUndoButton(
            UIColor.white,//.colorWithAlphaComponent(0.5),
            UIColor(white: 0.08, alpha: a)
            ),
            for: .disabled
        )

        
        return button
    }
}

