//
//  ControlPanel.swift
//  Capture
//
//  Created by Jean Flaherty on 10/7/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class ControlPanel: UIView {

    let rows: [Row]
    
    init(rows: [Row], frame: CGRect){
        self.rows = rows
        super.init(frame: frame)
        
        let r: CGFloat = 10
        layoutMargins = UIEdgeInsetsMake(0, r, 0, r)
        
        // Layer Appearance
        layer.borderWidth = 1
        layer.borderColor = UIColor.whiteColor().CGColor
        layer.cornerRadius = r
        
        initRows()
    }
    
    private(set) var contentHeight: CGFloat = 0
    
    override func intrinsicContentSize() -> CGSize {
        return CGSizeMake(100, contentHeight + abs(layoutMargins.top) + abs(layoutMargins.bottom) )
    }
    
    override func contentCompressionResistancePriorityForAxis(axis: UILayoutConstraintAxis) -> UILayoutPriority {
        switch axis {
        case .Horizontal: return UILayoutPriorityDefaultLow
        case .Vertical: return UILayoutPriorityDefaultHigh
        }
    }
    override func contentHuggingPriorityForAxis(axis: UILayoutConstraintAxis) -> UILayoutPriority {
        switch axis {
        case .Horizontal: return UILayoutPriorityDefaultLow
        case .Vertical: return UILayoutPriorityDefaultHigh
        }
    }
    
    func initRows() {
        contentHeight = 0
        var nextTopConstraint = { (row:Row) -> NSLayoutConstraint in
            return NSLayoutConstraint(
                item: row.view,
                    attribute: .Top, relatedBy: .Equal,
                toItem: self,
                    attribute: .TopMargin, multiplier: 1, constant: 0
            )
        }
        
        rows.forEach { (row) in
            
            // Add Row View
            let rowFrame = CGRectMake(0, contentHeight, bounds.width, row.height)
            row.view.frame = rowFrame
            row.view.translatesAutoresizingMaskIntoConstraints = false
            //row.view.backgroundColor = UIColor.redColor()
            addSubview(row.view)
            
            
            // Declare Constraints
            let hFormat = row.hConstraintsFormat ?? "|-[Row]-|"
            let lowPriorityCenterXConstraint = NSLayoutConstraint(
                item: row.view,
                attribute: .CenterX, relatedBy: .Equal,
                toItem: self,
                attribute: .CenterX, multiplier: 1, constant: 0
            )
            lowPriorityCenterXConstraint.priority = UILayoutPriorityDefaultLow
            let xConstraints = NSLayoutConstraint.constraintsWithVisualFormat(
                 "H:\(hFormat)",
                options: .DirectionLeftToRight,
                metrics: nil, views: ["Row" : row.view]
            )
            let heightConstraint = NSLayoutConstraint(
                item: row.view,
                    attribute: .Height, relatedBy: .Equal,
                toItem: nil,
                    attribute: .NotAnAttribute, multiplier: 1, constant: row.height
            )
            let topConstraint = nextTopConstraint(row)
            
            // Add Constraints
            addConstraint(lowPriorityCenterXConstraint)
            addConstraints(xConstraints)
            addConstraint(heightConstraint)
            addConstraint(topConstraint)
            
            // Prepare For Next Row
            contentHeight += row.height
            nextTopConstraint = { (nextRow: Row) -> NSLayoutConstraint in
                return NSLayoutConstraint(
                    item: nextRow.view,
                        attribute: .Top, relatedBy: .Equal,
                    toItem: row.view,
                        attribute: .Bottom, multiplier: 1, constant: 0
                )
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    struct Row {
        let height: CGFloat
        let view: UIView
        var hConstraintsFormat: String?
        
        init(view: UIView, height: CGFloat = 50){
            self.view = view
            self.height = height
        }
        
        init(view: UIView, height: CGFloat, hConstraintsFormat: String){
            self.view = view
            self.height = height
            self.hConstraintsFormat = hConstraintsFormat
        }
        
        init(view: UIView, type: Type){
            let settings = ControlPanel.Row.settings(type)
            self.init(view: view,
                height: settings.height,
                hConstraintsFormat: settings.hConstraintsFormat)
        }
        
        init(_ modeControl: CaptureModeControl) {
            self.init(view: modeControl, type: .ModeControl)
        }
        
        init<V: Equatable>(_ optionControl: OptionControl<V>) {
            self.init(view: optionControl, type: .OptionControl)
        }
        
        init(_ slider: Slider) {
            self.init(view: slider, type: .Slider)
        }
        
        typealias Settings = (height: CGFloat, hConstraintsFormat: String)
        
        enum Type {
            case Slider, OptionControl, ModeControl
        }
        
        private static func settings(type:Type) -> Settings {
            switch type {
            case .Slider:
                return (40, "|-20-[Row(<=250)]-20-|")
            case .OptionControl, .ModeControl:
                return (30, "|->=10-[Row(>=150)]->=10-|")
            }
        }
        
    }

}
