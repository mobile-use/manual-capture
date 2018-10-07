//
//  ValueProgressHandlerTests.swift
//  Manual Capture Tests
//
//  Created by Jean Flaherty on 10/7/18.
//  Copyright © 2018 mobileuse. All rights reserved.
//
@testable import Capture
import XCTest

class ValueProgressHandlerTests: XCTestCase {
    var vpFloatHandlerInitialProperties: VPFloatHandler!
    var vpFloatHandlerNewProperties: VPFloatHandler!
    var vpExponentialCGFloatHandlerInitialProperties: VPExponentialCGFloatHandler!
    var vpExponentialCGFloatHandlerNewProperties: VPExponentialCGFloatHandler!

    override func setUp() {
        vpFloatHandlerInitialProperties = VPFloatHandler(start: -200, end: 200)
        vpFloatHandlerNewProperties = VPFloatHandler(start: -200, end: 200)
        vpExponentialCGFloatHandlerInitialProperties = VPExponentialCGFloatHandler(start: 0.0, end: 100.0, power: 2.0)
        vpExponentialCGFloatHandlerNewProperties = VPExponentialCGFloatHandler(start: 0.0, end: 100.0, power: 2.0)
        // Set new properties
        vpFloatHandlerNewProperties.start = 200
        vpFloatHandlerNewProperties.end = -200
        vpExponentialCGFloatHandlerNewProperties.start = 100.0
        vpExponentialCGFloatHandlerNewProperties.end = 0.0
        vpExponentialCGFloatHandlerNewProperties.power = 3.0
    }

    override func tearDown() {
        vpFloatHandlerInitialProperties = nil
        vpExponentialCGFloatHandlerInitialProperties = nil
    }
    
    func testFloatHandlerProgressForValueWithInitializedProperties() {
        // Given
        let values: [Float] = [-200, -100, 0, 100, 200]
        let guesses: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        
        XCTAssertEqual(guesses.count, values.count)
        
        for i in 0..<guesses.count {
            // When
            let result = vpFloatHandlerInitialProperties.progressForValue(values[i])
            // Then
            XCTAssertEqual(result, guesses[i])
        }
        
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithInitializedProperties() {
        // Given
        let values: [CGFloat] = [0.0, 6.25, 25.0, 56.25, 100.0]
        let guesses: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        
        XCTAssertEqual(guesses.count, values.count)
        
        for i in 0..<guesses.count {
            // When
            let result = vpExponentialCGFloatHandlerInitialProperties.progressForValue(values[i])
            // Then
            XCTAssertEqual(result, guesses[i])
        }
        
    }
    
    func testFloatHandlerValueForProgressWithInitializedProperties() {
        // Given
        let progressValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        let guesses: [Float] = [-200, -100, 0, 100, 200]
        
        XCTAssertEqual(guesses.count, progressValues.count)
        
        for i in 0..<guesses.count {
            // When
            let result = vpFloatHandlerInitialProperties.valueForProgress(progressValues[i])
            // Then
            XCTAssertEqual(result, guesses[i])
        }
        
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithInitializedProperties() {
        // Given
        let progressValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        let guesses: [CGFloat] = [0.0, 6.25, 25.0, 56.25, 100.0]
        
        XCTAssertEqual(guesses.count, progressValues.count)
        
        for i in 0..<guesses.count {
            // When
            let result = vpExponentialCGFloatHandlerInitialProperties.valueForProgress(progressValues[i])
            // Then
            XCTAssertEqual(result, guesses[i])
        }
        
    }
    
    func testFloatHandlerProgressForValueWithNewProperties() {
        // Given
        let values: [Float] = [200, 100, 0, -100, -200]
        let guesses: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        
        XCTAssertEqual(guesses.count, values.count)
        
        for i in 0..<guesses.count {
            // When
            let result = vpFloatHandlerNewProperties.progressForValue(values[i])
            // Then
            XCTAssertEqual(result, guesses[i])
        }
        
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithNewProperties() {
        // Given
        let values: [CGFloat] = [100.0, 98.4375, 87.5, 57.8125, 0.0]
        let guesses: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        
        XCTAssertEqual(guesses.count, values.count)
        
        for i in 0..<guesses.count {
            // When
            let result = vpExponentialCGFloatHandlerNewProperties.progressForValue(values[i])
            // Then
            XCTAssertEqual(result, guesses[i])
        }
        
    }
    
    func testFloatHandlerValueForProgressWithNewProperties() {
        // Given
        let progressValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        let guesses: [Float] = [200, 100, 0, -100, -200]
        
        XCTAssertEqual(guesses.count, progressValues.count)
        
        for i in 0..<guesses.count {
            // When
            let result = vpFloatHandlerNewProperties.valueForProgress(progressValues[i])
            // Then
            XCTAssertEqual(result, guesses[i])
        }
        
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithNewProperties() {
        // Given
        let progressValues: [Float] = [0.0, 0.25, 0.5, 0.75, 1.0]
        let guesses: [CGFloat] = [100.0, 98.4375, 87.5, 57.8125, 0.0]
        
        XCTAssertEqual(guesses.count, progressValues.count)
        
        for i in 0..<guesses.count {
            // When
            let result = vpExponentialCGFloatHandlerNewProperties.valueForProgress(progressValues[i])
            // Then
            XCTAssertEqual(result, guesses[i])
        }
        
    }

}
