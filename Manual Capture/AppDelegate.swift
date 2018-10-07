
//
//  AppDelegate.swift
//  Manual Capture
//
//  Created by Jean Flaherty on 8/6/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

let kAppName = "Capture"
let kCaptureTintColor = UIColor(red: 221/255, green: 0/255, blue: 63/255, alpha: 1.0)
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var isDemoMode = false
    var isVideoMode = false
    var isTestingNoReverse = false
    var isTestingWalkthrough = false
    var needsPagedGuide = true
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        let walkthroughNumber = UserDefaults.standard.integer(forKey: "WalkthroughNumber")
        if walkthroughNumber > 0 && !isTestingWalkthrough  {
            print("Not first launch.")
            needsPagedGuide = false
        } else {
            print("First launch, setting UserDefault.")
            UserDefaults.standard.set(1, forKey: "WalkthroughNumber")
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController: UIViewController
        
        if needsPagedGuide {
            initialViewController = storyBoard.instantiateViewController(withIdentifier: "PagedGuideViewController")
        } else {
            initialViewController = storyBoard.instantiateInitialViewController()!
        }
        
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        UIApplication.shared.ignoreSnapshotOnNextApplicationLaunch()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.landscape, .portrait]
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool {
        let properties = url.host?.components(separatedBy: "/")
        properties?.forEach { property in
            switch property {
            case "video":
                isVideoMode = true
            case "photo":
                isVideoMode = false
            case "demo": isDemoMode = true
            case "no-reverse": isTestingNoReverse = true
            case "paged-guide": needsPagedGuide = true
            default: break
            }
        }
        
        let storyBoard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewController = storyBoard.instantiateViewController(withIdentifier: "PagedGuideViewController")
        window?.rootViewController = initialViewController
        window?.makeKeyAndVisible()
        
        return true
    }

}

