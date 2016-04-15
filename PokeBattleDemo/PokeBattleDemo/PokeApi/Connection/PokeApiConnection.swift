//
//  PokeApiConnection.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

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
            
            self.onCompletion?(.UrlError, nil, nil)
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
