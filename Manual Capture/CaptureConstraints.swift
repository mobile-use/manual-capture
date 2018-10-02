//
//  CaptureConstraints.swift
//  Capture
//
//  Created by Jean Flaherty on 11/22/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

typealias Constraint = NSLayoutConstraint
typealias Constraints = [NSLayoutConstraint]
typealias StyleConstraints = (UIView) -> Constraints


extension NSLayoutConstraint {
    convenience init(item: UIView, attribute: NSLayoutConstraint.Attribute, relation: NSLayoutConstraint.Relation = .equal, toItem: UIView? = nil, attribute toAttribute: NSLayoutConstraint.Attribute = .notAnAttribute, multiplier: CGFloat = 1, constant: CGFloat = 0) {
        self.init(item: item, attribute: attribute,
            relatedBy: relation,
            toItem: toItem, attribute: toAttribute,
            multiplier: multiplier, constant: constant)
    }
    
}

struct Style {
    typealias StyleConstraints = ([UIView]) -> Constraints
    let constraints: StyleConstraints
    
    init(constraints: @escaping StyleConstraints){
        self.constraints = constraints
    }
    
    static let FillSuperview = Style { let view = $0[0]
        guard let superview = view.superview else { return [] }
        
        view.translatesAutoresizingMaskIntoConstraints = false
        view.frame = superview.bounds
        
        let horizontal = Constraint.constraints(withVisualFormat: "H:|[view]|",
                                                options: [.alignAllCenterX, .alignAllCenterY],
            metrics: nil, views: ["view" : view])
        let verticle = Constraint.constraints(withVisualFormat: "V:|[view]|",
                                              options: [.alignAllCenterX, .alignAllCenterY],
            metrics: nil, views: ["view" : view])
        
        return horizontal + verticle
    }
    
}

extension Style {
    
    static let CaptureButtonContainer = Style(){ let container = $0[0]
        guard let superview = container.superview else { return [] }
        
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = Constraint(item: container, attribute: .centerY,
                                 toItem: superview, attribute: .centerY)
        let rightMargin = Constraint(item: container, attribute: .rightMargin,
                                     toItem: superview, attribute: .rightMargin,
            constant: -10)
        let width = Constraint(item: container, attribute: .width, constant: 60)
        let height = Constraint(item: container, attribute: .height, constant: 60)
        
        return [centerY, rightMargin, width, height]
    }
    
    static let Toolbar = Style(){ let toolbar = $0[0]
        guard let superview = toolbar.superview else { return [] }
        
        toolbar.translatesAutoresizingMaskIntoConstraints = false
//        toolbar.backgroundColor = UIColor.black.withAlphaComponent(0.1)
//        toolbar.layer.borderWidth = 1.0
//        toolbar.layer.borderColor = UIColor.white.cgColor
        
        let x = Constraint.constraints(withVisualFormat: "H:|[toolbar(40)]",
                                       options: [.alignAllCenterX, .alignAllCenterY],
            metrics: nil, views: ["toolbar" : toolbar])
        let y = Constraint.constraints(withVisualFormat: "V:|[toolbar]|",
                                       options: [.alignAllCenterX, .alignAllCenterY],
            metrics: nil, views: ["toolbar" : toolbar])
        
        return x + y
    }
    
    static let Capturebar = Style(){ let capturebar = $0[0]
        guard let superview = capturebar.superview else { return [] }
        
        capturebar.translatesAutoresizingMaskIntoConstraints = false
        //capturebar.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.4)
//        capturebar.layer.borderWidth = 1.0
//        capturebar.layer.borderColor = UIColor.white.CGColor
        
        let x = Constraint.constraints(withVisualFormat: "H:[capturebar(80)]|",
                                       options: [.alignAllCenterX, .alignAllCenterY],
            metrics: nil, views: ["capturebar" : capturebar])
        let y = Constraint.constraints(withVisualFormat: "V:|[capturebar]|",
                                       options: [.alignAllCenterX, .alignAllCenterY],
            metrics: nil, views: ["capturebar" : capturebar])
        
        return x + y
    }
    
    static let GalleryButtonContainer = Style(){
        let galleryButtonContainer = $0[0]
        let shutterButtonContainer = $0[1]
        guard let superview = galleryButtonContainer.superview else { return [] }
        
        galleryButtonContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let centerY = Constraint(item: galleryButtonContainer, attribute: .centerY,
                                 toItem: superview, attribute: .centerY, multiplier: 1.0, constant: 75)
        let rightMargin = Constraint(item: galleryButtonContainer, attribute: .rightMargin,
                                     toItem: superview, attribute: .rightMargin,
                                     constant: -10)
        let width = Constraint(item: galleryButtonContainer, attribute: .width, constant: 40)
        let height = Constraint(item: galleryButtonContainer, attribute: .height, constant: 40)
        
        return [centerY, rightMargin, width, height]
    }
    
}

extension UIView {
    func layout(style: Style, views: UIView...){
        views.forEach { view in
            if view.superview == nil {
                addSubview(view)
            }
        }
        addConstraints(style.constraints(views))
    }
}
