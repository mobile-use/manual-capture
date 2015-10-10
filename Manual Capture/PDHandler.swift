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
    struct State: OptionSetType {
        let rawValue: Int
        static var Normal = State(rawValue: 0)
        static let Disabled = State(rawValue: 1 << 0)
        static let Active = State(rawValue: 1 << 1)
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
    
    /// Callback sending info about how much to change progress
    var actionDisplace: ((Float) -> Void)?
    var actionStateChanged: ((State) -> Void)?
    
    /// Ensures displacement actions won't get called when disabled
    var enabled: Bool = true {didSet{ state.getUpdateTransform(!enabled, .Disabled)? (&state) }}
    internal(set) var active: Bool = false {didSet{ state.getUpdateTransform(active, .Active)? (&state) }}
    internal(set) var state: State = .Normal {didSet{ actionStateChanged?(state) }}

    internal func shouldDisplace() -> Bool { return enabled }
    internal func startDisplacing() { active = shouldDisplace() }
    internal func continueDisplacing(displacement:Float) {
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
            oldGesture.removeTarget(self, action: "gestureAction:")
            gesture.addTarget(self, action: "gestureAction:")
        }
    }
    
    ///    Called when gestureRecognizer calls gestureAction() and needs to call displace.
    ///    Use gesture parameter to return progress displacement
    var gestureChangeHandler: (G) -> Float
    
    /// Enable / disable gesture and ensures displacementAction{} won't get called when disabled
    override var enabled: Bool {
        set{   gesture.enabled = newValue  }
        get{   return gesture.enabled      }
    }
    
    init(gesture: G, gestureHandler: (gesture: G) -> Float){
        self.gestureChangeHandler = gestureHandler
        self.gesture = gesture
        super.init()
        self.gesture.addTarget(self, action: "gestureAction:")
    }
    
    func gestureAction(sender:UIGestureRecognizer){
        guard let gesture = sender as? G else {
            fatalError("{[\(NSStringFromClass(self.dynamicType)).\(__FUNCTION__)} sender does not match type constraint.")
        }
        switch gesture.state {
        case .Began: startDisplacing()
        case .Changed:
            let d = gestureChangeHandler(gesture)
            continueDisplacing(d)
        case .Possible: break
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
//        case .AlongTop: return CGRectMake(0, 0, W, E)
//        case .AlongRight: return CGRectMake(W - E, 0, E, H)
//        case .AlongBottom: return CGRectMake(0, H - E, W, E)
//        case .AlongLeft: return CGRectMake(0, 0, E, H)
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