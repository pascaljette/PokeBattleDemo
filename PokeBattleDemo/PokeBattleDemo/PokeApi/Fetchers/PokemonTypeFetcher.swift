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

/// Delegate for a single pokemon type fetcher.
protocol PokemonTypeFetcherDelegate: class {
    
    /// Called after the fetch operation has completed.
    ///
    /// - parameter fetcher: Reference on the fetcher that has completed the operation.
    /// - parameter success: True if the operation succeeded, false otherwise.
    /// - parameter result: The retrieved type if successful, nil otherwise.
    /// - parameter error: Error object if the operation failed, nil if it succeeded.
    func didGetPokemonType(fetcher: PokemonTypeFetcher, success: Bool, result: PokemonType?, error: NSError?)
}

/// Retrieve detailed info for a single pokemon type.
class PokemonTypeFetcher {
    
    //
    // MARK: Nested types
    //
    
    /// Connection type
    typealias GetPokemonTypeConnection = PokeApiConnection<GetPokemonTypeRequest, GetPokemonTypeResponse>
    
    //
    // MARK: Stored properties
    //
    
    /// Weak reference on the delegate.
    weak var delegate: PokemonTypeFetcherDelegate?
    
    /// Internal reference on the pokemon type identifier (name).
    private var pokemonTypeIdentifier: PokemonTypeIdentifier
    
    //
    // MARK: Initialisation
    //

    /// Initialise with a single pokemon type identifier for which to retrieve detailed info.
    ///
    /// - parameter pokemonTypeIdentifier: Identifier for which to retrieve the detailed type info.
    init(pokemonTypeIdentifier: PokemonTypeIdentifier) {
        
        self.pokemonTypeIdentifier = pokemonTypeIdentifier
    }
}

extension PokemonTypeFetcher {
    
    //
    // MARK: Public functions
    //
    
    /// Fetch the data and calls the delegate on completion.
    func fetch() {
        
        // Check the cache first
        for cachedType in PokemonTypeCache.sharedInstance.cachedTypes {
            
            if cachedType.typeIdentifier.name == self.pokemonTypeIdentifier.name {
                
                delegate?.didGetPokemonType(self, success: true, result: cachedType, error: nil)
            }
        }
        
        let call: GetPokemonTypeConnection = GetPokemonTypeConnection()
        let getPokemonTypeRequest = GetPokemonTypeRequest(fullUrl: pokemonTypeIdentifier.infoUrl)
        
        call.onCompletion = { [weak self] (status, error, response) in
            
            guard let strongSelf = self else {
                
                return
            }
            
            switch status {
                
            case .Success:
                strongSelf.delegate?.didGetPokemonType(strongSelf, success: true, result: response!.model, error: nil)
                                
            case .ConnectionError:
                strongSelf.delegate?.didGetPokemonType(strongSelf, success: false, result: nil, error: error)
                
            case .UrlError:
                strongSelf.delegate?.didGetPokemonType(strongSelf, success: false, result: nil, error: error)
            }
        }
        
        call.execute(getPokemonTypeRequest)
    }
}

