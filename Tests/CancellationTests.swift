//
//  CancellationTests.swift
//
//  Copyright © 2017 Andreas Grosam. All rights reserved.
//

import XCTest
import Cancellation

// An example operation, good enough to run some tests with it.
// (also shows, how elaborate a generic Operation actually is, compared to a simple task function)
class Operation<T>: Cancelable {

    typealias Result = (T?, Error?)
    typealias Completion = (Result) -> ()

    private var this: Operation?
    private var completion: Completion?
    private var result: Result?
    private let syncQueue = DispatchQueue(label: "sync_queue")
    private var timer: DispatchSourceTimer! // test task
    private let value: T            // test result
    private let duration: Double    // test duration

    init(value: T, duration: Double) {
        self.value = value
        self.duration = duration
    }

    func cancel() {
        self.syncQueue.async {
            guard self.result == nil else {
                return  // already completed
            }
            self.result = (nil, CancellationError())
            if let timer = self.timer {
                timer.cancel()
                self.complete()
            } else {
            }
        }
    }

    func run(completion: @escaping Completion) {
        self.syncQueue.async {
            guard self.this == nil else {
                fatalError("already running") // The operation is currently executing. It also cannot be run more than once.
            }
            guard self.result == nil else {
                guard self.result!.1 is CancellationError else {
                    fatalError("already completed")
                }
                // Operation has been cancelled previously
                assert(self.result?.1 is CancellationError)
                self.complete()
                return
            }
            self.completion = completion
            self.this = self
            self.timer = DispatchSource.makeTimerSource(queue: self.syncQueue)
            self.timer.scheduleOneshot(deadline: .now() + self.duration)
            self.timer.setEventHandler { [weak self] in
                guard let this = self, this.result == nil else {
                    // This will happen, when the operation has been cancelled and then finished
                    return
                }
                this.result = (this.value, nil)
                this.complete()
            }
            self.timer.resume()
        }
    }

    private func complete() {
        guard let result = self.result else {
            fatalError("actually not completed")
        }
        guard let completion = self.completion else {
            return
        }
        self.completion = nil
        self.this = nil
        self.timer = nil
        DispatchQueue.global().async {
            completion(result)
        }
    }
}



// Some pseudo task that runs forever and needs to be cancelled in order to complete:
func task(cancellationToken ct: CancellationTokenType, completion: @escaping (Int?, Error?)->()) {
    ct.onCancel {
        completion(nil, CancellationError())
    }
}



class CancellationTests: XCTestCase {

    func testACancellationRequestStartsOutWithNoCancellationRequest() {
        let cr = CancellationRequest()
        XCTAssertFalse(cr.isCancellationRequested)
    }

    func testACancellationRequestTokenStartsOutWithNoCancellationRequest() {
        let cr = CancellationRequest()
        XCTAssertFalse(cr.token.isCancelled)
    }

    func testRequestingCancellation() {
        let cr = CancellationRequest()
        cr.cancel()
        let expect1 = self.expectation(description: "cancellation handler should be called")
        cr.token.onComplete { _ in
            expect1.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
        XCTAssertTrue(cr.isCancellationRequested)
        XCTAssertTrue(cr.token.isCancelled)
    }

    func testOnCompleteShouldRun1() {
        let cr = CancellationRequest()
        let ct = cr.token
        let expect1 = self.expectation(description: "cancellation handler should be called")
        cr.cancel()
        ct.onComplete { cancelled in
            XCTAssertTrue(cancelled)
            expect1.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOnCompleteShouldRun2() {
        let cr = CancellationRequest()
        let ct = cr.token
        let expect1 = self.expectation(description: "cancellation handler should be called")
        ct.onComplete { cancelled in
            XCTAssertTrue(cancelled)
            expect1.fulfill()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            cr.cancel()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }


    func testOnCompleteShouldNotRun() {
        let cr = CancellationRequest()
        let ct = cr.token
        let expect1 = self.expectation(description: "cancellation handler should be called")
        ct.onComplete { cancelled in
            XCTFail()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            expect1.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }


    func testOnCancelShouldRun1() {
        let cr = CancellationRequest()
        let ct = cr.token
        let expect1 = self.expectation(description: "cancellation handler should be called")
        cr.cancel()
        ct.onCancel {
            expect1.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOnCancelShouldRun2() {
        let cr = CancellationRequest()
        let ct = cr.token
        let expect1 = self.expectation(description: "cancellation handler should be called")
        ct.onCancel {
            expect1.fulfill()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            cr.cancel()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOnCancelShouldNotRun1() {
        let cr = CancellationRequest()
        let ct = cr.token
        let expect1 = self.expectation(description: "cancellation handler should be called")
        ct.onCancel {
            XCTFail()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            expect1.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOnCancelShouldNotRun2() {
        let expect1 = self.expectation(description: "cancellation handler should be called")
        func test() {
            let cr = CancellationRequest()
            cr.token.onCancel {
                XCTFail()
            }
        }
        test()
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            expect1.fulfill()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testOnCompleteShouldRunWithFalse() {
        let expect1 = self.expectation(description: "cancellation handler should be called")
        func test() {
            let cr = CancellationRequest()
            cr.token.onComplete { cancel in
                XCTAssertFalse(cancel)
                expect1.fulfill()
            }
        }
        test()
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testAsyncTaskShouldBeCancelled() {
        let expect = self.expectation(description: "cancellation handler should be called")
        let cr = CancellationRequest()

        task(cancellationToken: cr.token) { (result, error) in
            defer {
                expect.fulfill()
            }
            XCTAssertNotNil(error)
            guard error is CancellationError else {
                XCTFail("expected cancellation error")
                return
            }
        }

        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            cr.cancel()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func test10AsyncTasksShouldBeCancelled() {
        let cr = CancellationRequest()
        (0...10).forEach {_ in
            let expect = self.expectation(description: "cancellation handler should be called")
            task(cancellationToken: cr.token) { (result, error) in
                defer {
                    expect.fulfill()
                }
                XCTAssertNotNil(error)
                guard error is CancellationError else {
                    XCTFail("expected cancellation error")
                    return
                }
            }
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            cr.cancel()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

    func testCancelable() {
        let expect = self.expectation(description: "completion handler should be called")
        let op = Operation<Int>(value: 0, duration: 0.5)
        let cr = CancellationRequest()
        cr.token.register(cancelable: op)
        op.run { (value, error) in
            XCTAssertNotNil(error)
            XCTAssertTrue(error is CancellationError)
            XCTAssertNil(value)
            expect.fulfill()
        }
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.2) {
            cr.cancel()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }

}
