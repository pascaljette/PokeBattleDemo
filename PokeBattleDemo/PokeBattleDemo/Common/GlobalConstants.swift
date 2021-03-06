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

/// Constants used globally in the application.
final class GlobalConstants {
    
    /// Base Url for PokeApi.
    class var POKEAPI_BASE_URL: String {
        return "http://pokeapi.co"
    }
    
    /// Number of pokemon per player.
    class var NUMBER_OF_POKEMON_PER_PLAYER: Int {
        return NSBundle.mainBundle().objectForInfoDictionaryKey("PokemonCountPerPlayer") as! Int
    }
    
    // TODO: Put this in a plist or a data file
    /// Number of turn per player.
    class var NUMBER_OF_TURNS_PER_PLAYER: Int {
        return 2
    }

}
