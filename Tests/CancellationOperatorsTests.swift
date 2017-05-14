//
//  CancellationOperatorsTests.swift
//  FutureLib
//
//  Copyright © 2017 Andreas Grosam.
//  Licensed under the Apache License, Version 2.0.
//

import XCTest
@testable import Cancellation
import Dispatch

class CancellationOperatorsTests: XCTestCase {

    func testOred2CancellationToken() {
        let expect = self.expectation(description: "finished")
        func g() {
            let cr1 = CancellationRequest()
            let cr2 = CancellationRequest()
            func f(ct: CancellationTokenType) {
                DispatchQueue.global().async {
                    ct.onCancel {
                        XCTFail("should not be called")
                    }
                    for _ in 1...100 {
                        usleep(1000)
                    }
                    expect.fulfill()
                }
            }
            f(ct: cr1.token || cr2.token)
        }
        g()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testOred2CancellationToken10() {
        let expect = self.expectation(description: "finished")
        let cr = CancellationRequest()
        func g(cr: CancellationRequest) {
            let cr2 = CancellationRequest()
            func f(ct: CancellationTokenType) {
                DispatchQueue.global().async {
                    ct.onCancel {
                        expect.fulfill()
                    }
                    for _ in 1...100 {
                        usleep(1000)
                    }
                }
            }
            f(ct: cr.token || cr2.token)
        }
        g(cr: cr)
        cr.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }



    func testOred2CancellationToken1() {
        let expect = self.expectation(description: "handler shoulde be called")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let ct = cr1.token || cr2.token
        _ = ct.onCancel {
            expect.fulfill()
        }
        cr1.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(ct.isCancelled)
    }

    func testOred2CancellationToken2() {
        let expect = self.expectation(description: "handler shoulde be called")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let ct = cr1.token || cr2.token
        _ = ct.onCancel {
            expect.fulfill()
        }
        cr2.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(ct.isCancelled)
    }

    func testOred3CancellationToken1() {
        let expect = self.expectation(description: "handler shoulde be called")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let cr3 = CancellationRequest()
        let ct = cr1.token || cr2.token || cr3.token
        _ = ct.onCancel {
            expect.fulfill()
        }
        cr1.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(ct.isCancelled)
    }

    func testOred3CancellationToken2() {
        let expect = self.expectation(description: "handler shoulde be called")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let cr3 = CancellationRequest()
        let ct = cr1.token || cr2.token || cr3.token
        _ = ct.onCancel {
            expect.fulfill()
        }
        cr2.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(ct.isCancelled)
    }

    func testOred3CancellationToken3() {
        let expect = self.expectation(description: "handler shoulde be called")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let cr3 = CancellationRequest()
        let ct = cr1.token || cr2.token || cr3.token
        _ = ct.onCancel {
            expect.fulfill()
        }
        cr3.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(ct.isCancelled)
    }


    func testAnded2CancellationToken() {
        let expect = self.expectation(description: "finished")
        func g() {
            let cr1 = CancellationRequest()
            let cr2 = CancellationRequest()
            func f(ct: CancellationTokenType) {
                DispatchQueue.global().async {
                    ct.onCancel {
                        XCTFail("should not be called")
                    }
                    for _ in 1...100 {
                        usleep(1000)
                    }
                    expect.fulfill()
                }
            }
            f(ct: cr1.token && cr2.token)
        }
        g()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded2CancellationToken1() {
        let expect = self.expectation(description: "finished")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                ct.onCancel {
                    XCTFail("should not be called")
                }
                for _ in 1...100 {
                    usleep(1000)
                }
                expect.fulfill()
            }
        }
        f(ct: cr1.token && cr2.token)
        cr1.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded2CancellationToken1Polling() {
        let expect = self.expectation(description: "finished")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                for _ in 1...100 {
                    XCTAssertFalse(ct.isCancelled)
                    usleep(1000)
                }
                expect.fulfill()
            }
        }
        f(ct: cr1.token && cr2.token)
        cr1.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded2CancellationToken2() {
        let expect = self.expectation(description: "finished")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                ct.onCancel {
                    XCTFail("should not be called")
                }
                for _ in 1...100{
                    usleep(1000)
                }
                expect.fulfill()
            }
        }
        f(ct: cr1.token && cr2.token)
        cr2.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded2CancellationToken12() {
        let expect = self.expectation(description: "handler shoulde be called")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                ct.onCancel {
                    expect.fulfill()
                }
                for _ in 1...100 {
                    usleep(1000)
                }
            }
        }
        f(ct: cr1.token && cr2.token)
        cr1.cancel()
        cr2.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded2CancellationToken12Polling() {
        let expect = self.expectation(description: "handler shoulde be called")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                for _ in 1...100 {
                    if ct.isCancelled {
                        expect.fulfill()
                        return
                    }
                    usleep(1000)
                }
            }
        }
        f(ct: cr1.token && cr2.token)
        cr1.cancel()
        cr2.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded3CancellationToken1() {
        let expect = self.expectation(description: "finished")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let cr3 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                ct.onCancel {
                    XCTFail("should not be called")
                }
                for _ in 1...100{
                    usleep(1000)
                }
                expect.fulfill()
            }
        }
        f(ct: cr1.token && cr2.token && cr3.token)
        cr1.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded3CancellationToken2() {
        let expect = self.expectation(description: "finished")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let cr3 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                ct.onCancel {
                    XCTFail("should not be called")
                }
                for _ in 1...100{
                    usleep(1000)
                }
                expect.fulfill()
            }
        }
        f(ct: cr1.token && cr2.token && cr3.token)
        cr2.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded3CancellationToken3() {
        let expect = self.expectation(description: "finished")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let cr3 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                ct.onCancel {
                    XCTFail("should not be called")
                }
                for _ in 1...100{
                    usleep(1000)
                }
                expect.fulfill()
            }
        }
        f(ct: cr1.token && cr2.token && cr3.token)
        cr3.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

    func testAnded3CancellationToken123() {
        let expect = self.expectation(description: "handler shoulde be called")
        let cr1 = CancellationRequest()
        let cr2 = CancellationRequest()
        let cr3 = CancellationRequest()
        func f(ct: CancellationTokenType) {
            DispatchQueue.global().async {
                for _ in 1...100 {
                    if ct.isCancelled {
                        expect.fulfill()
                        return
                    }
                    usleep(1000)
                }
            }
        }
        f(ct: cr1.token && cr2.token && cr3.token)
        cr1.cancel()
        cr2.cancel()
        cr3.cancel()
        self.waitForExpectations(timeout: 1, handler: nil)
    }

}
