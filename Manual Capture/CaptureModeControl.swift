//
//  CaptureModeControl.swift
//  Capture
//
//  Created by Jean Flaherty on 10/7/15.
//  Copyright © 2015 mobileuse. All rights reserved.
//

import UIKit

class CaptureModeControl: Control {
    
    var glyph: CALayer?
    private var selectionIndicator = SelectionIndicator()
    var items: [CaptureModeControlItem] {didSet{ setupItems() }}
    var selectedIndex: Int = -1 {
        didSet{ selectionChanged(oldValue) }
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
                self?.selectionIndicator.removeFromSuperlayer()
            }
            selectionIndicator.opacity = 0.0
            return
        }
        
        // make sure layer are there
        if !(textLayers.indices ~= selectedIndex) {
            setupItems()
        }
        
        let textLayer = textLayers[selectedIndex]
        
        var newSize = textLayer.preferredFrameSize()
        newSize.width += 10
        newSize.height = 20
        if !(items.indices ~= oldIndex) {
            // had no selection so dont animate movement
            CATransaction.disableActions {
                self.layer.addSublayer(self.selectionIndicator)
                self.selectionIndicator.bounds.size = newSize
                textLayer.foregroundColor = kCaptureTintColor.CGColor
            }
            selectionIndicator.opacity = 1.0
        }else{
            CATransaction.performBlock {
                CATransaction.setAnimationDuration(CATransaction.animationDuration() * 2)
                textLayer.foregroundColor = kCaptureTintColor.CGColor
            }
            selectionIndicator.bounds.size = newSize
        }
        
        // trigger action
        items[selectedIndex].action?(self)
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
    
    override func intrinsicContentSize() -> CGSize {
        let spacing: CGFloat = 5.0
        let width = textLayers.reduce(spacing) { (width, textLayer) -> CGFloat in
            return width + textLayer.preferredFrameSize().width + spacing
        }
        return CGSizeMake(width, 30.0)
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

        guard textLayers.indices ~= selectedIndex else { return }
        let selectedTextLayer = textLayers[selectedIndex]
        let textCenterPoint = CGPointMake(
            selectedTextLayer.frame.midX,
            selectedTextLayer.frame.midY
        )
        selectionIndicator.position = textCenterPoint
    }
 
    init(items:[CaptureModeControlItem] = [], selectedIndex: Int, frame: CGRect = CGRectMake(0, 0, 50, 50)) {
        self.items = items
        self.selectedIndex = selectedIndex
        super.init(frame: frame)
        
        tapGesture.addTarget(self, action: "handleTapGesture:")
        addGestureRecognizer(tapGesture)
        
        selectionIndicator.opacity = 1.0
        selectionIndicator.frame = CGRectMake(0, 0, 40, 20)
        selectionIndicator.zPosition = -100
        
        setupItems()
        
        let indexRange = items.startIndex ..< items.endIndex
        if(indexRange ~= selectedIndex){
            selectionIndicator.opacity = 1.0
            layer.addSublayer(selectionIndicator)
        }
        
        selectionChanged(-1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private class SelectionIndicator : CALayer {
        override var bounds: CGRect {
            didSet{ updateRoundedRect() }
        }
        
        func updateRoundedRect(){
            let thickness = min(bounds.width, bounds.height)
            cornerRadius = thickness / 2
            //self.path = UIBezierPath(roundedRect: bounds, cornerRadius: thickness / 2 ).CGPath
        }
        
        override init() {
            super.init()
            backgroundColor = UIColor.whiteColor().CGColor
            updateRoundedRect()
        }
        
        override init(layer: AnyObject) {
            super.init(layer: layer)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

struct CaptureModeControlItem {
    let title: String
    let action: ActionCallback?
    typealias ActionCallback = ((CaptureModeControl) -> ())
    
    init(title: String, action: ActionCallback? = nil){
        self.title = title
        self.action = action
    }
}

