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
    
    typealias Value = V
    typealias SetValueAction = (V)->()
    var setValueAction: SetValueAction?
    
    typealias Item = (title: String, value: Value)
    var items: [Item] {didSet{ setupItems() }}
    var selectedIndex: Int = -1 {
        didSet{ selectionChanged(oldValue) }
    }
    
    static func indexOfItemWithValue(value: V, items:[Item]) -> Int? {
        for (i, item) in items.enumerate() {
            if item.value == value {
                return i
            }
        }
        return nil
    }
    func selectItemWithValue(value:V) -> Void? {
        selectedIndex = OptionControl.indexOfItemWithValue(value, items: items) ?? -1
        // return normally if found
        return (selectedIndex != -1) ? () : nil
    }
    
    func selectionChanged(oldIndex: Int){
        guard selectedIndex != oldIndex else { return }
        
        // reset old selected item
        if items.indices ~= oldIndex {
            let oldTextLayer = textLayers[oldIndex]
            oldTextLayer.foregroundColor = UIColor.whiteColor().CGColor
        }
        
        // fade away if out of range
        guard items.indices ~= selectedIndex else {
            CATransaction.setCompletionBlock { [weak self] in
                guard let me = self else {return}
                if !(me.items.indices ~= me.selectedIndex){
                    me.selectionIndicator.removeFromSuperlayer()
                }
            }
            selectionIndicator.opacity = 0.0
            return
        }
        
        // make sure layers are there
        if !(textLayers.indices ~= selectedIndex) {
            setupItems()
        }
        if selectionIndicator.superlayer == nil {
            layer.addSublayer(selectionIndicator)
        }
        
        let textLayer = textLayers[selectedIndex]
        
        var newSize = textLayer.preferredFrameSize()
        newSize.width += 10
        newSize.height = 20
        if !(items.indices ~= oldIndex) {
            // had no selection so dont animate movement
            CATransaction.begin()
            CATransaction.disableActions()
            updateIndicatorFrame()
            layer.layoutIfNeeded()
            textLayer.foregroundColor = kCaptureTintColor.CGColor
            CATransaction.commit()
            selectionIndicator.opacity = 1.0
        }else{
            CATransaction.begin()
            CATransaction.setAnimationDuration(CATransaction.animationDuration() * 2)
                textLayer.foregroundColor = kCaptureTintColor.CGColor
            CATransaction.commit()
            updateIndicatorFrame()
        }
        
        // trigger action
        setValueAction?(items[selectedIndex].value)
    }
    
    private let tapGesture = UITapGestureRecognizer()
    func handleTapGesture(gesture: UITapGestureRecognizer){
        let tapCoords = gesture.locationInView(self)
        guard CGRectContainsPoint(bounds, tapCoords) else { return }
        let itemLength = bounds.width / CGFloat(items.count)
        selectedIndex = Int( floor( tapCoords.x / itemLength ) )
    }
    
    private var textLayers: [CATextLayer] = []
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
    
    override func layoutSublayersOfLayer(layer: CALayer) {
        super.layoutSublayersOfLayer(layer)
        
        var nextXPosition: CGFloat = 0
        
        textLayers.forEach {
            let textLayer = $0
            
            let pSize = textLayer.preferredFrameSize()
            var itemRect = bounds
            itemRect.origin.x = nextXPosition
            itemRect.origin.y = (bounds.height - pSize.height) * 0.5
            itemRect.size.width /= CGFloat(items.count)
            itemRect.size.height = pSize.height
            
            textLayer.frame = itemRect
            
            nextXPosition += itemRect.width
        }
        updateIndicatorFrame()
    }
    
    private func updateIndicatorFrame(){
        guard textLayers.indices ~= selectedIndex else { return }
        let selectedTextLayer = textLayers[selectedIndex]
        
        var newSize = selectedTextLayer.preferredFrameSize()
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
        
        setupItems()
        
        let indexRange = items.startIndex ..< items.endIndex
        if(indexRange ~= selectedIndex){
            selectionIndicator.opacity = 1.0
            layer.addSublayer(selectionIndicator)
            selectionChanged(-1)
        }
    }
    convenience init(items:[Item], selectedValue: V, frame: CGRect = CGRectMake(0, 0, 50, 50)) {
        let sIndex = OptionControl.indexOfItemWithValue(selectedValue, items: items) ?? -1
        self.init(items: items, selectedIndex: sIndex, frame: frame)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override func intrinsicContentSize() -> CGSize { return CGSizeMake(100, 60) }
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

