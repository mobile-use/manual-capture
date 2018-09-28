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
        layoutMargins = UIEdgeInsets(top: 0, left: r, bottom: 0, right: r)
        
        // Layer Appearance
        layer.borderWidth = 1
        layer.borderColor = UIColor.white.cgColor
        layer.cornerRadius = r
        
        initRows()
    }
    
    private(set) var contentHeight: CGFloat = 0
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 100, height: contentHeight + abs(layoutMargins.top) + abs(layoutMargins.bottom) )
    }
    
    override func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        switch axis {
        case .horizontal: return .defaultLow
        case .vertical: return .defaultHigh
        }
    }
    override func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        switch axis {
        case .horizontal: return .defaultLow
        case .vertical: return .defaultHigh
        }
    }
    
    func initRows() {
        contentHeight = 0
        var nextTopConstraint = { (row:Row) -> NSLayoutConstraint in
            return NSLayoutConstraint(
                item: row.view,
                    attribute: .top, relatedBy: .equal,
                toItem: self,
                    attribute: .topMargin, multiplier: 1, constant: 0
            )
        }
        
        rows.forEach { (row) in
            
            // Add Row View
            let rowFrame = CGRect(x: 0, y: contentHeight, width: bounds.width, height: row.height)
            row.view.frame = rowFrame
            row.view.translatesAutoresizingMaskIntoConstraints = false
            //row.view.backgroundColor = UIColor.redColor()
            addSubview(row.view)
            
            
            // Declare Constraints
            let hFormat = row.hConstraintsFormat ?? "|-[Row]-|"
            let lowPriorityCenterXConstraint = NSLayoutConstraint(
                item: row.view,
                attribute: .centerX, relatedBy: .equal,
                toItem: self,
                attribute: .centerX, multiplier: 1, constant: 0
            )
            lowPriorityCenterXConstraint.priority = UILayoutPriority.defaultLow
            let xConstraints = NSLayoutConstraint.constraints(
                withVisualFormat: "H:\(hFormat)",
                options: .directionLeftToRight,
                metrics: nil, views: ["Row" : row.view]
            )
            let heightConstraint = NSLayoutConstraint(
                item: row.view,
                    attribute: .height, relatedBy: .equal,
                toItem: nil,
                attribute: .notAnAttribute, multiplier: 1, constant: row.height
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
                        attribute: .top, relatedBy: .equal,
                    toItem: row.view,
                    attribute: .bottom, multiplier: 1, constant: 0
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
        
        init(view: UIView, type: ControlType){
            let settings = ControlPanel.Row.settings(type: type)
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
        
        enum ControlType {
            case Slider, OptionControl, ModeControl
        }
        
        private static func settings(type: ControlType) -> Settings {
            switch type {
            case .Slider:
                return (40, "|-20-[Row(<=250)]-20-|")
            case .OptionControl, .ModeControl:
                return (30, "|->=10-[Row(>=150)]->=10-|")
            }
        }
        
    }

}
