//
//  PokemonTypeCache.swift
//  PokeBattleDemo
//
//  Created by Pascal Jette on 4/16/16.
//  Copyright © 2016 Pascal Jette. All rights reserved.
//

import Foundation


class PokemonTypeCache {
    
    // Singleton pattern
    static let sharedInstance = PokemonTypeCache()
    
    private init() {
    
    }
    
    func downloadAndCacheMultiple(allIdentifiers: [PokemonTypeIdentifier]) {
        
        for identifier in allIdentifiers {
            
            downloadAndCache(identifier)
        }
    }
    
    func downloadAndCache(pokemonTypeIdentifier: PokemonTypeIdentifier) {
        
        let pokemonTypeFetcher: PokemonTypeFetcher = PokemonTypeFetcher(pokemonTypeIdentifier: pokemonTypeIdentifier)
        
        pokemonTypeFetcher.fetch()
    }
    
    func isCachedForIdentifier(pokemonTypeIdentifier: PokemonTypeIdentifier) -> Bool {
        
        return cachedTypeForIdentifier(pokemonTypeIdentifier) != nil
    }
    
    func cachedTypeForIdentifier(pokemonTypeIdentifier: PokemonTypeIdentifier) -> PokemonType? {
        
        return cachedTypes.filter( { $0.typeIdentifier.name == pokemonTypeIdentifier.name } ).first
    }
    
    var cachedTypes: [PokemonType] = []
}
