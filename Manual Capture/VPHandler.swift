//
//  VPHandler.swift
//  Capture
//
//  Created by Jean on 9/10/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

/// Value Progress Handler
class VPHandler<V> {
    var progressForValue:(V) -> Float
    var valueForProgress:(Float) -> V
    init(pfv:@escaping (V)->Float, vfp:@escaping (Float)->V){
        progressForValue = pfv
        valueForProgress = vfp
    }
}

class VPFloatHandler : VPHandler<Float> {
    var start: Float {didSet{updateConversion(start, end)}}
    var end: Float {didSet{updateConversion(start, end)}}
    
    func updateConversion(_ start:Float, _ end:Float){
        progressForValue = {($0 - start)/(end - start)}
        valueForProgress = {(start + $0) * (end - start)}
    }
    
    init(start:Float, end:Float) {
        self.start = start
        self.end = end
        let pfv = {($0 - start)/(end - start)}
        let vfp = {start + ($0 * (end - start))}
        super.init(pfv: pfv, vfp: vfp)
    }
}

class VPExponentialCGFloatHandler : VPHandler<CGFloat> {
    var start: CGFloat {didSet{updateConversion(start, end)}}
    var end: CGFloat {didSet{updateConversion(start, end)}}
    let power: CGFloat //didSet{updateConversion(start, end)}}
    
    private func updateConversion(_ start:CGFloat, _ end:CGFloat){
        let p = power
//        {
//            if (start != end) {
//                let bounded = max(start, min(end, $0))
//                let normed = (bounded - start)/(end - start)
//                let rooted = pow(normed, 1 / p)
//                print()
//                return Float(rooted)
//            } else {
//                return 0
//            } }
        progressForValue = { (start != end) ? Float(pow( (max(start, min(end, $0)) - start)/(end - start), 1 / p)) : 0 }
        valueForProgress = { start + (pow( CGFloat($0), p ) * (end - start)) }
    }
    
    init(start: CGFloat, end: CGFloat, power: CGFloat = 2) {
        self.start = start
        self.end = end
        self.power = power
        let pfv = { Float(pow( (max(start, min(end, $0)) - start)/(end - start), 1 / power)) }
        let vfp = { (p:Float) in  start + (pow( CGFloat(p), power ) * (end - start)) }
        super.init(pfv: pfv, vfp: vfp)
    }
}
