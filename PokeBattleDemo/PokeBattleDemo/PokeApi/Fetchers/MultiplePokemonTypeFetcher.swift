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

/// Delegate for a multiple pokemon type fetcher.
protocol MultiplePokemonTypeFetcherDelegate: class {
    
    /// Called after the fetch operation has completed.
    ///
    /// - parameter fetcher: Reference on the fetcher that has completed the operation.
    /// - parameter success: True if the operation succeeded, false otherwise.
    /// - parameter result: The retrieved type array if successful, nil otherwise.
    /// - parameter error: Error object if the operation failed, nil if it succeeded.
    func didGetPokemonTypeArray(fetcher: MultiplePokemonTypeFetcher, success: Bool, result: [PokemonType]?, error: NSError?)
}

/// Only supports random fetching now.
class MultiplePokemonTypeFetcher {
    
    //
    // MARK: Stored properties
    //
    
    weak var delegate: MultiplePokemonTypeFetcherDelegate?
    
    private var pokemonTypeFetchers: [PokemonTypeFetcher] = []

    private let pokemonTypeIdentifiers: [PokemonTypeIdentifier]
    
    private var pokemonTypeArray: [PokemonType] = []
    
    private var success: Bool = true
    private var error: NSError?
    
    private let dispatchGroup = dispatch_group_create();
    
    //
    // MARK: Initialization
    //
    
    init(pokemonTypeIdentifiers: [PokemonTypeIdentifier]) {
        
        self.pokemonTypeIdentifiers = pokemonTypeIdentifiers
    }
}

extension MultiplePokemonTypeFetcher {
    
    func fetch() {
        
        for typeIdentifier in self.pokemonTypeIdentifiers {
            
            let typeFetcher = PokemonTypeFetcher(pokemonTypeIdentifier: typeIdentifier)
            typeFetcher.delegate = self
            pokemonTypeFetchers.append(typeFetcher)
            
            dispatch_group_enter(dispatchGroup)
            
            typeFetcher.fetch()
            
        }
        
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            dispatch_group_wait(strongSelf.dispatchGroup, DISPATCH_TIME_FOREVER)
            
            strongSelf.delegate?.didGetPokemonTypeArray(strongSelf
                , success: strongSelf.success
                , result: strongSelf.pokemonTypeArray
                , error: strongSelf.error)
        }
    }
}

extension MultiplePokemonTypeFetcher : PokemonTypeFetcherDelegate {
    
    func didGetPokemonType(fetcher: PokemonTypeFetcher, success: Bool, result: PokemonType?, error: NSError?) {
    
        defer {
            
            dispatch_group_leave(dispatchGroup)
            pokemonTypeFetchers = pokemonTypeFetchers.filter( { $0 !== fetcher} )
        }
        
        guard let pokemonTypeInstance = result where success == true else {
            
            self.success = false
            self.error = error
            
            return
        }
        
        self.pokemonTypeArray.append(pokemonTypeInstance)
    }
}
