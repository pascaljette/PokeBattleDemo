//
//  GetPokemonListResponse.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/12/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation
import SwiftyJSON

class GetPokemonResponse: PokeApiResponseBase {
    
    typealias ModelType = Pokemon
    
    required init(json: JSON) {
        
        model = ModelType()
        
        model.name = json["name"].string ?? ""
        model.spriteUrl = json["sprites"].dictionary?["front_default"]?.string ?? ""
        
        for (_, typeElement) in json["types"] {
            
            let type = PokemonType()
            type.name = typeElement["type"]["name"].string ?? ""
            type.infoUrl = typeElement["type"]["url"].string ?? ""
            
            model.types.append(type)
        }
    }
    
    // enforce the fact that every response must be associated with a model
    var model: ModelType
}
