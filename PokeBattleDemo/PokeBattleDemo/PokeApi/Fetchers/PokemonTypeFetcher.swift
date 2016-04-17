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

protocol PokemonTypeFetcherDelegate: class {
    
    func didGetPokemonType(success: Bool, result: PokemonType?, error: NSError?)
}

class PokemonTypeFetcher {
    
    typealias GetPokemonTypeConnection = PokeApiConnection<GetPokemonTypeRequest, GetPokemonTypeResponse>
    
    weak var delegate: PokemonTypeFetcherDelegate?
    
    var pokemonTypeIdentifier: PokemonTypeIdentifier
    
    init(pokemonTypeIdentifier: PokemonTypeIdentifier) {
        
        self.pokemonTypeIdentifier = pokemonTypeIdentifier
    }
}

extension PokemonTypeFetcher {
    
    func fetch() {
        
        // Check the cache first
        for cachedType in PokemonTypeCache.sharedInstance.cachedTypes {
            
            if cachedType.typeIdentifier.name == self.pokemonTypeIdentifier.name {
                
                delegate?.didGetPokemonType(true, result: cachedType, error: nil)
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
                strongSelf.delegate?.didGetPokemonType(true, result: response!.model, error: nil)
                                
            case .ConnectionError:
                strongSelf.delegate?.didGetPokemonType(false, result: nil, error: error)
                
            case .UrlError:
                strongSelf.delegate?.didGetPokemonType(false, result: nil, error: error)
            }
        }
        
        call.execute(getPokemonTypeRequest)
    }
}

