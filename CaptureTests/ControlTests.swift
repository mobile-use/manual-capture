//
//  ControlTests.swift
//  CaptureTests
//
//  Created by Jean Flaherty on 10/8/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//
@testable import Capture
import XCTest

class ControlTests: XCTestCase {
    var control1: Control!
    var control2: Control!

    override func setUp() {
        control1 = Control(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        control2 = Control(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
        Control.currentControl = nil
    }

    override func tearDown() {
        control1 = nil
        control2 = nil
    }
    
    func testBecomeCurrentControlCase1() {
        // Given
        Control.currentControl = nil
        // When
        control1.becomeCurrentControl()
        // Then
        XCTAssertEqual(Control.currentControl, control1)
    }
    
    func testBecomeCurrentControlCase2() {
        // Given
        Control.currentControl = nil
        // When
        control2.becomeCurrentControl()
        // Then
        XCTAssertEqual(Control.currentControl, control2)
    }
    
    func testResignCurrentControlCase1() {
        // Given
        Control.currentControl = control1
        // When
        control1.resignCurrentControl()
        // Then
        XCTAssertNil(Control.currentControl, "Control.currentControl should be nil after resignCurrentControl()")
    }
    
    func testResignCurrentControlCase2() {
        // Given
        Control.currentControl = control2
        // When
        control2.resignCurrentControl()
        // Then
        XCTAssertNil(Control.currentControl, "Control.currentControl should be nil after resignCurrentControl()")
    }

}
