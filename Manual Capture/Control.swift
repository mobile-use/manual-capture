//
//  CaptureControl.swift
//  Manual Capture
//
//  Created by Jean Flaherty on 10/4/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//

import UIKit

class Control: UIView {
    static var currentControl: Control? = nil {
        didSet(oldControl) {
            //guard Control.currentControl != oldControl else {return}
            oldControl?.isCurrentControl = false
            currentControl?.isCurrentControl = true
        }
    }
    var isCurrentControl: Bool = false {
        didSet {
            state.getUpdateTransform(isCurrentControl, .current)?(&state)
        }
    }
    final func becomeCurrentControl(){
        guard Control.currentControl != self else {return}
        Control.currentControl = self
    }
    final func resignCurrentControl(){
        guard Control.currentControl == self else {return}
        Control.currentControl = nil
    }
    
    var actionDidStateChange: ((_ add: State, _ remove: State) -> Void)?
    var actionWillStateChange: ((_ add: State, _ remove: State) -> Void)?
    
    
    struct State: OptionSet {
        let rawValue: Int
        static var normal = State(rawValue: 0)
        static let disabled = State(rawValue: 1 << 0)
        static let active = State(rawValue: 1 << 1)
        static let current = State(rawValue: 1 << 2)
        static let simplified = State(rawValue: 1 << 3)
        static let computerControlled = State(rawValue: 1 << 4)
        func hasProperty(_ property: State) -> Bool {
            // Makes no sense to ask if state contains empty property
            if property.isEmpty {return self.isEmpty}
            return contains(property)
        }
        
        typealias StateTransForm = (inout State) -> Void
        /// returns nil if update is unneeded otherwise returns a inout closure that can do the job
        func getUpdateTransform(_ shouldHave:Bool, _ change:State) -> StateTransForm? {
            guard self.hasProperty(change) != shouldHave else { return nil/*no need to update*/ }
            if shouldHave {
                return { ( state: inout State) in state = state.union(change) }
            } else {
                return { ( state: inout State) in state = state.subtracting(change) }
            }
        }
    }
    var state: State = .normal {
        didSet{
            guard state != oldValue else { return }
            didChangeState(oldState: oldValue)
            
            actionDidStateChange?(
                state.subtracting(oldValue),
                oldValue.subtracting(state)
            )
        }
        willSet{
            guard state != newValue else { return }
            willChangeState(newState: newValue)
            
            actionWillStateChange?(
                newValue.subtracting(state),
                state.subtracting(newValue)
            )
        }
    }
    func didChangeState(oldState:State){}
    func willChangeState(newState:State){}
}
