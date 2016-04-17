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
    
    // TODO this should be a dictionary to be able to clear when multiple calls are made.
    // Right now we are using this only to keep references to the fetchers so they don't
    // get de-allocated.
    private var activeFetchers: [PokemonTypeFetcher] = []
    
    var dispatchGroup = dispatch_group_create()
    
    var registerCompletion: (() -> Void)?
    
    private init() {
    
    }
    
    func downloadAndCacheMultiple(allIdentifiers: [PokemonTypeIdentifier]) {
        
        for identifier in allIdentifiers {
            
            downloadAndCache(identifier)
        }
        
        dispatch_group_notify(dispatchGroup, dispatch_get_main_queue()) {
            
            self.activeFetchers = []
            self.registerCompletion?()
        }
    }
    
    private func downloadAndCache(pokemonTypeIdentifier: PokemonTypeIdentifier) {
        
        let pokemonTypeFetcher: PokemonTypeFetcher = PokemonTypeFetcher(pokemonTypeIdentifier: pokemonTypeIdentifier)
        pokemonTypeFetcher.delegate = self
        
        dispatch_group_enter(dispatchGroup)
        
        activeFetchers.append(pokemonTypeFetcher)
        
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

extension PokemonTypeCache : PokemonTypeFetcherDelegate {
    
    func didGetPokemonType(success: Bool, result: PokemonType?, error: NSError?) {
        
        dispatch_group_leave(dispatchGroup)
        
        if let typeInstance = result where success == true {
            
            if !cachedTypes.contains( {$0.typeIdentifier.name == typeInstance.typeIdentifier.name} ) {
                
                cachedTypes.append(typeInstance)
            }
        }
    }
}
