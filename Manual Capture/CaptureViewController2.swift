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
    func layout(layout: Layout, duration: NSTimeInterval = 0.3){
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
        
        view.layout(Style.FillSuperview, views: steadyView)
        steadyView.view.layout(Style.FillSuperview, views: previewView)
        steadyView.view.addSubview(controlView)
        steadyView.view.layout(Style.Capturebar, views: capturebar)
        steadyView.view.layout(Style.CaptureButtonContainer, views: captureButtonContainer)
        steadyView.view.layout(Style.Toolbar, views: toolbar)
        
        layout = .Init
        
    }
    
    override func viewWillAppear(animated: Bool) {
        UIDevice.currentDevice().beginGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "deviceOrientationChanged",
            name:UIDeviceOrientationDidChangeNotification , object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        UIDevice.currentDevice().endGeneratingDeviceOrientationNotifications()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        let deltaTransform = coordinator.targetTransform()
        let newAngle = self.steadyView.rotation - atan2(deltaTransform.b, deltaTransform.a)
        
        coordinator.animateAlongsideTransition({ coordinator in
            // counter rotate
            self.steadyView.rotation = newAngle + 0.0001
            }, completion: { coordinator in
                // get rid of 0.0001
                self.steadyView.rotation = newAngle
        })
    }
    
    enum Orientation {
        case LandscapeRight
        case Portrait
        case LandscapeLeft
        var rotation: Double {
            switch self {
            case .LandscapeRight: return 0.00001-M_PI
            case .Portrait: return -M_PI/2
            case .LandscapeLeft: return 0
            }
        }
    }
    
    var orientation: Orientation = .LandscapeLeft {
        didSet(oldOrientation) {
            guard orientation != oldOrientation else { return }

            let duration: NSTimeInterval = 0.2
            let animations = (
                normal: {
                    self.captureButtonContainer.rotation = CGFloat(self.orientation.rotation)
                    
                    let heightAndWidthSwapped = self.orientation == .Portrait || oldOrientation == .Portrait
                    if heightAndWidthSwapped {
                        self.previewView.aspectRatio = 1 / self.previewView.aspectRatio
                    }
                },
                fade: {
                    var rect = self.steadyView.view.bounds
                    
                    if self.orientation == .Portrait {
                        rect.size.width -= 40
                    }
                    self.controlView.frame = rect
                    self.controlView.rotation = CGFloat(self.orientation.rotation)
                }
            )
            
            UIView.animateWithDuration(duration) { CATransaction.performBlock(duration) {
                    animations.normal()
            }}
            
            UIView.animateWithDuration(duration,
                animations: { self.controlView.alpha = 0.0 }, completion: { _ in
                    CATransaction.disableActions {
                        animations.fade()
                    }
                    UIView.animateWithDuration(duration) { self.controlView.alpha = 1.0 }
            })
        }
    }
    
    func deviceOrientationChanged() {
        switch UIDevice.currentDevice().orientation {
        case .LandscapeRight: orientation = .LandscapeRight
        case .Portrait: orientation = .Portrait
        case .LandscapeLeft: orientation = .LandscapeLeft
        default: return
        }
    }
    
    override func prefersStatusBarHidden() -> Bool { return true }
    
    struct Layout : OptionSetType {
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
            let currentHeritage = componentGroup.reduce(self) { $0.subtract($1) }.subtract(currentSisters)
            
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
        
        private mutating func PathMakeOptionSate(component:Component) -> Path? {
            return PathMake(component,
                suspectHeritages: [ContinuePath()],
                componentGroup: _OptionState,
                sisterGroups: [_ContinueState])
        }
        
        private mutating func PathMakeGoState(component:Component) -> Path? {
            return PathMake(component,
                suspectHeritages: (component == .Help) ? [ContinuePath(), PausePath()] : [ContinuePath()],
                componentGroup: _ContinueState,
                sisterGroups: [_OptionState])
        }
        
        
        mutating func InitPath() -> Path { return .Init }
        // Init
        mutating func ContinuePath() -> Path { return [InitPath(), .Continue] }
        mutating func PausePath() -> Path { return [InitPath(), .Pause] }
        // Go
        mutating func FocusPath() -> Path? { return PathMakeOptionSate(.Focus) }
        mutating func ExposurePath() -> Path? { return PathMakeOptionSate(.Exposure) }
        mutating func WhiteBalancePath() -> Path? { return PathMakeOptionSate(.WhiteBalance) }
        mutating func ZoomPath() -> Path? { return PathMakeOptionSate(.Zoom) }
        mutating func AspectRatioPath() -> Path? { return PathMakeOptionSate(.AspectRatio) }
        // Pause
        mutating func ErrorPath() -> Path { return [PausePath(), .Error] }
        // Focus, Exposure, WhiteBalance ect..
        mutating func ShootPath() -> Path? { return PathMakeGoState(.Shoot) }
        mutating func OptionsPath() -> Path? { return PathMakeGoState(.Options) }
        // Focus, Exposure, WhiteBalance ect.. + Pause
        mutating func HelpPath() -> Path? { return PathMakeGoState(.Help) }
        
        
        mutating func proceed(layouts: Layout...) {
            for layout in layouts {
                func mutateFor(component: Component) -> ((Path?)->())? {
                    if layout.contains(component) {
                        return { if let value = $0 { self = value } }
                    }
                    return nil
                }
                
                mutateFor(.Init)? (InitPath())
                
                mutateFor(.Pause)? (PausePath())
                mutateFor(.Continue)? (ContinuePath())
                
                mutateFor(.Help)? (HelpPath())
                mutateFor(.Options)? (OptionsPath())
                mutateFor(.Shoot)? (ShootPath())
                
                mutateFor(.Error)? (ErrorPath())
                
                mutateFor(.AspectRatio)? (AspectRatioPath())
                mutateFor(.Zoom)? (ZoomPath())
                mutateFor(.WhiteBalance)? (WhiteBalancePath())
                mutateFor(.Exposure)? (ExposurePath())
                mutateFor(.Focus)? (FocusPath())
                
            }
            
        }
        
    }
}
