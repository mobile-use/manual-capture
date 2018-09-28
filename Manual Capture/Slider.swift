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
        state.getUpdateTransform(isCurrentControl, .current)?(&state)
        }}
    final func becomeCurrentControl(){
        guard Control.currentControl != self else {return}
        Control.currentControl = self
    }
    final func resignCurrentControl(){
        guard Control.currentControl == self else {return}
        Control.currentControl = nil
    }
    
    var actionDidStateChange: ((_ add: State, _ remove: State) -> Void)?
    var actionWillStateChange: ((_ add: State, _ remove: State) -> Void)?
    
    
    struct State: OptionSet {
        let rawValue: Int
        static var normal = State(rawValue: 0)
        static let disabled = State(rawValue: 1 << 0)
        static let active = State(rawValue: 1 << 1)
        static let current = State(rawValue: 1 << 2)
        static let simplified = State(rawValue: 1 << 3)
        static let computerControlled = State(rawValue: 1 << 4)
        func hasProperty(_ property: State) -> Bool {
            // Makes no sense to ask if state contains empty property
            if property.isEmpty {return self.isEmpty}
            return contains(property)
        }
        
        typealias StateTransForm = (inout State) -> Void
        /// returns nil if update is unneeded otherwise returns a inout closure that can do the job
        func getUpdateTransform(_ shouldHave:Bool, _ change:State) -> StateTransForm? {
            guard self.hasProperty(change) != shouldHave else { return nil/*no need to update*/ }
            if shouldHave {
                return { ( state: inout State) in state = state.union(change) }
            } else {
                return { ( state: inout State) in state = state.subtracting(change) }
            }
        }
    }
    var state: State = .normal {
        didSet{
            guard state != oldValue else { return }
            didChangeState(oldState: oldValue)
            
            actionDidStateChange?(
                state.subtracting(oldValue),
                oldValue.subtracting(state)
            )
        }
        willSet{
            guard state != newValue else { return }
            willChangeState(newState: newValue)
            
            actionWillStateChange?(
                newValue.subtracting(state),
                state.subtracting(newValue)
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
        case right, left, down, up
        enum Axis { case horizontal, vertical }
        var axis: Axis {
            switch self {
            case .right, .left: return .horizontal
            case .up, .down: return .vertical
            }
        }
    }

    var direction: Direction = .right
    let lineLayer = CAShapeLayer()

    override var intrinsicContentSize: CGSize {
        switch direction.axis {
            case .horizontal: return CGSize(width: frame.width, height: 2*(kSliderKnobRadius+kSliderKnobMargin))
            case .vertical: return CGSize(width: 2*(kSliderKnobRadius+kSliderKnobMargin), height: frame.height)
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
            state.getUpdateTransform(true, .computerControlled)?(&state)
        }
        get{ return vpHandler?.valueForProgress(progress) }
    }
    
    internal(set) var progress: Float = 0.0
    
    func addPDHandler(_ key: String, handler: PDHandler){
        handler.actionDisplace = { [weak self] in
            self?.setProgress(self!.progress + $0, animated: false)
            self?.actionProgressChanged?(self!)
        }
        handler.actionStateChanged = { [weak self] handlerState in
            guard let slider = self else { return }
            if !slider.state.hasProperty(.active) && handlerState.hasProperty(.active) {
                // first to activate
                slider.becomeCurrentControl()
                slider.state.getUpdateTransform(true, .active)?(&slider.state)
                slider.state.getUpdateTransform(false, .computerControlled)?(&slider.state)
                slider.actionProgressStarted?(slider)
            }
            else if slider.state.hasProperty(.active) && !handlerState.hasProperty(.active) {
                var active = false
                for (_, pdh) in slider.pdHandlers {
                    if pdh.state.hasProperty(.active) { active = true; break }
                }
                if !active {
                    // last to deactivate
                    slider.state = slider.state.subtracting(.active)
                    slider.actionProgressEnded?(slider)
                }
            }
        }
        pdHandlers[key] = handler
    }
    func removePDHandler(_ key: String){
        pdHandlers.removeValue(forKey: key)
    }
    internal(set) var pdHandlers:[ String : PDHandler ] = [ : ]
    var vpHandler: VPHandler<V>?
    
    func setProgress(_ progress: Float, animated:Bool) {
        // temporarily disable default animation
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        let laniAnimating = lineLayer.animation(forKey: "pathAnimation") != nil
        let sanixAnimating = lineLayer.animation(forKey: "positionXAnimation") != nil
        let saniyAnimating = lineLayer.animation(forKey: "positionYAnimation") != nil
        if !animated {
            if laniAnimating || sanixAnimating || saniyAnimating {
                lineLayer.removeAnimation(forKey: "pathAnimation")
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
                if let pll = lineLayer.presentation() {
                    sanix.fromValue = pll.path
                }
                if let psl = knobLayer.presentation() {
                    sanix.fromValue = psl.position.x
                    saniy.fromValue = psl.position.y
                }
            }
            lineLayer.add(lani, forKey: "pathAnimation")
            knobLayer.add(sanix, forKey: "positionXAnimation")
            knobLayer.add(saniy, forKey: "positionYAnimation")
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
        super.init(frame:CGRect.zero)
        self.direction = direction
        
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.opacity = 1
        lineLayer.lineWidth = 1
        layer.addSublayer(lineLayer)
        
        //knobLayer.frame = CGRect(0, 0, kSliderKnobRadius*2, kSliderKnobRadius*2)
        knobLayer.zPosition = 100
        layer.addSublayer(knobLayer)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        guard self.layer.isEqual(layer) else{
            super.layoutSublayers(of: layer)
            return
        }
        func setLinePathFor(_ sp1:CGPoint, _ ep1:CGPoint, _ sp2:CGPoint, _ ep2:CGPoint) {
            let lp1 = CGMutablePath()
            let lp2 = CGMutablePath()
            lp1.move(to: sp1)
//            CGPathMoveToPoint(lp1, nil, sp1.x, sp1.y)
            lp1.addLine(to: ep1)
//            CGPathAddLineToPoint(lp1, nil, ep1.x, ep1.y)
            lp2.move(to: sp2)
//            CGPathMoveToPoint(lp2, nil, sp2.x, sp2.y)
            lp2.addLine(to: ep2)
//            CGPathAddLineToPoint(lp2, nil, ep2.x, ep2.y)
            let combinedPath: CGMutablePath = lp1.mutableCopy()!
            combinedPath.addPath(lp2)
//            CGPathAddPath(combinedPath, nil, lp2)
            lineLayer.path = combinedPath
        }
        
        switch direction {
        case .right:
            let sMR = kSliderKnobMargin + kSliderKnobRadius
            let y = bounds.midY
            // travel
            let tsp = CGPoint(x: bounds.minX + sMR, y: y)
            let tep = CGPoint(x: bounds.maxX - sMR, y: y)
            let td = (tep.x - tsp.x)*CGFloat(self.progress)
            // travel point
            let tp = CGPoint(x: tsp.x + td, y: y)
            // line points
            let lsp1 = CGPoint(x: bounds.minX, y: y)
            let lep1 = CGPoint(x: tp.x - sMR, y: y)
            let lsp2 = CGPoint(x: tp.x + sMR, y: y)
            let lep2 = CGPoint(x: bounds.maxX, y: y)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            //_scrubberLayer.setPosition(position: tp, animated: false)
            knobLayer.position = tp
        case .left:
            let sMR = kSliderKnobMargin + kSliderKnobRadius
            let y = bounds.midY
            // travel
            let tsp = CGPoint(x: bounds.maxX - sMR, y: y)
            let tep = CGPoint(x: bounds.minX + sMR, y: y)
            let td = (tep.x - tsp.x)*CGFloat(self.progress)
            // travel point
            let tp = CGPoint(x: tsp.x + td, y: y)
            // line points
            let lsp1 = CGPoint(x: bounds.maxX, y: y)
            let lep1 = CGPoint(x: tp.x + sMR, y: y)
            let lsp2 = CGPoint(x: tp.x - sMR, y: y)
            let lep2 = CGPoint(x: bounds.minX, y: y)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = tp
        case .down:
            let sMR = kSliderKnobMargin + kSliderKnobRadius
            let x = bounds.midX
            // travel
            let tsp = CGPoint(x: x, y: bounds.minY + sMR)
            let tep = CGPoint(x: x, y: bounds.maxY - sMR)
            let td = (tep.y - tsp.y)*CGFloat(self.progress)
            // travel point
            let tp = CGPoint(x: x, y: tsp.y + td)
            // line points
            let lsp1 = CGPoint(x: x, y: bounds.minY)
            let lep1 = CGPoint(x: x, y: tp.y - sMR)
            let lsp2 = CGPoint(x: x, y: tp.y + sMR)
            let lep2 = CGPoint(x: x, y: bounds.maxY)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = tp
        case .up:
            let sMR = kSliderKnobMargin + kSliderKnobRadius
            let x = bounds.midX
            // travel
            let tsp = CGPoint(x: x, y: bounds.maxY - sMR)
            let tep = CGPoint(x: x, y: bounds.minY + sMR)
            let td = (tep.y - tsp.y)*CGFloat(self.progress)
            // travel point
            let tp = CGPoint(x: x, y: tsp.y + td)
            // line points
            let lsp1 = CGPoint(x: x, y: bounds.maxY)
            let lep1 = CGPoint(x: x, y: tp.y + sMR)
            let lsp2 = CGPoint(x: x, y: tp.y - sMR)
            let lep2 = CGPoint(x: x, y: bounds.minX)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = tp
        }
        
    }
}
