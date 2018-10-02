//
//  CaptureViewController2.swift
//  Capture
//
//  Created by Jean Flaherty on 11/22/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class CaptureViewController2: UIViewController, CaptureView2Delegate, MWPhotoBrowserDelegate, UINavigationControllerDelegate {
    
//    typealias Constraints = CaptureConstraint
    typealias PreviewView = CapturePreviewView
    
    let steadyView = RotationContainer()
    // Continue
    var continueView = UIView()
    var controlViewContainer = RotationContainer()
    var controlView: CaptureView2!
    var captureButton = UIButton.shutterButton()
    var captureButtonContainer: RotationContainer!
    let galleryButton = UIButton.galleryButton()
    var galleryButtonContainer: RotationContainer!
    var previewView: PreviewView!
    var sessionController: CSController2!
    
    let menuControl = OptionControl<Layout>(items: [
        ("Focus", .focus),
        ("Zoom", .zoom),
        ("Exposure", .exposure),
        ("WB", .whiteBalance),
        ("Aspect Ratio", .aspectRatio) ]
    )
    
    private var currentControlPanel: ControlPanel?
    
    
    
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
            self.previewView = self.sessionController.previewView
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
        super.viewDidLoad()
        let toolbar = UIView()
        let capturebar = UIView()
        captureButtonContainer = RotationContainer(view: captureButton)
        galleryButtonContainer = RotationContainer(view: galleryButton)
        sessionController = CSController2()
        captureButton.addTarget(sessionController, action: #selector(sessionController.captureStillPhoto), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(self.showPhotoBrowser),
                                for: .touchUpInside)
        galleryButton.alpha = 0.0
        previewView = sessionController.previewView
        controlView = CaptureView2(frame: controlViewContainer.view.bounds, sessionController: sessionController)
        controlView.delegate = self
        
        view.layout(style: Style.FillSuperview, views: steadyView)
        steadyView.view.layout(style: Style.FillSuperview, views: previewView)
        steadyView.view.layout(style: Style.Capturebar, views: capturebar)
        steadyView.view.layout(style: Style.Toolbar, views: toolbar)
        steadyView.view.layout(style: Style.FillSuperview, views: controlViewContainer)
        
        controlViewContainer.view.layout(style: Style.FillSuperview, views: controlView)
        view.backgroundColor = UIColor.black
        
        steadyView.view.layout(style: Style.CaptureButtonContainer, views: captureButtonContainer)
        steadyView.view.layout(style: Style.GalleryButtonContainer, views: galleryButtonContainer, captureButtonContainer)
//
//        layout = .initial
//        layout.proceed(layouts: .shoot, .whiteBalance, .focus, .whiteBalance)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        let selector = #selector(self.deviceOrientationChanged)
        NotificationCenter.default.addObserver(self, selector: selector,
                                               name:UIDevice.orientationDidChangeNotification , object: nil)
        updateRotation()
//        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
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
                    self.galleryButtonContainer.rotation = CGFloat(self.orientation.rotation)
                    
                    let aspectRatioOrientationAgnostic = self.sessionController.aspectRatioMode == .fullscreen || self.sessionController.aspectRatioMode == .sensor
                    let heightAndWidthSwapped = self.orientation == .portrait || oldOrientation == .portrait
                    if heightAndWidthSwapped && !aspectRatioOrientationAgnostic {
                        self.previewView.aspectRatio = 1 / self.previewView.aspectRatio
                    }
                },
                fade: {
//                    var rect = self.steadyView.view.bounds
                    
//                    if self.orientation == .portrait {
//                        rect.size.width -= 40
//                    }
//                    self.controlViewContainer.frame = rect
                    self.controlViewContainer.rotation = CGFloat(self.orientation.rotation)
                    self.galleryButtonContainer.rotation = CGFloat(self.orientation.rotation)
                }
            )
            UIView.animate(withDuration: duration) { CATransaction.performBlock(duration: duration) {
                    animations.normal()
            }}
            UIView.animate(withDuration: duration,
                           animations: { [unowned self] in self.controlViewContainer.alpha = 0.0 },
                           completion: { [unowned self] _ in
                CATransaction.disableActions {
                    animations.fade()
                    self.controlView.updateConstraints(forKeys:
                        [
                            .slider(.top),
                            .slider(.bottom),
                            .slider(.left),
                            .slider(.right),
                            .menuControl,
                            .controlPanel
                        ]
                    )
                }
                UIView.animate(withDuration: duration) { [unowned self] in self.controlViewContainer.alpha = 1.0 }
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
    
    func flashPreview() {
        CATransaction.disableActions {
            self.previewView.previewLayer.opacity = 0.0
        }
        CATransaction.performBlock(duration: 0.4) {
            self.previewView.previewLayer.opacity = 1.0
        }
    }
    
    
    func shouldShowGalleryButton(show: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState, animations:  {
            self.galleryButton.alpha = (show) ? 1.0 : 0.0
        }, completion: nil)
    }
    
    func shouldShowCaptureButton(show: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState, animations:  {
            self.captureButton.alpha = (show) ? 1.0 : 0.0
        }, completion: nil)
    }

    @objc func showPhotoBrowser() {
        loadCameraRollAssets()
        guard let browser = MWPhotoBrowser(delegate: self) else {
            fatalError("couldn't load MWPhotoBrowser")
        }
        browser.startOnGrid = true
        browser.enableGrid = true
        browser.enableSwipeToDismiss = true
        
        let nav = UINavigationController(rootViewController: browser)
        present(nav, animated: true, completion: nil)
    }
    
    var cameraRollAssets: PHFetchResult<PHAsset>!
    
    func loadCameraRollAssets() {
        let result = PHAssetCollection.fetchAssetCollections(
            with: PHAssetCollectionType.smartAlbum,
            subtype: PHAssetCollectionSubtype.smartAlbumUserLibrary,
            options: nil
        )
        guard let cameraRoll = result.firstObject else { print(result); return }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        cameraRollAssets = PHAsset.fetchAssets(in: cameraRoll, options: fetchOptions)
    }
    
    func numberOfPhotos(in photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(cameraRollAssets.count)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, photoAt index: UInt) -> MWPhotoProtocol! {
        let asset = cameraRollAssets.object(at: Int(index))
        //        let id = asset.localIdentifier[0..<36]
        //        let url = NSURL(string: "assets-library://asset/asset.JPG?id=\(id)&ext=JPG")
        //        print(url)
        //        return MWPhoto(URL: url)
        var size = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
        let length = max(size.width, size.height)
        let maxLength: CGFloat = 1920
        let scaleDown = maxLength / max(length, maxLength)
        size.width *= scaleDown
        size.height *= scaleDown
        return MWPhoto(asset: asset, targetSize: size)
    }
    
    func photoBrowser(_ photoBrowser: MWPhotoBrowser!, thumbPhotoAt index: UInt) -> MWPhotoProtocol! {
        let asset = cameraRollAssets.object(at: Int(index))
        let size = CGSize(width: 400, height: 400)
        return MWPhoto(asset: asset, targetSize: size)
    }
    
    func photoBrowserDidFinishModalPresentation(_ photoBrowser: MWPhotoBrowser!) {
        // rotate back
        delay(0.1) { [unowned self] in
            self.updateRotation()
        }
        self.dismiss(animated: true) {
        }
    }
    
//    override func transition(from fromViewController: UIViewController, to toViewController: UIViewController, duration: TimeInterval, options: UIView.AnimationOptions = [], animations: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
//        //
//    }
    
    private func updateRotation() {
        var newAngle: CGFloat = 0
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight:
            newAngle = 0
//            orientation = .landscapeRight
        case .portrait:
            newAngle = CGFloat(Double.pi/2)
//            orientation = .portrait
        case .landscapeLeft:
            newAngle = CGFloat(Double.pi)
//            orientation = .landscapeLeft
        default: break// should not happen
        }
        self.steadyView.rotation = newAngle
        // update orientation
    }

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
