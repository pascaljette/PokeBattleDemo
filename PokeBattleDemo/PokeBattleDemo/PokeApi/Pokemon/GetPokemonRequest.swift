//
//  GetPokemonListRequest.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

class GetPokemonRequest {
    
    var pokemonFullUrl: String = ""
    
    required init() {

    }
    
    init(fullUrl: String) {
        
        self.pokemonFullUrl = fullUrl
    }
}

extension GetPokemonRequest : PokeApiRequestBase {
    
    var apiPath: String {
        
        /// TODO better error handling
        guard let url: NSURL = NSURL(string: pokemonFullUrl) else {
            
            print("could not build URL")
            return ""
        }
        
        return url.path ?? ""
    }
    
    var queryItems: [NSURLQueryItem]? {
        
        return [NSURLQueryItem(name: "limit", value: "1000")]
    }

}

