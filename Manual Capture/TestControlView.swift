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
        
        super.init(frame:frame)
        
        sessionController.delegate = self
        sessionController.previewLayer.backgroundColor = UIColor.blackColor().CGColor
        //sessionController.previewLayer.opacity = 0.0
        layer.addSublayer(sessionController.previewLayer)
        sessionController.previewLayer.frame = bounds
        
        self.layer.opacity = 0.0
        self.backgroundColor = UIColor.blackColor()
        
        initControls()
        
        setUpLayoutInfoForMode(.Initial)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gesture Related
    
    var tapGesture: UITapGestureRecognizer!
    var doubleTapGesture: UIShortTapGestureRecognizer!
    var twoFingerTapGesture: UITapGestureRecognizer!
    
    override func addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
        super.addGestureRecognizer(gestureRecognizer)
        gestureRecognizer.delegate = self
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if let cp = currentControlPanel where touch.view!.isDescendantOfView(cp) {
            return false
        }
        if touch.view!.isKindOfClass(UIButton) || touch.view!.isKindOfClass(CaptureControlPanel) {
            return false// allows button to recieve touch down for button pressed look
        }
        return true
    }
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOfGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return (
            gestureRecognizer == tapGesture &&
            otherGestureRecognizer == doubleTapGesture &&
            layoutInfo.currentMode == .AspectRatio
        )
    }
    
    func handleTapGesture(tapGesture: UITapGestureRecognizer){
        switch tapGesture.numberOfTapsRequired {
        case 1 where tapGesture.numberOfTouchesRequired == 1 : switchToLayout(
                (layoutInfo.currentMode == .Normal) ? .Options : .Normal
            )
        case 2:
            switchToLayout(.AspectRatio)
            if sessionController.cropAspectRatio == CSCAspectRatio(16, 9) {
                sessionController.cropAspectRatio = CSCAspectRatio(4, 3)
            }else if sessionController.cropAspectRatio == CSCAspectRatio(4, 3) {
                sessionController.cropAspectRatio = CSCAspectRatio(1, 1)
            }else if sessionController.cropAspectRatio == CSCAspectRatio(1, 1) {
                sessionController.cropAspectRatio = CSCAspectRatio(3, 2)
            }else{
                sessionController.cropAspectRatio = CSCAspectRatio(16, 9)
            }
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
    var shutterButton = UIButton.shutterButton()
    
    // MARK: Actions
    
    func shutterPressed() {
        sessionController.captureStillPhoto()
    }
    
    // MARK: CaptureSessionControllerDelegate
    
    func sessionControllerError(error: ErrorType) {
        print(error)
    }
    func sessionControllerNotification(notification: CSCNotification) {
        switch notification {
        case .capturingStillImage(true):
            
            CATransaction.disableActions {
                self.layer.opacity = 0.0
            }
            UIView.animateWithDuration(0.25, animations: {
                self.layer.opacity = 1.0
            })
            
        case .sessionRunning(true):
            
            configControls()
            UIView.animateWithDuration(0.6, animations: {
                //self.sessionController.previewLayer.opacity = 1.0
                self.layer.opacity = 1.0
                }){$0; if(self.layoutInfo.currentMode == .Initial){ self.switchToLayout(.Normal, 0.2) }}
            
        case .sessionRunning(false):
            
            switchToLayout(.Initial)
            
        // camera properties
        case .change(.cameraExposure(.ISO(let ISO))):
            
            guard sliders.iso.state.hasProperty(.ComputerControlled) else { break }
            sliders.iso.value = ISO
            
        case .change(.cameraLensPosition(let lensPosition)):
            
            guard sliders.focus.state.hasProperty(.ComputerControlled) else { break }
            sliders.focus.value = lensPosition
            
        case .change(.cameraExposure(.duration(let duration))):
            
            guard sliders.exposureDuration.state.hasProperty(.ComputerControlled) else { break }
            sliders.exposureDuration.value = duration
            
        case .change(.cameraWhiteBalanceGains(let wbgains)):
            
            guard sliders.temperature.state.hasProperty(.ComputerControlled) else { break }
            let temperatureAndTint = self.sessionController.camera.temperatureAndTintValuesForDeviceWhiteBalanceGains(wbgains)
            sliders.temperature.value = temperatureAndTint.temperature
            sliders.tint.value = temperatureAndTint.tint
            
        // camera modes
        case .change(.cameraFocusMode(let focusMode)):
            
            let computerControlled = ( focusMode != .Locked )
            sliders.focus.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&sliders.focus.state)
            
        case .change(.cameraExposureMode(let exposureMode)):
            
            let computerControlled = ( exposureMode != .Locked && exposureMode != .Custom )
            sliders.iso.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&sliders.iso.state)
            sliders.exposureDuration.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&sliders.exposureDuration.state)
            
        case .change(.cameraWhiteBalanceMode(let whiteBalanceMode)):
            
            let computerControlled = ( whiteBalanceMode != .Locked )
            sliders.temperature.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&sliders.temperature.state)
            sliders.tint.state.getUpdateTransform( computerControlled, .ComputerControlled )? (&sliders.tint.state)
            
        case .change(.cameraExposure(.targetOffset(_))): break // stop print messages for these
        default: print(notification) // break
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
    
    func initControls(){
        doubleTapGesture = UIShortTapGestureRecognizer(target: self, action: "handleTapGesture:")
        doubleTapGesture.numberOfTapsRequired = 2
        addGestureRecognizer(doubleTapGesture)
        
        tapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        addGestureRecognizer(tapGesture)
        
        twoFingerTapGesture = UITapGestureRecognizer(target: self, action: "handleTapGesture:")
        twoFingerTapGesture.numberOfTouchesRequired = 2
        addGestureRecognizer(twoFingerTapGesture)
        
        menuControl.setValueAction = {self.switchToLayout($0)}
        menuControl.translatesAutoresizingMaskIntoConstraints = false
        //menuControl.backgroundColor = UIColor.redColor()
        addSubview(menuControl)
        
        sliders.zoom = SmartSlider<CGFloat>(
            glyph: ManualCaptureGlyph(type: .Zoom),
            direction: .Right,
            startBounds: nil,
            sliderBounds: nil,
            30
        )
        sliders.zoom.initialSensitivity = 0.5
        sliders.zoom.labelTextForValue = {
            if $1 {
                return "\(round($0 * 5) / 5)x"
            }else{
                return "\(round($0 * 10) / 10 )x"
            }
        }
        sliders.zoom.actionProgressChanged = {[weak self](slider) in
            self?.sessionController.set(CSCSet.cameraZoomFactor(CGFloat(slider.value)))
        }
        sliders.zoom.actionProgressStarted = {[weak self](slider) in self?.switchToLayout(.Zoom)}
        
        sliders.focus = SmartSlider<Float>(
            glyph: ManualCaptureGlyph(type: .Focus),
            direction: .Right,
            startBounds: {[unowned self] in self.startBoundsForType(.RightAlongBottom, edgeDistance: 160, gestureView: self)},
            sliderBounds: nil//{[unowned self] in self.sliderBoundsForType(.Bottom)}
        )
        sliders.focus.initialSensitivity = 0.75
        sliders.focus.labelTextForValue = {"\(Int(round($0 * 100 / ($1 ? 10 : 1) ) * ($1 ? 10 : 1) ))%"
        }
        sliders.focus.actionProgressChanged = {[weak self](slider) in
            self?.sessionController.set(.cameraLensPosition(slider.value))
        }
        sliders.focus.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.Focus) }
        
        sliders.temperature = SmartSlider<Float>(
            glyph: ManualCaptureGlyph(type: .Temperature),
            direction: .Right,
            startBounds: {[unowned self] in self.startBoundsForType(.RightAlongTop, edgeDistance: 160, gestureView: self)},
            sliderBounds: nil//{[unowned self] in self.sliderBoundsForType(.Top)}
        )
        sliders.temperature.initialSensitivity = 0.3
        sliders.temperature.labelTextForValue = {"\(Int( round( $0 / ($1 ? 100 : 1) ) * ($1 ? 100 : 1) ))k"}
        sliders.temperature.actionProgressChanged = {[weak self](slider) in
            let temperatureAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: self!.sliders.temperature.value, tint: self!.sliders.tint.value)
            let wbgains = self!._normalizeGainsForTemperatureAndTint(temperatureAndTint)
            self?.sessionController.set(.cameraWhiteBalanceGains(wbgains))
        }
        sliders.temperature.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.WhiteBalance) }
        
        sliders.tint = SmartSlider<Float>(
            glyph: ManualCaptureGlyph(type: .Tint),
            direction: .Right,
            startBounds: nil,
            sliderBounds: nil,
            25
        )
        sliders.tint.initialSensitivity = 0.3
        sliders.tint.labelTextForValue = {"\(Int( round( $0 / ($1 ? 10 : 1) ) * ($1 ? 10 : 1) ))"}
        sliders.tint.actionProgressChanged = {[weak self](slider) in
            let temperatureAndTint = AVCaptureWhiteBalanceTemperatureAndTintValues(temperature: self!.sliders.temperature.value, tint: self!.sliders.tint.value)
            let wbgains = self!._normalizeGainsForTemperatureAndTint(temperatureAndTint)
            self?.sessionController.set(.cameraWhiteBalanceGains(wbgains))
        }
        sliders.tint.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.WhiteBalance) }
        
        sliders.iso = SmartSlider<Float>(
            glyph: ManualCaptureGlyph(type: .ISO),
            direction: .Up,
            startBounds: {[unowned self] in self.startBoundsForType(.UpAlongLeft, edgeDistance: 240, gestureView: self)},
            sliderBounds: nil,//{[unowned self] in self.sliderBoundsForType(.Left)},
            25
        )
        sliders.iso.initialSensitivity = 0.6
        sliders.iso.labelTextForValue = {
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
        sliders.iso.actionProgressChanged = {[weak self](slider) in
            self?.sessionController.set(.cameraExposure(.durationAndISO(self!.sliders.exposureDuration.value, self!.sliders.iso.value)))
        }
        sliders.iso.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.Exposure) }
        sliders.iso.knobLayer.positionType = .Left
        
        sliders.exposureDuration = SmartSlider<CMTime>(
            glyph: ManualCaptureGlyph(type: .ExposureDuration),
            direction: .Up,
            startBounds: {[unowned self] in self.startBoundsForType(.UpAlongRight, edgeDistance: 240, gestureView: self)},
            sliderBounds: nil,//{[unowned self] in self.sliderBoundsForType(.Right)},
            52
            )
        sliders.exposureDuration.initialSensitivity = 0.2
        sliders.exposureDuration.labelTextForValue = {
            if($1){
                return roundExposureDurationString($0)
            }else {
                return roundExposureDurationStringFast($0)
            }
        }
        sliders.exposureDuration.actionProgressChanged = {[weak self](slider) in
            self?.sessionController.set(.cameraExposure(.durationAndISO(self!.sliders.exposureDuration.value, self!.sliders.iso.value)))
        }
        sliders.exposureDuration.actionProgressStarted = {[weak self](_) in self?.switchToLayout(.Exposure) }
        sliders.exposureDuration.knobLayer.positionType = .Right
        //sliders.exposureDuration.knobLayer.anchorPoint = CGPoint(x: 1.0 - (sliders.iso.knobLayer.frame.height / (2 * sliders.iso.knobLayer.frame.width)), y: 0.5)
        
        mainSliders[.Right] = sliders.exposureDuration
        mainSliders[.Left] = sliders.iso
        mainSliders[.Bottom] = sliders.focus
        mainSliders[.Top] = sliders.temperature
        
        shutterButton.addTarget(self, action: "shutterPressed", forControlEvents: UIControlEvents.TouchUpInside)
        shutterButton.translatesAutoresizingMaskIntoConstraints = false
        shutterButton.enabled = false
        shutterButton.alpha = 0.0
        addSubview(shutterButton)
        
        for (key, slider) in mainSliders {
            slider.translatesAutoresizingMaskIntoConstraints = false
            addSubview(slider)
            addConstraints(createConstraintsForKey(.Slider(key)))
        }
        
        addConstraintsForKeys([.MenuControl, .ShutterButton])
        
        // switchToLayout(.Normal)
    }
    func configControls(){
        sessionController.set(.cameraExposure(.bias(-0.5)))
        
        
        let zoomMax = min(sessionController.camera.activeFormat.videoMaxZoomFactor, 25)
        let zVPHandler = VPExponentialCGFloatHandler(start: 1.0, end: zoomMax) as VPHandler<CGFloat>
        sliders.zoom.vpHandler = zVPHandler
        
        let pdscale = PDScale(self, vpHandler: zVPHandler)
        pdscale.currentScale = {[unowned self] in self.sessionController.camera.videoZoomFactor }
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
    }
    
    private let menuControl = OptionControl<LayoutMode>(items: [
        ("Focus", .Focus),
        ("Zoom", .Zoom),
        ("Exposure", .Exposure),
        ("WB", .WhiteBalance),
        ("Aspect Ratio", .AspectRatio) ]
    )
    private var currentControlPanel: CaptureControlPanel?
    
    // MARK: Layout Related
    private enum LayoutMode {
        case Initial, Normal, Focus, Exposure, WhiteBalance, Zoom, AspectRatio, Options, Fullscreen
    }
    private func setUpLayoutInfoForMode(mode:LayoutMode) -> Void {
        var me: TestControlView {unowned let me = self; return me}
        typealias VO = (key:String, type:CSCValueType)
        func fuseLayoutPerformers(first: LayoutPerformer, second: LayoutPerformer) -> LayoutPerformer {
            return { first();second() }
        }
        func fuseLayoutCompleters(first: LayoutCompleter, second: LayoutCompleter) -> LayoutCompleter {
            return { first($0);second($0) }
        }
        func setUpControlPanelEntranceExit(rows:[CaptureControlPanelRow], inout _ layoutInfo: LayoutInfo) {
            
            CATransaction.begin()
            CATransaction.disableActions()
            
            let cp = CaptureControlPanel(
                rows: rows,
                frame: CGRectMake(0, 20, self.bounds.width, 50)
            )
            cp.translatesAutoresizingMaskIntoConstraints = false
            cp.alpha = 0.0
            self.addSubview(cp)
            self.currentControlPanel = cp
            self.addConstraintsForKeys([.ControlPanel])
            CATransaction.commit()
            
            layoutInfo.entrancePerformer = fuseLayoutPerformers(layoutInfo.entrancePerformer){ //[unowned self] in
                guard let controlPanel = me.currentControlPanel where controlPanel == cp else { return }
                controlPanel.alpha = 1.0
            }
            layoutInfo.exitPerformer = fuseLayoutPerformers(layoutInfo.exitPerformer){ //[unowned self] in
                guard let controlPanel = me.currentControlPanel where controlPanel == cp else { return }
                controlPanel.alpha = 0.0
            }
            layoutInfo.exitCompleter = fuseLayoutCompleters(layoutInfo.exitCompleter){ (_) in
                guard let controlPanel = me.currentControlPanel where controlPanel == cp else { return }
                controlPanel.removeFromSuperview()
                //guard let controlPanel = me.currentControlPanel where controlPanel == cp else { return }
                me.currentControlPanel = nil
            }
        }
        
        var info: LayoutInfo = layoutInfo ?? (
            {},
            {},
            {$0},
            {},
            {$0},
            .Focus,
            .Initial
        )
        
        info.entranceStarter = {}
        info.entrancePerformer = {}
        info.entranceCompleter = {$0}
        info.exitPerformer = {}
        info.exitCompleter = {$0}
        let oldSaveMode = info.savedMode
        info.savedMode = info.currentMode
        info.currentMode = mode
        
        switch mode {
        case .Initial:
            info.exitPerformer = {
                me.sliders.focus.alpha = 0.0
                me.sliders.temperature.alpha = 0.0
                me.sliders.iso.alpha = 0.0
                me.sliders.exposureDuration.alpha = 0.0
                me.shutterButton.enabled = true
                me.shutterButton.alpha = 1.0
            }
        case .Normal:
            info.entrancePerformer = {
                me.shutterButton.enabled = true
                me.shutterButton.alpha = 1.0
                me.menuControl.alpha = 0.0
            }
            info.exitPerformer = {
                me.shutterButton.enabled = false
                me.shutterButton.alpha = 0.15
            }
        case .Focus:
            let modeVO: VO = ("FocusModeControl", .cameraFocusMode)
            let modeControl = OptionControl<AVCaptureFocusMode>(
                items: [("Manual", .Locked), ("Auto", .ContinuousAutoFocus)],
                selectedValue: me.sessionController.camera.focusMode
            )
            modeControl.setValueAction = { (fmode) in
                me.sessionController.set(.cameraFocusMode(fmode))
            }
            me.sessionController.setValueObservingBlockFor(modeVO.type, key: modeVO.key) { [weak modeControl] in
                switch $0 {
                case .cameraFocusMode(let fmode):
                    modeControl?.selectItemWithValue(fmode)
                default: return
                }
            }
            info.entrancePerformer = {
                me.sliders.focus.hidden = false
                me.sliders.focus.alpha = 1.0
            }
            info.exitPerformer = {
                me.sliders.focus.alpha = 0.0
            }
            info.exitCompleter = { (_) in
                me.sliders.focus.hidden = true
                me.sessionController.removeValueObservingBlockFor(modeVO.type, key: modeVO.key)
            }
            //guard menuControl.alpha > 0 else { break }
            setUpControlPanelEntranceExit([
                CaptureControlPanelRow.fromOptionControl(modeControl)
                ], &info)
        case .Exposure:
            let modeVO: VO = ("ExposureModeControl", .cameraExposureMode)
            let modeControl = OptionControl<AVCaptureExposureMode>(
                items: [ ("Manual", .Custom), ("Auto", .ContinuousAutoExposure) ],
                selectedValue: me.sessionController.camera.exposureMode
            )
            modeControl.setValueAction = { (emode) in
                me.sessionController.set(.cameraExposureMode(emode))
            }
            me.sessionController.setValueObservingBlockFor(modeVO.type, key: modeVO.key){ [weak modeControl] in
                switch $0 {
                case .cameraExposureMode(let emode):
                    modeControl?.selectItemWithValue(emode) ?? print("didNotFind:\(emode)")
                default: return
                }
            }
            
            info.entrancePerformer = {
                me.sliders.iso.hidden = false
                me.sliders.iso.alpha = 1.0
                me.sliders.exposureDuration.hidden = false; me.sliders.exposureDuration.alpha = 1.0
            }
            info.exitPerformer = {
                me.sliders.iso.alpha = 0.0
                me.sliders.exposureDuration.alpha = 0.0
            }
            info.exitCompleter = { (_) in
                me.sliders.iso.hidden = true
                me.sliders.exposureDuration.hidden = true
                me.sessionController.removeValueObservingBlockFor(modeVO.type, key: modeVO.key)
            }
            let rows: [CaptureControlPanelRow] = [
                CaptureControlPanelRow.fromOptionControl(modeControl)
            ]
            //guard menuControl.alpha > 0 else { break }
            setUpControlPanelEntranceExit(rows, &info)
        case .WhiteBalance:
            let modeVO: VO = ("WhiteBalanceModeControl", .cameraWhiteBalanceMode)
            
            let modeControl = OptionControl<AVCaptureWhiteBalanceMode>(
                items: [ ("Manual", .Locked), ("Auto", .ContinuousAutoWhiteBalance) ],
                selectedValue: me.sessionController.camera.whiteBalanceMode
            )
            modeControl.setValueAction = { (wbmode) in
                me.sessionController.set(.cameraWhiteBalanceMode(wbmode))
            }
            me.sessionController.setValueObservingBlockFor(modeVO.type, key: modeVO.key){[weak modeControl] in
                switch $0 {
                case .cameraWhiteBalanceMode(let wbmode):
                    modeControl?.selectItemWithValue(wbmode)
                default: return
                }
            }
            
            info.entrancePerformer = {
                me.sliders.temperature.hidden = false
                me.sliders.temperature.alpha = 1.0
            }
            info.exitPerformer = {
                me.sliders.temperature.alpha = 0.0 }
            info.exitCompleter = { (_) in
                me.sliders.temperature.hidden = true
                me.sessionController.removeValueObservingBlockFor(modeVO.type, key: modeVO.key)
            }
            
            let rows: [CaptureControlPanelRow] = [
                CaptureControlPanelRow.fromOptionControl(modeControl),
                CaptureControlPanelRow.fromSlider(me.sliders.tint)
            ]
            //guard menuControl.alpha > 0 else { break }
            setUpControlPanelEntranceExit(rows, &info)
        case .Zoom:
            setUpControlPanelEntranceExit([
                CaptureControlPanelRow.fromSlider(me.sliders.zoom)
                ], &info)
        case .AspectRatio:
            let modeVO: VO = ("AspectRatioOptionControl", .cropAspectRatio)
            info.entrancePerformer = {
                me.menuControl.alpha = 1.0
            }
            let optionControl = OptionControl<CSCAspectRatio>(
                items: [
                    ("16:9", CSCAspectRatio(16,9)),
                    ("4:3", CSCAspectRatio(4,3)),
                    ("3:2", CSCAspectRatio(3,2)),
                    ("Square", CSCAspectRatio(1,1))
                ],
                selectedValue: me.sessionController.cropAspectRatio
            )
            optionControl.setValueAction = { (aspectRatio) in
                me.sessionController.set(CSCSet.cropAspectRatio(aspectRatio))
            }
            me.sessionController.setValueObservingBlockFor(modeVO.type, key: modeVO.key){[weak optionControl] in
                switch $0 {
                case .cropAspectRatio(let ar):
                    optionControl?.selectItemWithValue(ar)
                default: return
                }
            }
            setUpControlPanelEntranceExit([
                CaptureControlPanelRow.fromOptionControl(optionControl)
                ], &info)
        case .Options:
            info.entranceStarter = {
                let i = OptionControl.indexOfItemWithValue(
                    oldSaveMode,
                    items: me.menuControl.items
                    ) ?? 0
                me.menuControl.selectedIndex = i
            }
            info.entrancePerformer = {
                me.menuControl.alpha = 1.0
            }
        case .Fullscreen: break
        }
        
        me.layoutInfo = info
    }
    private typealias LayoutInit = () -> Void
    private typealias LayoutPerformer = () -> Void
    private typealias LayoutCompleter = (Bool) -> Void
    private typealias LayoutInfo = (
        entranceStarter: LayoutInit,
        entrancePerformer: LayoutPerformer,
        entranceCompleter: LayoutCompleter,
        exitPerformer: LayoutPerformer,
        exitCompleter: LayoutCompleter,
        savedMode: LayoutMode,
        currentMode: LayoutMode
    )
    private var layoutInfo: LayoutInfo!
    
    private func switchToLayout(layoutMode:LayoutMode, _ duration: NSTimeInterval = 0.2) {
        guard layoutInfo.currentMode != layoutMode else {return}
        UIView.animateWithDuration(
            duration,
            animations: layoutInfo.exitPerformer,
            completion: layoutInfo.exitCompleter
        )
        setUpLayoutInfoForMode(layoutMode)
        menuControl.selectItemWithValue(layoutMode)
        UIView.animateWithDuration(duration,
            animations: layoutInfo.entrancePerformer,
            completion: layoutInfo.entranceCompleter
        )
        layoutInfo.entranceStarter()
    }

    
    override var bounds: CGRect {
        didSet {
            guard bounds != oldValue else { return }
            sessionController.previewLayer.frame = bounds
            updateConstraintsForKeys([.Slider(.Top), .Slider(.Bottom), .Slider(.Left), .Slider(.Right), .ShutterButton])
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
            case .ControlPanel: return "ControlPanel"
            case .MenuControl: return "MenuControl"
            }
        }
        case Slider(MainSliderPositionType)
        case ShutterButton
        case ControlPanel
        case MenuControl
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
        case .MenuControl:
            let sHeight = my + 5
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                "H:|->=0-[MC(==350@250)]->=0-|",
                options: .DirectionLeftToRight,
                metrics: nil,
                views: ["MC" : menuControl]
            )
            let centerXConstraint = NSLayoutConstraint(item: menuControl, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            let yConstraint = NSLayoutConstraint(item: menuControl, attribute: NSLayoutAttribute.TopMargin, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Top, multiplier: 1, constant: sHeight)
            constraints.appendContentsOf(hConstraints)
            constraints.append(centerXConstraint)
            constraints.append(yConstraint)
        case .ControlPanel:
            let sHeight = my + 5
            guard let controlPanel = currentControlPanel else { break }
            let centerXConstraint = NSLayoutConstraint(item: controlPanel, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0)
            let yConstraint = NSLayoutConstraint(item: controlPanel, attribute: NSLayoutAttribute.BottomMargin, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Bottom, multiplier: 1, constant: -sHeight)
            constraints.append(centerXConstraint)
            constraints.append(yConstraint)
        case .ShutterButton:
            let sWidth = xMargin
            let centerYConstraint = NSLayoutConstraint(item: shutterButton, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0)
            let centerXConstraint = NSLayoutConstraint(item: shutterButton, attribute: NSLayoutAttribute.RightMargin, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.RightMargin, multiplier: 1, constant: -sWidth)
            constraints.appendContentsOf([centerXConstraint])
            constraints.appendContentsOf([centerYConstraint])
            
        case .Slider(.Left):
            guard let slider = mainSliders[.Left] else { break }
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-x-[S]", options: .DirectionLeftToRight, metrics: ["x": xMargin], views: ["S":slider])
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-m-[S]-m-|", options: .DirectionLeftToRight, metrics: ["m": my], views: ["S":slider])
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
        case .Slider(.Right):
            guard let slider = mainSliders[.Right] else { break }
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:[S]-x-|", options: .DirectionLeftToRight, metrics: ["x": xMargin], views: ["S":slider])
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-m-[S]-m-|", options: .DirectionLeftToRight, metrics: ["m": my], views: ["S":slider])
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
        case .Slider(.Bottom):
            guard let slider = mainSliders[.Bottom] else { break }
            let vConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:[S]-y-|", options: .DirectionLeftToRight, metrics: ["y": yMargin], views: ["S":slider])
            let hConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-m-[S]-m-|", options: .DirectionLeftToRight, metrics: ["m": mx], views: ["S":slider])
            constraints.appendContentsOf(hConstraints)
            constraints.appendContentsOf(vConstraints)
        case .Slider(.Top):
            guard let slider = mainSliders[.Top] else { break }
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
