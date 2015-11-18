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
        controlView = CaptureView(frame: view.frame)
        controlView.delegate = self
        
        view.backgroundColor = UIColor.blackColor()
        view.addSubview(controlView)
    }
    
    override func viewDidLayoutSubviews() {
        controlView.frame = view.frame
    }
    
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.Landscape
//    }
    
    func showPhotoBrowser() {
        loadCameraRollAssets()
        let browser = MWPhotoBrowser(delegate: self)
        browser.startOnGrid = true
        browser.enableGrid = true
        browser.enableSwipeToDismiss = true
        
        let nav = UINavigationController(rootViewController: browser)
        presentViewController(nav, animated: true, completion: nil)
    }
    
    var cameraRollAssets: PHFetchResult!
    
    func loadCameraRollAssets() {
        let result = PHAssetCollection.fetchAssetCollectionsWithType(
            PHAssetCollectionType.SmartAlbum,
            subtype: PHAssetCollectionSubtype.SmartAlbumUserLibrary,
            options: nil
        )
        guard let cameraRoll = result.firstObject as? PHAssetCollection else { print(result); return }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        cameraRollAssets =  PHAsset.fetchAssetsInAssetCollection(cameraRoll, options: fetchOptions)
    }
    
    func numberOfPhotosInPhotoBrowser(photoBrowser: MWPhotoBrowser!) -> UInt {
        return UInt(cameraRollAssets.count)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, photoAtIndex index: UInt) -> MWPhotoProtocol! {
        guard let asset = cameraRollAssets.objectAtIndex(Int(index)) as? PHAsset else { return nil }
//        let id = asset.localIdentifier[0..<36]
//        let url = NSURL(string: "assets-library://asset/asset.JPG?id=\(id)&ext=JPG")
//        print(url)
//        return MWPhoto(URL: url)
        var size = CGSizeMake(CGFloat(asset.pixelWidth), CGFloat(asset.pixelHeight))
        let length = max(size.width, size.height)
        let maxLength: CGFloat = 1920
        let scaleDown = maxLength / max(length, maxLength)
        size.width *= scaleDown
        size.height *= scaleDown
        return MWPhoto(asset: asset, targetSize: size)
    }
    
    func photoBrowser(photoBrowser: MWPhotoBrowser!, thumbPhotoAtIndex index: UInt) -> MWPhotoProtocol! {
        guard let asset = cameraRollAssets.objectAtIndex(Int(index)) as? PHAsset else { return nil }
        let size = CGSizeMake(400, 400)
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
    
    
    override func prefersStatusBarHidden() -> Bool {return true}
    
}
