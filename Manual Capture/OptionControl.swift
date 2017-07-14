//
//  CaptureModeControl.swift
//  Capture
//
//  Created by Jean Flaherty on 10/7/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class OptionControl<V: Equatable>: Control {
    private typealias SelectionIndicator = OptionControlSelectionIndicator
    private var selectionIndicator = SelectionIndicator()
    
    typealias SetValueAction = (V) -> Void
    var setValueAction: SetValueAction?
    private(set) var value: V? = nil
    
    typealias Item = (title: String, value: V)
    var items: [Item] {didSet{ setupItems() }}
    typealias Index = Int
    var selectedIndex: Index = -1 {
        didSet{ selectionChanged(oldValue) }
    }
    
    class func indexOfItemWithValue(value: V, items:[Item]) -> Int? {
        for (i, item) in items.enumerate() {
            if item.value == value {
                return i
            }
        }
        return nil
    }
    func itemWithValue(value: V) -> Item? {
        guard let i = OptionControl<V>.indexOfItemWithValue(value, items: items) else {
            return nil
        }
        return items[i]
    }
    
    func selectItemWithValue(value:V) -> Void? {
        selectedIndex = OptionControl.indexOfItemWithValue(value, items: items) ?? -1
        // return normally if found
        return (selectedIndex != -1) ? () : nil
    }
    
    func selectionChanged(oldIndex: Index){
        guard selectedIndex != oldIndex else { return }
        
        // reset old selected item
        if items.indices ~= oldIndex {
            let oldText = textLayers[oldIndex]
            oldText.foregroundColor = UIColor.whiteColor().CGColor
        }
        
        // fade away if out of range
        guard items.indices ~= selectedIndex else {
            selectionIndicator.opacity = 0.0
            value = nil
            return
        }
        
        // selection changed and is visible so must need layout
        layer.setNeedsLayout()
        
        let text = textLayers[selectedIndex]
        
        if !(items.indices ~= oldIndex) {
            // had no selection so dont animate movement
            CATransaction.disableActions {
                self.layer.layoutIfNeeded()
                text.foregroundColor = kCaptureTintColor.CGColor
            }
            selectionIndicator.opacity = 1.0
        }else{
            layer.layoutIfNeeded()
            CATransaction.performBlock(CATransaction.animationDuration() * 2) {
                text.foregroundColor = kCaptureTintColor.CGColor
            }
        }
        
        // trigger action
        value = items[selectedIndex].value
        setValueAction?(items[selectedIndex].value)
    }
    
    private var touchBounds = [CGRect]()
    private let tapGesture = UITapGestureRecognizer()
    func handleTapGesture(gesture: UITapGestureRecognizer){
        let tapCoords = gesture.locationInView(self)
        for (i, touchBound) in touchBounds.enumerate() {
            if touchBound.contains(tapCoords) {
                selectedIndex = i
                break
            }
        }
    }
    
    private var textLayers = [CATextLayer]()
    private func setupItems() {
        textLayers.forEach { $0.removeFromSuperlayer() }
        textLayers = []
        
        items.forEach {
            let item = $0
            
            let textLayer = CATextLayer()
            textLayer.string = item.title
            textLayer.font = UIFont(name: "HelveticaNeue", size: 12)
            textLayer.fontSize = 12
            textLayer.foregroundColor = UIColor.whiteColor().CGColor
            textLayer.contentsScale = UIScreen.mainScreen().scale
            textLayer.alignmentMode = kCAAlignmentCenter
            
            textLayers.append(textLayer)
            layer.addSublayer(textLayer)
        }
    }
    
    var minWidth: CGFloat = 10
    
    override func intrinsicContentSize() -> CGSize {
        let minSpacing: CGFloat = 15.0
        let width = textLayers.reduce(minSpacing) { (widthSum, textLayer) -> CGFloat in
            return widthSum + max(textLayer.preferredFrameSize().width, minWidth) + minSpacing
        }
        return CGSizeMake(width, 30.0)
    }
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        let extraSpace = textLayers.reduce(bounds.width) {
            $0 - max($1.preferredFrameSize().width, minWidth)
        }
        let space = extraSpace / CGFloat(textLayers.count + 1)
        
        var nextX: CGFloat = space
        touchBounds = []
        
        textLayers.forEach { (textLayer) in
            var textRect = CGRectZero
            textRect.size = textLayer.preferredFrameSize()
            textRect.size.width = max(textRect.width, minWidth)
            textRect.origin.x = nextX
            textRect.origin.y = (bounds.height - textRect.height) * 0.5
            
            textLayer.frame = textRect
            
            nextX += textRect.width + space
            var touchBound = CGRectInset(textRect, -(space / 2), 0)
            touchBound.origin.y = 0
            touchBound.size.height = bounds.height
            touchBounds.append(touchBound)
        }
        updateIndicatorFrame()
    }
    
    private func updateIndicatorFrame(){
        guard textLayers.indices ~= selectedIndex else { return }
        let selectedTextLayer = textLayers[selectedIndex]
        
        var newSize = selectedTextLayer.bounds.size
        newSize.width += 10
        newSize.height = 20
        
        let textCenterPoint = CGPointMake(
            selectedTextLayer.frame.midX,
            selectedTextLayer.frame.midY
        )
        selectionIndicator.position = textCenterPoint
        selectionIndicator.bounds.size = newSize
    }
 
    init(items:[Item], selectedIndex: Int = -1, frame: CGRect = CGRectMake(0, 0, 100, 30)) {
        self.items = items
        self.selectedIndex = selectedIndex
        super.init(frame: frame)
        
        tapGesture.addTarget(self, action: "handleTapGesture:")
        addGestureRecognizer(tapGesture)
        
        selectionIndicator.opacity = 0.0
        selectionIndicator.frame = CGRectMake(0, 0, 40, 20)
        selectionIndicator.zPosition = -100
        layer.addSublayer(selectionIndicator)
        
        setupItems()
        
        let indexRange = items.startIndex ..< items.endIndex
        if(indexRange ~= selectedIndex){
            selectionIndicator.opacity = 1.0
            selectionChanged(-1)
        }
    }
    convenience init(items:[Item], selectedValue: V, frame: CGRect = CGRectMake(0, 0, 50, 50)) {
        let sIndex = OptionControl.indexOfItemWithValue(selectedValue, items: items) ?? -1
        self.init(items: items, selectedIndex: sIndex, frame: frame)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func contentCompressionResistancePriorityForAxis(axis: UILayoutConstraintAxis) -> UILayoutPriority {
        switch axis {
        case .Horizontal: return UILayoutPriorityDefaultHigh
        case .Vertical: return UILayoutPriorityDefaultHigh
        }
    }
    override func contentHuggingPriorityForAxis(axis: UILayoutConstraintAxis) -> UILayoutPriority {
        switch axis {
        case .Horizontal: return UILayoutPriorityDefaultLow
        case .Vertical: return UILayoutPriorityDefaultHigh
        }
    }
}

private class OptionControlSelectionIndicator : CALayer {
    override var bounds: CGRect { didSet{ updateRoundedRect() } }
    func updateRoundedRect(){
        let thickness = min(bounds.width, bounds.height)
        cornerRadius = thickness / 2
    }
    
    override init() {
        super.init()
        backgroundColor = UIColor.whiteColor().CGColor
        updateRoundedRect()
    }
    override init(layer: AnyObject) { super.init(layer: layer) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

