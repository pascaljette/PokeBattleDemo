//
//  GetPokemonListResponse.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation
import SwiftyJSON

class GetPokemonListResponse: PokeApiResponseBase {
    
    typealias ModelType = PokemonList
    
    required init(json: JSON) {
        
        model = PokemonList()
        
        if let allPokemon = json["results"].array {

            for pokemon in allPokemon {
                
                model.pokemonUrlStrings.append(pokemon["url"].string!)
            }
        }
    }
    
    // enforce the fact that every response must be associated with a model
    var model: ModelType
}