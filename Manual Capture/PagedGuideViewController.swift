//
//  PagedGuide.swift
//  Capture
//
//  Created by Jean Flaherty on 11/28/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class PagedGuideViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    // Overriding UIViewController dynamic properties
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return .landscapeRight
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    @IBOutlet var pageContainer: UIView!
    @IBOutlet var closeButton: UIButton!
    
    var pageViewController: UIPageViewController!
    let contents: [PagedGuideContentModel] = [
        PagedGuideContentModel(title: "Quick Adjustments",
                               description: "Swipe along the sides of the frame for quick adjustments. Get accustomed to using these quick gestures and you will be snapping quality shots with ease.",
                               videoName: "FourCornerUI"),
        PagedGuideContentModel(title: "Warp Speed",
                               description: "Ramp up the tracking speed by sliding away from the slider.",
                               videoName: "WarpSpeedDemo"),
        PagedGuideContentModel(title: "Advanced Controls",
                               description: "Tap the screen to hide or show advanced controls.",
                               videoName: "AdvancedControlsDemo")
    ]
    
    
    override func viewDidLoad() {
        pageViewController = storyboard?.instantiateViewController(withIdentifier: "PageViewController") as? UIPageViewController
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.view.frame = pageContainer.bounds
        addChild(pageViewController)
        pageContainer.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        guard let firstPage = createPageViewController(atIndex: 0) else { return }
        pageViewController.setViewControllers([firstPage], direction: .forward, animated: true, completion: nil)
    }
    
    // MARK: Data Source Methods
    
    // UIPageViewControllerDataSource Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let referedPage = viewController as? PagedGuideContentViewController else { return nil }
        return createPageViewController(atIndex: referedPage.index+1)
    }

    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let referedPage = viewController as? PagedGuideContentViewController else { return nil }
        return createPageViewController(atIndex: referedPage.index-1)
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return contents.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    private func createPageViewController(atIndex index: Int) -> UIViewController? {
        guard contents.indices ~= index else { return nil }
        
        guard let page = storyboard?.instantiateViewController(withIdentifier: "PagedGuideContentViewController") as! PagedGuideContentViewController? else { fatalError() }
        page.content = contents[index]
        page.index = index
        return page
    }
    
    // MARK: Delegate Methods
    
    // UIPageViewControllerDelegate Methods
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        guard let transitionPage = pendingViewControllers.first as? PagedGuideContentViewController else { return }
        if transitionPage.index + 1 == contents.endIndex {
            closeButton.isEnabled = true
        }
    }
    
    // MARK: Actions
    
    // Launch CaptureViewController
    @IBAction func startApp(){
        let capture = storyboard?.instantiateViewController(withIdentifier: "CaptureViewController")
        present(capture!, animated: true, completion: nil)
    }
}
