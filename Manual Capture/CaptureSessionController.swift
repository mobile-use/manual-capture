//
//  CaptureSessionController.swift
//  Capture
//
//  Created by Jean on 9/7/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

enum SessionError : ErrorType {
    case NoCameraForPosition
    case CameraInputError(InputError)
    case CameraAccessDenied
    case StillImageOutputError(OutputError)
}

enum InputError : ErrorType {
    case AccessDenied
    case CannotAddToSession
    case InitFailed(ErrorType?)
}

enum OutputError : ErrorType {
    case CannotAddToSession
}

protocol CaptureSessionControllerDelegate {
    func sessionControllerError(error: ErrorType)
    func sessionControllerNotification(notification:CSCNotification)
}

typealias KVOContext = UInt8

// value change type
enum CSCValue {
    enum Exposure {
        case ISO(Float), targetOffset(Float), duration(CMTime)
        case bias(Float)
        case durationAndISO(CMTime, Float)
        
        case minISO(Float), maxISO(Float)
        case minDuration(CMTime), maxDuration(CMTime)
    }
    case cameraLensPosition(Float)
    case cameraExposure(Exposure)
    case cameraWhiteBalanceGains(AVCaptureWhiteBalanceGains)
    case cameraZoomFactor(CGFloat), cameraZoomFactorRamp(CGFloat, Float)
    
    
    case cameraFocusMode(AVCaptureFocusMode)
    case cameraExposureMode(AVCaptureExposureMode)
    case cameraWhiteBalanceMode(AVCaptureWhiteBalanceMode)
    
    case cropAspectRatio(CSCAspectRatio)
}

// value set type
enum CSCSet {
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
    
    case cropAspectRatio(CSCAspectRatio)
}

/// value type key path is raw value
enum CSCValueType : String {
    case cameraLensPosition = "camera.lensPosition"
    case cameraExposureBias = "camera.exposureTargetBias"
    case cameraExposureISO = "camera.ISO"
    case cameraExposureTargetOffset = "camera.exposureTargetOffset"
    case cameraExposureDuation = "camera.exposureDuration"
    case cameraWhiteBalanceGains = "camera.deviceWhiteBalanceGains"
    case cameraZoomFactor = "camera.videoZoomFactor"
    
    case cameraFocusMode = "camera.focusMode"
    case cameraExposureMode = "camera.exposureMode"
    case cameraWhiteBalanceMode = "camera.whiteBalanceMode"
    
    case cropAspectRatio = "cropAspectRatio"

}

// notification type
enum CSCNotification {
    case capturingStillImage(Bool)
    case cameraSubjectAreaChange
    case sessionRunning(Bool)
    case change(CSCValue)
}

enum CSCNotificationType {
    case capturingStillImage
    case cameraSubjectAreaChange
    case sessionRunning(Bool)
    case change(CSCValueType)
}

func == (left: CSCAspectRatio, right: CSCAspectRatio) -> Bool {
    return (left.w == right.w) && (left.h == right.h)
}
func != (left: CSCAspectRatio, right: CSCAspectRatio) -> Bool {
    return !(left == right)
}

struct CSCAspectRatio : Equatable {
    var w: CGFloat
    var h: CGFloat
    var value: CGFloat {return w / h}
    init(_ w: CGFloat, _ h: CGFloat) {
        self.w = w
        self.h = h
    }
}

class CaptureSessionController: NSObject {
    //var notificationTypes: [CSCNotificationType]
    var notificationObservers: [ String : AnyObject? ] = [ : ]
    var context: [ String : KVOContext ] = [ : ]
    
    private var _isChanging = false
    
    let session: AVCaptureSession
    let sessionQueue: dispatch_queue_t
    let previewLayer: CapturePreviewLayer
    var camera: AVCaptureDevice!
    var cameraInput: AVCaptureDeviceInput!
    var stillImageOutput: AVCaptureStillImageOutput!
    
    //typealias AspectRatio = (w:CGFloat, h:CGFloat)
    var cropAspectRatio = CSCAspectRatio(16,9) {
        didSet{
            previewLayer.cropAspectRatio = cropAspectRatio.value
            sendNotification(.change(.cropAspectRatio(cropAspectRatio)), keyPath: "cropAspectRatio")
        }
    }
    var volumeButtonHandler: JPSVolumeButtonHandler!
    
    var delegate: CaptureSessionControllerDelegate?
    
    typealias ValueObserverBlock = (CSCValue) -> ()
    typealias KeyPath = String
    var valueObservingBlocks: [KeyPath : [String : ValueObserverBlock]] = [:]
    
    func setValueObservingBlockFor(type: CSCValueType, key: String, block: ValueObserverBlock) {
        let keypath = type.rawValue
        var blocks = valueObservingBlocks[keypath] ?? [:]
        blocks[key] = block
        valueObservingBlocks[keypath] = blocks
    }
    
    func removeValueObservingBlockFor(type: CSCValueType, key: String) {
        let keypath = type.rawValue
        valueObservingBlocks[keypath]?[key] = nil
    }
    
    
    override init(/*notificationTypes:[CSCNotificationType]*/) {
        //self.notificationTypes = notificationTypes
        session = AVCaptureSession()
        switch UIDevice.currentDevice().modelName {
            //case "iPhone 4", "iPhone 4s": session.sessionPreset = AVCaptureSessionPresetHigh
            default: session.sessionPreset = AVCaptureSessionPresetPhoto
        }
        sessionQueue = dispatch_queue_create("Capture Session", DISPATCH_QUEUE_SERIAL)
        previewLayer = CapturePreviewLayer(session: session)
        previewLayer.cropAspectRatio = cropAspectRatio.value
        super.init()
        
        let volumeButtonBlock:JPSVolumeButtonBlock = {[unowned self] in self.captureStillPhoto()}
        volumeButtonHandler = JPSVolumeButtonHandler(upBlock: volumeButtonBlock, downBlock: volumeButtonBlock)
        
        requestCameraAccess(){self.startCamera()}
    }
    
    private func requestCameraAccess(completionHandler:()->Void) {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo){(granted:Bool) -> Void in
            if granted {
                completionHandler()
            }else{
                self.handleError(SessionError.CameraAccessDenied)
            }
        }
    }
    
    func startCamera() {
        func addDevicesIfNeeded(){
            func addCameraFromPosition(position:AVCaptureDevicePosition) throws {
                guard let cameraFromPosition = position.device else {throw SessionError.NoCameraForPosition}
                camera = cameraFromPosition
            }
            func addInputFromCamera(camera:AVCaptureDevice) throws {
                do {    cameraInput = try AVCaptureDeviceInput(device: camera)  }
                catch {     throw SessionError.CameraInputError(.InitFailed(error))  }
                guard session.canAddInput(cameraInput) else { throw SessionError.CameraInputError(.CannotAddToSession) }
                session.addInput(cameraInput)
                
                previewLayer.connection.videoOrientation = AVCaptureVideoOrientation(ui:UIApplication.sharedApplication().statusBarOrientation)
                previewLayer.connection.preferredVideoStabilizationMode = .Auto//.Auto
            }
            func addStillImageOutput() throws {
                stillImageOutput = AVCaptureStillImageOutput()
                guard session.canAddOutput(stillImageOutput) else { throw SessionError.StillImageOutputError(.CannotAddToSession) }
                
                stillImageOutput.highResolutionStillImageOutputEnabled = true
                session.addOutput(stillImageOutput)
            }
            do {
                session.beginConfiguration()
                if camera == nil {try addCameraFromPosition(AVCaptureDevicePosition.Back)}
                if cameraInput == nil {try addInputFromCamera(camera)}
                if stillImageOutput == nil {try addStillImageOutput()}
                session.commitConfiguration()
            }
            catch{  self.handleError(error)    }
        }
        func startRunningSession() {
            dispatch_async(sessionQueue, {
                self.addObservers()
                self.session.startRunning()
            })
        }
        addDevicesIfNeeded()
        startRunningSession()
    }
    
    func handleError(error: ErrorType) {
        dispatch_async(dispatch_get_main_queue(), {
            self.delegate?.sessionControllerError(error)
            print(error)
        })
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        guard let newValue = change![NSKeyValueChangeNewKey], kp = keyPath /*where !_isChanging/*where context == &self.context[kp]!*/*/ else { return }
        
        var notification: CSCNotification?
        switch kp {
        case "stillImageOutput.capturingStillImage":
            guard let capturing = newValue.boolValue else { fatalError() }
            notification = .capturingStillImage(capturing)
        case "camera.adjustingFocus": break
        case "camera.adjustingExposure": break
            
        case "camera.focusMode":
            guard let intValue = newValue.integerValue, focusMode = AVCaptureFocusMode(rawValue: intValue) else { fatalError() }
            notification = .change(.cameraFocusMode(focusMode))
        case "camera.exposureMode":
            guard let intValue = newValue.integerValue, exposureMode = AVCaptureExposureMode(rawValue: intValue) else { fatalError() }
            notification = .change(.cameraExposureMode(exposureMode))
        case "camera.whiteBalanceMode":
            guard let intValue = newValue.integerValue, whiteBalanceMode = AVCaptureWhiteBalanceMode(rawValue: intValue) else { fatalError() }
            notification = .change(.cameraWhiteBalanceMode(whiteBalanceMode))
            
        case "camera.ISO":
            guard let iso = newValue.floatValue else { fatalError() }
            notification = .change(.cameraExposure(.ISO(iso)))
        case "camera.exposureTargetOffset":
            guard let exposureTargetOffset = newValue.floatValue else { fatalError() }
            notification = .change(.cameraExposure(.targetOffset(exposureTargetOffset)))
        case "camera.exposureDuration":
            guard let exposureDuration = newValue.CMTimeValue else { fatalError() }
            notification = .change(.cameraExposure(.duration(exposureDuration)))
        case "camera.deviceWhiteBalanceGains":
            guard let nsvalue = newValue as? NSValue else { fatalError() }
            var wbgains = self.camera.deviceWhiteBalanceGains
            nsvalue.getValue(&wbgains)
            notification = .change(.cameraWhiteBalanceGains(wbgains))
        case "camera.lensPosition":
            guard let lensPosition = newValue.floatValue else { fatalError() }
            notification = .change(.cameraLensPosition(lensPosition))
        default: break
        }
        
        guard let notif = notification else { return }
        sendNotification(notif, keyPath: kp)
    }
    
    private func sendNotification(notification: CSCNotification, keyPath: KeyPath? = nil) {
        dispatch_async( dispatch_get_main_queue(), {
            self.delegate?.sessionControllerNotification(notification)
            if let kp = keyPath {
                switch notification {
                case .change(let value):
                    self.valueObservingBlocks[kp]?.forEach {$1(value)}
                default: break
                }
            }
        })
    }
//
//    func beginChange(){self._isChanging = true}
//    func endChange(){self._isChanging = false}
    
    func set(set:CSCSet){
        let deviceConfig = {(config: () -> Void) -> Void in
            do {
                try self.camera.lockForConfiguration()
                config()
                self.camera.unlockForConfiguration()
            }
            catch { print(error) }
        }
        switch set {
        case .cameraFocusMode(let focusMode): deviceConfig(){self.camera.focusMode = focusMode}
        case .cameraExposureMode(let exposureMode): deviceConfig(){self.camera.exposureMode = exposureMode}
        case .cameraWhiteBalanceMode(let whiteBalanceMode): deviceConfig(){self.camera.whiteBalanceMode = whiteBalanceMode}
            
        case .cameraExposure(.durationAndISO(let duration, let ISO)):
            deviceConfig(){
                self.camera.setExposureModeCustomWithDuration(duration, ISO: ISO, completionHandler: nil)
            }

        case .cameraExposure(.bias(let bias)):
            deviceConfig(){
                self.camera.setExposureTargetBias(bias, completionHandler: nil)
            }
            
        case .cameraLensPosition(let lensPosition): deviceConfig(){ self.camera.setFocusModeLockedWithLensPosition(lensPosition, completionHandler: nil)}
            
        case .cameraWhiteBalanceGains(let wbgains): deviceConfig(){ self.camera.setWhiteBalanceModeLockedWithDeviceWhiteBalanceGains(wbgains, completionHandler: nil)}
            
        case .cameraZoomFactor(let zFactor): deviceConfig(){ self.camera.videoZoomFactor = zFactor }
        case .cameraZoomFactorRamp(let zFactor, let rate): deviceConfig(){ self.camera.rampToVideoZoomFactor(zFactor, withRate: rate) }
            
        case .cropAspectRatio(let aspectRatio): cropAspectRatio = aspectRatio
            
        }
    }
    
    func addObservers(){
        let keyPaths = [
            "stillImageOutput.capturingStillImage",
            
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
        for kp in keyPaths { self.observe(kp) }
        notificationObservers["RuntimeError"] = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionRuntimeErrorNotification, object: sessionQueue, queue: NSOperationQueue.mainQueue(), usingBlock: {
            [unowned self](note: NSNotification!) -> Void in
            dispatch_async(self.sessionQueue, {self.session.startRunning()})
            })
        notificationObservers["SubjectAreaChange"] = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureDeviceSubjectAreaDidChangeNotification, object: camera, queue: NSOperationQueue.mainQueue(), usingBlock: {
            [unowned self](note: NSNotification!) -> Void in
            self.delegate?.sessionControllerNotification(.cameraSubjectAreaChange)
            })
//        notificationObservers["CameraConnected"] = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureDeviceWasConnectedNotification, object: camera, queue: NSOperationQueue.mainQueue(), usingBlock: {
//            [unowned self](note: NSNotification!) -> Void in
//            self.delegate?.sessionControllerNotification(.cameraConnected(true))
//            })
//        notificationObservers["CameraDisonnected"] = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureDeviceWasDisconnectedNotification, object: camera, queue: NSOperationQueue.mainQueue(), usingBlock: {
//            [unowned self](note: NSNotification!) -> Void in
//            self.delegate?.sessionControllerNotification(.cameraConnected(false))
//            })
        notificationObservers["SessionStarted"] = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionDidStartRunningNotification, object: session, queue: NSOperationQueue.mainQueue(), usingBlock: {
            [unowned self](note: NSNotification!) -> Void in
            self.delegate?.sessionControllerNotification(.sessionRunning(true))
            })
        notificationObservers["SessionStopped"] = NSNotificationCenter.defaultCenter().addObserverForName(AVCaptureSessionDidStopRunningNotification, object: session, queue: NSOperationQueue.mainQueue(), usingBlock: {
            [unowned self](note: NSNotification!) -> Void in
            self.delegate?.sessionControllerNotification(.sessionRunning(false))
            })
    }
    func removeObservers(){
        for (kp, _) in context {
            removeObserver(self, forKeyPath: kp, context: &context[kp]!)
        }
        for (_, observer) in notificationObservers {
            NSNotificationCenter.defaultCenter().removeObserver(observer!)
        }
    }
    
    func observe(keyPath: String){
        context[keyPath] = KVOContext()
        addObserver(self, forKeyPath: keyPath, options: .New, context: &self.context[keyPath]!)
    }
    
    func captureStillPhoto() {
        dispatch_async(sessionQueue, {
            func captureError(errorText:String) {
                UIAlertView(title: "Capture Error", message: errorText, delegate: nil, cancelButtonTitle: "Dismiss").show()
            }
            
            let connection = self.stillImageOutput.connectionWithMediaType(AVMediaTypeVideo)
            if connection != nil &&  self.previewLayer.connection != nil{
                // Update the orientation on the still image output video connection before capturing.
                connection.videoOrientation = self.previewLayer.connection.videoOrientation
                // Flash set to Auto for Still Capture
                //self.setFlashMode
                self.stillImageOutput.captureStillImageAsynchronouslyFromConnection(connection){
                    (imageSampleBuffer, error) in
                    
                    if((imageSampleBuffer) != nil){
                        let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                        let image: UIImage = UIImage(data: imageData)!
                        
                        let ratioW = image.size.height * self.cropAspectRatio.value
                        let ratioH = image.size.width / self.cropAspectRatio.value
                        
                        let imageRect = CGRectMake(0, 0, image.size.width, image.size.height)
                        let cropRect = CGRectInset(
                            imageRect,
                            max(image.size.width - ratioW, 0) / 2 , // clipped width
                            max(image.size.height - ratioH, 0) / 2 // clipped height
                        )
                        let croppedImage = CGImageCreateWithImageInRect(image.CGImage, cropRect)
                        
                        //                        let orientation = image.imageOrientation
                        //                        self.delegate?.didCaptureImage(CGImageOrientation(image.CGImage!, orientation: orientation))
                        ALAssetsLibrary().writeImageToSavedPhotosAlbum(croppedImage, orientation: ALAssetOrientation(rawValue: image.imageOrientation.rawValue)!, completionBlock: { (path:NSURL!, error:NSError!) -> Void in
                            if error != nil {
                                captureError("Couldn't save photo.\n\(error.localizedRecoverySuggestion ?? error.localizedFailureReason ?? error.localizedDescription)")
                            }
                            //self.setFeedbackButtonHidden(false, delay: 60.0)
                            // photo saved
                            //self.controlView.guideLabel.text = "Photo Saved"
                            print("\(path)")
                        })
                    }
                    else{print("imageSampleBuffer == nil \n could not complete captureStillPhoto() \n captureStillPhoto()");captureError("Sample Buffer was nil")}
                }
            }
            else{print("connection or self.previewView.connection == nil \n could not complete captureStillPhoto() \n captureStillPhoto()");captureError("Connection was nil")}
        })
    }
    
    deinit {
        removeObservers()
    }
}
