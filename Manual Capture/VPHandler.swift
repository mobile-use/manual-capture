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
    init(pfv:(V)->Float, vfp:(Float)->V){
        progressForValue = pfv
        valueForProgress = vfp
    }
}

class VPFloatHandler : VPHandler<Float> {
    var start: Float {didSet{updateConversion(start, end)}}
    var end: Float {didSet{updateConversion(start, end)}}
    
    func updateConversion(start:Float, _ end:Float){
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