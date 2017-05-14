# Cancellation

[![Build Status](https://travis-ci.org/couchdeveloper/Cancellation.svg?branch=master)](https://travis-ci.org/couchdeveloper/Cancellation) [![GitHub license](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](http://www.apache.org/licenses/LICENSE-2.0) [![Swift 3.0](https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat)](https://developer.apple.com/swift/) ![Platforms MacOS | iOS | tvOS | watchOS](https://img.shields.io/badge/Platforms-OS%20X%20%7C%20iOS%20%7C%20tvOS%20%7C%20watchOS-brightgreen.svg) [![Carthage Compatible](https://img.shields.io/badge/Carthage-Compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![CocoaPods](https://img.shields.io/badge/CocoaPods-available-370301.svg)](https://cocoapods.org/?q=Cancellation)


----------------------------------------

## Overview

The `Cancellation` library enables any cancelable task and even quite complex systems of asynchronous tasks to be cancelled in a safe and effective manner.

The approach chosen to solve this task separates the perspective of a client which creates a task and possibly wants to cancel it later and the perspective of the task which needs to get notified about the cancellation request.

For the perspective of the client the library provides the class `CancellationRequest`. A client simply creates an instance using the default initializer:

```Swift
self.cancellationRequest = CancellationRequest()
```
which then can be used later to perform a "cancellation request":
```Swift
self.cancellationRequest = cancel()
```

Now, in order associate a cancelable asynchronous task with this cancelation request, the cancellation request has one _Cancellation Token_. This cancellation token can be used to register one or more cancellation handlers or it can be queried about its state, that is, obtain a boolean value which indicates that the client has requested a cancellation. The cancellation request's cancellation token is passed as a parameter to a function that starts its underlying asynchronous task:

> **Note:**  
 The library exposes a _Cancellation Token_ as a protocol `CancellationTokenType`.

```Swift
let cr = CancellationRequest()
task(param: param, cancellationToken: cr.token) { (result, error) in
  ...
}
```

The implementation of the above function `task` must of course monitor the state of the token, so when the client requested a cancellation, the state of the token changes to "cancelled", and the task should cancel its underlying operation.

Basically, there are two ways to achieve this:

 1. Polling

 The cancellation token has a property `isCancelled`. It becomes `true` when the client requested a cancellation. The task must periodically query the property and then abort the operation if `isCancelled` returns `true`.

 2. Registering a _Cancellation Handler_

 A Cancellation Token can register one or more "handlers". Actually, there are a few ways to register a handler, `onCancel` is the most straight forward one. The handler will be called when the client has requested a cancellation. This can be utilized to cancel the underlying task.

A handy `URLSession` extension is a perfect example to illustrate the second approach number:
```Swift
extension URLSession {
  func data(from url: URL, cancellationToken: CancellationTokenType, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
    let task = self.dataTask(with: url) { data, response, error in
      completion(data, response, error)

    cancellationToken.onCancel { [weak task] in
      task?.cancel()
    }
    task.resume()
  }   
}
```

 We should notice, that in order to not keeping a reference to the data task _longer_ than necessary, it is important, that the cancellation handler _weakly_ captures the data task reference.

 The above rule might be a good practice, but it is difficult to enforce. Due to this, there are further ways to register a handler. Actually, there is a slightly better way to implement the above extension, which is shown further below.



## Installation

### [Carthage](https://github.com/Carthage/Carthage)

Add    
```Ruby
github "couchdeveloper/Cancellation"
```
to your Cartfile.		

In your source files, import the library as follows
```Swift
import Cancellation
```



### [CocoaPods](https://guides.cocoapods.org/using/using-cocoapods.html)

Add the following line to your [Podfile](http://guides.cocoapods.org/using/the-podfile.html):

```ruby
pod 'Cancellation'
```

In your source files, import the library as follows
```Swift
import Cancellation
```

### [SwiftPM](https://github.com/apple/swift-package-manager/tree/master/Documentation)

To use SwiftPM, add this to your Package.swift:

```Swift
.Package(url: "https://github.com/couchdeveloper/Cancellation.git")
```


## Usage

### Example

Here, we define a handy extension for `URLSession` to perform a "GET" request with a function `data` having a cancellation token as an additional parameter.

In order to accomplish this, we implement the monitoring of the token with a function `register`. This takes a `Cancelable` as a parameter. A `Cancelable` is a protocol which declares just one function `func cancel()`. A `URLSessionTask` already naturally conforms to this protocol, we just need to declare it. Using `register` over `onCancel` has the benefit that we do not need to implement a handler at all and thus, since there is no handler we also don't have to take care of the fact that the task should be captured _weakly_ within the handler.

```Swift
extension URLSessionTask: Cancelable {}
extension URLSession {
    func data(from url: URL, cancellationToken: CancellationTokenType, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let task = self.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }
        cancellationToken.register(cancelable: task)
        task.resume()
    }
}
```

Suppose, you want to issue a network request from your view controller. You have defined an instance value, like so
```Swift
var cancellationRequest = CancellationRequest()
```
Then use it as follows:

```Swift
self.cancellationRequest = CancellationRequest() // invalidate any previous obsolete cancellation handlers
URLSession.shared.data(form: url, cancellationToken: self.cancellationRequest.token) { data, response, error in
    // handle (data, response, error)
    ...
}
```
and possibly, you may want to cancel this request (or any other tasks monitoring the cancellation token):
```Swift
override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    self.cancellationRequest.cancel()
}    
```
