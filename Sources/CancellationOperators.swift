//
//  CancellationOperators.swift
//
//  Copyright © 2017 Andreas Grosam. All rights reserved.
//


/// Returns a new cancellation token which will be completed when either of the
/// two operands have been completed. If either operand becomes cancelled, the
/// returned token will be cancelled as well.
///
/// - Parameters:
///   - left: A Cancellation Token as the left operand.
///   - right: A Cancellation Token as the right operand.
/// - Returns: A new cancellation token.
public func || (left: CancellationTokenType, right: CancellationTokenType)
    -> CancellationTokenType 
{
    let returnedToken = CancellationToken()
    left.onCancel {
        returnedToken.complete(cancel: true)
    }
    right.onComplete { cancelled in
        returnedToken.complete(cancel: true)
    }
    return returnedToken
}



/// Returns a new cancellation token which will be completed when both of the
/// two operands have been completed. Both operands must be cancelled in order
/// the returned token will be become cancelled as well.
///
/// - Parameters:
///   - left: A Cancellation Token as the left operand.
///   - right: A Cancellation Token as the right operand.
/// - Returns: A new cancellation token.
public func && (left: CancellationTokenType, right: CancellationTokenType)
    -> CancellationTokenType 
{
    return left.flatMap {
        right.map {true}
    }
}
