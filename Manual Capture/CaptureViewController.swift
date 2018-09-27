//
//  CaptureViewController.swift
//  Capture
//
//  Created by Jean on 9/7/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit
import AVFoundation
import AssetsLibrary

let kCaptureTintColor = UIColor(red: 221/255, green: 0/255, blue: 63/255, alpha: 1.0)

class CaptureViewController: UIViewController, MWPhotoBrowserDelegate, CaptureViewDelegate {
    
    var controlView: CaptureView!
    
    override func viewDidLoad() {
        controlView = CaptureView(frame: view.bounds)
        controlView.delegate = self
        
        view.backgroundColor = UIColor.black
        view.addSubview(controlView)
        
        delay(2.4) {
            self.allowPortrait = true
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        print(view.frame, view.bounds)
//        print(controlView.frame, controlView.bounds)
//        print(controlView.sessionController.previewLayer.frame, controlView.sessionController.previewLayer.bounds)
        
        controlView.frame = view.superview!.convert(view.superview!.bounds, to: controlView)
        controlView.frame.origin = CGPoint.zero
        controlView.sessionController.previewLayer.frame.size = controlView.bounds.size
        controlView.sessionController.previewLayer.position = CGPoint(x: controlView.bounds.midX, y: controlView.bounds.midY)
        previousOrient = UIApplication.shared.statusBarOrientation
        UIView.animate(withDuration: 0.2){
             self.controlView.alpha = 1.0
        }
        //controlView.sessionController.aspectRatio = controlView.sessionController.aspectRatio
        
//        print(view.frame, view.bounds)
//        print(controlView.frame, controlView.bounds)
//        print(controlView.sessionController.previewLayer.frame, controlView.sessionController.previewLayer.bounds)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        controlView.sessionController.volumeButtonHandler?.active = true
        UIView.animate(withDuration: 0){
            self.controlView.updateConstraints(
                forKeys: [
                    .Slider(.Top),
                    .Slider(.Bottom),
                    .Slider(.Left),
                    .Slider(.Right),
                    .ShutterButton,
                    .MenuControl,
                    .GalleryButton,
                    .UndoButton,
                    .ControlPanel
                ]
            )
        }
        controlView.sessionController.updateAspectRatio()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        controlView.sessionController.volumeButtonHandler?.active = false
    }
    
    
    var allowPortrait = false
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return (allowPortrait) ? [.landscape, .portrait] : [.landscape, .portrait]//UIInterfaceOrientationMask.Landscape
    }
    
    func showPhotoBrowser() {
        loadCameraRollAssets()
        guard let browser = MWPhotoBrowser(delegate: self) else {
            fatalError("couldn't load MWPhotoBrowser")
            return
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
    
//    - (void)showSquareImageForAsset:(PHAsset *)asset
//    {
//    NSInteger retinaScale = [UIScreen mainScreen].scale;
//    CGSize retinaSquare = CGSizeMake(100*retinaScale, 100*retinaScale);
//    
//    PHImageRequestOptions *cropToSquare = [[PHImageRequestOptions alloc] init];
//    cropToSquare.resizeMode = PHImageRequestOptionsResizeModeExact;
//    
//    CGFloat cropSideLength = MIN(asset.pixelWidth, asset.pixelHeight);
//    CGRect square = CGRectMake(0, 0, cropSideLength, cropSideLength);
//    CGRect cropRect = CGRectApplyAffineTransform(square,
//    CGAffineTransformMakeScale(1.0 / asset.pixelWidth,
//    1.0 / asset.pixelHeight));
//    
//    cropToSquare.normalizedCropRect = cropRect;
//    
//    [[PHImageManager defaultManager]
//    requestImageForAsset:(PHAsset *)asset
//    targetSize:retinaSquare
//    contentMode:PHImageContentModeAspectFit
//    options:cropToSquare
//    resultHandler:^(UIImage *result, NSDictionary *info) {
//    self.imageView.image = result;
//    }];
//    }
    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        let cView = coordinator.containerView()
//        
//        let oldAPoint = cView.layer.anchorPoint
//        let aCoord = cView.convertPoint(controlView.shutterButton.center, fromView: controlView)
//        let aPoint = CGPointMake(aCoord.x / cView.frame.width, aCoord.y / cView.frame.height)
//        
//        cView.layer.anchorPoint = aPoint
//        
//        let oldCenter = cView.center
//        
//        cView.center = CGPointMake( +aCoord.x, +aCoord.y)
//        
//       let dur = coordinator.transitionDuration()
//
//        UIView.animateWithDuration(dur*0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { cView.alpha = 0.3 }) { (_) in
//            
//            let orient = UIApplication.sharedApplication().statusBarOrientation
//            self.controlView.sessionController.previewLayer.connection.videoOrientation = AVCaptureVideoOrientation(ui:orient)
//            
//            UIView.animateWithDuration(dur*0.3, delay: 0, options: UIViewAnimationOptions.CurveEaseOut, animations: { cView.alpha = 1.0 }) { (_) in
//                UIView.animateWithDuration(dur*0.4, delay: 0, options: UIViewAnimationOptions.CurveEaseInOut, animations: { cView.center = CGPointMake( +aCoord.x, +aCoord.y) }) { (_) in
//                    cView.layer.anchorPoint = oldAPoint
//                    cView.center = oldCenter
//                }
//            }
//        }
//        
//        
//        
//        coordinator.animateAlongsideTransition({(_) in
//            cView.center = oldCenter // CGPointMake( oldCenter.x - aCoord.x / 2, oldCenter.y - aCoord.y / 2)
//            }, completion: { (_) in
//                
////                UIView.animateWithDuration(dur/2, delay: 0, options: UIViewAnimationOptions.CurveEaseIn, animations: { CGPointMake( +aCoord.x, +aCoord.y) }) { (_) in
////                    cView.layer.anchorPoint = oldAPoint
////                    cView.center = oldCenter
////                }
//        })
//        
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }

    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        controlView.backgroundColor = UIColor.clearColor()
//        let oldSuperlayer = controlView.sessionController.previewLayer.superlayer
//        let pLayer = controlView.sessionController.previewLayer
//        pLayer.removeFromSuperlayer()
//        pLayer.zPosition = -100
//        view.layer.addSublayer(pLayer)
//        
//        let dur = coordinator.transitionDuration()
//        
//        let deltaTransform = coordinator.targetTransform()
//        let deltaAngle = atan2(deltaTransform.b, deltaTransform.a)
//        
//        var currentRotation = CGFloat( view.layer.valueForKeyPath("transform.rotation.z")?.floatValue ?? 0 )
//        let oldRotation = currentRotation
//        
//        currentRotation += -1 * deltaAngle + 0.0001
//        
//        UIView.animateWithDuration(0.3, delay: 0, options: UIViewAnimationOptions.CurveLinear, animations: { self.controlView.alpha = 0.0 }) { (_) in
//            
//            self.controlView.layer.setValue(deltaAngle, forKeyPath: "transform.rotation.z")
//            
//            UIView.animateWithDuration(0.3, delay: dur*0.02, options: UIViewAnimationOptions.CurveLinear, animations: { self.controlView.alpha = 1.0 }) { (_) in
//            }
//        }
//        
//        
//        
//        coordinator.animateAlongsideTransition({(_) in
//            self.view.layer.setValue(currentRotation, forKeyPath: "transform.rotation.z")
//            }, completion: { (_) in
//                self.controlView.layer.setValue(oldRotation, forKeyPath: "transform.rotation.z")
//                self.view.layer.setValue(oldRotation, forKeyPath: "transform.rotation.z")
//                
//                let orient = UIApplication.sharedApplication().statusBarOrientation
//                self.controlView.sessionController.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(ui:orient)
//                
//                pLayer.removeFromSuperlayer()
//                oldSuperlayer?.addSublayer(pLayer)
//        })
//
//        
//        
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }

    
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        controlView.backgroundColor = UIColor.clearColor()
//        let oldSuperlayer = controlView.sessionController.previewLayer.superlayer
//        let pLayer = controlView.sessionController.previewLayer
//        pLayer.removeFromSuperlayer()
//        pLayer.zPosition = -100
//        view.layer.addSublayer(pLayer)
//        
//        let dur = coordinator.transitionDuration()
//        
//        let deltaTransform = coordinator.targetTransform()
//        let deltaAngle = atan2(deltaTransform.b, deltaTransform.a)
//        
//        var currentRotation = CGFloat( view.layer.valueForKeyPath("transform.rotation.z")?.floatValue ?? 0 )
//        let oldRotation = currentRotation
//        
//        currentRotation += -1 * deltaAngle + 0.0001
//        
//        let options: UIViewAnimationOptions = [.CurveLinear, .BeginFromCurrentState]
//        UIView.animateWithDuration(0.3, delay: 0, options: options, animations: { self.controlView.alpha = 0.0 }) { (_) in
//            
//            self.controlView.layer.setValue(deltaAngle, forKeyPath: "transform.rotation.z")
//            
//            UIView.animateWithDuration(0.3, delay: dur*0.02, options: options, animations: { self.controlView.alpha = 1.0 }) { (_) in
//            }
//        }
//        
//        coordinator.animateAlongsideTransition({(_) in
//            self.view.layer.setValue(currentRotation, forKeyPath: "transform.rotation.z")
//            }, completion: { (_) in
//                self.controlView.layer.setValue(oldRotation, forKeyPath: "transform.rotation.z")
//                self.view.layer.setValue(oldRotation, forKeyPath: "transform.rotation.z")
//                
//                let orient = UIApplication.sharedApplication().statusBarOrientation
//                self.controlView.sessionController.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(ui:orient)
//                
//                pLayer.removeFromSuperlayer()
//                oldSuperlayer?.addSublayer(pLayer)
//        })
//        
//        
//        
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//    }
    
    var previousOrient: UIInterfaceOrientation? = nil
    var previousaspectRatio: CSAspectRatio? = nil
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
//        controlView.backgroundColor = UIColor.clearColor()
//        let oldSuperlayer = controlView.sessionController.previewLayer.superlayer
//        let pLayer = controlView.sessionController.previewLayer
//        pLayer.removeFromSuperlayer()
//        pLayer.zPosition = -100
//        view.layer.addSublayer(pLayer)
        
//        let dur = coordinator.transitionDuration()
        
        let oldTransform = (view: view.transform, controlView: controlView.transform)
        let deltaTransform = coordinator.targetTransform
        let invertTransform = deltaTransform.inverted()
        
        
        coordinator.animate(alongsideTransition: {(_) in
            UIView.animate(withDuration: 0){
                self.view.frame = coordinator.containerView.bounds
            }
            
            // counter rotate
            self.view.transform = self.view.transform.concatenating(invertTransform)
                .rotate(angle: 0.000001)
            // correct position
            
//            self.view.bounds.size = self.view.convertRect(coordinator.containerView().bounds, toView: self.view).size
//            
//            self.controlView.frame = self.view.bounds
            
            self.controlView.frame.offsetBy(dx: (size.width - self.view.frame.width)/2 ,
                                            dy: (size.height - self.view.frame.height)/2)
        }, completion: nil)
        
        let options: UIView.AnimationOptions = [.curveLinear, .beginFromCurrentState]
        let fadeSpeed = 0.4
        
        var oldAlphas: [Int : CGFloat] = [:]
        
        UIView.animate(withDuration: fadeSpeed/2, delay: 0, options: options, animations: {
                self.controlView.subviews.forEach { subview in
                    oldAlphas[subview.hash] = subview.alpha
                    subview.alpha = (subview == self.controlView.shutterButton) ? subview.alpha : 0.0
                }
            }) { _ in
                
                self.view.transform = oldTransform.view
                    self.controlView.frame.insetBy(dx: (self.controlView.frame.width - size.width)/2,
                                               dy: (self.controlView.frame.height - size.height)/2)
                
                    let orient = UIApplication.shared.statusBarOrientation
                
                    CATransaction.disableActions {
                    
                self.controlView.sessionController.previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation(ui:orient)
                        
                    }
                
                let currentaspectRatio = self.controlView.sessionController.aspectRatio
                
                    guard let previousOrient = self.previousOrient, orient != previousOrient else {
                    self.previousOrient = orient
                    return
                }
                self.previousOrient = orient
                
                CATransaction.disableActions {
                    self.controlView.sessionController.previewLayer.frame.size = self.controlView.bounds.size
                    self.controlView.sessionController.previewLayer.position = CGPointMake(self.controlView.bounds.midX, self.controlView.bounds.midY)
                    
                    self.controlView.sessionController.updateAspectRatio()
                    
                }
                
                self.controlView.updateConstraintsForKeys(
                    [
                        .Slider(.Top),
                        .Slider(.Bottom),
                        .Slider(.Left),
                        .Slider(.Right),
                        .ShutterButton,
                        .MenuControl,
                        .GalleryButton,
                        .UndoButton,
                        .ControlPanel
                    ]
                )
            
//            
//            let isTempAR = self.controlView.menuControl.alpha != 1 && self.controlView.layout.currentMode == .AspectRatio
//            if isTempAR {
//                self.controlView.switchToLayout(.Normal, 0)
//            }
//            
//            func teaseAspectRatio() {
//                let oldLayout = self.controlView.layout.currentMode
//                self.controlView.menuControl.selectItemWithValue(.AspectRatio)
//                self.controlView.switchToLayout(.AspectRatio, 0)
//            }
//            switch orient {
//            case .LandscapeLeft, .LandscapeRight :
//                switch previousOrient {
//                case .Portrait, .PortraitUpsideDown:
//                    if currentaspectRatio < 1.0 {
//                        teaseAspectRatio()
//                    }
//                default: break
//                }
//            case .Portrait, .PortraitUpsideDown:
//                switch previousOrient {
//                case .LandscapeLeft, .LandscapeRight:
//                    if currentaspectRatio > 1.0 {
//                        teaseAspectRatio()
//                    }
//                default: break
//                }
//            default: break
//            }
    
            UIView.animateWithDuration(fadeSpeed/2, delay: 0, options: options, animations: {
                self.controlView.subviews.forEach { subview in
                    subview.alpha = oldAlphas[subview.hash] ?? 1.0
                }
                }) { (_) in
//                
//                func teaseAspectRatio() {
//                    let oldLayout = self.controlView.layout.currentMode
//                    self.controlView.menuControl.selectItemWithValue(.AspectRatio)
//                    self.controlView.switchToLayout(.AspectRatio)
////                    delay(0.5){
////                        if self.controlView.layout.currentMode == .AspectRatio {
////                            self.controlView.switchToLayout(oldLayout)
////                        }
////                    }
//                }
//                switch orient {
//                case .LandscapeLeft, .LandscapeRight :
//                    switch previousOrient {
//                    case .Portrait, .PortraitUpsideDown:
//                        if currentaspectRatio < 1.0 {
//                            teaseAspectRatio()
////                            delay(0.1){
////                                self.controlView.sessionController.aspectRatio = self.previousaspectRatio ?? CSAspectRatioMake(16, 9)
////                            }
//                        }
//                    default: break
//                    }
//                case .Portrait, .PortraitUpsideDown:
//                    switch previousOrient {
//                    case .LandscapeLeft, .LandscapeRight:
//                        if currentaspectRatio > 1.0 {
//                            teaseAspectRatio()
////                            delay(0.1) {
////                                self.previousaspectRatio = self.controlView.sessionController.aspectRatio
////                                self.controlView.sessionController.aspectRatio = CSAspectRatioMake(3, 4)
////                            }
//                        }
//                    default: break
//                    }
//                default: break
                //}
                }
        }
        
        
        
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    }

    
    
    override func prefersStatusBarHidden() -> Bool {return true}
    
}
