//
//  SmartSlider.swift
//  Capture
//
//  Created by Jean on 9/18/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

var warpSpeedReverses = true

class SmartSlider<V> : GenericSlider<V, SmartSliderKnobLayer> {
    let line = SmartSliderLine()
    
    override var bounds: CGRect {
        didSet {
            guard bounds != oldValue else { return }
            line.regularLine.removeAnimationForKey("pathAnimation")
            knobLayer.removeAnimationForKey("positionXAnimation")
            knobLayer.removeAnimationForKey("positionYAnimation")
            CATransaction.disableActions {
                self.line.frame = self.bounds
                self.layoutSublayersOfLayer(self.layer)
            }
        }
    }
    
    override func didChangeState(oldState: State) {
        super.didChangeState(oldState)
        let added = state.subtract(oldState)
        let removed = oldState.subtract(state)

        var transitionScale: Float?
        if !state.hasProperty(.ComputerControlled) {
            if removed.hasProperty(.Active) { transitionScale = 0.0 }
            
            if removed.hasProperty(.ComputerControlled) && !state.hasProperty(.Active) { transitionScale = 0.0 }
        }else if added.hasProperty(.ComputerControlled) { transitionScale = 1.0 }
        
        if let tScale = transitionScale {
            line.updateLineApearance(initialSensitivity, tScale, travelDistance, fingerProgress)
        }
    }
    
    override func setProgress(progress: Float, animated:Bool) {
        // temporarily disable default animation
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        let laniAnimating = line.regularLine.animationForKey("pathAnimation") != nil
        let sanixAnimating = lineLayer.animationForKey("positionXAnimation") != nil
        let saniyAnimating = lineLayer.animationForKey("positionYAnimation") != nil
        if !animated {
            if laniAnimating || sanixAnimating || saniyAnimating {
                line.regularLine.removeAnimationForKey("pathAnimation")
                knobLayer.removeAnimationForKey("positionXAnimation")
                knobLayer.removeAnimationForKey("positionYAnimation")
            }
        }else{
            let lani = CABasicAnimation(keyPath: "path")// line path animation
            let sanix = CABasicAnimation(keyPath: "position.x")// scrubber x animation
            let saniy = CABasicAnimation(keyPath: "position.y")// scrubber y animation
            let aniG = CAAnimationGroup()
            aniG.animations = [lani, sanix, saniy]
            aniG.duration = 0.25
            aniG.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            aniG.removedOnCompletion = true
            
            if laniAnimating && sanixAnimating && saniyAnimating {
                if let pll = line.regularLine.presentationLayer() as? CAShapeLayer {
                    sanix.fromValue = pll.path
                }
                if let psl = knobLayer.presentationLayer() as? CALayer {
                    sanix.fromValue = psl.position.x
                    saniy.fromValue = psl.position.y
                }
            }
            line.regularLine.addAnimation(lani, forKey: "pathAnimation")
            knobLayer.addAnimation(sanix, forKey: "positionXAnimation")
            knobLayer.addAnimation(saniy, forKey: "positionYAnimation")
        }
        let inRangeValue = max(0, min(progress, 1))
        if inRangeValue != self.progress {
            self.progress = inRangeValue
            layer.layoutSublayers()
        }
        var shouldRound = false
        if state.hasProperty(.Active) {
            line.updateLineApearance(initialSensitivity, transitionScale, travelDistance, fingerProgress)
            shouldRound = (transitionScale == 1.0)
        }
        
        if value != nil {
            knobLayer.text = labelTextForValue(value, shouldRound)
        }
            // resume default animation
            CATransaction.commit()
    }
    
    let labelTextMinWidth: CGFloat
    var labelTextForValue: (V, Bool) -> String = { $0;$1;return "Slider" } {
        didSet { updateLabelText() }
    }
    override var vpHandler: VPHandler<V>? {
        didSet { updateLabelText() }
    }
    
    func updateLabelText(){
        guard let v = value else { return }
        knobLayer.text = labelTextForValue(v, false)
    }
    
    var travelDistance: CGFloat = 0
    var totalDistance: CGFloat = 0
    
    let gesture: SmartSliderGesture
    
    var initialSensitivity: CGFloat = 0.3 {
        didSet{
            gesture.sensitivity = initialSensitivity
        }
    }
    
    //var sensitivityScale: CGFloat = 1 / 0.3
    var transitionScale: Float = 0
    
    /// displacement of progress so that the knob will position right under finger
    private var transitionDistance: CGFloat {
        if !warpSpeedReverses {
            return (direction.axis == .Horizontal) ? 120.0 : 180.0
            //return (direction.axis == .Horizontal) ? 50 : 75
        }else {
            return (direction.axis == .Horizontal) ? 90.0 : 135.0
            //return (direction.axis == .Horizontal) ? 50 : 75
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
    
    func handleSmartSliderGesture(sender:SmartSliderGesture) {
        switch sender.state {
        case .Began:
            perpendicularDistance = _perpendicularDisplacementForPointTargetPoint(gesture.lastFingerLocation) // touch down location
            perpendicularStartDistance = abs(perpendicularDistance) + transitionStartDistance
            fingerProgress = 0
            accuracyProgress = progress
            
            if !state.hasProperty(.Active) {
                // first to activate
                becomeCurrentControl()
                state.getUpdateTransform(true, .Active)?(&state)
                state.getUpdateTransform(false, .ComputerControlled)?(&state)
                actionProgressStarted?(self)
                actionStarted?()
            }
            
        case .Changed:
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
                let newAccuracyProgress = (0.001 + progress - transitionScale * fingerProgress) / (1.001 - transitionScale)
                accuracyProgress = newAccuracyProgress // + abs(accuracyProgress - newAccuracyProgress) * reverseValue
            }
            
            accuracyProgress += sender.progressChange
            
            let newProgress = (accuracyProgress + (fingerProgress - accuracyProgress) * transitionScale)
            
            setProgress(newProgress, animated: false)
            actionProgressChanged?(self)
        case .Possible: break
        default:
            transitionScale = 0.0
            
            if state.hasProperty(.Active) {
                var active = false
                for (_, pdh) in pdHandlers {
                    if pdh.state.hasProperty(.Active) { active = true; break }
                }
                if !active {
                    // last to deactivate
                    state.subtractInPlace(.Active)
                    actionProgressEnded?(self)
                    actionEnded?()
                }
            }
        }
    }
    
    private func _perpendicularDisplacementForPointTargetPoint(var targetPoint:CGPoint) -> CGFloat {
        targetPoint = convertPoint(targetPoint, fromView: superview!)
        switch direction.axis {
        case .Horizontal: return bounds.midY - targetPoint.y
        case .Vertical: return bounds.midX - targetPoint.x
        }
    }
    
    private func _progressForTargetPoint(var targetPoint:CGPoint) -> Float {
        targetPoint = convertPoint(targetPoint, fromView: superview!)
        let sMR = kSliderKnobMargin + kSliderKnobRadius
        switch direction {
        case .Right:
            let y = bounds.midY
            // travel
            let tsp = CGPointMake(bounds.minX + sMR, y)
            let tep = CGPointMake(bounds.maxX - sMR, y)
            
            let tp = targetPoint
            let td = tp.x - tsp.x
            let p = Float(td/(tep.x - tsp.x))
            return p
        case .Left:
            let y = bounds.midY
            // travel
            let tsp = CGPointMake(bounds.maxX - sMR, y)
            let tep = CGPointMake(bounds.minX + sMR, y)
            
            let tp = targetPoint
            let td = tp.x - tsp.x
            let p = Float(td/(tep.x - tsp.x))
            return p
        case .Down:
            let x = bounds.midX
            // travel
            let tsp = CGPointMake(x, bounds.minY + sMR)
            let tep = CGPointMake(x, bounds.maxY - sMR)
            
            let tp = targetPoint
            let td = tp.y - tsp.y
            let p = Float(td/(tep.y - tsp.y))
            return p
        case .Up:
            let x = bounds.midX
            // travel
            let tsp = CGPointMake(x, bounds.maxY - sMR)
            let tep = CGPointMake(x, bounds.minY + sMR)
            
            let tp = targetPoint
            let td = tp.y - tsp.y
            let p = Float(td/(tep.y - tsp.y))
            return p
        }
    }
        
    convenience init(glyph: CALayer, direction:Direction, _ labelTextMinWidth: CGFloat = 35){
        self.init(glyph: glyph, direction:direction, startBounds: nil, sliderBounds: nil, labelTextMinWidth)
    }
    
    init(glyph: CALayer, direction:Direction, startBounds: (() -> CGRect)?, sliderBounds: (() -> CGRect)?, _ labelTextMinWidth:CGFloat = 35){
        
        
        
        gesture = SmartSliderGesture(direction: direction)
        self.labelTextMinWidth = labelTextMinWidth
        
        super.init(knobLayer: SmartSliderKnobLayer(glyph: glyph), direction: direction)
        
        /// prevent strong ownership in closures
        unowned let me = self
        
        knobLayer.labelTextMinWidth = labelTextMinWidth
        
        gesture.sensitivity = initialSensitivity
        gesture.addTarget(self, action: "handleSmartSliderGesture:")
        
        lineLayer.removeFromSuperlayer()
        layer.addSublayer(line)
        
        
        
        if sliderBounds == nil {
            
            
            switch direction.axis {
            case .Horizontal:
                gesture.sliderBounds = {
                    guard !me.hidden || me.layer.opacity != 0.0 else { return CGRectZero }
                    return CGRectInset(
                        me.convertRect(
                            CGRectMake(0, me.knobLayer.frame.origin.y, me.bounds.width, me.knobLayer.bounds.height),
                            toView: me.gesture.view
                        ),
                        0,
                        min( me.knobLayer.bounds.height / 2 - 30, 0 )
                    )
                }
            case .Vertical:
                gesture.sliderBounds = {
                    guard !me.hidden || me.layer.opacity != 0.0 else { return CGRectZero }
                    return CGRectInset(
                        me.convertRect(
                            CGRectMake(me.knobLayer.frame.origin.x, 0, me.knobLayer.bounds.width, me.bounds.height),
                            toView: me.gesture.view
                        ),
                        min( me.knobLayer.bounds.width / 2 - 30, 0),
                        0
                    )
                }
            }
        }
        else {
            gesture.sliderBounds = sliderBounds
        }
        if startBounds == nil {
            
            switch direction.axis {
            case .Horizontal:
                gesture.startBounds = {
                    return CGRectInset(
                        me.convertRect(
                            CGRectMake(0, me.knobLayer.frame.origin.y, me.bounds.width, me.knobLayer.bounds.height),
                            toView: me.gesture.view
                        ), 0, min(me.knobLayer.bounds.height/2 - 30, 0))
                }
            case .Vertical:
                gesture.startBounds = {
                    return CGRectInset(
                        me.convertRect(
                            CGRectMake(me.knobLayer.frame.origin.x, 0, me.knobLayer.bounds.width, me.bounds.height),
                            toView: me.gesture.view
                        ), min(me.knobLayer.bounds.width/2 - 30, 0), 0)
                }
            }
        }
        else{
            gesture.startBounds = startBounds
        }
    }

    override func didMoveToSuperview() {
        guard let sv = superview else { return }
        sv.addGestureRecognizer(gesture)
    }
    override func layoutSublayersOfLayer(layer: CALayer) {
        guard self.layer.isEqual(layer) else{super.layoutSublayersOfLayer(layer);return}
        
        func setLinePathFor(sp:CGPoint, _ ep:CGPoint) {
            let lp = CGPathCreateMutable()
            CGPathMoveToPoint(lp, nil, sp.x, sp.y)
            CGPathAddLineToPoint(lp, nil, ep.x, ep.y)
            line.dashLineLayer1.path = lp
            line.dashLineLayer2.path = lp
        }
        
        func setSplitLinePathFor(sp1:CGPoint, _ ep1:CGPoint, _ sp2:CGPoint, _ ep2:CGPoint) {
            let lp1 = CGPathCreateMutable()
            let lp2 = CGPathCreateMutable()
            CGPathMoveToPoint(lp1, nil, sp1.x, sp1.y)
            CGPathAddLineToPoint(lp1, nil, ep1.x, ep1.y)
            CGPathMoveToPoint(lp2, nil, sp2.x, sp2.y)
            CGPathAddLineToPoint(lp2, nil, ep2.x, ep2.y)
            let combinedPath: CGMutablePathRef = CGPathCreateMutableCopy(lp1)!
            CGPathAddPath(combinedPath, nil, lp2)
            line.regularLine.path = combinedPath
        }
        
        let sML = kSliderKnobMargin + ((direction.axis == .Horizontal) ? knobLayer.bounds.width : knobLayer.bounds.height )/2
        
        switch direction {
        case .Right:
            let y = bounds.midY
            
            // travel
            let tsp = CGPointMake(bounds.minX + sML, y)
            let tep = CGPointMake(bounds.maxX - sML, y)
            let td = (tep.x - tsp.x)*CGFloat(self.progress)
            travelDistance = td
            totalDistance = abs(tep.x - tsp.x)
            
            // travel point
            let tp = CGPointMake(tsp.x + td, y)
            
            // line points
            let lsp = CGPointMake(bounds.minX, y)
            let lep = CGPointMake(bounds.maxX, y)
            setLinePathFor(lsp, lep)
            
            // split line points
            let lsp1 = lsp
            let lep1 = CGPointMake(tp.x - sML, y)
            let lsp2 = CGPointMake(tp.x + sML, y)
            let lep2 = lep
            setSplitLinePathFor(lsp1, lep1, lsp2, lep2)
            
            knobLayer.position = tp
        case .Left:
            let y = bounds.midY
            
            // travel
            let tsp = CGPointMake(bounds.maxX - sML, y)
            let tep = CGPointMake(bounds.minX + sML, y)
            let td = (tep.x - tsp.x)*CGFloat(self.progress)
            travelDistance = td
            totalDistance = abs(tep.x - tsp.x)
            
            // travel point
            let tp = CGPointMake(tsp.x + td, y)
            
            // line points
            let lsp = CGPointMake(bounds.maxX, y)
            let lep = CGPointMake(bounds.minX, y)
            setLinePathFor(lsp, lep)
            
            // split line points
            let lsp1 = lsp
            let lep1 = CGPointMake(tp.x + sML, y)
            let lsp2 = CGPointMake(tp.x - sML, y)
            let lep2 = lep
            setSplitLinePathFor(lsp1, lep1, lsp2, lep2)
            
            knobLayer.position = tp
        case .Down:
            let x = bounds.midX
            // travel
            let tsp = CGPointMake(x, bounds.minY + sML)
            let tep = CGPointMake(x, bounds.maxY - sML)
            let td = (tep.y - tsp.y)*CGFloat(self.progress)
            travelDistance = td
            totalDistance = abs(tep.y - tsp.y)
            // travel point
            let tp = CGPointMake(x, tsp.y + td)
            // line points
            let lsp = CGPointMake(x, bounds.minY)
            let lep = CGPointMake(x, bounds.maxY)
            setLinePathFor(lsp, lep)
            
            // split line points
            let lsp1 = lsp
            let lep1 = CGPointMake(x, tp.y - sML)
            let lsp2 = CGPointMake(x, tp.y + sML)
            let lep2 = lep
            setSplitLinePathFor(lsp1, lep1, lsp2, lep2)
            
            knobLayer.position = tp
        case .Up:
            let x = bounds.midX
            
            // travel
            let tsp = CGPointMake(x, bounds.maxY - sML)
            let tep = CGPointMake(x, bounds.minY + sML)
            let td = (tep.y - tsp.y)*CGFloat(self.progress)
            travelDistance = td
            totalDistance = abs(tep.y - tsp.y)
            
            // travel point
            let tp = CGPointMake(x, tsp.y + td)
            
            // line points
            let lsp = CGPointMake(x, bounds.maxY)
            let lep = CGPointMake(x, bounds.minX)
            setLinePathFor(lsp, lep)
            
            // line points
            let lsp1 = lsp
            let lep1 = CGPointMake(x, tp.y + sML)
            let lsp2 = CGPointMake(x, tp.y - sML)
            let lep2 = lep
            setSplitLinePathFor(lsp1, lep1, lsp2, lep2)
            
            knobLayer.position = tp
        }
    }
    override func intrinsicContentSize() -> CGSize {
        switch direction.axis {
        case .Horizontal: return CGSizeMake(frame.width, knobLayer.bounds.height + (2 * kSliderKnobMargin))
        case .Vertical: return CGSizeMake(knobLayer.bounds.width + (2 * kSliderKnobMargin), frame.height)
        }
    }
}

import UIKit.UIGestureRecognizerSubclass

class SmartSliderGesture: UIPanGestureRecognizer {
    var sensitivity: CGFloat = 0.4
    var startBounds: (() -> CGRect)?
    var sliderBounds: (() -> CGRect)?
    var direction: Slider.Direction
    var change: CGFloat = 0
    var progressChange: Float = 0
    var perpendicularDisplacement: CGFloat = 0
    var lastFingerLocation:CGPoint!
    
    init(startBounds: (() -> CGRect), direction: Slider.Direction, target: AnyObject, action: Selector) {
        self.startBounds = startBounds
        self.direction = direction
        super.init(target: target, action: action)
        didInit()
    }
    
    init(startBounds: () -> CGRect, direction: Slider.Direction) {
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
    
    func didInit() {
        //self.delaysTouchesBegan = true
        self.maximumNumberOfTouches = 1
        self.minimumNumberOfTouches = 1
        self.delaysTouchesBegan = false
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent) {
        super.touchesMoved(touches, withEvent: event)
        let touchPoint = touches.first!.locationInView(view)
        let prevTouchPoint = touches.first!.previousLocationInView(view)
        lastFingerLocation = touchPoint
        began: if state == .Began {
            if let sbiv = sliderBounds where CGRectContainsPoint(sbiv(), touchPoint) {
                view?.gestureRecognizers?.forEach({
                    if $0 != self && $0 is SmartSliderGesture {
                        $0.state = .Cancelled
                    }
                })
                break began /* dont cancel */
            }
            else if let sb = startBounds where !CGRectContainsPoint(sb(), touchPoint) { state = .Cancelled }
            
            let velocity = velocityInView(view)
            switch direction {
            case .Right where fabs(velocity.y) > fabs(velocity.x), .Left where fabs(velocity.y) > fabs(velocity.x):
                state = .Cancelled
            case .Up where fabs(velocity.x) > fabs(velocity.y), .Down where fabs(velocity.x) > fabs(velocity.y):
                state = .Cancelled
            default:
                break
            }
        }
        
        if state == .Changed || state == .Began {
            switch direction {
            case .Right:
                change = touchPoint.x - prevTouchPoint.x
                perpendicularDisplacement = touchPoint.y - prevTouchPoint.y
            case .Left:
                change = prevTouchPoint.x - touchPoint.x
                perpendicularDisplacement = touchPoint.y - prevTouchPoint.y
            case .Down:
                change = touchPoint.y - prevTouchPoint.y
                perpendicularDisplacement = touchPoint.x - prevTouchPoint.x
            case .Up:
                change = prevTouchPoint.y - touchPoint.y
                perpendicularDisplacement = touchPoint.x - prevTouchPoint.x
            }
            let frame = (view != nil) ? view!.frame : UIScreen.mainScreen().bounds
            let progressLength: CGFloat = (direction == .Right || direction == .Left) ? frame.width : frame.height
            progressChange = Float(sensitivity * change / progressLength)
        }
    }
    
    override func reset() {
        super.reset()
        change = 0
        perpendicularDisplacement = 0
    }
    
}