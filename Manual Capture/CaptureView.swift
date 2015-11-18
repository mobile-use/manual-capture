//
//  CaptureView.swift
//  Capture
//
//  Created by Jean on 9/16/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation

private let kExposureDurationPower: Double = 6
private let kMainSliderHideDelay: Double = 1.0

protocol CaptureViewDelegate {
    func showPhotoBrowser()
}

class CaptureView: UIView, CSControllerDelegate, UIGestureRecognizerDelegate {
    
    var delegate: CaptureViewDelegate?
    var sessionController: CSController
    
    override init(frame:CGRect) {
        sessionController = CSController()
        
        super.init(frame:frame)
        
        sessionController.delegate = self
        
        if kIsDemoMode { // For screen shots
            let sampleImageLayer = CALayer()
            sampleImageLayer.contentsGravity = kCAGravityResizeAspect
            sampleImageLayer.contents = UIImage(named: "SampleImage.JPG")?.CGImage
            sampleImageLayer.frame = bounds
            
            layer.addSublayer(sampleImageLayer)
        }else{
            sessionController.previewLayer.backgroundColor = UIColor.blackColor().CGColor
            sessionController.previewLayer.opacity = 0.0
            sessionController.previewLayer.frame = bounds
            
            layer.addSublayer(sessionController.previewLayer)
        }

        self.backgroundColor = UIColor.blackColor()
        
        setUpLayoutForMode(.Initial)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gesture Related
    
    
    let gesture = (
        tap: UITapGestureRecognizer(),
        doubleTap: UIShortTapGestureRecognizer(),
        twoFinger: UITapGestureRecognizer()
    )
    
    override func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        super.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.delegate = self
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let controlPanel = currentControlPanel where touch.view!.isDescendantOfView(controlPanel) {
            return false
        }
        if touch.view!.isKindOfClass(UIButton) || touch.view!.isKindOfClass(ControlPanel) {
            return false// allows button to recieve touch down for button pressed look
        }
        
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (
            
            gestureRecognizer == gesture.tap &&
                
            otherGestureRecognizer == gesture.doubleTap &&
                
            layout.currentMode == .AspectRatio
            
        )
    }
    
    func handleTapGesture(tapGesture: UITapGestureRecognizer){
        
        switch tapGesture.numberOfTapsRequired {
            
        case 1 where tapGesture.numberOfTouchesRequired == 1 :
            
            switchToLayout(
                (layout.currentMode == .Normal) ? .Options : .Normal
            )
            
        case 2:
            
            switchToLayout(.AspectRatio)
            
            
            switch sessionController.cropAspectRatio {
                
            case CSAspectRatioMake(16, 9):
                
                sessionController.cropAspectRatio = CSAspectRatioMake(4, 3)
                
            case CSAspectRatioMake(4, 3):
                
                sessionController.cropAspectRatio = CSAspectRatioMake(1, 1)
                
            case CSAspectRatioMake(1, 1):
                
                sessionController.cropAspectRatio = CSAspectRatioMake(3, 2)
                
            case CSAspectRatioMake(3, 2):
                
                sessionController.cropAspectRatio = CSAspectRatioMake(4, 3)
                
            case CSAspectRatioMake(4, 3):
                
                sessionController.cropAspectRatio = CSAspectRatioMake(16, 9)
                
            default:
                
                sessionController.cropAspectRatio = CSAspectRatioMake(16, 9)
                
            }
            
            case 1 where tapGesture.numberOfTouchesRequired == 2 : delegate?.showPhotoBrowser()
            
            
            
        default: break
            
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
    }

    // MARK: UI
    // MARK: |-- Buttons
    let shutterButton = UIButton.shutterButton()
    let galleryButton = UIButton.galleryButton()
    
    // MARK: Actions
    
    func shutterPressed() {
        sessionController.captureStillPhoto()
    }
    func galleryPressed() {
        switchToLayout(.Normal)
        delegate?.showPhotoBrowser()
    }
    
    // MARK: CSControllerDelegate
    
    func sessionControllerError(error: ErrorType) {
        switchToLayout(.Error)
        switch error {
        case SessionError.CameraAccessDenied:
            
            UIAlertView(
                title: "I can't see anything :(",
                message: "\(kAppName) was denied access to the camera. To fix it go to:\n\nSettings > Privacy > Camera\nThen switch \(kAppName) to On",
                delegate: nil, cancelButtonTitle: nil
                ).show()
            
        default:
            
            UIAlertView(
                title: "Error",
                message: (error as NSError).description,
                delegate: nil, cancelButtonTitle: "Ok"
                ).show()
            
        }
    }
    
    func sessionControllerNotification(notification: CSNotification) {
        var hideTimerCount = 0
        switch notification {
        case .capturingStillImage(true):
            
            CATransaction.disableActions {
                
                self.sessionController.previewLayer.opacity = 0.0
                
            }
            
            CATransaction.performBlock(0.4) {
                
                self.sessionController.previewLayer.opacity = 1.0
                
            }
            
        case .sessionRunning(true):
            
            switchToLayout(.AssembleControls, 1.6)
            
        case .sessionRunning(false):
            
            switchToLayout(.DisassembleControls)
            
        case .imageSaved:
        
            UIView.animateWithDuration(0.2,
                delay: 0.0,
                options: .BeginFromCurrentState, animations: {
                    self.galleryButton.alpha = 1.0
                }, completion: nil)

//            UIView.animateWithDuration(0.2,
//                delay: 1.2,
//                options: .BeginFromCurrentState, animations: {
//                    self.galleryButton.alpha = 0.0
//                }, completion: nil)
            
        default:  break
        }
    }
    
    // MARK: |-- Sliders
    
    enum MainSliderPositionType {
        case Top, Right, Bottom, Left
    }
    
    var mainSliders: [ MainSliderPositionType : Slider ] = [ : ]
    
    var sliders: (
        zoom: SmartSlider<CGFloat>!,
        focus: SmartSlider<Float>!,
        temperature: SmartSlider<Float>!,
        tint: SmartSlider<Float>!,
        iso: SmartSlider<Float>!,
        exposureDuration: SmartSlider<CMTime>!
    )
    
    // MARK: Control Related
    
    private let menuControl = OptionControl<Layout.Mode>(items: [
        ("Focus", .Focus),
        ("Zoom", .Zoom),
        ("Exposure", .Exposure),
        ("WB", .WhiteBalance),
        ("Aspect Ratio", .AspectRatio) ]
    )
    
    private var currentControlPanel: ControlPanel?
    
    // MARK: Layout Related
    
    private func setUpLayoutForMode(mode:Layout.Mode) -> Void {
        
        unowned let me = self
        
        func setUpControlPanel(rows:[ControlPanel.Row], inout _ layout: Layout) {
            
            let controlPanel = ControlPanel(
                
                rows: rows,
                
                frame: CGRectMake(0, 20, self.bounds.width, 50)
            )
            
            controlPanel.translatesAutoresizingMaskIntoConstraints = false
            
            controlPanel.alpha = 0.0
            
            CATransaction.disableActions{
                
                self.addSubview(controlPanel)
                
                self.currentControlPanel = controlPanel
                
                self.addConstraintsForKeys([.ControlPanel])
                
            }
            
            Layout.appendPerformer(&layout.entrancePerformer){
                
                controlPanel.alpha = 1.0
                
            }
            
            Layout.appendPerformer(&layout.exitPerformer){
                
                controlPanel.alpha = 0.0
                
            }
            
            Layout.appendCompleter(&layout.exitCompleter){ (_) in
                
                controlPanel.removeFromSuperview()
                
                me.currentControlPanel = nil
                
            }
        }
        
        var oldSavedMode = menuControl.items.first!.value
        
        var newSavedMode = menuControl.items.first!.value
        
        if let oldInfo = layout {
            
            oldSavedMode = oldInfo.savedMode
            
            if let existingItem = menuControl.itemWithValue(oldInfo.currentMode) {
                
                newSavedMode = existingItem.value
                
            }
        }
        
        var newLayout = Layout()
        newLayout.savedMode = newSavedMode
        newLayout.currentMode = mode
        
        switch mode {
        case .Initial: // MARK: Initial
            
            func initControls(){
                
                
                
                
                
                // MARK: Gestures
                
                gesture.doubleTap.addTarget(self, action: "handleTapGesture:")
                gesture.doubleTap.numberOfTapsRequired = 2
                addGestureRecognizer(gesture.doubleTap)
                
                gesture.tap.addTarget(self, action: "handleTapGesture:")
                addGestureRecognizer(gesture.tap)
                
                gesture.twoFinger.addTarget(self, action: "handleTapGesture:")
                gesture.twoFinger.numberOfTouchesRequired = 2
                addGestureRecognizer(gesture.twoFinger)
                
                
                
                
                
                /// prevent strong ownership in closures
                unowned let me = self
                
                
                
                
                
                // MARK: Menu Control
                
                menuControl.setValueAction = {
                    
                    if me.menuControl.alpha != 0 {
                        
                        me.switchToLayout( $0 )
                        
                    }
                
                }
                
                menuControl.translatesAutoresizingMaskIntoConstraints = false
                
                addSubview(menuControl)
                
                
                
                
                
                
                
                
                
                // MARK: Zoom Slider
                
                sliders.zoom = SmartSlider<CGFloat>(
                    
                    glyph: ManualCaptureGlyph(type: .Zoom),
                    
                    direction: .Right,
                    
                    30
                )
                
                sliders.zoom.initialSensitivity = 0.5
                
                sliders.zoom.labelTextForValue = { (value, shouldRound) in
                    
                    let nearest: CGFloat = (shouldRound) ? 1 : 0.1
                    let rounded = round( value / nearest ) * nearest
                    return "\( rounded )x"
                    
                }
                
                sliders.zoom.actionProgressChanged = { (slider) in
                    
                    me.sessionController.set( .cameraZoomFactor( slider.value ) )
                    
                }
                sliders.zoom.actionProgressStarted = { (slider) in
                    
                    me.switchToLayout(.Zoom)
                    
                }
                
                
                
                
                
                
                
                
                
                // MARK: Focus Slider
                
                sliders.focus = SmartSlider<Float>(
                    
                    glyph: ManualCaptureGlyph(type: .Focus),
                    
                    direction: .Right,
                    
                    startBounds: {
                        
                        me.startBoundsForType(
                            
                            .RightAlongBottom,
                            
                            edgeDistance: 160,
                            
                            gestureView: me
                            
                        )
                        
                    },
                    
                    sliderBounds: nil
                    
                )
                
                sliders.focus.initialSensitivity = 0.75
                
                sliders.focus.labelTextForValue = { (value, shouldRound) in
                    
                    let percent = value * 100
                    
                    let nearest: Float = (shouldRound) ? 10 : 1
                    
                    let rounded = Int( round( percent / nearest ) * nearest )
                    
                    return "\( rounded )%"
                    
                }
                
                sliders.focus.actionProgressChanged = { (slider) in
                    
                    me.sessionController.set(.cameraLensPosition(slider.value))
                    
                }
                
                sliders.focus.actionProgressStarted = { (_) in
                    
                    me.menuControl.selectItemWithValue(.Focus)
                    
                }
                
                
                
                
                
                
                
                
                
                // MARK: temperature slider
                
                sliders.temperature = SmartSlider<Float>(
                    
                    glyph: ManualCaptureGlyph(type: .Temperature),
                    
                    direction: .Right,
                    
                    startBounds: {
                        
                        me.startBoundsForType(
                            
                            .RightAlongTop,
                            
                            edgeDistance: 160,
                            
                            gestureView: self
                        
                        )
                        
                    },
                    
                    sliderBounds: nil
                    
                )
                
                sliders.temperature.initialSensitivity = 0.3
                
                sliders.temperature.labelTextForValue = { (value, shouldRound) in
                    
                    let nearest: Float = (shouldRound) ? 100 : 1
                    
                    let rounded = Int( round( value / nearest ) * nearest )
                    
                    return "\( rounded )k"
                    
                }
                
                sliders.temperature.actionProgressChanged = { (_) in
                    
                    let temperatureAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(
                        
                        temperature: me.sliders.temperature.value,
                        
                        tint: me.sliders.tint.value
                        
                    )
                    
                    let whiteBalanceGains = me.sessionController._normalizeGainsForTemperatureAndTint(temperatureAndTint)
                    
                    me.sessionController.set( .cameraWhiteBalanceGains( whiteBalanceGains ) )
                    
                }
                
                sliders.temperature.actionProgressStarted = { (_) in
                    
                    me.menuControl.selectItemWithValue(.WhiteBalance)
                    
                }
                
                
                
                
                
                
                
                
                
                // MARK: tint slider
                
                sliders.tint = SmartSlider<Float>(
                    
                    glyph: ManualCaptureGlyph(type: .Tint),
                    
                    direction: .Right,
                    
                    25
                    
                )
                
                sliders.tint.initialSensitivity = 0.3
                
                sliders.tint.labelTextForValue = { (value, shouldRound) in
                    
                    let nearest: Float = (shouldRound) ? 10 : 1
                    
                    let rounded = Int( round( value / nearest ) * nearest )
                    
                    return "\( rounded )"
                    
                }
                
                sliders.tint.actionProgressChanged = { (_) in
                    
                    let temperatureAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(
                        
                        temperature: me.sliders.temperature.value,
                        
                        tint: me.sliders.tint.value
                        
                    )
                    
                    let whiteBalanceGains = me.sessionController._normalizeGainsForTemperatureAndTint(temperatureAndTint)
                    
                    me.sessionController.set( .cameraWhiteBalanceGains( whiteBalanceGains ) )
                    
                }
                
                sliders.tint.actionProgressStarted = { (_) in
                    
                    me.menuControl.selectItemWithValue(.WhiteBalance)
                
                }
                
                
                
                
                
                
                
                
                
                // MARK: iso slider
                
                sliders.iso = SmartSlider<Float>(
                    
                    glyph: ManualCaptureGlyph(type: .ISO),
                    
                    direction: .Up,
                    
                    startBounds: {
                        
                        me.startBoundsForType(.UpAlongLeft, edgeDistance: 240, gestureView: me)
                    
                    },
                    
                    sliderBounds: nil,
                    
                    25
                    
                )
                
                sliders.iso.initialSensitivity = 0.6
                
                sliders.iso.labelTextForValue = { (value, shouldRound) in
                    
                    let nearest: Float = (shouldRound) ? 25 : 1
                    
                    let rounded = Int( round( value / nearest ) * nearest )
                    
                    return "\( rounded )"
                    
                }
                
                sliders.iso.actionProgressChanged = { (_) in
                    
                    let exposureDuration = me.sliders.exposureDuration.value
                    
                    let iso = me.sliders.iso.value
                    
                    me.sessionController.set( .cameraExposure( .durationAndISO( exposureDuration, iso ) ) )
                    
                }
                
                sliders.iso.actionProgressStarted = { (_) in
                    
                    me.menuControl.selectItemWithValue(.Exposure)
                
                }
                
                sliders.iso.knobLayer.positionType = .Left
                
                
                
                
                
                
                
                
                
                // MARK: exposure duration slider
                
                sliders.exposureDuration = SmartSlider <CMTime> (
                    
                    glyph: ManualCaptureGlyph( type: .ExposureDuration ),
                    
                    direction: .Up,
                    
                    startBounds: {
                        
                        me.startBoundsForType (
                            
                            .UpAlongRight,
                            
                            edgeDistance: 240,
                            
                            gestureView: self
                        
                        )
                        
                    },
                    
                    sliderBounds: nil,
                    
                    42
                    
                )
                
                sliders.exposureDuration.initialSensitivity = 0.2
                
                sliders.exposureDuration.labelTextForValue = { (value, shouldRound) in
                    
                    if shouldRound {
                        
                        return roundExposureDurationString( value )
                        
                    } else {
                        
                        return roundExposureDurationStringFast( value )
                        
                    }
                }
                
                sliders.exposureDuration.actionProgressChanged = { (_) in
                    
                    let exposureDuration = me.sliders.exposureDuration.value
                    
                    let iso = me.sliders.iso.value
                    
                    me.sessionController.set( .cameraExposure( .durationAndISO( exposureDuration, iso ) ) )
                    
                }
                
                sliders.exposureDuration.actionProgressStarted = { (_) in
                    
                    me.menuControl.selectItemWithValue(.Exposure)
                
                }
                
                sliders.exposureDuration.knobLayer.positionType = .Right
                
                
                
                
                
                
                // main sliders
                
                mainSliders[.Right] = sliders.exposureDuration
                
                mainSliders[.Left] = sliders.iso
                
                mainSliders[.Bottom] = sliders.focus
                
                mainSliders[.Top] = sliders.temperature
                
                
                
                
                
                // MARK: shutter button
                
                shutterButton.addTarget(
                    
                    self,
                    
                    action: "shutterPressed",
                    
                    forControlEvents: .TouchUpInside
                
                )
                
                shutterButton.translatesAutoresizingMaskIntoConstraints = false
                
                shutterButton.enabled = false
                
                shutterButton.alpha = 0.0
                
                addSubview(shutterButton)
                
                
                
                
                
                
                
                // MARK: gallery button
                galleryButton.addTarget(
                    
                    self,
                    
                    action: "galleryPressed",
                    
                    forControlEvents: .TouchUpInside
                
                )
                
                galleryButton.translatesAutoresizingMaskIntoConstraints = false
                
                galleryButton.alpha = 0.0
                
                addSubview(galleryButton)
                
                
                
                
                
                
                
                // add main sliders
                
                for (key, slider) in mainSliders {
                    
                    slider.translatesAutoresizingMaskIntoConstraints = false
                    
                    addSubview(slider)
                    
                    addConstraints( createConstraintsForKey( .Slider( key ) ) )
                    
                    var hideTimerCount = 0
                    
                    slider.actionDidStateChange = { [unowned slider] added, removed in
                        
                        var shouldHide = true
                        switch me.layout.currentMode {
                        case .Focus:
                            shouldHide = !(slider == me.sliders.focus)
                        case .Exposure:
                            shouldHide = !(slider == me.sliders.iso || slider == me.sliders.exposureDuration)
                        case .WhiteBalance:
                            shouldHide = !(slider == me.sliders.temperature || slider == me.sliders.tint)
                        default:break
                        }
                        
                        if added.contains(.Current) && slider.alpha != 1.0{
                            UIView.animateWithDuration(0.2) {
                                slider.alpha = 1.0
                            }
                        }
                        
                        if removed.contains(.Current) && shouldHide {
                            let duration: NSTimeInterval = (Control.currentControl != nil) ? 0.2 : 0.4
                            UIView.animateWithDuration(duration) {
                                slider.alpha = 0.0
                            }
                        }
                        
                    }
                    
                    slider.actionStarted = {
                        hideTimerCount++
                        if slider.alpha != 1.0 {
                            UIView.animateWithDuration(0.2) {
                                slider.alpha = 1.0
                            }
                        }
                    }
                    
                    slider.actionEnded = { [unowned slider] in
                        
                        let delayNSEC = kMainSliderHideDelay * Double(NSEC_PER_SEC)
                        
                        let dispatchTime = dispatch_time(DISPATCH_TIME_NOW, Int64(delayNSEC))
                        
                        dispatch_after(dispatchTime, dispatch_get_main_queue()) {
                            
                            hideTimerCount--
                            if hideTimerCount == 0 {
                                slider.resignCurrentControl()
                            }
                        }
                        
                    }
                    
                    
                    
                }
                
                
                addConstraintsForKeys( [ .MenuControl, .ShutterButton, .GalleryButton ] )
                
            }
            
            newLayout = Layout()
            
            initControls()
            
            sliders.focus.alpha = 0.0
            
            sliders.temperature.alpha = 0.0
            
            sliders.iso.alpha = 0.0
            
            sliders.exposureDuration.alpha = 0.0
            
            menuControl.alpha = 0.0
            
        case .Error: // MARK: Error
            
            newLayout.entrancePerformer = Layout.fusePerformers(
                Layout.opacityPerformer(layers:
                    me.sessionController.previewLayer
                ),
                Layout.alphaPerformer(views:
                    sliders.focus,
                    sliders.temperature,
                    sliders.iso,
                    sliders.exposureDuration,
                    menuControl,
                    shutterButton,
                    galleryButton
                )
            )

    
            
        case .DisassembleControls: // MARK: DisassembleControls
            
            func disassembleControls(){
                
                sliders.zoom.vpHandler = nil
                
                sliders.zoom.pdHandlers["Scale"] = nil
                
                sliders.focus.vpHandler = nil
                
                sliders.temperature.vpHandler = nil
                
                sliders.tint.vpHandler = nil
                
                sliders.iso.vpHandler = nil
                
                sliders.exposureDuration.vpHandler = nil
                
                
                
                sessionController.voBlocks.zoomFactor["Slider"] = nil
                
                sessionController.voBlocks.lensPosition["Slider"] = nil
                
                sessionController.voBlocks.iso["Slider"] = nil
                
                sessionController.voBlocks.exposureDuration["Slider"] = nil
                
                sessionController.voBlocks.whiteBalance["Slider"] = nil
                
                sessionController.voBlocks.focusMode["Slider"] = nil
                
                sessionController.voBlocks.exposureMode["Slider"] = nil
                
                sessionController.voBlocks.whiteBalanceMode["Slider"] = nil
                
            }
            
            newLayout.entranceCompleter = { (_) in
                
                disassembleControls()
                
            }
            
        case .AssembleControls: // MARK: AssembleControls
            
            func assembleControls(){
                
                let zoomMax = min(sessionController.camera.activeFormat.videoMaxZoomFactor, 25)
                
                let zVPHandler = VPExponentialCGFloatHandler(start: 1.0, end: zoomMax) as VPHandler<CGFloat>
                
                sliders.zoom.vpHandler = zVPHandler
                
                
                let pdscale = PDScale(self, vpHandler: zVPHandler)
                
                /// prevent strong ownership in closures
                unowned let me = self
                
                pdscale.currentScale = { me.sessionController.camera.videoZoomFactor }
                
                pdscale.maxScale = zoomMax
                
                sliders.zoom.addPDHandler("Scale", handler: pdscale)
                
                
                
                
                
                sliders.focus.vpHandler = VPFloatHandler(start: 0.0, end: 1.0)
                
                sliders.temperature.vpHandler = VPFloatHandler(start: 2000, end: 8000)
                
                sliders.tint.vpHandler = VPFloatHandler(start: -150, end: 150)
                
                sliders.iso.vpHandler = VPFloatHandler(start: sessionController.camera.activeFormat.minISO, end: sessionController.camera.activeFormat.maxISO)
                
                
                
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
                
                sliders.exposureDuration.vpHandler = VPHandler(pfv: pfv, vfp: vfp)
                
    
                
                
                sliders.zoom.value = sessionController.camera.videoZoomFactor
                
                sliders.focus.value = sessionController.camera.lensPosition
                
                let tt = sessionController.camera.temperatureAndTintValuesForDeviceWhiteBalanceGains(sessionController.camera.deviceWhiteBalanceGains)
                
                sliders.temperature.value = tt.temperature
                
                sliders.tint.value = tt.tint
                
                sliders.iso.value = sessionController.camera.ISO
                
                sliders.exposureDuration.value = sessionController.camera.exposureDuration
                
                
                var focusVOE: Bool { return self.sessionController.camera.focusMode != .Locked }
                var exposureVOE: Bool { return self.sessionController.camera.exposureMode != .Custom && self.sessionController.camera.exposureMode != .Locked }
                var whiteBalanceVOE: Bool { return self.sessionController.camera.whiteBalanceMode != .Locked }
                
                sessionController.voBlocks.lensPosition["Slider"] = { (focusVOE) ? self.sliders.focus.value = $0 : () }
                
                sessionController.voBlocks.iso["Slider"] = { (exposureVOE) ? self.sliders.iso.value = $0 : () }
                
                sessionController.voBlocks.exposureDuration["Slider"] = { (exposureVOE) ? self.sliders.exposureDuration.value = $0 : () }
                
                sessionController.voBlocks.whiteBalance["Slider"] = {
                    
                    guard whiteBalanceVOE else { return }
                    
                    let temperatureAndTint = self.sessionController.camera.temperatureAndTintValuesForDeviceWhiteBalanceGains($0)
                    
                    self.sliders.temperature.value = temperatureAndTint.temperature
                    
                    self.sliders.tint.value = temperatureAndTint.tint
                    
                }
                
                
                
                sessionController.voBlocks.focusMode["Slider"] = {
                    
                    let cc = ($0 != .Locked)
                    
                    self.sliders.focus.state.getUpdateTransform( cc, .ComputerControlled )? (&self.sliders.focus.state)
                    
                }
                
                sessionController.voBlocks.exposureMode["Slider"] = {
                    
                    let cc = ($0 != .Custom)
                    
                    self.sliders.exposureDuration.state.getUpdateTransform( cc, .ComputerControlled )? (&self.sliders.exposureDuration.state)
                    
                    self.sliders.iso.state.getUpdateTransform( cc, .ComputerControlled )? (&self.sliders.iso.state)
                    
                }
                
                sessionController.voBlocks.whiteBalanceMode["Slider"] = {
                    
                    let cc = ($0 != .Locked)
                    
                    self.sliders.temperature.state.getUpdateTransform( cc, .ComputerControlled )? (&self.sliders.temperature.state)
                    
                    self.sliders.tint.state.getUpdateTransform( cc, .ComputerControlled )? (&self.sliders.tint.state)
                    
                }
                
            }
            
            assembleControls()
            
            newLayout.entrancePerformer = {
                
                me.sessionController.previewLayer.opacity = 1.0
                
            }
            
            newLayout.entranceCompleter = { (_) in
                
                me.switchToLayout(.Normal, 0.2)
                
            }
            
            sessionController.set(.cameraExposureMode(.ContinuousAutoExposure))
            sessionController.set(.cameraFocusMode(.ContinuousAutoFocus))
            sessionController.set(.cameraWhiteBalanceMode(.ContinuousAutoWhiteBalance))
            
        case .Normal: // MARK: Normal
            
            
            newLayout.entrancePerformer = {
                me.menuControl.alpha = 0.0
                me.shutterButton.enabled = true
                me.galleryButton.enabled = false
            }
            
            newLayout.exitPerformer = {
                me.shutterButton.enabled = false
                me.galleryButton.enabled = true
            }
            newLayout.tempAlpha(shutterButton, 1.0, 0.15)
            newLayout.tempHide(galleryButton)
            
            
        case .Focus: // MARK: Focus
            
            
            sliders.focus.alpha = 0.0
            newLayout.tempShow(sliders.focus)
            
            
            
            let modeControl = OptionControl<AVCaptureFocusMode>(
                
                items: [
                    
                    ("Manual", .Locked),
                    
                    ("Auto", .ContinuousAutoFocus)
                    
                ],
                
                selectedValue: sessionController.camera.focusMode
                
            )
            
            modeControl.setValueAction = { me.sessionController.set(.cameraFocusMode($0)) }
            
            let voKey = "FocusModeControl"
            
            sessionController.voBlocks.focusMode[voKey] = { modeControl.selectItemWithValue($0) }
            
            newLayout.temp(&sessionController.voBlocks.focusMode[voKey])
            

            
            setUpControlPanel([
                
                ControlPanel.Row(modeControl)
                
                ], &newLayout)
            
        case .Exposure: // MARK: Exposure
            
            
            newLayout.tempAlpha(galleryButton, 0.15)
            
            sliders.iso.alpha = 0.0
            sliders.exposureDuration.alpha = 0.0
            newLayout.tempShow(sliders.iso, sliders.exposureDuration)
            
            
            
            let modeControl = OptionControl<AVCaptureExposureMode>(
                
                items: [ ("Manual", .Custom), ("Auto", .ContinuousAutoExposure) ],
                
                selectedValue: me.sessionController.camera.exposureMode
                
            )
            
            modeControl.setValueAction = { me.sessionController.set(.cameraExposureMode($0)) }
            
            let voKey = "ExposureModeControl"
            
            sessionController.voBlocks.exposureMode[voKey] = { modeControl.selectItemWithValue($0) }
            
            newLayout.temp(&sessionController.voBlocks.exposureMode[voKey])
            
            
            let rows: [ControlPanel.Row] = [
                
                ControlPanel.Row(modeControl)
                
            ]
            
            //guard menuControl.alpha > 0 else { break }
            
            setUpControlPanel(rows, &newLayout)
            
        case .WhiteBalance: // MARK: WhiteBalance
            
            sliders.temperature.alpha = 0.0
            newLayout.tempShow(sliders.temperature)
            
            
            
            let modeControl = OptionControl<AVCaptureWhiteBalanceMode>(
                
                items: [ ("Manual", .Locked), ("Auto", .ContinuousAutoWhiteBalance) ],
                
                selectedValue: sessionController.camera.whiteBalanceMode
                
            )
            
            modeControl.setValueAction = { me.sessionController.set(.cameraWhiteBalanceMode($0)) }
            
            let voKey = "WhiteBalanceModeControl"
            
            sessionController.voBlocks.whiteBalanceMode[voKey] = { modeControl.selectItemWithValue($0) }
            
            newLayout.temp(&sessionController.voBlocks.whiteBalanceMode[voKey])
            
            let rows: [ControlPanel.Row] = [
                
                ControlPanel.Row(modeControl),
                
                ControlPanel.Row(sliders.tint)
                
            ]
            
            setUpControlPanel(rows, &newLayout)
            
        case .Zoom: // MARK: Zoom
            
            newLayout.entrancePerformer = {
                me.menuControl.alpha = 1.0
            }
            
            setUpControlPanel([
                
                ControlPanel.Row(me.sliders.zoom)
                
                ], &newLayout)
            
        case .AspectRatio: // MARK: AspectRatio
            
            let voKey = "AspectRatioOptionControl"
            
            
            let optionControl = OptionControl<CSAspectRatio>(
                
                items: [
                    
                    ("16:9", CSAspectRatioMake(16,9)),
                    
                    ("4:3", CSAspectRatioMake(4,3)),
                    
                    ("3:2", CSAspectRatioMake(3,2)),
                    
                    ("Square", CSAspectRatioMake(1,1)),
                    
                    ("Portrait", CSAspectRatioMake(3,4))
                    
                ],
                
                selectedValue: sessionController.cropAspectRatio
                
            )
            
            optionControl.setValueAction = { me.sessionController.set(.cropAspectRatio($0)) }
            
            me.sessionController.voBlocks.aspectRatio[voKey] = { optionControl.selectItemWithValue($0) }
            
            newLayout.temp(&me.sessionController.voBlocks.aspectRatio[voKey])
            
            
            
            newLayout.entrancePerformer = {
                
                me.menuControl.alpha = 1.0
                
            }
            
            
            
            setUpControlPanel([
                
                ControlPanel.Row(optionControl)
                
                ], &newLayout)
            
        case .Options: // MARK: Options
            
            newLayout.entranceStarter = {
                
                me.switchToLayout(me.menuControl.value ?? .Focus)
                
            }
            
            newLayout.entrancePerformer = {
                
                me.menuControl.alpha = 1.0
                
                me.galleryButton.alpha = 1.0
                
                me.galleryButton.enabled = true
                
            }
            
        case .Shortcut: break
            
        case .Fullscreen: break
            
        }
        
        
        me.layout = newLayout
        
    }
    
    private var layout: Layout!
    
    
    
    private func switchToLayout(layoutMode:Layout.Mode, _ duration: NSTimeInterval = 0.2) {
        
        guard layout.currentMode != layoutMode else {return}
        
        CATransaction.begin()
        
        CATransaction.setDisableActions(false)
        
        CATransaction.setAnimationDuration(duration)
        
        UIView.animateWithDuration(duration,
            delay: 0.0,
            options: .BeginFromCurrentState,
            animations: layout.exitPerformer,
            completion: layout.exitCompleter)
        
        
        
        CATransaction.commit()
        
        
        
        setUpLayoutForMode(layoutMode)
        
        if let i = OptionControl.indexOfItemWithValue(layoutMode, items: menuControl.items) {
            menuControl.selectedIndex = i
        }
        
        
        
        CATransaction.begin()
        
        CATransaction.setDisableActions(false)
        
        CATransaction.setAnimationDuration(duration)
        
        
        
        UIView.animateWithDuration(duration,
            delay: 0.0,
            options: .BeginFromCurrentState,
            animations: layout.entrancePerformer,
            completion: layout.entranceCompleter)
        
        
        
        CATransaction.commit()
        
        
        
        layout.entranceStarter()
        
    }

    
    
    
    override var bounds: CGRect {
        
        didSet {
            
            guard bounds != oldValue else { return }
            
            sessionController.previewLayer.frame = bounds
            
            updateConstraintsForKeys(
                [
                    .Slider(.Top),
                    .Slider(.Bottom),
                    .Slider(.Left),
                    .Slider(.Right),
                    .ShutterButton
                ]
            )
            
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
            case .ShutterButton: return "ShutterButton"
            case .GalleryButton: return "GalleryButton"
            case .ControlPanel: return "ControlPanel"
            case .MenuControl: return "MenuControl"
            }
        }
        case Slider(MainSliderPositionType)
        case ShutterButton, GalleryButton
        case ControlPanel
        case MenuControl
    }
    
    
    func createConstraintsForKey(key:ConstraintKey) -> [NSLayoutConstraint] {
        
        var constraints: [NSLayoutConstraint] = []
        
        let sDistance = kSliderKnobMargin + kSliderKnobRadius + 2
        
        
        
        let xMargin: CGFloat = 10
        
        let yMargin: CGFloat = 10
        
        let mx = 2 * sDistance + xMargin
        let my = 2 * sDistance + yMargin
        
        
        
        switch key {
            
            
            
        case .MenuControl: // MARK: MenuControl
            
            
            
            let sHeight = my + 5
            
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "H:|->=0-[MC(==350@250)]->=0-|",
                options: .DirectionLeftToRight,
                metrics: nil,
                views: ["MC" : menuControl]
                
            )
            
            let centerXConstraint = NSLayoutConstraint(
                
                item: menuControl,
                attribute: .CenterX,
                relatedBy: .Equal,
                
                toItem: self,
                attribute: .CenterX,
                multiplier: 1,
                constant: 0
            
            )
            
            let yConstraint = NSLayoutConstraint(
                
                item: menuControl,
                attribute: NSLayoutAttribute.TopMargin,
                relatedBy: NSLayoutRelation.Equal,
                
                toItem: self,
                attribute: NSLayoutAttribute.Top,
                multiplier: 1,
                constant: sHeight
            
            )
            
            constraints.appendContentsOf(hConstraints)
            constraints.append(centerXConstraint)
            constraints.append(yConstraint)
            
            
            
        case .ControlPanel: // MARK: ControlPanel
            
            
            
            let sHeight = my + 5
            
            guard let controlPanel = currentControlPanel else { break }
            
            let centerXConstraint = NSLayoutConstraint(
                
                item: controlPanel,
                attribute: .CenterX,
                relatedBy: .Equal,
                
                toItem: self,
                attribute: .CenterX,
                multiplier: 1,
                constant: 0
            
            )
            
            let yConstraint = NSLayoutConstraint(
                
                item: controlPanel,
                attribute: .BottomMargin,
                relatedBy: .Equal,
                
                toItem: self,
                attribute: .Bottom,
                multiplier: 1,
                constant: -sHeight
            
            )
            
            constraints.append(centerXConstraint)
            constraints.append(yConstraint)
            
            
            
            
            
        case .ShutterButton: // MARK: ShutterButton
            
            
            
            let sWidth = xMargin
            
            let centerYConstraint = NSLayoutConstraint(
                
                item: shutterButton,
                attribute: .CenterY,
                relatedBy: .Equal,
                
                toItem: self,
                attribute: .CenterY,
                multiplier: 1,
                constant: 0
            
            )
            
            let centerXConstraint = NSLayoutConstraint(
                
                item: shutterButton,
                attribute: .RightMargin,
                relatedBy: .Equal,
                
                toItem: self,
                attribute: .RightMargin,
                multiplier: 1,
                constant: -sWidth
                
            )
            
            constraints.appendContentsOf([centerXConstraint])
            constraints.appendContentsOf([centerYConstraint])
            
            
            
            
            
        case .GalleryButton: // MARK: GalleryButton
            
            
            
            let sHeight = my + 15
            
            let sWidth = xMargin
            
            let centerYConstraint = NSLayoutConstraint(
                
                item: galleryButton,
                attribute: .BottomMargin,
                relatedBy: .Equal,
                
                toItem: self,
                attribute: .Bottom,
                multiplier: 1,
                constant: -sHeight
            
            )
            
            let centerXConstraint = NSLayoutConstraint(
                
                item: galleryButton,
                attribute: .RightMargin,
                relatedBy: .Equal,
                
                toItem: self,
                attribute: .RightMargin,
                multiplier: 1,
                constant: -sWidth
            )
            
            constraints.appendContentsOf([centerXConstraint])
            constraints.appendContentsOf([centerYConstraint])
            
            
            
            
            
        case .Slider(.Left): // MARK: Slider(.Left)
            
            
            
            guard let slider = mainSliders[.Left] else { break }
            
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "H:|-x-[S]",
                options: .DirectionLeftToRight,
                metrics: [ "x" : xMargin ],
                views: [ "S" :slider ]
                
            )
            
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "V:|->=m-[S(==450@250)]->=m-|",
                options: .DirectionLeftToRight,
                metrics: [ "m" : my ],
                views: [ "S" : slider ]
            
            )
            
            let lowPriorityCenterYConstraint = NSLayoutConstraint(
                item: slider,
                attribute: .CenterY, relatedBy: .Equal,
                toItem: self,
                attribute: .CenterY, multiplier: 1, constant: 0
            )
            lowPriorityCenterYConstraint.priority = UILayoutPriorityDefaultLow
            
            constraints.append(lowPriorityCenterYConstraint)
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
            
            
            
            
            
        case .Slider(.Right): // MARK: Slider(.Right)
            
            
            
            guard let slider = mainSliders[.Right] else { break }
            
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "H:[S]-x-|",
                options: .DirectionLeftToRight,
                metrics: [ "x" : xMargin ],
                views: [ "S" : slider ]
            
            )
            
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "V:|->=m-[S(==450@250)]->=m-|",
                options: .DirectionLeftToRight,
                metrics: [ "m" : my ],
                views: [ "S" : slider ]
            
            )
            
            let lowPriorityCenterYConstraint = NSLayoutConstraint(
                item: slider,
                attribute: .CenterY, relatedBy: .Equal,
                toItem: self,
                attribute: .CenterY, multiplier: 1, constant: 0
            )
            lowPriorityCenterYConstraint.priority = UILayoutPriorityDefaultLow
            
            constraints.append(lowPriorityCenterYConstraint)
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
            
            
            
            
            
        case .Slider(.Bottom): // MARK: Slider(.Bottom)
            
            guard let slider = mainSliders[.Bottom] else { break }
            
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "V:[S]-y-|",
                options: .DirectionLeftToRight,
                metrics: [ "y" : yMargin ],
                views: [ "S" : slider ]
            
            )
            
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "H:|->=m-[S(==450@250)]->=m-|",
                options: .DirectionLeftToRight,
                metrics: [ "m" : mx ],
                views: [ "S" : slider ]
            
            )
            
            let lowPriorityCenterXConstraint = NSLayoutConstraint(
                item: slider,
                attribute: .CenterX, relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX, multiplier: 1, constant: 0
            )
            lowPriorityCenterXConstraint.priority = UILayoutPriorityDefaultLow
            
            constraints.append(lowPriorityCenterXConstraint)
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
            
            
            
            
            
            
        case .Slider(.Top): // MARK: Slider(.Top)
            
            guard let slider = mainSliders[.Top] else { break }
            
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "V:|-y-[S]",
                options: .DirectionLeftToRight,
                metrics: [ "y" : yMargin ],
                views: [ "S":slider ]
            
            )
            
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                
                "H:|->=m-[S(==450@250)]->=m-|",
                options: .DirectionLeftToRight,
                metrics: ["m": mx],
                views: ["S":slider]
            
            )
            
            let lowPriorityCenterXConstraint = NSLayoutConstraint(
                item: slider,
                attribute: .CenterX, relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX, multiplier: 1, constant: 0
            )
            lowPriorityCenterXConstraint.priority = UILayoutPriorityDefaultLow
            
            constraints.append(lowPriorityCenterXConstraint)
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
         
            
            
        }
        
        for constraint in constraints {
            
            constraint.identifier = key.description
        
        }
        
        return constraints
        
    }
    
    
    func addConstraintsForKeys( keys: [ConstraintKey] ) {
        
        for key in keys {
            
            addConstraints( createConstraintsForKey( key ) )
            
        }
        
    }
    
    
    func getConstraintsForKeys( keys: [ConstraintKey] ) -> [NSLayoutConstraint] {
        
        return constraints.filter { (constraint) in
            
            guard let id = constraint.identifier else { return false }
            
            for key in keys { if key.description == id { return true } }
            
            return false
            
        }
        
    }
    
    
    func updateConstraintsForKeys(keys:[ConstraintKey]) {
        
        removeConstraints( getConstraintsForKeys ( keys ) )
        
        addConstraintsForKeys(keys)
        
    }
    
    private struct Layout {
        
        typealias Init = () -> Void
        
        typealias Performer = () -> Void
        
        typealias Completer = (Bool) -> Void
        
        enum Mode {
            case Initial
            case Error
            case DisassembleControls
            case AssembleControls
            case Normal
            case Focus
            case Exposure
            case WhiteBalance
            case Zoom
            case AspectRatio
            case Options
            case Shortcut
            case Fullscreen
        }
        
        static func appendPerformer (inout performer: Performer, appendedPerformer: Performer) {
            let previousPerformer = performer
            performer = { previousPerformer(); appendedPerformer() }
        }
        
        static func appendCompleter (inout completer: Completer, appendedCompleter: Completer) {
            let previousCompleter = completer
            completer = { previousCompleter($0); appendedCompleter($0) }
        }
        
        static func fusePerformers(performers: Performer...) -> Performer {
            return performers.reduce({}) { left, right in
                { left(); right() }
            }
        }
        
        static func alphaPerformer(alpha: CGFloat = 0.0, views: UIView...) -> Performer {
            var performer: Performer = {}
            views.forEach { (view: UIView) in
                Layout.appendPerformer(&performer) { [unowned view] in
                    view.alpha = alpha
                }
            }
            return performer
        }
        
        static func opacityPerformer(opacity: Float = 0.0, layers: CALayer...) -> Performer {
            var performer: Performer = {}
            layers.forEach { (layer: CALayer) in
                Layout.appendPerformer(&performer) { [unowned layer] in
                    layer.opacity = opacity
                }
            }
            return performer
        }
        
        mutating func tempShow(views: UIView...) {
            views.forEach { (view: UIView) in
                self.tempAlpha(view, 1.0)
            }
        }
        
        mutating func tempHide(views: UIView...) {
            views.forEach { (view: UIView) in
                self.tempAlpha(view, 0.0)
            }
        }
        
        /// sets optional to nil on exitCompletion
        mutating func temp<Optional>(inout optional:Optional?) {
            Layout.appendCompleter(&exitCompleter) { _ in
                optional = nil
            }
        }
        
        mutating func tempAlpha(view: UIView, _ temporaryAlpha: CGFloat, _ resetAlpha: CGFloat? = nil ) {
            let resetAlpha = resetAlpha ?? view.alpha
            
            Layout.appendPerformer(&entrancePerformer) { [unowned view] in
                view.alpha = temporaryAlpha
            }
            Layout.appendPerformer(&exitPerformer) { [unowned view] in
                view.alpha = resetAlpha
            }
        }
        
        var entranceStarter: Init = {}
        
        var entrancePerformer: Performer = {}
        
        var entranceCompleter: Completer = {$0}
        
        var exitPerformer: Performer = {}
        
        var exitCompleter: Completer = {$0}
        
        var savedMode: Mode = .Focus
        
        var currentMode: Mode = .Initial
        
    }
    
}


