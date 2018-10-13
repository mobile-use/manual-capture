//
//  AVCaptureDeviceDummie.swift
//  Manual Capture
//
//  Created by Jean Flaherty on 10/11/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//

import UIKit

class AVCaptureDeviceDummie: AVCaptureDevice {
    @available(iOS 10.0, *)
    override class func `default`(_ deviceType: AVCaptureDeviceDummie.DeviceType, for mediaType: AVMediaType?, position: AVCaptureDeviceDummie.Position) -> AVCaptureDeviceDummie? {
        return AVCaptureDeviceDummie(mediaTypes: .video, position: .front)
    }
    
    override class func `default`(for mediaType: AVMediaType) -> AVCaptureDeviceDummie? {
        return AVCaptureDeviceDummie(mediaTypes: mediaType)
    }
    
    override class func devices(for mediaType: AVMediaType) -> [AVCaptureDevice] {
        return [AVCaptureDeviceDummie(mediaTypes: mediaType)]
    }
    
    override var uniqueID: String { return "Dummie" }
    
    private var _focusMode: AVCaptureDeviceDummie.FocusMode = .continuousAutoFocus
    override var focusMode: AVCaptureDeviceDummie.FocusMode {
        get {
            return _focusMode
        }
        set {
            _focusMode = newValue
        }
    }
    private var _exposureMode: AVCaptureDeviceDummie.ExposureMode = .continuousAutoExposure
    override var exposureMode: AVCaptureDeviceDummie.ExposureMode {
        get {
            return _exposureMode
        }
        set {
            _exposureMode = newValue
        }
    }
    private var _whiteBalanceMode: AVCaptureDeviceDummie.WhiteBalanceMode = .continuousAutoWhiteBalance
    override var whiteBalanceMode: AVCaptureDeviceDummie.WhiteBalanceMode {
        get {
            return _whiteBalanceMode
        }
        set {
            _whiteBalanceMode = newValue
        }
    }
    private var _iso: Float = 0
    override var iso: Float { return _iso }
    private var _exposureTargetOffset: Float = 0
    override var exposureTargetOffset: Float { return _exposureTargetOffset }
    private var _exposureDuration: CMTime = .zero
    override var exposureDuration: CMTime { return _exposureDuration }
    private var _deviceWhiteBalanceGains: AVCaptureDeviceDummie.WhiteBalanceGains =
        AVCaptureDeviceDummie.WhiteBalanceGains(redGain: 0,greenGain: 0,blueGain: 0)
    override var deviceWhiteBalanceGains: AVCaptureDeviceDummie.WhiteBalanceGains {
        return _deviceWhiteBalanceGains
    }
    private var _lensPosition: Float = 0
    override var lensPosition: Float { return _lensPosition }
    private var _videoZoomFactor: CGFloat = 0
    override var videoZoomFactor: CGFloat {
        get {
            return _videoZoomFactor
        }
        set {
            _videoZoomFactor = newValue
        }
    }
    override var maxWhiteBalanceGain: Float { return 4.0 }
    override var maxExposureTargetBias: Float { return 1.0 }
    private var _activeMaxExposureDuration = CMTime(seconds: 1, preferredTimescale: 1)
    override var activeMaxExposureDuration: CMTime {
        get{
            return _activeMaxExposureDuration
        }
        set{
            _activeMaxExposureDuration = newValue
        }
    }
    
    private let _position: AVCaptureDeviceDummie.Position
    override var position: AVCaptureDeviceDummie.Position  { return _position }
    
    private let _mediaTypes: [AVMediaType]
    
    init(mediaTypes: AVMediaType..., position: AVCaptureDeviceDummie.Position = .front) {
        _mediaTypes = mediaTypes
        _position = position
    }
    
    override func hasMediaType(_ mediaType: AVMediaType) -> Bool {
        return _mediaTypes.contains(mediaType)
    }
    
    override func lockForConfiguration() throws {}
    override func unlockForConfiguration() {}
    
    override func setFocusModeLocked(lensPosition: Float, completionHandler handler: ((CMTime) -> Void)? = nil) {
        focusMode = .locked
        handler?(.zero)
    }
    override func setExposureModeCustom(duration: CMTime, iso ISO: Float, completionHandler handler: ((CMTime) -> Void)? = nil) {
        _exposureMode = .custom
        _exposureDuration = duration
        _iso = ISO
        handler?(.zero)
    }
    override func setExposureTargetBias(_ bias: Float, completionHandler handler: ((CMTime) -> Void)? = nil) {
        _exposureTargetOffset = bias
        handler?(.zero)
    }
    override func setWhiteBalanceModeLocked(with whiteBalanceGains: AVCaptureDevice.WhiteBalanceGains, completionHandler handler: ((CMTime) -> Void)? = nil) {
        _whiteBalanceMode = .locked
        _deviceWhiteBalanceGains = whiteBalanceGains
        handler?(.zero)
    }
    override func isExposureModeSupported(_ exposureMode: AVCaptureDevice.ExposureMode) -> Bool { return true }
    
    override func ramp(toVideoZoomFactor factor: CGFloat, withRate rate: Float) {
        _videoZoomFactor = factor
    }
    
}
