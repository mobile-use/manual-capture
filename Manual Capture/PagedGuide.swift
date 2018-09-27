//
//  PagedGuide.swift
//  Capture
//
//  Created by Jean Flaherty on 11/28/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class PagedGuide: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    var allowPortrait = false
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return (allowPortrait) ? [.landscape, .portrait] : .landscape
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    typealias Content = (title: String, description: String, videoName: String)
    typealias Page = PagedGuideContent
    
    @IBOutlet var pageContainer: UIView!
    @IBOutlet var closeButton: UIButton!
    
    var pageViewController: UIPageViewController!
    let contents: [Content] = [
        (title: "Quick Adjustments",
         description: "Get accustomed to using these quick gestures and you will be snaping quality shots with ease.",
         videoName: "FourCornerUI"),
        (title: "Warp Speed",
         description: "Ramp up the traking speed by sliding away from the slider.",
         videoName: "WarpSpeedDemo"),
        (title: "Advanced Controls",
         description: "Tap the screen to hide or show advanced controls.",
         videoName: "AdvancedControlsDemo")
    ]
    
    
    override func viewDidLoad() {
        pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageController") as? UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.frame = pageContainer.bounds
        addChild(pageViewController)
        pageContainer.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        guard let firstPage = createPageViewController(atIndex: 0) else { return }
        pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
        
        delay(2.4) {
            self.allowPortrait = true
            UIViewController.attemptRotationToDeviceOrientation()
        }
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let referedPage = viewController as? Page else { return nil }
        return createPageViewController(atIndex: referedPage.index+1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let referedPage = viewController as? Page else { return nil }
        return createPageViewController(atIndex: referedPage.index-1)
    }
    
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return contents.count
    }
    
    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let transitionPage = pendingViewControllers.first as? Page else { return }
        if transitionPage.index + 1 == contents.endIndex {
            closeButton.isEnabled = true
        }
    }
    
    func createPageViewController(atIndex index: Int) -> UIViewController? {
        guard contents.indices ~= index else { return nil }
        
        let page = storyboard?.instantiateViewController(withIdentifier: "PagedGuideContent") as! Page
        page.content = contents[index]
        page.index = index
        return page
    }
    
    @IBAction func startApp(){
        let capture = storyboard?.instantiateViewController(withIdentifier: "Capture")
        present(capture!, animated: true, completion: nil)
    }
}
