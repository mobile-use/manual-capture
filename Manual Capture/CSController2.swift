//
//  CSController.swift
//  Capture
//
//  Created by Jean on 9/7/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

//enum SessionError : ErrorType {
//    enum InputError : ErrorType {
//        case AccessDenied
//        case CannotAddToSession
//        case InitFailed(ErrorType?)
//    }
//    enum OutputError : ErrorType {
//        case CannotAddToSession
//    }
//    case NoCameraForPosition
//    case CameraInputError(InputError)
//    case CameraAccessDenied
//    case PhotoOutputError(OutputError)
//}
//
//// MARK: Delegate Protocol
//
//protocol CSControllerDelegate {
//    func sessionControllerError(error: ErrorType)
//    func sessionControllerNotification(notification:CSNotification)
//}
//
//// change type
//enum CSChange {
//    enum Exposure {
//        case ISO(Float), TargetOffset(Float), Duration(CMTime)
//        case Bias(Float)
//        
//        case MinISO(Float), MaxISO(Float)
//        case MinDuration(CMTime), MaxDuration(CMTime)
//    }
//    case LensPosition(Float)
//    case Exposure(Exposure)
//    case WhiteBalanceGains(AVCaptureWhiteBalanceGains)
//    case ZoomFactor(CGFloat)
//    
//    
//    case FocusMode(AVCaptureFocusMode)
//    case ExposureMode(AVCaptureExposureMode)
//    case WhiteBalanceMode(AVCaptureWhiteBalanceMode)
//    
//    case AspectRatio(CSAspectRatio)
//}
//
//// value set type
//enum CSSet {
//    enum Exposure {
//        case Bias(Float)
//        case DurationAndISO(CMTime, Float)
//    }
//    case LensPosition(Float)
//    case Exposure(Exposure)
//    case WhiteBalanceGains(AVCaptureWhiteBalanceGains)
//    case ZoomFactor(CGFloat), ZoomFactorRamp(CGFloat, Float)
//    
//    
//    case FocusMode(AVCaptureFocusMode)
//    case ExposureMode(AVCaptureExposureMode)
//    case WhiteBalanceMode(AVCaptureWhiteBalanceMode)
//    
//    case AspectRatio(CSAspectRatio)
//}
//
//// notification type
//enum CSNotification {
//    case CapturingPhoto(Bool)
//    case PhotoSaved
//    case SubjectAreaChange
//    case SessionRunning(Bool)
//}
//
//typealias CSAspectRatio = CGFloat
//func CSAspectRatioMake(width: CGFloat, _ height: CGFloat) -> CSAspectRatio {
//    return width / height
//}

class CSController2: NSObject {
    
    private var _notifObservers: [ String : AnyObject? ] = [ : ]
    typealias KVOContext = UInt8
    private var _context: [ String : KVOContext ] = [ : ]
    
    let session: AVCaptureSession
    let sessionQueue: dispatch_queue_t
    let previewView: CapturePreviewView
    var camera: AVCaptureDevice!
    var cameraInput: AVCaptureDeviceInput!
    var photoOutput: AVCaptureStillImageOutput!
    
    var aspectRatio = CSAspectRatioMake(16,9) {
        didSet{
            
            //previewView.aspectRatio = aspectRatio
            notify( .AspectRatio(aspectRatio) )
            
        }
    }
    var volumeButtonHandler = JPSVolumeButtonHandler()
    
    var delegate: CSControllerDelegate?
    
    struct VOBlocks {
        
        typealias LensPositionBlock = (Float) -> ()
        typealias ISOBlock = (Float) -> ()
        typealias ExposureDurationBlock = (CMTime) -> ()
        typealias TargetOffsetBlock = (Float) -> ()
        typealias TargetBiasBlock = (Float) -> ()
        typealias WhiteBalanceGainsBlock = (AVCaptureWhiteBalanceGains) -> ()
        typealias ZoomFactorBlock = (CGFloat) -> ()
        
        typealias FocusModeBlock = (AVCaptureFocusMode) -> ()
        typealias ExposureModeBlock = (AVCaptureExposureMode) -> ()
        typealias WhiteBalanceModeBlock = (AVCaptureWhiteBalanceMode) -> ()
        
        typealias AspectRatioBlock = (CSAspectRatio) -> ()
        
        var lensPosition        = [ String : LensPositionBlock ]()
        var iso                 = [ String : ISOBlock ]()
        var exposureDuration    = [ String : ExposureDurationBlock ]()
        var targetOffset        = [ String : TargetOffsetBlock ]()
        var targetBias          = [ String : TargetOffsetBlock ]()
        var whiteBalance        = [ String : WhiteBalanceGainsBlock ]()
        var zoomFactor          = [ String : ZoomFactorBlock ]()
        
        var focusMode           = [ String : FocusModeBlock ]()
        var exposureMode        = [ String : ExposureModeBlock ]()
        var whiteBalanceMode    = [ String : WhiteBalanceModeBlock ]()
        
        var aspectRatio         = [ String : AspectRatioBlock ]()
        
    }
    var voBlocks = VOBlocks()
    
    override init() {
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        
        sessionQueue = dispatch_queue_create("Capture Session", DISPATCH_QUEUE_SERIAL)
        
        previewView = CapturePreviewView(session: session)
        previewView.aspectRatio = aspectRatio
        
        super.init()
        
        unowned let me = self
        volumeButtonHandler.action = { me.captureStillPhoto() }
        
        
        requestCameraAccess(){
            self.startCamera()
        }
    }
    
    private func requestCameraAccess(completionHandler:()->Void) {
        
        AVCaptureDevice.requestAccessForMediaType( AVMediaTypeVideo ) {
            (granted) in
            
            if granted {
                
                completionHandler()
                
            }else{
                
                self.notify(SessionError.CameraAccessDenied)
                
            }
            
        }
        
    }
    
    func startCamera() {
        
        func addDevicesIfNeeded(){
            
            func addCameraFromPosition(position:AVCaptureDevicePosition) throws {
                
                guard let cameraFromPosition = position.device else {
                    throw SessionError.NoCameraForPosition
                }
                camera = cameraFromPosition
                
            }
            
            func addInputFromCamera(camera:AVCaptureDevice) throws {
                
                do {
                    cameraInput = try AVCaptureDeviceInput(device: camera)
                }
                    
                catch {
                    throw SessionError.CameraInputError(.InitFailed(error))
                }
                
                guard session.canAddInput(cameraInput) else {
                    throw SessionError.CameraInputError(.CannotAddToSession)
                }
                
                session.addInput(cameraInput)
                previewView.previewLayer.connection.videoOrientation = .LandscapeRight
                previewView.previewLayer.connection?.preferredVideoStabilizationMode = .Auto
                
            }
            
            func addPhotoOutput() throws {
                
                photoOutput = AVCaptureStillImageOutput()
                
                guard session.canAddOutput(photoOutput) else {
                    throw SessionError.PhotoOutputError(.CannotAddToSession)
                }
                
                photoOutput.highResolutionStillImageOutputEnabled = true
                session.addOutput(photoOutput)
                
            }
            
            do {
                
                session.beginConfiguration()
                
                if camera == nil {
                    
                    try addCameraFromPosition(AVCaptureDevicePosition.Back)
                    
                }
                if cameraInput == nil {
                    
                    try addInputFromCamera(camera)
                    
                }
                if photoOutput == nil {
                    
                    try addPhotoOutput()
                    
                }
                
                session.commitConfiguration()
                
            } catch {
                
                self.notify(error)
                
            }
        }
        
        func startRunningSession() {
            
            dispatch_async(sessionQueue) {
                
                self.addObservers()
                
                self.session.startRunning()
                
            }
            
        }
        
        addDevicesIfNeeded()
        startRunningSession()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        guard let new = change![NSKeyValueChangeNewKey], keyPath = keyPath else { return }
        
        switch keyPath {
            
        case "photoOutput.capturingStillImage":
            
            let capturing = new.boolValue
            
            notify( .CapturingPhoto(capturing) )
            
        case "camera.focusMode":
            
            let focusMode = AVCaptureFocusMode(rawValue: new.integerValue)!
            
            notify( .FocusMode(focusMode) )
            
        case "camera.exposureMode":
            
            let exposureMode = AVCaptureExposureMode(rawValue: new.integerValue)!
            
            notify( .ExposureMode(exposureMode) )
            
        case "camera.whiteBalanceMode":
            
            let whiteBalanceMode = AVCaptureWhiteBalanceMode(rawValue: new.integerValue)!
            
            notify (.WhiteBalanceMode(whiteBalanceMode) )
            
        case "camera.ISO":
            
            let iso = new.floatValue
            notify( .Exposure(.ISO(iso)) )
            
        case "camera.exposureTargetOffset":
            
            let exposureTargetOffset = new.floatValue
            
            notify(.Exposure(.TargetOffset(exposureTargetOffset)) )
            
        case "camera.exposureDuration":
            
            let exposureDuration = new.CMTimeValue
            
            notify( .Exposure(.Duration(exposureDuration)) )
            
        case "camera.deviceWhiteBalanceGains":
            
            var whiteBalanceGains = AVCaptureWhiteBalanceGains() // Empty
            (new as! NSValue).getValue( &whiteBalanceGains ) // Convert
            
            notify( .WhiteBalanceGains( whiteBalanceGains ) )
            
        case "camera.lensPosition":
            
            let lensPosition = new.floatValue
            
            notify( .LensPosition(lensPosition) )
            
            
        case "camera.adjustingFocus": return
        case "camera.adjustingExposure": return
        default: return
            
        }
    }
    
    // MARK: Notify
    
    private func notify(error: ErrorType) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.delegate?.sessionControllerError(error)
            print(error)
            
        }
        
    }
    
    private func notify(notification: CSNotification) {
        dispatch_async( dispatch_get_main_queue() ) {
            self.delegate?.sessionControllerNotification(notification)
        }
    }
    
    private func notify(change: CSChange) {
        switch change {
        case .LensPosition(let v): self.voBlocks.lensPosition.forEach { $1(v) }
        case .Exposure(.ISO(let v)): self.voBlocks.iso.forEach { $1(v) }
        case .Exposure(.Duration(let v)): self.voBlocks.exposureDuration.forEach { $1(v) }
        case .Exposure(.TargetOffset(let v)): self.voBlocks.targetOffset.forEach { $1(v) }
        case .Exposure(.Bias(let v)): self.voBlocks.targetBias.forEach { $1(v) }
        case .WhiteBalanceGains(let v): self.voBlocks.whiteBalance.forEach { $1(v) }
        case .ZoomFactor(let v): self.voBlocks.zoomFactor.forEach { $1(v) }
            
        case .FocusMode(let v): self.voBlocks.focusMode.forEach { $1(v) }
        case .ExposureMode(let v): self.voBlocks.exposureMode.forEach { $1(v) }
        case .WhiteBalanceMode(let v): self.voBlocks.whiteBalanceMode.forEach { $1(v) }
            
        case .AspectRatio(let v): self.voBlocks.aspectRatio.forEach { $1(v) }
        default: break
        }
    }
    
    private func addObservers(){
        
        let keyPaths = [
            "photoOutput.capturingStillImage",
            
            "camera.adjustingFocus",
            "camera.adjustingExposure",
            
            "camera.focusMode",
            "camera.exposureMode",
            "camera.whiteBalanceMode",
            
            "camera.ISO",
            "camera.exposureTargetOffset",
            "camera.exposureDuration",
            "camera.deviceWhiteBalanceGains",
            "camera.lensPosition"
        ]
        
        for keyPath in keyPaths {
            
            // add observer
            _context[keyPath] = KVOContext()
            addObserver(
                self,
                forKeyPath: keyPath,
                options: .New,
                context: &self._context[keyPath]!
            )
            
        }
        
        unowned let me = self
        
        _notifObservers["RuntimeError"] = NSNotificationCenter.defaultCenter().addObserverForName(
            AVCaptureSessionRuntimeErrorNotification,
            object: sessionQueue,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { (_) in
                dispatch_async( me.sessionQueue ) {
                    me.session.startRunning()
                }
            }
        )
        
        _notifObservers["SubjectAreaChange"] = NSNotificationCenter.defaultCenter().addObserverForName(
            AVCaptureDeviceSubjectAreaDidChangeNotification,
            object: camera,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { (_) in
                me.delegate?.sessionControllerNotification(.SubjectAreaChange)
            }
        )
        
        _notifObservers["SessionStarted"] = NSNotificationCenter.defaultCenter().addObserverForName(
            AVCaptureSessionDidStartRunningNotification,
            object: session, queue: NSOperationQueue.mainQueue(),
            usingBlock: { (_) in
                me.delegate?.sessionControllerNotification( .SessionRunning(true) )
            }
        )
        
        _notifObservers["SessionStopped"] = NSNotificationCenter.defaultCenter().addObserverForName(
            AVCaptureSessionDidStopRunningNotification,
            object: session,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { (_) in
                me.delegate?.sessionControllerNotification( .SessionRunning(false) )
            }
        )
    }
    
    private func removeObservers(){
        
        for (kp, _) in _context {
            
            removeObserver(self, forKeyPath: kp, context: &_context[kp]!)
            
        }
        
        for (_, observer) in _notifObservers {
            
            NSNotificationCenter.defaultCenter().removeObserver(observer!)
            
        }
        
    }
    
    func set(set:CSSet){
        
        let cameraConfig = { (config: () -> Void) -> Void in
            
            do {
                try self.camera.lockForConfiguration()
                
                config()
                
                self.camera.unlockForConfiguration()
            }
                
            catch {
                print(error)
            }
            
        }
        
        switch set {
            
        case .FocusMode( let focusMode ):
            
            cameraConfig(){
                
                self.camera.focusMode = focusMode
                
            }
            
        case .ExposureMode( let exposureMode ):
            
            cameraConfig(){
                
                self.camera.exposureMode = exposureMode
                
            }
            
        case .WhiteBalanceMode( let whiteBalanceMode ):
            
            cameraConfig(){
                
                self.camera.whiteBalanceMode = whiteBalanceMode
                
            }
            
        case .Exposure( .DurationAndISO( let duration , let ISO ) ):
            
            cameraConfig(){
                
                self.camera.setExposureModeCustomWithDuration(duration, ISO: ISO, completionHandler: nil)
                
            }

        case .Exposure( .Bias( let bias ) ):
            
            cameraConfig(){
                
                self.camera.setExposureTargetBias( bias, completionHandler: nil )
                
            }
            
        case .LensPosition( let lensPosition ):
            
            cameraConfig(){
                
                self.camera.setFocusModeLockedWithLensPosition( lensPosition, completionHandler: nil )
                
            }
            
        case .WhiteBalanceGains( let wbgains ):
            
            cameraConfig(){
                
                self.camera.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains( wbgains, completionHandler: nil )
                
            }
            
        case .ZoomFactor(let zFactor):
            
            cameraConfig(){
                
                self.camera.videoZoomFactor = zFactor
                
            }
            
        case .ZoomFactorRamp(let zFactor, let rate):
            
            cameraConfig(){
                
                self.camera.rampToVideoZoomFactor(zFactor, withRate: rate)
                
            }
            
        case .AspectRatio(let aspectRatio):
            
            self.aspectRatio = aspectRatio
            
            
        case .AspectRatioMode(let _): break
            
        }
        
    }
    
    func captureStillPhoto() {
        
        dispatch_async(sessionQueue){
            
            func captureError(errorText:String) {
                
                UIAlertView(title: "Capture Error", message: errorText, delegate: nil, cancelButtonTitle: "Dismiss").show()
                
            }
            
            // Update the orientation on the still image output video connection before capturing.
            guard let connection = self.photoOutput.connectionWithMediaType(AVMediaTypeVideo) else {
                
                captureError("Output connection was bad. Try retaking photo.")
                return
                
            }
            connection.videoOrientation = self.previewView.previewLayer.connection?.videoOrientation ?? .LandscapeRight
            
            self.photoOutput.captureStillImageAsynchronouslyFromConnection(connection){
                (imageSampleBuffer, error) in
                
                guard imageSampleBuffer != nil else{
                    
                    captureError("Couldn't retrieve sample buffer. Try retaking photo.")
                    return
                    
                }
                guard let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer) else {
                    
                    captureError("Couldn't get image data. Try retaking photo.")
                    return
                    
                }
                guard let image: UIImage = UIImage(data: imageData) else {
                    
                    captureError("Couldn't create image from data. Try retaking photo.")
                    return
                    
                }
                
                let scaled = (
                    width: min( image.size.height * self.aspectRatio, image.size.width),
                    height: min( image.size.width / self.aspectRatio, image.size.height)
                )
                var cropRect = CGRectInset(
                    CGRectMake(0, 0, image.size.width, image.size.height), // original rect
                    (image.size.width - scaled.width) / 2 , // clipped width
                    (image.size.height - scaled.height) / 2 // clipped height
                )
                
                var cropTransForm: CGAffineTransform {
                    func rad(deg:Double)-> CGFloat {
                        return CGFloat(deg / 180.0 * M_PI)
                    }
                    switch (image.imageOrientation)
                    {
                    case .Left:
                        return CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(90)), 0, -image.size.height)
                    case .Right:
                        return CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-90)), -image.size.width, 0)
                    case .Down:
                        return CGAffineTransformTranslate(CGAffineTransformMakeRotation(rad(-180)), -image.size.width, -image.size.height)
                    default:
                        return CGAffineTransformIdentity
                    }
                }
                
                cropRect = CGRectApplyAffineTransform(cropRect, cropTransForm)
                
                guard let croppedImage = CGImageCreateWithImageInRect(image.CGImage, cropRect) else {
                    
                    captureError("Couldn't crop image to apropriate size. Try retaking photo.")
                    return
                    
                }
                let orientation = ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!
                
                ALAssetsLibrary().writeImageToSavedPhotosAlbum(croppedImage, orientation: orientation) {
                    (path, error) in
                    
                    self.notify(.PhotoSaved)
                    
                    guard error == nil else {
                        
                        captureError("Couldn't save photo.\n Try going to Settings > Privacy > Photos\n Then switch \(kAppName) to On")
                        return
                        
                    }
                    
                    // photo saved
                    
                }
            }
        }
        
    }
    
    
    // MARK: Utilities
    
    
    
    func _normalizeGains(var g:AVCaptureWhiteBalanceGains) -> AVCaptureWhiteBalanceGains{
        
        let maxGain = camera.maxWhiteBalanceGain - 0.001
        
        g.redGain = max( 1.0, g.redGain )
        
        
        g.greenGain = max( 1.0, g.greenGain )
        
        g.blueGain = max( 1.0, g.blueGain )
        
        g.redGain = min( maxGain, g.redGain )
        
        g.greenGain = min( maxGain, g.greenGain )
        
        g.blueGain = min( maxGain, g.blueGain )
        
        return g
        
    }
    
    
    
    /// previous tint and temp
    
    
    
    private var _ptt:AVCaptureWhiteBalanceTemperatureAndTintValues? = nil
    
    func _normalizeGainsForTemperatureAndTint(tt:AVCaptureWhiteBalanceTemperatureAndTintValues) -> AVCaptureWhiteBalanceGains{
        
        var g = camera.deviceWhiteBalanceGainsForTemperatureAndTintValues(tt)
        
        if !_gainsInRange(g){
            
            if _ptt != nil {
                
                let dTemp = tt.temperature - _ptt!.temperature
                
                let dTint = tt.tint - _ptt!.tint
                
                var eTint = round(tt.tint)
                
                var eTemperature = round(tt.temperature)
                
                var i = 0
                
                var eGains: AVCaptureWhiteBalanceGains = camera.deviceWhiteBalanceGainsForTemperatureAndTintValues(tt)
                
                
                
                if abs(dTemp) > abs(dTint) {
                    
                    while !_gainsInRange(eGains) {
                        
                        let nTT = camera.temperatureAndTintValuesForDeviceWhiteBalanceGains(_normalizeGains(eGains))
                        
                        let eTintNew = round(nTT.tint)
                        
                        let eTemperatureNew = round(nTT.temperature)
                        
                        //prioritize
                        
                        if eTint != eTintNew {eTint = eTintNew}
                            
                        else if eTemperature != eTemperatureNew {eTemperature = eTemperatureNew}
                        
                        if i > 3 || (eTint == eTintNew && eTemperature == eTemperatureNew) {
                            
                            eGains = _normalizeGains(eGains)
                            
                        }else{
                            
                            eGains = camera.deviceWhiteBalanceGainsForTemperatureAndTintValues(AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: eTemperature, tint: eTint))
                            
                        }
                        
                        i++
                        
                    }
                    
                    g = eGains
                    
                }else if abs(dTemp) < abs(dTint) {
                    
                    while !_gainsInRange(eGains) {
                        
                        let nTT = camera.temperatureAndTintValuesForDeviceWhiteBalanceGains(_normalizeGains(eGains))
                        
                        let eTintNew = round(nTT.tint)
                        
                        let eTemperatureNew = round(nTT.temperature)
                        
                        if eTemperature != eTemperatureNew {eTemperature = eTemperatureNew}
                            
                        else if eTint != eTintNew {eTint = eTintNew}
                        
                        if i > 3 || (eTint == eTintNew && eTemperature == eTemperatureNew) {
                            
                            eGains = _normalizeGains(eGains)
                            
                        }else{
                            
                            eGains = camera.deviceWhiteBalanceGainsForTemperatureAndTintValues(AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: eTemperature, tint: eTint))
                            
                        }
                        
                        i++
                        
                    }
                    
                    g = eGains
                    
                }
                
            }
            
        }
        
        _ptt = tt
        
        return _normalizeGains(g)
        
    }
    
    func _gainsInRange(gains:AVCaptureWhiteBalanceGains) -> Bool {
        
        let maxGain = camera.maxWhiteBalanceGain
        
        let r = (1.0 <= gains.redGain && gains.redGain <= maxGain)
        
        let g = (1.0 <= gains.greenGain && gains.greenGain <= maxGain)
        
        let b = (1.0 <= gains.blueGain && gains.blueGain <= maxGain)
        
        return r && g && b
        
    }
    

    deinit {
        removeObservers()
    }
}
