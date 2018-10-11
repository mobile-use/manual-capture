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
    
    // MARK: -- testFloatHandlerProgressForValueWithInitializedProperties --
    
    func testFloatHandlerProgressForValueWithInitializedPropertiesCase1() {
        // Given
        let value: Float = -200
        let guess: Float = 0.0
        // When
        let result = vpFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerProgressForValueWithInitializedPropertiesCase2() {
        // Given
        let value: Float = -100
        let guess: Float = 0.25
        // When
        let result = vpFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerProgressForValueWithInitializedPropertiesCase3() {
        // Given
        let value: Float = 0.0
        let guess: Float = 0.5
        // When
        let result = vpFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerProgressForValueWithInitializedPropertiesCase4() {
        // Given
        let value: Float = 100
        let guess: Float = 0.75
        // When
        let result = vpFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerProgressForValueWithInitializedPropertiesCase5() {
        // Given
        let value: Float = 200
        let guess: Float = 1.0
        // When
        let result = vpFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    // MARK: -- testExponentialCGFloatHandlerProgressForValueWithInitializedProperties --
    
    func testExponentialCGFloatHandlerProgressForValueWithInitializedPropertiesCase1() {
        // Given
        let value: CGFloat = 0.0
        let guess: Float = 0.0
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithInitializedPropertiesCase2() {
        // Given
        let value: CGFloat = 6.25
        let guess: Float = 0.25
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithInitializedPropertiesCase3() {
        // Given
        let value: CGFloat = 25.0
        let guess: Float = 0.5
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithInitializedPropertiesCase4() {
        // Given
        let value: CGFloat = 56.25
        let guess: Float = 0.75
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithInitializedPropertiesCase5() {
        // Given
        let value: CGFloat = 100.0
        let guess: Float = 1.0
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    // MARK: -- testFloatHandlerValueForProgressWithInitializedProperties --
    
    func testFloatHandlerValueForProgressWithInitializedPropertiesCase1() {
        // Given
        let progressValue: Float = 0.0
        let guess: Float = -200
        // When
        let result = vpFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerValueForProgressWithInitializedPropertiesCase2() {
        // Given
        let progressValue: Float = 0.25
        let guess: Float = -100
        // When
        let result = vpFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerValueForProgressWithInitializedPropertiesCase3() {
        // Given
        let progressValue: Float = 0.5
        let guess: Float = 0
        // When
        let result = vpFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerValueForProgressWithInitializedPropertiesCase4() {
        // Given
        let progressValue: Float = 0.75
        let guess: Float = 100
        // When
        let result = vpFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerValueForProgressWithInitializedPropertiesCase5() {
        // Given
        let progressValue: Float = 1.0
        let guess: Float = 200
        // When
        let result = vpFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    // MARK: -- testExponentialCGFloatHandlerValueForProgressWithInitializedProperties --
    
    func testExponentialCGFloatHandlerValueForProgressWithInitializedPropertiesCase1() {
        // Given
        let progressValue: Float = 0.0
        let guess: CGFloat = 0.0
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithInitializedPropertiesCase2() {
        // Given
        let progressValue: Float = 0.25
        let guess: CGFloat = 6.25
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithInitializedPropertiesCase3() {
        // Given
        let progressValue: Float = 0.5
        let guess: CGFloat = 25.0
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithInitializedPropertiesCase4() {
        // Given
        let progressValue: Float = 0.75
        let guess: CGFloat = 56.25
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithInitializedPropertiesCase5() {
        // Given
        let progressValue: Float = 1.0
        let guess: CGFloat = 100.0
        // When
        let result = vpExponentialCGFloatHandlerInitialProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    // MARK: -- testFloatHandlerProgressForValueWithNewProperties --
    
    func testFloatHandlerProgressForValueWithNewPropertiesCase1() {
        // Given
        let value: Float = 200
        let guess: Float = 0.0
        // When
        let result = vpFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerProgressForValueWithNewPropertiesCase2() {
        // Given
        let value: Float = 100
        let guess: Float = 0.25
        // When
        let result = vpFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerProgressForValueWithNewPropertiesCase3() {
        // Given
        let value: Float = 0
        let guess: Float = 0.5
        // When
        let result = vpFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerProgressForValueWithNewPropertiesCase4() {
        // Given
        let value: Float = -100
        let guess: Float = 0.75
        // When
        let result = vpFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerProgressForValueWithNewPropertiesCase5() {
        // Given
        let value: Float = -200
        let guess: Float = 1.0
        // When
        let result = vpFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    // MARK: -- testExponentialCGFloatHandlerProgressForValueWithNewProperties --
    
    func testExponentialCGFloatHandlerProgressForValueWithNewPropertiesCase1() {
        // Given
        let value: CGFloat = 100.0
        let guess: Float = 0.0
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithNewPropertiesCase2() {
        // Given
        let value: CGFloat = 98.4375
        let guess: Float = 0.25
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithNewPropertiesCase3() {
        // Given
        let value: CGFloat = 87.5
        let guess: Float = 0.5
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithNewPropertiesCase4() {
        // Given
        let value: CGFloat = 57.8125
        let guess: Float = 0.75
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerProgressForValueWithNewPropertiesCase5() {
        // Given
        let value: CGFloat = 0.0
        let guess: Float = 1.0
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.progressForValue(value)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    // MARK: -- testFloatHandlerValueForProgressWithNewProperties --
    
    func testFloatHandlerValueForProgressWithNewPropertiesCase1() {
        // Given
        let progressValue: Float = 0.0
        let guess: Float = 200
        // When
        let result = vpFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerValueForProgressWithNewPropertiesCase2() {
        // Given
        let progressValue: Float = 0.25
        let guess: Float = 100
        // When
        let result = vpFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerValueForProgressWithNewPropertiesCase3() {
        // Given
        let progressValue: Float = 0.5
        let guess: Float = 0.0
        // When
        let result = vpFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerValueForProgressWithNewPropertiesCase4() {
        // Given
        let progressValue: Float = 0.75
        let guess: Float = -100
        // When
        let result = vpFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testFloatHandlerValueForProgressWithNewPropertiesCase5() {
        // Given
        let progressValue: Float = 1.0
        let guess: Float = -200
        // When
        let result = vpFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    // MARK: -- testExponentialCGFloatHandlerValueForProgressWithNewProperties --
    
    func testExponentialCGFloatHandlerValueForProgressWithNewPropertiesCase1() {
        // Given
        let progressValue: Float = 0.0
        let guess: CGFloat = 100.0
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithNewPropertiesCase2() {
        // Given
        let progressValue: Float = 0.25
        let guess: CGFloat = 98.4375
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithNewPropertiesCase3() {
        // Given
        let progressValue: Float = 0.5
        let guess: CGFloat = 87.5
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithNewPropertiesCase4() {
        // Given
        let progressValue: Float = 0.75
        let guess: CGFloat = 57.8125
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }
    
    func testExponentialCGFloatHandlerValueForProgressWithNewPropertiesCase5() {
        // Given
        let progressValue: Float = 1.0
        let guess: CGFloat = 0.0
        // When
        let result = vpExponentialCGFloatHandlerNewProperties.valueForProgress(progressValue)
        // Then
        XCTAssertEqual(result, guess)
    }

}
