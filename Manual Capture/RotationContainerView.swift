//
//  UIRotationContainer.swift
//  Capture
//
//  Created by Jean Flaherty on 2/4/16.
//  Copyright © 2016 mobileuse. All rights reserved.
//

import UIKit

/// allow constraints to work in rotated enviroment
class RotationContainerView: UIView {
    var inbetweenView: UIView
    var view: UIView
    override var frame: CGRect {
        didSet{
            // temporarily reset transform and resize frame
            tempSetDo(set: &inbetweenView.transform, to: CGAffineTransform.identity) {
                self.inbetweenView.frame = self.bounds
                self.view.frame = self.inbetweenView.bounds
            }
        }
    }
    
    var rotation: CGFloat {
        set {
            rotate(angle: newValue)
        }
        get {
            return CGFloat((inbetweenView.layer.value(forKeyPath: "transform.rotation.z") as AnyObject).floatValue ?? 0)
        }
    }
    
    func rotate(angle: CGFloat) {
        
        inbetweenView.layer.setValue(angle, forKeyPath: "transform.rotation.z")
        inbetweenView.frame = bounds
        view.frame = convert(bounds, to: inbetweenView)

    }
    
    override init(frame: CGRect){
        // frame with zero origin
        view = UIView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        inbetweenView = UIView(frame: CGRect(origin: CGPoint.zero, size: frame.size))
        super.init(frame: frame)
        addSubview(inbetweenView)
        inbetweenView.addSubview(view)
    }
    
    init(view:UIView){
        self.view = view
        inbetweenView = UIView(frame: CGRect(origin: CGPoint.zero, size: view.frame.size))
        super.init(frame: view.frame)
        addSubview(inbetweenView)
        inbetweenView.addSubview(view)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
