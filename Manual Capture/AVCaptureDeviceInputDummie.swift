//
//  AVCaptureDeviceInputDummie.swift
//  Manual Capture
//
//  Created by Jean Flaherty on 10/11/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//

import UIKit

class AVCaptureDeviceInputDummie: AVCaptureDeviceInput {
    private let _ports: [AVCaptureInput.Port] = []
    override var ports: [AVCaptureInput.Port] { return _ports }
    private let _device: AVCaptureDevice
    override var device: AVCaptureDevice { return _device }
    private var _unifiedAutoExposureDefaultsEnabled = false
    override var unifiedAutoExposureDefaultsEnabled: Bool {
        get {
            return _unifiedAutoExposureDefaultsEnabled
        }
        set {
            _unifiedAutoExposureDefaultsEnabled = newValue
        }
    }
    
    override required init(device: AVCaptureDevice) throws {
        _device = device
        do {
            try super.init(device: device)
        }
    }
}
