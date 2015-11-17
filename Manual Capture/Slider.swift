//
//  Slider.swift
//  Capture
//
//  Created by Jean on 9/10/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
//var currentControl: Control? = nil
class Control: UIView {
    static var currentControl: Control? = nil {
        didSet(oldControl) {
            //guard Control.currentControl != oldControl else {return}
            oldControl?.isCurrentControl = false
            currentControl?.isCurrentControl = true
        }
    }
    var isCurrentControl:Bool = false {didSet{
        state.getUpdateTransform(isCurrentControl, .Current)?(&state)
        }}
    final func becomeCurrentControl(){
        guard Control.currentControl != self else {return}
        Control.currentControl = self
    }
    final func resignCurrentControl(){
        guard Control.currentControl == self else {return}
        Control.currentControl = nil
    }
    
    var actionDidStateChange: ((add: State, remove: State) -> Void)?
    var actionWillStateChange: ((add: State, remove: State) -> Void)?
    
    
    struct State: OptionSetType {
        let rawValue: Int
        static var Normal = State(rawValue: 0)
        static let Disabled = State(rawValue: 1 << 0)
        static let Active = State(rawValue: 1 << 1)
        static let Current = State(rawValue: 1 << 2)
        static let Simplified = State(rawValue: 1 << 3)
        static let ComputerControlled = State(rawValue: 1 << 4)
        func hasProperty(property: State) -> Bool {
            // Makes no sense to ask if state contains empty property
            if property.isEmpty {return self.isEmpty}
            return contains(property)
        }
        
        typealias StateTransForm = (inout State) -> Void
        /// returns nil if update is unneeded otherwise returns a inout closure that can do the job
        func getUpdateTransform(shouldHave:Bool, _ change:State) -> StateTransForm? {
            guard self.hasProperty(change) != shouldHave else {return nil/*no need to update*/ }
            if shouldHave {
                return { (inout state: State) in state.unionInPlace(change) }
            }else {
                return { (inout state: State) in state.subtractInPlace(change) }
            }
        }
    }
    var state: State = .Normal {
        didSet{
            guard state != oldValue else { return }
            didChangeState(oldValue)
            
            actionDidStateChange?(
                add: state.subtract(oldValue),
                remove: oldValue.subtract(state)
            )
        }
        willSet{
            guard state != newValue else { return }
            willChangeState(newValue)
            
            actionWillStateChange?(
                add: newValue.subtract(state),
                remove: state.subtract(newValue)
            )
        }
    }
    func didChangeState(oldState:State){}
    func willChangeState(newState:State){}
}

let kSliderKnobRadius: CGFloat = 9
let kSliderKnobMargin: CGFloat = 3
let kSliderKnobFadeMaxOpacity:Float = 0.4
let kSliderKnobFadeMinOpacity:Float = 0.0
let kSliderKnobDisabeledOpacity:Float = 0.4
let kSliderLineDisabledOpacity:Float = 0.4

class Slider : Control {
    var actionStarted:(() -> Void)?
    var actionEnded:(() -> Void)?
    
    enum Direction {
        case Right, Left, Down, Up
        enum Axis { case Horizontal, Vertical }
        var axis: Axis {
            switch self {
            case .Right, .Left: return .Horizontal
            case .Up, .Down: return .Vertical
            }
        }
    }

    var direction: Direction = .Right
    let lineLayer = CAShapeLayer()

    
    override func intrinsicContentSize() -> CGSize {
        switch direction.axis {
        case .Horizontal: return CGSizeMake(frame.width, 2*(kSliderKnobRadius+kSliderKnobMargin))
        case .Vertical: return CGSizeMake(2*(kSliderKnobRadius+kSliderKnobMargin), frame.height)
        }
    }
}

class GenericSlider<V, K: CALayer> : Slider {
    var actionProgressStarted:((GenericSlider<V, K>) -> Void)?
    var actionProgressChanged:((GenericSlider<V, K>) -> Void)?
    var actionProgressEnded:((GenericSlider<V, K>) -> Void)?
    
    var value: V! {
        set{
            setProgress(vpHandler?.progressForValue(newValue) ?? 0, animated:true)
            state.getUpdateTransform(true, .ComputerControlled)?(&state)
        }
        get{ return vpHandler?.valueForProgress(progress) }
    }
    
    internal(set) var progress: Float = 0.0
    
    func addPDHandler(key:NSObject, handler: PDHandler){
        handler.actionDisplace = { [weak self] in
            self?.setProgress(self!.progress + $0, animated: false)
            self?.actionProgressChanged?(self!)
        }
        handler.actionStateChanged = { [weak self](handlerState) in
            guard let slider = self else { return }
            if !slider.state.hasProperty(.Active) && handlerState.hasProperty(.Active) {
                // first to activate
                slider.becomeCurrentControl()
                slider.state.getUpdateTransform(true, .Active)?(&slider.state)
                slider.state.getUpdateTransform(false, .ComputerControlled)?(&slider.state)
                slider.actionProgressStarted?(slider)
            }
            else if slider.state.hasProperty(.Active) && !handlerState.hasProperty(.Active) {
                var active = false
                for (_, pdh) in slider.pdHandlers {
                    if pdh.state.hasProperty(.Active) { active = true; break }
                }
                if !active {
                    // last to deactivate
                    slider.state.subtractInPlace(.Active)
                    slider.actionProgressEnded?(slider)
                }
            }
        }
        pdHandlers[key] = handler
    }
    func removePDHandler(key:NSObject){
        pdHandlers.removeValueForKey(key)
    }
    internal(set) var pdHandlers:[ NSObject : PDHandler ] = [ : ]
    var vpHandler: VPHandler<V>?
    
    func setProgress(progress: Float, animated:Bool) {
        // temporarily disable default animation
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        let laniAnimating = lineLayer.animationForKey("pathAnimation") != nil
        let sanixAnimating = lineLayer.animationForKey("positionXAnimation") != nil
        let saniyAnimating = lineLayer.animationForKey("positionYAnimation") != nil
        if !animated {
            if laniAnimating || sanixAnimating || saniyAnimating {
                lineLayer.removeAnimationForKey("pathAnimation")
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
                if let pll = lineLayer.presentationLayer() as? CAShapeLayer {
                    sanix.fromValue = pll.path
                }
                if let psl = knobLayer.presentationLayer() as? CALayer {
                    sanix.fromValue = psl.position.x
                    saniy.fromValue = psl.position.y
                }
            }
            lineLayer.addAnimation(lani, forKey: "pathAnimation")
            knobLayer.addAnimation(sanix, forKey: "positionXAnimation")
            knobLayer.addAnimation(saniy, forKey: "positionYAnimation")
        }
        let inRangeValue = max(0, min(progress, 1))
        if inRangeValue != self.progress {
            self.progress = inRangeValue
            layer.layoutSublayers()
        }
        // resume default animation
        CATransaction.commit()
    }
    
    let knobLayer: K
    
    init(knobLayer: K, direction:Direction){
        self.knobLayer = knobLayer
        super.init(frame:CGRectZero)
        self.direction = direction
        
        lineLayer.strokeColor = UIColor.whiteColor().CGColor
        lineLayer.opacity = 1
        lineLayer.lineWidth = 1
        layer.addSublayer(lineLayer)
        
        //knobLayer.frame = CGRectMake(0, 0, kSliderKnobRadius*2, kSliderKnobRadius*2)
        knobLayer.zPosition = 100
        layer.addSublayer(knobLayer)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        guard self.layer.isEqual(layer) else{super.layoutSublayersOfLayer(layer);return}
        func setLinePathFor(sp1:CGPoint, _ ep1:CGPoint, _ sp2:CGPoint, _ ep2:CGPoint) {
            let lp1 = CGPathCreateMutable()
            let lp2 = CGPathCreateMutable()
            CGPathMoveToPoint(lp1, nil, sp1.x, sp1.y)
            CGPathAddLineToPoint(lp1, nil, ep1.x, ep1.y)
            CGPathMoveToPoint(lp2, nil, sp2.x, sp2.y)
            CGPathAddLineToPoint(lp2, nil, ep2.x, ep2.y)
            let combinedPath: CGMutablePathRef = CGPathCreateMutableCopy(lp1)!
            CGPathAddPath(combinedPath, nil, lp2)
            lineLayer.path = combinedPath
        }
        
        switch direction {
        case .Right:
            let sMR = kSliderKnobMargin + kSliderKnobRadius
            let y = bounds.midY
            // travel
            let tsp = CGPointMake(bounds.minX + sMR, y)
            let tep = CGPointMake(bounds.maxX - sMR, y)
            let td = (tep.x - tsp.x)*CGFloat(self.progress)
            // travel point
            let tp = CGPointMake(tsp.x + td, y)
            // line points
            let lsp1 = CGPointMake(bounds.minX, y)
            let lep1 = CGPointMake(tp.x - sMR, y)
            let lsp2 = CGPointMake(tp.x + sMR, y)
            let lep2 = CGPointMake(bounds.maxX, y)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            //_scrubberLayer.setPosition(position: tp, animated: false)
            knobLayer.position = tp
        case .Left:
            let sMR = kSliderKnobMargin + kSliderKnobRadius
            let y = bounds.midY
            // travel
            let tsp = CGPointMake(bounds.maxX - sMR, y)
            let tep = CGPointMake(bounds.minX + sMR, y)
            let td = (tep.x - tsp.x)*CGFloat(self.progress)
            // travel point
            let tp = CGPointMake(tsp.x + td, y)
            // line points
            let lsp1 = CGPointMake(bounds.maxX, y)
            let lep1 = CGPointMake(tp.x + sMR, y)
            let lsp2 = CGPointMake(tp.x - sMR, y)
            let lep2 = CGPointMake(bounds.minX, y)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = tp
        case .Down:
            let sMR = kSliderKnobMargin + kSliderKnobRadius
            let x = bounds.midX
            // travel
            let tsp = CGPointMake(x, bounds.minY + sMR)
            let tep = CGPointMake(x, bounds.maxY - sMR)
            let td = (tep.y - tsp.y)*CGFloat(self.progress)
            // travel point
            let tp = CGPointMake(x, tsp.y + td)
            // line points
            let lsp1 = CGPointMake(x, bounds.minY)
            let lep1 = CGPointMake(x, tp.y - sMR)
            let lsp2 = CGPointMake(x, tp.y + sMR)
            let lep2 = CGPointMake(x, bounds.maxY)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = tp
        case .Up:
            let sMR = kSliderKnobMargin + kSliderKnobRadius
            let x = bounds.midX
            // travel
            let tsp = CGPointMake(x, bounds.maxY - sMR)
            let tep = CGPointMake(x, bounds.minY + sMR)
            let td = (tep.y - tsp.y)*CGFloat(self.progress)
            // travel point
            let tp = CGPointMake(x, tsp.y + td)
            // line points
            let lsp1 = CGPointMake(x, bounds.maxY)
            let lep1 = CGPointMake(x, tp.y + sMR)
            let lsp2 = CGPointMake(x, tp.y - sMR)
            let lep2 = CGPointMake(x, bounds.minX)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = tp
        }
        
    }
}
