//
//  CaptureExtentions.swift
//  Capture
//
//  Created by Jean on 9/7/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation

// from: https://stackoverflow.com/questions/24092884/get-nth-character-of-a-string-in-swift-programming-language
extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String {
            #if os(iOS)
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
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad6,11", "iPad6,12":                    return "iPad 5"
            case "iPad7,5", "iPad7,6":                      return "iPad 6"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }
    
}

func delay(_ delay:TimeInterval, closure:@escaping ()->()) {
    DispatchQueue.main.asyncAfter(deadline: .now() + delay) { closure() }
}

func progressValue(_ progress:CGFloat, _ start:CGFloat, _ end:CGFloat) -> CGFloat {
    let d = end - start
    return start + d * progress
}

func bound<Value : Comparable> (_ value: Value, _ start: Value, _ end: Value) -> Value {
    if (start < end) {
        return max(start, min(end, value))
    } else if (start > end) {
        return max(end, min(start, value))
    } else {
        // start == end so only one possible bounded value
        return start
    }
}

func progressValue(_ progress:Float, _ start:Float, _ end:Float) -> Float {
    let d = end - start
    return start + d * progress
}

func roundToLog(_ x: Double, _ base: Double, _ coefficient: Double ) -> Double {
    let power = round( log10(x / coefficient) / log10(base) )
    return pow(base, power) * coefficient
}

/// temporarily set a value and perform a function then set back to original value
func tempSetDo<T : Any>( set: inout T, to: T, action: () -> Void){
    let oldValue = set
    set = to
    action()
    set = oldValue
}

func roundExposureDurationStringFast(_ exposureDuration:CMTime) -> String {
    let doubleValue = CMTimeGetSeconds(exposureDuration)
    if ( doubleValue < 1 ) {
        let d = floor(log10(1/doubleValue))
        let p = d > 1 ? d - 1 : 0
        let rDouble = pow(10, p) * round((1/doubleValue) / pow(10, p))
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

extension CGAffineTransform {
    init(rotatingWithAngle angle: CGFloat) {
        let t = CGAffineTransform(rotationAngle: angle)
        self.init(a: t.a, b: t.b, c: t.c, d: t.d, tx: t.tx, ty: t.ty)
        
    }
    init(scaleX sx: CGFloat, scaleY sy: CGFloat) {
        let t = CGAffineTransform(scaleX: sx, y: sy)
        self.init(a: t.a, b: t.b, c: t.c, d: t.d, tx: t.tx, ty: t.ty)
        
    }
    func scale(sx: CGFloat, sy: CGFloat) -> CGAffineTransform {
        return self.scaledBy(x: sx, y: sy)
    }
    func rotate(angle: CGFloat) -> CGAffineTransform {
        return self.rotated(by: angle)
    }
}

extension AVCaptureDevice.Position {
    var transform: CGAffineTransform {
        switch self {
        case .front:
            return CGAffineTransform(rotatingWithAngle: -CGFloat(Double.pi / 2)).scale(sx: 1, sy: -1)
        case .back:
            return CGAffineTransform(rotatingWithAngle: -CGFloat(Double.pi / 2))
        default:
            return CGAffineTransform.identity
            
        }
    }
    
    var device: AVCaptureDevice? {
        return AVCaptureDevice.devices(for: AVMediaType.video).filter {
            $0.position == self
            }.first
    }
}

extension AVCaptureVideoOrientation {
    var uiInterfaceOrientation: UIInterfaceOrientation {
        get {
            switch self {
            case .landscapeLeft:        return .landscapeLeft
            case .landscapeRight:       return .landscapeRight
            case .portrait:             return .portrait
            case .portraitUpsideDown:   return .portraitUpsideDown
            }
        }
    }
    
    init(ui:UIInterfaceOrientation) {
        switch ui {
        case .landscapeRight:       self = .landscapeRight
        case .landscapeLeft:        self = .landscapeLeft
        case .portrait:             self = .portrait
        case .portraitUpsideDown:   self = .portraitUpsideDown
        default:                    self = .portrait
        }
    }
}

import UIKit.UIGestureRecognizerSubclass

class UIShortTapGestureRecognizer: UITapGestureRecognizer {
    var tapMaxDelay: Double = 0.3
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        delay(tapMaxDelay) {
            // Enough time has passed and the gesture was not recognized -> It has failed.
            if  self.state != UIGestureRecognizer.State.ended {
                self.state = UIGestureRecognizer.State.failed
            }
        }
    }
}

extension CATransaction {
    class func disableActions(block: ()->Void ) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        block()
        CATransaction.commit()
    }
    class func performBlock(duration: CFTimeInterval = CATransaction.animationDuration(), _ block: () -> Void) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        block()
        CATransaction.commit()
    }
    class func performBlockWithCompletion(duration: CFTimeInterval = CATransaction.animationDuration(), block: () -> Void, completion: @escaping () -> Void) {
        CATransaction.performBlock(duration: duration) {() -> Void in
            CATransaction.setCompletionBlock(completion)
            block()
        }
    }
}
