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
    private let outputVolumeObserver: NSKeyValueObservation
    
    private let maxVolume: Float = 0.99999, minVolume: Float = 0.00001
    
    private var appIsActive: Bool
    
    @objc dynamic private var session = AVAudioSession.sharedInstance()
    
    private var volumeView: MPVolumeView!
    
    private var volumeSlider: UISlider?
    
    private var initialVolume: Float!
    
    var action: (()->Void)?
    
    override init() {
        
        appIsActive = true
        
        super.init()
        
        do {
            if #available(iOS 10.0, *) {
                try session.setCategory(AVAudioSession.Category.ambient, mode: .default)
            } else {
                session.perform(NSSelectorFromString("setCategory:error:"), with: AVAudioSession.Category.playback)
            }
            
            try session.setActive(true)
            
            
        } catch {
            
            // Error
            
        }
        // Observe outputVolume
        outputVolumeObserver = session.observe(\AVAudioSession.outputVolume, options: [.new]) {
            [unowned self] session, change in
            guard self.appIsActive else { return /* Probably control center */ }
            guard let newVolume = change.newValue else { fatalError("missing new value") }
            guard newVolume != self.initialVolume else { return /* Resetting volume */ }
            self.action?()
            self.setSystemVolume(volume: self.initialVolume)
        }
        
        // Audio session is interrupted when you send the app to the background,
        // and needs to be set to active again when it goes to app goes back to the foreground
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(VolumeButtonHandler.audioSessionInterrupted),
                                               name: AVAudioSession.interruptionNotification,
                                               object: nil)
        
    }
    
    convenience init(action:@escaping () -> Void) {
        self.init()
        self.action = action
    }
    
    
    @objc func audioSessionInterrupted(notification: NSNotification) {
        
        guard let info = notification.userInfo,
            let typeObject = info[AVAudioSessionInterruptionTypeKey],
            let typeInt = typeObject as? Int,
            let interuptionType = AVAudioSession.InterruptionType(rawValue: UInt(typeInt)) else {
            print("Audio Session Interruption Type Unknown.")
            return
        }
        
        switch interuptionType {
        case .began:
            print("Audio Session Interruption Began.")
        case .ended:
            do {
                try session.setActive(true)
            } catch {
                print(error)
            }
        }
    }
    
    func disableVolumeHUD() {
        let max = CGFloat( MAXFLOAT )
        let rect = CGRect(x: max, y: max, width: 0, height: 0)
        volumeView = MPVolumeView(frame: rect)
        
        let window = UIApplication.shared.windows.first
        window?.addSubview(volumeView)
        
        volumeView.subviews.forEach { view in
            let classString = NSStringFromClass(type(of: view))
                .components(separatedBy: ".")
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
            setSystemVolume(volume: initialVolume)
        } else if initialVolume < minVolume {
            initialVolume = minVolume
            setSystemVolume(volume: initialVolume)
        }
    }
    
    func applicationDidChangeActive(notification: NSNotification) {
        appIsActive = (notification.name == UIApplication.didBecomeActiveNotification)
    }
    
    // MARK: System Volume
    
    func setSystemVolume(volume:Float) {
//        let musicPlayer = MPMusicPlayerController.applicationMusicPlayer()
//        musicPlayer.volume = volume
        volumeSlider?.setValue(volume, animated: true)
        volumeSlider?.sendActions(for: .touchUpInside)
        
    }
}
