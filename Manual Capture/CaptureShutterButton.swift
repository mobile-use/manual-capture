//
//  CaptureShutterButton.swift
//  Capture
//
//  Created by Jean Flaherty on 8/20/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit


let kCaptureShutterButtonSize = CGSizeMake(60, 60)
let kCaptureGalleryButtonSize = CGSizeMake(40, 40)
let kCaptureUndoButtonSize = CGSizeMake(40, 40)
extension UIButton {
    class func shutterButton() -> UIButton {
        func iconImageWithColor(color:UIColor, _ bgcolor:UIColor) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(kCaptureShutterButtonSize, false, 0)
            
            //// Ring Drawing
            let ringPath = UIBezierPath(ovalInRect: CGRectMake(0, 0, 60, 60))
            bgcolor.setFill()
            ringPath.fill()
            
            //// Camera Glyph Drawing
            let cameraGlyphPath = UIBezierPath()
            cameraGlyphPath.moveToPoint(CGPointMake(34, 31))
            cameraGlyphPath.addCurveToPoint(CGPointMake(30, 35), controlPoint1: CGPointMake(34, 33.21), controlPoint2: CGPointMake(32.21, 35))
            cameraGlyphPath.addCurveToPoint(CGPointMake(26, 31), controlPoint1: CGPointMake(27.79, 35), controlPoint2: CGPointMake(26, 33.21))
            cameraGlyphPath.addCurveToPoint(CGPointMake(29.58, 27.02), controlPoint1: CGPointMake(26, 28.93), controlPoint2: CGPointMake(27.57, 27.23))
            cameraGlyphPath.addCurveToPoint(CGPointMake(30, 27), controlPoint1: CGPointMake(29.72, 27.01), controlPoint2: CGPointMake(29.86, 27))
            cameraGlyphPath.addCurveToPoint(CGPointMake(34, 31), controlPoint1: CGPointMake(32.21, 27), controlPoint2: CGPointMake(34, 28.79))
            cameraGlyphPath.closePath()
            cameraGlyphPath.moveToPoint(CGPointMake(30, 25))
            cameraGlyphPath.addCurveToPoint(CGPointMake(29.05, 25.08), controlPoint1: CGPointMake(29.68, 25), controlPoint2: CGPointMake(29.36, 25.03))
            cameraGlyphPath.addCurveToPoint(CGPointMake(28.01, 25.34), controlPoint1: CGPointMake(28.69, 25.13), controlPoint2: CGPointMake(28.35, 25.22))
            cameraGlyphPath.addCurveToPoint(CGPointMake(24, 31), controlPoint1: CGPointMake(25.68, 26.16), controlPoint2: CGPointMake(24, 28.38))
            cameraGlyphPath.addCurveToPoint(CGPointMake(30, 37), controlPoint1: CGPointMake(24, 34.31), controlPoint2: CGPointMake(26.69, 37))
            cameraGlyphPath.addCurveToPoint(CGPointMake(36, 31), controlPoint1: CGPointMake(33.31, 37), controlPoint2: CGPointMake(36, 34.31))
            cameraGlyphPath.addCurveToPoint(CGPointMake(30, 25), controlPoint1: CGPointMake(36, 27.69), controlPoint2: CGPointMake(33.31, 25))
            cameraGlyphPath.closePath()
            cameraGlyphPath.moveToPoint(CGPointMake(37.99, 19.2))
            cameraGlyphPath.addLineToPoint(CGPointMake(38.11, 19.22))
            cameraGlyphPath.addCurveToPoint(CGPointMake(39.78, 20.89), controlPoint1: CGPointMake(38.88, 19.51), controlPoint2: CGPointMake(39.49, 20.12))
            cameraGlyphPath.addCurveToPoint(CGPointMake(39.97, 22), controlPoint1: CGPointMake(39.89, 21.25), controlPoint2: CGPointMake(39.94, 21.59))
            cameraGlyphPath.addLineToPoint(CGPointMake(41.41, 22))
            cameraGlyphPath.addCurveToPoint(CGPointMake(43.99, 22.2), controlPoint1: CGPointMake(42.73, 22), controlPoint2: CGPointMake(43.39, 22))
            cameraGlyphPath.addLineToPoint(CGPointMake(44.11, 22.22))
            cameraGlyphPath.addCurveToPoint(CGPointMake(45.78, 23.89), controlPoint1: CGPointMake(44.88, 22.51), controlPoint2: CGPointMake(45.49, 23.12))
            cameraGlyphPath.addCurveToPoint(CGPointMake(46, 26.59), controlPoint1: CGPointMake(46, 24.61), controlPoint2: CGPointMake(46, 25.27))
            cameraGlyphPath.addLineToPoint(CGPointMake(46, 35.41))
            cameraGlyphPath.addCurveToPoint(CGPointMake(45.8, 37.99), controlPoint1: CGPointMake(46, 36.73), controlPoint2: CGPointMake(46, 37.39))
            cameraGlyphPath.addLineToPoint(CGPointMake(45.78, 38.11))
            cameraGlyphPath.addCurveToPoint(CGPointMake(44.11, 39.78), controlPoint1: CGPointMake(45.49, 38.88), controlPoint2: CGPointMake(44.88, 39.49))
            cameraGlyphPath.addCurveToPoint(CGPointMake(41.41, 40), controlPoint1: CGPointMake(43.39, 40), controlPoint2: CGPointMake(42.73, 40))
            cameraGlyphPath.addLineToPoint(CGPointMake(18.59, 40))
            cameraGlyphPath.addCurveToPoint(CGPointMake(16.01, 39.8), controlPoint1: CGPointMake(17.27, 40), controlPoint2: CGPointMake(16.61, 40))
            cameraGlyphPath.addLineToPoint(CGPointMake(15.89, 39.78))
            cameraGlyphPath.addCurveToPoint(CGPointMake(14.22, 38.11), controlPoint1: CGPointMake(15.12, 39.49), controlPoint2: CGPointMake(14.51, 38.88))
            cameraGlyphPath.addCurveToPoint(CGPointMake(14, 35.41), controlPoint1: CGPointMake(14, 37.39), controlPoint2: CGPointMake(14, 36.73))
            cameraGlyphPath.addLineToPoint(CGPointMake(14, 26.59))
            cameraGlyphPath.addCurveToPoint(CGPointMake(14.2, 24.01), controlPoint1: CGPointMake(14, 25.27), controlPoint2: CGPointMake(14, 24.61))
            cameraGlyphPath.addLineToPoint(CGPointMake(14.22, 23.89))
            cameraGlyphPath.addCurveToPoint(CGPointMake(15.89, 22.22), controlPoint1: CGPointMake(14.51, 23.12), controlPoint2: CGPointMake(15.12, 22.51))
            cameraGlyphPath.addCurveToPoint(CGPointMake(18.59, 22), controlPoint1: CGPointMake(16.61, 22), controlPoint2: CGPointMake(17.27, 22))
            cameraGlyphPath.addLineToPoint(CGPointMake(20.03, 22))
            cameraGlyphPath.addCurveToPoint(CGPointMake(20.2, 21.01), controlPoint1: CGPointMake(20.05, 21.61), controlPoint2: CGPointMake(20.1, 21.3))
            cameraGlyphPath.addLineToPoint(CGPointMake(20.22, 20.89))
            cameraGlyphPath.addCurveToPoint(CGPointMake(21.89, 19.22), controlPoint1: CGPointMake(20.51, 20.12), controlPoint2: CGPointMake(21.12, 19.51))
            cameraGlyphPath.addCurveToPoint(CGPointMake(24.59, 19), controlPoint1: CGPointMake(22.61, 19), controlPoint2: CGPointMake(23.27, 19))
            cameraGlyphPath.addLineToPoint(CGPointMake(35.41, 19))
            cameraGlyphPath.addCurveToPoint(CGPointMake(37.99, 19.2), controlPoint1: CGPointMake(36.73, 19), controlPoint2: CGPointMake(37.39, 19))
            cameraGlyphPath.closePath()
            color.setFill()
            cameraGlyphPath.fill()
            
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        
        func alpha(image: UIImage, _ value:CGFloat)->UIImage
        {
            UIGraphicsBeginImageContextWithOptions(image.size, false, 0.0)
            
            let ctx = UIGraphicsGetCurrentContext()
            let area = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            
            CGContextScaleCTM(ctx, 1, -1)
            CGContextTranslateCTM(ctx, 0, -area.size.height)
            CGContextSetBlendMode(ctx, CGBlendMode.Multiply)
            CGContextSetAlpha(ctx, value)
            CGContextDrawImage(ctx, area, image.CGImage);
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return newImage;
        }
        
        let button = UIButton(type: UIButtonType.Custom)
        button.frame = CGRectMake(0, 0, kCaptureShutterButtonSize.width, kCaptureShutterButtonSize.height)

        //button.adjustsImageWhenHighlighted = true
        if kIsVideoMode {
            let n = kCaptureTintColor, h = UIColor(white: 1, alpha: 0.8), c = UIColor.clearColor()
            button.setBackgroundImage(iconImageWithColor(c, n), forState: .Normal)
            button.setBackgroundImage(iconImageWithColor(c, h), forState: .Highlighted)
            button.setBackgroundImage(iconImageWithColor(c, n), forState: .Disabled)
//            let a: CGFloat = 0.15
//            button.setBackgroundImage(iconImageWithColor(
//                UIColor.whiteColor(),//.colorWithAlphaComponent(0.5),
//                UIColor(white: 0.08, alpha: a)
//                ),
//                forState: .Normal
//            )
//            button.setBackgroundImage(iconImageWithColor(
//                UIColor(white: 0.08, alpha: a),
//                UIColor(white: 1, alpha: 1)
//                ),
//                forState: .Highlighted
//            )
//            button.setBackgroundImage(iconImageWithColor(
//                UIColor.whiteColor(),//.colorWithAlphaComponent(0.5),
//                UIColor(white: 0.08, alpha: a)
//                ),
//                forState: .Disabled
//            )
        }else {
            button.setBackgroundImage(iconImageWithColor(kCaptureTintColor, UIColor.whiteColor()), forState: .Normal)
            button.setBackgroundImage(iconImageWithColor(UIColor.whiteColor(), kCaptureTintColor), forState: .Highlighted)
            button.setBackgroundImage(alpha(iconImageWithColor(kCaptureTintColor, UIColor.whiteColor()), 1.0), forState: .Disabled)
        }
        
        return button
    }
    
    class func galleryButton() -> UIButton {
        func drawGalleryButton(color: UIColor,_ color2: UIColor, frame: CGRect = CGRectMake(8, 8, 24, 24)) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(kCaptureGalleryButtonSize, false, 0)
            
            //// Oval 2 Drawing
            let oval2Path = UIBezierPath(ovalInRect: CGRectMake(0, 0, 40, 40))
            color2.setFill()
            oval2Path.fill()
            
            
            //// Rectangle Drawing
            let rectanglePath = UIBezierPath()
            rectanglePath.moveToPoint(CGPointMake(frame.minX + 0.21287 * frame.width, frame.minY + 0.15000 * frame.height))
            rectanglePath.addLineToPoint(CGPointMake(frame.minX + 0.78713 * frame.width, frame.minY + 0.15000 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.87301 * frame.width, frame.minY + 0.15655 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.83115 * frame.width, frame.minY + 0.15000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.85316 * frame.width, frame.minY + 0.15000 * frame.height))
            rectanglePath.addLineToPoint(CGPointMake(frame.minX + 0.87685 * frame.width, frame.minY + 0.15749 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.93251 * frame.width, frame.minY + 0.21315 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.90272 * frame.width, frame.minY + 0.16691 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.92309 * frame.width, frame.minY + 0.18728 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.94000 * frame.width, frame.minY + 0.30287 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.94000 * frame.width, frame.minY + 0.23684 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.94000 * frame.width, frame.minY + 0.25885 * frame.height))
            rectanglePath.addLineToPoint(CGPointMake(frame.minX + 0.94000 * frame.width, frame.minY + 0.71713 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.93345 * frame.width, frame.minY + 0.80301 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.94000 * frame.width, frame.minY + 0.76115 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.94000 * frame.width, frame.minY + 0.78316 * frame.height))
            rectanglePath.addLineToPoint(CGPointMake(frame.minX + 0.93251 * frame.width, frame.minY + 0.80685 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.87685 * frame.width, frame.minY + 0.86251 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.92309 * frame.width, frame.minY + 0.83272 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.90272 * frame.width, frame.minY + 0.85309 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.78713 * frame.width, frame.minY + 0.87000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.85316 * frame.width, frame.minY + 0.87000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.83115 * frame.width, frame.minY + 0.87000 * frame.height))
            rectanglePath.addLineToPoint(CGPointMake(frame.minX + 0.21287 * frame.width, frame.minY + 0.87000 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.12699 * frame.width, frame.minY + 0.86345 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.16885 * frame.width, frame.minY + 0.87000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.14684 * frame.width, frame.minY + 0.87000 * frame.height))
            rectanglePath.addLineToPoint(CGPointMake(frame.minX + 0.12315 * frame.width, frame.minY + 0.86251 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.06749 * frame.width, frame.minY + 0.80685 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.09728 * frame.width, frame.minY + 0.85309 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.07691 * frame.width, frame.minY + 0.83272 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.06000 * frame.width, frame.minY + 0.71713 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.06000 * frame.width, frame.minY + 0.78316 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.06000 * frame.width, frame.minY + 0.76115 * frame.height))
            rectanglePath.addLineToPoint(CGPointMake(frame.minX + 0.06000 * frame.width, frame.minY + 0.30287 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.06655 * frame.width, frame.minY + 0.21699 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.06000 * frame.width, frame.minY + 0.25885 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.06000 * frame.width, frame.minY + 0.23684 * frame.height))
            rectanglePath.addLineToPoint(CGPointMake(frame.minX + 0.06749 * frame.width, frame.minY + 0.21315 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.12315 * frame.width, frame.minY + 0.15749 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.07691 * frame.width, frame.minY + 0.18728 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.09728 * frame.width, frame.minY + 0.16691 * frame.height))
            rectanglePath.addCurveToPoint(CGPointMake(frame.minX + 0.21287 * frame.width, frame.minY + 0.15000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.14684 * frame.width, frame.minY + 0.15000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.16885 * frame.width, frame.minY + 0.15000 * frame.height))
            rectanglePath.closePath()
            color.setStroke()
            rectanglePath.lineWidth = 1
            rectanglePath.stroke()
            
            
            //// Oval Drawing
            let ovalPath = UIBezierPath()
            ovalPath.moveToPoint(CGPointMake(frame.minX + 0.37000 * frame.width, frame.minY + 0.33000 * frame.height))
            ovalPath.addCurveToPoint(CGPointMake(frame.minX + 0.27000 * frame.width, frame.minY + 0.43000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.37000 * frame.width, frame.minY + 0.38523 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.32523 * frame.width, frame.minY + 0.43000 * frame.height))
            ovalPath.addCurveToPoint(CGPointMake(frame.minX + 0.17000 * frame.width, frame.minY + 0.33000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.21477 * frame.width, frame.minY + 0.43000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.17000 * frame.width, frame.minY + 0.38523 * frame.height))
            ovalPath.addCurveToPoint(CGPointMake(frame.minX + 0.27000 * frame.width, frame.minY + 0.23000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.17000 * frame.width, frame.minY + 0.27477 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.21477 * frame.width, frame.minY + 0.23000 * frame.height))
            ovalPath.addCurveToPoint(CGPointMake(frame.minX + 0.37000 * frame.width, frame.minY + 0.33000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.32523 * frame.width, frame.minY + 0.23000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.37000 * frame.width, frame.minY + 0.27477 * frame.height))
            ovalPath.closePath()
            color.setStroke()
            ovalPath.lineWidth = 1
            ovalPath.stroke()
            
            
            //// Bezier Drawing
            let bezierPath = UIBezierPath()
            bezierPath.moveToPoint(CGPointMake(frame.minX + 0.77108 * frame.width, frame.minY + 0.53178 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.77483 * frame.width, frame.minY + 0.53416 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.77235 * frame.width, frame.minY + 0.53253 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.77360 * frame.width, frame.minY + 0.53333 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.82187 * frame.width, frame.minY + 0.58870 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.79082 * frame.width, frame.minY + 0.54597 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.80117 * frame.width, frame.minY + 0.56021 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.93983 * frame.width, frame.minY + 0.75105 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.82187 * frame.width, frame.minY + 0.58870 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.88157 * frame.width, frame.minY + 0.67087 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.93345 * frame.width, frame.minY + 0.80301 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.93942 * frame.width, frame.minY + 0.77404 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.93805 * frame.width, frame.minY + 0.78905 * frame.height))
            bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.93251 * frame.width, frame.minY + 0.80685 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.87685 * frame.width, frame.minY + 0.86251 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.92309 * frame.width, frame.minY + 0.83272 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.90272 * frame.width, frame.minY + 0.85309 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.78713 * frame.width, frame.minY + 0.87000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.85316 * frame.width, frame.minY + 0.87000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.83115 * frame.width, frame.minY + 0.87000 * frame.height))
            bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.22664 * frame.width, frame.minY + 0.87000 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.50934 * frame.width, frame.minY + 0.66460 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.31585 * frame.width, frame.minY + 0.80518 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.42437 * frame.width, frame.minY + 0.72634 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.63708 * frame.width, frame.minY + 0.57179 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.56758 * frame.width, frame.minY + 0.62229 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.61476 * frame.width, frame.minY + 0.58801 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.65105 * frame.width, frame.minY + 0.56165 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.64609 * frame.width, frame.minY + 0.56525 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.65105 * frame.width, frame.minY + 0.56165 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.70971 * frame.width, frame.minY + 0.52550 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.67954 * frame.width, frame.minY + 0.54095 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.69378 * frame.width, frame.minY + 0.53060 * frame.height))
            bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.71264 * frame.width, frame.minY + 0.52431 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.77108 * frame.width, frame.minY + 0.53178 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.73238 * frame.width, frame.minY + 0.51865 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.75351 * frame.width, frame.minY + 0.52140 * frame.height))
            bezierPath.closePath()
            bezierPath.moveToPoint(CGPointMake(frame.minX + 0.40907 * frame.width, frame.minY + 0.56801 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.44050 * frame.width, frame.minY + 0.58004 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.42020 * frame.width, frame.minY + 0.56956 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.43096 * frame.width, frame.minY + 0.57361 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.48753 * frame.width, frame.minY + 0.63459 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.45648 * frame.width, frame.minY + 0.59185 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.46683 * frame.width, frame.minY + 0.60610 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.50934 * frame.width, frame.minY + 0.66460 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.48753 * frame.width, frame.minY + 0.63459 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.49586 * frame.width, frame.minY + 0.64606 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.22664 * frame.width, frame.minY + 0.87000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.42437 * frame.width, frame.minY + 0.72634 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.31585 * frame.width, frame.minY + 0.80518 * frame.height))
            bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.21287 * frame.width, frame.minY + 0.87000 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.12699 * frame.width, frame.minY + 0.86345 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.16885 * frame.width, frame.minY + 0.87000 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.14684 * frame.width, frame.minY + 0.87000 * frame.height))
            bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.12315 * frame.width, frame.minY + 0.86251 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.06749 * frame.width, frame.minY + 0.80685 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.09728 * frame.width, frame.minY + 0.85309 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.07691 * frame.width, frame.minY + 0.83272 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.06360 * frame.width, frame.minY + 0.79143 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.06587 * frame.width, frame.minY + 0.80171 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.06459 * frame.width, frame.minY + 0.79665 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.31671 * frame.width, frame.minY + 0.60753 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.06402 * frame.width, frame.minY + 0.79113 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.31671 * frame.width, frame.minY + 0.60753 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.37537 * frame.width, frame.minY + 0.57139 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.34520 * frame.width, frame.minY + 0.58683 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.35945 * frame.width, frame.minY + 0.57648 * frame.height))
            bezierPath.addLineToPoint(CGPointMake(frame.minX + 0.37830 * frame.width, frame.minY + 0.57019 * frame.height))
            bezierPath.addCurveToPoint(CGPointMake(frame.minX + 0.40907 * frame.width, frame.minY + 0.56801 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.38841 * frame.width, frame.minY + 0.56729 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.39889 * frame.width, frame.minY + 0.56660 * frame.height))
            bezierPath.closePath()
            color.setStroke()
            bezierPath.lineWidth = 1
            bezierPath.stroke()
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        let button = UIButton(type: UIButtonType.Custom)
        button.frame = CGRectMake(0, 0, kCaptureGalleryButtonSize.width, kCaptureGalleryButtonSize.height)
        
        //button.adjustsImageWhenHighlighted = true
        button.setBackgroundImage(drawGalleryButton(
            kCaptureTintColor,
            UIColor.whiteColor()
            ),
            forState: .Normal
        )
        button.setBackgroundImage(drawGalleryButton(
            UIColor.whiteColor(),
            kCaptureTintColor
            ),
            forState: .Highlighted
        )
        button.setBackgroundImage(drawGalleryButton(
            kCaptureTintColor,
            UIColor.whiteColor()
            ),
            forState: .Disabled
        )
        
        return button
    }

    
    class func undoButton() -> UIButton {
        func drawUndoButton(color: UIColor,_ color2: UIColor, frame: CGRect = CGRectMake(10, 10, 20, 20)) -> UIImage {
            UIGraphicsBeginImageContextWithOptions(kCaptureUndoButtonSize, false, 0)
                
            //// Oval 2 Drawing
            let oval2Path = UIBezierPath(ovalInRect: CGRectMake(0, 0, kCaptureUndoButtonSize.width, kCaptureUndoButtonSize.height))
            color2.setFill()
            oval2Path.fill()
            
            
            //// undoGlyph Drawing
            let undoGlyphPath = UIBezierPath()
            undoGlyphPath.moveToPoint(CGPointMake(frame.minX + 0.43649 * frame.width, frame.minY + 0.20588 * frame.height))
            undoGlyphPath.addLineToPoint(CGPointMake(frame.minX + 0.43649 * frame.width, frame.minY + 0.00000 * frame.height))
            undoGlyphPath.addLineToPoint(CGPointMake(frame.minX + 0.12500 * frame.width, frame.minY + 0.35294 * frame.height))
            undoGlyphPath.addLineToPoint(CGPointMake(frame.minX + 0.43649 * frame.width, frame.minY + 0.67647 * frame.height))
            undoGlyphPath.addLineToPoint(CGPointMake(frame.minX + 0.43692 * frame.width, frame.minY + 0.47059 * frame.height))
            undoGlyphPath.addCurveToPoint(CGPointMake(frame.minX + 0.60640 * frame.width, frame.minY + 1.00000 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.55019 * frame.width, frame.minY + 0.47059 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.90249 * frame.width, frame.minY + 0.60576 * frame.height))
            undoGlyphPath.addCurveToPoint(CGPointMake(frame.minX + 0.83294 * frame.width, frame.minY + 0.64706 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.69501 * frame.width, frame.minY + 0.93688 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.83294 * frame.width, frame.minY + 0.83262 * frame.height))
            undoGlyphPath.addCurveToPoint(CGPointMake(frame.minX + 0.43649 * frame.width, frame.minY + 0.20588 * frame.height), controlPoint1: CGPointMake(frame.minX + 0.83294 * frame.width, frame.minY + 0.62532 * frame.height), controlPoint2: CGPointMake(frame.minX + 0.86126 * frame.width, frame.minY + 0.20588 * frame.height))
            undoGlyphPath.closePath()
            color.setFill()
            undoGlyphPath.fill()
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return image
        }
        let button = UIButton(type: UIButtonType.Custom)
        button.frame = CGRectMake(0, 0, kCaptureGalleryButtonSize.width, kCaptureGalleryButtonSize.height)
        
        button.adjustsImageWhenHighlighted = true
//        button.setBackgroundImage(drawUndoButton(
//            kCaptureTintColor,
//            UIColor.whiteColor()
//            ),
//            forState: .Normal
//        )
//        button.setBackgroundImage(drawUndoButton(
//            UIColor.whiteColor(),
//            kCaptureTintColor
//            ),
//            forState: .Highlighted
//        )
//        button.setBackgroundImage(drawUndoButton(
//            kCaptureTintColor,
//            UIColor.whiteColor()
//            ),
//            forState: .Disabled
//        )

        let a: CGFloat = 0.15
        button.setBackgroundImage(drawUndoButton(
            UIColor.whiteColor(),//.colorWithAlphaComponent(0.5),
            UIColor(white: 0.08, alpha: a)
            ),
            forState: .Normal
        )
        button.setBackgroundImage(drawUndoButton(
            UIColor(white: 0.08, alpha: a),
            UIColor(white: 1, alpha: 1)
            ),
            forState: .Highlighted
        )
        button.setBackgroundImage(drawUndoButton(
            UIColor.whiteColor(),//.colorWithAlphaComponent(0.5),
            UIColor(white: 0.08, alpha: a)
            ),
            forState: .Disabled
        )

        
        return button
    }
}

