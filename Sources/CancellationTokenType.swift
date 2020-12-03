//
//  Copyright © 2020 Andreas Grosam.
//  Licensed under the Apache License, Version 2.0.
//

import Dispatch

/// The protocol `CancellationTokenType` defines the methods and behavior for a
/// concrete implementation of a _cancellation token_.
///
/// A cancellation token is associated to a corresponding `CancellationRequest`
/// with a one-to-one relationship.
///
/// A cancellation token starts out with an "undefined" state and can then be
/// completed with a value representing a "cancelled" or "not cancelled" state.
/// Completion will be performed by its associated cancellation request value.
/// Once a cancellation token is completed, it cannot change its state anymore.
///
/// A cancellation token is passed from a client to a potentially long lasting task
/// when the client creates this task. The task may now observe the state of the
/// cancellation token via periodically polling its state, or it may _register_ a
/// handler function which will be invoked when the token gets completed.
///
/// When a client requested a cancellation the token will be completed accordingly.
/// When this happens the task should take the appropriate steps to cancel/terminate
/// its operation. It may however also to decide _not_ to cancel its operation, for
/// example when there are yet other clients still waiting for the result. One
/// cancellation token may be shared by many observers.
public protocol CancellationTokenType {

    /// Returns `true` if `self`'s associated `CancellationRequest` has requested
    /// a cancellation. Otherwise, it returns `false`.
    var isCancelled: Bool { get }
    
    /// Returns `true` if `self` has been completed. A token will be completed when
    /// a client requests a cancellation via its cancellatoion request, when the
    /// cancellation request deallocates or when the cancellation token is inherently
    /// not mutable (e.g. it is a `CancellationTokenNone`).
    var isCompleted: Bool { get }


    /// Register a closure which will be called when `self` has been completed with
    /// its argument set to the current value of the completion state (either `true`
    /// or `false`).
    ///
    /// - parameter f: The closure which defines the event handler to be executed
    /// when `self` is completed.
    func onComplete(f: @escaping (Bool)->())
    
    /// Returns a new Cancellation Token which will be completed with the return
    /// value of the function `f` when `self` has been cancelled. If `self` has
    /// not been cancelled the returned cancellation token will be completed with
    /// the value `false` ("not cancelled") as well.
    ///
    /// - Parameter f: Mapping function.
    /// - Returns: A new cancellation token.
    func map(f: @escaping () -> (Bool)) -> Self

    /// Returns a new Cancellation Token which will be completed with the returned
    /// _deferred_ cancellation state of the function `f` when `self` has been cancelled.
    /// If `self` has not been cancelled the returned cancellation token will be
    /// completed with "not cancelled" as well.
    ///
    /// - Parameter f: Mapping function.
    /// - Returns: A new cancellation token.
    func flatMap(f: @escaping () -> (CancellationTokenType)) -> Self

    /// Registers a `Cancelable` whose function `cancel()` will be called on the
    /// specified dispatch queue when 'self'`s associated cancellation request
    /// has been cancelled.
    /// The `Cancelable` value will be kept weekly until after the cancellation
    /// request will be completed.
    /// cancelable should be submitted.
    /// - parameter cancelable: The value whose underlying task should be cancelled.
    /// - parameter queue: A dispatch queue where the `cancel()` function will be 
    ///   submitted, when a canellation is requested.
    func register(cancelable: Cancelable, queue: DispatchQueue)

}

extension CancellationTokenType {

    /// Register a closure which will be called when `self` has been completed with
    /// value `true`, that is, there has been a cancellation requested by means
    /// of the associated cancellation request.
    ///
    /// - parameter f: The closure which defines the handler to be executed
    /// when `self` has been cancelled.
    public func onCancel(f: @escaping ()->()) {
        onComplete { cancelled in
            if cancelled {
                f()
            }
        }
    }

    /// Registers a `Cancelable` whose function `cancel()` will be called on a
    /// private dispatch queue when 'self'`s associated cancellation request
    /// has been cancelled.
    /// The `Cancelable` value will be kept weekly until after the cancellation
    /// request will be completed.
    /// cancelable should be submitted.
    /// - parameter cancelable: The value whose underlying task should be cancelled.
    public func register(cancelable: Cancelable) {
        register(cancelable: cancelable, queue: cancellationQueue)
    }

    /// Registers a `Cancelable` whose function `cancel()` will be called on the
    /// specified dispatch queue when 'self'`s associated cancellation request
    /// has been cancelled.
    /// The `Cancelable` value will be kept weekly until after the cancellation
    /// request will be completed.
    /// cancelable should be submitted.
    /// - parameter cancelable: The value whose underlying task should be cancelled.
    /// - parameter queue: A dispatch queue where the `cancel()` function will be
    ///   submitted, when a canellation is requested.
    public func register(cancelable: Cancelable, queue: DispatchQueue) {
        self.onComplete { [weak cancelable] cancelled in
            guard let cancelable = cancelable, cancelled == true else { return }
            cancelable.cancel()
        }
    }

}
