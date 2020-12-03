//
//  Copyright © 2020 Andreas Grosam.
//  Licensed under the Apache License, Version 2.0.
//

/// A `CancellationRequest` is a means to let a client signal one or more tasks 
/// that it is no more interested in the result and that the tasks should stop
/// as soon as possible, that is, "cancel" their operation.
public final class CancellationRequest {

    // A CancellationRequest keeps a strong reference to the shared CancellationState
    private let _token = CancellationToken()

    /// Creates and initializes a cancellation request.
    public init() {}

    deinit {
        // If the CancellationState is not yet completed, complete is with "not cancelled":
        self._token.complete(cancel: false)
    }

    /// Returns `true` if a cancellation has been requested.
    public final var isCancellationRequested: Bool {
        return self._token.isCancelled
    }

    /// Request a cancellation. Clients will call this method in order to signal
    /// a cancellation request to any object which has registered handlers with
    /// `self`'s cancelation token.
    ///
    /// Cancellation is asynchronous, that is, the effect of requesting a cancellation
    /// may not yet be visible on the same thread immediately after `cancel` returns.
    ///
    /// `self` will be retained up until all registered handlers have been finished
    /// executing.
    public final func cancel() {
        self._token.complete(cancel: true)
    }

    /// Returns `self`'s associated cancellation token.
    public final var token: CancellationTokenType {
        return _token
    }

}

extension CancellationRequest: CustomDebugStringConvertible {

    /// - returns: A description of `self`.
    public var debugDescription: String {
        let stateString: String = self.isCancellationRequested == true
            ? "cancellation requested"
            : "no cancellation requested"
        return "CancellationRequest state: \(stateString)"
    }

}
