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
    var controlView = RotationContainer()
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
        
        
        added(.Continue)? {
            self.previewView = self.sessionController.previewView
        }
        removed(.Continue)? {
            self.previewView = nil
        }
        has(.Init)? {
            print("hi")
        }
    }
    
    var sessionController: CSController2!
    
    override func viewDidLoad() {
        captureButtonContainer = RotationContainer(view: captureButton)
        let toolbar = UIView()
        let capturebar = UIView()
        sessionController = CSController2()
        previewView = sessionController.previewView
        
        view.layout(style: Style.FillSuperview, views: steadyView)
        steadyView.view.layout(style: Style.FillSuperview, views: previewView)
        steadyView.view.addSubview(controlView)
        steadyView.view.layout(style: Style.Capturebar, views: capturebar)
        steadyView.view.layout(style: Style.CaptureButtonContainer, views: captureButtonContainer)
        steadyView.view.layout(style: Style.Toolbar, views: toolbar)
        
        layout = .Init
        
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
                    
                    let heightAndWidthSwapped = self.orientation == .portrait || oldOrientation == .portrait
                    if heightAndWidthSwapped {
                        self.previewView.aspectRatio = 1 / self.previewView.aspectRatio
                    }
                },
                fade: {
                    var rect = self.steadyView.view.bounds
                    
                    if self.orientation == .portrait {
                        rect.size.width -= 40
                    }
                    self.controlView.frame = rect
                    self.controlView.rotation = CGFloat(self.orientation.rotation)
                }
            )
            UIView.animate(withDuration: duration) { CATransaction.performBlock(duration: duration) {
                    animations.normal()
            }}
            UIView.animate(withDuration: duration,
                animations: { self.controlView.alpha = 0.0 }, completion: { _ in
                    CATransaction.disableActions {
                        animations.fade()
                    }
                    UIView.animate(withDuration: duration) { self.controlView.alpha = 1.0 }
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
        
        static let Init = Layout(rawValue: 1)
        
        // Init
        static let Continue = Layout(rawValue: 1 << 1)
        static let Pause = Layout(rawValue: 1 << 2)
        
        // Go
        static let Shoot = Layout(rawValue: 1 << 3)
        static let Options = Layout(rawValue: 1 << 4)
        
        // Pause
        static let Error = Layout(rawValue: 1 << 5)
        
        // Go, Pause
        static let Help = Layout(rawValue: 1 << 6)
        
        // Shoot, Options, Help
        static let Focus = Layout(rawValue: 1 << 7)
        static let Exposure = Layout(rawValue: 1 << 8)
        static let WhiteBalance = Layout(rawValue: 1 << 9)
        static let Zoom = Layout(rawValue: 1 << 10)
        static let AspectRatio = Layout(rawValue: 1 << 11)
        
        //////
        
        private var _OptionState: Group { return [.Focus, .Exposure, .WhiteBalance, .Zoom, .AspectRatio] }
        private var _ContinueState: Group { return [.Shoot, .Options, .Help] }
        
        static let OptionState: Layout = [.Focus, .Exposure, .WhiteBalance, .Zoom, .AspectRatio]
        static let ContinueState: Layout = [.Shoot, .Options, .Help]
        
        typealias Group = [Component]
        typealias Component = Layout
        typealias Path = Layout
        typealias PartialPath = Layout
        
        private func PathMake(component: Component, suspectHeritages: [Path?], componentGroup: Group = [], sisterGroups: [Group] = []) -> Path? {
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
        
        private func PathMakeOptionSate(_ component:Component) -> Path? {
            return PathMake(component: component,
                suspectHeritages: [ContinuePath()],
                componentGroup: _OptionState,
                sisterGroups: [_ContinueState])
        }
        
        private func PathMakeGoState(_ component:Component) -> Path? {
            return PathMake(component: component,
                suspectHeritages: (component == .Help) ? [ContinuePath(), PausePath()] : [ContinuePath()],
                componentGroup: _ContinueState,
                sisterGroups: [_OptionState])
        }
        
        
        func InitPath() -> Path { return .Init }
        // Init
        func ContinuePath() -> Path { return [InitPath(), .Continue] }
        func PausePath() -> Path { return [InitPath(), .Pause] }
        // Go
        func FocusPath() -> Path? { return PathMakeOptionSate(.Focus) }
        func ExposurePath() -> Path? { return PathMakeOptionSate(.Exposure) }
        func WhiteBalancePath() -> Path? { return PathMakeOptionSate(.WhiteBalance) }
        func ZoomPath() -> Path? { return PathMakeOptionSate(.Zoom) }
        func AspectRatioPath() -> Path? { return PathMakeOptionSate(.AspectRatio) }
        // Pause
        func ErrorPath() -> Path { return [PausePath(), .Error] }
        // Focus, Exposure, WhiteBalance ect..
        func ShootPath() -> Path? { return PathMakeGoState(.Shoot) }
        func OptionsPath() -> Path? { return PathMakeGoState(.Options) }
        // Focus, Exposure, WhiteBalance ect.. + Pause
        func HelpPath() -> Path? { return PathMakeGoState(.Help) }
        
        
        mutating func proceed(layouts: Layout...) {
            for layout in layouts {
                func mutateFor(component: Component) -> ((Path?)->(Path?))? {
                    if layout.contains(component) {
                        return { $0 }
                    }
                    return nil
                }
                
                if let path = mutateFor(component: .Init)? (InitPath()) { self = path }
                
                if let path = mutateFor(component: .Pause)? (PausePath()) { self = path }
                if let path = mutateFor(component: .Continue)? (ContinuePath()) { self = path }
                
                if let path = mutateFor(component: .Help)? (HelpPath()) { self = path }
                if let path = mutateFor(component: .Options)? (OptionsPath()) { self = path }
                if let path = mutateFor(component: .Shoot)? (ShootPath()) { self = path }
                
                if let path = mutateFor(component: .Error)? (ErrorPath()) { self = path }
                
                if let path = mutateFor(component: .AspectRatio)? (AspectRatioPath()) { self = path }
                if let path = mutateFor(component: .Zoom)? (ZoomPath()) { self = path }
                if let path = mutateFor(component: .WhiteBalance)? (WhiteBalancePath()) { self = path }
                if let path = mutateFor(component: .Exposure)? (ExposurePath()) { self = path }
                if let path = mutateFor(component: .Focus)? (FocusPath()) { self = path }
                
            }
            
        }
        
    }
}
