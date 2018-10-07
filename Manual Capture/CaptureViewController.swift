//
//  CaptureViewController2.swift
//  Capture
//
//  Created by Jean Flaherty on 11/22/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class CaptureViewController: UIViewController, CaptureControlsViewDelegate, MWPhotoBrowserDelegate, UINavigationControllerDelegate {
    private let steadyView = RotationContainerView()
    private var controlViewContainer = RotationContainerView()
    private var controlView: ControlsView!
    private let captureButton = UIButton.shutterButton()
    private var captureButtonContainer: RotationContainerView!
    private let galleryButton = UIButton.galleryButton()
    private var galleryButtonContainer: RotationContainerView!
    private var previewView: PreviewView!
    private var captureSession: CaptureSession!
    private var cameraRollAssets: PHFetchResult<PHAsset>!
    
    override var prefersStatusBarHidden: Bool { return true }

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

    private var orientation: Orientation = .landscapeLeft {
        didSet(oldOrientation) {
            guard orientation != oldOrientation else { return }
            
            let duration: TimeInterval = 0.2
            // normal animations include rotation animations
            // fade animations are for rotations that cross-fade rather than continuous rotation
            let animations = (
                normal: {
                    self.captureButtonContainer.rotation = CGFloat(self.orientation.rotation)
                    self.galleryButtonContainer.rotation = CGFloat(self.orientation.rotation)
                    // if height and width are swapped and aspect ratio is locked, we need to set the
                    // aspect ratio to the inverse in order to keep the same aspect ratio relative to
                    // the current orientation.
                    let aspectRatioIsLocked = self.captureSession.aspectRatioMode == .lock
                    let heightAndWidthSwapped = self.orientation == .portrait || oldOrientation == .portrait
                    if heightAndWidthSwapped && aspectRatioIsLocked {
                        self.previewView.aspectRatio = 1 / self.previewView.aspectRatio
                    }
            },
                fade: {
                    self.controlViewContainer.rotation = CGFloat(self.orientation.rotation)
            })
            UIView.animate(withDuration: duration) { CATransaction.performBlock(duration: duration) {
                animations.normal()
            }}
            UIView.animate(withDuration: duration,
                           animations: { [unowned self] in self.controlViewContainer.alpha = 0.0 },
                           completion: { [unowned self] _ in
                CATransaction.disableActions {
                    animations.fade()
                    // controlView will resize so update constraints
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        captureSession = CaptureSession()
        
        // UI initialization
        captureButtonContainer = RotationContainerView(view: captureButton)
        galleryButtonContainer = RotationContainerView(view: galleryButton)
        captureButton.addTarget(captureSession, action: #selector(captureSession.captureStillPhoto), for: .touchUpInside)
        galleryButton.addTarget(self, action: #selector(self.showPhotoBrowser), for: .touchUpInside)
        galleryButton.alpha = 0.0
        previewView = captureSession.previewView
        controlView = ControlsView(frame: controlViewContainer.view.bounds, sessionController: captureSession)
        controlView.delegate = self
        view.backgroundColor = UIColor.black
        
        // Layout, style and constraints
        view.layout(style: .fillSuperview, views: steadyView)
        steadyView.view.layout(style: .fillSuperview, views: previewView)
        steadyView.view.layout(style: .fillSuperview, views: controlViewContainer)
        controlViewContainer.view.layout(style: Style.fillSuperview, views: controlView)
        steadyView.view.layout(style: .captureButtonContainer, views: captureButtonContainer)
        steadyView.view.layout(style: .galleryButtonContainer, views: galleryButtonContainer, captureButtonContainer)
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        let selector = #selector(self.deviceOrientationChanged)
        NotificationCenter.default.addObserver(self, selector: selector,
                                               name:UIDevice.orientationDidChangeNotification , object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool){
        super.viewWillAppear(animated)
        
        // view layout gets messed up when user enters photo browser, changes orientation, then dismisses
        // 0.0 delay does the trick for now
        // Todo: Find a better solution. Maybe a different viewcontroller method will have better timing.
        delay(0.0) { [unowned self] in
            self.updateRotation()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let deltaTransform = coordinator.targetTransform
        let newAngle = self.steadyView.rotation - atan2(deltaTransform.b, deltaTransform.a)
        
        coordinator.animate(alongsideTransition: { coordinator in
            // counter clock-wise rotation requires + 0.0001
            self.steadyView.rotation = newAngle + 0.0001
        }, completion: { coordinator in
            // get rid of 0.0001
            self.steadyView.rotation = newAngle
        })
    }
    
    deinit {
        UIDevice.current.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: -- Orientation related --
    
    @objc func deviceOrientationChanged() {
        switch UIDevice.current.orientation {
        case .landscapeRight: orientation = .landscapeRight
        case .portrait: orientation = .portrait
        case .landscapeLeft: orientation = .landscapeLeft
        default: return
        }
    }
    
    // Should be used when steadyView is or might be out of sync with current orientation
    private func updateRotation() {
        var newAngle: CGFloat = 0
        switch UIApplication.shared.statusBarOrientation {
        case .landscapeRight: newAngle = 0
        case .portrait: newAngle = CGFloat(Double.pi/2)
        case .landscapeLeft: newAngle = CGFloat(Double.pi)
        default: newAngle = 0
        }
        self.steadyView.rotation = newAngle
    }
    
    // MARK: -- Actions --
    
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
    
    // MARK: -- Delegates --
    
    // ControlView Delegate Methods
    
    // Used to signify camera shutter trigger by animating previewLayer
    func flashPreview() {
        CATransaction.disableActions {
            self.previewView.previewLayer.opacity = 0.0
        }
        CATransaction.performBlock(duration: 0.4) {
            self.previewView.previewLayer.opacity = 1.0
        }
    }
    
    // For showing/hiding the gallery button
    func shouldShowGalleryButton(show: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState, animations:  {
            self.galleryButton.alpha = (show) ? 1.0 : 0.0
        }, completion: nil)
    }
    
    // For showing/hiding the capture button
    func shouldShowCaptureButton(show: Bool) {
        UIView.animate(withDuration: 0.2, delay: 0, options: UIView.AnimationOptions.beginFromCurrentState, animations:  {
            self.captureButton.alpha = (show) ? 1.0 : 0.0
        }, completion: nil)
    }
    
    // MWPhotoBrowser Delegate Methods
    
    // Loading the cameral roll images for the photo browser
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
}
