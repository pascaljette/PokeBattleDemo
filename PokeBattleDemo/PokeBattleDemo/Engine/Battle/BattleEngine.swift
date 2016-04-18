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

/// Engine for damage calculation and battle flow when the pokemon have been decided and are 
/// prepared to fight.
/// Damage is based on what is described here: http://bulbapedia.bulbagarden.net/wiki/Type
/// However, every pokemon is considered to possess only one ability that corresponds to the
/// pokemon's innate type.
class BattleEngine {

    //
    // MARK: Public methods
    //

    /// Calculate a battle result based on both players' pokemons.  Note that this methods waits
    /// until the pokemon type cache is fully populated in order to be able to perform its 
    /// calculations, therefore it might block whichever thread it is called on.
    ///
    /// - parameter player1: Instance of the first player, containing their pokemon draw.
    /// - parameter player2: Instance of the second player, containing their pokemon draw.
    ///
    /// - returns: Battle Result calculated from both players pokemon draw.
    func fight(player1 player1: Player, player2: Player) -> BattleResult {
        
        // first wait for the cache dispatch group to finish.
        // TODO there might be a better way to do this. At least show an indicator that 
        // we are waiting for a better UX
        dispatch_group_wait(PokemonTypeCache.sharedInstance.dispatchGroup, DISPATCH_TIME_FOREVER)
        
        let player1Result = PlayerResult(player: player1, score: dealDamageFromPlayer(player1, toPlayer: player2))
        let player2Result = PlayerResult(player: player2, score: dealDamageFromPlayer(player2, toPlayer: player1))

        return BattleResult(player1Result: player1Result, player2Result: player2Result)
    }
 
}

extension BattleEngine {
    
    //
    // MARK: Class variables
    //

    /// Base damage done by a type to another.  Used as a basis to calculate
    /// half and double damange based on type strengths and weakenesses.
    private var BASE_DAMAGE: Double {
        return 10.0
    }
}

extension BattleEngine {
    
    //
    // MARK: Private damage methods
    //

    /// Calculates the damage a player deals to another.
    ///
    /// - parameter player: The player dealing the damage.
    /// - parameter toPlayer: The player on the receiving end of the attack.
    ///
    /// - returns: Total number of damage dealt from player to toPlayer.
    private func dealDamageFromPlayer(player: Player, toPlayer: Player) -> Double {
        
        var totalDamage: Double = 0
        
        // Add the damage dealt from player to toPlayer for each of their pokemon.
        for pokemon in player.pokemonDraw {
            
            for targetPokemon in toPlayer.pokemonDraw {
                
                totalDamage += dealDamageFromPokemon(pokemon, toPokemon: targetPokemon)
            }
        }
        
        return totalDamage
    }
    
    /// Calculates the damage a pokemon deals to another based only on their innate types.
    ///
    /// - parameter pokemon: The pokemon dealing the damage.
    /// - parameter toPokemon: The pokemon on the receiving end of the attack.
    ///
    /// - returns: Total number of damage dealt from pokemon to toPokemon.
    private func dealDamageFromPokemon(pokemon: Pokemon, toPokemon: Pokemon) -> Double {
        
        var totalDamage: Double = 0
        
        var targetTypes: [PokemonType] = []
        
        // Build target types from cache
        for targetTypeIdentifier in toPokemon.types {
            
            if let targetTypeInstance = PokemonTypeCache.sharedInstance.cachedTypeForIdentifier(targetTypeIdentifier) {
                
                targetTypes.append(targetTypeInstance)
                
            } else {
                
                print("TYPE \(targetTypeIdentifier.name) not cache yet!")
            }
        }
        
        // Calculate the damage from damage dealer type array to enemy's type array.
        for sourceTypeIdentifier in pokemon.types {
            
            if let sourceTypeInstance = PokemonTypeCache.sharedInstance.cachedTypeForIdentifier(sourceTypeIdentifier) {
                
                totalDamage += dealDamageFromType(sourceTypeInstance, toTypes: targetTypes)
                
            } else {
                
                print("TYPE \(sourceTypeIdentifier.name) not cache yet!")
            }
        }
        
        return totalDamage
    }
    
    /// Calculates the damage a type deals to the array of receiving types.
    ///
    /// - parameter pokemon: The type dealing the damage.
    /// - parameter toPokemon: The type array on the receiving end of the attack.
    ///
    /// - returns: Total number of damage dealt from type to toTypes (array0.
    private func dealDamageFromType(pokemonType: PokemonType, toTypes: [PokemonType]) -> Double {
        
        var totalDamage: Double = 0
        
        for toType in toTypes {
            
            // If a type in the array is resistant from the damage dealer type, the total damange will be 0.
            if pokemonType.noDamageToTypes.contains( { $0.name == toType.typeIdentifier.name} ) {
                
                return 0.0
                
            } else if pokemonType.halfDamageToTypes.contains( { $0.name == toType.typeIdentifier.name} ) {
                
                totalDamage += 0.5 * BASE_DAMAGE
                
            } else if pokemonType.doubleDamageToTypes.contains( { $0.name == toType.typeIdentifier.name} ) {
                
                totalDamage += 2 * BASE_DAMAGE
                
            } else {
                
                totalDamage += BASE_DAMAGE
            }
        }
        
        return totalDamage
    }
}
