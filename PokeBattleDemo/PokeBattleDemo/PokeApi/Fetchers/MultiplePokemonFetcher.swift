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

/// Delegate for a fetcher that retrieves multiple random pokemon.
protocol MultiplePokemonFetcherDelegate: class {
    
    /// Did get the pokemon array.
    ///
    /// - parameter success: Whether the list retrieval succeeded.
    /// - parameter result: Retrieved list or nil on failure.
    /// - parameter error: Error object or nil on failure.
    func didGetPokemonArray(success: Bool, result: [Pokemon]?, error: NSError?)
}

/// Only supports random fetching now.
class MultiplePokemonFetcher {
    
    //
    // MARK: Stored properties
    //
    
    /// Weak reference on the delegate
    weak var delegate: MultiplePokemonFetcherDelegate?
    
    /// Internal list of single pokemon fetchers.
    private var pokemonFetchers: [RandomPokemonFetcher] = []
    
    /// Count of pokemon to retrieve.
    private var count: Int
    
    /// Internal pokemon array to pass to the delegate.
    private var pokemonArray: [Pokemon]?
    
    /// Internal success flag to pass to the delegate.
    private var success: Bool = true
    
    /// Internal reference on error object to pass to the delegate.
    private var error: NSError?
    
    /// Internal dispatch group for thread synchronisation.
    private let dispatchGroup = dispatch_group_create();
    
    //
    // MARK: Initialization
    //
    
    /// Initialise based on a count of pokemon to retrieve.  An equal amount of single
    /// pokemon fetchers will be created.
    ///
    /// - parameter count: Number of pokemon to retrieve.
    init(count: Int) {
        
        self.count = count
    }
}

extension MultiplePokemonFetcher {
    
    //
    // MARK: Public functions
    //
    
    /// Fetch the data and calls the delegate on completion.
    ///
    /// - parameter allPokemonList: List of all available pokemon on which to retrieve an array of 
    /// random detailed entries.
    func fetch(allPokemonList: AllPokemonList) {
        
        // Generate fetchers for :count: pokemon and start the fetch operation.
        for _ in 0..<count {
            
            let pokemonFetcher = RandomPokemonFetcher(allPokemonList: allPokemonList)
            pokemonFetcher.delegate = self
            pokemonFetchers.append(pokemonFetcher)
            
            dispatch_group_enter(dispatchGroup)
            
            pokemonFetcher.fetch()

        }
        
        // Start another thread that will wait on all single fetchers to complete
        // and will then call the delegate with the full pokemon array.
        // Another thread is needed in case the fetch function is called from the main thread.
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0)) { [weak self] in
            
            guard let strongSelf = self else {
                
                return
            }
            
            dispatch_group_wait(strongSelf.dispatchGroup, DISPATCH_TIME_FOREVER)
            
            strongSelf.delegate?.didGetPokemonArray(strongSelf.success
                , result: strongSelf.pokemonArray
                , error: strongSelf.error)
        }
    }
}

extension MultiplePokemonFetcher : RandomPokemonFetcherDelegate {
    
    //
    // MARK: RandomPokemonFetcherDelegate implementation
    //

    /// Did get random pokemon from a single fetcher.
    ///
    /// - parameter success: Whether the list retrieval succeeded.
    /// - parameter result: Retrieved list or nil on failure.
    /// - parameter error: Error object or nil on failure.
    func didGetPokemon(success: Bool, result: Pokemon?, error: NSError?) {
     
        defer {
            
            dispatch_group_leave(dispatchGroup)
        }

        guard let pokemonInstance = result where success == true else {
            
            self.success = false
            self.error = error
            self.pokemonArray = nil
            
            return
        }
        
        if pokemonArray == nil {
            
            pokemonArray = []
        }
        
        self.pokemonArray!.append(pokemonInstance)
    }
}
