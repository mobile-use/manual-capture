//
//  CaptureShutterButton.swift
//  Capture
//
//  Created by Jean Flaherty on 8/20/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit


let kCaptureShutterButtonSize = CGSizeMake(60, 60)
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
        button.setBackgroundImage(iconImageWithColor(kCaptureTintColor, UIColor.whiteColor()), forState: .Normal)
        button.setBackgroundImage(iconImageWithColor(UIColor.whiteColor(), kCaptureTintColor), forState: .Highlighted)
        button.setBackgroundImage(alpha(iconImageWithColor(kCaptureTintColor, UIColor.whiteColor()), 1.0), forState: .Disabled)
        
        return button
    }

}
