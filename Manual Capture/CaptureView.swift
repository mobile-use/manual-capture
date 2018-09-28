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
private let kAspectRatiosControlItems: [OptionControl<CSAspectRatio>.Item] = [
    //("21:9", CSAspectRatioMake(21,9)),
    ("16:9", CSAspectRatioMake(16,9)),
    ("4:3", CSAspectRatioMake(4,3)),
    ("3:2", CSAspectRatioMake(3,2)),
    ("Square", CSAspectRatioMake(1,1)),
    ("Portrait", CSAspectRatioMake(3,4)),
    ("Tall", CSAspectRatioMake(9,16))
    
]


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
        self.backgroundColor = UIColor.black
        if kIsDemoMode { // For screen shots
//            let sampleImageLayer = CALayer()
//            sampleImageLayer.contentsGravity = kCAGravityResizeAspect
//            sampleImageLayer.contents = UIImage(named: "SampleImage.JPG")?.cgImage
//            sampleImageLayer.frame = bounds
//            
//            layer.addSublayer(sampleImageLayer)
            backgroundColor = UIColor.green
        }else{
            sessionController.previewLayer.backgroundColor = UIColor.black.cgColor
            sessionController.previewLayer.opacity = 0.0
            sessionController.previewLayer.frame = bounds
            layer.addSublayer(sessionController.previewLayer)
        }
        setUpLayout(forMode:.initial)
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
    
    override func addGestureRecognizer(_ gestureRecognizer: UIGestureRecognizer) {
        super.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.delegate = self
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        guard let touchView = touch.view else { return true }
        if let controlPanel = currentControlPanel, touchView.isDescendant(of: controlPanel) {
            return false
        }
        if touchView is UIButton || touchView is ControlPanel {
            return false// allows button to recieve touch down for button pressed look
        }
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (
            gestureRecognizer == gesture.tap &&
            otherGestureRecognizer == gesture.doubleTap &&
            layout.currentMode == .aspectRatio
        )
    }
    
    @objc func handleTapGesture(tapGesture: UITapGestureRecognizer){
        switch tapGesture.numberOfTapsRequired {
        case 1 where tapGesture.numberOfTouchesRequired == 1 :
            switchToLayout(
                (layout.currentMode == .normal) ? .options : .normal
            )
        case 2:
            switchToLayout(.aspectRatio)
            var i = kAspectRatiosControlItems.firstIndex() { $0.value == sessionController.aspectRatio } ?? -1
            // switch to next aspect ratio
            i = i.advanced(by: 1)
            // if last then go back to first
            i = (kAspectRatiosControlItems.indices ~= i) ? i : 0
            sessionController.set(.aspectRatio( kAspectRatiosControlItems[i].value ) )
            
        case 1 where tapGesture.numberOfTouchesRequired == 2 : delegate?.showPhotoBrowser()
            
        default: break
        }
    }
    
    private func startBounds(forType type:StartBoundType, gestureView: UIView) -> CGRect {
        let W = gestureView.frame.width
        let H = gestureView.frame.height
        let E = (type.edge == .alongTop || type.edge == .alongBottom) ? H/2 : W/2
        switch type.edge {
        case .alongTop: return CGRect(x: 0, y: 0, width: W, height: E)
        case .alongRight: return CGRect(x: W - E, y: 0, width: E, height: H)
        case .alongBottom: return CGRect(x: 0, y: H - E, width: W, height: E)
        case .alongLeft: return CGRect(x: 0, y: 0, width: E, height: H)
        }
    }
    
    enum StartBoundType : String {
        case rightAlongTop = "rightAlongTop",
        leftAlongTop = "leftAlongTop",
        upAlongRight = "upAlongRight",
        downAlongRight = "downAlongRight",
        leftAlongBottom = "leftAlongBottom",
        rightAlongBottom = "rightAlongBottom",
        downAlongLeft = "downAlongLeft",
        upAlongLeft = "upAlongLeft"
        
        enum Direction : String {
            case right = "right",
            left = "left",
            up = "up",
            down = "down"
        }
        enum Edge : String {
            case alongTop = "alongTop",
            alongRight = "alongRight",
            alongBottom = "alongBottom",
            alongLeft = "alongLeft"
        }
        var direction: Direction {
            switch self {
            case .upAlongLeft, .upAlongRight: return .up
            case .rightAlongTop, .rightAlongBottom: return .right
            case .downAlongLeft, .downAlongRight: return .down
            case .leftAlongBottom, .leftAlongTop: return .left
            }
        }
        var edge: Edge {
            switch self {
            case .rightAlongTop, .leftAlongTop: return .alongTop
            case .upAlongRight, .downAlongRight: return .alongRight
            case .rightAlongBottom, .leftAlongBottom: return .alongBottom
            case .upAlongLeft, .downAlongLeft: return .alongLeft
            }
        }
    }

    // MARK: UI
    // MARK: |-- Buttons
    let shutterButton = UIButton.shutterButton()
    let galleryButton = UIButton.galleryButton()
    let undoButton = UIButton.undoButton()
    
    // MARK: Actions
    
    @objc func shutterPressed() {
        if kIsVideoMode {
            sessionController.captureVideo()
        }else {
            sessionController.captureStillPhoto()
        }
    }
    @objc func galleryPressed() {
        switchToLayout(.normal)
        delegate?.showPhotoBrowser()
    }
    @objc func undoPressed() {
        sessionController.set(.exposureMode(.continuousAutoExposure))
        sessionController.set(.focusMode(.continuousAutoFocus))
        sessionController.set(.whiteBalanceMode(.continuousAutoWhiteBalance))
        guard layout.currentMode == .normal else {return}
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
            self.undoButton.alpha = 0.0
            }, completion: nil)
    }
    
    // MARK: CSControllerDelegate
    
    func sessionControllerError(error: Error) {
        switch error {
        case SessionError.cameraAccessDenied:
            switchToLayout(.error)
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
        switch notification {
        case .capturingPhoto(true):
            CATransaction.disableActions {
                self.sessionController.previewLayer.opacity = 0.0
            }
            CATransaction.performBlock(duration: 0.4) {
                self.sessionController.previewLayer.opacity = 1.0
            }
        case .sessionRunning(true):
            switchToLayout(.assembleControls, 1.6)
        case .sessionRunning(false):
            //break
            switchToLayout(.disassembleControls)
        case .photoSaved:
            UIView.animate(withDuration: 0.2,
                delay: 0.0,
                options: .beginFromCurrentState, animations: {
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
        case top, right, bottom, left
    }
    
    var mainSliders: [ MainSliderPositionType : Slider ] = [ : ]
    
    var sliders: (
        zoom: SmartSlider<CGFloat>,
        focus: SmartSlider<Float>,
        temperature: SmartSlider<Float>,
        tint: SmartSlider<Float>,
        iso: SmartSlider<Float>,
        exposureDuration: SmartSlider<CMTime>
    )!
    
    // MARK: Control Related
    
    let menuControl = OptionControl<Layout.Mode>(items: [
        ("Focus", .focus),
        ("Zoom", .zoom),
        ("Exposure", .exposure),
        ("WB", .whiteBalance),
        ("Aspect Ratio", .aspectRatio) ]
    )
    
    private var currentControlPanel: ControlPanel?
    
    var magnifyForFocus = true
    
    // MARK: Layout Related
    
    private func setUpLayout(forMode mode:Layout.Mode) -> Void {
        unowned let me = self
        func setUpControlPanel(rows:[ControlPanel.Row], _ layout: inout Layout) {
            let controlPanel = ControlPanel(
                rows: rows,
                frame: CGRect(x: 0, y: 20, width: self.bounds.width, height: 50)
            )
            controlPanel.translatesAutoresizingMaskIntoConstraints = false
            controlPanel.alpha = 0.0
//            CATransaction.disableActions{
//                
//                self.addSubview(controlPanel)
//                
//                self.currentControlPanel = controlPanel
//                
//                self.addConstraintsForKeys([.ControlPanel])
//                
//            }
            
            Layout.appendPerformer(&layout.entrancePerformer){
                UIView.animate(withDuration: 0){
                    CATransaction.disableActions{
                        me.addSubview(controlPanel)
                        me.currentControlPanel = controlPanel
                        me.addConstraints(forKeys: [.controlPanel])
                    }
                }
                controlPanel.alpha = 1.0
            }
            Layout.appendPerformer(&layout.exitPerformer){
                controlPanel.alpha = 0.0
            }
            Layout.appendCompleter(&layout.exitCompleter){ (_) in
                if me.currentControlPanel == controlPanel {
                    me.removeConstraints(me.getConstraints(forKeys: [.controlPanel]))
                    me.currentControlPanel = nil
                }
                controlPanel.removeFromSuperview()
            }
        }
        var oldSavedMode = menuControl.items.first!.value
        var newSavedMode = menuControl.items.first!.value
        if let oldInfo = layout {
            oldSavedMode = oldInfo.savedMode
            if let existingItem = menuControl.item(with: oldInfo.currentMode) {
                newSavedMode = existingItem.value
            }
        }
        var newLayout = Layout()
        newLayout.savedMode = newSavedMode
        newLayout.currentMode = mode
        
        switch mode {
        case .initial: // MARK: Initial
            func initControls(){
                // MARK: Gestures
                gesture.doubleTap.addTarget(self, action: #selector(self.handleTapGesture(tapGesture:)))
                gesture.doubleTap.numberOfTapsRequired = 2
                addGestureRecognizer(gesture.doubleTap)
                
                gesture.tap.addTarget(self, action: #selector(self.handleTapGesture(tapGesture:)))
                addGestureRecognizer(gesture.tap)
                
                gesture.twoFinger.addTarget(self, action: #selector(self.handleTapGesture(tapGesture:)))
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
                    glyph: ManualCaptureGlyph(type: .zoom),
                    direction: .right,
                    30
                )
                sliders.zoom.initialSensitivity = 0.4
                sliders.zoom.labelTextForValue = { (value, shouldRound) in
                    let nearest: CGFloat = (shouldRound) ? 1 : 0.1
                    let rounded = round( value / nearest ) * nearest
                    return "\( rounded )x"
                }
                sliders.zoom.actionProgressChanged = { (slider) in
                    me.sessionController.set( .zoomFactor( slider.value ) )
                }
                sliders.zoom.actionProgressStarted = { (slider) in
                    me.switchToLayout(.zoom)
                }
                
                // MARK: Focus Slider
                
                sliders.focus = SmartSlider<Float>(
                    glyph: ManualCaptureGlyph(type: .focus),
                    direction: .right,
                    startBounds: {
                        me.startBounds(
                            forType: .rightAlongBottom,
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
                    me.sessionController.set(.lensPosition(slider.value))
                }
                var previousZoom: CGFloat = 1.0
                sliders.focus.actionProgressStarted = { (_) in
                    me.menuControl.selectItem(with: .focus)
                    previousZoom = me.sessionController.camera?.videoZoomFactor ?? 1.0
                    let mag: CGFloat = me.magnifyForFocus ? 3.2 : 1
                    let newZoom = min(previousZoom * mag, 50, me.sessionController.camera?.activeFormat.videoMaxZoomFactor ?? 1.0)
                    me.sessionController.set(CSSet.zoomFactor(newZoom))
                    //me.sessionController.set(CSSet.ZoomFactorRamp(newZoom, MAXFLOAT))
                }
                sliders.focus.actionProgressEnded = { (_) in
                    me.sessionController.set(CSSet.zoomFactor(previousZoom))
                }
                
                // MARK: temperature slider
                
                sliders.temperature = SmartSlider<Float>(
                    glyph: ManualCaptureGlyph(type: .temperature),
                    direction: .right,
                    startBounds: {
                        me.startBounds(
                            forType: .rightAlongTop,
                            gestureView: self
                        )
                    },
                    sliderBounds: nil
                )
                sliders.temperature.initialSensitivity = 0.2
                sliders.temperature.labelTextForValue = { (value, shouldRound) in
                    let nearest: Float = (shouldRound) ? 100 : 1
                    let rounded = Int( round( value / nearest ) * nearest )
                    return "\( rounded )k"
                }
                sliders.temperature.actionProgressChanged = { (_) in
                    let temperatureAndTint = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(
                        temperature: me.sliders.temperature.value,
                        tint: me.sliders.tint.value
                    )
                    let whiteBalanceGains = me.sessionController._normalizeGainsForTemperatureAndTint(temperatureAndTint)
                    me.sessionController.set( .whiteBalanceGains( whiteBalanceGains ) )
                }
                sliders.temperature.actionProgressStarted = { (_) in
                    me.menuControl.selectItem(with: .whiteBalance)
                }
                
                // MARK: tint slider
                
                sliders.tint = SmartSlider<Float>(
                    glyph: ManualCaptureGlyph(type: .tint),
                    direction: .right,
                    25
                )
                sliders.tint.initialSensitivity = 0.2
                sliders.tint.labelTextForValue = { (value, shouldRound) in
                    let nearest: Float = (shouldRound) ? 10 : 1
                    let rounded = Int( round( value / nearest ) * nearest )
                    return "\( rounded )"
                }
                sliders.tint.actionProgressChanged = { (_) in
                    let temperatureAndTint = AVCaptureDevice.WhiteBalanceTemperatureAndTintValues(
                        temperature: me.sliders.temperature.value,
                        tint: me.sliders.tint.value
                    )
                    let whiteBalanceGains = me.sessionController._normalizeGainsForTemperatureAndTint(temperatureAndTint)
                    me.sessionController.set( .whiteBalanceGains( whiteBalanceGains ) )
                }
                sliders.tint.actionProgressStarted = { (_) in
                    me.menuControl.selectItem(with: .whiteBalance)
                }
                
                // MARK: iso slider
                
                sliders.iso = SmartSlider<Float>(
                    glyph: ManualCaptureGlyph(type: .iso),
                    direction: .up,
                    startBounds: {
                        me.startBounds(forType: .upAlongLeft, gestureView: me)
                    },
                    sliderBounds: nil,
                    25
                )
                sliders.iso.initialSensitivity = 0.4
                sliders.iso.labelTextForValue = { (value, shouldRound) in
                    let nearest: Float = (shouldRound) ? 25 : 1
                    let rounded = Int( round( value / nearest ) * nearest )
                    return "\( rounded )"
                }
                sliders.iso.actionProgressChanged = { (_) in
                    guard let exposureDuration = me.sliders.exposureDuration.value else {
                        print("couldn't read exposureDuration.value")
                        return
                    }
                    guard let iso = me.sliders.iso.value else {
                        print("couldn't read iso.value")
                        return
                    }
                    me.sessionController.set( .exposure( .durationAndISO( exposureDuration, iso ) ) )
                }
                sliders.iso.actionProgressStarted = { (_) in
                    me.menuControl.selectItem(with: .exposure)
                }
                sliders.iso.knobLayer.positionType = .left
                
                // MARK: exposure duration slider
                
                sliders.exposureDuration = SmartSlider <CMTime> (
                    glyph: ManualCaptureGlyph( type: .exposureDuration ),
                    direction: .up,
                    startBounds: {
                        me.startBounds (
                            forType: .upAlongRight,
                            gestureView: self
                        )
                    },
                    sliderBounds: nil,
                    42
                )
                
                sliders.exposureDuration.initialSensitivity = 0.2
                sliders.exposureDuration.labelTextForValue = { (value, shouldRound) in
                    return (shouldRound ? roundExposureDurationString : roundExposureDurationStringFast)(value)
                }
                sliders.exposureDuration.actionProgressChanged = { (_) in
                    guard let exposureDuration = me.sliders.exposureDuration.value else {
                        print("couldn't read exposureDuration.value")
                        return
                    }
                    guard let iso = me.sliders.iso.value else {
                        print("couldn't read iso.value")
                        return
                    }
                    me.sessionController.set( .exposure( .durationAndISO( exposureDuration, iso ) ) )
                }
                sliders.exposureDuration.actionProgressStarted = { (_) in
                    me.menuControl.selectItem(with: .exposure)
                }
                sliders.exposureDuration.knobLayer.positionType = .right
                
                // main sliders
                
                mainSliders[.right] = sliders.exposureDuration
                mainSliders[.left] = sliders.iso
                mainSliders[.bottom] = sliders.focus
                mainSliders[.top] = sliders.temperature
                

                
                // MARK: shutter button
                
                shutterButton.addTarget(self, action: #selector(self.shutterPressed),
                                        for: .touchUpInside)
                shutterButton.translatesAutoresizingMaskIntoConstraints = false
                shutterButton.isEnabled = false
                shutterButton.alpha = 1
                addSubview(shutterButton)
                
                // MARK: gallery button
                galleryButton.addTarget(self, action: #selector(self.galleryPressed),
                                        for: .touchUpInside)
                galleryButton.translatesAutoresizingMaskIntoConstraints = false
                galleryButton.alpha = 0.0
                addSubview(galleryButton)
                
                // MARK: undo button
                undoButton.addTarget(self, action: #selector(self.undoPressed),
                                     for: .touchUpInside)
                undoButton.translatesAutoresizingMaskIntoConstraints = false
                undoButton.alpha = 0.0
                addSubview(undoButton)
                
                // add main sliders
                
                for (key, slider) in mainSliders {
                    slider.translatesAutoresizingMaskIntoConstraints = false
                    addSubview(slider)
                    addConstraints( createConstraints(forKey: .slider( key ) ) )
                    
                    var hideTimerCount = 0
                    
                    slider.actionDidStateChange = { [unowned slider] added, removed in
                        
                        var shouldHide = true
                        switch me.layout.currentMode {
                        case .focus:
                            shouldHide = !(slider == me.sliders.focus)
                        case .exposure:
                            shouldHide = !(slider == me.sliders.iso || slider == me.sliders.exposureDuration)
                        case .whiteBalance:
                            shouldHide = !(slider == me.sliders.temperature || slider == me.sliders.tint)
                        default:break
                        }
                        
                        if added.contains(.current) && slider.alpha != 1.0{
                            UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                                slider.alpha = 1.0
                                me.layout.tempShow(slider)
                            }, completion: nil)
                            UIView.animate(withDuration: 0.2, delay: 0.0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                                me.undoButton.alpha = 1.0
                                me.layout.tempShow(me.undoButton)
                                }, completion: nil)
                        }
                        
                        if removed.contains(.current) && shouldHide {
                            let duration: TimeInterval = (Control.currentControl != nil) ? 0.2 : 0.4
                            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState, animations:  {
                                slider.alpha = 0.0
                            }, completion: nil)
                            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState, animations: {
                                //me.undoButton.alpha = 0.0
                                }, completion: nil)
                        }
                        
                    }
                    slider.actionStarted = {
                        hideTimerCount += 1
                        if slider.alpha != 1.0 {
                            UIView.animate(withDuration: 0.2) {
                                slider.alpha = 1.0
                            }
                        }
                    }
                    slider.actionEnded = { [unowned slider] in
                        delay(kMainSliderHideDelay){
                            hideTimerCount -= 1
                            if hideTimerCount == 0 {
                                slider.resignCurrentControl()
                            }
                        }
                    }
                }
                
                addConstraints(forKeys: [ .menuControl, .shutterButton, .galleryButton, .undoButton ] )
                
            }
            
            newLayout = Layout()
            
            initControls()
            
            sliders.focus.alpha = 0.0
            sliders.temperature.alpha = 0.0
            sliders.iso.alpha = 0.0
            sliders.exposureDuration.alpha = 0.0
            menuControl.alpha = 0.0
            
        case .error: // MARK: Error
            
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
                    galleryButton,
                    undoButton
                )
            )

    
            
        case .disassembleControls: // MARK: DisassembleControls
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
            
        case .assembleControls: // MARK: AssembleControls
            func assembleControls(){
                let zoomMax = min(sessionController.camera?.activeFormat.videoMaxZoomFactor ?? 1, 25)
                let zVPHandler = VPExponentialCGFloatHandler(start: 1.0, end: zoomMax) as VPHandler<CGFloat>
                sliders.zoom.vpHandler = zVPHandler
                
                let pdscale = PDScale(self, vpHandler: zVPHandler)
                /// prevent strong ownership in closures
                unowned let me = self
                pdscale.currentScale = { me.sessionController.camera?.videoZoomFactor ?? 1.0 }
                pdscale.maxScale = zoomMax
                sliders.zoom.addPDHandler("Scale", handler: pdscale)
                
                sliders.focus.vpHandler = VPFloatHandler(start: 0.0, end: 1.0)
                sliders.temperature.vpHandler = VPFloatHandler(start: 2000, end: 8000)
                sliders.tint.vpHandler = VPFloatHandler(start: -150, end: 150)
                sliders.iso.vpHandler = VPFloatHandler(start: sessionController.camera?.activeFormat.minISO ?? 0, end: sessionController.camera?.activeFormat.maxISO ?? 0)
                
                guard !kIsDemoMode else { return }
                
                let vfp: (_ progress:Float) -> CMTime = {
                    let p = pow( Double($0), kExposureDurationPower ); // Apply power function to expand slider's low-end range
                    let minDurationSeconds = max(CMTimeGetSeconds(self.sessionController.camera.activeFormat.minExposureDuration), 1 / 16000 )
                    let maxDurationSeconds = min(CMTimeGetSeconds( self.sessionController.camera.activeFormat.maxExposureDuration ), 1/5)
                    let newDurationSeconds = p * ( maxDurationSeconds - minDurationSeconds ) + minDurationSeconds // Scale from 0-1 slider range to actual duration
                    let t = CMTimeMakeWithSeconds( newDurationSeconds, preferredTimescale: 1000*1000*1000 )
                    return t
                }
                
                let pfv: (CMTime) -> Float = {
                    let time: CMTime = $0
                    var doubleValue: Double = CMTimeGetSeconds(time)
                    let minDurationSeconds = max(CMTimeGetSeconds(self.sessionController.camera.activeFormat.minExposureDuration), 1 / 16000 )
                    let maxDurationSeconds = min(CMTimeGetSeconds( self.sessionController.camera.activeFormat.maxExposureDuration ), 1/5)
                    doubleValue = max(minDurationSeconds, min(doubleValue, maxDurationSeconds))
                    let p: Double = (doubleValue - minDurationSeconds ) / ( maxDurationSeconds - minDurationSeconds )// Scale to 0-1
                    return Float(pow( p, 1/kExposureDurationPower))
                }
                
                sliders.exposureDuration.vpHandler = VPHandler(pfv: pfv, vfp: vfp)
                
                if sessionController.camera.videoZoomFactor > 1.0 {
                    sliders.zoom.value = sessionController.camera.videoZoomFactor
                    sliders.zoom.state.getUpdateTransform(false, .disabled)? (&sliders.zoom.state)
                } else {
                    sliders.zoom.state.getUpdateTransform(true, .disabled)? (&sliders.zoom.state)
                }
                
                sliders.focus.value = sessionController.camera.lensPosition
                
                let tt = sessionController.camera.temperatureAndTintValues(for: sessionController.camera.deviceWhiteBalanceGains)
                sliders.temperature.value = tt.temperature
                sliders.tint.value = tt.tint
                sliders.iso.value = sessionController.camera.iso
                sliders.exposureDuration.value = sessionController.camera.exposureDuration
                
                
                var focusVOE: Bool { return self.sessionController.camera.focusMode != .locked }
                var exposureVOE: Bool { return self.sessionController.camera.exposureMode != .custom && self.sessionController.camera.exposureMode != .locked }
                var whiteBalanceVOE: Bool { return self.sessionController.camera.whiteBalanceMode != .locked }
                
                sessionController.voBlocks.lensPosition["Slider"] = { (focusVOE) ? self.sliders.focus.value = $0 : () }
                sessionController.voBlocks.iso["Slider"] = { (exposureVOE) ? self.sliders.iso.value = $0 : () }
                sessionController.voBlocks.exposureDuration["Slider"] = { (exposureVOE) ? self.sliders.exposureDuration.value = $0 : () }
                sessionController.voBlocks.whiteBalance["Slider"] = {
                    guard whiteBalanceVOE else { return }
                    let temperatureAndTint = self.sessionController.camera.temperatureAndTintValues(for: $0)
                    self.sliders.temperature.value = temperatureAndTint.temperature
                    self.sliders.tint.value = temperatureAndTint.tint
                }
                sessionController.voBlocks.focusMode["Slider"] = {
                    let cc = ($0 != .locked)
                    self.sliders.focus.state.getUpdateTransform( cc, .computerControlled )? (&self.sliders.focus.state)
                }
                sessionController.voBlocks.exposureMode["Slider"] = {
                    let cc = ($0 != .custom)
                    self.sliders.exposureDuration.state.getUpdateTransform( cc, .computerControlled )? (&self.sliders.exposureDuration.state)
                    self.sliders.iso.state.getUpdateTransform( cc, .computerControlled )? (&self.sliders.iso.state)
                }
                sessionController.voBlocks.whiteBalanceMode["Slider"] = {
                    let cc = ($0 != .locked)
                    self.sliders.temperature.state.getUpdateTransform( cc, .computerControlled )? (&self.sliders.temperature.state)
                    self.sliders.tint.state.getUpdateTransform( cc, .computerControlled )? (&self.sliders.tint.state)
                }
            }
            
            assembleControls()
            
            newLayout.entrancePerformer = {
                me.sessionController.previewLayer.opacity = 1.0
            }
            
            newLayout.entranceCompleter = { (_) in
                me.switchToLayout(.normal, 0.2)
            }
            
            sessionController.set(.exposureMode(.continuousAutoExposure))
            sessionController.set(.focusMode(.continuousAutoFocus))
            sessionController.set(.whiteBalanceMode(.continuousAutoWhiteBalance))
            
        case .normal: // MARK: Normal
            
            
            newLayout.entrancePerformer = {
                me.menuControl.alpha = 0.0
                me.shutterButton.isEnabled = true
                me.galleryButton.isEnabled = false
            }
            
            newLayout.exitPerformer = {
                me.shutterButton.isEnabled = false
                me.galleryButton.isEnabled = true
            }
            newLayout.tempAlpha(shutterButton, 1.0, 0.15)
            newLayout.tempHide(galleryButton)
            let showReset = (
                sessionController.camera.focusMode == .locked ||
                sessionController.camera.exposureMode == .locked ||
                sessionController.camera.exposureMode == .custom ||
                sessionController.camera.whiteBalanceMode == .locked
            )
            showReset ? newLayout.tempShow(undoButton) : newLayout.tempHide(undoButton)
            
            
        case .focus: // MARK: Focus
            
            newLayout.tempShow(sliders.focus)
            //newLayout.tempShow(undoButton)
            
//            if UIApplication.sharedApplication().statusBarOrientation == .Portrait {
//                newLayout.tempAlpha(galleryButton, 0.15)
//            }
            
            let modeControl = OptionControl<AVCaptureDevice.FocusMode>(
                items: [
                    ("Manual", .locked),
                    ("Auto", .continuousAutoFocus)
                ],
                selectedValue: sessionController.camera.focusMode
            )
            
            let magSwitchControl = OptionControl<Bool>(
                items: [
                    ("Magnify Preview", true),
                    ("On", true),
                    ("Off", false)
                ],
                selectedIndex:  magnifyForFocus ? 1 : 2
            )
            magSwitchControl.minWidth = 35
            magSwitchControl.setValueAction = {
                guard magSwitchControl.selectedIndex != 0 else { magSwitchControl.selectedIndex = me.magnifyForFocus ? 1 : 2; return }
                me.magnifyForFocus = $0 }
            
            modeControl.setValueAction = { me.sessionController.set(.focusMode($0)) }
            
            let voKey = "FocusModeControl"
            
            sessionController.voBlocks.focusMode[voKey] = { modeControl.selectItem(with: $0) }
            
            newLayout.temp(root: sessionController, keyPath: \CSController.voBlocks.focusMode, key: voKey)
            
            setUpControlPanel(rows: [
                ControlPanel.Row(modeControl),
                ControlPanel.Row(magSwitchControl)
            ], &newLayout)
            
        case .exposure: // MARK: Exposure
            
            if UIApplication.shared.statusBarOrientation != .portrait {
                newLayout.tempAlpha(galleryButton, 0.15)
            }
            
            newLayout.tempShow(sliders.iso, sliders.exposureDuration)
            //newLayout.tempShow(undoButton)
        
            let modeControl = OptionControl<AVCaptureDevice.ExposureMode>(
                items: [ ("Manual", .custom), ("Auto", .continuousAutoExposure) ],
                selectedValue: me.sessionController.camera.exposureMode
            )
            modeControl.setValueAction = { me.sessionController.set(.exposureMode($0)) }
            let voKey = "ExposureModeControl"
            sessionController.voBlocks.exposureMode[voKey] = { modeControl.selectItem(with: $0) }
            newLayout.temp(root: sessionController, keyPath: \CSController.voBlocks.exposureMode, key: voKey)
            let rows: [ControlPanel.Row] = [
                ControlPanel.Row(modeControl)
            ]
            //guard menuControl.alpha > 0 else { break }
            setUpControlPanel(rows: rows, &newLayout)
            
        case .whiteBalance: // MARK: WhiteBalance
            newLayout.tempShow(sliders.temperature)
            //newLayout.tempShow(undoButton)
            let modeControl = OptionControl<AVCaptureDevice.WhiteBalanceMode>(
                items: [ ("Manual", .locked), ("Auto", .continuousAutoWhiteBalance) ],
                selectedValue: sessionController.camera.whiteBalanceMode
            )
            modeControl.setValueAction = { me.sessionController.set(.whiteBalanceMode($0)) }
            let voKey = "WhiteBalanceModeControl"
            sessionController.voBlocks.whiteBalanceMode[voKey] = { modeControl.selectItem(with: $0) }
            newLayout.temp(root: sessionController, keyPath: \CSController.voBlocks.whiteBalanceMode, key: voKey)
            let rows: [ControlPanel.Row] = [
                ControlPanel.Row(modeControl),
                ControlPanel.Row(sliders.tint)
            ]
            setUpControlPanel(rows: rows, &newLayout)
            
        case .zoom: // MARK: Zoom
            newLayout.entrancePerformer = {
                me.menuControl.alpha = 1.0
            }
            setUpControlPanel(rows: [
                ControlPanel.Row(me.sliders.zoom)
            ], &newLayout)
            
        case .aspectRatio: // MARK: AspectRatio
            
            let voKey = "AspectRatioOptionControl"
            
            let modeItems: [OptionControl<CSAspectRatioMode>.Item] = [
                ("Lock", .lock),
                ("Fullscreen", .fullscreen),
                ("Sensor", .sensor)]
            let modeControl = OptionControl<CSAspectRatioMode>(items: modeItems, selectedValue: sessionController.aspectRatioMode)

            modeControl.setValueAction = {
                guard me.sessionController.aspectRatioMode != $0 else { return }
                me.sessionController.set(.aspectRatioMode($0))
            }
            
            let optionControl = OptionControl<CSAspectRatio>(
                
                items: kAspectRatiosControlItems,
                
                selectedValue: sessionController.aspectRatio
                
            )
            
            let isTemp = me.menuControl.alpha != 1
            optionControl.setValueAction = {
                guard me.sessionController.aspectRatio != $0 else { return }
                me.sessionController.set(.aspectRatio($0))
                if isTemp { me.switchToLayout(.normal) }
            }
            
            me.sessionController.voBlocks.aspectRatio[voKey] = { optionControl.selectItem(with: $0) }
            me.sessionController.voBlocks.aspectRatioMode[voKey] = { modeControl.selectItem(with: $0) }
            
//            newLayout.temp(&me.sessionController.voBlocks.aspectRatio[voKey])
//            newLayout.temp(&me.sessionController.voBlocks.aspectRatioMode[voKey])
//
            newLayout.temp(root: me, keyPath: \CaptureView.sessionController.voBlocks.aspectRatio, key: voKey)
            newLayout.temp(root: me, keyPath: \CaptureView.sessionController.voBlocks.aspectRatioMode, key: voKey)
            
            let showReset = (
                sessionController.camera.focusMode == .locked ||
                    sessionController.camera.exposureMode == .locked ||
                    sessionController.camera.exposureMode == .custom ||
                    sessionController.camera.whiteBalanceMode == .locked
            ) && isTemp
            
            showReset ? newLayout.tempShow(undoButton) : ()
        
            let ep = newLayout.entrancePerformer
            let exp = newLayout.exitPerformer
            newLayout.entrancePerformer = {
                ep()
                me.shutterButton.alpha = 0.15 + (1-0.15) * (1 - me.menuControl.alpha)
                me.galleryButton.alpha = me.menuControl.alpha
            }
            
            newLayout.exitPerformer = {
                exp()
                me.shutterButton.alpha = 0.15 + (1-0.15) * (1 - me.menuControl.alpha)
                me.galleryButton.alpha = me.menuControl.alpha
            }
            
            setUpControlPanel(rows: [
                ControlPanel.Row(modeControl),
                ControlPanel.Row(optionControl)
            ], &newLayout)
            
        case .options: // MARK: Options
            newLayout.entranceStarter = {
                me.switchToLayout(me.menuControl.value ?? .focus)
            }
            newLayout.entrancePerformer = {
                me.menuControl.alpha = 1.0
                me.galleryButton.alpha = 1.0
                me.galleryButton.isEnabled = true
            }
        case .shortcut: break
        case .fullscreen: break
        }
        me.layout = newLayout
    }
    
    var layout: Layout!
    
    func switchToLayout(_ layoutMode:Layout.Mode, _ duration: TimeInterval = 0.2) {
        
        guard layout.currentMode != layoutMode else {return}
        
        CATransaction.begin()
        
        CATransaction.setDisableActions(false)
        
        CATransaction.setAnimationDuration(duration)
        
        UIView.animate(withDuration: duration,
            delay: 0.0,
            options: .beginFromCurrentState,
            animations: layout.exitPerformer,
            completion: layout.exitCompleter)
        
        
        
        CATransaction.commit()
        
        
        
        setUpLayout(forMode:layoutMode)
        
        if let i = OptionControl.indexOfItem(with: layoutMode, items: menuControl.items) {
            menuControl.selectedIndex = i
        }
        
        
        
        CATransaction.begin()
        
        CATransaction.setDisableActions(false)
        
        CATransaction.setAnimationDuration(duration)
        
        
        
        UIView.animate(withDuration: duration,
            delay: 0.0,
            options: .beginFromCurrentState,
            animations: layout.entrancePerformer,
            completion: layout.entranceCompleter)
        
        
        
        CATransaction.commit()
        
        
        
        layout.entranceStarter()
        
    }

    
    
    
//    override var frame: CGRect {
//        
//        didSet {
//            
//            guard frame != oldValue else { return }
//            
//            //sessionController.previewLayer.frame = layer.bounds
//            
//            updateConstraintsForKeys(
//                [
//                    .Slider(.Top),
//                    .Slider(.Bottom),
//                    .Slider(.Left),
//                    .Slider(.Right),
//                    .ShutterButton,
//                    .MenuControl,
//                    .GalleryButton,
//                    .ControlPanel
//                ]
//            )
//            
//        }
//        
//    }
    
    
    
    enum ConstraintKey : CustomStringConvertible {
        var description : String {
            switch self {
            // Use Internationalization, as appropriate.
            case .slider(let pType):
                switch pType {
                case .top: return "Slider(Top)"
                case .right: return "Slider(Right)"
                case .bottom: return "Slider(Bottom)"
                case .left: return "Slider(Left)"
                }
            case .shutterButton: return "ShutterButton"
            case .galleryButton: return "GalleryButton"
            case .undoButton: return "UndoButton"
            case .controlPanel: return "ControlPanel"
            case .menuControl: return "MenuControl"
            }
        }
        case slider(MainSliderPositionType)
        case shutterButton, galleryButton, undoButton
        case controlPanel
        case menuControl
    }
    
    
    func createConstraints(forKey key:ConstraintKey) -> [NSLayoutConstraint] {
        
        let orientation = UIApplication.shared.statusBarOrientation
        
        var constraints: [NSLayoutConstraint] = []
        
        let sDistance = kSliderKnobMargin + kSliderKnobRadius + 2
        
        
        
        let xMargin: CGFloat = 15
        
        let yMargin: CGFloat = (orientation == .portrait) ? 60 : 15
        
        let mx = 2 * sDistance + xMargin
        let my = 2 * sDistance + yMargin
        
        
        
        switch key {
            
            
            
        case .menuControl: // MARK: MenuControl
            
            
            
            let sHeight = (orientation != .portrait) ? my + 5 : 15//my + 5//35
            
            let hConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "H:|->=M-[MC(==350@250)]->=M-|",
                options: .directionLeftToRight,
                metrics: ["M" : 0/*mx - 5*/],
                views: ["MC" : menuControl]
                
            )
            
            let centerXConstraint = NSLayoutConstraint(
                
                item: menuControl,
                attribute: .centerX,
                relatedBy: .equal,
                
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            
            )
            
            let yConstraint = NSLayoutConstraint(
                
                item: menuControl,
                attribute: NSLayoutConstraint.Attribute.topMargin,
                relatedBy: NSLayoutConstraint.Relation.equal,
                
                toItem: self,
                attribute: NSLayoutConstraint.Attribute.top,
                multiplier: 1,
                constant: sHeight
            
            )
            
            constraints.append(contentsOf: hConstraints)
            constraints.append(centerXConstraint)
            constraints.append(yConstraint)
            
            
            
        case .controlPanel: // MARK: ControlPanel
            
            
            
            let sHeight = my
            
            guard let controlPanel = currentControlPanel else {
                break
            }
            
            let centerXConstraint = NSLayoutConstraint(
                
                item: controlPanel,
                attribute: .centerX,
                relatedBy: .equal,
                
                toItem: self,
                attribute: .centerX,
                multiplier: 1,
                constant: 0
            
            )
            
            let yConstraint = NSLayoutConstraint(
                
                item: controlPanel,
                attribute: .bottomMargin,
                relatedBy: .equal,
                
                toItem: self,
                attribute: .bottomMargin,
                multiplier: 1,
                constant: -sHeight
            
            )
            
            constraints.append(centerXConstraint)
            constraints.append(yConstraint)
            
            
            
            
            
        case .shutterButton: // MARK: ShutterButton
            
            
            
//            let sWidth = xMargin
            
            let sideAttribute: NSLayoutConstraint.Attribute
            let sideMargin: CGFloat
            let centerAttribute: NSLayoutConstraint.Attribute
            
            switch orientation {
            case .landscapeLeft:
                sideAttribute = .leftMargin
                sideMargin = 15
                centerAttribute = .centerY
            case .landscapeRight:
                sideAttribute = .rightMargin
                sideMargin = -15
                centerAttribute = .centerY
            default:
                sideAttribute = .bottomMargin
                sideMargin = -15
                centerAttribute = .centerX
            }
            
            let center = NSLayoutConstraint(item: shutterButton, attribute: centerAttribute,
                relation: .equal,
                toItem: self, attribute: centerAttribute)
            
            let side = NSLayoutConstraint(item: shutterButton, attribute: sideAttribute,
                relatedBy: .equal,
                toItem: self, attribute: sideAttribute,
                multiplier: 1, constant: sideMargin)
            
            constraints += [side, center]
            
            
            
            
            
        case .galleryButton: // MARK: GalleryButton

            let offsetAttribute: NSLayoutConstraint.Attribute
            let offsetToAttribute: NSLayoutConstraint.Attribute
            let offsetAmount: CGFloat
            let alignAttribute: NSLayoutConstraint.Attribute
            let distance: CGFloat = 20
            switch orientation {
            case .landscapeLeft:
                offsetAttribute = .bottom
                offsetToAttribute = .top
                offsetAmount = -distance
                alignAttribute = .left
            case .landscapeRight:
                offsetAttribute = .top
                offsetToAttribute = .bottom
                offsetAmount = distance
                alignAttribute = .right
            default:
                offsetAttribute = .right
                offsetToAttribute = .left
                offsetAmount = -distance
                alignAttribute = .bottom
            }
            
            let offset = NSLayoutConstraint(item: galleryButton, attribute: offsetAttribute,
                                            relatedBy: .equal,
                toItem: shutterButton, attribute: offsetToAttribute,
                multiplier: 1, constant: offsetAmount)
            
            let align = NSLayoutConstraint(item: galleryButton, attribute: alignAttribute,
                                           relation: .equal,
                toItem: shutterButton, attribute: alignAttribute)
            
            constraints.append(contentsOf: [align, offset])
            
            
            
            
            
        case .undoButton: // MARK: UndoButton
            
            let v = NSLayoutConstraint.constraints(withVisualFormat: "V:[U]-15-|", options: .directionLeftToRight, metrics: nil, views: ["U":undoButton])
            
            let h = NSLayoutConstraint.constraints(withVisualFormat: "H:[U]-15-|", options: .directionLeftToRight, metrics: nil, views: ["U":undoButton])
            
            constraints += h + v
            
            
            
        case .slider(.left): // MARK: Slider(.Left)
            
            
            
            guard let slider = mainSliders[.left] else { break }
            
            let hConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "H:|-x-[S]",
                options: .directionLeftToRight,
                metrics: [ "x" : xMargin ],
                views: [ "S" : slider ]
                
            )
            
            let vConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "V:|->=m-[S(>=300@750)]->=m-|",
                options: .directionLeftToRight,
                metrics: [ "m" : my + 25 ],
                views: [ "S" : slider ]
            
            )
            
            let lowPriorityCenterYConstraint = NSLayoutConstraint(
                item: slider,
                attribute: .centerY, relatedBy: .equal,
                toItem: self,
                attribute: .centerY, multiplier: 1, constant: 0
            )
            lowPriorityCenterYConstraint.priority = UILayoutPriority.defaultLow
            
            constraints.append(lowPriorityCenterYConstraint)
            constraints.append(contentsOf: hConstraints)
            constraints.append(contentsOf: vConstraints)
            
            
            
            
            
        case .slider(.right): // MARK: Slider(.Right)
            
            
            
            guard let slider = mainSliders[.right] else { break }
            
            let hConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "H:[S]-x-|",
                options: .directionLeftToRight,
                metrics: [ "x" : xMargin ],
                views: [ "S" : slider ]
            
            )
            
            let vConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "V:|->=m-[S(>=300@750)]->=m-|",
                options: .directionLeftToRight,
                metrics: [ "m" : my + 25 ],
                views: [ "S" : slider ]
            
            )
            
            let lowPriorityCenterYConstraint = NSLayoutConstraint(
                item: slider,
                attribute: .centerY, relatedBy: .equal,
                toItem: self,
                attribute: .centerY, multiplier: 1, constant: 0
            )
            lowPriorityCenterYConstraint.priority = UILayoutPriority.defaultLow
            
            constraints.append(lowPriorityCenterYConstraint)
            constraints.append(contentsOf: hConstraints)
            constraints.append(contentsOf: vConstraints)
            
            
            
            
            
        case .slider(.bottom): // MARK: Slider(.Bottom)
            
            guard let slider = mainSliders[.bottom] else { break }
            
            let vConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "V:[S]-y-|",
                options: .directionLeftToRight,
                metrics: [ "y" : yMargin ],
                views: [ "S" : slider ]
            
            )
            
            let hConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "H:|->=m-[S(>=300@750)]->=m-|",
                options: .directionLeftToRight,
                metrics: [ "m" : mx ],
                views: [ "S" : slider ]
            
            )
            
            let lowPriorityCenterXConstraint = NSLayoutConstraint(
                item: slider,
                attribute: .centerX, relatedBy: .equal,
                toItem: self,
                attribute: .centerX, multiplier: 1, constant: 0
            )
            lowPriorityCenterXConstraint.priority = UILayoutPriority.defaultLow
            
            constraints.append(lowPriorityCenterXConstraint)
            constraints.append(contentsOf: hConstraints)
            constraints.append(contentsOf: vConstraints)
            
        case .slider(.top): // MARK: slider(.top)
            
            guard let slider = mainSliders[.top] else { break }
            
            let vConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "V:|-y-[S]",
                options: .directionLeftToRight,
                metrics: [ "y" : yMargin ],
                views: [ "S":slider ]
            
            )
            
            let hConstraints = NSLayoutConstraint.constraints(
                
                withVisualFormat: "H:|->=m-[S(>=300@750)]->=m-|",
                options: .directionLeftToRight,
                metrics: ["m": mx],
                views: ["S":slider]
            
            )
            
            let lowPriorityCenterXConstraint = NSLayoutConstraint(
                item: slider,
                attribute: .centerX, relatedBy: .equal,
                toItem: self,
                attribute: .centerX, multiplier: 1, constant: 0
            )
            lowPriorityCenterXConstraint.priority = UILayoutPriority.defaultLow
            
            constraints.append(lowPriorityCenterXConstraint)
            constraints.append(contentsOf: hConstraints)
            constraints.append(contentsOf: vConstraints)
         
            
            
        }
        for constraint in constraints {
            constraint.identifier = key.description
        }
        return constraints
    }
    
    
    func addConstraints(forKeys keys: [ConstraintKey] ) {
        for key in keys {
            addConstraints( createConstraints(forKey: key ) )
        }
    }
    
    
    func getConstraints(forKeys keys: [ConstraintKey] ) -> [NSLayoutConstraint] {
        let returnConstraints = constraints.filter { (constraint) in
            guard let id = constraint.identifier else { return false }
            for key in keys {
                if key.description == id {
                    return true
                }
            }
            return false
        }
        return returnConstraints
    }
    
    
    func updateConstraints(forKeys keys:[ConstraintKey]) {
        removeConstraints( getConstraints(forKeys: keys) )
        addConstraints(forKeys: keys)
    }
    
    struct Layout {
        typealias Init = () -> Void
        typealias Performer = () -> Void
        typealias Completer = (Bool) -> Void
        
        enum Mode {
            case initial
            case error
            case disassembleControls
            case assembleControls
            case normal
            case focus
            case exposure
            case whiteBalance
            case zoom
            case aspectRatio
            case options
            case shortcut
            case fullscreen
        }
        
        static func appendPerformer (_ performer: inout Performer, appendedPerformer: @escaping Performer) {
            let previousPerformer = performer
            performer = { previousPerformer(); appendedPerformer() }
        }
        
        static func appendCompleter (_ completer: inout Completer, appendedCompleter: @escaping Completer) {
            let previousCompleter = completer
            completer = { previousCompleter($0); appendedCompleter($0) }
        }
        
        static func fusePerformers(_ performers: Performer...) -> Performer {
            return performers.reduce({}) { left, right in
                { left(); right() }
            }
        }
        
        static func alphaPerformer(_ alpha: CGFloat = 0.0, views: UIView...) -> Performer {
            var performer: Performer = {}
            views.forEach { (view: UIView) in
                Layout.appendPerformer(&performer) { [unowned view] in
                    view.alpha = alpha
                }
            }
            return performer
        }
        
        static func opacityPerformer(_ opacity: Float = 0.0, layers: CALayer...) -> Performer {
            var performer: Performer = {}
            layers.forEach { (layer: CALayer) in
                Layout.appendPerformer(&performer) { [unowned layer] in
                    layer.opacity = opacity
                }
            }
            return performer
        }
        
        mutating func tempShow(_ views: UIView...) {
            views.forEach { (view: UIView) in
                self.tempAlpha(view, 1.0, 0.0)
            }
        }
        
        mutating func tempHide(_ views: UIView...) {
            views.forEach { (view: UIView) in
                self.tempAlpha(view, 0.0)
            }
        }
        
//        /// sets optional to nil on exitCompletion
//        mutating func temp<Optional>(_ optional: inout Optional?) {
//            Layout.appendCompleter(&exitCompleter) { _ in
//                optional = nil
//            }
//        }
        
        mutating func temp<Root, Value>(root: Root, keyPath: ReferenceWritableKeyPath<Root, Value?>) {
            Layout.appendCompleter(&exitCompleter) { _ in
                root[keyPath: keyPath] = nil
            }
        }
        
        mutating func temp<Root, Value> (root: Root, keyPath: ReferenceWritableKeyPath<Root, [String : Value]>,
                                         key: String) {
            Layout.appendCompleter(&exitCompleter) { _ in
                root[keyPath: keyPath][key] = nil
            }
        }
        
        mutating func tempAlpha(_ view: UIView, _ temporaryAlpha: CGFloat, _ resetAlpha: CGFloat? = nil ) {
            let resetAlpha = resetAlpha ?? view.alpha
            
            Layout.appendPerformer(&entrancePerformer) { // [unowned view] in
                view.alpha = temporaryAlpha
            }
            Layout.appendPerformer(&exitPerformer) { // [unowned view] in
                view.alpha = resetAlpha
            }
        }
        
        var entranceStarter: Init = {}
        var entrancePerformer: Performer = {}
        var entranceCompleter: Completer = {$0}
        var exitPerformer: Performer = {}
        var exitCompleter: Completer = {$0}
        var savedMode: Mode = .focus
        var currentMode: Mode = .initial
        
    }
    
}


