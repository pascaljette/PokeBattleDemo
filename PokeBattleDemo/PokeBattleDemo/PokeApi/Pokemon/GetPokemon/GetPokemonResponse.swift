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

/// Response gotten when getting a single pokemon info from the API.
class GetPokemonResponse: PokeApiResponseBase {
    
    //
    // MARK: PokeApiResponseBase implementation
    //
    
    /// Model type
    typealias ModelType = Pokemon
    
    /// Initialize from json.
    ///
    /// - parameter json: JSON or subJSON data with which to initialize.
    required init(json: JSON) {
        
        model = ModelType()
        
        model.name = json["name"].string ?? ""
        model.spriteUrl = json["sprites"].dictionary?["front_default"]?.string ?? ""
        
        for (_, typeElement) in json["types"] {
            
            let type = PokemonTypeIdentifier(name: typeElement["type"]["name"].string ?? ""
                , infoUrl: typeElement["type"]["url"].string ?? "")
            
            model.types.append(type)
        }
    }
    
    /// Model instance.
    var model: ModelType
}
