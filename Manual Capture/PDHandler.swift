//
//  SliderGestureHandler.swift
//  Capture
//
//  Created by Jean on 9/8/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

/// Abstract Progress Displacement Handler Class
class PDHandler: NSObject {
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

class PDGestureBased<G:UIGestureRecognizer>: PDHandler {
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
    let vpHandler: VPHandler<CGFloat>
    init(_ gestureView:UIView, vpHandler: VPHandler<CGFloat>) {
        self.vpHandler = vpHandler
        let g = UIPinchGestureRecognizer()
        gestureView.addGestureRecognizer(g)
        super.init(gesture: g){ Float($0.scale - 1.0) }
        gestureChangeHandler = {
            let maxChange = self.maxScale - 1.0
            guard maxChange != 0 else { return 0 }
            let scaleChange = vpHandler.progressForValue($0.scale) - vpHandler.progressForValue(self.lastScale)
            self.lastScale = $0.scale
            return scaleChange
        }
    }
    
    override func startDisplacing() {
        guard let cScale = currentScale?() else {return}
            lastScale = cScale
            gesture.scale = cScale
    }
    
}

//class PDEdgeSlide: PDGestureBased<SlideFromBoundsGestureRecognizer> {
//    enum Type : String {
//        case RightAlongTop = "RightAlongTop",
//        LeftAlongTop = "LeftAlongTop",
//        UpAlongRight = "UpAlongRight",
//        DownAlongRight = "DownAlongRight",
//        LeftAlongBottom = "LeftAlongBottom",
//        RightAlongBottom = "RightAlongBottom",
//        DownAlongLeft = "DownAlongLeft",
//        UpAlongLeft = "UpAlongLeft"
//        
//        enum Direction : String {
//            case Right = "Right",
//            Left = "Left",
//            Up = "Up",
//            Down = "Down"
//        }
//        enum Edge : String {
//            case AlongTop = "AlongTop",
//            AlongRight = "AlongRight",
//            AlongBottom = "AlongBottom",
//            AlongLeft = "AlongLeft"
//        }
//        var direction: Direction {
//            switch self {
//            case .UpAlongLeft, .UpAlongRight: return .Up
//            case .RightAlongTop, .RightAlongBottom: return .Right
//            case .DownAlongLeft, .DownAlongRight: return .Down
//            case .LeftAlongBottom, .LeftAlongTop: return .Left
//            }
//        }
//        var edge: Edge {
//            switch self {
//            case .RightAlongTop, .LeftAlongTop: return .AlongTop
//            case .UpAlongRight, .DownAlongRight: return .AlongRight
//            case .RightAlongBottom, .LeftAlongBottom: return .AlongBottom
//            case .UpAlongLeft, .DownAlongLeft: return .AlongLeft
//            }
//        }
//        func sfbDirection() -> SlideFromBoundsDirection {
//            switch direction {
//            case .Up: return .Up
//            case .Right: return .Right
//            case .Down: return .Down
//            case .Left: return .Left
//            }
//        }
//    }
//    
//    var type: Type
//    var gestureView: UIView
//    var edgeDistance: CGFloat = 160
//    var startBounds: CGRect {
//        let W = gestureView.frame.width
//        let H = gestureView.frame.height
//        let E = edgeDistance
//        switch type.edge {
//        case .AlongTop: return CGRect(0, 0, W, E)
//        case .AlongRight: return CGRect(W - E, 0, E, H)
//        case .AlongBottom: return CGRect(0, H - E, W, E)
//        case .AlongLeft: return CGRect(0, 0, E, H)
//        }
//    }
//    
//    init(type:Type, gestureView:UIView) {
//        self.type = type
//        self.gestureView = gestureView
//        let gesture = SlideFromBoundsGestureRecognizer(direction: type.sfbDirection())
//        gestureView.addGestureRecognizer(gesture)
//        super.init(gesture: gesture){ $0.progressChange }
//        self.gesture.startBounds = { self.startBounds }
//    }
//}
