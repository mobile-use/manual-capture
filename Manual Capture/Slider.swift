//
//  Slider.swift
//  Capture
//
//  Created by Jean on 9/10/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

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

class GenericSlider<Value, KnobLayer: CALayer> : Slider {
    var actionProgressStarted:((GenericSlider<Value, KnobLayer>) -> Void)?
    var actionProgressChanged:((GenericSlider<Value, KnobLayer>) -> Void)?
    var actionProgressEnded:((GenericSlider<Value, KnobLayer>) -> Void)?
    
    var value: Value! {
        set {
            setProgress(valueProgressHandler?.progressForValue(newValue) ?? 0, animated:true)
            state.getUpdateTransform(true, .computerControlled)?(&state)
        }
        get {
            return valueProgressHandler?.valueForProgress(progress)
        }
    }
    
    internal(set) var progress: Float = 0.0
    
    func addProgressDisplacementHandler(_ key: String, handler: ProgressDisplacementHandler){
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
                for (_, pdh) in slider.progressDisplacementHandlers {
                    if pdh.state.hasProperty(.active) { active = true; break }
                }
                if !active {
                    // last to deactivate
                    slider.state = slider.state.subtracting(.active)
                    slider.actionProgressEnded?(slider)
                }
            }
        }
        progressDisplacementHandlers[key] = handler
    }
    func removeProgressDisplacementHandler(_ key: String){
        progressDisplacementHandlers.removeValue(forKey: key)
    }
    internal(set) var progressDisplacementHandlers:[ String : ProgressDisplacementHandler ] = [ : ]
    var valueProgressHandler: ValueProgressHandler<Value>?
    
    func setProgress(_ progress: Float, animated:Bool) {
        // temporarily disable default animation
        CATransaction.begin()
        CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
        
        let lineAnimationAnimating = lineLayer.animation(forKey: "pathAnimation") != nil
        let knobAnimationXAnimating = lineLayer.animation(forKey: "positionXAnimation") != nil
        let knobAnimationYAnimating = lineLayer.animation(forKey: "positionYAnimation") != nil
        if !animated {
            if lineAnimationAnimating || knobAnimationXAnimating || knobAnimationYAnimating {
                lineLayer.removeAnimation(forKey: "pathAnimation")
                knobLayer.removeAnimation(forKey: "positionXAnimation")
                knobLayer.removeAnimation(forKey: "positionYAnimation")
            }
        } else {
            let lineAnimation = CABasicAnimation(keyPath: "path") // line path animation
            let knobAnimationX = CABasicAnimation(keyPath: "position.x") // knob x animation
            let knobAnimationY = CABasicAnimation(keyPath: "position.y") // scrubber y animation
            let animationGroup = CAAnimationGroup()
            animationGroup.animations = [lineAnimation, knobAnimationX, knobAnimationY]
            animationGroup.duration = 0.25
            animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animationGroup.isRemovedOnCompletion = true
            
            if lineAnimationAnimating && knobAnimationXAnimating && knobAnimationYAnimating {
                if let pll = lineLayer.presentation() {
                    knobAnimationX.fromValue = pll.path
                }
                if let psl = knobLayer.presentation() {
                    knobAnimationX.fromValue = psl.position.x
                    knobAnimationY.fromValue = psl.position.y
                }
            }
            lineLayer.add(lineAnimation, forKey: "pathAnimation")
            knobLayer.add(knobAnimationX, forKey: "positionXAnimation")
            knobLayer.add(knobAnimationY, forKey: "positionYAnimation")
        }
        let inRangeValue = max(0, min(progress, 1))
        if inRangeValue != self.progress {
            self.progress = inRangeValue
            layer.layoutSublayers()
        }
        // resume default animation
        CATransaction.commit()
    }
    
    let knobLayer: KnobLayer
    
    init(knobLayer: KnobLayer, direction:Direction){
        self.knobLayer = knobLayer
        super.init(frame:CGRect.zero)
        self.direction = direction
        
        lineLayer.strokeColor = UIColor.white.cgColor
        lineLayer.opacity = 1
        lineLayer.lineWidth = 1
        layer.addSublayer(lineLayer)
        
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
            lp1.addLine(to: ep1)
            lp2.move(to: sp2)
            lp2.addLine(to: ep2)
            let combinedPath: CGMutablePath = lp1.mutableCopy()!
            combinedPath.addPath(lp2)
            lineLayer.path = combinedPath
        }
        
        switch direction {
        case .right:
            let sliderMarginAndRadius = kSliderKnobMargin + kSliderKnobRadius
            let y = bounds.midY
            // travel
            let travelStart = CGPoint(x: bounds.minX + sliderMarginAndRadius, y: y)
            let travelEnd = CGPoint(x: bounds.maxX - sliderMarginAndRadius, y: y)
            let travelDistance = (travelEnd.x - travelStart.x)*CGFloat(self.progress)
            // travel point
            let travelPoint = CGPoint(x: travelStart.x + travelDistance, y: y)
            // line points
            let lsp1 = CGPoint(x: bounds.minX, y: y)
            let lep1 = CGPoint(x: travelPoint.x - sliderMarginAndRadius, y: y)
            let lsp2 = CGPoint(x: travelPoint.x + sliderMarginAndRadius, y: y)
            let lep2 = CGPoint(x: bounds.maxX, y: y)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            //_scrubberLayer.setPosition(position: tp, animated: false)
            knobLayer.position = travelPoint
        case .left:
            let sliderMarginAndRadius = kSliderKnobMargin + kSliderKnobRadius
            let y = bounds.midY
            // travel
            let travelStart = CGPoint(x: bounds.maxX - sliderMarginAndRadius, y: y)
            let travelEnd = CGPoint(x: bounds.minX + sliderMarginAndRadius, y: y)
            let travelDistance = (travelEnd.x - travelStart.x) * CGFloat(self.progress)
            // travel point
            let travelPoint = CGPoint(x: travelStart.x + travelDistance, y: y)
            // line points
            let lsp1 = CGPoint(x: bounds.maxX, y: y)
            let lep1 = CGPoint(x: travelPoint.x + sliderMarginAndRadius, y: y)
            let lsp2 = CGPoint(x: travelPoint.x - sliderMarginAndRadius, y: y)
            let lep2 = CGPoint(x: bounds.minX, y: y)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = travelPoint
        case .down:
            let sliderMarginAndRadius = kSliderKnobMargin + kSliderKnobRadius
            let x = bounds.midX
            // travel
            let travelStart = CGPoint(x: x, y: bounds.minY + sliderMarginAndRadius)
            let travelEnd = CGPoint(x: x, y: bounds.maxY - sliderMarginAndRadius)
            let travelDistance = (travelEnd.y - travelStart.y) * CGFloat(self.progress)
            // travel point
            let travelPoint = CGPoint(x: x, y: travelStart.y + travelDistance)
            // line points
            let lsp1 = CGPoint(x: x, y: bounds.minY)
            let lep1 = CGPoint(x: x, y: travelPoint.y - sliderMarginAndRadius)
            let lsp2 = CGPoint(x: x, y: travelPoint.y + sliderMarginAndRadius)
            let lep2 = CGPoint(x: x, y: bounds.maxY)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = travelPoint
        case .up:
            let sliderMarginAndRadius = kSliderKnobMargin + kSliderKnobRadius
            let x = bounds.midX
            // travel
            let travelStart = CGPoint(x: x, y: bounds.maxY - sliderMarginAndRadius)
            let travelEnd = CGPoint(x: x, y: bounds.minY + sliderMarginAndRadius)
            let travelDistance = (travelEnd.y - travelStart.y) * CGFloat(self.progress)
            // travel point
            let tp = CGPoint(x: x, y: travelStart.y + travelDistance)
            // line points
            let lsp1 = CGPoint(x: x, y: bounds.maxY)
            let lep1 = CGPoint(x: x, y: tp.y + sliderMarginAndRadius)
            let lsp2 = CGPoint(x: x, y: tp.y - sliderMarginAndRadius)
            let lep2 = CGPoint(x: x, y: bounds.minX)
            setLinePathFor(lsp1, lep1, lsp2, lep2)
            knobLayer.position = tp
        }
        
    }
}
