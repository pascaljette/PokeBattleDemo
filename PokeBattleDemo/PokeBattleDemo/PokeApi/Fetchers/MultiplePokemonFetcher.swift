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

protocol MultiplePokemonFetcherDelegate: class {
    
    func didGetPokemonArray(success: Bool, result: [Pokemon]?, error: NSError?)
}

/// Only supports random fetching now.
class MultiplePokemonFetcher {
    
    //
    // MARK: Stored properties
    //
    
    weak var delegate: MultiplePokemonFetcherDelegate?
    
    private var pokemonFetchers: [RandomPokemonFetcher] = []
    private var count: Int
    
    private var pokemonArray: [Pokemon] = []
    private var success: Bool = true
    private var error: NSError?
    
    private let dispatchGroup = dispatch_group_create();
    
    //
    // MARK: Initialization
    //
    
    init(count: Int) {
        
        self.count = count
    }
}

extension MultiplePokemonFetcher {
    
    func fetch(allPokemonList: AllPokemonList) {
        
        for _ in 0..<count {
            
            let pokemonFetcher = RandomPokemonFetcher(allPokemonList: allPokemonList)
            pokemonFetcher.delegate = self
            pokemonFetchers.append(pokemonFetcher)
            
            dispatch_group_enter(dispatchGroup)
            
            pokemonFetcher.fetch()

        }
        
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
    
    func didGetPokemon(success: Bool, result: Pokemon?, error: NSError?) {
     
        defer {
            
            dispatch_group_leave(dispatchGroup)
        }

        guard let pokemonInstance = result where success == true else {
            
            self.success = false
            self.error = error
            
            return
        }
        
        self.pokemonArray.append(pokemonInstance)
    }
}
