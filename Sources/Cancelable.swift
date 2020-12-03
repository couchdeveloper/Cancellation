//
//  Copyright © 2020 Andreas Grosam.
//  Licensed under the Apache License, Version 2.0.
//

/// A `Cancelable` is itself a potentially lengthy task or is associated to one or more tasks, which all
/// can be cancelled.
///
/// Calling cancel on a `Cancelable` _may eventually_ cancel its associated tasks. However, due to the
/// inherently asynchronous behavior of canceling a task there is no guarantee that after requesting a
/// cancellation the Cancelable becomes _immediately_ "cancelled".
///
/// There is even no guarantee that the Cancelable becomes eventually cancelled at all - it may fail or
/// succeed afterward.
public protocol Cancelable: class {

    /// Requests a cancellation for the associated task or tasks.
    ///
    /// An implementation should as soon as possible
    /// cancel the underlying tasks or tasks. If the cancelable is already finished,
    /// no action should be performed.
    func cancel()
}
