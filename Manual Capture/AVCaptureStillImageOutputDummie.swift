//
//  AVCaptureStillImageOutputDummie.swift
//  Manual Capture
//
//  Created by Jean Flaherty on 10/11/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//

import UIKit

class AVCaptureStillImageOutputDummie: AVCaptureStillImageOutput {
    private var _isCapturingStillImage: Bool = false
    @objc override var isCapturingStillImage: Bool { return _isCapturingStillImage }
    
    override required init() {
//        super.init()
    }
}
