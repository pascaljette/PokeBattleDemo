//
//  GetPokemonListRequest.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

class GetPokemonListRequest {

    required init() {

    }
}

extension GetPokemonListRequest : PokeApiRequestBase {
    
    
    var apiPath: String {
        
        return "/api/v2/pokemon"
    }
    
    var queryItems: [NSURLQueryItem]? {
        
        return [NSURLQueryItem(name: "limit", value: "1000")]
    }
}
