//
//  PagedGuide.swift
//  Capture
//
//  Created by Jean Flaherty on 11/28/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class PagedGuide: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    typealias Content = (title: String, description: String, videoName: String)
    typealias Page = PagedGuideContent
    
    @IBOutlet var pageContainer: UIView!
    @IBOutlet var closeButton: UIButton!
    
    var pageViewController: UIPageViewController!
    let contents: [Content] = [
        (title: "Quick Adjustments", description: "Get accustomed to using these quick gestures and you will be snaping quality shots with ease.", videoName: "FourCornerUI"),
        (title: "Warp Speed", description: "Ramp up the traking speed by sliding away from the slider.", videoName: "WarpSpeedDemo"),
        (title: "Advanced Controls", description: "Tap the screen to hide or show advanced controls.", videoName: "AdvancedControlsDemo")
//        ,
//        (title: "I Can't See Yet :(", description: "Please allow \(kAppName) to use the camera.", videoName: "TestFoot4")
    ]
    
    override func viewDidLoad() {
        pageViewController = storyboard?.instantiateViewControllerWithIdentifier("PageController") as! UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.frame = pageContainer.bounds
        addChildViewController(pageViewController)
        pageContainer.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
        
        let firstPage = viewControllerAtIndex(0)!
        pageViewController.setViewControllers([firstPage], direction: .Forward, animated: true, completion: nil)
        
        delay(2.4) {
            self.allowPortrait = true
            UIViewController.attemptRotationToDeviceOrientation()
        }
        
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        guard let referedPage = viewController as? Page else { return nil }
        return viewControllerAtIndex(referedPage.index+1)
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        guard let referedPage = viewController as? Page else { return nil }
        return viewControllerAtIndex(referedPage.index-1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contents.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [UIViewController]) {
        guard let transitionPage = pendingViewControllers.first as? Page else { return }
        if transitionPage.index + 1 == contents.endIndex {
            closeButton.enabled = true
        }
    }
    
    func viewControllerAtIndex(index:Int) -> UIViewController? {
        guard contents.indices ~= index else { return nil }
        
        let page = storyboard?.instantiateViewControllerWithIdentifier("PagedGuideContent") as? Page
        page?.content = contents[index]
        page?.index = index
        return page
    }
    
    @IBAction func startApp(){
        let capture = storyboard?.instantiateViewControllerWithIdentifier("Capture")
        presentViewController(capture!, animated: true, completion: nil)
    }
    
    var allowPortrait = false
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return (allowPortrait) ? [.Landscape, .Portrait] : UIInterfaceOrientationMask.Landscape
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
}
