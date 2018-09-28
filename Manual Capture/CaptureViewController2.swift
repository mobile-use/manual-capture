//
//  CaptureViewController2.swift
//  Capture
//
//  Created by Jean Flaherty on 11/22/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class CaptureViewController2: UIViewController {
//    typealias Constraints = CaptureConstraint
    typealias PreviewView = CapturePreviewView
    
    let steadyView = RotationContainer()
    // Continue
    var continueView = UIView()
    var controlView: CaptureView2!
    var controlViewContainer = RotationContainer()
    var captureButton = UIButton.shutterButton()
    var captureButtonContainer: RotationContainer!
    var previewView: PreviewView!
    
    
    
    private var layout: Layout = []
    
    func layout(layout: Layout, duration: TimeInterval = 0.3){
        let oldLayout = self.layout
        typealias Block = ()->()
        typealias Curry = (Block)->()
        typealias Conditional = (Layout) -> Curry?
        
        let curry: Curry = { $0() }
        let has: Conditional = { self.layout.contains($0) ? curry : nil }
        let hasNot: Conditional = { !self.layout.contains($0) ? curry : nil }
        let had: Conditional = { oldLayout.contains($0) ? curry : nil }
        let hadNot: Conditional = { oldLayout.contains($0) ? curry : nil }
        let added: Conditional = { (has($0) != nil && hadNot($0) != nil) ? curry : nil }
        let removed: Conditional = { (had($0) != nil && hasNot($0) != nil) ? curry : nil }
        
        var animations: [Block] = []
        var completions: [Block] = []
        
        
        added(.go)? {
            self.previewView = self.controlView.sessionController.previewView
        }
        removed(.go)? {
            self.previewView = nil
        }
        has(.initial)? {
            print("hi")
        }
    }
    
//    var sessionController: CSController2!
    
    override func viewDidLoad() {
        captureButtonContainer = RotationContainer(view: captureButton)
        controlView = CaptureView2(frame: controlViewContainer.view.bounds)
        let toolbar = UIView()
        let capturebar = UIView()
//        sessionController = CSController2()
        previewView = controlView.sessionController.previewView
        
//        controlView.backgroundColor = .red
        
        view.layout(style: Style.FillSuperview, views: steadyView)
        steadyView.view.layout(style: Style.FillSuperview, views: previewView)
        
        steadyView.view.layout(style: Style.Capturebar, views: capturebar)
        steadyView.view.layout(style: Style.CaptureButtonContainer, views: captureButtonContainer)
        steadyView.view.layout(style: Style.Toolbar, views: toolbar)
        
        steadyView.view.layout(style: Style.FillSuperview, views: controlViewContainer)
        
        controlViewContainer.view.layout(style: Style.FillSuperview, views: controlView)
        view.backgroundColor = UIColor.black
        
        layout = .initial
        layout.proceed(layouts: .shoot, .whiteBalance, .focus, .whiteBalance)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        let selector = #selector(self.deviceOrientationChanged)
        NotificationCenter.default.addObserver(self, selector: selector,
                                               name:UIDevice.orientationDidChangeNotification , object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let deltaTransform = coordinator.targetTransform
        let newAngle = self.steadyView.rotation - atan2(deltaTransform.b, deltaTransform.a)
        
        coordinator.animate(alongsideTransition: { coordinator in
            // counter rotate
            self.steadyView.rotation = newAngle + 0.0001
        }, completion: { coordinator in
            // get rid of 0.0001
            self.steadyView.rotation = newAngle
        })
    }
    
    enum Orientation {
        case landscapeRight
        case portrait
        case landscapeLeft
        var rotation: Double {
            switch self {
            case .landscapeRight: return 0.00001-Double.pi
            case .portrait: return -Double.pi/2
            case .landscapeLeft: return 0
            }
        }
    }
    
    var orientation: Orientation = .landscapeLeft {
        didSet(oldOrientation) {
            guard orientation != oldOrientation else { return }

            let duration: TimeInterval = 0.2
            let animations = (
                normal: {
                    self.captureButtonContainer.rotation = CGFloat(self.orientation.rotation)
                    
                    let aspectRatioOrientationAgnostic = self.controlView.sessionController.aspectRatioMode != .fullscreen && self.controlView.sessionController.aspectRatioMode != .sensor
                    let heightAndWidthSwapped = self.orientation == .portrait || oldOrientation == .portrait
                    if heightAndWidthSwapped && aspectRatioOrientationAgnostic {
                        self.previewView.aspectRatio = 1 / self.previewView.aspectRatio
                    }
                },
                fade: {
                    var rect = self.steadyView.view.bounds
                    
//                    if self.orientation == .portrait {
//                        rect.size.width -= 40
//                    }
                    self.controlViewContainer.frame = rect
                    self.controlViewContainer.rotation = CGFloat(self.orientation.rotation)
                }
            )
            UIView.animate(withDuration: duration) { CATransaction.performBlock(duration: duration) {
                    animations.normal()
            }}
            UIView.animate(withDuration: duration,
                           animations: { self.controlViewContainer.alpha = 0.0 },
                           completion: { _ in
                CATransaction.disableActions {
                    animations.fade()
                }
                UIView.animate(withDuration: duration) { self.controlViewContainer.alpha = 1.0 }
            })
        }
    }
    
    @objc func deviceOrientationChanged() {
        switch UIDevice.current.orientation {
            case .landscapeRight: orientation = .landscapeRight
            case .portrait: orientation = .portrait
            case .landscapeLeft: orientation = .landscapeLeft
            default: return
        }
    }
    
    override var prefersStatusBarHidden: Bool { return true }
    
    struct Layout : OptionSet {
        let rawValue: UInt
        
        static let initial = Layout(rawValue: 1)
        
        // Init
        static let go = Layout(rawValue: 1 << 1)
        static let pause = Layout(rawValue: 1 << 2)
        
        // Go
        static let shoot = Layout(rawValue: 1 << 3)
        static let options = Layout(rawValue: 1 << 4)
        
        // Pause
        static let error = Layout(rawValue: 1 << 5)
        
        // Go, Pause
        static let help = Layout(rawValue: 1 << 6)
        
        // Shoot, Options, Help
        static let focus = Layout(rawValue: 1 << 7)
        static let exposure = Layout(rawValue: 1 << 8)
        static let whiteBalance = Layout(rawValue: 1 << 9)
        static let zoom = Layout(rawValue: 1 << 10)
        static let aspectRatio = Layout(rawValue: 1 << 11)
        
        //////
        
        private var _optionState: Group { return [.focus, .exposure, .whiteBalance, .zoom, .aspectRatio] }
        private var _mainState: Group { return [.shoot, .options, .help] }
        private var _sessionState: Group { return [.go, .pause] }
        
        static let optionState: Layout = [.focus, .exposure, .whiteBalance, .zoom, .aspectRatio]
        static let mainState: Layout = [.shoot, .options, .help]
        static let sessionState: Layout = [.go, .pause]
        
        typealias Group = [Component]
        typealias Component = Layout
        typealias Path = Layout
        typealias PartialPath = Layout
        
        private func path(component: Component, suspectHeritages: [Path?], componentGroup: Group = [], sisterGroups: [Group] = []) -> Path? {
            let suspectHeritages = suspectHeritages.reduce([Path]()) { return ($1 != nil) ? $0 + [$1!] : $0 }
            
            let currentSisters: PartialPath = sisterGroups.reduce(Component()) { (currentSisters, sisterGroup) -> Component in
                for currentSister in sisterGroup {
                    if self.contains(currentSister) {
                        return currentSisters.union(currentSister)
                    }
                }
                return currentSisters
            }
            
            if suspectHeritages.count == 1 {
                if let heritage = suspectHeritages.first {
                    return [heritage, component, currentSisters]
                }
            }
            
            // search self's decendants
            for suspectHeritage in suspectHeritages {
                if self == suspectHeritage {
                    let heritage = suspectHeritage
                    return [heritage, component, currentSisters]
                }
            }
            // search siblings
            let currentHeritage = componentGroup.reduce(self) { $0.subtracting($1) }.subtracting(currentSisters)
            
            for suspectHeritage in suspectHeritages {
                if currentHeritage == suspectHeritage {
                    let heritage = suspectHeritage
                    return [heritage, component, currentSisters]
                }
            }
            // search ancestry
            for suspectHeritage in suspectHeritages {
                if self.contains(suspectHeritage) {
                    let heritage = suspectHeritage
                    return [heritage, component, currentSisters]
                }
            }
            
            return nil
        }
        
        private func optionStatePath(_ component:Component) -> Path? {
            return path(component: component,
                suspectHeritages: [goPath()],
                componentGroup: _optionState,
                sisterGroups: [_mainState])
        }
        
        private func mainStatePath(_ component:Component) -> Path? {
            return path(component: component,
                suspectHeritages: (component == .help) ? [goPath(), pausePath()] : [goPath()],
                componentGroup: _mainState,
                sisterGroups: [_optionState])
        }
        
        
        func initialPath() -> Path { return .initial }
        // Init
        func goPath() -> Path { return [initialPath(), .go] }
        func pausePath() -> Path { return [initialPath(), .pause] }
        // Go
        func focusPath() -> Path? { return optionStatePath(.focus) }
        func exposurePath() -> Path? { return optionStatePath(.exposure) }
        func whiteBalancePath() -> Path? { return optionStatePath(.whiteBalance) }
        func zoomPath() -> Path? { return optionStatePath(.zoom) }
        func aspectRatioPath() -> Path? { return optionStatePath(.aspectRatio) }
        // Pause
        func errorPath() -> Path { return [pausePath(), .error] }
        // Focus, Exposure, WhiteBalance ect..
        func shootPath() -> Path? { return mainStatePath(.shoot) }
        func optionsPath() -> Path? { return mainStatePath(.options) }
        // Focus, Exposure, WhiteBalance ect.. + Pause
        func helpPath() -> Path? { return mainStatePath(.help) }
        
        
        mutating func proceed(layouts: Layout...) {
            for layout in layouts {
                func mutateFor(component: Component) -> ((Path?)->(Path?))? {
                    if layout.contains(component) {
                        return { $0 }
                    }
                    return nil
                }
                
                if let path = mutateFor(component: .initial)? (initialPath()) { self = path }
                
                if let path = mutateFor(component: .pause)? (pausePath()) { self = path }
                if let path = mutateFor(component: .go)? (goPath()) { self = path }
                
                if let path = mutateFor(component: .help)? (helpPath()) { self = path }
                if let path = mutateFor(component: .options)? (optionsPath()) { self = path }
                if let path = mutateFor(component: .shoot)? (shootPath()) { self = path }
                
                if let path = mutateFor(component: .error)? (errorPath()) { self = path }
                
                if let path = mutateFor(component: .aspectRatio)? (aspectRatioPath()) { self = path }
                if let path = mutateFor(component: .zoom)? (zoomPath()) { self = path }
                if let path = mutateFor(component: .whiteBalance)? (whiteBalancePath()) { self = path }
                if let path = mutateFor(component: .exposure)? (exposurePath()) { self = path }
                if let path = mutateFor(component: .focus)? (focusPath()) { self = path }
                
            }
            
        }
        
    }
}
