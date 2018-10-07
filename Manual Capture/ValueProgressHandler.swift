//
//  VPHandler.swift
//  Capture
//
//  Created by Jean on 9/10/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

/// Value Progress Handler
class ValueProgressHandler<V> {
    var progressForValue:(V) -> Float
    var valueForProgress:(Float) -> V
    init(pfv:@escaping (V)->Float, vfp:@escaping (Float)->V){
        progressForValue = pfv
        valueForProgress = vfp
    }
}

class VPFloatHandler : ValueProgressHandler<Float> {
    var start: Float {didSet{updateConversion(start, end)}}
    var end: Float {didSet{updateConversion(start, end)}}
    
    func updateConversion(_ start:Float, _ end:Float){
        progressForValue = {($0 - start)/(end - start)}
        valueForProgress = {start + $0 * (end - start)}
    }
    
    init(start:Float, end:Float) {
        self.start = start
        self.end = end
        let pfv = {($0 - start)/(end - start)}
        let vfp = {start + ($0 * (end - start))}
        super.init(pfv: pfv, vfp: vfp)
    }
}

class VPExponentialCGFloatHandler : ValueProgressHandler<CGFloat> {
    var start: CGFloat {didSet{updateConversion(start, end)}}
    var end: CGFloat {didSet{updateConversion(start, end)}}
    var power: CGFloat {didSet{updateConversion(start, end)}}
    
    private func updateConversion(_ start:CGFloat, _ end:CGFloat){
        let power = self.power
        progressForValue = { (start != end) ? Float(pow( (bound($0, start, end) - start)/(end - start), 1 / power)) : 0 }
        valueForProgress = { start + (pow( CGFloat($0), power) * (end - start)) }
    }
    
    init(start: CGFloat, end: CGFloat, power: CGFloat = 2) {
        self.start = start
        self.end = end
        self.power = power
        let pfv: (CGFloat) -> Float = { (start != end) ? Float(pow( (bound($0, start, end) - start)/(end - start), 1 / power)) : 0 }
        let vfp: (Float) -> CGFloat = { start + (pow( CGFloat($0), power) * (end - start)) }
        super.init(pfv: pfv, vfp: vfp)
    }
}
