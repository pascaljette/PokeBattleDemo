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

class GetPokemonTypeResponse: PokeApiResponseBase {
    
    typealias ModelType = PokemonType
    
    required init(json: JSON) {
        
        model = ModelType()
        
        let typeIdentifier = PokemonTypeIdentifier()
        typeIdentifier.name = json["name"].string ?? ""
        typeIdentifier.infoUrl = json["url"].string ?? ""
        
        model.typeIdentifier = typeIdentifier
        
        guard let damageRelations = json["damage_relations"].dictionary else {
            
            return
        }
        
        for (_,subJson):(String, JSON) in damageRelations["no_damage_to"]! {
            
            let type = PokemonTypeIdentifier()
            type.name = subJson["name"].string ?? ""
            type.infoUrl = subJson["url"].string ?? ""
            
            model.noDamageToTypes.append(type)
        }
        
        for (_,subJson):(String, JSON) in damageRelations["half_damage_to"]! {
            
            let type = PokemonTypeIdentifier()
            type.name = subJson["name"].string ?? ""
            type.infoUrl = subJson["url"].string ?? ""
            
            model.halfDamageToTypes.append(type)
        }

        for (_,subJson):(String, JSON) in damageRelations["double_damage_to"]! {
            
            let type = PokemonTypeIdentifier()
            type.name = subJson["name"].string ?? ""
            type.infoUrl = subJson["url"].string ?? ""
            
            model.doubleDamageToTypes.append(type)
        }
    }
    
    // enforce the fact that every response must be associated with a model
    var model: ModelType
}
