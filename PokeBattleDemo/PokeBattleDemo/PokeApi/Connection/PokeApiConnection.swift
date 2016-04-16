// The MIT License (MIT)
//
// Copyright (c) 2015 pascaljette
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import Foundation
import SwiftyJSON


enum PokeapiConnectionStatus {
    
    case Success
    case ConnectionError
    case UrlError
}

class PokeApiConnection<RequestType: PokeApiRequestBase, ResponseType: PokeApiResponseBase> {
    
    typealias OnCompletion = (PokeapiConnectionStatus, NSError?, ResponseType?) -> Void
    
    var onCompletion: OnCompletion?
    
    init() {
        
    }
    
    func execute() {
        
        performCall(RequestType())
    }
    
    func execute(request: RequestType) {
        
        performCall(request)
    }
    
    private func performCall(request: RequestType) {
        
        // TODO-pk add log or error handling here
        guard let requestFullUrl = request.absoluteUrl else {

            let error: NSError = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
            self.onCompletion?(.UrlError, error, nil)
            return
        }
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(requestFullUrl) {(data, response, error) in
            
            guard error == nil else {
                
                self.onCompletion?(.ConnectionError, error, nil)
                return
            }
            
            if let dataInstance = data {
                
                let json: JSON = JSON(data: dataInstance);
                
                let response: ResponseType = ResponseType(json: json);
                
                self.onCompletion?(.Success, nil, response)
            }
        }
        
        task.resume()
    }
}
