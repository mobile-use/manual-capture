//
//  CaptureExtentions.swift
//  Capture
//
//  Created by Jean on 9/7/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8 where value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,1", "iPad5,3", "iPad5,4":           return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

func progressValue(progress:CGFloat, _ start:CGFloat, _ end:CGFloat) -> CGFloat {
    let d = end - start
    return start + d * progress
}

func progressValue(progress:Float, _ start:Float, _ end:Float) -> Float {
    let d = end - start
    return start + d * progress
}

func roundToLog(x: Double, _ base: Double, _ coefficient: Double ) -> Double {
    let power = round( log10(x / coefficient) / log10(base) )
    return pow(base, power) * coefficient
}

//func roundExposureDurationString(exposureDuration:CMTime) -> String {
//    let doubleValue = CMTimeGetSeconds(exposureDuration)
//    if ( doubleValue < 1 ) {
//        let s = round(1 / doubleValue)
//        var m:Double
//        switch s {
//        case 1:             return "1.0s"
//        case 2...3: m = 1                       // 2, 3
//        case 4...10: m = 2                      // 4, 8, 12
//        case 11...34: m = 15                    // 15, 30
//        case 35...94: m = 10                   // 40, 50, 60, 70, 80, 90
//        default:
//            let c: Double = (s >= 11.3137085 ) ? ((s >= 84.8528137) ? 125 : 15) : 1
//            let rDouble = roundToLog(s, 2, c)
//            return "1/\(Int(rDouble))s"
//        }
//            let r = round(round(s / m) * m)
//            return "1/\(Int(r))s"
//    }
//    else {
//        return String(format: "%.1fs", doubleValue)
//    }
//}

func roundExposureDurationStringFast(exposureDuration:CMTime) -> String {
    let doubleValue = CMTimeGetSeconds(exposureDuration)
    if ( doubleValue < 1 ) {
        //let digits = max( 0, 2 - floor(log10(doubleValue)))
        let d = floor(log10(1/doubleValue))
        let p = d > 1 ? d - 1 : 0
        let rDouble = pow(10, p) * round((1/doubleValue) / pow(10, p))
        //print("\(p), \(rDouble)")
        return String(format: "1/%.*fs", 0, rDouble)
    }
    else {
        return String(format: "%.2fs", doubleValue)
    }
}

func roundExposureDurationString(exposureDuration:CMTime) -> String {
    let doubleValue = CMTimeGetSeconds(exposureDuration)
    if ( doubleValue < 1 ) {
        let s = 1 / doubleValue
        let c: Double = (s > 10.606601718 ) ? ((s > 88.38834765) ? 125 : 15) : 1
        let rDouble = roundToLog(s, 2, c)
        return "1/\(Int(rDouble))s"
    }
    else {
        return String(format: "%.2fs", doubleValue)
    }
}

//func roundExposureDuration(exposureDuration:CMTime) -> CMTime {
//    let doubleValue = CMTimeGetSeconds(exposureDuration)
//    if ( doubleValue < 1 ) {
//        let s = 1 / doubleValue
//        let c: Double = (s >= 11 ) ? ((s >= 84) ? 125 : 15) : 1
//        let rDouble = 1 / roundToLog(s, 2, c)
//        return CMTime(seconds: rDouble, preferredTimescale: 1000*1000*1000)
//    }
//    else {
//        return CMTime(seconds: round(doubleValue * 10) / 10 , preferredTimescale: 1000*1000*1000)
//    }
//}

extension CGAffineTransform {
    
    init(rotatingWithAngle angle: CGFloat) {
        let t = CGAffineTransformMakeRotation(angle)
        self.init(a: t.a, b: t.b, c: t.c, d: t.d, tx: t.tx, ty: t.ty)
        
    }
    init(scaleX sx: CGFloat, scaleY sy: CGFloat) {
        let t = CGAffineTransformMakeScale(sx, sy)
        self.init(a: t.a, b: t.b, c: t.c, d: t.d, tx: t.tx, ty: t.ty)
        
    }
    
    func scale(sx: CGFloat, sy: CGFloat) -> CGAffineTransform {
        return CGAffineTransformScale(self, sx, sy)
    }
    func rotate(angle: CGFloat) -> CGAffineTransform {
        return CGAffineTransformRotate(self, angle)
    }
}

extension AVCaptureDevicePosition {
    var transform: CGAffineTransform {
        switch self {
        case .Front:
            return CGAffineTransform(rotatingWithAngle: -CGFloat(M_PI_2)).scale(1, sy: -1)
        case .Back:
            return CGAffineTransform(rotatingWithAngle: -CGFloat(M_PI_2))
        default:
            return CGAffineTransformIdentity
            
        }
    }
    
    var device: AVCaptureDevice? {
        return AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo).filter {
            $0.position == self
            }.first as? AVCaptureDevice
    }
}

extension AVCaptureVideoOrientation {
    var uiInterfaceOrientation: UIInterfaceOrientation {
        get {
            switch self {
            case .LandscapeLeft:        return .LandscapeLeft
            case .LandscapeRight:       return .LandscapeRight
            case .Portrait:             return .Portrait
            case .PortraitUpsideDown:   return .PortraitUpsideDown
            }
        }
    }
    
    init(ui:UIInterfaceOrientation) {
        switch ui {
        case .LandscapeRight:       self = .LandscapeRight
        case .LandscapeLeft:        self = .LandscapeLeft
        case .Portrait:             self = .Portrait
        case .PortraitUpsideDown:   self = .PortraitUpsideDown
        default:                    self = .Portrait
        }
    }
}

import UIKit.UIGestureRecognizerSubclass

class UIShortTapGestureRecognizer: UITapGestureRecognizer {
    var tapMaxDelay: Double = 0.3
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesBegan(touches, withEvent: event)
        delay(tapMaxDelay) {
            // Enough time has passed and the gesture was not recognized -> It has failed.
            if  self.state != UIGestureRecognizerState.Ended {
                self.state = UIGestureRecognizerState.Failed
            }
        }
    }
    
    func delay(delay:Double, closure:()->()) {
        dispatch_after(dispatch_time( DISPATCH_TIME_NOW, Int64(delay * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), closure)
    }
}

extension CATransaction {
    class func disableActions(block: ()->Void ) {
        CATransaction.begin()
        CATransaction.disableActions()
        block()
        CATransaction.commit()
    }
    class func performBlock(block: () -> Void) {
        CATransaction.begin()
        block()
        CATransaction.commit()
    }
    class func performBlockWithCompletion(block: () -> Void, completion: () -> Void) {
        CATransaction.performBlock() {() -> Void in
            CATransaction.setCompletionBlock(completion)
            block()
        }
    }
}