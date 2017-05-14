//: Playground - noun: a place where people can play

import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = true

import Cocoa
import Cancellation



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


extension URLSession {
    func data2(from url: URL, cancellationToken: CancellationTokenType, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        let task = self.dataTask(with: url) { data, response, error in
            completion(data, response, error)
        }
        cancellationToken.onCancel { [weak task] in
            task?.cancel()
        }
        task.resume()
    }   
}


extension String: Error {}
let cr = CancellationRequest()
let url = URL(string: "https://www.example.com")!
URLSession.shared.data(from: url, cancellationToken: cr.token) { (data, response, error) in
    guard error == nil, let response = response, let data = data else {
        print("Error: \(error ?? "nil")")
        return
    }
    print(data)
}
DispatchQueue.global().asyncAfter(deadline: .now() + 0.01) {
    cr.cancel()
}