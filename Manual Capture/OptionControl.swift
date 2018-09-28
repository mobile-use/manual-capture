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
        didSet{ selectionChanged(oldIndex: oldValue) }
    }
    
    class func indexOfItem(with value: V, items:[Item]) -> Int? {
        for (i, item) in items.enumerated() {
            if item.value == value {
                return i
            }
        }
        return nil
    }
    func item(with value: V) -> Item? {
        guard let i = OptionControl<V>.indexOfItem(with: value, items: items) else {
            return nil
        }
        return items[i]
    }
    
    func selectItem(with value:V) -> Void? {
        selectedIndex = OptionControl.indexOfItem(with: value, items: items) ?? -1
        // return normally if found
        return (selectedIndex != -1) ? () : nil
    }
    
    func selectionChanged(oldIndex: Index){
        guard selectedIndex != oldIndex else { return }
        
        // reset old selected item
        if items.indices ~= oldIndex {
            let oldText = textLayers[oldIndex]
            oldText.foregroundColor = UIColor.white.cgColor
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
                text.foregroundColor = kCaptureTintColor.cgColor
            }
            selectionIndicator.opacity = 1.0
        }else{
            layer.layoutIfNeeded()
            CATransaction.performBlock(duration: CATransaction.animationDuration() * 2) {
                text.foregroundColor = kCaptureTintColor.cgColor
            }
        }
        
        // trigger action
        value = items[selectedIndex].value
        setValueAction?(items[selectedIndex].value)
    }
    
    private var touchBounds = [CGRect]()
    private let tapGesture = UITapGestureRecognizer()
    @objc func handleTapGesture(gesture: UITapGestureRecognizer){
        let tapCoords = gesture.location(in: self)
        for (i, touchBound) in touchBounds.enumerated() {
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
            textLayer.foregroundColor = UIColor.white.cgColor
            textLayer.contentsScale = UIScreen.main.scale
            textLayer.alignmentMode = CATextLayerAlignmentMode.center
            
            textLayers.append(textLayer)
            layer.addSublayer(textLayer)
        }
    }
    
    var minWidth: CGFloat = 10
    
    override var intrinsicContentSize: CGSize {
        let minSpacing: CGFloat = 15.0
        let width = textLayers.reduce(minSpacing) { (widthSum, textLayer) -> CGFloat in
            return widthSum + max(textLayer.preferredFrameSize().width, minWidth) + minSpacing
        }
        return CGSize(width: width, height: 30.0)
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        let extraSpace = textLayers.reduce(bounds.width) {
            $0 - max($1.preferredFrameSize().width, minWidth)
        }
        let space = extraSpace / CGFloat(textLayers.count + 1)
        
        var nextX: CGFloat = space
        touchBounds = []
        
        textLayers.forEach { (textLayer) in
            var textRect = CGRect.zero
            textRect.size = textLayer.preferredFrameSize()
            textRect.size.width = max(textRect.width, minWidth)
            textRect.origin.x = nextX
            textRect.origin.y = (bounds.height - textRect.height) * 0.5
            
            textLayer.frame = textRect
            
            nextX += textRect.width + space
            var touchBound = textRect.insetBy(dx: -(space / 2), dy: 0)
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
        
        let textCenterPoint = CGPoint(
            x: selectedTextLayer.frame.midX,
            y: selectedTextLayer.frame.midY
        )
        selectionIndicator.position = textCenterPoint
        selectionIndicator.bounds.size = newSize
    }
 
    init(items:[Item], selectedIndex: Int = -1, frame: CGRect = CGRect(x: 0, y: 0, width: 100, height: 30)) {
        self.items = items
        self.selectedIndex = selectedIndex
        super.init(frame: frame)
        
        tapGesture.addTarget(self, action: #selector(self.handleTapGesture(gesture:)))
        addGestureRecognizer(tapGesture)
        
        selectionIndicator.opacity = 0.0
        selectionIndicator.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
        selectionIndicator.zPosition = -100
        layer.addSublayer(selectionIndicator)
        
        setupItems()
        
        let indexRange = items.startIndex ..< items.endIndex
        if(indexRange ~= selectedIndex){
            selectionIndicator.opacity = 1.0
            selectionChanged(oldIndex: -1)
        }
    }
    convenience init(items:[Item], selectedValue: V, frame: CGRect = CGRect(x: 0, y: 0, width: 50, height: 50)) {
        let sIndex = OptionControl.indexOfItem(with: selectedValue, items: items) ?? -1
        self.init(items: items, selectedIndex: sIndex, frame: frame)
    }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override func contentCompressionResistancePriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        switch axis {
        case .horizontal: return UILayoutPriority.defaultHigh
        case .vertical: return UILayoutPriority.defaultHigh
        }
    }
    override func contentHuggingPriority(for axis: NSLayoutConstraint.Axis) -> UILayoutPriority {
        switch axis {
        case .horizontal: return UILayoutPriority.defaultLow
        case .vertical: return UILayoutPriority.defaultHigh
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
        backgroundColor = UIColor.white.cgColor
        updateRoundedRect()
    }
    override init(layer: Any) { super.init(layer: layer) }
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
}

