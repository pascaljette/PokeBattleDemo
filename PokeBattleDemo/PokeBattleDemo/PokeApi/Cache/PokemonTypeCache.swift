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
    
    private var activeMultipleFetchers: [MultiplePokemonTypeFetcher] = []
    
    var dispatchGroup = dispatch_group_create()
    
    private init() {
    
    }
    
    func downloadAndCacheMultiple(allIdentifiers: [PokemonTypeIdentifier]) {
        
        let multipleTypeFetcher = MultiplePokemonTypeFetcher(pokemonTypeIdentifiers: allIdentifiers)
        multipleTypeFetcher.delegate = self
        
        dispatch_group_enter(dispatchGroup)
        
        activeMultipleFetchers.append(multipleTypeFetcher)
        
        multipleTypeFetcher.fetch()
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
    
    func didGetPokemonType(fetcher: PokemonTypeFetcher, success: Bool, result: PokemonType?, error: NSError?) {
        
        defer {
            
            dispatch_group_leave(dispatchGroup)
            activeFetchers = activeFetchers.filter( { $0 !== fetcher} )

        }
        
        if let typeInstance = result where success == true {
            
            if !cachedTypes.contains( {$0.typeIdentifier.name == typeInstance.typeIdentifier.name} ) {
                
                cachedTypes.append(typeInstance)
            }
        }
    }
}

extension PokemonTypeCache : MultiplePokemonTypeFetcherDelegate {
    
    func didGetPokemonTypeArray(fetcher: MultiplePokemonTypeFetcher, success: Bool, result: [PokemonType]?, error: NSError?) {
    
        defer {
            
            dispatch_group_leave(dispatchGroup)
            activeMultipleFetchers = activeMultipleFetchers.filter( { $0 !== fetcher} )
        }
        
        if let typeArrayInstance = result where success == true {
            
            for typeInstance in typeArrayInstance {
                
                if !cachedTypes.contains( {$0.typeIdentifier.name == typeInstance.typeIdentifier.name} ) {
                    
                    cachedTypes.append(typeInstance)
                }
            }
        }
    }
}

