

import Foundation
import Dispatch

enum Result<T> {
    case error(Error)
    case success(T)
}

class Promise<T> {
    
    let dispatchQueue: DispatchQueue
    
    let future: Future<T>
    
    init() {
        
        future = Future<T>()
        
        dispatchQueue = DispatchQueue(label: "promise",
                                      qos: .userInitiated,
                                      attributes: .concurrent)
    }
    
    func completeWithSuccess(value: T) {
        future.notify(.success(value))
    }
    
    func completeWithFail(error: Error) {
        future.notify(.error(error))
    }
    
}


class Future<T> {
    
    var dispatchQueue: DispatchQueue?
    var onCompletion: (@escaping (T)->Void)?
    var onFailure: (@escaping (Error)->Void)?
    
    public init() {
        
    }
    
    public func notify(_ value: Result<T>) {
        
        switch value {
        case .success(let a):
            dispatchQueue?.async {
            
                self.onCompletion?(a)
                
            }
        case .error(let error):
            
            self.onFailure?(error)
            
        }
        
    }
    
    /**
    Set up a routine for when the Future has a successful value.
 
    - parameter qos:                Quality service level of the returned completionHandler
    - parameter completionHandler:  Callback with a successful value
    
    - returns: new Future
    */
    public func onSuccess(qos: DispatchQoS,
                          completionHander: @escaping (T)->Void) -> Future<T> {
        
        onCompletion = completionHander
        dispatchQueue = DispatchQueue(label: "future", qos: qos, attributes: .concurrent)
        
        return self
    }
    
    /**
    Set up a routine if there is an error.
    
    - parameter completionHandler:  Callback with an error
 
    - returns: new Future
    */
    public func onFailure(completionHander: @escaping (Error)->Void) -> Future<T> {
        
        onFailure = completionHander
        
        return self
    }
    
}





