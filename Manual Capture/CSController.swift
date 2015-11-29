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

enum SessionError : ErrorType {
    enum InputError : ErrorType {
        case AccessDenied
        case CannotAddToSession
        case InitFailed(ErrorType?)
    }
    enum OutputError : ErrorType {
        case CannotAddToSession
    }
    case NoCameraForPosition
    case CameraInputError(InputError)
    case AudioInputError(InputError)
    case CameraAccessDenied
    case PhotoOutputError(OutputError)
    case VideoOutputError(OutputError)
}

// MARK: Delegate Protocol

protocol CSControllerDelegate {
    func sessionControllerError(error: ErrorType)
    func sessionControllerNotification(notification:CSNotification)
}

// change type
enum CSChange {
    enum Exposure {
        case ISO(Float), targetOffset(Float), duration(CMTime)
        case bias(Float)
        
        case minISO(Float), maxISO(Float)
        case minDuration(CMTime), maxDuration(CMTime)
    }
    case cameraLensPosition(Float)
    case cameraExposure(Exposure)
    case cameraWhiteBalanceGains(AVCaptureWhiteBalanceGains)
    case cameraZoomFactor(CGFloat)
    
    
    case cameraFocusMode(AVCaptureFocusMode)
    case cameraExposureMode(AVCaptureExposureMode)
    case cameraWhiteBalanceMode(AVCaptureWhiteBalanceMode)
    
    case cropAspectRatio(CSAspectRatio)
}

// value set type
enum CSSet {
    enum Exposure {
        case bias(Float)
        case durationAndISO(CMTime, Float)
    }
    case cameraLensPosition(Float)
    case cameraExposure(Exposure)
    case cameraWhiteBalanceGains(AVCaptureWhiteBalanceGains)
    case cameraZoomFactor(CGFloat), cameraZoomFactorRamp(CGFloat, Float)
    
    
    case cameraFocusMode(AVCaptureFocusMode)
    case cameraExposureMode(AVCaptureExposureMode)
    case cameraWhiteBalanceMode(AVCaptureWhiteBalanceMode)
    
    case cropAspectRatio(CSAspectRatio)
}

// notification type
enum CSNotification {
    case capturingStillImage(Bool)
    case imageSaved
    case cameraSubjectAreaChange
    case sessionRunning(Bool)
}

typealias CSAspectRatio = CGFloat
func CSAspectRatioMake(width: CGFloat, _ height: CGFloat) -> CSAspectRatio {
    return width / height
}

class CSController: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    private var _notifObservers: [ String : AnyObject? ] = [ : ]
    typealias KVOContext = UInt8
    private var _context: [ String : KVOContext ] = [ : ]
    
    let session: AVCaptureSession
    let sessionQueue: dispatch_queue_t
    let previewLayer: CapturePreviewLayer
    var camera: AVCaptureDevice!
    var cameraInput: AVCaptureDeviceInput!
    var audioInput: AVCaptureDeviceInput!
    var photoOutput: AVCaptureStillImageOutput!
    var videoOutput: AVCaptureMovieFileOutput!
    var backgroundRecordingID: UIBackgroundTaskIdentifier!
    
    var cropAspectRatio = CSAspectRatioMake(16,9) {
        didSet{
            
            previewLayer.cropAspectRatio = cropAspectRatio
            notify( .cropAspectRatio(cropAspectRatio) )
            
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
        session.sessionPreset = kIsVideoMode ? AVCaptureSessionPresetHigh : AVCaptureSessionPresetPhoto
        
        sessionQueue = dispatch_queue_create("Capture Session", DISPATCH_QUEUE_SERIAL)
        
        previewLayer = CapturePreviewLayer(session: session)
        previewLayer.cropAspectRatio = cropAspectRatio
        
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
            
            func addCameraInputFromCamera(camera:AVCaptureDevice) throws {
                
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
                
                guard let connection = previewLayer.connection else { return }
                
                let statusBarOrientation = UIApplication.sharedApplication().statusBarOrientation
                connection.videoOrientation = AVCaptureVideoOrientation(ui: statusBarOrientation)
                if connection.supportsVideoStabilization {
                    connection.preferredVideoStabilizationMode = .Auto
                }
                
            }
            
            func addAudioInput() throws {
                
                do {
                    let audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
                    audioInput = try AVCaptureDeviceInput(device: audioDevice)
                }
                    
                catch {
                    throw SessionError.AudioInputError(.InitFailed(error))
                }
                
                guard session.canAddInput(audioInput) else {
                    throw SessionError.AudioInputError(.CannotAddToSession)
                }
                session.addInput(audioInput)
                
            }
            
            func addPhotoOutput() throws {
                
                photoOutput = AVCaptureStillImageOutput()
                
                guard session.canAddOutput(photoOutput) else {
                    throw SessionError.PhotoOutputError(.CannotAddToSession)
                }
                
                photoOutput.highResolutionStillImageOutputEnabled = true
                session.addOutput(photoOutput)
                
            }
            
            func addVideoOutput() throws {
                videoOutput =  AVCaptureMovieFileOutput()
                guard session.canAddOutput(videoOutput) else {
                    throw SessionError.VideoOutputError(.CannotAddToSession)
                }
                session.addOutput(videoOutput)
                
                let connection = videoOutput.connectionWithMediaType(AVMediaTypeVideo)
                if connection.supportsVideoStabilization {
                    connection.preferredVideoStabilizationMode = .Auto
                }
            }
            
            do {
                
                session.beginConfiguration()
                
                backgroundRecordingID = UIBackgroundTaskInvalid
                
                if camera == nil {
                    try addCameraFromPosition(AVCaptureDevicePosition.Back)
                }
                if cameraInput == nil {
                    try addCameraInputFromCamera(camera)
                }
                if photoOutput == nil {
                    try addPhotoOutput()
                }
                if kIsVideoMode {
                    if audioInput == nil {
                        try addAudioInput()
                    }
                    if videoOutput == nil {
                        try addVideoOutput()
                    }
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
            
            notify( .capturingStillImage(capturing) )
            
        case "camera.focusMode":
            
            let focusMode = AVCaptureFocusMode(rawValue: new.integerValue)!
            
            notify( .cameraFocusMode(focusMode) )
            
        case "camera.exposureMode":
            
            let exposureMode = AVCaptureExposureMode(rawValue: new.integerValue)!
            
            notify( .cameraExposureMode(exposureMode) )
            
        case "camera.whiteBalanceMode":
            
            let whiteBalanceMode = AVCaptureWhiteBalanceMode(rawValue: new.integerValue)!
            
            notify (.cameraWhiteBalanceMode(whiteBalanceMode) )
            
        case "camera.ISO":
            
            let iso = new.floatValue
            notify( .cameraExposure(.ISO(iso)) )
            
        case "camera.exposureTargetOffset":
            
            let exposureTargetOffset = new.floatValue
            
            notify(.cameraExposure(.targetOffset(exposureTargetOffset)) )
            
        case "camera.exposureDuration":
            
            let exposureDuration = new.CMTimeValue
            
            notify( .cameraExposure(.duration(exposureDuration)) )
            
        case "camera.deviceWhiteBalanceGains":
            
            var whiteBalanceGains = AVCaptureWhiteBalanceGains() // Empty
            (new as! NSValue).getValue( &whiteBalanceGains ) // Convert
            
            notify( .cameraWhiteBalanceGains( whiteBalanceGains ) )
            
        case "camera.lensPosition":
            
            let lensPosition = new.floatValue
            
            notify( .cameraLensPosition(lensPosition) )
            
            
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
        case .cameraLensPosition(let v): self.voBlocks.lensPosition.forEach { $1(v) }
        case .cameraExposure(.ISO(let v)): self.voBlocks.iso.forEach { $1(v) }
        case .cameraExposure(.duration(let v)): self.voBlocks.exposureDuration.forEach { $1(v) }
        case .cameraExposure(.targetOffset(let v)): self.voBlocks.targetOffset.forEach { $1(v) }
        case .cameraExposure(.bias(let v)): self.voBlocks.targetBias.forEach { $1(v) }
        case .cameraWhiteBalanceGains(let v): self.voBlocks.whiteBalance.forEach { $1(v) }
        case .cameraZoomFactor(let v): self.voBlocks.zoomFactor.forEach { $1(v) }
            
        case .cameraFocusMode(let v): self.voBlocks.focusMode.forEach { $1(v) }
        case .cameraExposureMode(let v): self.voBlocks.exposureMode.forEach { $1(v) }
        case .cameraWhiteBalanceMode(let v): self.voBlocks.whiteBalanceMode.forEach { $1(v) }
            
        case .cropAspectRatio(let v): self.voBlocks.aspectRatio.forEach { $1(v) }
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
                me.delegate?.sessionControllerNotification(.cameraSubjectAreaChange)
            }
        )
        
        _notifObservers["SessionStarted"] = NSNotificationCenter.defaultCenter().addObserverForName(
            AVCaptureSessionDidStartRunningNotification,
            object: session, queue: NSOperationQueue.mainQueue(),
            usingBlock: { (_) in
                me.delegate?.sessionControllerNotification( .sessionRunning(true) )
            }
        )
        
        _notifObservers["SessionStopped"] = NSNotificationCenter.defaultCenter().addObserverForName(
            AVCaptureSessionDidStopRunningNotification,
            object: session,
            queue: NSOperationQueue.mainQueue(),
            usingBlock: { (_) in
                me.delegate?.sessionControllerNotification( .sessionRunning(false) )
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
            
        case .cameraFocusMode( let focusMode ):
            
            cameraConfig(){
                
                self.camera.focusMode = focusMode
                
            }
            
        case .cameraExposureMode( let exposureMode ):
            
            cameraConfig(){
                
                self.camera.exposureMode = exposureMode
                
            }
            
        case .cameraWhiteBalanceMode( let whiteBalanceMode ):
            
            cameraConfig(){
                
                self.camera.whiteBalanceMode = whiteBalanceMode
                
            }
            
        case .cameraExposure( .durationAndISO( let duration , let ISO ) ):
            
            cameraConfig(){
                
                self.camera.setExposureModeCustomWithDuration(duration, ISO: ISO, completionHandler: nil)
                
            }

        case .cameraExposure( .bias( let bias ) ):
            
            cameraConfig(){
                
                self.camera.setExposureTargetBias( bias, completionHandler: nil )
                
            }
            
        case .cameraLensPosition( let lensPosition ):
            
            cameraConfig(){
                
                self.camera.setFocusModeLockedWithLensPosition( lensPosition, completionHandler: nil )
                
            }
            
        case .cameraWhiteBalanceGains( let wbgains ):
            
            cameraConfig(){
                
                self.camera.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains( wbgains, completionHandler: nil )
                
            }
            
        case .cameraZoomFactor(let zFactor):
            
            cameraConfig(){
                
                self.camera.videoZoomFactor = zFactor
                
            }
            
        case .cameraZoomFactorRamp(let zFactor, let rate):
            
            cameraConfig(){
                
                self.camera.rampToVideoZoomFactor(zFactor, withRate: rate)
                
            }
            
        case .cropAspectRatio(let aspectRatio):
            
            cropAspectRatio = aspectRatio
            
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
            connection.videoOrientation = self.previewLayer.connection?.videoOrientation ?? .LandscapeRight
            
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
                    width: min( image.size.height * self.cropAspectRatio, image.size.width),
                    height: min( image.size.width / self.cropAspectRatio, image.size.height)
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
                    
                    self.notify(.imageSaved)
                    
                    guard error == nil else {
                        
                        captureError("Couldn't save photo.\n Try going to Settings > Privacy > Photos\n Then switch \(kAppName) to On")
                        return
                        
                    }
                    
                    // photo saved
                    
                }
            }
        }
        
    }
    
    
    func captureVideo() {
        
        dispatch_async(sessionQueue){
            if !self.videoOutput.recording {
                if UIDevice.currentDevice().multitaskingSupported {
                    self.backgroundRecordingID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler(nil)
                }
                
                let recordingConnection = self.videoOutput.connectionWithMediaType(AVMediaTypeVideo)
                recordingConnection.videoOrientation = self.previewLayer.connection.videoOrientation
                
                let videoFileName = NSProcessInfo.processInfo().globallyUniqueString
                let videoFilePath = NSTemporaryDirectory().stringByAppendingString(videoFileName + ".mov")

                self.videoOutput.startRecordingToOutputFileURL(
                    NSURL(fileURLWithPath: videoFilePath), recordingDelegate: self)
            }else{
                self.videoOutput.stopRecording()
            }
        }
    
    }
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        let currentBackgroundRecordingID = backgroundRecordingID
        backgroundRecordingID = UIBackgroundTaskInvalid
        
        let cleanup = {
            do {
                try NSFileManager.defaultManager().removeItemAtURL(outputFileURL)
            } catch {
                
            }
            if currentBackgroundRecordingID != UIBackgroundTaskInvalid {
                UIApplication.sharedApplication().endBackgroundTask(currentBackgroundRecordingID)
            }
        }
        
        if error == nil {
            PHPhotoLibrary.requestAuthorization { status in
                guard status == .Authorized else { cleanup(); return }
                PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                    if #available(iOS 9.0, *) {
                        let options = PHAssetResourceCreationOptions()
                        options.shouldMoveFile = true
                        let changeRequest = PHAssetCreationRequest.creationRequestForAsset()
                        changeRequest.addResourceWithType(.Video, fileURL: outputFileURL, options: options)
                    } else {
                        // Fallback on earlier versions
                        PHAssetChangeRequest.creationRequestForAssetFromVideoAtFileURL(outputFileURL)
                    }
                    
                    }, completionHandler: { success, error in
                
                        if ( !success ) {
                            print( "Could not save movie to photo library: ", error )
                        }
                        cleanup()
                })
            }
        }else{
            print( "Could not save movie to photo library: ", error )
            cleanup()
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
