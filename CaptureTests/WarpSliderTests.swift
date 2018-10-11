//
//  WarpSliderTests.swift
//  Manual Capture Tests
//
//  Created by Jean Flaherty on 10/4/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//
@testable import Capture
import XCTest

class WarpSliderTests: XCTestCase {
    var sliderFloat: WarpSlider<Float>!
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        let startBounds = { CGRect(x: 0, y: 0, width: 100, height: 10) }
        let sliderBounds = { CGRect(x: 0, y: 0, width: 100, height: 10) }
        sliderFloat = WarpSlider(glyph: CaptureGlyph(type: .focus), direction: .right, startBounds: startBounds, sliderBounds: sliderBounds, 30)
        sliderFloat.initialSensitivity = 0.25
        sliderFloat.labelTextForValue = { (value, shouldRound) in
            return String(format: "%.1f", value)
        }
        sliderFloat.valueProgressHandler = VPFloatHandler(start: -100, end: 100)
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sliderFloat = nil
    }

    func testSetProgress() {
        // Given
        let progressValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        let guesses: [Float] = [-100, -50, 0, 50, 100]
        
        XCTAssertEqual(guesses.count, progressValues.count)
        
        for i in 0..<guesses.count {
            // When
            sliderFloat.setProgress(progressValues[i], animated: false)
            // Then
            XCTAssertEqual(sliderFloat.value, guesses[i])
        }
    }
    
    func testKnobLayerText() {
        // Given
        let progressValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        let guesses: [String] = ["-100.0", "-50.0", "0.0", "50.0", "100.0"]
        
        XCTAssertEqual(guesses.count, progressValues.count)
        
        for i in 0..<guesses.count {
            // When
            sliderFloat.setProgress(progressValues[i], animated: false)
            // Then
            XCTAssertEqual(sliderFloat.knobLayer.text, guesses[i])
        }
    }

}
