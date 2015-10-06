//
//  TestControlView.swift
//  Capture
//
//  Created by Jean on 9/16/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation

let kExposureDurationPower: Double = 6

protocol ControlViewDelegate {
    func showPhotoBrowser()
}

class TestControlView: UIView, CaptureSessionControllerDelegate, UIGestureRecognizerDelegate {
    
    var delegate: ControlViewDelegate?
    var sessionController: CaptureSessionController
    var volumeButtonHandler: JPSVolumeButtonHandler!
    
    override init(frame:CGRect) {
        sessionController = CaptureSessionController()
        
        currentLayoutMode = .Initial
        // needs self to set
        exitLayoutPerformer = {}
        exitLayoutCompleter = {$0}
        
        super.init(frame:frame)
        
        exitLayoutPerformer = {[unowned self] in
            self.focusSlider.alpha = 0.0
            self.tempSlider.alpha = 0.0
            self.ISOSlider.alpha = 0.0
            self.exposureDurationSlider.alpha = 0.0
            self.shutterButton.enabled = true
            self.shutterButton.alpha = 1.0
        }
        exitLayoutCompleter = {(_) in}
        
        sessionController.delegate = self
        sessionController.previewLayer.backgroundColor = UIColor.blackColor().CGColor
        //sessionController.previewLayer.opacity = 0.0
        layer.addSublayer(sessionController.previewLayer)
        sessionController.previewLayer.frame = bounds
        
        self.layer.opacity = 0.0
        self.backgroundColor = UIColor.blackColor()
        
        initControls()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gesture Related
    
    override func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        super.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.delegate = self
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.view!.isKindOfClass(UIButton) {
            return false// allows button to recieve touch down for button pressed look
        }
        return true
    }
    
    func handleTapGesture(tapGesture: UITapGestureRecognizer){
        switch tapGesture.numberOfTapsRequired {
        case 1 where tapGesture.numberOfTouchesRequired == 1 : switchToLayout(.Normal, nil)
        case 2:
            if sessionController.cropAspectRatio == CSCAspectRatio(16, 9) {
                sessionController.cropAspectRatio = CSCAspectRatio(4, 3)
            }else if sessionController.cropAspectRatio == CSCAspectRatio(4, 3) {
                sessionController.cropAspectRatio = CSCAspectRatio(1, 1)
            }else if sessionController.cropAspectRatio == CSCAspectRatio(1, 1) {
                sessionController.cropAspectRatio = CSCAspectRatio(3, 2)
            }else{
                sessionController.cropAspectRatio = CSCAspectRatio(16, 9)
            }
            //warpSpeedReverses = !warpSpeedReverses
            
//        UIView.animateWithDuration(0.2, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.alpha = 0.0 }) { (_) in
//            UIView.animateWithDuration(0.2, delay: 0.6, options: UIViewAnimationOptions.CurveLinear, animations: { self.alpha = 1.0 }) { (_) in
//            }
//            }
            case 1 where tapGesture.numberOfTouchesRequired == 2 : delegate?.showPhotoBrowser()
            
        default:break
        }
    }
    
    private func startBoundsForType(sbType:StartBoundType, edgeDistance: CGFloat, gestureView: UIView) -> CGRect {
        let W = gestureView.frame.width
        let H = gestureView.frame.height
        let E = edgeDistance
        switch sbType.edge {
        case .AlongTop: return CGRectMake(0, 0, W, E)
        case .AlongRight: return CGRectMake(W - E, 0, E, H)
        case .AlongBottom: return CGRectMake(0, H - E, W, E)
        case .AlongLeft: return CGRectMake(0, 0, E, H)
        }
    }
//    private func sliderBoundsForType(spType:SliderPositionType) -> CGRect {
//        let W = frame.width
//        let H = frame.height
//        
//        var xMargin: CGFloat = 10
//        var yMargin: CGFloat = 10
//        let pRect = sessionController.previewLayer.rectForMetadataOutputRectOfInterest(CGRectMake(0, 0, 1, 1))
//        if pRect.width == frame.width || pRect.height == frame.height  {
//            xMargin += pRect.origin.x
//            yMargin += pRect.origin.y
//        }
//        let t: CGFloat = (sliders[spType]?.alpha ?? 0.0 == 0.0) ? -10 : 80
//        let E: CGFloat =  (spType == .Top || spType == .Bottom) ? yMargin + t : xMargin + t + 40
//        
//        switch spType {
//        case .Top: return CGRectMake(0, 0, W , E)
//        case .Right: return CGRectMake(W - E, 0, E, H)
//        case .Bottom: return CGRectMake(0, H - E, W, E)
//        case .Left: return CGRectMake(0, 0, E, H)
//        }
//    }
    
    enum StartBoundType : String {
        case RightAlongTop = "RightAlongTop",
        LeftAlongTop = "LeftAlongTop",
        UpAlongRight = "UpAlongRight",
        DownAlongRight = "DownAlongRight",
        LeftAlongBottom = "LeftAlongBottom",
        RightAlongBottom = "RightAlongBottom",
        DownAlongLeft = "DownAlongLeft",
        UpAlongLeft = "UpAlongLeft"
        
        enum Direction : String {
            case Right = "Right",
            Left = "Left",
            Up = "Up",
            Down = "Down"
        }
        enum Edge : String {
            case AlongTop = "AlongTop",
            AlongRight = "AlongRight",
            AlongBottom = "AlongBottom",
            AlongLeft = "AlongLeft"
        }
        var direction: Direction {
            switch self {
            case .UpAlongLeft, .UpAlongRight: return .Up
            case .RightAlongTop, .RightAlongBottom: return .Right
            case .DownAlongLeft, .DownAlongRight: return .Down
            case .LeftAlongBottom, .LeftAlongTop: return .Left
            }
        }
        var edge: Edge {
            switch self {
            case .RightAlongTop, .LeftAlongTop: return .AlongTop
            case .UpAlongRight, .DownAlongRight: return .AlongRight
            case .RightAlongBottom, .LeftAlongBottom: return .AlongBottom
            case .UpAlongLeft, .DownAlongLeft: return .AlongLeft
            }
        }
//        func sDirection() -> Slider<>.Direction {
//            switch direction {
//            case .Up: return .Up
//            case .Right: return .Right
//            case .Down: return .Down
//            case .Left: return .Left
//            }
//        }
    }

    // MARK: UI
    // MARK: |-- Buttons
    var shutterButton = UIButton.shutterButton()
    var autoButton = UIButton(type: .Custom)
    
    // MARK: Actions
    
    func shutterPressed() {
        sessionController.captureStillPhoto()
    }
    func auto(){
        switch currentLayoutMode {
        case .Focus: sessionController.set(.cameraFocusMode(.ContinuousAutoFocus))
        case .Exposure: sessionController.set(.cameraExposureMode(.ContinuousAutoExposure))
        case .WhiteBalance: sessionController.set(.cameraWhiteBalanceMode(.ContinuousAutoWhiteBalance))
        default: break
        }
    }
    
    // MARK: CaptureSessionControllerDelegate
    
    func sessionControllerError(error: ErrorType) {
        print(error)
    }
    func sessionControllerNotification(notification: CSCNotification) {
        switch notification {
        case .capturingStillImage(true):
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            self.layer.opacity = 0.0
            CATransaction.commit()
            UIView.animateWithDuration(0.25, animations: {
                self.layer.opacity = 1.0
            })
            
        case .sessionRunning(true):
            
            configControls()
            UIView.animateWithDuration(0.6, animations: {
                //self.sessionController.previewLayer.opacity = 1.0
                self.layer.opacity = 1.0
                }){$0; if(self.currentLayoutMode == .Initial){ self.switchToLayout(.Normal, 0.2) }}
            
        case .sessionRunning(false):
            
            switchToLayout(.Initial, nil)
            //self.layer.opacity = 0.0
//            UIView.animateWithDuration(1.0, animations: {
//                //self.sessionController.previewLayer.opacity = 0.0
//                self.layer.opacity = 0.0
//            })
            
        // camera properties
        case .change(.cameraExposure(.ISO(let ISO))):
            
            guard ISOSlider.state.hasProperty(.ComputerControlled) else { break }
            ISOSlider.value = ISO
            
        case .change(.cameraLensPosition(let lensPosition)):
            
            guard focusSlider.state.hasProperty(.ComputerControlled) else { break }
            focusSlider.value = lensPosition
            
        case .change(.cameraExposure(.duration(let duration))):
            
            guard exposureDurationSlider.state.hasProperty(.ComputerControlled) else { break }
            exposureDurationSlider.value = duration
            
        case .change(.cameraWhiteBalanceGains(let wbgains)):
            
            guard tempSlider.state.hasProperty(.ComputerControlled) else { break }
            let temperatureAndTint = self.sessionController.camera.temperatureAndTintValuesForDeviceWhiteBalanceGains(wbgains)
            tempSlider.value = temperatureAndTint.temperature
            
        // camera modes
        case .change(.cameraFocusMode(let focusMode)):
            
            let computerControlled = ( focusMode != .Locked )
            focusSlider.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&focusSlider.state)
            updateAutoButtonTitle()
            
        case .change(.cameraExposureMode(let exposureMode)):
            
            let computerControlled = ( exposureMode != .Locked && exposureMode != .Custom )
            ISOSlider.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&ISOSlider.state)
            exposureDurationSlider.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&exposureDurationSlider.state)
            updateAutoButtonTitle()
            
        case .change(.cameraWhiteBalanceMode(let whiteBalanceMode)):
            
            let computerControlled = ( whiteBalanceMode != .Locked )
            tempSlider.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&tempSlider.state)
            updateAutoButtonTitle()
            
        case .change(.cameraExposure(.targetOffset(_))): break // stop print messages for these
        default: print(notification) // break
        }
    }
    
    // MARK: |-- Sliders
    
    enum SliderPositionType {
        case Top, Right, Bottom, Left
    }
    
    var sliders: [ SliderPositionType : Slider ] = [ : ]
    
    var zoomSlider: SmartSlider<Float>!
    var focusSlider: SmartSlider<Float>!
    var tempSlider: SmartSlider<Float>!
    var ISOSlider: SmartSlider<Float>!
    var exposureDurationSlider: SmartSlider<CMTime>!
    
    // MARK: Control Related
    
    func initControls(){
        let tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        addGestureRecognizer(tapGesture)
        
        let tap2Gesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tap2Gesture.numberOfTapsRequired = 2
        addGestureRecognizer(tap2Gesture)
        
        let tap3Gesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        tap3Gesture.numberOfTouchesRequired = 2
        addGestureRecognizer(tap3Gesture)
        
        zoomSlider = SmartSlider<Float>(
            glyph: ManualCaptureGlyph(type: .Focus),
            direction: .Right,
            startBounds: {[unowned self] in self.startBoundsForType(.UpAlongLeft, edgeDistance: 160, gestureView: self)},
            sliderBounds: nil,//{[unowned self] in self.sliderBoundsForType(.Left)},
            25
        )
        zoomSlider.initialSensitivity = 0.5
        zoomSlider.labelTextForValue = {
            if $1 {
                //                let base: Float = 2.0
                //                let c: Float = 100
                //                let power = round( log10($0 / c) / log10(base) )
                //                let int = Int( pow(base, power) * 100 )
                let int = Int( round($0 * 25) / 25 )
                return "\(int)"
            }else{
                return "\(Int(round($0 * 2) / 2 ))"
            }
        }
        zoomSlider.actionProgressChanged = {[weak self](slider) in
            self?.sessionController.set(CSCSet.cameraZoomFactor(CGFloat(slider.value)))
        }
        zoomSlider.actionProgressStarted = {[weak self](slider) in self?.switchToLayout(.Normal, nil)}
        zoomSlider.alpha = 0.0
        zoomSlider.addPDHandler("Scale", handler: PDScale(self))
        
        addSubview(zoomSlider)
        
        focusSlider = SmartSlider<Float>(
            glyph: ManualCaptureGlyph(type: .Focus),
            direction: .Right,
            startBounds: {[unowned self] in self.startBoundsForType(.RightAlongBottom, edgeDistance: 160, gestureView: self)},
            sliderBounds: nil//{[unowned self] in self.sliderBoundsForType(.Bottom)}
        )
        focusSlider.initialSensitivity = 0.55
        focusSlider.labelTextForValue = {"\(Int(round($0 * 100 / ($1 ? 10 : 1) ) * ($1 ? 10 : 1) ))%"
        }
        focusSlider.actionProgressChanged = {[weak self](slider) in
            self?.sessionController.set(.cameraLensPosition(slider.value))
        }
        focusSlider.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.Focus, nil) }
        
        tempSlider = SmartSlider<Float>(
            glyph: ManualCaptureGlyph(type: .Temperature),
            direction: .Right,
            startBounds: {[unowned self] in self.startBoundsForType(.RightAlongTop, edgeDistance: 160, gestureView: self)},
            sliderBounds: nil//{[unowned self] in self.sliderBoundsForType(.Top)}
        )
        tempSlider.initialSensitivity = 0.25
        tempSlider.labelTextForValue = {"\(Int( round( $0 / ($1 ? 100 : 1) ) * ($1 ? 100 : 1) ))k"}
        tempSlider.actionProgressChanged = {[weak self](slider) in
            let temperatureAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: slider.value, tint: 0)
            let wbgains = self!._normalizeGainsForTemperatureAndTint(temperatureAndTint)
            self?.sessionController.set(.cameraWhiteBalanceGains(wbgains))
        }
        tempSlider.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.WhiteBalance, nil) }
        
        ISOSlider = SmartSlider<Float>(
            glyph: ManualCaptureGlyph(type: .ISO),
            direction: .Up,
            startBounds: {[unowned self] in self.startBoundsForType(.UpAlongLeft, edgeDistance: 240, gestureView: self)},
            sliderBounds: nil,//{[unowned self] in self.sliderBoundsForType(.Left)},
            25
        )
        ISOSlider.initialSensitivity = 0.5
        ISOSlider.labelTextForValue = {
            if $1 {
//                let base: Float = 2.0
//                let c: Float = 100
//                let power = round( log10($0 / c) / log10(base) )
//                let int = Int( pow(base, power) * 100 )
                let int = Int( round($0 / 25) * 25)
                return "\(int)"
            }else{
                return "\(Int(round($0)))"
            }
        }
        ISOSlider.actionProgressChanged = {[weak self](slider) in
            self?.sessionController.set(.cameraExposure(.durationAndISO(self!.exposureDurationSlider.value, self!.ISOSlider.value)))
        }
        ISOSlider.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.Exposure, nil) }
        ISOSlider.knobLayer.positionType = .Left
        
        exposureDurationSlider = SmartSlider<CMTime>(
            glyph: ManualCaptureGlyph(type: .ExposureDuration),
            direction: .Up,
            startBounds: {[unowned self] in self.startBoundsForType(.UpAlongRight, edgeDistance: 240, gestureView: self)},
            sliderBounds: nil,//{[unowned self] in self.sliderBoundsForType(.Right)},
            52
            )
        exposureDurationSlider.initialSensitivity = 0.2
        exposureDurationSlider.labelTextForValue = {
            if($1){
                return roundExposureDurationString($0)
            }else {
                return roundExposureDurationStringFast($0)
            }
        }
        exposureDurationSlider.actionProgressChanged = {[weak self](slider) in
            self?.sessionController.set(.cameraExposure(.durationAndISO(self!.exposureDurationSlider.value, self!.ISOSlider.value)))
        }
        exposureDurationSlider.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.Exposure, nil) }
        exposureDurationSlider.knobLayer.positionType = .Right
        //exposureDurationSlider.knobLayer.anchorPoint = CGPoint(x: 1.0 - (ISOSlider.knobLayer.frame.height / (2 * ISOSlider.knobLayer.frame.width)), y: 0.5)
        
        sliders[.Right] = exposureDurationSlider
        sliders[.Left] = ISOSlider
        sliders[.Bottom] = focusSlider
        sliders[.Top] = tempSlider
        
        shutterButton.addTarget(self, action: "shutterPressed", forControlEvents: UIControlEvents.TouchUpInside)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.enabled = false
        shutterButton.alpha = 0.0
        addSubview(shutterButton)
        
        autoButton.addTarget(self, action: "auto", forControlEvents: UIControlEvents.TouchUpInside)
        autoButton.setTitle("", forState: .Normal)
        autoButton.translatesAutoresizingMaskIntoConstraints = false
        autoButton.layer.shadowColor = kCaptureTintColor.CGColor//UIColor.blackColor().CGColor
        autoButton.layer.shadowOffset = CGSizeMake(0.5, 0.5)
        autoButton.layer.shadowOpacity = 0.75
        autoButton.layer.shadowRadius = 0.0
        autoButton.alpha = 0.0
        
        //autoButton.enabled = false
        addSubview(autoButton)
        
        for (key, slider) in sliders {
            slider.translatesAutoresizingMaskIntoConstraints = false
            addSubview(slider)
            addConstraints(createConstraintsForKey(.Slider(key)))
        }
        
        addConstraintsForKeys([.AutoButton, .ShutterButton])
        
        // switchToLayout(.Normal)
    }
    func configControls(){
//        CATransaction.begin()
//        CATransaction.disableActions()
//        updateConstraintsForKeys([.Slider(.Top), .Slider(.Bottom), .Slider(.Left), .Slider(.Right), .AutoButton, .ShutterButton])
//        CATransaction.commit()
        
        if let pdscale = zoomSlider.pdHandlers["Scale"] as? PDScale {
            pdscale.currentScale = {[unowned self] in self.sessionController.camera.videoZoomFactor }
            pdscale.maxScale = sessionController.camera.activeFormat.videoMaxZoomFactor
        }
        zoomSlider.vpHandler = VPFloatHandler(start: 1.0, end: Float(sessionController.camera.activeFormat.videoMaxZoomFactor))
        
        
        focusSlider.vpHandler = VPFloatHandler(start: 0.0, end: 1.0)
        tempSlider.vpHandler = VPFloatHandler(start: 2000, end: 8000)
        ISOSlider.vpHandler = VPFloatHandler(start: sessionController.camera.activeFormat.minISO, end: sessionController.camera.activeFormat.maxISO)

        let vfp: (progress:Float) -> CMTime = {
            let p = pow( Double($0), kExposureDurationPower ); // Apply power function to expand slider's low-end range
            let minDurationSeconds = max(CMTimeGetSeconds(self.sessionController.camera.activeFormat.minExposureDuration), 1 / 16000 )
            let maxDurationSeconds = CMTimeGetSeconds( self.sessionController.camera.activeFormat.maxExposureDuration )
            let newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds; // Scale from 0-1 slider range to actual duration
            let t = CMTimeMakeWithSeconds( newDurationSeconds, 1000*1000*1000 )
            return t
        }
        let pfv: (CMTime) -> Float = {
            let time: CMTime = $0
            var doubleValue: Double = CMTimeGetSeconds(time)
            let minDurationSeconds: Double = CMTimeGetSeconds( self.sessionController.camera.activeFormat.minExposureDuration )
            let maxDurationSeconds: Double = CMTimeGetSeconds( self.sessionController.camera.activeFormat.maxExposureDuration )
            doubleValue = max(minDurationSeconds, min(doubleValue, maxDurationSeconds))
            let p: Double = (doubleValue - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds )// Scale to 0-1
            return Float(pow( p, 1/kExposureDurationPower))
        }
        exposureDurationSlider.vpHandler = VPHandler(pfv: pfv, vfp: vfp)
        
        focusSlider.value = sessionController.camera.lensPosition
        let tt = sessionController.camera.temperatureAndTintValuesForDeviceWhiteBalanceGains(sessionController.camera.deviceWhiteBalanceGains)
        tempSlider.value = tt.temperature
        ISOSlider.value = sessionController.camera.ISO
        exposureDurationSlider.value = sessionController.camera.exposureDuration
    }
    func updateAutoButtonTitle() {
        let c = sessionController.camera
        let f = c.focusMode, e = c.exposureMode, wb = c.whiteBalanceMode
        
        var text = ""
        switch currentLayoutMode {
        case .Focus where f == .Locked : text = "Manual Focus ❌"
        case .Exposure where e == .Locked || e == .Custom : text = "Manual Exposure ❌"
        case .WhiteBalance where wb == .Locked : text = "Manual WB ❌"
        default: break
        }
        
        autoButton.setTitle( text, forState: .Normal )
    }
    
    // MARK: Layout Related
    
    private enum LayoutMode {
        case Initial, Normal, Focus, Exposure, WhiteBalance, Fullscreen
    }
    
    private typealias LayoutPerformer = () -> Void
    private typealias LayoutCompleter = (Bool) -> Void
    
    private var exitLayoutPerformer: LayoutPerformer
    private var exitLayoutCompleter: LayoutCompleter
    private var currentLayoutMode:LayoutMode
    
    private func switchToLayout(layoutMode:LayoutMode, _ duration: NSTimeInterval?) {
        guard currentLayoutMode != layoutMode else {return}
        UIView.animateWithDuration(duration ?? 0.2, animations: exitLayoutPerformer, completion: exitLayoutCompleter)
        currentLayoutMode = layoutMode
        updateAutoButtonTitle()
        
        var entranceLayoutPerformer: LayoutPerformer
        var entranceLayoutCompleter: LayoutCompleter
        switch layoutMode {
        case .Initial:
            entranceLayoutPerformer = {}
            entranceLayoutCompleter = {$0}
            exitLayoutPerformer = {[unowned self] in
                self.focusSlider.alpha = 0.0
                self.tempSlider.alpha = 0.0
                self.ISOSlider.alpha = 0.0
                self.exposureDurationSlider.alpha = 0.0
                self.shutterButton.enabled = true
                self.shutterButton.alpha = 1.0
            }
            exitLayoutCompleter = {(_) in}
        case .Normal:
            entranceLayoutPerformer = {[unowned self] in self.shutterButton.enabled = true; self.shutterButton.alpha = 1.0; self.autoButton.alpha = 0.0}
            entranceLayoutCompleter = {$0}
            exitLayoutPerformer = {[unowned self] in self.shutterButton.enabled = false; self.shutterButton.alpha = 0.15; self.autoButton.alpha = 1.0}
            exitLayoutCompleter = {$0}
        case .Focus:
            entranceLayoutPerformer = {[unowned self] in self.focusSlider.hidden = false; self.focusSlider.alpha = 1.0}
            entranceLayoutCompleter = {$0}
            exitLayoutPerformer = {[unowned self] in self.focusSlider.alpha = 0.0}
            exitLayoutCompleter = {[unowned self] (_) in self.focusSlider.hidden = true}
        case .Exposure:
            entranceLayoutPerformer = {[unowned self] in
                self.ISOSlider.hidden = false; self.ISOSlider.alpha = 1.0
                self.exposureDurationSlider.hidden = false; self.exposureDurationSlider.alpha = 1.0
            }
            entranceLayoutCompleter = {$0}
            exitLayoutPerformer = {[unowned self] in
                self.ISOSlider.alpha = 0.0; self.exposureDurationSlider.alpha = 0.0
            }
            exitLayoutCompleter = {[unowned self] (_) in
                self.ISOSlider.hidden = true; self.exposureDurationSlider.hidden = true
            }
        case .WhiteBalance:
            entranceLayoutPerformer = {[unowned self] in self.tempSlider.hidden = false; self.tempSlider.alpha = 1.0}
            entranceLayoutCompleter = {$0}
            exitLayoutPerformer = {[unowned self] in self.tempSlider.alpha = 0.0}
            exitLayoutCompleter = {[unowned self] (_) in self.tempSlider.hidden = true}
        case .Fullscreen:
            entranceLayoutPerformer = {}
            entranceLayoutCompleter = {$0}
            exitLayoutPerformer = {}
            exitLayoutCompleter = {$0}
        }
        
        UIView.animateWithDuration(duration ?? 0.2, animations: entranceLayoutPerformer, completion: entranceLayoutCompleter)
    }
    
    override var bounds: CGRect {
        didSet {
            guard bounds != oldValue else { return }
            sessionController.previewLayer.frame = bounds
            updateConstraintsForKeys([.Slider(.Top), .Slider(.Bottom), .Slider(.Left), .Slider(.Right), .AutoButton, .ShutterButton])
        }
    }
    
    enum ConstraintKey : CustomStringConvertible {
        var description : String {
            switch self {
                // Use Internationalization, as appropriate.
            case .Slider(let pType):
                switch pType {
                case .Top: return "Slider(Top)"
                case .Right: return "Slider(Right)"
                case .Bottom: return "Slider(Bottom)"
                case .Left: return "Slider(Left)"
                }
            case .AutoButton: return "AutoButton";
            case .ShutterButton: return "ShutterButton";
            }
        }
        case Slider(SliderPositionType)
        case ShutterButton
        case AutoButton
    }
    func createConstraintsForKey(key:ConstraintKey) -> [NSLayoutConstraint] {
        var constraints: [NSLayoutConstraint] = []
        let sDistance = kSliderKnobMargin + kSliderKnobRadius + 2
        
        let xMargin: CGFloat = 10
        let yMargin: CGFloat = 10
//        let pRect = sessionController.previewLayer.frame
//        if pRect.width == frame.width || pRect.height == frame.height  {
//            xMargin += pRect.origin.x
//            yMargin += pRect.origin.y
//        }
        
        let mx = 2 * sDistance + xMargin
        let my = 2 * sDistance + yMargin
        
        switch key {
        case .AutoButton:
            let sHeight = my + 5
            let centerXConstraint = NSLayoutConstraint(item: autoButton, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            let centerYConstraint = NSLayoutConstraint(item: autoButton, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -sHeight)
            constraints.appendContentsOf([centerXConstraint])
            constraints.appendContentsOf([centerYConstraint])
        case .ShutterButton:
            let sWidth = xMargin
            let centerYConstraint = NSLayoutConstraint(item: shutterButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            let centerXConstraint = NSLayoutConstraint(item: shutterButton, attribute: NSLayoutAttribute.RightMargin, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.RightMargin, multiplier: 1, constant: -sWidth)
            constraints.appendContentsOf([centerXConstraint])
            constraints.appendContentsOf([centerYConstraint])
            
        case .Slider(.Left):
            guard let slider = sliders[.Left] else { break }
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-x-[S]", options: .DirectionLeftToRight, metrics: ["x": xMargin], views: ["S":slider])
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-m-[S]-m-|", options: .DirectionLeftToRight, metrics: ["m": my], views: ["S":slider])
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
        case .Slider(.Right):
            guard let slider = sliders[.Right] else { break }
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[S]-x-|", options: .DirectionLeftToRight, metrics: ["x": xMargin], views: ["S":slider])
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-m-[S]-m-|", options: .DirectionLeftToRight, metrics: ["m": my], views: ["S":slider])
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
        case .Slider(.Bottom):
            guard let slider = sliders[.Bottom] else { break }
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[S]-y-|", options: .DirectionLeftToRight, metrics: ["y": yMargin], views: ["S":slider])
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-m-[S]-m-|", options: .DirectionLeftToRight, metrics: ["m": mx], views: ["S":slider])
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
        case .Slider(.Top):
            guard let slider = sliders[.Top] else { break }
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-y-[S]", options: .DirectionLeftToRight, metrics: ["y": yMargin], views: ["S":slider])
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-m-[S]-m-|", options: .DirectionLeftToRight, metrics: ["m": mx], views: ["S":slider])
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
        }
        for c in constraints { c.identifier = key.description }
        return constraints
    }
    func addConstraintsForKeys(keys:[ConstraintKey]) {
        for key in keys {
            addConstraints(createConstraintsForKey(key))
        }
    }
    func removeConstraintsForKeys(keys:[ConstraintKey]) {
        removeConstraints(getConstraintsForKeys(keys))
    }
    func getConstraintsForKeys(keys:[ConstraintKey]) -> [NSLayoutConstraint]{
        return constraints.filter {
            guard let id = $0.identifier else { return false }
            for key in keys { if key.description == id { return true } }
            return false
        }
    }
    func updateConstraintsForKeys(keys:[ConstraintKey]) {
        removeConstraintsForKeys(keys)
        addConstraintsForKeys(keys)
    }
    
    // MARK: Utilities
    
    private func _normalizeGains(var g:AVCaptureWhiteBalanceGains) -> AVCaptureWhiteBalanceGains{
        guard let d = sessionController.camera else {fatalError()}
        let maxG = d.maxWhiteBalanceGain - 0.001
        g.redGain = max( 1.0, g.redGain )
        g.greenGain = max( 1.0, g.greenGain )
        g.blueGain = max( 1.0, g.blueGain )
        g.redGain = min( maxG, g.redGain )
        g.greenGain = min( maxG, g.greenGain )
        g.blueGain = min( maxG, g.blueGain )
        return g
    }
    
    /// previous tint and temp
    
    private var _ptt:AVCaptureWhiteBalanceTemperatureAndTintValues? = nil
    private func _normalizeGainsForTemperatureAndTint(tt:AVCaptureWhiteBalanceTemperatureAndTintValues) -> AVCaptureWhiteBalanceGains{
        guard let d = sessionController.camera else {fatalError()}
        var g = d.deviceWhiteBalanceGainsForTemperatureAndTintValues(tt)
        if !_gainsInRange(g){
            if _ptt != nil {
                let dTemp = tt.temperature - _ptt!.temperature
                let dTint = tt.tint - _ptt!.tint
                var eTint = round(tt.tint)
                var eTemperature = round(tt.temperature)
                var i = 0
                var eGains: AVCaptureWhiteBalanceGains = d.deviceWhiteBalanceGainsForTemperatureAndTintValues(tt)
                
                if abs(dTemp) > abs(dTint) {
                    while !_gainsInRange(eGains) {
                        let nTT = d.temperatureAndTintValuesForDeviceWhiteBalanceGains(_normalizeGains(eGains))
                        let eTintNew = round(nTT.tint)
                        let eTemperatureNew = round(nTT.temperature)
                        //prioritize
                        if eTint != eTintNew {eTint = eTintNew}
                        else if eTemperature != eTemperatureNew {eTemperature = eTemperatureNew}
                        if i > 3 || (eTint == eTintNew && eTemperature == eTemperatureNew) {
                            eGains = _normalizeGains(eGains)
                        }else{
                            eGains = d.deviceWhiteBalanceGainsForTemperatureAndTintValues(AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: eTemperature, tint: eTint))
                        }
                        i++
                    }
                    g = eGains
                }else if abs(dTemp) < abs(dTint) {
                    while !_gainsInRange(eGains) {
                        let nTT = d.temperatureAndTintValuesForDeviceWhiteBalanceGains(_normalizeGains(eGains))
                        let eTintNew = round(nTT.tint)
                        let eTemperatureNew = round(nTT.temperature)
                        if eTemperature != eTemperatureNew {eTemperature = eTemperatureNew}
                        else if eTint != eTintNew {eTint = eTintNew}
                        if i > 3 || (eTint == eTintNew && eTemperature == eTemperatureNew) {
                            eGains = _normalizeGains(eGains)
                        }else{
                            eGains = d.deviceWhiteBalanceGainsForTemperatureAndTintValues(AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: eTemperature, tint: eTint))
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
    private func _gainsInRange(gains:AVCaptureWhiteBalanceGains) -> Bool {
        guard let d = sessionController.camera else {fatalError()}
        let maxGain = d.maxWhiteBalanceGain
        let redIsFine = (1.0 <= gains.redGain && gains.redGain <= maxGain)
        let greenIsFine = (1.0 <= gains.greenGain && gains.greenGain <= maxGain)
        let blueIsFine = (1.0 <= gains.blueGain && gains.blueGain <= maxGain)
        return redIsFine && greenIsFine && blueIsFine
    }
}
