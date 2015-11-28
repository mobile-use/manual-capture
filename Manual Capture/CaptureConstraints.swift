//
//  CaptureConstraints.swift
//  Capture
//
//  Created by Jean Flaherty on 11/22/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    convenience init(item: UIView, attribute: NSLayoutAttribute, relation: NSLayoutRelation = .Equal, toItem: UIView? = nil, attribute toAttribute: NSLayoutAttribute = .NotAnAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        self.init(item: item, attribute: attribute,
            relatedBy: relation,
            toItem: toItem, attribute: toAttribute,
            multiplier: multiplier, constant: constant)
    }
}

struct CaptureConstraint {
    private typealias Constraint = NSLayoutConstraint
    private typealias Constraints = [NSLayoutConstraint]
    
    static func captureButton(button: UIButton) -> [NSLayoutConstraint]! {
        guard let superview = button.superview else { return nil }
        let centerY = Constraint(item: button, attribute: .CenterY,
            toItem: superview, attribute: .CenterY)
        let rightMargin = Constraint(item: button, attribute: .RightMargin,
            toItem: superview, attribute: .RightMargin,
            constant: -10)
        
        return [centerY, rightMargin]
    }
    
    static func fillSuperview(view: UIView) -> [NSLayoutConstraint] {
        let horizontal = Constraint.constraintsWithVisualFormat("H:|[view]|",
            options: [.AlignAllCenterX, .AlignAllCenterY],
            metrics: nil, views: ["view" : view])
        let verticle = Constraint.constraintsWithVisualFormat("V:|[view]|",
            options: [.AlignAllCenterX, .AlignAllCenterY],
            metrics: nil, views: ["view" : view])
        
        return horizontal + verticle
    }
}
