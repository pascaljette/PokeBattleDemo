//
//  PokeApiRequestBase.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

protocol PokeApiRequestBase {
    
    // Force to have an init method even if it is empty for creatin in Generics.
    init()
    
    var apiPath: String { get }
    var queryItems: [NSURLQueryItem]? { get }
}

extension PokeApiRequestBase {
    
    var baseUrlString: String {
        
        return GlobalConstants.POKEAPI_BASE_URL
    }
    
    var absoluteUrl: NSURL? {
        
        guard let url: NSURL = NSURL(string: baseUrlString) else {
            
            print("Could not form url from string \(baseUrlString)")
            return nil;
        }
        
        guard let components: NSURLComponents = NSURLComponents(URL: url, resolvingAgainstBaseURL: true) else {
            
            print("Could not find URL components from string \(baseUrlString)")
            return nil;
        }
        
        // NSURLComponents does not get fully initialized, even passing a NSURL in its constructor.
        // We must do it manually.  There might be a better way (XCode 7.2)
        components.scheme = url.scheme
        components.host = url.host
        components.path = apiPath
        components.queryItems = queryItems
                
        return components.URL;
    }
}
