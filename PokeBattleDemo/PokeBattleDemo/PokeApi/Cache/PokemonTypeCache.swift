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

