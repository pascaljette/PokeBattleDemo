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

/// Player id, differentiates between player 1 and player 2.
enum PlayerId {
    
    /// Player 1
    case PLAYER_1
    
    /// Player 2
    case PLAYER_2
}

/// Representation of a player with their id and pokemons.
struct Player {
    
    //
    // MARK: Stored properties
    //
    
    /// Player id used to differentiate between player 1 and player 2.
    var id: PlayerId
    
    /// Pokemon currently in the player's possession.
    var pokemonDraw: [Pokemon]
    
    //
    // MARK: Initialization
    //
    
    /// Initialize with an id and an array of currently possessed pokemon.
    ///
    /// - parameter id: Player id used to differentiate between player 1 and player 2.
    /// - parameter pokemonDraw: Array of pokemon currently in the player's possession.
    init(id: PlayerId, pokemonDraw: [Pokemon]) {
        
        self.id = id
        self.pokemonDraw = pokemonDraw
    }
}
