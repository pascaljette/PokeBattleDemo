//
//  BattleEngine.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/17/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation

class BattleEngine {

    private var BASE_DAMAGE: Double {
        return 10.0
    }
    
    func fight(player1 player1: Player, player2: Player) -> BattleResult {
        
        // first wait for the cache dispatch group to finish.
        // TODO there might be a better way to do this. At least show an indicator that 
        // we are waiting for a better UX
        dispatch_group_wait(PokemonTypeCache.sharedInstance.dispatchGroup, DISPATCH_TIME_FOREVER)
        
        let player1Result = PlayerResult(player: player1, score: dealDamageFromPlayer(player1, toPlayer: player2))
        let player2Result = PlayerResult(player: player2, score: dealDamageFromPlayer(player2, toPlayer: player1))

        return BattleResult(player1Result: player1Result, player2Result: player2Result)
    }
    
    private func dealDamageFromPlayer(player: Player, toPlayer: Player) -> Double {
        
        var totalDamage: Double = 0
        
        for pokemon in player.pokemonDraw {
            
            for targetPokemon in toPlayer.pokemonDraw {
                
                totalDamage += dealDamageFromPokemon(pokemon, toPokemon: targetPokemon)
            }
        }
        
        return totalDamage
    }
    
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
        
        // Calculate the damage
        for sourceTypeIdentifier in pokemon.types {
            
            if let sourceTypeInstance = PokemonTypeCache.sharedInstance.cachedTypeForIdentifier(sourceTypeIdentifier) {
                
                totalDamage += dealDamageFromType(sourceTypeInstance, toTypes: targetTypes)
            } else {
                
                print("TYPE \(sourceTypeIdentifier.name) not cache yet!")
            }
        }
        
        return totalDamage
    }
    
    private func dealDamageFromType(pokemonType: PokemonType, toTypes: [PokemonType]) -> Double {
        
        var totalDamage: Double = 0
        
        for toType in toTypes {
            
            if pokemonType.noDamageToTypes.contains( { $0.name == toType.typeIdentifier.name} ) {
                
                continue
            
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
