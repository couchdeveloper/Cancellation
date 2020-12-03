//
//  Copyright © 2020 Andreas Grosam.
//  Licensed under the Apache License, Version 2.0.
//

import Dispatch

/// A special Cancellation Token implementation which represents a token which
/// cannot be cancelled.
public struct CancellationTokenNone: CancellationTokenType {

    /// Initializes a `CancellationTokenNone`.
    ///
    /// - returns: An instance of a CancellationTokenNone.
    public init() {}

    /// Returns always `false`.
    public var isCancelled: Bool { return false }

    /// Returns always `true`.
    public var isCompleted: Bool { return true }

    /// Register a closure which will be called when `self` has been completed with
    /// its argument set to the current value of the completion state (either `true`
    /// or `false`).
    ///
    /// - parameter f: The closure which defines the event handler to be executed
    /// when `self` is completed.
    public func onComplete(f: @escaping (Bool) -> ()) {
        cancellationQueue.async {
            f(false)
        }
    }

    public func map(f: @escaping () -> (Bool)) -> CancellationTokenNone { return CancellationTokenNone() }

    public func flatMap(f: @escaping () -> (CancellationTokenType)) -> CancellationTokenNone { return CancellationTokenNone() }


    /// A NoOp function.
    ///
    /// - parameter queue:      unused
    /// - parameter cancelable: unused
    /// - parameter f:          unused
    ///
    /// - returns: `nil`.
    public func register(cancelable: Cancelable, queue: DispatchQueue) {
        return
    }
    
}
