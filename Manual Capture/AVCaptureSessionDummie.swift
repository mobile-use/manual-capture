//
//  AVCaptureSessionDummie.swift
//  Manual Capture
//
//  Created by Jean Flaherty on 10/11/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//

import UIKit

class AVCaptureSessionDummie: AVCaptureSession {
    var _isRunning: Bool = false
    override var isRunning: Bool { return _isRunning }
    var _inputs: [AVCaptureInput] = []
    override var inputs: [AVCaptureInput] { return _inputs }
    var _outputs: [AVCaptureOutput] = []
    override var outputs: [AVCaptureOutput] { return _outputs }
    var _sessionPreset: AVCaptureSession.Preset = AVCaptureSession.Preset.photo
    override var sessionPreset: AVCaptureSession.Preset {
        get {
            return _sessionPreset
        }
        set {
            _sessionPreset = newValue
        }
    }
    
    override required init() {
        
    }
    
    override func addInput(_ input: AVCaptureInput) {
        _inputs.append(input)
    }
    
    override func removeInput(_ input: AVCaptureInput) {
        _inputs.removeAll() { $0 == input }
    }
    
    override func addOutput(_ output: AVCaptureOutput) {
        _outputs.append(output)
    }
    
    override func removeOutput(_ output: AVCaptureOutput) {
        _outputs.removeAll() { $0 == output }
    }
    
    override func canAddInput(_ input: AVCaptureInput) -> Bool {
        return true
    }
    
    override func canAddOutput(_ output: AVCaptureOutput) -> Bool {
        return true
    }
    
    override func beginConfiguration() {}
    
    override func commitConfiguration() {}
    
    override func startRunning() {
        _isRunning = true
        NotificationCenter.default.post(name: .AVCaptureSessionDidStartRunning, object: self)
    }
    
    override func stopRunning() {
        _isRunning = false
        NotificationCenter.default.post(name: .AVCaptureSessionDidStopRunning, object: self)
    }

}
