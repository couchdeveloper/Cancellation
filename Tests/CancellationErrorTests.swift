//
//  CancellationErrorTests.swift
//  Cancellation
//
//  Created by Andreas Grosam on 01/07/16.
//
//

import XCTest
@testable import Cancellation



class CancellationErrorTests: XCTestCase {

    func testTwoDefaultConstructedCancellationErrorsCompareEqual() {
        let ce1 = CancellationError()
        let ce2 = CancellationError()
        XCTAssertTrue(ce1 == ce2)
    }

    func testTwoCancellationErrorsWithUnequalDescriptionsCompareNotEqual() {
        let ce1 = CancellationError(message: "a")
        let ce2 = CancellationError(message: "b")
        XCTAssertFalse(ce1 == ce2)
    }

    func testTwoDefaultConstructedCancellationErrorsCompareEqualWithErrorProtocol1() {
        let error: Error = CancellationError()
        let ce2 = CancellationError()
        XCTAssertTrue(error == ce2)
    }
    
    func testTwoDefaultConstructedCancellationErrorsCompareEqualWithErrorProtocol2() {
        let ce1 = CancellationError()
        let error: Error = CancellationError()
        XCTAssertTrue(ce1 == error)
    }
    
    func testTwoCancellationErrorsWithUnequalDescriptionsCompareNotEqualWithErrorProtocol1() {
        let error: Error = CancellationError(message: "a")
        let ce2 = CancellationError(message: "b")
        XCTAssertFalse(error == ce2)
    }
    
    func testTwoCancellationErrorsWithUnequalDescriptionsCompareNotEqualWithErrorProtocol2() {
        let ce1 = CancellationError(message: "a")
        let error: Error = CancellationError(message: "b")
        XCTAssertFalse(ce1 == error)
    }
    
    func testCancellationErrorComparedToOtherErrorComapareFalse() {
        struct OtherError: Error {}
        let ce1 = CancellationError()
        let error = OtherError()
        XCTAssertFalse(ce1 == error)
        
    }

}
