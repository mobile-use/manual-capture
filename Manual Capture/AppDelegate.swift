
//
//  AppDelegate.swift
//  Manual Capture
//
//  Created by Jean Flaherty on 8/6/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

let kAppName = "Capture"
let kIsDemoMode = false
let isVideoMode = true
//private(set) var kLastVersion: Version? = nil

extension NSBundle {
    
    class var applicationVersionNumber: String {
        if let version = NSBundle.mainBundle().infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "Version Number Not Available"
    }
    
    class var applicationBuildNumber: String {
        if let build = NSBundle.mainBundle().infoDictionary?["CFBundleVersion"] as? String {
            return build
        }
        return "Build Number Not Available"
    }
    
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var needsIntro = true

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        let walkthroughNumber = NSUserDefaults.standardUserDefaults().integerForKey("WalkthroughNumber")
        if walkthroughNumber > 0  {
            print("Not first launch.")
            needsIntro = false
        }
        else {
            print("First launch, setting NSUserDefault.")
            //NSUserDefaults.standardUserDefaults().setInteger(1, forKey: "WalkthroughNumber")
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController
        
        if needsIntro {
            initialViewController = storyBoard.instantiateViewControllerWithIdentifier("PagedGuide")
        }else{
            initialViewController = storyBoard.instantiateInitialViewController()!
        }
        
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        UIApplication.sharedApplication().ignoreSnapshotOnNextApplicationLaunch()
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, supportedInterfaceOrientationsForWindow window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.Landscape, .Portrait]
    }


}

