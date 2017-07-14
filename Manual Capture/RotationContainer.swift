//
//  UIRotationContainer.swift
//  Capture
//
//  Created by Jean Flaherty on 2/4/16.
//  Copyright © 2016 mobileuse. All rights reserved.
//

import UIKit

/// allow constraints to work in rotated enviroment
class RotationContainer: UIView {
    var inbetweenView: UIView
    var view: UIView
    override var frame: CGRect {
        didSet{
            // temporarily reset transform and resize frame
            tempSetDo(&inbetweenView.transform, to: CGAffineTransformIdentity) {
                self.inbetweenView.frame = self.bounds
                self.view.frame = self.inbetweenView.bounds
            }
        }
    }
    
    var rotation: CGFloat {
        set {
            rotate(newValue)
        }
        get {
            return CGFloat(inbetweenView.layer.valueForKeyPath("transform.rotation.z")?.floatValue ?? 0)
        }
    }
    
    func rotate(angle: CGFloat) {
        
        inbetweenView.layer.setValue(angle, forKeyPath: "transform.rotation.z")
        inbetweenView.frame = bounds
        view.frame = convertRect(bounds, toView: inbetweenView)

    }
    
    override init(frame: CGRect){
        // frame with zero origin
        view = UIView(frame: CGRect(origin: CGPointZero, size: frame.size))
        inbetweenView = UIView(frame: CGRect(origin: CGPointZero, size: frame.size))
        super.init(frame: frame)
        addSubview(inbetweenView)
        inbetweenView.addSubview(view)
    }
    
    init(view:UIView){
        self.view = view
        inbetweenView = UIView(frame: CGRect(origin: CGPointZero, size: view.frame.size))
        super.init(frame: view.frame)
        addSubview(inbetweenView)
        inbetweenView.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
