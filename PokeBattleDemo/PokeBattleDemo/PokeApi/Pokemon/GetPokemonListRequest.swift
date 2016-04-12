//
//  GetPokemonListRequest.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation


class GetPokemonListRequest : PokeApiRequestBase {
    
    // Force to have an init method even if it is empty for creatin in Generics.
    required init() {
        
    }
    
    var apiPath: String {
     
        return "/api/v2/pokemon"
    }
    
    var queryItems: [NSURLQueryItem]? {
        
        return [NSURLQueryItem(name: "limit", value: "1000")]
    }
}
