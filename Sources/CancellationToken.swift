//
//  CancellationToken.swift
//
//  Copyright © 2017 Andreas Grosam. All rights reserved.
//

import Dispatch


private var _sync_id: Int32 = 0


/// The CancelationToken is passed from the client to a task when it creates the task
/// to let it know when the client has requested a cancellation.
internal final class CancellationToken: CancellationTokenType {

    private enum State {
        init(targetQueue: DispatchQueue) {
            let handlerQueue = DispatchQueue(label: "handler-queue", target: targetQueue)
            handlerQueue.suspend()
            self = .pending(handlerQueue)
        }
        case pending(DispatchQueue)
        case completed(Bool)
    }

    private var state: State
    private let syncQueue = DispatchQueue(label: "cancellation.sync_queue-\(Int(OSAtomicIncrement32(&_sync_id)))")


    internal init() {
        self.state = State(targetQueue: self.syncQueue)
    }

    deinit {
        // assert: self.completed == true
        // If you get an error "BUG IN CLIENT OF LIBDISPATCH: Release of a suspended object"
        // ensure, that 
        //  - `self`'s associated cancellation request will be cancelled or
        //  - the cancellation request will be deinitialized _before_ `self`, or 
        //  - `self` has registered at least one handler.
    }


    /// Returns `true` if `self`'s associated `CancellationRequest` has requested
    /// a cancellation. Otherwise, it returns `false`.
    final var isCancelled: Bool {
        return syncQueue.sync {
            if case .completed(let cancelled) = self.state  {
                return cancelled
            } else {
                return false
            }
        }
    }

    
    /// Returns `true` if `self` has been completed. A token will be completed when
    /// a client requests a cancellation via its cancellatoion request, when the
    /// cancellation request deallocates or when the cancellation token is inherently
    /// not mutable (e.g. it is a `CancellationTokenNone`).
    final var isCompleted: Bool {
        return syncQueue.sync {
            if case .completed = self.state  {
                return true
            } else {
                return false
            }
        }
    }


    /// Register a closure which will be called when `self` has been completed with
    /// its argument set to the current value of the completion state (either `true`
    /// or `false`).
    ///
    /// `self` will be retained up until the handlers will be called when `self` has
    /// been completed.
    ///
    /// - parameter f: The closure which will be executed on a private queue when `self` has been completed.
    final func onComplete(f: @escaping (Bool)->()) {
        self.syncQueue.sync {
            switch self.state {
            case .pending(let queue):
                queue.async {
                    // it's safe to access self.state here, since queue's target queue is the sync queue
                    guard case .completed(let cancelled) = self.state else {
                        fatalError("state not completed")
                    }
                    DispatchQueue.global().async {
                        f(cancelled)
                    }
                }
            case .completed(let cancelled):
                DispatchQueue.global().async {
                    f(cancelled)
                }
            }
        }
    }


    /// Returns a new Cancellation Token which will be completed with the return
    /// value of the function `f` when `self` has been cancelled. If `self` has 
    /// not been cancelled the returned cancellation token will be completed with
    /// the value `false` ("not cancelled") as well.
    ///
    /// - Parameter f: Mapping function.
    /// - Returns: A new cancellation token.
    final func map(f: @escaping () -> (Bool)) -> CancellationToken {
        let returnedToken = CancellationToken()
        onComplete { cancelled in
            returnedToken.complete(cancel: cancelled ? f() : false)
        }
        return returnedToken
    }


    /// Returns a new Cancellation Token which will be completed with the returned 
    /// _deferred_ cancellation state of the function `f` when `self` has been cancelled.
    /// If `self` has not been cancelled the returned cancellation token will be 
    /// completed with "not cancelled" as well.
    ///
    /// - Parameter f: Mapping function.
    /// - Returns: A new cancellation token.
    final func flatMap(f: @escaping () -> (CancellationTokenType)) -> CancellationToken {
        let returnedToken = CancellationToken()
        onComplete { cancelled in
            if cancelled {
                returnedToken.completeWith(f())
            } else {
                returnedToken.complete(cancel: false)
            }
        }
        return returnedToken
    }



    internal final func complete(cancel: Bool) {
        syncQueue.sync {   // TODO: consider using async
            switch self.state {
            case .completed: return
            case .pending(let queue):
                self.state = .completed(cancel)
                queue.resume()
            }
        }
    }

    internal final func completeWith(_ other: CancellationTokenType) {
        other.onComplete {  otherValue in
            self.complete(cancel: otherValue)
        }
    }

}
