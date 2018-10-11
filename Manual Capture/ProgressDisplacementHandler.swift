//
//  SliderGestureHandler.swift
//  Capture
//
//  Created by Jean on 9/8/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

/// Abstract Progress Displacement Handler Class
class ProgressDisplacementHandler: NSObject {
    struct State: OptionSet {
        let rawValue: Int
        static var normal = State(rawValue: 0)
        static let disabled = State(rawValue: 1 << 0)
        static let active = State(rawValue: 1 << 1)
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
    
    /// Callback sending info about how much to change progress
    var actionDisplace: ((Float) -> Void)?
    var actionStateChanged: ((State) -> Void)?
    
    /// Ensures displacement actions won't get called when disabled
    var enabled: Bool = true {didSet{ state.getUpdateTransform(!enabled, .disabled)? (&state) }}
    internal(set) var active: Bool = false {didSet{ state.getUpdateTransform(active, .active)? (&state) }}
    internal(set) var state: State = .normal {didSet{ actionStateChanged?(state) }}

    internal func shouldDisplace() -> Bool { return enabled }
    internal func startDisplacing() { active = shouldDisplace() }
    internal func continueDisplacing(_ displacement:Float) {
        if shouldDisplace() {
            if !active { active = true }
            actionDisplace?(displacement)
        }
    }
    internal func stopDisplacing() { active = false }
}

class PDGestureBased<G:UIGestureRecognizer>: ProgressDisplacementHandler {
    // Any subclass of UIGestureRecognizer
    
    var gesture: G {
        didSet(oldGesture){
            oldGesture.removeTarget(self, action: #selector(self.gestureAction(sender:)))
            gesture.addTarget(self, action: #selector(self.gestureAction(sender:)))
        }
    }
    
    ///    Called when gestureRecognizer calls gestureAction() and needs to call displace.
    ///    Use gesture parameter to return progress displacement
    var gestureChangeHandler: (G) -> Float
    
    /// Enable / disable gesture and ensures displacementAction{} won't get called when disabled
    override var enabled: Bool {
        set{   gesture.isEnabled = newValue  }
        get{   return gesture.isEnabled      }
    }
    
    init(gesture: G, gestureHandler: @escaping (_ gesture: G) -> Float){
        self.gestureChangeHandler = gestureHandler
        self.gesture = gesture
        super.init()
        self.gesture.addTarget(self, action: #selector(self.gestureAction(sender:)))
    }
    
    @objc func gestureAction(sender:UIGestureRecognizer){
        guard let gesture = sender as? G else {
            fatalError("{[\(NSStringFromClass(type(of: self))).\(#function)} sender does not match type constraint.")
        }
        switch gesture.state {
        case .began: startDisplacing()
        case .changed:
            let d = gestureChangeHandler(gesture)
            continueDisplacing(d)
        case .possible: break
        default: stopDisplacing()
        }
    }
}

class PDScale: PDGestureBased<UIPinchGestureRecognizer> {
    private var lastScale: CGFloat = 1.0
    var currentScale: (() -> CGFloat)?
    var maxScale: CGFloat = 2.0
    let valueProgressHandler: ValueProgressHandler<CGFloat>
    init(_ gestureView:UIView, valueProgressHandler: ValueProgressHandler<CGFloat>) {
        self.valueProgressHandler = valueProgressHandler
        let g = UIPinchGestureRecognizer()
        gestureView.addGestureRecognizer(g)
        super.init(gesture: g){ Float($0.scale - 1.0) }
        gestureChangeHandler = {
            let maxChange = self.maxScale - 1.0
            guard maxChange != 0 else { return 0 }
            let scaleChange = valueProgressHandler.progressForValue($0.scale) - valueProgressHandler.progressForValue(self.lastScale)
            self.lastScale = $0.scale
            return scaleChange
        }
    }
    
    override func startDisplacing() {
        guard let currentScale = currentScale?() else {return}
            lastScale = currentScale
            gesture.scale = currentScale
    }
    
}
