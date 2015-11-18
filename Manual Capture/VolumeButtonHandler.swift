//
//  VolumeButtonHandler.swift
//  Capture
//
//  Created by Jean Flaherty on 11/17/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import AVFoundation
import MediaPlayer

class VolumeButtonHandler: NSObject {
    
    private let sessionVolumeKeyPath = "outputVolume"
    
    private var sessionContext = KVOContext()
    
    private let maxVolume: Float = 0.99999, minVolume: Float = 0.00001
    
    private var appIsActive: Bool
    
    private var session = AVAudioSession.sharedInstance()
    
    private var volumeView: MPVolumeView!
    
    private var volumeSlider: UISlider?
    
    private var initialVolume: Float!
    
    var action: (()->Void)?
    
    override init() {
        
        appIsActive = true
        
        super.init()
        
        do {
            
            try setUpSession()
            
        } catch {
            
            // Error
            
        }
        
    }
    
    convenience init(action:() -> Void) {
        self.init()
        self.action = action
    }
    
    func setUpSession() throws {
        
        try session.setCategory(AVAudioSessionCategoryAmbient)
        
        try session.setActive(true)
        
        // Observe outputVolume
        session.addObserver(self,
            forKeyPath: sessionVolumeKeyPath,
            options: [.Old, .New],
            context: &sessionContext)
        
        // Audio session is interrupted when you send the app to the background,
        // and needs to be set to active again when it goes to app goes back to the foreground
        NSNotificationCenter.defaultCenter().addObserver(self,
            selector: "audioSessionInterrupted:",
            name: AVAudioSessionInterruptionNotification,
            object: nil)
        
    }
    
    func audioSessionInterrupted(notification: NSNotification) {
        
        guard let info = notification.userInfo,
            typeObject = info[AVAudioSessionInterruptionTypeKey],
            typeInt = typeObject.integerValue,
            interuptionType = AVAudioSessionInterruptionType(rawValue: UInt(typeInt)) else {
            print("Audio Session Interruption Type Unknown.")
            return
        }
        
        
        switch interuptionType {
        case .Began:
            print("Audio Session Interruption Began.")
        case .Ended:
            do {
                try session.setActive(true)
            } catch {
                print(error)
            }
            
        }
    }
    
    func disableVolumeHUD() {
        let max = CGFloat( MAXFLOAT )
        let rect = CGRectMake(max, max, 0, 0)
        volumeView = MPVolumeView(frame: rect)
        
        let window = UIApplication.sharedApplication().windows.first
        window?.addSubview(volumeView)
        
        volumeView.subviews.forEach { view in
            let classString = NSStringFromClass(view.dynamicType)
                .componentsSeparatedByString(".")
                .last
            if classString == "MPVolumeSlider" {
                volumeSlider = view as? UISlider
            }
        }
    }
    
    func setInitialVolume() {
        initialVolume = session.outputVolume
        if initialVolume > maxVolume {
            initialVolume = maxVolume
            setSystemVolume(initialVolume)
        } else if initialVolume < minVolume {
            initialVolume = minVolume
            setSystemVolume(initialVolume)
        }
    }
    
    func applicationDidChangeActive(notification: NSNotification) {
        appIsActive = (notification.name == UIApplicationDidBecomeActiveNotification)
    }
    
    // MARK: KVO
    
    private typealias KVOContext = UInt8
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if context == &sessionContext && keyPath == sessionVolumeKeyPath {
            guard appIsActive else {
                // Probably control center
                return
            }
            
            guard let newVolume = change?[NSKeyValueChangeNewKey]?.floatValue
                //, oldVolume = change?[NSKeyValueChangeOldKey]?.floatValue
                else { return }
            
            guard newVolume != initialVolume else {
                // Probably resetting volume
                return
            }
            
            action?()
            setSystemVolume(initialVolume)
            
        }
    }
    
    // MARK: System Volume
    
    func setSystemVolume(volume:Float) {
//        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
//        musicPlayer.volume = volume
        volumeSlider?.setValue(volume, animated: true)
        volumeSlider?.sendActionsForControlEvents(.TouchUpInside)
        
    }
}
