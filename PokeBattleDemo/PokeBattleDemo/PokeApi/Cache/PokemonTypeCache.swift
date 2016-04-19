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

/// Cache for pokemon type.  All pokemon types, when downloaded, will be saved in this cache.
/// All functionalities who require the full info for a pokemon type will first try to retrieve 
/// it from cache, and if it doesn't exist, fetch it and wait until the fetch is completed.
class PokemonTypeCache {
    
    //
    // MARK: Singleton pattern
    //
    
    /// Shared instance.
    static let sharedInstance = PokemonTypeCache()
    
    /// Private singleton initialiser.
    private init() {
        
    }
    
    //
    // MARK: Stored properties
    //
    
    // TODO this should be a dictionary to be able to clear when multiple calls are made.
    // Right now we are using this only to keep references to the fetchers so they don't
    // get de-allocated.
    
    /// Reference on all active single fetchers.
    private var activeFetchers: [PokemonTypeFetcher] = []
    
    /// Reference on all active multiple fetchers.
    private var activeMultipleFetchers: [MultiplePokemonTypeFetcher] = []
    
    /// Dispatch group for synchronization.
    var dispatchGroup = dispatch_group_create()

    /// All cached types.
    var cachedTypes: [PokemonType] = []
}

extension PokemonTypeCache {
    
    //
    // MARK: Public cache methods
    //

    /// Download and cache from multiple identifiers.
    ///
    /// - parameter allIdentifiers: Array of identifiers to download and cache.
    func downloadAndCacheMultiple(allIdentifiers: [PokemonTypeIdentifier]) {
        
        // First, filter out all identifiers that have already been cached.
        let identifiersToDownload = allIdentifiers.filter( { singleIdentifier in
            !cachedTypes.contains({ cachedType in
                singleIdentifier.name == cachedType.typeIdentifier.name
            })
        })
        
        guard !identifiersToDownload.isEmpty else {
            
            return
        }
        
        let multipleTypeFetcher = MultiplePokemonTypeFetcher(pokemonTypeIdentifiers: identifiersToDownload)
        
        multipleTypeFetcher.delegate = self
        
        dispatch_group_enter(dispatchGroup)
        
        activeMultipleFetchers.append(multipleTypeFetcher)
        
        multipleTypeFetcher.fetch()
    }
    
    /// Download and cache from a single identifier.
    ///
    /// - parameter pokemonTypeIdentifier: Identifier of the type to download and cache.
    func downloadAndCache(pokemonTypeIdentifier: PokemonTypeIdentifier) {
        
        guard !isCachedForIdentifier(pokemonTypeIdentifier) else {
            
            return
        }
        
        let pokemonTypeFetcher: PokemonTypeFetcher = PokemonTypeFetcher(pokemonTypeIdentifier: pokemonTypeIdentifier)
        pokemonTypeFetcher.delegate = self
        
        dispatch_group_enter(dispatchGroup)
        
        activeFetchers.append(pokemonTypeFetcher)
        
        pokemonTypeFetcher.fetch()
    }
    
    /// Check if an identifier is already cached.
    ///
    /// - parameter pokemonTypeIdentifier: Identifier (name) of the type to check.
    ///
    /// - returns: True if there is a cached entry for that identifier, false otherwise.
    func isCachedForIdentifier(pokemonTypeIdentifier: PokemonTypeIdentifier) -> Bool {
        
        return cachedTypeForIdentifier(pokemonTypeIdentifier) != nil
    }
    
    /// Returns the cached type for a given identifier.
    ///
    /// - parameter pokemonTypeIdentifier: Identifier (name) of the type to check.
    ///
    /// - returns: The cached type if it exists, nil if it does not.
    func cachedTypeForIdentifier(pokemonTypeIdentifier: PokemonTypeIdentifier) -> PokemonType? {
        
        return cachedTypes.filter( { $0.typeIdentifier.name == pokemonTypeIdentifier.name } ).first
    }
}

extension PokemonTypeCache : PokemonTypeFetcherDelegate {
    
    //
    // MARK: PokemonTypeFetcherDelegate implementation
    //
    
    /// Called after the fetch operation has completed.
    ///
    /// - parameter fetcher: Reference on the fetcher that has completed the operation.
    /// - parameter success: True if the operation succeeded, false otherwise.
    /// - parameter result: The retrieved type if successful, nil otherwise.
    /// - parameter error: Error object if the operation failed, nil if it succeeded.
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
    
    //
    // MARK: MultiplePokemonTypeFetcherDelegate implementation
    //
    
    /// Called after the fetch operation has completed.
    ///
    /// - parameter fetcher: Reference on the fetcher that has completed the operation.
    /// - parameter success: True if the operation succeeded, false otherwise.
    /// - parameter result: The retrieved type array if successful, nil otherwise.
    /// - parameter error: Error object if the operation failed, nil if it succeeded.
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

