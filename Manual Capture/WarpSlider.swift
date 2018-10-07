//
//  WarpSlider.swift
//  Capture
//
//  Created by Jean on 9/18/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class WarpSlider<Value> : GenericSlider<Value, WarpSliderKnobLayer> {
    let line = WarpSliderLine()
    
    override var bounds: CGRect {
        didSet {
            guard bounds != oldValue else { return }
            line.regularLine.removeAnimation(forKey: "pathAnimation")
            knobLayer.removeAnimation(forKey: "positionXAnimation")
            knobLayer.removeAnimation(forKey: "positionYAnimation")
            CATransaction.disableActions {
                self.line.frame = self.bounds
                self.layoutSublayers(of: self.layer)
            }
        }
    }
    
    override func didChangeState(oldState: State) {
        super.didChangeState(oldState: oldState)
        let added = state.subtracting(oldState)
        let removed = oldState.subtracting(state)

        var transitionScale: Float?
        if !state.hasProperty(.computerControlled) {
            if removed.hasProperty(.active) { transitionScale = 0.0 }
            
            if removed.hasProperty(.computerControlled) && !state.hasProperty(.active) { transitionScale = 0.0 }
        }else if added.hasProperty(.computerControlled) { transitionScale = 1.0 }
        
        if let tScale = transitionScale {
            line.updateLineApearance(initialSensitivity, tScale, travelDistance, fingerProgress, progress, totalDistance)
        }
    }
    
    override func setProgress(_ progress: Float, animated:Bool) {
        // temporarily disable default animation
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        let laniAnimating = line.regularLine.animation(forKey: "pathAnimation") != nil
        let sanixAnimating = lineLayer.animation(forKey: "positionXAnimation") != nil
        let saniyAnimating = lineLayer.animation(forKey: "positionYAnimation") != nil
        if !animated {
            if laniAnimating || sanixAnimating || saniyAnimating {
                line.regularLine.removeAnimation(forKey: "pathAnimation")
                knobLayer.removeAnimation(forKey: "positionXAnimation")
                knobLayer.removeAnimation(forKey: "positionYAnimation")
            }
        } else {
            let lani = CABasicAnimation(keyPath: "path")// line path animation
            let sanix = CABasicAnimation(keyPath: "position.x")// scrubber x animation
            let saniy = CABasicAnimation(keyPath: "position.y")// scrubber y animation
            let aniG = CAAnimationGroup()
            aniG.animations = [lani, sanix, saniy]
            aniG.duration = 0.25
            aniG.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
            aniG.isRemovedOnCompletion = true
            
            if laniAnimating && sanixAnimating && saniyAnimating {
                if let pll = line.regularLine.presentation() {
                    sanix.fromValue = pll.path
                }
                if let psl = knobLayer.presentation() {
                    sanix.fromValue = psl.position.x
                    saniy.fromValue = psl.position.y
                }
            }
            line.regularLine.add(lani, forKey: "pathAnimation")
            knobLayer.add(sanix, forKey: "positionXAnimation")
            knobLayer.add(saniy, forKey: "positionYAnimation")
        }
        let inRangeValue = max(0, min(progress, 1))
        if inRangeValue != self.progress {
            self.progress = inRangeValue
            layer.layoutSublayers()
        }
        var shouldRound = false
        if state.hasProperty(.active) {
            line.updateLineApearance(initialSensitivity, transitionScale, travelDistance, fingerProgress, progress, totalDistance)
            shouldRound = (transitionScale == 1.0)
        }
        
        if value != nil {
            knobLayer.text = labelTextForValue(value, shouldRound)
        }
            // resume default animation
            CATransaction.commit()
    }
    
    let labelTextMinWidth: CGFloat
    var labelTextForValue: (Value, Bool) -> String = { _, _ in "Slider" } {
        didSet { updateLabelText() }
    }
    override var valueProgressHandler: ValueProgressHandler<Value>? {
        didSet { updateLabelText() }
    }
    
    func updateLabelText() {
        guard let v = value else { return }
        knobLayer.text = labelTextForValue(v, false)
    }
    
    var travelDistance: CGFloat = 0
    var totalDistance: CGFloat = 0
    
    let gesture: WarpSliderGesture
    var initialSensitivity: CGFloat = 0.3
    let warpSpeedReverses = (UIApplication.shared.delegate as? AppDelegate)?.isVideoMode ?? false
    var transitionScale: Float = 0
    
    /// displacement of progress so that the knob will position right under finger
    private var transitionDistance: CGFloat {
        if warpSpeedReverses {
            return (direction.axis == .horizontal) ? 130.0 : 195.0
        } else {
            return (direction.axis == .horizontal) ? 90.0 : 135.0
        }
    }
    private var transitionStartDistance: CGFloat = 35.0
    
    /// progress values for tracking under finger
    private var fingerProgress: Float = 0
    /// progress values for tracking using sensitivity
    private var accuracyProgress: Float = 0
    /// absolute referance of perpendicular distance from slider on touch began
    private var perpendicularDistance: CGFloat = 0
    /// relative referance of perpendicular distance where transition should start
    private var perpendicularStartDistance: CGFloat = 0
    
    private var startTravelDistance: CGFloat = 0
    
    @objc func handleWarpSliderGesture(sender: WarpSliderGesture) {
        switch sender.state {
        case .began:
            perpendicularDistance = _perpendicularDisplacementForPointTargetPoint(gesture.lastFingerLocation) // touch down location
            perpendicularStartDistance = abs(perpendicularDistance) + transitionStartDistance
            fingerProgress = 0
            accuracyProgress = progress
            
            if !state.hasProperty(.active) {
                // first to activate
                becomeCurrentControl()
                state.getUpdateTransform(true, .active)?(&state)
                state.getUpdateTransform(false, .computerControlled)?(&state)
                actionProgressStarted?(self)
                actionStarted?()
            }
            
        case .changed:
            let oldPerpendicularDistance = perpendicularDistance
            perpendicularDistance = _perpendicularDisplacementForPointTargetPoint(sender.lastFingerLocation)
            
            let start: CGFloat = perpendicularStartDistance
            let end: CGFloat = perpendicularStartDistance + transitionDistance
            let relativeDistance = min(max(abs(perpendicularDistance), start), end) - start
            
            if abs(perpendicularDistance) < perpendicularStartDistance - transitionStartDistance {
                perpendicularStartDistance = abs(perpendicularDistance) + transitionStartDistance
            }
            
            transitionScale =  Float(relativeDistance / (end - start))
            fingerProgress = _progressForTargetPoint(sender.lastFingerLocation)
            
            if abs(perpendicularDistance) < abs(oldPerpendicularDistance) - 0.5 && !warpSpeedReverses {
                let newAccuracyProgress = (0.000001 + progress - transitionScale * fingerProgress) / (1.000001 - transitionScale)
                accuracyProgress = newAccuracyProgress // + abs(accuracyProgress - newAccuracyProgress) * reverseValue
            }
            
            accuracyProgress += sender.progressChange * Float(initialSensitivity)
            let newProgress = (accuracyProgress + (fingerProgress - accuracyProgress) * transitionScale)
            setProgress(newProgress, animated: false)
            actionProgressChanged?(self)
        case .possible: break
        default:
            transitionScale = 0.0
            
            if state.hasProperty(.active) {
                var active = false
                for (_, progressDisplacementHandler) in progressDisplacementHandlers {
                    if progressDisplacementHandler.state.hasProperty(.active) {
                        active = true
                        break
                    }
                }
                if !active {
                    // last to deactivate
                    state = state.subtracting(.active)
                    actionProgressEnded?(self)
                    actionEnded?()
                }
            }
        }
    }
    
    private func _perpendicularDisplacementForPointTargetPoint(_ targetPoint: CGPoint) -> CGFloat {
        let targetPoint = convert(targetPoint, from: superview!)
        switch direction.axis {
            case .horizontal: return bounds.midY - targetPoint.y
            case .vertical: return bounds.midX - targetPoint.x
        }
    }
    
    private func _progressForTargetPoint(_ targetPoint: CGPoint) -> Float {
        let targetPoint = convert(targetPoint, from: superview!)
        let sMR = kSliderKnobMargin + kSliderKnobRadius
        switch direction {
        case .right:
            let y = bounds.midY
            // travel
            let tsp = CGPoint(x: bounds.minX + sMR, y: y)
            let tep = CGPoint(x: bounds.maxX - sMR, y: y)
            
            let tp = targetPoint
            let td = tp.x - tsp.x
            let p = Float(td/(tep.x - tsp.x))
            return p
        case .left:
            let y = bounds.midY
            // travel
            let tsp = CGPoint(x: bounds.maxX - sMR, y: y)
            let tep = CGPoint(x: bounds.minX + sMR, y: y)
            
            let tp = targetPoint
            let td = tp.x - tsp.x
            let p = Float(td/(tep.x - tsp.x))
            return p
        case .down:
            let x = bounds.midX
            // travel
            let tsp = CGPoint(x: x, y: bounds.minY + sMR)
            let tep = CGPoint(x: x, y: bounds.maxY - sMR)
            
            let tp = targetPoint
            let td = tp.y - tsp.y
            let p = Float(td/(tep.y - tsp.y))
            return p
        case .up:
            let x = bounds.midX
            // travel
            let tsp = CGPoint(x: x, y: bounds.maxY - sMR)
            let tep = CGPoint(x: x, y: bounds.minY + sMR)
            
            let tp = targetPoint
            let td = tp.y - tsp.y
            let p = Float(td/(tep.y - tsp.y))
            return p
        }
    }
        
    convenience init(glyph: CALayer, direction:Direction, _ labelTextMinWidth: CGFloat = 35){
        self.init(glyph: glyph, direction:direction, startBounds: nil, sliderBounds: nil, labelTextMinWidth)
    }
    
    init(glyph: CALayer, direction:Direction, startBounds: (() -> CGRect)?, sliderBounds: (() -> CGRect)?, _ labelTextMinWidth:CGFloat = 35) {
        gesture = WarpSliderGesture(direction: direction)
        self.labelTextMinWidth = labelTextMinWidth
        super.init(knobLayer: WarpSliderKnobLayer(glyph: glyph), direction: direction)
        
        /// prevent strong ownership in closures
        unowned let me = self
        knobLayer.labelTextMinWidth = labelTextMinWidth
        gesture.addTarget(self, action: #selector(self.handleWarpSliderGesture(sender:)))
        lineLayer.removeFromSuperlayer()
        layer.addSublayer(line)
        if sliderBounds == nil {
            switch direction.axis {
            case .horizontal:
                gesture.sliderBounds = {
                    guard !me.isHidden || me.layer.opacity != 0.0 else { return CGRect.zero }
                    let convertedRect = me.convert(
                        CGRect(x: 0, y: me.knobLayer.frame.origin.y, width: me.bounds.width, height: me.knobLayer.bounds.height),
                        to: me.gesture.view
                    )
                    return convertedRect.insetBy(dx: 0, dy: min( me.knobLayer.bounds.height / 2 - 30, 0 ) )
                }
            case .vertical:
                gesture.sliderBounds = {
                    guard !me.isHidden || me.layer.opacity != 0.0 else { return CGRect.zero }
                    let convertedRect = me.convert(
                        CGRect(x: me.knobLayer.frame.origin.x, y: 0, width: me.knobLayer.bounds.width, height: me.bounds.height),
                        to: me.gesture.view
                    )
                    return convertedRect.insetBy(dx: min( me.knobLayer.bounds.width / 2 - 30, 0), dy: 0)
                }
            }
        }
        else {
            gesture.sliderBounds = sliderBounds
        }
        if startBounds == nil {
            
            switch direction.axis {
            case .horizontal:
                gesture.startBounds = {
                    let convertedRect = me.convert(
                        CGRect(x: 0, y: me.knobLayer.frame.origin.y, width: me.bounds.width, height: me.knobLayer.bounds.height),
                        to: me.gesture.view
                    )
                    return convertedRect.insetBy(dx: 0, dy: min(me.knobLayer.bounds.height/2 - 30, 0))
                }
            case .vertical:
                gesture.startBounds = {
                    let convertedRect = me.convert(
                        CGRect(x: me.knobLayer.frame.origin.x, y: 0, width: me.knobLayer.bounds.width, height: me.bounds.height),
                        to: me.gesture.view
                    )
                    return convertedRect.insetBy(dx: min(me.knobLayer.bounds.width/2 - 30, 0), dy: 0)
                }
            }
        }
        else{
            gesture.startBounds = startBounds
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToSuperview() {
        guard let sv = superview else { return }
        sv.addGestureRecognizer(gesture)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        guard self.layer.isEqual(layer) else{ super.layoutSublayers(of: layer);return }
        
        func setLinePathFor(_ sp: CGPoint, _ ep: CGPoint) {
            let lp = CGMutablePath()
            lp.move(to: sp)
            lp.addLine(to: ep)
            line.dashLineLayer1.path = lp
            line.dashLineLayer2.path = lp
        }
        
        func setSplitLinePathFor(_ sp1:CGPoint, _ ep1:CGPoint, _ sp2:CGPoint, _ ep2:CGPoint) {
            let lp1 = CGMutablePath()
            let lp2 = CGMutablePath()
            lp1.move(to: sp1)
            lp1.addLine(to: ep1)
            lp2.move(to: sp2)
            lp2.addLine(to: ep2)
            let combinedPath: CGMutablePath = lp1.mutableCopy()!
            combinedPath.addPath(lp2)
            line.regularLine.path = combinedPath
        }
        
        let sML = kSliderKnobMargin + ((direction.axis == .horizontal) ? knobLayer.bounds.width : knobLayer.bounds.height )/2
        
        switch direction {
        case .right:
            let y = bounds.midY
            
            // travel
            let tsp = CGPoint(x: bounds.minX + sML, y: y)
            let tep = CGPoint(x: bounds.maxX - sML, y: y)
            let td = (tep.x - tsp.x)*CGFloat(self.progress)
            travelDistance = td
            totalDistance = abs(tep.x - tsp.x)
            
            // travel point
            let tp = CGPoint(x: tsp.x + td, y: y)
            
            // line points
            let lsp = CGPoint(x: bounds.minX, y: y)
            let lep = CGPoint(x: bounds.maxX, y: y)
            setLinePathFor(lsp, lep)
            
            // split line points
            let lsp1 = lsp
            let lep1 = CGPoint(x: tp.x - sML, y: y)
            let lsp2 = CGPoint(x: tp.x + sML, y: y)
            let lep2 = lep
            setSplitLinePathFor(lsp1, lep1, lsp2, lep2)
            
            knobLayer.position = tp
        case .left:
            let y = bounds.midY
            
            // travel
            let tsp = CGPoint(x: bounds.maxX - sML, y: y)
            let tep = CGPoint(x: bounds.minX + sML, y: y)
            let td = (tep.x - tsp.x)*CGFloat(self.progress)
            travelDistance = td
            totalDistance = abs(tep.x - tsp.x)
            
            // travel point
            let tp = CGPoint(x: tsp.x + td, y: y)
            
            // line points
            let lsp = CGPoint(x: bounds.maxX, y: y)
            let lep = CGPoint(x: bounds.minX, y: y)
            setLinePathFor(lsp, lep)
            
            // split line points
            let lsp1 = lsp
            let lep1 = CGPoint(x: tp.x + sML, y: y)
            let lsp2 = CGPoint(x: tp.x - sML, y: y)
            let lep2 = lep
            setSplitLinePathFor(lsp1, lep1, lsp2, lep2)
            
            knobLayer.position = tp
        case .down:
            let x = bounds.midX
            // travel
            let tsp = CGPoint(x: x, y: bounds.minY + sML)
            let tep = CGPoint(x: x, y: bounds.maxY - sML)
            let td = (tep.y - tsp.y)*CGFloat(self.progress)
            travelDistance = td
            totalDistance = abs(tep.y - tsp.y)
            // travel point
            let tp = CGPoint(x: x, y: tsp.y + td)
            // line points
            let lsp = CGPoint(x: x, y: bounds.minY)
            let lep = CGPoint(x: x, y: bounds.maxY)
            setLinePathFor(lsp, lep)
            
            // split line points
            let lsp1 = lsp
            let lep1 = CGPoint(x: x, y: tp.y - sML)
            let lsp2 = CGPoint(x: x, y: tp.y + sML)
            let lep2 = lep
            setSplitLinePathFor(lsp1, lep1, lsp2, lep2)
            
            knobLayer.position = tp
        case .up:
            let x = bounds.midX
            
            // travel
            let tsp = CGPoint(x: x, y: bounds.maxY - sML)
            let tep = CGPoint(x: x, y: bounds.minY + sML)
            let td = (tep.y - tsp.y)*CGFloat(self.progress)
            travelDistance = td
            totalDistance = abs(tep.y - tsp.y)
            
            // travel point
            let tp = CGPoint(x: x, y: tsp.y + td)
            
            // line points
            let lsp = CGPoint(x: x, y: bounds.maxY)
            let lep = CGPoint(x: x, y: bounds.minX)
            setLinePathFor(lsp, lep)
            
            // line points
            let lsp1 = lsp
            let lep1 = CGPoint(x: x, y: tp.y + sML)
            let lsp2 = CGPoint(x: x, y: tp.y - sML)
            let lep2 = lep
            setSplitLinePathFor(lsp1, lep1, lsp2, lep2)
            
            knobLayer.position = tp
        }
    }
    override var intrinsicContentSize: CGSize {
        switch direction.axis {
        case .horizontal: return CGSize(width: frame.width, height: 2 * (kSliderKnobMargin + kSliderKnobRadius))
        case .vertical: return CGSize(width: 2 * (kSliderKnobMargin + kSliderKnobRadius), height: frame.height)
        }
    }
}

import UIKit.UIGestureRecognizerSubclass

class WarpSliderGesture: UIPanGestureRecognizer {
    var startBounds: (() -> CGRect)?
    var sliderBounds: (() -> CGRect)?
    var direction: Slider.Direction
    var change: CGFloat = 0
    var progressChange: Float = 0
    var perpendicularDisplacement: CGFloat = 0
    var lastFingerLocation:CGPoint!
    
    init(startBounds: @escaping (() -> CGRect), direction: Slider.Direction, target: AnyObject, action: Selector) {
        self.startBounds = startBounds
        self.direction = direction
        super.init(target: target, action: action)
        didInit()
    }
    
    init(startBounds: @escaping () -> CGRect, direction: Slider.Direction) {
        self.startBounds = startBounds
        self.direction = direction
        super.init(target: nil, action: nil)
        didInit()
    }
    
    init(direction: Slider.Direction){
        self.direction = direction
        self.startBounds = nil
        super.init(target: nil, action: nil)
        didInit()
    }
    
    private func didInit() {
        self.maximumNumberOfTouches = 1
        self.minimumNumberOfTouches = 1
        self.delaysTouchesBegan = false
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)
        let touchPoint = touches.first!.location(in: view)
        let prevTouchPoint = touches.first!.previousLocation(in: view)
        lastFingerLocation = touchPoint
        began: if state == .began {
            if let sbiv = sliderBounds, sbiv().contains(touchPoint) {
                view?.gestureRecognizers?.forEach({
                    if $0 != self && $0 is WarpSliderGesture {
                        $0.state = .cancelled
                    }
                })
                break began /* dont cancel */
            }
            else if let sb = startBounds, !sb().contains(touchPoint) { state = .cancelled }
            
            let vel = velocity(in: view)
            switch direction {
                case .right where abs(vel.y) > abs(vel.x), .left where abs(vel.y) > abs(vel.x):
                    state = .cancelled
                case .up where abs(vel.x) > abs(vel.y), .down where abs(vel.x) > abs(vel.y):
                    state = .cancelled
                default:
                    break
            }
        }
        
        if state == .changed || state == .began {
            switch direction {
            case .right:
                change = touchPoint.x - prevTouchPoint.x
                perpendicularDisplacement = touchPoint.y - prevTouchPoint.y
            case .left:
                change = prevTouchPoint.x - touchPoint.x
                perpendicularDisplacement = touchPoint.y - prevTouchPoint.y
            case .down:
                change = touchPoint.y - prevTouchPoint.y
                perpendicularDisplacement = touchPoint.x - prevTouchPoint.x
            case .up:
                change = prevTouchPoint.y - touchPoint.y
                perpendicularDisplacement = touchPoint.x - prevTouchPoint.x
            }
            let frame = (view != nil) ? view!.frame : UIScreen.main.bounds
            let progressLength: CGFloat = (direction == .right || direction == .left) ? frame.width : frame.height
            progressChange = Float( change / progressLength)
        }
    }
    
    override func reset() {
        super.reset()
        change = 0
        perpendicularDisplacement = 0
    }
    
}
