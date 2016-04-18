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
import UIKit

/// Model representing a pokemon.  We store only the information we need from the massive JSON from
/// PokeApi.
struct Pokemon : PokeApiModelBase {
    
    //
    // MARK: Stored properties
    //

    /// Pokemon name.
    var name: String = ""
    
    /// String representing the URL to retrieve the pokemon's image.
    var spriteUrl: String = ""
    
    /// List of type identifiers associated with this pokemon.
    var types: [PokemonTypeIdentifier] = []
    
    //
    // MARK: Stored properties
    //

    /// Required by PokeApiModelBase
    init() {
        
    }
    
    /// Initialize with a name and sprite Url
    ///
    /// - parameter name: Pokemon name.
    /// - paramater spriteUrl: String representing the URL to retrieve the pokemon's image.
    init(name: String, spriteUrl: String) {
        
        self.name = name
        self.spriteUrl = spriteUrl
    }    
}
