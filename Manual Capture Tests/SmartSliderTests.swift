//
//  SmartSliderTests.swift
//  Manual Capture Tests
//
//  Created by Jean Flaherty on 10/4/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//
@testable import Capture
import XCTest

class SmartSliderTests: XCTestCase {
    
    var slider: WarpSlider<Float>!
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let startBounds = { CGRect(x: 0, y: 0, width: 100, height: 10) }
        let sliderBounds = { CGRect(x: 0, y: 0, width: 100, height: 10) }
        slider = WarpSlider(glyph: CaptureGlyph(type: .focus), direction: .right, startBounds: startBounds, sliderBounds: sliderBounds, 30)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        slider = nil
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
